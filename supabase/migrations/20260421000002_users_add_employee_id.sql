-- Link a user account to its corresponding employee record (nullable — not all users are employees
-- and not all employees have user accounts).
alter table public.users
  add column employee_id uuid references public.employees (id) on delete set null;

create index users_employee_id_idx on public.users (employee_id)
  where employee_id is not null;
