create type public.group_source as enum ('manual', 'active_directory', 'ldap', 'scim');

create table public.groups (
  id          uuid             primary key default gen_random_uuid(),
  name        text             not null unique,
  description text,
  source      public.group_source not null default 'manual',
  sync_config jsonb,
  is_active   boolean          not null default true,
  -- base entity audit fields
  _created_at timestamptz      not null default now(),
  _created_by uuid             not null references auth.users (id),
  _updated_at timestamptz,
  _updated_by uuid             references auth.users (id),
  _deleted    boolean          not null default false,
  -- sync_config required when source is not manual
  constraint groups_sync_config_required check (
    source = 'manual' or sync_config is not null
  )
);

create trigger set_groups_updated_at
  before update on public.groups
  for each row execute function public.set_updated_at();

alter table public.groups enable row level security;

create policy "groups: authenticated can select active"
  on public.groups for select
  to authenticated
  using (_deleted = false);


-- group_users: many-to-many between groups and users.
create table public.group_users (
  group_id uuid not null references public.groups (id) on delete cascade,
  user_id  uuid not null references public.users (id) on delete cascade,
  primary key (group_id, user_id)
);

alter table public.group_users enable row level security;

create policy "group_users: authenticated can select"
  on public.group_users for select
  to authenticated
  using (true);


-- group_subgroups: self-referential nesting.
-- Circular nesting is prevented by the application layer and the check trigger below.
create table public.group_subgroups (
  parent_group_id uuid not null references public.groups (id) on delete cascade,
  child_group_id  uuid not null references public.groups (id) on delete cascade,
  primary key (parent_group_id, child_group_id),
  constraint group_subgroups_no_self_loop check (parent_group_id <> child_group_id)
);

alter table public.group_subgroups enable row level security;

create policy "group_subgroups: authenticated can select"
  on public.group_subgroups for select
  to authenticated
  using (true);


-- group_permissions: many-to-many between groups and permissions.
create table public.group_permissions (
  group_id      uuid not null references public.groups (id) on delete cascade,
  permission_id uuid not null references public.permissions (id) on delete restrict,
  primary key (group_id, permission_id)
);

alter table public.group_permissions enable row level security;

create policy "group_permissions: authenticated can select"
  on public.group_permissions for select
  to authenticated
  using (true);
