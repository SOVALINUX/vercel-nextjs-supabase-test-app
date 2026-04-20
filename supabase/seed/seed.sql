-- Seed data for local development.
-- Requires `supabase start` to have run (which creates dev@example.com via config.toml).
-- Idempotent: safe to re-run after `supabase db reset`.

do $$
declare
  dev_user_id   uuid;
  role_sa_id    uuid;
  role_am_id    uuid;
begin
  -- Resolve the test user created by config.toml
  select id into dev_user_id from auth.users where email = 'dev@example.com';
  if dev_user_id is null then
    raise exception 'dev@example.com not found. Run `supabase start` first.';
  end if;

  -- Ensure public.users row exists (the auth trigger handles this on real sign-ups,
  -- but the test user injected by config.toml may need a manual insert in local dev).
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

  -- Seed clients (dev user as account manager)
  insert into public.clients (name, account_manager_id, _created_by) values
    ('Acme Corp',            dev_user_id, dev_user_id),
    ('Globex Corporation',   dev_user_id, dev_user_id),
    ('Initech',              dev_user_id, dev_user_id),
    ('Umbrella Ltd',         dev_user_id, dev_user_id)
  on conflict do nothing;

end $$;
