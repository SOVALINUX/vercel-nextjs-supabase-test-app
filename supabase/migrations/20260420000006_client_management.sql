-- clients: central grouping entity for the replenishment system.
create table public.clients (
  id                   uuid primary key default gen_random_uuid(),
  name                 text not null,
  link                 text,
  sales_executive_id   uuid references public.users (id),
  account_manager_id   uuid not null references public.users (id),
  -- base entity audit fields
  _created_at          timestamptz not null default now(),
  _created_by          uuid        not null references auth.users (id),
  _updated_at          timestamptz,
  _updated_by          uuid        references auth.users (id),
  _deleted             boolean     not null default false,
  constraint clients_link_format check (link is null or link ~* '^https?://')
);

create trigger set_clients_updated_at
  before update on public.clients
  for each row execute function public.set_updated_at();

-- Index for soft-delete queries.
create index clients_active_idx on public.clients (_deleted) where _deleted = false;

alter table public.clients enable row level security;

-- All authenticated users can read active clients.
create policy "clients: authenticated can select active"
  on public.clients for select
  to authenticated
  using (_deleted = false);

-- Any authenticated user may create a client (they become _created_by).
create policy "clients: authenticated can insert"
  on public.clients for insert
  to authenticated
  with check (_created_by = auth.uid());

-- Account manager or creator may update.
create policy "clients: manager or creator can update"
  on public.clients for update
  to authenticated
  using (account_manager_id = auth.uid() or _created_by = auth.uid());

-- No hard deletes; soft-delete is an update.
create policy "clients: no hard delete"
  on public.clients for delete
  using (false);


-- client_representatives: many-to-many between clients and representative users.
create table public.client_representatives (
  client_id uuid not null references public.clients (id) on delete cascade,
  user_id   uuid not null references public.users (id) on delete cascade,
  primary key (client_id, user_id)
);

alter table public.client_representatives enable row level security;

create policy "client_representatives: authenticated can select"
  on public.client_representatives for select
  to authenticated
  using (true);

create policy "client_representatives: manager or creator can manage"
  on public.client_representatives for insert
  to authenticated
  with check (
    exists (
      select 1 from public.clients c
      where c.id = client_id
        and c._deleted = false
        and (c.account_manager_id = auth.uid() or c._created_by = auth.uid())
    )
  );

create policy "client_representatives: manager or creator can delete"
  on public.client_representatives for delete
  using (
    exists (
      select 1 from public.clients c
      where c.id = client_id
        and c._deleted = false
        and (c.account_manager_id = auth.uid() or c._created_by = auth.uid())
    )
  );
