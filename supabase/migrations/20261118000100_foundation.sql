-- =============================================================================
-- JobsAndMore: foundation
-- Enums, shared helpers, staff roles, taxonomy, feature flags, profiles,
-- organisations, membership and verification.
--
-- Conventions
--   * Every table has RLS enabled. No table is readable without a policy.
--   * Helper functions that RLS policies call are SECURITY DEFINER with an
--     empty search_path, so they cannot be hijacked and never recurse into RLS.
--   * Content that can be seeded carries is_demo. Public read policies hide
--     demo rows unless the `show_demo_content` feature flag is on, so a
--     production project never shows seed data (product rule 1).
--   * Money is stored in kobo (bigint). Never store card details (rule 10).
-- =============================================================================

create extension if not exists pg_trgm with schema extensions;

-- ---------------------------------------------------------------- enums ----

create type public.app_role as enum (
  'job_seeker', 'employer', 'business_owner', 'training_provider'
);

create type public.staff_role as enum (
  'super_admin', 'ops_admin', 'verification_officer', 'content_manager',
  'finance_officer'
);

create type public.org_type as enum ('employer', 'business', 'training_provider');

-- Precise, separate levels (product rule 2). A badge must never imply checks
-- that were not done.
create type public.verification_level as enum (
  'none', 'email_verified', 'details_reviewed', 'verified'
);

create type public.org_member_role as enum ('owner', 'admin', 'recruiter', 'viewer');

create type public.review_status as enum (
  'pending', 'approved', 'rejected', 'needs_info'
);

-- --------------------------------------------------------------- helpers ---

create or replace function public.set_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

-- ----------------------------------------------------------- staff roles ---

create table public.staff_roles (
  user_id uuid not null references auth.users (id) on delete cascade,
  role public.staff_role not null,
  granted_by uuid references auth.users (id),
  created_at timestamptz not null default now(),
  primary key (user_id, role)
);
alter table public.staff_roles enable row level security;

-- True when the caller holds any of the given staff roles (super_admin always
-- qualifies). Called with no arguments it means "any staff role".
create or replace function public.is_staff(variadic roles public.staff_role[] default '{}')
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.staff_roles s
    where s.user_id = auth.uid()
      and (
        cardinality(roles) = 0
        or s.role = 'super_admin'
        or s.role = any (roles)
      )
  );
$$;

create policy "staff read own roles; super admins read all"
  on public.staff_roles for select to authenticated
  using (user_id = auth.uid() or public.is_staff('super_admin'));

create policy "super admins manage roles"
  on public.staff_roles for all to authenticated
  using (public.is_staff('super_admin'))
  with check (public.is_staff('super_admin'));

-- ---------------------------------------------------------- feature flags --

create table public.feature_flags (
  key text primary key check (key ~ '^[a-z][a-z0-9_]*$'),
  enabled boolean not null default false,
  description text,
  data jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);
alter table public.feature_flags enable row level security;
create trigger feature_flags_updated_at before update on public.feature_flags
  for each row execute function public.set_updated_at();

create policy "flags are public"
  on public.feature_flags for select to anon, authenticated using (true);
create policy "super/ops admins manage flags"
  on public.feature_flags for all to authenticated
  using (public.is_staff('ops_admin'))
  with check (public.is_staff('ops_admin'));

-- Off by default: a fresh (production) project hides seeded demo content.
insert into public.feature_flags (key, enabled, description) values
  ('show_demo_content', false,
   'Show rows flagged is_demo. Turn on only in development/staging.');

create or replace function public.demo_visible()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select coalesce(
    (select enabled from public.feature_flags where key = 'show_demo_content'),
    false
  );
$$;

-- -------------------------------------------------------------- taxonomy ---

create table public.taxonomy_states (
  code text primary key,                 -- e.g. 'LA', 'FC'
  name text not null unique,             -- e.g. 'Lagos', 'Federal Capital Territory'
  capital text not null,
  geo_zone text not null check (geo_zone in (
    'north_central', 'north_east', 'north_west',
    'south_east', 'south_south', 'south_west'
  )),
  -- Neighbouring state codes, used by job alerts ("include nearby states").
  neighbours text[] not null default '{}'
);

create table public.taxonomy_industries (
  slug text primary key,
  name text not null unique,
  position int not null default 0
);

create table public.taxonomy_skills (
  slug text primary key,
  name text not null unique,
  category text,
  aliases text[] not null default '{}'
);

alter table public.taxonomy_states enable row level security;
alter table public.taxonomy_industries enable row level security;
alter table public.taxonomy_skills enable row level security;

create policy "taxonomy is public" on public.taxonomy_states
  for select to anon, authenticated using (true);
create policy "taxonomy is public" on public.taxonomy_industries
  for select to anon, authenticated using (true);
create policy "taxonomy is public" on public.taxonomy_skills
  for select to anon, authenticated using (true);

create policy "content managers edit taxonomy" on public.taxonomy_states
  for all to authenticated
  using (public.is_staff('content_manager')) with check (public.is_staff('content_manager'));
create policy "content managers edit taxonomy" on public.taxonomy_industries
  for all to authenticated
  using (public.is_staff('content_manager')) with check (public.is_staff('content_manager'));
create policy "content managers edit taxonomy" on public.taxonomy_skills
  for all to authenticated
  using (public.is_staff('content_manager')) with check (public.is_staff('content_manager'));

-- -------------------------------------------------------------- profiles ---

create table public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  full_name text check (char_length(full_name) <= 120),
  phone text check (phone is null or phone ~ '^\+?[0-9 ]{7,20}$'),
  state text references public.taxonomy_states (code),
  city text check (char_length(city) <= 80),
  avatar_url text,
  roles public.app_role[] not null default '{}',
  active_role public.app_role,
  -- Separate, withdrawable consents (product rule 9). Shape per key:
  --   {"granted": bool, "at": timestamptz}
  -- Keys: terms, marketing_email, whatsapp, location, data_improvement.
  consents jsonb not null default '{}'::jsonb,
  -- Answers from onboarding step 3 (personalisation), free-form per role.
  personalisation jsonb not null default '{}'::jsonb,
  onboarding_step smallint not null default 0 check (onboarding_step between 0 and 5),
  onboarding_completed_at timestamptz,
  referral_code text unique default upper(substr(md5(gen_random_uuid()::text), 1, 8)),
  deleted_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint active_role_is_held check (active_role is null or active_role = any (roles))
);
alter table public.profiles enable row level security;
create trigger profiles_updated_at before update on public.profiles
  for each row execute function public.set_updated_at();

create policy "users read own profile"
  on public.profiles for select to authenticated
  using (id = auth.uid() or public.is_staff('ops_admin', 'verification_officer'));

create policy "users update own profile"
  on public.profiles for update to authenticated
  using (id = auth.uid())
  with check (id = auth.uid());

-- Profiles are created by the trigger below, never by clients directly.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.profiles (id, full_name)
  values (new.id, nullif(new.raw_user_meta_data ->> 'full_name', ''));
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- --------------------------------------------------------- organisations ---

create table public.organisations (
  id uuid primary key default gen_random_uuid(),
  type public.org_type not null,
  name text not null check (char_length(name) between 2 and 120),
  slug text not null unique check (slug ~ '^[a-z0-9]+(-[a-z0-9]+)*$'),
  logo_url text,
  industry text references public.taxonomy_industries (slug),
  size text check (size in ('1-10', '11-50', '51-200', '201-500', '501-1000', '1000+')),
  website text check (website is null or website ~* '^https?://'),
  email_domain text,
  address text,
  state text references public.taxonomy_states (code),
  city text,
  description text,
  culture text,
  -- Set only by staff (see guard trigger below).
  verification_level public.verification_level not null default 'none',
  verified_at timestamptz,
  is_demo boolean not null default false,
  created_by uuid references auth.users (id) on delete set null,
  deleted_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
alter table public.organisations enable row level security;
create trigger organisations_updated_at before update on public.organisations
  for each row execute function public.set_updated_at();
create index organisations_type_idx on public.organisations (type) where deleted_at is null;
create index organisations_name_trgm on public.organisations using gin (name extensions.gin_trgm_ops);

create table public.organisation_members (
  org_id uuid not null references public.organisations (id) on delete cascade,
  user_id uuid not null references auth.users (id) on delete cascade,
  role public.org_member_role not null default 'viewer',
  created_at timestamptz not null default now(),
  primary key (org_id, user_id)
);
alter table public.organisation_members enable row level security;
create index organisation_members_user_idx on public.organisation_members (user_id);

-- True when the caller belongs to the org with at least the given role.
-- Role order: owner > admin > recruiter > viewer.
create or replace function public.is_org_member(
  org uuid,
  min_role public.org_member_role default 'viewer'
)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.organisation_members m
    where m.org_id = org
      and m.user_id = auth.uid()
      and array_position(
            array['viewer', 'recruiter', 'admin', 'owner']::public.org_member_role[],
            m.role
          ) >= array_position(
            array['viewer', 'recruiter', 'admin', 'owner']::public.org_member_role[],
            min_role
          )
  );
$$;

create policy "public organisations are visible"
  on public.organisations for select to anon, authenticated
  using (
    deleted_at is null and (not is_demo or public.demo_visible())
    or public.is_org_member(id)
    or public.is_staff()
  );

create policy "signed-in users create organisations"
  on public.organisations for insert to authenticated
  with check (
    created_by = auth.uid()
    and verification_level = 'none'
    and verified_at is null
    and not is_demo
  );

create policy "org admins update their organisation"
  on public.organisations for update to authenticated
  using (public.is_org_member(id, 'admin') or public.is_staff('ops_admin', 'verification_officer'))
  with check (public.is_org_member(id, 'admin') or public.is_staff('ops_admin', 'verification_officer'));

-- Only verification officers may change the verification level.
-- Runs as the caller (not SECURITY DEFINER) so current_user is the real
-- database role: postgres / service_role (seeds, edge functions) may set it.
create or replace function public.guard_verification_level()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if new.verification_level is distinct from old.verification_level
     and not public.is_staff('verification_officer')
     and current_user not in ('postgres', 'service_role', 'supabase_admin') then
    raise exception 'verification_level can only be changed by a verification officer'
      using errcode = '42501';
  end if;
  if new.verification_level is distinct from old.verification_level then
    new.verified_at = case when new.verification_level = 'none' then null else now() end;
  end if;
  return new;
end;
$$;

create trigger organisations_guard_verification
  before update on public.organisations
  for each row execute function public.guard_verification_level();

-- The creator becomes owner automatically.
create or replace function public.add_org_owner()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if new.created_by is not null then
    insert into public.organisation_members (org_id, user_id, role)
    values (new.id, new.created_by, 'owner')
    on conflict do nothing;
  end if;
  return new;
end;
$$;

create trigger organisations_add_owner
  after insert on public.organisations
  for each row execute function public.add_org_owner();

create policy "members see their org's members"
  on public.organisation_members for select to authenticated
  using (user_id = auth.uid() or public.is_org_member(org_id) or public.is_staff());

create policy "org admins manage members"
  on public.organisation_members for all to authenticated
  using (public.is_org_member(org_id, 'admin'))
  with check (public.is_org_member(org_id, 'admin'));

-- --------------------------------------------------- verification requests --

create table public.verification_requests (
  id uuid primary key default gen_random_uuid(),
  org_id uuid not null references public.organisations (id) on delete cascade,
  submitted_by uuid not null references auth.users (id),
  requested_level public.verification_level not null
    check (requested_level <> 'none'),
  -- Storage paths in the private `verification-evidence` bucket, e.g.
  -- [{"path": "...", "kind": "cac_certificate"}]
  evidence jsonb not null default '[]'::jsonb,
  status public.review_status not null default 'pending',
  reviewer_id uuid references auth.users (id),
  reviewer_notes text,
  decided_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
alter table public.verification_requests enable row level security;
create trigger verification_requests_updated_at before update on public.verification_requests
  for each row execute function public.set_updated_at();
create index verification_requests_queue_idx
  on public.verification_requests (status, created_at);

create policy "org admins and verification staff read requests"
  on public.verification_requests for select to authenticated
  using (public.is_org_member(org_id, 'admin') or public.is_staff('verification_officer'));

create policy "org admins submit requests"
  on public.verification_requests for insert to authenticated
  with check (
    public.is_org_member(org_id, 'admin')
    and submitted_by = auth.uid()
    and status = 'pending'
    and reviewer_id is null
  );

create policy "verification officers decide requests"
  on public.verification_requests for update to authenticated
  using (public.is_staff('verification_officer'))
  with check (public.is_staff('verification_officer'));
