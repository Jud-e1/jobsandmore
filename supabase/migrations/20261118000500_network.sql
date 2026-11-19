-- =============================================================================
-- Business services marketplace, enquiries, connections, blocking, messaging
-- and notifications.
-- =============================================================================

-- ------------------------------------------------------------- services ----

create table public.services (
  id uuid primary key default gen_random_uuid(),
  org_id uuid not null references public.organisations (id) on delete cascade,
  title text not null check (char_length(title) between 3 and 140),
  slug text not null check (slug ~ '^[a-z0-9]+(-[a-z0-9]+)*$'),
  category text not null check (category in (
    'hr', 'strategy', 'operations', 'finance', 'funding_readiness', 'project_management',
    'analytics', 'training', 'marketing', 'legal', 'technology', 'other'
  )),
  description text not null,
  pricing_model text not null check (pricing_model in ('fixed', 'hourly', 'daily', 'quote')),
  price_from_kobo bigint check (price_from_kobo >= 0),
  delivery text not null default 'remote' check (delivery in ('remote', 'on_site', 'both')),
  states text[] not null default '{}',
  status text not null default 'draft' check (status in ('draft', 'published', 'paused')),
  is_demo boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (org_id, slug),
  check (pricing_model = 'quote' or price_from_kobo is not null)
);
alter table public.services enable row level security;
create trigger services_updated_at before update on public.services
  for each row execute function public.set_updated_at();
create index services_category_idx on public.services (category) where status = 'published';

create policy "published services are public"
  on public.services for select to anon, authenticated
  using (
    status = 'published' and (not is_demo or public.demo_visible())
    or public.is_org_member(org_id)
    or public.is_staff()
  );
create policy "org admins manage services"
  on public.services for all to authenticated
  using (public.is_org_member(org_id, 'admin'))
  with check (public.is_org_member(org_id, 'admin') and not is_demo);

create table public.enquiries (
  id uuid primary key default gen_random_uuid(),
  service_id uuid references public.services (id) on delete set null,
  org_id uuid not null references public.organisations (id) on delete cascade,
  sender_id uuid not null references auth.users (id) on delete cascade,
  subject text not null,
  message text not null check (char_length(message) <= 4000),
  budget_kobo bigint check (budget_kobo >= 0),
  -- The provider sees the sender's contact details only with this consent.
  share_contact boolean not null default false,
  status text not null default 'new'
    check (status in ('new', 'responded', 'in_progress', 'won', 'lost', 'closed')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
alter table public.enquiries enable row level security;
create trigger enquiries_updated_at before update on public.enquiries
  for each row execute function public.set_updated_at();
create index enquiries_org_idx on public.enquiries (org_id, status);

create policy "sender and provider read enquiries"
  on public.enquiries for select to authenticated
  using (sender_id = auth.uid() or public.is_org_member(org_id));
create policy "signed-in users send enquiries"
  on public.enquiries for insert to authenticated
  with check (sender_id = auth.uid() and status = 'new');
create policy "provider updates enquiry status"
  on public.enquiries for update to authenticated
  using (public.is_org_member(org_id, 'recruiter'))
  with check (public.is_org_member(org_id, 'recruiter'));

-- ------------------------------------------------- connections & blocks ----

create table public.blocks (
  blocker_id uuid not null references auth.users (id) on delete cascade,
  blocked_id uuid not null references auth.users (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (blocker_id, blocked_id),
  check (blocker_id <> blocked_id)
);
alter table public.blocks enable row level security;
create policy "own blocks" on public.blocks for all to authenticated
  using (blocker_id = auth.uid()) with check (blocker_id = auth.uid());

create or replace function public.is_blocked_between(a uuid, b uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.blocks
    where (blocker_id = a and blocked_id = b) or (blocker_id = b and blocked_id = a)
  );
$$;

create table public.connections (
  id uuid primary key default gen_random_uuid(),
  requester_id uuid not null references auth.users (id) on delete cascade,
  addressee_id uuid not null references auth.users (id) on delete cascade,
  status text not null default 'pending' check (status in ('pending', 'accepted', 'declined')),
  message text check (char_length(message) <= 500),
  created_at timestamptz not null default now(),
  responded_at timestamptz,
  check (requester_id <> addressee_id)
);
create unique index connections_pair_idx on public.connections (
  least(requester_id, addressee_id), greatest(requester_id, addressee_id)
);
alter table public.connections enable row level security;

create policy "parties read connections"
  on public.connections for select to authenticated
  using (auth.uid() in (requester_id, addressee_id));
create policy "request a connection"
  on public.connections for insert to authenticated
  with check (
    requester_id = auth.uid()
    and status = 'pending'
    and not public.is_blocked_between(requester_id, addressee_id)
  );
create policy "addressee responds"
  on public.connections for update to authenticated
  using (addressee_id = auth.uid()) with check (addressee_id = auth.uid());
create policy "either party removes"
  on public.connections for delete to authenticated
  using (auth.uid() in (requester_id, addressee_id));

-- ------------------------------------------------------------- messaging ---

create table public.conversations (
  id uuid primary key default gen_random_uuid(),
  kind text not null check (kind in ('application', 'connection', 'enquiry', 'support')),
  application_id uuid references public.applications (id) on delete cascade,
  enquiry_id uuid references public.enquiries (id) on delete cascade,
  subject text,
  created_by uuid references auth.users (id) on delete set null,
  created_at timestamptz not null default now(),
  last_message_at timestamptz
);

create table public.conversation_participants (
  conversation_id uuid not null references public.conversations (id) on delete cascade,
  user_id uuid not null references auth.users (id) on delete cascade,
  last_read_at timestamptz,
  muted boolean not null default false,
  primary key (conversation_id, user_id)
);

create table public.messages (
  id uuid primary key default gen_random_uuid(),
  conversation_id uuid not null references public.conversations (id) on delete cascade,
  sender_id uuid not null references auth.users (id) on delete cascade,
  body text not null check (char_length(body) between 1 and 4000),
  attachments jsonb not null default '[]'::jsonb,
  created_at timestamptz not null default now(),
  edited_at timestamptz,
  deleted_at timestamptz
);

alter table public.conversations enable row level security;
alter table public.conversation_participants enable row level security;
alter table public.messages enable row level security;
create index conversation_participants_user_idx on public.conversation_participants (user_id);
create index messages_conversation_idx on public.messages (conversation_id, created_at);

create or replace function public.is_participant(conv uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.conversation_participants p
    where p.conversation_id = conv and p.user_id = auth.uid()
  );
$$;

create policy "participants read conversations"
  on public.conversations for select to authenticated
  using (public.is_participant(id) or public.is_staff('ops_admin'));
-- Conversations are opened by server-side functions that check the context
-- (an application, an accepted connection or an enquiry), not by clients.

create policy "participants read participants"
  on public.conversation_participants for select to authenticated
  using (public.is_participant(conversation_id));
create policy "participants update own read state"
  on public.conversation_participants for update to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());

create policy "participants read messages"
  on public.messages for select to authenticated
  using (public.is_participant(conversation_id) or public.is_staff('ops_admin'));

-- Blocked users cannot message each other.
create policy "participants send messages"
  on public.messages for insert to authenticated
  with check (
    sender_id = auth.uid()
    and public.is_participant(conversation_id)
    and not exists (
      select 1 from public.conversation_participants p
      where p.conversation_id = messages.conversation_id
        and p.user_id <> auth.uid()
        and public.is_blocked_between(auth.uid(), p.user_id)
    )
  );
create policy "senders edit or delete own messages"
  on public.messages for update to authenticated
  using (sender_id = auth.uid()) with check (sender_id = auth.uid());

create or replace function public.touch_conversation()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  update public.conversations set last_message_at = new.created_at
   where id = new.conversation_id;
  return new;
end;
$$;
create trigger messages_touch_conversation after insert on public.messages
  for each row execute function public.touch_conversation();

-- --------------------------------------------------------- notifications ---

create table public.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  category text not null check (category in (
    'application', 'job_alert', 'message', 'interview', 'course', 'billing',
    'verification', 'rewards', 'system'
  )),
  title text not null,
  body text,
  link text,                       -- in-app route, e.g. /app/applications/<id>
  data jsonb not null default '{}'::jsonb,
  read_at timestamptz,
  created_at timestamptz not null default now()
);
alter table public.notifications enable row level security;
create index notifications_user_idx on public.notifications (user_id, created_at desc);
create index notifications_unread_idx on public.notifications (user_id) where read_at is null;

create policy "own notifications"
  on public.notifications for select to authenticated using (user_id = auth.uid());
create policy "mark own notifications read"
  on public.notifications for update to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "delete own notifications"
  on public.notifications for delete to authenticated using (user_id = auth.uid());
