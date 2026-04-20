-- permissions: URN-based permission records (immutable after creation).
create table public.permissions (
  id          uuid primary key default gen_random_uuid(),
  urn         text        not null unique,
  description text,
  -- base entity audit fields
  _created_at timestamptz not null default now(),
  _created_by uuid        not null references auth.users (id),
  _updated_at timestamptz,
  _updated_by uuid        references auth.users (id),
  _deleted    boolean     not null default false,
  constraint permissions_urn_format check (urn ~ '^!?urn:[^:]+:[^:]+:[^:]+:[^:]+:[^:]+$')
);

alter table public.permissions enable row level security;

create policy "permissions: authenticated can select"
  on public.permissions for select
  to authenticated
  using (_deleted = false);


-- roles: named permission profiles seeded by migration.
create table public.roles (
  id          uuid primary key default gen_random_uuid(),
  name        text        not null unique,
  description text,
  -- base entity audit fields
  _created_at timestamptz not null default now(),
  _created_by uuid        not null references auth.users (id),
  _updated_at timestamptz,
  _updated_by uuid        references auth.users (id),
  _deleted    boolean     not null default false
);

create trigger set_roles_updated_at
  before update on public.roles
  for each row execute function public.set_updated_at();

alter table public.roles enable row level security;

create policy "roles: authenticated can select"
  on public.roles for select
  to authenticated
  using (_deleted = false);


-- role_permissions: many-to-many between roles and permissions.
create table public.role_permissions (
  role_id       uuid not null references public.roles (id) on delete restrict,
  permission_id uuid not null references public.permissions (id) on delete restrict,
  primary key (role_id, permission_id)
);

alter table public.role_permissions enable row level security;

create policy "role_permissions: authenticated can select"
  on public.role_permissions for select
  to authenticated
  using (true);


-- user_roles: many-to-many between users and roles.
create table public.user_roles (
  user_id uuid not null references public.users (id) on delete cascade,
  role_id uuid not null references public.roles (id) on delete restrict,
  primary key (user_id, role_id)
);

alter table public.user_roles enable row level security;

create policy "user_roles: authenticated can select"
  on public.user_roles for select
  to authenticated
  using (true);


-- Seed the two built-in roles.
-- _created_by is a chicken-and-egg problem at seed time: we use a placeholder system UUID.
-- The trigger for auth.users handles real users; this is a one-time migration seed.
do $$
declare
  system_user_id uuid := '00000000-0000-0000-0000-000000000000';
begin
  -- Insert a synthetic system entry in auth.users if it doesn't exist,
  -- solely to satisfy the FK on _created_by for these seeded rows.
  insert into auth.users (id, email, created_at, updated_at, raw_app_meta_data, raw_user_meta_data, aud, role)
  values (system_user_id, 'system@internal', now(), now(), '{}', '{}', 'authenticated', 'authenticated')
  on conflict (id) do nothing;

  insert into public.users (id, name, email, _created_by)
  values (system_user_id, 'System', 'system@internal', system_user_id)
  on conflict (id) do nothing;

  insert into public.roles (name, description, _created_by) values
    ('super_admin',     'Full access to all entities including user and role management.', system_user_id),
    ('account_manager', 'Access to clients, employees, and opportunities. Cannot manage users or roles.', system_user_id);
end $$;
