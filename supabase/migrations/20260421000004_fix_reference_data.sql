-- Corrects the 5 employees seeded by 000003 (email domain fix) and adds the
-- management chain that was mistakenly edited into 000003 after it had been
-- deployed — so it never ran on remote.

-- Fix email domain on existing employees
update public.employees set email = 'alice.anderson@company.com' where email = 'alice.anderson@company.internal';
update public.employees set email = 'bob.baker@company.com'       where email = 'bob.baker@company.internal';
update public.employees set email = 'carol.chen@company.com'      where email = 'carol.chen@company.internal';
update public.employees set email = 'dave.davies@company.com'     where email = 'dave.davies@company.internal';
update public.employees set email = 'eve.evans@company.com'       where email = 'eve.evans@company.internal';

-- Insert management chain
insert into public.employees
  (first_name, last_name, email, job_title, department,
   employment_type, job_function_track, job_function_name, job_function_level,
   work_start_date, _created_by)
values
  ('Balazs',  'Fejes',         'balazs.fejes@company.com',
   'CEO', 'Leadership',
   'employee', 'Leadership', 'CEO', 'C',
   '2015-01-01', '00000000-0000-0000-0000-000000000000'),

  ('Viktar',  'Dvorkin',       'viktar.dvorkin@company.com',
   'VP Delivery', 'Delivery',
   'employee', 'Delivery Management', 'VP Delivery', 'C',
   '2017-03-01', '00000000-0000-0000-0000-000000000000'),

  ('Dmitry',  'Razorionov',    'dmitry.razorionov@company.com',
   'Head of Delivery', 'Delivery',
   'employee', 'Delivery Management', 'Head of Delivery', 'B5',
   '2019-06-01', '00000000-0000-0000-0000-000000000000'),

  ('Siarhei', 'Nekhviadovich', 'siarhei.nekhviadovich@company.com',
   'Director, Delivery Management', 'Delivery',
   'employee', 'Delivery Management', 'Director', 'B4',
   '2020-01-01', '00000000-0000-0000-0000-000000000000');

-- Wire manager chain
update public.employees set manager_id = (select id from public.employees where email = 'balazs.fejes@company.com')
  where email = 'viktar.dvorkin@company.com';

update public.employees set manager_id = (select id from public.employees where email = 'viktar.dvorkin@company.com')
  where email = 'dmitry.razorionov@company.com';

update public.employees set manager_id = (select id from public.employees where email = 'dmitry.razorionov@company.com')
  where email = 'siarhei.nekhviadovich@company.com';
