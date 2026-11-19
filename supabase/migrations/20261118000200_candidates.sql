-- =============================================================================
-- Candidate career profile and its sections.
--
-- Privacy (product rule 8): candidates control visibility. Employers can read
-- a candidate's profile only when (a) the candidate applied to one of their
-- organisation's jobs, or (b) the candidate made their profile visible to
-- employers. They never see another employer's applicants.
-- =============================================================================

create type public.profile_visibility as enum ('private', 'employers_only', 'public');

create table public.candidate_profiles (
  user_id uuid primary key references auth.users (id) on delete cascade,
  headline text check (char_length(headline) <= 140),
  about text check (char_length(about) <= 4000),
  employment_status text check (employment_status in (
    'employed', 'unemployed', 'self_employed', 'student', 'nysc', 'graduate'
  )),
  availability text check (availability in (
    'immediately', 'two_weeks', 'one_month', 'three_months', 'not_looking'
  )),
  open_to_work boolean not null default true,
  desired_roles text[] not null default '{}',
  desired_states text[] not null default '{}',
  desired_job_types text[] not null default '{}',
  salary_expectation_min bigint check (salary_expectation_min >= 0),
  salary_expectation_max bigint check (salary_expectation_max >= 0),
  years_experience smallint check (years_experience between 0 and 60),
  visibility public.profile_visibility not null default 'employers_only',
  -- Sections the candidate marked "Not applicable" (excluded from the score).
  not_applicable text[] not null default '{}',
  completion_score smallint not null default 0 check (completion_score between 0 and 100),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint salary_expectation_range check (
    salary_expectation_max is null or salary_expectation_min is null
    or salary_expectation_max >= salary_expectation_min
  )
);
alter table public.candidate_profiles enable row level security;
create trigger candidate_profiles_updated_at before update on public.candidate_profiles
  for each row execute function public.set_updated_at();

-- Defined after applications/jobs exist (migration 0300) because it looks at
-- them; declared here as a stub so policies below can reference it.
create or replace function public.can_view_candidate(candidate uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select candidate = auth.uid() or public.is_staff();
$$;

create policy "owner and permitted employers read candidate profile"
  on public.candidate_profiles for select to authenticated
  using (public.can_view_candidate(user_id));
create policy "owner writes candidate profile"
  on public.candidate_profiles for all to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());

-- Each section table follows the same shape: owned by user_id, readable by
-- whoever may view the candidate, writable only by the owner.
create table public.experiences (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  title text not null,
  company text not null,
  employment_type text,
  state text references public.taxonomy_states (code),
  city text,
  start_date date not null,
  end_date date,
  is_current boolean not null default false,
  description text,
  achievements text[] not null default '{}',
  position int not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (end_date is null or end_date >= start_date),
  check (not (is_current and end_date is not null))
);

create table public.educations (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  institution text not null,
  qualification text not null,     -- e.g. B.Sc., HND, OND, WAEC/SSCE
  field_of_study text,
  grade text,                      -- e.g. "Second Class Upper", "3.62/5.0"
  start_date date,
  end_date date,
  position int not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (end_date is null or start_date is null or end_date >= start_date)
);

create table public.skills (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  name text not null,
  skill_slug text references public.taxonomy_skills (slug),
  level text check (level in ('beginner', 'intermediate', 'advanced', 'expert')),
  years smallint check (years between 0 and 60),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, name)
);

create table public.languages (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  language text not null,          -- English, Hausa, Yoruba, Igbo, Pidgin, French...
  proficiency text not null check (proficiency in (
    'basic', 'conversational', 'professional', 'fluent', 'native'
  )),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, language)
);

create table public.certificates (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  name text not null,
  issuer text,
  issued_on date,
  expires_on date,
  credential_id text,
  credential_url text,
  kind text not null default 'certificate' check (kind in ('certificate', 'award', 'licence')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.associations (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  name text not null,              -- e.g. ICAN, NSE, CIPM
  membership_level text,
  member_since date,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.cv_documents (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  title text not null,
  source text not null check (source in ('upload', 'builder')),
  -- Private `cvs` bucket path for uploads; builder CVs store structured data.
  storage_path text,
  content jsonb,
  mime_type text check (mime_type in (
    'application/pdf',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
  )),
  size_bytes int check (size_bytes between 1 and 10485760),
  -- Set by the upload scan hook; unscanned/infected files are never shared.
  scan_status text not null default 'pending'
    check (scan_status in ('pending', 'clean', 'infected', 'error')),
  version int not null default 1,
  is_primary boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (source <> 'upload' or storage_path is not null),
  check (source <> 'builder' or content is not null)
);
create unique index cv_documents_one_primary on public.cv_documents (user_id) where is_primary;

create table public.cover_letters (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  title text not null,
  body text not null check (char_length(body) <= 8000),
  version int not null default 1,
  ai_assisted boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.portfolio_items (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  title text not null,
  description text,
  url text check (url is null or url ~* '^https?://'),
  storage_path text,
  position int not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

do $$
declare
  t text;
begin
  foreach t in array array[
    'experiences', 'educations', 'skills', 'languages', 'certificates',
    'associations', 'cv_documents', 'cover_letters', 'portfolio_items'
  ] loop
    execute format('alter table public.%I enable row level security', t);
    execute format('create index %I on public.%I (user_id)', t || '_user_idx', t);
    execute format(
      'create trigger %I before update on public.%I
         for each row execute function public.set_updated_at()',
      t || '_updated_at', t);
    execute format(
      'create policy "owner and permitted employers read" on public.%I
         for select to authenticated using (public.can_view_candidate(user_id))', t);
    execute format(
      'create policy "owner writes" on public.%I
         for all to authenticated
         using (user_id = auth.uid()) with check (user_id = auth.uid())', t);
  end loop;
end $$;
