import { redirect } from "next/navigation";
import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import { ClientProfileCard } from "@/components/clients/client-profile-card";
import { ClientFormWrapper } from "@/components/clients/client-form-wrapper";
import { Button } from "@/components/ui/button";
import type { ClientWithRelations, UserPickerOption } from "@/lib/clients/types";

async function getClient(
  supabase: Awaited<ReturnType<typeof createClient>>,
  id: string,
): Promise<ClientWithRelations | null> {
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
    .eq("id", id)
    .eq("_deleted", false)
    .single();

  if (error || !data) return null;

  return {
    ...data,
    account_manager: data.account_manager as ClientWithRelations["account_manager"],
    sales_executive: data.sales_executive as ClientWithRelations["sales_executive"],
    representatives: (
      (data.representatives as { user: { id: string; name: string } | null }[]) ?? []
    )
      .map((r) => r.user)
      .filter((u): u is { id: string; name: string } => u !== null),
  };
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

interface ClientProfilePageProps {
  params: Promise<{ id: string }>;
}

export default async function ClientProfilePage({ params }: ClientProfilePageProps) {
  const { id } = await params;
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) redirect("/auth/login");

  const [client, users] = await Promise.all([getClient(supabase, id), getUsers(supabase)]);

  if (!client) {
    return (
      <div className="flex flex-col gap-4">
        <p className="text-muted-foreground">Client not found.</p>
        <Link href="/protected/clients" className="text-sm hover:underline text-primary">
          ← Back to Clients
        </Link>
      </div>
    );
  }

  return (
    <div className="flex flex-col gap-6">
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-3">
          <Link
            href="/protected/clients"
            className="text-sm text-muted-foreground hover:underline"
          >
            ← Clients
          </Link>
          <span className="text-muted-foreground">/</span>
          <h1 className="text-2xl font-bold">{client.name}</h1>
        </div>
        <ClientFormWrapper
          client={client}
          users={users}
          trigger={<Button variant="outline">Edit</Button>}
        />
      </div>
      <ClientProfileCard client={client} />
    </div>
  );
}
