-- public.users: application-level profile that extends auth.users.
-- auth.users is managed by Supabase Auth; this table holds domain fields only.
create table public.users (
  id          uuid primary key references auth.users (id) on delete cascade,
  name        text        not null,
  email       text        not null unique,
  is_active   boolean     not null default true,
  -- base entity audit fields
  _created_at timestamptz not null default now(),
  _created_by uuid        not null references auth.users (id),
  _updated_at timestamptz,
  _updated_by uuid        references auth.users (id),
  _deleted    boolean     not null default false
);

create trigger set_users_updated_at
  before update on public.users
  for each row execute function public.set_updated_at();

alter table public.users enable row level security;

-- Users can read any active, non-deleted profile (needed for FK display names).
create policy "users: authenticated can select active"
  on public.users for select
  to authenticated
  using (_deleted = false and is_active = true);

-- A user may only update their own profile.
create policy "users: owner can update"
  on public.users for update
  to authenticated
  using (id = auth.uid());

-- Insert is handled by the auth trigger (see below); no direct insert via API.
create policy "users: no direct insert"
  on public.users for insert
  with check (false);

-- Soft-delete only; hard delete blocked at DB level.
create policy "users: no hard delete"
  on public.users for delete
  using (false);

-- Automatically create a public.users row when a new auth.users row is inserted.
create or replace function public.handle_new_auth_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.users (id, name, email, _created_by)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'name', split_part(new.email, '@', 1)),
    new.email,
    new.id
  );
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_auth_user();
