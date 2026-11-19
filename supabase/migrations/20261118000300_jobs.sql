-- =============================================================================
-- Jobs marketplace, opportunities, applications (ATS), saved jobs, alerts and
-- AI run history.
-- =============================================================================

create type public.job_type as enum (
  'full_time', 'part_time', 'contract', 'internship', 'nysc', 'temporary'
);
create type public.work_arrangement as enum ('on_site', 'hybrid', 'remote');
create type public.experience_level as enum (
  'entry', 'mid', 'senior', 'manager', 'executive'
);
create type public.job_status as enum ('draft', 'published', 'paused', 'closed', 'expired');

-- Separate listing types, never mixed with jobs (product rule 7).
create type public.opportunity_type as enum (
  'scholarship', 'fellowship', 'grant', 'volunteering', 'competition',
  'international', 'tender', 'accelerator', 'internship_programme'
);

create type public.application_stage as enum (
  'new', 'under_review', 'shortlisted', 'assessment', 'interview',
  'reference_check', 'offer', 'hired', 'rejected', 'withdrawn'
);

create type public.alert_frequency as enum ('immediate', 'daily', 'weekly');

-- ------------------------------------------------------------------- jobs --

create table public.jobs (
  id uuid primary key default gen_random_uuid(),
  org_id uuid not null references public.organisations (id) on delete cascade,
  created_by uuid references auth.users (id) on delete set null,
  title text not null check (char_length(title) between 3 and 140),
  slug text not null check (slug ~ '^[a-z0-9]+(-[a-z0-9]+)*$'),
  summary text check (char_length(summary) <= 300),
  description text not null,
  responsibilities text[] not null default '{}',
  requirements text[] not null default '{}',
  benefits text[] not null default '{}',
  skills text[] not null default '{}',
  job_type public.job_type not null,
  arrangement public.work_arrangement not null,
  experience_level public.experience_level not null,
  industry text references public.taxonomy_industries (slug),
  state text references public.taxonomy_states (code),
  city text,
  salary_min bigint check (salary_min >= 0),
  salary_max bigint check (salary_max >= 0),
  salary_period text not null default 'month' check (salary_period in ('month', 'year', 'hour', 'contract')),
  salary_disclosed boolean not null default false,
  closing_date date,
  status public.job_status not null default 'draft',
  published_at timestamptz,
  -- Paid placement is always labelled in the UI (product rule 5).
  is_sponsored boolean not null default false,
  sponsored_until timestamptz,
  -- [{"id": "q1", "question": "...", "type": "yes_no|text|choice",
  --   "options": [...], "knockout": {"answer": "no"}}]
  -- Knockout answers only flag an application for review; candidates are never
  -- auto-rejected by AI scores (product rule 4).
  screening_questions jsonb not null default '[]'::jsonb,
  apply_method text not null default 'platform' check (apply_method in ('platform', 'external')),
  external_url text check (external_url is null or external_url ~* '^https://'),
  views_count int not null default 0,
  is_demo boolean not null default false,
  search tsvector generated always as (
    setweight(to_tsvector('english', coalesce(title, '')), 'A')
    || setweight(to_tsvector('english', coalesce(summary, '')), 'B')
    || setweight(to_tsvector('english', coalesce(description, '')), 'C')
  ) stored,
  deleted_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (org_id, slug),
  constraint salary_range check (salary_max is null or salary_min is null or salary_max >= salary_min),
  constraint disclosed_salary_has_value check (
    not salary_disclosed or salary_min is not null or salary_max is not null
  ),
  constraint external_needs_url check (apply_method <> 'external' or external_url is not null),
  constraint published_needs_date check (status <> 'published' or published_at is not null)
);
alter table public.jobs enable row level security;
create trigger jobs_updated_at before update on public.jobs
  for each row execute function public.set_updated_at();

create index jobs_public_idx on public.jobs (published_at desc)
  where status = 'published' and deleted_at is null;
create index jobs_org_idx on public.jobs (org_id, status);
create index jobs_state_idx on public.jobs (state) where status = 'published';
create index jobs_search_idx on public.jobs using gin (search);
create index jobs_title_trgm on public.jobs using gin (title extensions.gin_trgm_ops);

-- A job is publicly "open" only while published and not past its closing date.
-- Expired vacancies never appear as active (product rule 6), even before the
-- nightly expire_jobs() run flips their status.
create or replace function public.job_is_open(j public.jobs)
returns boolean
language sql
stable
set search_path = ''
as $$
  select j.status = 'published'
     and j.deleted_at is null
     and (j.closing_date is null or j.closing_date >= current_date);
$$;

create policy "open jobs are public"
  on public.jobs for select to anon, authenticated
  using (
    (
      status = 'published'
      and deleted_at is null
      and (closing_date is null or closing_date >= current_date)
      and (not is_demo or public.demo_visible())
    )
    or public.is_org_member(org_id)
    or public.is_staff()
  );

create policy "recruiters create jobs for their org"
  on public.jobs for insert to authenticated
  with check (public.is_org_member(org_id, 'recruiter') and not is_demo and not is_sponsored);

create policy "recruiters edit their org's jobs"
  on public.jobs for update to authenticated
  using (public.is_org_member(org_id, 'recruiter') or public.is_staff('ops_admin'))
  with check (public.is_org_member(org_id, 'recruiter') or public.is_staff('ops_admin'));

create policy "org admins delete their org's jobs"
  on public.jobs for delete to authenticated
  using (public.is_org_member(org_id, 'admin'));

-- Sponsorship is bought (Phase 9), never self-assigned; publishing stamps
-- published_at.
create or replace function public.guard_job_update()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if current_user not in ('postgres', 'service_role', 'supabase_admin')
     and not public.is_staff('ops_admin') then
    if new.is_sponsored is distinct from coalesce(old.is_sponsored, false)
       or new.sponsored_until is distinct from old.sponsored_until then
      raise exception 'sponsorship is set by billing, not edited directly'
        using errcode = '42501';
    end if;
  end if;
  if new.status = 'published' and new.published_at is null then
    new.published_at = now();
  end if;
  return new;
end;
$$;

create trigger jobs_guard before insert or update on public.jobs
  for each row execute function public.guard_job_update();

-- Nightly: flip past-deadline jobs to expired (scheduled with pg_cron in
-- Phase 3). Returns the number of jobs closed.
create or replace function public.expire_jobs()
returns int
language plpgsql
security definer
set search_path = ''
as $$
declare
  n int;
begin
  update public.jobs
     set status = 'expired'
   where status in ('published', 'paused')
     and closing_date < current_date;
  get diagnostics n = row_count;
  update public.opportunities
     set status = 'closed'
   where status = 'published'
     and deadline < current_date;
  return n;
end;
$$;
revoke execute on function public.expire_jobs() from anon, authenticated;

-- ---------------------------------------------------------- opportunities --

create table public.opportunities (
  id uuid primary key default gen_random_uuid(),
  type public.opportunity_type not null,
  title text not null,
  slug text not null unique check (slug ~ '^[a-z0-9]+(-[a-z0-9]+)*$'),
  provider_name text not null,
  org_id uuid references public.organisations (id) on delete set null,
  summary text,
  description text not null,
  -- Always link to the official source so users can check it themselves.
  source_url text not null check (source_url ~* '^https?://'),
  -- {"min_age": 18, "max_age": 35, "states": [...], "fields": [...],
  --  "education": "...", "nationality": "Nigerian", "notes": "..."}
  eligibility jsonb not null default '{}'::jsonb,
  benefits text,
  funding_amount text,             -- free text: "Up to ₦5m", "Fully funded"
  state text references public.taxonomy_states (code),
  country text not null default 'Nigeria',
  is_remote boolean not null default false,
  deadline date,
  status text not null default 'draft' check (status in ('draft', 'published', 'closed')),
  is_featured boolean not null default false,
  is_demo boolean not null default false,
  last_checked_at timestamptz,     -- when staff last confirmed the source
  created_by uuid references auth.users (id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
alter table public.opportunities enable row level security;
create trigger opportunities_updated_at before update on public.opportunities
  for each row execute function public.set_updated_at();
create index opportunities_public_idx on public.opportunities (type, deadline)
  where status = 'published';

create policy "open opportunities are public"
  on public.opportunities for select to anon, authenticated
  using (
    (
      status = 'published'
      and (deadline is null or deadline >= current_date)
      and (not is_demo or public.demo_visible())
    )
    or public.is_staff()
  );

create policy "content managers manage opportunities"
  on public.opportunities for all to authenticated
  using (public.is_staff('content_manager'))
  with check (public.is_staff('content_manager'));

-- ----------------------------------------------------------- applications --

create table public.applications (
  id uuid primary key default gen_random_uuid(),
  job_id uuid not null references public.jobs (id) on delete cascade,
  candidate_id uuid not null references auth.users (id) on delete cascade,
  cv_document_id uuid references public.cv_documents (id) on delete set null,
  cover_letter text check (char_length(cover_letter) <= 8000),
  answers jsonb not null default '{}'::jsonb,
  stage public.application_stage not null default 'new',
  -- Set when a knockout answer is given. A flag for human review only.
  needs_review boolean not null default false,
  source text,                     -- 'search', 'alert', 'recommendation', ...
  tags text[] not null default '{}',
  withdrawn_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (job_id, candidate_id)
);
alter table public.applications enable row level security;
create trigger applications_updated_at before update on public.applications
  for each row execute function public.set_updated_at();
create index applications_candidate_idx on public.applications (candidate_id, created_at desc);
create index applications_job_stage_idx on public.applications (job_id, stage);

create or replace function public.application_org(app_job uuid)
returns uuid
language sql
stable
security definer
set search_path = ''
as $$
  select org_id from public.jobs where id = app_job;
$$;

create policy "candidates read own; org members read their org's"
  on public.applications for select to authenticated
  using (
    candidate_id = auth.uid()
    or public.is_org_member(public.application_org(job_id))
    or public.is_staff('ops_admin')
  );

-- Candidates apply only to open, on-platform jobs, and only with their own CV.
create policy "candidates apply to open jobs"
  on public.applications for insert to authenticated
  with check (
    candidate_id = auth.uid()
    and stage = 'new'
    and exists (
      select 1 from public.jobs j
      where j.id = job_id
        and j.status = 'published'
        and j.deleted_at is null
        and j.apply_method = 'platform'
        and (j.closing_date is null or j.closing_date >= current_date)
    )
    and (
      cv_document_id is null
      or exists (
        select 1 from public.cv_documents c
        where c.id = cv_document_id and c.user_id = auth.uid()
      )
    )
  );

create policy "candidates withdraw; recruiters move stages"
  on public.applications for update to authenticated
  using (
    candidate_id = auth.uid()
    or public.is_org_member(public.application_org(job_id), 'recruiter')
  )
  with check (
    candidate_id = auth.uid()
    or public.is_org_member(public.application_org(job_id), 'recruiter')
  );

-- Column rules the policy cannot express: candidates may only withdraw;
-- recruiters may not alter what the candidate submitted.
create or replace function public.guard_application_update()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if current_user in ('postgres', 'service_role', 'supabase_admin') then
    return new;
  end if;
  if old.candidate_id = auth.uid() then
    if new.stage is distinct from old.stage and new.stage <> 'withdrawn' then
      raise exception 'candidates can only withdraw an application' using errcode = '42501';
    end if;
    if new.tags is distinct from old.tags or new.needs_review is distinct from old.needs_review then
      raise exception 'candidates cannot change recruiter fields' using errcode = '42501';
    end if;
    if new.stage = 'withdrawn' and old.stage <> 'withdrawn' then
      new.withdrawn_at = now();
    end if;
  else
    if new.cv_document_id is distinct from old.cv_document_id
       or new.cover_letter is distinct from old.cover_letter
       or new.answers is distinct from old.answers
       or new.candidate_id is distinct from old.candidate_id
       or new.job_id is distinct from old.job_id then
      raise exception 'recruiters cannot change the submitted application' using errcode = '42501';
    end if;
    if old.stage = 'withdrawn' then
      raise exception 'a withdrawn application cannot be moved' using errcode = '42501';
    end if;
  end if;
  return new;
end;
$$;

create trigger applications_guard before update on public.applications
  for each row execute function public.guard_application_update();

-- ----------------------------------------------------- application events --

create table public.application_events (
  id uuid primary key default gen_random_uuid(),
  application_id uuid not null references public.applications (id) on delete cascade,
  actor_id uuid references auth.users (id) on delete set null,
  kind text not null check (kind in (
    'submitted', 'stage_change', 'interview_scheduled', 'message', 'note', 'viewed'
  )),
  from_stage public.application_stage,
  to_stage public.application_stage,
  data jsonb not null default '{}'::jsonb,
  visible_to_candidate boolean not null default true,
  created_at timestamptz not null default now()
);
alter table public.application_events enable row level security;
create index application_events_app_idx on public.application_events (application_id, created_at);

create policy "candidates see their visible events; org members see all"
  on public.application_events for select to authenticated
  using (
    exists (
      select 1 from public.applications a
      where a.id = application_id
        and (
          (a.candidate_id = auth.uid() and visible_to_candidate)
          or public.is_org_member(public.application_org(a.job_id))
        )
    )
    or public.is_staff('ops_admin')
  );

-- Timeline entries are written by triggers only.
create or replace function public.log_application_event()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if tg_op = 'INSERT' then
    insert into public.application_events (application_id, actor_id, kind, to_stage)
    values (new.id, auth.uid(), 'submitted', new.stage);
  elsif new.stage is distinct from old.stage then
    insert into public.application_events (application_id, actor_id, kind, from_stage, to_stage)
    values (new.id, auth.uid(), 'stage_change', old.stage, new.stage);
  end if;
  return new;
end;
$$;

create trigger applications_log_event
  after insert or update of stage on public.applications
  for each row execute function public.log_application_event();

create table public.recruiter_notes (
  id uuid primary key default gen_random_uuid(),
  application_id uuid not null references public.applications (id) on delete cascade,
  author_id uuid not null references auth.users (id),
  body text not null check (char_length(body) <= 4000),
  created_at timestamptz not null default now()
);
alter table public.recruiter_notes enable row level security;
create index recruiter_notes_app_idx on public.recruiter_notes (application_id);

-- Never visible to the candidate.
create policy "org members read and write notes"
  on public.recruiter_notes for all to authenticated
  using (
    exists (
      select 1 from public.applications a
      where a.id = application_id
        and public.is_org_member(public.application_org(a.job_id), 'recruiter')
    )
  )
  with check (
    author_id = auth.uid()
    and exists (
      select 1 from public.applications a
      where a.id = application_id
        and public.is_org_member(public.application_org(a.job_id), 'recruiter')
    )
  );

create table public.interviews (
  id uuid primary key default gen_random_uuid(),
  application_id uuid not null references public.applications (id) on delete cascade,
  scheduled_at timestamptz not null,
  duration_minutes int not null default 45 check (duration_minutes between 10 and 480),
  mode text not null check (mode in ('in_person', 'video', 'phone')),
  location text,
  meeting_url text check (meeting_url is null or meeting_url ~* '^https://'),
  instructions text,
  status text not null default 'scheduled'
    check (status in ('scheduled', 'confirmed', 'rescheduled', 'cancelled', 'completed')),
  created_by uuid references auth.users (id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
alter table public.interviews enable row level security;
create trigger interviews_updated_at before update on public.interviews
  for each row execute function public.set_updated_at();

create policy "candidate and org read interviews"
  on public.interviews for select to authenticated
  using (
    exists (
      select 1 from public.applications a
      where a.id = application_id
        and (a.candidate_id = auth.uid()
             or public.is_org_member(public.application_org(a.job_id)))
    )
  );
create policy "recruiters manage interviews"
  on public.interviews for all to authenticated
  using (
    exists (
      select 1 from public.applications a
      where a.id = application_id
        and public.is_org_member(public.application_org(a.job_id), 'recruiter')
    )
  )
  with check (
    exists (
      select 1 from public.applications a
      where a.id = application_id
        and public.is_org_member(public.application_org(a.job_id), 'recruiter')
    )
  );

-- --------------------------------------------- candidate visibility (real) --

-- Replaces the stub from migration 0200 now that applications exist.
create or replace function public.can_view_candidate(candidate uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select
    candidate = auth.uid()
    or public.is_staff('ops_admin', 'verification_officer')
    -- Applied to a job at an organisation the caller belongs to.
    or exists (
      select 1
      from public.applications a
      join public.jobs j on j.id = a.job_id
      join public.organisation_members m on m.org_id = j.org_id
      where a.candidate_id = candidate
        and a.stage <> 'withdrawn'
        and m.user_id = auth.uid()
    )
    -- Or chose to be discoverable by employers.
    or exists (
      select 1
      from public.candidate_profiles cp
      where cp.user_id = candidate
        and cp.visibility in ('employers_only', 'public')
        and exists (
          select 1
          from public.organisation_members m
          join public.organisations o on o.id = m.org_id
          where m.user_id = auth.uid()
            and o.type = 'employer'
            and o.verification_level in ('details_reviewed', 'verified')
        )
    );
$$;

-- CVs are stricter than the rest of the profile: an employer only sees a CV
-- the candidate attached to an application at their organisation.
drop policy "owner and permitted employers read" on public.cv_documents;
create policy "owner and receiving employers read CVs"
  on public.cv_documents for select to authenticated
  using (
    user_id = auth.uid()
    or public.is_staff('ops_admin')
    or exists (
      select 1
      from public.applications a
      join public.jobs j on j.id = a.job_id
      where a.cv_document_id = cv_documents.id
        and a.stage <> 'withdrawn'
        and public.is_org_member(j.org_id)
    )
  );

-- ------------------------------------------------- saved jobs and alerts ---

create table public.saved_jobs (
  user_id uuid not null references auth.users (id) on delete cascade,
  job_id uuid not null references public.jobs (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (user_id, job_id)
);

create table public.saved_searches (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  name text not null,
  query jsonb not null,
  created_at timestamptz not null default now()
);

create table public.job_alerts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  name text not null,
  keywords text[] not null default '{}',
  states text[] not null default '{}',
  include_nearby_states boolean not null default false,
  -- Radius search needs location consent; enforced by the app and the
  -- matcher (which ignores radius when consent is withdrawn).
  radius_km int check (radius_km between 1 and 500),
  job_types public.job_type[] not null default '{}',
  arrangements public.work_arrangement[] not null default '{}',
  industries text[] not null default '{}',
  experience_levels public.experience_level[] not null default '{}',
  frequency public.alert_frequency not null default 'daily',
  channels text[] not null default '{email,in_app}'
    check (channels <@ array['email', 'push', 'whatsapp', 'in_app']),
  paused boolean not null default false,
  last_sent_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Dedupe: a job is sent to an alert at most once.
create table public.job_alert_deliveries (
  alert_id uuid not null references public.job_alerts (id) on delete cascade,
  job_id uuid not null references public.jobs (id) on delete cascade,
  reasons text[] not null default '{}',
  sent_at timestamptz not null default now(),
  primary key (alert_id, job_id)
);

alter table public.saved_jobs enable row level security;
alter table public.saved_searches enable row level security;
alter table public.job_alerts enable row level security;
alter table public.job_alert_deliveries enable row level security;
create trigger job_alerts_updated_at before update on public.job_alerts
  for each row execute function public.set_updated_at();
create index job_alerts_active_idx on public.job_alerts (frequency) where not paused;

create policy "own saved jobs" on public.saved_jobs for all to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "own saved searches" on public.saved_searches for all to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "own alerts" on public.job_alerts for all to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "own alert deliveries" on public.job_alert_deliveries for select to authenticated
  using (exists (
    select 1 from public.job_alerts a where a.id = alert_id and a.user_id = auth.uid()
  ));

-- ---------------------------------------------------------------- ai runs --

create table public.ai_runs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  tool text not null check (tool in (
    'cv_builder', 'ats_analyser', 'cv_improver', 'job_match', 'application_assistant',
    'interview_coach', 'career_coach', 'skills_gap', 'career_pathway',
    'salary_insight', 'cover_letter', 'about_me'
  )),
  input_ref jsonb not null default '{}'::jsonb,   -- ids of the CV/job used, never raw secrets
  output jsonb,
  score numeric(5, 2) check (score between 0 and 100),
  model text,
  tokens_in int,
  tokens_out int,
  status text not null default 'succeeded' check (status in ('succeeded', 'failed', 'rejected_by_user')),
  created_at timestamptz not null default now()
);
alter table public.ai_runs enable row level security;
create index ai_runs_user_tool_idx on public.ai_runs (user_id, tool, created_at desc);

-- Written only by Edge Functions (service role), which also enforce limits.
create policy "users read own AI runs" on public.ai_runs for select to authenticated
  using (user_id = auth.uid());
create policy "users mark own runs rejected" on public.ai_runs for update to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid() and status = 'rejected_by_user');
