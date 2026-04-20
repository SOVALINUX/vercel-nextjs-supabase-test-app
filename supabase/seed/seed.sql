-- Seed data for local development.
-- Run after: `supabase db reset`
-- Idempotent: all inserts guard with existence checks or ON CONFLICT ON CONSTRAINT.

do $$
declare
  dev_user_id   uuid := gen_random_uuid();
  dev_emp_id    uuid := gen_random_uuid();
  role_sa_id    uuid;
  role_am_id    uuid;
begin
  -- Create the dev test user in auth.users (local only).
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

  -- Resolve id (handles both first-run and re-run)
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
  on conflict (user_id, role_id) do nothing;

  -- Seed an employee record linked to the dev user
  insert into public.employees
    (id, first_name, last_name, email, job_title, department, employment_type, _created_by)
  values
    (dev_emp_id, 'Dev', 'User', 'dev@example.com', 'Developer', 'Engineering', 'employee', dev_user_id)
  on conflict (email) do nothing;

  -- Resolve employee id
  select id into dev_emp_id from public.employees where email = 'dev@example.com';

  -- Link user → employee
  update public.users
    set employee_id = dev_emp_id
  where id = dev_user_id and employee_id is null;

  -- Seed clients (dev user as account manager)
  if not exists (select 1 from public.clients where name = 'Acme Corp' and _deleted = false) then
    insert into public.clients (name, account_manager_id, _created_by)
    values ('Acme Corp', dev_user_id, dev_user_id);
  end if;

  if not exists (select 1 from public.clients where name = 'Globex Corporation' and _deleted = false) then
    insert into public.clients (name, account_manager_id, _created_by)
    values ('Globex Corporation', dev_user_id, dev_user_id);
  end if;

  if not exists (select 1 from public.clients where name = 'Initech' and _deleted = false) then
    insert into public.clients (name, account_manager_id, _created_by)
    values ('Initech', dev_user_id, dev_user_id);
  end if;

  if not exists (select 1 from public.clients where name = 'Umbrella Ltd' and _deleted = false) then
    insert into public.clients (name, account_manager_id, _created_by)
    values ('Umbrella Ltd', dev_user_id, dev_user_id);
  end if;

end $$;
