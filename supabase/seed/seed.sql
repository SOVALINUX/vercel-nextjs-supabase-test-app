-- Seed data for local development.
-- Run via: supabase start  (automatic) or supabase db reset
-- Idempotent: all inserts guard with NOT EXISTS checks.

do $$
declare
  dev_user_id   uuid;
  dev_emp_id    uuid;
  role_sa_id    uuid;
  role_am_id    uuid;
begin
  -- Only create the dev user if they don't already exist
  if not exists (select 1 from auth.users where email = 'dev@example.com') then
    dev_user_id := gen_random_uuid();
    insert into auth.users (
      id, email, encrypted_password, email_confirmed_at,
      created_at, updated_at, raw_app_meta_data, raw_user_meta_data, aud, role
    ) values (
      dev_user_id,
      'dev@example.com',
      crypt('password123', gen_salt('bf')),
      now(), now(), now(),
      '{"provider":"email","providers":["email"]}',
      '{"name":"Dev User"}',
      'authenticated',
      'authenticated'
    );
  end if;

  select id into dev_user_id from auth.users where email = 'dev@example.com';

  -- Ensure public.users profile row exists
  if not exists (select 1 from public.users where id = dev_user_id) then
    insert into public.users (id, name, email, _created_by)
    values (dev_user_id, 'Dev User', 'dev@example.com', dev_user_id);
  end if;

  -- Resolve seeded roles
  select id into role_sa_id from public.roles where name = 'super_admin';
  select id into role_am_id from public.roles where name = 'account_manager';

  -- Assign roles
  if role_sa_id is not null and not exists (
    select 1 from public.user_roles where user_id = dev_user_id and role_id = role_sa_id
  ) then
    insert into public.user_roles (user_id, role_id) values (dev_user_id, role_sa_id);
  end if;

  if role_am_id is not null and not exists (
    select 1 from public.user_roles where user_id = dev_user_id and role_id = role_am_id
  ) then
    insert into public.user_roles (user_id, role_id) values (dev_user_id, role_am_id);
  end if;

  -- Seed employee linked to dev user
  if not exists (select 1 from public.employees where email = 'dev@example.com') then
    insert into public.employees
      (first_name, last_name, email, job_title, department, employment_type, _created_by)
    values
      ('Dev', 'User', 'dev@example.com', 'Developer', 'Engineering', 'employee', dev_user_id)
    returning id into dev_emp_id;
  else
    select id into dev_emp_id from public.employees where email = 'dev@example.com';
  end if;

  -- Link user → employee
  update public.users set employee_id = dev_emp_id
  where id = dev_user_id and employee_id is null;

  -- Seed clients
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
