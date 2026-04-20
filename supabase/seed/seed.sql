-- Seed data for local development.
-- Run after: `supabase db reset`
-- Idempotent: safe to re-run.

do $$
declare
  dev_user_id   uuid := gen_random_uuid();
  role_sa_id    uuid;
  role_am_id    uuid;
begin
  -- Create the dev test user in auth.users (local only — never runs in production via db push).
  -- Uses a fixed well-known email so on conflict we resolve by email lookup.
  insert into auth.users (
    id, email, encrypted_password, email_confirmed_at,
    created_at, updated_at, raw_app_meta_data, raw_user_meta_data, aud, role
  )
  values (
    dev_user_id,
    'dev@example.com',
    crypt('password123', gen_salt('bf')),
    now(), now(), now(),
    '{"provider":"email","providers":["email"]}',
    '{"name":"Dev User"}',
    'authenticated',
    'authenticated'
  )
  on conflict (email) do nothing;

  -- Resolve the user id (handles both first-run and re-run after conflict)
  select id into dev_user_id from auth.users where email = 'dev@example.com';

  -- Ensure public.users profile row exists
  insert into public.users (id, name, email, _created_by)
  values (dev_user_id, 'Dev User', 'dev@example.com', dev_user_id)
  on conflict (id) do nothing;

  -- Resolve seeded roles
  select id into role_sa_id from public.roles where name = 'super_admin';
  select id into role_am_id from public.roles where name = 'account_manager';

  -- Assign both roles to the dev user
  insert into public.user_roles (user_id, role_id) values
    (dev_user_id, role_sa_id),
    (dev_user_id, role_am_id)
  on conflict do nothing;

  -- Seed clients
  insert into public.clients (name, account_manager_id, _created_by) values
    ('Acme Corp',          dev_user_id, dev_user_id),
    ('Globex Corporation', dev_user_id, dev_user_id),
    ('Initech',            dev_user_id, dev_user_id),
    ('Umbrella Ltd',       dev_user_id, dev_user_id)
  on conflict do nothing;

end $$;
