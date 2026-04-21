-- Creates auth + public.users accounts for the four named employees and links
-- them via public.users.employee_id.
-- Passwords are temporary and should be rotated on first login in production.

do $$
declare
  uid_alice   uuid := gen_random_uuid();
  uid_bob     uuid := gen_random_uuid();
  uid_dmitry  uuid := gen_random_uuid();
  uid_siarhei uuid := gen_random_uuid();
begin
  -- Insert auth.users rows; the handle_new_auth_user trigger auto-creates
  -- the matching public.users rows.
  insert into auth.users (
    id, email, encrypted_password, email_confirmed_at,
    created_at, updated_at, raw_app_meta_data, raw_user_meta_data, aud, role
  ) values
    (uid_alice,
     'alice.anderson@company.com',
     crypt('ChangeMe123!', gen_salt('bf')),
     now(), now(), now(),
     '{"provider":"email","providers":["email"]}',
     '{"name":"Alice Anderson"}',
     'authenticated', 'authenticated'),

    (uid_bob,
     'bob.baker@company.com',
     crypt('ChangeMe123!', gen_salt('bf')),
     now(), now(), now(),
     '{"provider":"email","providers":["email"]}',
     '{"name":"Bob Baker"}',
     'authenticated', 'authenticated'),

    (uid_dmitry,
     'dmitry.razorionov@company.com',
     crypt('ChangeMe123!', gen_salt('bf')),
     now(), now(), now(),
     '{"provider":"email","providers":["email"]}',
     '{"name":"Dmitry Razorionov"}',
     'authenticated', 'authenticated'),

    (uid_siarhei,
     'siarhei.nekhviadovich@company.com',
     crypt('ChangeMe123!', gen_salt('bf')),
     now(), now(), now(),
     '{"provider":"email","providers":["email"]}',
     '{"name":"Siarhei Nekhviadovich"}',
     'authenticated', 'authenticated');

  -- Link each user to their employee record
  update public.users set employee_id = (select id from public.employees where email = 'alice.anderson@company.com')
    where id = uid_alice;

  update public.users set employee_id = (select id from public.employees where email = 'bob.baker@company.com')
    where id = uid_bob;

  update public.users set employee_id = (select id from public.employees where email = 'dmitry.razorionov@company.com')
    where id = uid_dmitry;

  update public.users set employee_id = (select id from public.employees where email = 'siarhei.nekhviadovich@company.com')
    where id = uid_siarhei;

end $$;
