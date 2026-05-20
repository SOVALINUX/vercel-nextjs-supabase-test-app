import { NextRequest, NextResponse } from "next/server";
import { createClient } from "@/lib/supabase/server";
import { clientFormSchema, type ClientWithRelations } from "@/lib/clients/types";

async function fetchClientsWithRelations(
  supabase: Awaited<ReturnType<typeof createClient>>,
): Promise<ClientWithRelations[]> {
  const { data: clients, error } = await supabase
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

  return (clients ?? []).map((c) => ({
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

export async function GET() {
  try {
    const supabase = await createClient();
    const {
      data: { user },
    } = await supabase.auth.getUser();
    if (!user) {
      return NextResponse.json({ data: null, error: "Unauthorized" }, { status: 401 });
    }

    const clients = await fetchClientsWithRelations(supabase);
    return NextResponse.json({ data: clients, error: null });
  } catch (err) {
    const message = err instanceof Error ? err.message : "Internal server error";
    return NextResponse.json({ data: null, error: message }, { status: 500 });
  }
}

export async function POST(request: NextRequest) {
  try {
    const supabase = await createClient();
    const {
      data: { user },
    } = await supabase.auth.getUser();
    if (!user) {
      return NextResponse.json({ data: null, error: "Unauthorized" }, { status: 401 });
    }

    const body: unknown = await request.json();
    const parsed = clientFormSchema.safeParse(body);
    if (!parsed.success) {
      const message = parsed.error.issues[0]?.message ?? "Validation error";
      return NextResponse.json({ data: null, error: message }, { status: 400 });
    }

    const { name, link, account_manager_id, sales_executive_id, representative_ids } =
      parsed.data;

    const { data: client, error: insertError } = await supabase
      .from("clients")
      .insert({
        name,
        link: link ?? null,
        account_manager_id,
        sales_executive_id: sales_executive_id ?? null,
        _created_by: user.id,
      })
      .select()
      .single();

    if (insertError || !client) {
      return NextResponse.json(
        { data: null, error: insertError?.message ?? "Failed to create client" },
        { status: 500 },
      );
    }

    if (representative_ids.length > 0) {
      const { error: repError } = await supabase.from("client_representatives").insert(
        representative_ids.map((uid) => ({ client_id: client.id, user_id: uid })),
      );
      if (repError) {
        return NextResponse.json({ data: null, error: repError.message }, { status: 500 });
      }
    }

    return NextResponse.json({ data: client, error: null }, { status: 201 });
  } catch (err) {
    const message = err instanceof Error ? err.message : "Internal server error";
    return NextResponse.json({ data: null, error: message }, { status: 500 });
  }
}
