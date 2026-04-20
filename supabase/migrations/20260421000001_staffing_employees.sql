create type public.employment_type as enum ('employee', 'contractor', 'trainee');

create table public.employees (
  id                  uuid        primary key default gen_random_uuid(),
  first_name          text        not null,
  last_name           text        not null,
  email               text        not null unique,
  job_title           text,
  department          text,
  is_active           boolean     not null default true,
  work_start_date     date,
  work_end_date       date,
  manager_id          uuid        references public.employees (id),
  employment_type     public.employment_type not null default 'employee',
  job_function_track  text,
  job_function_name   text,
  job_function_level  text,
  -- base entity audit fields
  _created_at         timestamptz not null default now(),
  _created_by         uuid        not null references auth.users (id),
  _updated_at         timestamptz,
  _updated_by         uuid        references auth.users (id),
  _deleted            boolean     not null default false,
  constraint employees_work_dates_check
    check (work_end_date is null or work_start_date is null or work_end_date >= work_start_date),
  constraint employees_no_self_manager
    check (manager_id <> id)
);

create trigger set_employees_updated_at
  before update on public.employees
  for each row execute function public.set_updated_at();

create index employees_active_idx on public.employees (_deleted, is_active)
  where _deleted = false;

alter table public.employees enable row level security;

-- All authenticated users can read active employees.
create policy "employees: authenticated can select active"
  on public.employees for select
  to authenticated
  using (_deleted = false);

-- Account managers and super admins manage employees (enforced at app layer via roles).
-- At DB layer we allow any authenticated user to insert/update — role check is application-side.
create policy "employees: authenticated can insert"
  on public.employees for insert
  to authenticated
  with check (_created_by = auth.uid());

create policy "employees: authenticated can update"
  on public.employees for update
  to authenticated
  using (_deleted = false);

-- Soft-delete only.
create policy "employees: no hard delete"
  on public.employees for delete
  using (false);
