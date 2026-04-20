-- Shared trigger function: auto-sets _updated_at on every UPDATE.
-- All domain tables that have _updated_at should attach this trigger.
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new._updated_at = now();
  return new;
end;
$$;
