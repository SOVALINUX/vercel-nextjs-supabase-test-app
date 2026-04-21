-- Reference / demo data — runs in every environment via db push.
-- Idempotent: all inserts use ON CONFLICT DO NOTHING.
-- Uses the system user (id = 00000000-0000-0000-0000-000000000000) seeded in migration 000003
-- as _created_by for all records.

do $$
declare
  sys_id   uuid := '00000000-0000-0000-0000-000000000000';

  -- employee ids
  emp_alice  uuid := gen_random_uuid();
  emp_bob    uuid := gen_random_uuid();
  emp_carol  uuid := gen_random_uuid();
  emp_dave   uuid := gen_random_uuid();
  emp_eve    uuid := gen_random_uuid();

  -- client ids
  cli_acme   uuid;
  cli_globex uuid;
  cli_init   uuid;
begin
  --------------------------------------------------------------------------
  -- Employees
  --------------------------------------------------------------------------
  insert into public.employees
    (id, first_name, last_name, email, job_title, department,
     employment_type, job_function_track, job_function_name, job_function_level,
     work_start_date, _created_by)
  values
    (emp_alice, 'Alice', 'Anderson', 'alice.anderson@company.internal',
     'Engineering Manager', 'Engineering',
     'employee', 'Software Engineering', 'Engineering Manager', 'Level 5',
     '2020-03-01', sys_id),

    (emp_bob, 'Bob', 'Baker', 'bob.baker@company.internal',
     'Senior Backend Engineer', 'Engineering',
     'employee', 'Software Engineering', 'Backend Engineer', 'Level 4',
     '2021-06-15', sys_id),

    (emp_carol, 'Carol', 'Chen', 'carol.chen@company.internal',
     'Account Manager', 'Delivery',
     'employee', 'Delivery Management', 'Account Manager', 'Level 3',
     '2022-01-10', sys_id),

    (emp_dave, 'Dave', 'Davies', 'dave.davies@company.internal',
     'Senior Consultant', 'Delivery',
     'contractor', 'Delivery Management', 'Senior Consultant', 'Level 4',
     '2023-04-01', sys_id),

    (emp_eve, 'Eve', 'Evans', 'eve.evans@company.internal',
     'Graduate Engineer', 'Engineering',
     'trainee', 'Software Engineering', 'Backend Engineer', 'Level 1',
     '2025-09-01', sys_id)
  on conflict (email) do nothing;

  -- Re-resolve ids in case rows already existed (on conflict do nothing skips the insert)
  select id into emp_alice from public.employees where email = 'alice.anderson@company.internal';
  select id into emp_bob   from public.employees where email = 'bob.baker@company.internal';
  select id into emp_carol from public.employees where email = 'carol.chen@company.internal';

  -- Wire up manager relationships (Alice manages Bob, Carol, Eve; Bob manages Dave)
  update public.employees set manager_id = emp_alice
    where email in ('bob.baker@company.internal', 'carol.chen@company.internal', 'eve.evans@company.internal')
      and manager_id is null;

  update public.employees set manager_id = emp_bob
    where email = 'dave.davies@company.internal'
      and manager_id is null;

  --------------------------------------------------------------------------
  -- User accounts for seed employees
  -- Create auth + public.users rows so clients can reference them as account managers.
  --------------------------------------------------------------------------
  insert into auth.users (
    id, email, created_at, updated_at,
    raw_app_meta_data, raw_user_meta_data,
    aud, role, encrypted_password
  )
  select
    e.id, e.email, now(), now(),
    '{"provider":"email","providers":["email"]}',
    jsonb_build_object('name', e.first_name || ' ' || e.last_name),
    'authenticated', 'authenticated', ''
  from public.employees e
  where e._deleted = false
  on conflict (id) do nothing;

  insert into public.users (id, name, email, employee_id, _created_by)
  select
    e.id,
    e.first_name || ' ' || e.last_name,
    e.email,
    e.id,
    sys_id
  from public.employees e
  where e._deleted = false
  on conflict (id) do nothing;

  --------------------------------------------------------------------------
  -- Clients (resolve existing rows seeded in local dev or previous runs)
  --------------------------------------------------------------------------
  insert into public.clients (name, account_manager_id, _created_by)
  values
    ('Acme Corp',          emp_carol, sys_id),
    ('Globex Corporation', emp_carol, sys_id),
    ('Initech',            emp_carol, sys_id)
  on conflict do nothing;

  select id into cli_acme   from public.clients where name = 'Acme Corp'          and _deleted = false limit 1;
  select id into cli_globex from public.clients where name = 'Globex Corporation' and _deleted = false limit 1;
  select id into cli_init   from public.clients where name = 'Initech'            and _deleted = false limit 1;

  -- Assign Bob and Dave as representatives on Acme
  if cli_acme is not null then
    insert into public.client_representatives (client_id, user_id)
    select cli_acme, u.id from public.users u
    where u.employee_id in (emp_bob, emp_dave)
    on conflict do nothing;
  end if;

end $$;
