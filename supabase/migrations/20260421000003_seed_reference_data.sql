-- Reference / demo data — runs in every environment via db push.
-- Idempotent: all inserts use ON CONFLICT DO NOTHING.
-- Uses the system user (id = 00000000-0000-0000-0000-000000000000) seeded in migration 000003
-- as _created_by for all records.

do $$
declare
  sys_id uuid := '00000000-0000-0000-0000-000000000000';
begin
  insert into public.employees
    (first_name, last_name, email, job_title, department,
     employment_type, job_function_track, job_function_name, job_function_level,
     work_start_date, _created_by)
  values
    ('Alice', 'Anderson', 'alice.anderson@company.com',
     'Engineering Manager', 'Engineering',
     'employee', 'Software Engineering', 'Engineering Manager', 'Level 5',
     '2020-03-01', sys_id),

    ('Bob', 'Baker', 'bob.baker@company.com',
     'Senior Backend Engineer', 'Engineering',
     'employee', 'Software Engineering', 'Backend Engineer', 'Level 4',
     '2021-06-15', sys_id),

    ('Carol', 'Chen', 'carol.chen@company.com',
     'Account Manager', 'Delivery',
     'employee', 'Delivery Management', 'Account Manager', 'Level 3',
     '2022-01-10', sys_id),

    ('Dave', 'Davies', 'dave.davies@company.com',
     'Senior Consultant', 'Delivery',
     'contractor', 'Delivery Management', 'Senior Consultant', 'Level 4',
     '2023-04-01', sys_id),

    ('Eve', 'Evans', 'eve.evans@company.com',
     'Graduate Engineer', 'Engineering',
     'trainee', 'Software Engineering', 'Backend Engineer', 'Level 1',
     '2025-09-01', sys_id)
  on conflict (email) do nothing;

  -- Wire manager relationships (Alice → Bob, Carol, Eve; Bob → Dave)
  update public.employees e
    set manager_id = (select id from public.employees where email = 'alice.anderson@company.com')
  where e.email in (
    'bob.baker@company.com',
    'carol.chen@company.com',
    'eve.evans@company.com'
  ) and e.manager_id is null;

  update public.employees e
    set manager_id = (select id from public.employees where email = 'bob.baker@company.com')
  where e.email = 'dave.davies@company.com' and e.manager_id is null;

end $$;
