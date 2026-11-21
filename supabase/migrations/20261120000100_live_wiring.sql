-- =============================================================================
-- JobsAndMore: live wiring
-- Small additions the app needs to run against the live database:
--   * sign-up keeps the role, location and consents chosen on the register
--     screen (they arrive as auth metadata), and seekers get a career profile;
--   * job_cards: one row per open job with its employer, for listings;
--   * pipeline_cards: applications with the candidate's display name, for the
--     employer pipeline (rows still filtered by the applications policies);
--   * employer_overview(): the counts on the employer dashboard.
-- =============================================================================

-- ------------------------------------------------------------ sign-up -----

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  meta jsonb := coalesce(new.raw_user_meta_data, '{}'::jsonb);
  wanted text := meta ->> 'role';
  role_value public.app_role;
  state_code text;
  consent jsonb := '{}'::jsonb;
  k text;
begin
  if wanted in ('job_seeker', 'employer', 'business_owner', 'training_provider') then
    role_value := wanted::public.app_role;
  end if;

  select code into state_code
  from public.taxonomy_states
  where lower(name) = lower(coalesce(meta ->> 'state', ''))
     or code = upper(coalesce(meta ->> 'state', ''))
  limit 1;

  -- Each consent is stored separately with the time it was given, so it can
  -- be withdrawn on its own later (product rule 9).
  if jsonb_typeof(meta -> 'consents') = 'object' then
    for k in select jsonb_object_keys(meta -> 'consents') loop
      consent := consent || jsonb_build_object(
        k, jsonb_build_object(
          'granted', coalesce((meta -> 'consents' ->> k)::boolean, false),
          'at', now()
        )
      );
    end loop;
  end if;

  insert into public.profiles (id, full_name, state, city, roles, active_role, consents)
  values (
    new.id,
    nullif(trim(meta ->> 'full_name'), ''),
    state_code,
    nullif(left(trim(coalesce(meta ->> 'city', '')), 80), ''),
    case when role_value is null then '{}' else array[role_value] end,
    role_value,
    consent
  );

  if role_value = 'job_seeker' then
    insert into public.candidate_profiles (user_id, employment_status, desired_states)
    values (
      new.id,
      case when meta ->> 'career_status' in (
        'employed', 'unemployed', 'self_employed', 'student', 'nysc', 'graduate'
      ) then meta ->> 'career_status' end,
      case when state_code is null then '{}' else array[state_code] end
    )
    on conflict (user_id) do nothing;
  end if;

  return new;
end;
$$;

-- ----------------------------------------------------------- job cards -----

create or replace view public.job_cards
with (security_invoker = true) as
select
  j.id,
  j.slug,
  j.title,
  j.summary,
  j.description,
  j.responsibilities,
  j.requirements,
  j.benefits,
  j.skills,
  j.job_type,
  j.arrangement,
  j.experience_level,
  j.industry,
  j.state,
  s.name as state_name,
  j.city,
  j.salary_min,
  j.salary_max,
  j.salary_period,
  j.salary_disclosed,
  j.closing_date,
  j.status,
  j.published_at,
  j.is_sponsored and (j.sponsored_until is null or j.sponsored_until > now()) as is_sponsored,
  j.screening_questions,
  j.apply_method,
  j.external_url,
  j.created_at,
  o.id as org_id,
  o.name as org_name,
  o.slug as org_slug,
  o.logo_url as org_logo_url,
  o.verification_level as org_verification
from public.jobs j
join public.organisations o on o.id = j.org_id
left join public.taxonomy_states s on s.code = j.state
where j.deleted_at is null and o.deleted_at is null;

grant select on public.job_cards to anon, authenticated;

-- ------------------------------------------------------- pipeline cards ----

create or replace view public.pipeline_cards
with (security_invoker = true) as
select
  a.id,
  a.job_id,
  j.title as job_title,
  j.org_id,
  a.candidate_id,
  coalesce(p.full_name, 'Candidate') as candidate_name,
  cp.headline as candidate_headline,
  a.stage,
  a.needs_review,
  a.tags,
  a.cover_letter,
  a.created_at,
  a.updated_at
from public.applications a
join public.jobs j on j.id = a.job_id
left join public.profiles p on p.id = a.candidate_id
left join public.candidate_profiles cp on cp.user_id = a.candidate_id
where a.withdrawn_at is null;

grant select on public.pipeline_cards to authenticated;

-- ------------------------------------------------- employer dashboard ------

create or replace function public.employer_overview(p_org uuid)
returns jsonb
language sql
stable
security invoker
set search_path = ''
as $$
  select jsonb_build_object(
    'active_jobs', (select count(*) from public.jobs
                    where org_id = p_org and status = 'published' and deleted_at is null),
    'draft_jobs', (select count(*) from public.jobs
                   where org_id = p_org and status = 'draft' and deleted_at is null),
    'paused_jobs', (select count(*) from public.jobs
                    where org_id = p_org and status = 'paused' and deleted_at is null),
    'new_applicants', (select count(*) from public.applications a
                       join public.jobs j on j.id = a.job_id
                       where j.org_id = p_org and a.created_at > now() - interval '7 days'),
    'pending_review', (select count(*) from public.applications a
                       join public.jobs j on j.id = a.job_id
                       where j.org_id = p_org and a.stage in ('new', 'under_review')
                         and a.withdrawn_at is null),
    'interviews', (select count(*) from public.applications a
                   join public.jobs j on j.id = a.job_id
                   where j.org_id = p_org and a.stage = 'interview'),
    'offers', (select count(*) from public.applications a
               join public.jobs j on j.id = a.job_id
               where j.org_id = p_org and a.stage = 'offer'),
    'hires', (select count(*) from public.applications a
              join public.jobs j on j.id = a.job_id
              where j.org_id = p_org and a.stage = 'hired')
  );
$$;

revoke execute on function public.employer_overview(uuid) from anon;
grant execute on function public.employer_overview(uuid) to authenticated;
