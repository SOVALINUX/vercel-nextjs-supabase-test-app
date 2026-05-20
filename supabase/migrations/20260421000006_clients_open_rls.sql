-- Relax client RLS to allow any authenticated user to mutate clients.
-- Permissions will be tightened in a later feature branch.

drop policy if exists "clients: manager or creator can update" on public.clients;

create policy "clients: authenticated can update"
  on public.clients for update
  to authenticated
  using (_deleted = false)
  with check (true);

drop policy if exists "client_representatives: manager or creator can manage" on public.client_representatives;
drop policy if exists "client_representatives: manager or creator can delete" on public.client_representatives;

create policy "client_representatives: authenticated can manage"
  on public.client_representatives for insert
  to authenticated
  with check (true);

create policy "client_representatives: authenticated can delete"
  on public.client_representatives for delete
  using (true);
