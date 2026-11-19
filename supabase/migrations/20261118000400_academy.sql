-- =============================================================================
-- Academy: courses, modules, lessons, enrolments, progress, quizzes and
-- verifiable certificates.
-- =============================================================================

create type public.course_level as enum ('beginner', 'intermediate', 'advanced', 'all_levels');
create type public.course_format as enum ('self_paced', 'video', 'live_cohort', 'blended', 'in_person');
create type public.course_status as enum ('draft', 'pending_review', 'published', 'archived');

create table public.courses (
  id uuid primary key default gen_random_uuid(),
  provider_org_id uuid not null references public.organisations (id) on delete cascade,
  title text not null check (char_length(title) between 3 and 160),
  slug text not null unique check (slug ~ '^[a-z0-9]+(-[a-z0-9]+)*$'),
  summary text check (char_length(summary) <= 300),
  description text not null,
  topic text not null,
  level public.course_level not null,
  format public.course_format not null,
  language text not null default 'English',
  duration_minutes int check (duration_minutes > 0),
  duration_label text,             -- "6 weeks", "3 hours"
  price_kobo bigint not null default 0 check (price_kobo >= 0),
  has_certificate boolean not null default false,
  outcomes text[] not null default '{}',
  skills text[] not null default '{}',
  cover_url text,
  status public.course_status not null default 'draft',
  published_at timestamptz,
  is_demo boolean not null default false,
  created_by uuid references auth.users (id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.course_modules (
  id uuid primary key default gen_random_uuid(),
  course_id uuid not null references public.courses (id) on delete cascade,
  title text not null,
  position int not null default 0,
  created_at timestamptz not null default now()
);

create table public.lessons (
  id uuid primary key default gen_random_uuid(),
  module_id uuid not null references public.course_modules (id) on delete cascade,
  title text not null,
  kind text not null check (kind in ('video', 'text', 'download', 'quiz', 'assignment', 'live')),
  -- Kind-specific payload: {"video_url"}, {"markdown"}, {"file_path"},
  -- {"questions": [...]}, {"brief"}, {"starts_at", "join_url"}.
  content jsonb not null default '{}'::jsonb,
  duration_minutes int,
  is_preview boolean not null default false,
  position int not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.enrolments (
  id uuid primary key default gen_random_uuid(),
  course_id uuid not null references public.courses (id) on delete cascade,
  user_id uuid not null references auth.users (id) on delete cascade,
  cohort text,
  status text not null default 'active' check (status in ('active', 'completed', 'cancelled')),
  progress numeric(5, 2) not null default 0 check (progress between 0 and 100),
  last_lesson_id uuid references public.lessons (id) on delete set null,
  enrolled_at timestamptz not null default now(),
  completed_at timestamptz,
  unique (course_id, user_id)
);

create table public.lesson_completions (
  enrolment_id uuid not null references public.enrolments (id) on delete cascade,
  lesson_id uuid not null references public.lessons (id) on delete cascade,
  completed_at timestamptz not null default now(),
  primary key (enrolment_id, lesson_id)
);

create table public.quiz_attempts (
  id uuid primary key default gen_random_uuid(),
  enrolment_id uuid not null references public.enrolments (id) on delete cascade,
  lesson_id uuid not null references public.lessons (id) on delete cascade,
  answers jsonb not null,
  score numeric(5, 2) check (score between 0 and 100),
  passed boolean,
  created_at timestamptz not null default now()
);

create table public.certificates_issued (
  id uuid primary key default gen_random_uuid(),
  -- Public, unguessable reference printed on the certificate, e.g. JM-7KQ4-X9TP.
  credential_ref text not null unique
    default 'JM-' || upper(substr(md5(gen_random_uuid()::text), 1, 4)) || '-'
                  || upper(substr(md5(gen_random_uuid()::text), 1, 4)),
  enrolment_id uuid not null unique references public.enrolments (id) on delete restrict,
  user_id uuid not null references auth.users (id) on delete cascade,
  course_id uuid not null references public.courses (id) on delete restrict,
  holder_name text not null,
  status text not null default 'pending_approval'
    check (status in ('pending_approval', 'issued', 'revoked')),
  approved_by uuid references auth.users (id),
  issued_at timestamptz,
  revoked_reason text,
  pdf_path text,
  created_at timestamptz not null default now()
);

do $$
declare
  t text;
begin
  foreach t in array array[
    'courses', 'course_modules', 'lessons', 'enrolments', 'lesson_completions',
    'quiz_attempts', 'certificates_issued'
  ] loop
    execute format('alter table public.%I enable row level security', t);
  end loop;
end $$;

create trigger courses_updated_at before update on public.courses
  for each row execute function public.set_updated_at();
create trigger lessons_updated_at before update on public.lessons
  for each row execute function public.set_updated_at();
create index courses_public_idx on public.courses (topic, level) where status = 'published';
create index course_modules_course_idx on public.course_modules (course_id, position);
create index lessons_module_idx on public.lessons (module_id, position);
create index enrolments_user_idx on public.enrolments (user_id);

create or replace function public.course_org(c uuid)
returns uuid
language sql
stable
security definer
set search_path = ''
as $$
  select provider_org_id from public.courses where id = c;
$$;

create or replace function public.is_enrolled(c uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.enrolments e
    where e.course_id = c and e.user_id = auth.uid() and e.status <> 'cancelled'
  );
$$;

-- Courses
create policy "published courses are public"
  on public.courses for select to anon, authenticated
  using (
    status = 'published' and (not is_demo or public.demo_visible())
    or public.is_org_member(provider_org_id)
    or public.is_staff()
  );
create policy "providers create draft courses"
  on public.courses for insert to authenticated
  with check (
    public.is_org_member(provider_org_id, 'admin')
    and status in ('draft', 'pending_review')
    and not is_demo
  );
-- Providers cannot self-publish: staff approve (Phase 10).
create policy "providers edit unpublished courses; staff edit any"
  on public.courses for update to authenticated
  using (public.is_org_member(provider_org_id, 'admin') or public.is_staff('content_manager'))
  with check (
    public.is_staff('content_manager')
    or (public.is_org_member(provider_org_id, 'admin') and status in ('draft', 'pending_review', 'archived'))
  );

-- Modules and lessons: outline visible with the course; lesson content only
-- for previews, enrolled learners and the provider.
create policy "module outline follows course"
  on public.course_modules for select to anon, authenticated
  using (exists (select 1 from public.courses c where c.id = course_id));
create policy "providers manage modules"
  on public.course_modules for all to authenticated
  using (public.is_org_member(public.course_org(course_id), 'admin'))
  with check (public.is_org_member(public.course_org(course_id), 'admin'));

create policy "lesson access"
  on public.lessons for select to anon, authenticated
  using (
    exists (
      select 1 from public.course_modules m
      where m.id = module_id
        and (
          is_preview
          or public.is_enrolled(m.course_id)
          or public.is_org_member(public.course_org(m.course_id))
          or public.is_staff()
        )
    )
  );
create policy "providers manage lessons"
  on public.lessons for all to authenticated
  using (exists (
    select 1 from public.course_modules m
    where m.id = module_id and public.is_org_member(public.course_org(m.course_id), 'admin')
  ))
  with check (exists (
    select 1 from public.course_modules m
    where m.id = module_id and public.is_org_member(public.course_org(m.course_id), 'admin')
  ));

-- Enrolments. Free courses: learners enrol themselves. Paid courses are
-- enrolled by the payment webhook (service role) in Phase 9.
create policy "learners and providers read enrolments"
  on public.enrolments for select to authenticated
  using (user_id = auth.uid() or public.is_org_member(public.course_org(course_id)) or public.is_staff());
create policy "learners enrol in free published courses"
  on public.enrolments for insert to authenticated
  with check (
    user_id = auth.uid()
    and status = 'active'
    and progress = 0
    and exists (
      select 1 from public.courses c
      where c.id = course_id and c.status = 'published' and c.price_kobo = 0
    )
  );
create policy "learners update own enrolment"
  on public.enrolments for update to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());

create policy "own lesson completions"
  on public.lesson_completions for all to authenticated
  using (exists (select 1 from public.enrolments e where e.id = enrolment_id and e.user_id = auth.uid()))
  with check (exists (select 1 from public.enrolments e where e.id = enrolment_id and e.user_id = auth.uid()));

create policy "own quiz attempts"
  on public.quiz_attempts for all to authenticated
  using (exists (select 1 from public.enrolments e where e.id = enrolment_id and e.user_id = auth.uid()))
  with check (exists (select 1 from public.enrolments e where e.id = enrolment_id and e.user_id = auth.uid()));

-- Certificates: holders and providers read; providers request, staff approve.
create policy "holders and providers read certificates"
  on public.certificates_issued for select to authenticated
  using (user_id = auth.uid() or public.is_org_member(public.course_org(course_id)) or public.is_staff());
create policy "providers request certificates"
  on public.certificates_issued for insert to authenticated
  with check (
    public.is_org_member(public.course_org(course_id), 'admin')
    and status = 'pending_approval'
    and approved_by is null
  );
create policy "staff approve or revoke certificates"
  on public.certificates_issued for update to authenticated
  using (public.is_staff('content_manager')) with check (public.is_staff('content_manager'));

-- Public verification page: anyone can check a reference, and only learns
-- what the certificate itself shows.
create or replace function public.verify_credential(ref text)
returns table (
  credential_ref text,
  holder_name text,
  course_title text,
  provider_name text,
  issued_at timestamptz,
  status text
)
language sql
stable
security definer
set search_path = ''
as $$
  select ci.credential_ref, ci.holder_name, c.title, o.name, ci.issued_at, ci.status
  from public.certificates_issued ci
  join public.courses c on c.id = ci.course_id
  join public.organisations o on o.id = c.provider_org_id
  where ci.credential_ref = upper(trim(ref))
    and ci.status in ('issued', 'revoked');
$$;
grant execute on function public.verify_credential(text) to anon, authenticated;
