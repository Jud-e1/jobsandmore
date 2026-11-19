-- =============================================================================
-- Billing, rewards, trust & safety, CMS content and storage buckets.
-- =============================================================================

-- ---------------------------------------------------------------- billing --
-- Paystack holds card data; we store references and amounts only (rule 10).
-- All billing rows are written by Edge Functions (service role) after
-- verifying Paystack webhooks. Clients only read their own.

create table public.plans (
  id uuid primary key default gen_random_uuid(),
  code text not null unique check (code ~ '^[a-z][a-z0-9_]*$'),
  name text not null,
  audience public.app_role not null,
  description text,
  -- Prices are configured by admins, never hard-coded in the app.
  price_kobo bigint not null check (price_kobo >= 0),
  interval text not null check (interval in ('month', 'year', 'one_off')),
  -- e.g. {"ai_reviews_per_month": 20, "active_vacancies": 5, "team_seats": 3}
  entitlements jsonb not null default '{}'::jsonb,
  features text[] not null default '{}',
  paystack_plan_code text,
  is_active boolean not null default true,
  is_highlighted boolean not null default false,
  sort_order int not null default 0,
  is_demo boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.subscriptions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users (id) on delete cascade,
  org_id uuid references public.organisations (id) on delete cascade,
  plan_id uuid not null references public.plans (id),
  status text not null check (status in ('trialing', 'active', 'past_due', 'cancelled', 'expired')),
  current_period_start timestamptz,
  current_period_end timestamptz,
  cancel_at_period_end boolean not null default false,
  paystack_subscription_code text unique,
  paystack_customer_code text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check ((user_id is null) <> (org_id is null))
);

create table public.transactions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users (id) on delete set null,
  org_id uuid references public.organisations (id) on delete set null,
  reference text not null unique,                 -- Paystack reference
  purpose text not null check (purpose in (
    'subscription', 'vacancy_credits', 'sponsored_listing', 'course', 'service', 'refund'
  )),
  amount_kobo bigint not null,
  currency text not null default 'NGN',
  status text not null check (status in ('pending', 'success', 'failed', 'reversed', 'refunded')),
  channel text,                                   -- card, bank_transfer, ussd...
  provider_payload jsonb not null default '{}'::jsonb,
  paid_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.invoices (
  id uuid primary key default gen_random_uuid(),
  number text not null unique,                    -- JM-2026-000123
  transaction_id uuid references public.transactions (id) on delete set null,
  user_id uuid references auth.users (id) on delete set null,
  org_id uuid references public.organisations (id) on delete set null,
  amount_kobo bigint not null,
  vat_kobo bigint not null default 0,
  line_items jsonb not null default '[]'::jsonb,
  issued_at timestamptz not null default now(),
  pdf_path text
);

create table public.credits (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users (id) on delete cascade,
  org_id uuid references public.organisations (id) on delete cascade,
  kind text not null check (kind in ('vacancy', 'ai', 'sponsored_listing')),
  delta int not null,                              -- + purchased/granted, - used
  reason text not null,
  transaction_id uuid references public.transactions (id) on delete set null,
  expires_at timestamptz,
  created_at timestamptz not null default now(),
  check ((user_id is null) <> (org_id is null))
);

do $$
declare
  t text;
begin
  foreach t in array array['plans', 'subscriptions', 'transactions', 'invoices', 'credits'] loop
    execute format('alter table public.%I enable row level security', t);
  end loop;
end $$;
create trigger plans_updated_at before update on public.plans
  for each row execute function public.set_updated_at();
create trigger subscriptions_updated_at before update on public.subscriptions
  for each row execute function public.set_updated_at();
create trigger transactions_updated_at before update on public.transactions
  for each row execute function public.set_updated_at();
create index credits_org_kind_idx on public.credits (org_id, kind);
create index credits_user_kind_idx on public.credits (user_id, kind);

create policy "active plans are public"
  on public.plans for select to anon, authenticated
  using (is_active and (not is_demo or public.demo_visible()) or public.is_staff('finance_officer'));
create policy "finance manages plans"
  on public.plans for all to authenticated
  using (public.is_staff('finance_officer')) with check (public.is_staff('finance_officer'));

create policy "own or org billing: subscriptions"
  on public.subscriptions for select to authenticated
  using (user_id = auth.uid() or public.is_org_member(org_id, 'admin') or public.is_staff('finance_officer'));
create policy "own or org billing: transactions"
  on public.transactions for select to authenticated
  using (user_id = auth.uid() or public.is_org_member(org_id, 'admin') or public.is_staff('finance_officer'));
create policy "own or org billing: invoices"
  on public.invoices for select to authenticated
  using (user_id = auth.uid() or public.is_org_member(org_id, 'admin') or public.is_staff('finance_officer'));
create policy "own or org billing: credits"
  on public.credits for select to authenticated
  using (user_id = auth.uid() or public.is_org_member(org_id) or public.is_staff('finance_officer'));

-- ---------------------------------------------------------------- rewards --

create table public.reward_ledger (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  points int not null check (points <> 0),
  reason text not null,            -- matches a published rule code
  reference text,                  -- e.g. referral id, course id
  expires_at timestamptz,
  created_at timestamptz not null default now()
);

create table public.referrals (
  id uuid primary key default gen_random_uuid(),
  referrer_id uuid not null references auth.users (id) on delete cascade,
  referred_user_id uuid unique references auth.users (id) on delete set null,
  code text not null,
  status text not null default 'signed_up'
    check (status in ('signed_up', 'qualified', 'rewarded', 'rejected')),
  rewarded_at timestamptz,
  created_at timestamptz not null default now(),
  check (referrer_id <> referred_user_id)
);

alter table public.reward_ledger enable row level security;
alter table public.referrals enable row level security;
create index reward_ledger_user_idx on public.reward_ledger (user_id, created_at desc);

create policy "own reward ledger" on public.reward_ledger for select to authenticated
  using (user_id = auth.uid() or public.is_staff('finance_officer', 'ops_admin'));
create policy "own referrals" on public.referrals for select to authenticated
  using (referrer_id = auth.uid() or public.is_staff('ops_admin'));

-- --------------------------------------------------------- trust & safety --

create table public.reports (
  id uuid primary key default gen_random_uuid(),
  reporter_id uuid not null references auth.users (id) on delete cascade,
  target_type text not null check (target_type in (
    'job', 'opportunity', 'organisation', 'user', 'review', 'message', 'service', 'course'
  )),
  target_id uuid not null,
  reason text not null check (reason in (
    'scam_or_fraud', 'fake_listing', 'expired', 'discrimination', 'harassment',
    'inappropriate', 'spam', 'other'
  )),
  details text check (char_length(details) <= 2000),
  status text not null default 'open' check (status in ('open', 'investigating', 'actioned', 'dismissed')),
  handled_by uuid references auth.users (id),
  handled_at timestamptz,
  resolution_notes text,
  created_at timestamptz not null default now()
);
alter table public.reports enable row level security;
create index reports_queue_idx on public.reports (status, created_at);

create policy "users file reports" on public.reports for insert to authenticated
  with check (reporter_id = auth.uid() and status = 'open');
create policy "reporters see own; staff see all" on public.reports for select to authenticated
  using (reporter_id = auth.uid() or public.is_staff('ops_admin'));
create policy "staff handle reports" on public.reports for update to authenticated
  using (public.is_staff('ops_admin')) with check (public.is_staff('ops_admin'));

create table public.reviews (
  id uuid primary key default gen_random_uuid(),
  org_id uuid not null references public.organisations (id) on delete cascade,
  author_id uuid not null references auth.users (id) on delete cascade,
  rating smallint not null check (rating between 1 and 5),
  title text not null check (char_length(title) <= 120),
  body text not null check (char_length(body) between 20 and 4000),
  relationship text check (relationship in ('current_employee', 'former_employee', 'candidate', 'client')),
  status text not null default 'pending' check (status in ('pending', 'published', 'rejected')),
  moderated_by uuid references auth.users (id),
  -- Right of reply for the organisation.
  employer_reply text check (char_length(employer_reply) <= 2000),
  replied_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (org_id, author_id)
);
alter table public.reviews enable row level security;
create trigger reviews_updated_at before update on public.reviews
  for each row execute function public.set_updated_at();

create policy "published reviews are public; authors and orgs see own"
  on public.reviews for select to anon, authenticated
  using (
    status = 'published'
    or author_id = auth.uid()
    or public.is_org_member(org_id)
    or public.is_staff('content_manager')
  );
create policy "users write reviews (moderated)"
  on public.reviews for insert to authenticated
  with check (
    author_id = auth.uid()
    and status = 'pending'
    and employer_reply is null
    and not public.is_org_member(org_id)
  );
create policy "orgs reply; staff moderate"
  on public.reviews for update to authenticated
  using (public.is_org_member(org_id, 'admin') or public.is_staff('content_manager'))
  with check (public.is_org_member(org_id, 'admin') or public.is_staff('content_manager'));

-- An organisation may only write its reply; it cannot edit or hide a review.
create or replace function public.guard_review_update()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if current_user in ('postgres', 'service_role', 'supabase_admin')
     or public.is_staff('content_manager') then
    return new;
  end if;
  if (new.rating, new.title, new.body, new.status, new.author_id, new.org_id)
     is distinct from (old.rating, old.title, old.body, old.status, old.author_id, old.org_id) then
    raise exception 'organisations can only reply to reviews' using errcode = '42501';
  end if;
  if new.employer_reply is distinct from old.employer_reply then
    new.replied_at = now();
  end if;
  return new;
end;
$$;
create trigger reviews_guard before update on public.reviews
  for each row execute function public.guard_review_update();

create table public.audit_log (
  id bigint generated always as identity primary key,
  actor_id uuid references auth.users (id) on delete set null,
  action text not null,            -- e.g. 'verification.approve'
  entity text not null,            -- table name
  entity_id text,
  before jsonb,
  after jsonb,
  ip inet,
  created_at timestamptz not null default now()
);
alter table public.audit_log enable row level security;
create index audit_log_entity_idx on public.audit_log (entity, entity_id);
create index audit_log_actor_idx on public.audit_log (actor_id, created_at desc);

-- Append-only. Staff actions call this; there is no update/delete policy.
create or replace function public.write_audit(
  p_action text, p_entity text, p_entity_id text,
  p_before jsonb default null, p_after jsonb default null
)
returns void
language sql
security definer
set search_path = ''
as $$
  insert into public.audit_log (actor_id, action, entity, entity_id, before, after)
  values (auth.uid(), p_action, p_entity, p_entity_id, p_before, p_after);
$$;
revoke execute on function public.write_audit(text, text, text, jsonb, jsonb) from anon;

create policy "super/ops admins read audit log" on public.audit_log for select to authenticated
  using (public.is_staff('ops_admin'));

-- Verification decisions are always audited.
create or replace function public.audit_verification_decision()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if new.status is distinct from old.status then
    perform public.write_audit(
      'verification.' || new.status::text, 'verification_requests', new.id::text,
      jsonb_build_object('status', old.status),
      jsonb_build_object('status', new.status, 'notes', new.reviewer_notes)
    );
  end if;
  return new;
end;
$$;
create trigger verification_requests_audit after update on public.verification_requests
  for each row execute function public.audit_verification_decision();

-- ---------------------------------------------------------------- content --

create table public.cms_pages (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique check (slug ~ '^[a-z0-9]+(-[a-z0-9]+)*$'),
  title text not null,
  body_markdown text not null,
  meta_description text check (char_length(meta_description) <= 160),
  status text not null default 'draft' check (status in ('draft', 'published')),
  updated_by uuid references auth.users (id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.articles (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique check (slug ~ '^[a-z0-9]+(-[a-z0-9]+)*$'),
  title text not null,
  excerpt text,
  body_markdown text not null,
  category text not null,
  cover_url text,
  author_name text,
  status text not null default 'draft' check (status in ('draft', 'published')),
  published_at timestamptz,
  is_demo boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.faqs (
  id uuid primary key default gen_random_uuid(),
  category text not null,
  question text not null,
  answer_markdown text not null,
  position int not null default 0,
  status text not null default 'published' check (status in ('draft', 'published')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Shown only with documented consent (no fake testimonials, rule 1).
create table public.success_stories (
  id uuid primary key default gen_random_uuid(),
  person_name text not null,
  role_title text,
  story text not null,
  photo_url text,
  consent_confirmed boolean not null default false,
  consent_evidence_path text,
  consent_confirmed_by uuid references auth.users (id),
  status text not null default 'draft' check (status in ('draft', 'published')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Logos shown only with written permission.
create table public.partners (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  logo_url text,
  url text,
  logo_permission boolean not null default false,
  permission_evidence_path text,
  status text not null default 'draft' check (status in ('draft', 'published')),
  position int not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

do $$
declare
  t text;
begin
  foreach t in array array['cms_pages', 'articles', 'faqs', 'success_stories', 'partners'] loop
    execute format('alter table public.%I enable row level security', t);
    execute format(
      'create trigger %I before update on public.%I
         for each row execute function public.set_updated_at()', t || '_updated_at', t);
    execute format(
      'create policy "content managers manage" on public.%I for all to authenticated
         using (public.is_staff(''content_manager''))
         with check (public.is_staff(''content_manager''))', t);
  end loop;
end $$;

create policy "published pages are public" on public.cms_pages
  for select to anon, authenticated using (status = 'published');
create policy "published articles are public" on public.articles
  for select to anon, authenticated
  using (status = 'published' and (not is_demo or public.demo_visible()));
create policy "published faqs are public" on public.faqs
  for select to anon, authenticated using (status = 'published');
create policy "consented stories are public" on public.success_stories
  for select to anon, authenticated using (status = 'published' and consent_confirmed);
create policy "permitted partners are public" on public.partners
  for select to anon, authenticated using (status = 'published' and logo_permission);

-- ---------------------------------------------------------------- storage --

-- Folder names are user-controlled text; never let a bad one raise inside a
-- policy.
create or replace function public.try_uuid(v text)
returns uuid
language plpgsql
immutable
set search_path = ''
as $$
begin
  return v::uuid;
exception when others then
  return null;
end;
$$;
-- Paths start with the owner's user id (or org id for org buckets):
--   avatars/<user_id>/avatar.webp, cvs/<user_id>/<uuid>.pdf,
--   logos/<org_id>/logo.webp, verification-evidence/<org_id>/<uuid>.pdf

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types) values
  ('avatars', 'avatars', true, 2097152, array['image/jpeg', 'image/png', 'image/webp']),
  ('logos', 'logos', true, 2097152, array['image/jpeg', 'image/png', 'image/webp', 'image/svg+xml']),
  ('cvs', 'cvs', false, 10485760, array[
    'application/pdf',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
  ]),
  ('verification-evidence', 'verification-evidence', false, 10485760,
    array['application/pdf', 'image/jpeg', 'image/png']),
  ('portfolio', 'portfolio', false, 10485760,
    array['application/pdf', 'image/jpeg', 'image/png', 'image/webp'])
on conflict (id) do nothing;

create policy "avatars: public read" on storage.objects for select to anon, authenticated
  using (bucket_id = 'avatars');
create policy "avatars: owner writes" on storage.objects for all to authenticated
  using (bucket_id = 'avatars' and (storage.foldername(name))[1] = auth.uid()::text)
  with check (bucket_id = 'avatars' and (storage.foldername(name))[1] = auth.uid()::text);

create policy "logos: public read" on storage.objects for select to anon, authenticated
  using (bucket_id = 'logos');
create policy "logos: org admins write" on storage.objects for all to authenticated
  using (bucket_id = 'logos' and public.is_org_member(public.try_uuid((storage.foldername(name))[1]), 'admin'))
  with check (bucket_id = 'logos' and public.is_org_member(public.try_uuid((storage.foldername(name))[1]), 'admin'));

-- Employers get CV files through short-lived signed URLs created by an Edge
-- Function after checking the application, never by direct bucket access.
create policy "cvs: owner only" on storage.objects for all to authenticated
  using (bucket_id = 'cvs' and (storage.foldername(name))[1] = auth.uid()::text)
  with check (bucket_id = 'cvs' and (storage.foldername(name))[1] = auth.uid()::text);

create policy "portfolio: owner only" on storage.objects for all to authenticated
  using (bucket_id = 'portfolio' and (storage.foldername(name))[1] = auth.uid()::text)
  with check (bucket_id = 'portfolio' and (storage.foldername(name))[1] = auth.uid()::text);

create policy "evidence: org admins upload and read; verification staff read"
  on storage.objects for select to authenticated
  using (
    bucket_id = 'verification-evidence'
    and (
      public.is_org_member(public.try_uuid((storage.foldername(name))[1]), 'admin')
      or public.is_staff('verification_officer')
    )
  );
create policy "evidence: org admins upload" on storage.objects for insert to authenticated
  with check (
    bucket_id = 'verification-evidence'
    and public.is_org_member(public.try_uuid((storage.foldername(name))[1]), 'admin')
  );
