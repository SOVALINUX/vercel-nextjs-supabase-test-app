import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { ClientsTable } from "@/components/clients/clients-table";
import { ClientFormWrapper } from "@/components/clients/client-form-wrapper";
import { Button } from "@/components/ui/button";
import type { ClientWithRelations, UserPickerOption } from "@/lib/clients/types";

async function getClients(
  supabase: Awaited<ReturnType<typeof createClient>>,
): Promise<ClientWithRelations[]> {
  const { data, error } = await supabase
    .from("clients")
    .select(
      `
      *,
      account_manager:users!clients_account_manager_id_fkey(id, name),
      sales_executive:users!clients_sales_executive_id_fkey(id, name),
      representatives:client_representatives(user:users(id, name))
    `,
    )
    .eq("_deleted", false)
    .order("name");

  if (error) throw error;

  return (data ?? []).map((c) => ({
    ...c,
    account_manager: c.account_manager as ClientWithRelations["account_manager"],
    sales_executive: c.sales_executive as ClientWithRelations["sales_executive"],
    representatives: (
      (c.representatives as { user: { id: string; name: string } | null }[]) ?? []
    )
      .map((r) => r.user)
      .filter((u): u is { id: string; name: string } => u !== null),
  }));
}

async function getUsers(
  supabase: Awaited<ReturnType<typeof createClient>>,
): Promise<UserPickerOption[]> {
  const { data } = await supabase
    .from("users")
    .select("id, name")
    .eq("_deleted", false)
    .eq("is_active", true)
    .order("name");
  return (data ?? []) as UserPickerOption[];
}

export default async function ClientsPage() {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) redirect("/auth/login");

  const [clients, users] = await Promise.all([
    getClients(supabase),
    getUsers(supabase),
  ]);

  return (
    <div className="flex flex-col gap-6">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold">Clients</h1>
        <ClientFormWrapper
          users={users}
          trigger={<Button>New Client</Button>}
        />
      </div>
      <ClientsTable clients={clients} />
    </div>
  );
}
