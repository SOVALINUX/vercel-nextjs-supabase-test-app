-- Migration 000003 was edited after it had already been applied to remote,
-- so the employee rows and email domain corrections never executed via db push.
-- This migration is idempotent and brings remote into the correct state.

do $$
declare
  sys_id uuid := '00000000-0000-0000-0000-000000000000';
begin
  --------------------------------------------------------------------------
  -- 1. Insert the four management-chain employees that were missing on remote
  --    (originally added to 000003 after it was already deployed).
  --    Uses NOT EXISTS so re-runs are safe.
  --------------------------------------------------------------------------
  if not exists (select 1 from public.employees where email = 'balazs.fejes@company.com') then
    insert into public.employees
      (first_name, last_name, email, job_title, department,
       employment_type, job_function_track, job_function_name, job_function_level,
       work_start_date, _created_by)
    values
      ('Balazs', 'Fejes', 'balazs.fejes@company.com',
       'CEO', 'Leadership',
       'employee', 'Leadership', 'CEO', 'C',
       '2015-01-01', sys_id);
  end if;

  if not exists (select 1 from public.employees where email = 'viktar.dvorkin@company.com') then
    insert into public.employees
      (first_name, last_name, email, job_title, department,
       employment_type, job_function_track, job_function_name, job_function_level,
       work_start_date, _created_by)
    values
      ('Viktar', 'Dvorkin', 'viktar.dvorkin@company.com',
       'VP Delivery', 'Delivery',
       'employee', 'Delivery Management', 'VP Delivery', 'C',
       '2017-03-01', sys_id);
  end if;

  if not exists (select 1 from public.employees where email = 'dmitry.razorionov@company.com') then
    insert into public.employees
      (first_name, last_name, email, job_title, department,
       employment_type, job_function_track, job_function_name, job_function_level,
       work_start_date, _created_by)
    values
      ('Dmitry', 'Razorionov', 'dmitry.razorionov@company.com',
       'Head of Delivery', 'Delivery',
       'employee', 'Delivery Management', 'Head of Delivery', 'B5',
       '2019-06-01', sys_id);
  end if;

  if not exists (select 1 from public.employees where email = 'siarhei.nekhviadovich@company.com') then
    insert into public.employees
      (first_name, last_name, email, job_title, department,
       employment_type, job_function_track, job_function_name, job_function_level,
       work_start_date, _created_by)
    values
      ('Siarhei', 'Nekhviadovich', 'siarhei.nekhviadovich@company.com',
       'Director, Delivery Management', 'Delivery',
       'employee', 'Delivery Management', 'Director', 'B4',
       '2020-01-01', sys_id);
  end if;

  --------------------------------------------------------------------------
  -- 2. Fix emails on the five employees seeded by 000003 with the old
  --    @company.internal domain.
  --------------------------------------------------------------------------
  update public.employees set email = 'alice.anderson@company.com'
    where email = 'alice.anderson@company.internal';
  update public.employees set email = 'bob.baker@company.com'
    where email = 'bob.baker@company.internal';
  update public.employees set email = 'carol.chen@company.com'
    where email = 'carol.chen@company.internal';
  update public.employees set email = 'dave.davies@company.com'
    where email = 'dave.davies@company.internal';
  update public.employees set email = 'eve.evans@company.com'
    where email = 'eve.evans@company.internal';

  --------------------------------------------------------------------------
  -- 3. Wire manager relationships (idempotent — only sets where null).
  --------------------------------------------------------------------------
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

  update public.employees e
    set manager_id = (select id from public.employees where email = 'balazs.fejes@company.com')
  where e.email = 'viktar.dvorkin@company.com' and e.manager_id is null;

  update public.employees e
    set manager_id = (select id from public.employees where email = 'viktar.dvorkin@company.com')
  where e.email = 'dmitry.razorionov@company.com' and e.manager_id is null;

  update public.employees e
    set manager_id = (select id from public.employees where email = 'dmitry.razorionov@company.com')
  where e.email = 'siarhei.nekhviadovich@company.com' and e.manager_id is null;

end $$;
