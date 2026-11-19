-- =============================================================================
-- Server-side helpers used by sign-up and onboarding.
-- =============================================================================

-- Records one consent with a server timestamp. Consents are separate and
-- withdrawable (product rule 9): calling with granted = false withdraws.
create or replace function public.set_consent(p_key text, p_granted boolean)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  result jsonb;
begin
  if auth.uid() is null then
    raise exception 'not signed in' using errcode = '42501';
  end if;
  if p_key not in ('terms', 'marketing_email', 'whatsapp', 'location', 'data_improvement') then
    raise exception 'unknown consent %', p_key using errcode = '22023';
  end if;
  if p_key = 'terms' and not p_granted then
    raise exception 'terms cannot be withdrawn here; delete the account instead'
      using errcode = '22023';
  end if;
  update public.profiles
     set consents = consents || jsonb_build_object(
           p_key, jsonb_build_object('granted', p_granted, 'at', now())
         )
   where id = auth.uid()
  returning consents into result;
  return result;
end;
$$;
revoke execute on function public.set_consent(text, boolean) from anon;

-- Creates an organisation for the caller with a unique slug and makes them
-- owner. Used by onboarding for employers, business owners and providers.
create or replace function public.create_my_organisation(
  p_type public.org_type,
  p_name text,
  p_industry text default null,
  p_state text default null,
  p_size text default null,
  p_website text default null
)
returns public.organisations
language plpgsql
security definer
set search_path = ''
as $$
declare
  base text;
  candidate text;
  n int := 0;
  org public.organisations;
begin
  if auth.uid() is null then
    raise exception 'not signed in' using errcode = '42501';
  end if;
  if char_length(trim(coalesce(p_name, ''))) < 2 then
    raise exception 'organisation name is required' using errcode = '22023';
  end if;

  base := trim(both '-' from regexp_replace(lower(trim(p_name)), '[^a-z0-9]+', '-', 'g'));
  if base = '' then
    base := 'org';
  end if;
  base := left(base, 60);
  candidate := base;
  while exists (select 1 from public.organisations where slug = candidate) loop
    n := n + 1;
    candidate := base || '-' || n;
  end loop;

  insert into public.organisations (type, name, slug, industry, state, size, website, created_by)
  values (p_type, trim(p_name), candidate, p_industry, p_state, p_size, p_website, auth.uid())
  returning * into org;
  return org;
end;
$$;
revoke execute on function public.create_my_organisation(
  public.org_type, text, text, text, text, text
) from anon;

-- Organisations the caller belongs to, with their role. Used to pick a
-- workspace after sign-in.
create or replace function public.my_organisations()
returns table (
  org_id uuid,
  name text,
  type public.org_type,
  role public.org_member_role,
  verification_level public.verification_level
)
language sql
stable
security definer
set search_path = ''
as $$
  select o.id, o.name, o.type, m.role, o.verification_level
  from public.organisation_members m
  join public.organisations o on o.id = m.org_id
  where m.user_id = auth.uid() and o.deleted_at is null
  order by m.created_at;
$$;
revoke execute on function public.my_organisations() from anon;
