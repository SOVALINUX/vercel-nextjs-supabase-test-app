-- Reference / demo data — runs in every environment via db push.
-- Idempotent: all inserts use ON CONFLICT DO NOTHING.
-- Uses the system user (id = 00000000-0000-0000-0000-000000000000) seeded in migration 000003
-- as _created_by for all records.
--
-- NOTE: clients.account_manager_id references public.users, not employees.
-- Employees seeded here have no user accounts, so clients are omitted from this migration —
-- client data is environment-specific and belongs in application seeds or manual setup.

do $$
declare
  sys_id uuid := '00000000-0000-0000-0000-000000000000';
begin
  --------------------------------------------------------------------------
  -- Employees
  --------------------------------------------------------------------------
  insert into public.employees
    (first_name, last_name, email, job_title, department,
     employment_type, job_function_track, job_function_name, job_function_level,
     work_start_date, _created_by)
  values
    ('Alice', 'Anderson', 'alice.anderson@company.internal',
     'Engineering Manager', 'Engineering',
     'employee', 'Software Engineering', 'Engineering Manager', 'Level 5',
     '2020-03-01', sys_id),

    ('Bob', 'Baker', 'bob.baker@company.internal',
     'Senior Backend Engineer', 'Engineering',
     'employee', 'Software Engineering', 'Backend Engineer', 'Level 4',
     '2021-06-15', sys_id),

    ('Carol', 'Chen', 'carol.chen@company.internal',
     'Account Manager', 'Delivery',
     'employee', 'Delivery Management', 'Account Manager', 'Level 3',
     '2022-01-10', sys_id),

    ('Dave', 'Davies', 'dave.davies@company.internal',
     'Senior Consultant', 'Delivery',
     'contractor', 'Delivery Management', 'Senior Consultant', 'Level 4',
     '2023-04-01', sys_id),

    ('Eve', 'Evans', 'eve.evans@company.internal',
     'Graduate Engineer', 'Engineering',
     'trainee', 'Software Engineering', 'Backend Engineer', 'Level 1',
     '2025-09-01', sys_id),

    -- Management chain above Siarhei (top-down so FK references resolve)
    ('Balazs', 'Fejes', 'balazs.fejes@company.internal',
     'CEO', 'Leadership',
     'employee', 'Leadership', 'CEO', 'Level 7',
     '2015-01-01', sys_id),

    ('Viktar', 'Dvorkin', 'viktar.dvorkin@company.internal',
     'VP Delivery', 'Delivery',
     'employee', 'Delivery Management', 'VP Delivery', 'Level 6',
     '2017-03-01', sys_id),

    ('Dmitry', 'Razorionov', 'dmitry.razorionov@company.internal',
     'Head of Delivery', 'Delivery',
     'employee', 'Delivery Management', 'Head of Delivery', 'Level 5',
     '2019-06-01', sys_id),

    ('Siarhei', 'Nekhviadovich', 'siarhei.nekhviadovich@company.internal',
     'Director, Delivery Management', 'Delivery',
     'employee', 'Delivery Management', 'Director', 'B4',
     '2020-01-01', sys_id)
  on conflict (email) do nothing;

  -- Wire up manager relationships (Alice → Bob, Carol, Eve; Bob → Dave)
  -- Only set where not already assigned to keep re-runs idempotent.
  update public.employees e
    set manager_id = (select id from public.employees where email = 'alice.anderson@company.internal')
  where e.email in (
    'bob.baker@company.internal',
    'carol.chen@company.internal',
    'eve.evans@company.internal'
  ) and e.manager_id is null;

  update public.employees e
    set manager_id = (select id from public.employees where email = 'bob.baker@company.internal')
  where e.email = 'dave.davies@company.internal'
    and e.manager_id is null;

  -- Management chain: Balazs → Viktar → Dmitry → Siarhei
  update public.employees e
    set manager_id = (select id from public.employees where email = 'balazs.fejes@company.internal')
  where e.email = 'viktar.dvorkin@company.internal' and e.manager_id is null;

  update public.employees e
    set manager_id = (select id from public.employees where email = 'viktar.dvorkin@company.internal')
  where e.email = 'dmitry.razorionov@company.internal' and e.manager_id is null;

  update public.employees e
    set manager_id = (select id from public.employees where email = 'dmitry.razorionov@company.internal')
  where e.email = 'siarhei.nekhviadovich@company.internal' and e.manager_id is null;

end $$;
