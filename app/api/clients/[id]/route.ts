import { NextRequest, NextResponse } from "next/server";
import { createClient } from "@/lib/supabase/server";
import { clientFormSchema, type ClientWithRelations } from "@/lib/clients/types";

type RouteContext = { params: Promise<{ id: string }> };

async function fetchClientWithRelations(
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

export async function GET(_request: NextRequest, { params }: RouteContext) {
  try {
    const { id } = await params;
    const supabase = await createClient();
    const {
      data: { user },
    } = await supabase.auth.getUser();
    if (!user) {
      return NextResponse.json({ data: null, error: "Unauthorized" }, { status: 401 });
    }

    const client = await fetchClientWithRelations(supabase, id);
    if (!client) {
      return NextResponse.json({ data: null, error: "Client not found" }, { status: 404 });
    }
    return NextResponse.json({ data: client, error: null });
  } catch (err) {
    const message = err instanceof Error ? err.message : "Internal server error";
    return NextResponse.json({ data: null, error: message }, { status: 500 });
  }
}

export async function PATCH(request: NextRequest, { params }: RouteContext) {
  try {
    const { id } = await params;
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

    const { data: updated, error: updateError } = await supabase
      .from("clients")
      .update({
        name,
        link: link ?? null,
        account_manager_id,
        sales_executive_id: sales_executive_id ?? null,
        _updated_by: user.id,
      })
      .eq("id", id)
      .eq("_deleted", false)
      .select()
      .single();

    if (updateError) {
      if (updateError.code === "PGRST116") {
        return NextResponse.json({ data: null, error: "Client not found" }, { status: 404 });
      }
      return NextResponse.json({ data: null, error: updateError.message }, { status: 500 });
    }
    if (!updated) {
      return NextResponse.json({ data: null, error: "Client not found" }, { status: 404 });
    }

    // Reconcile representatives: fetch current, diff, delete removed, insert added.
    const { data: currentReps } = await supabase
      .from("client_representatives")
      .select("user_id")
      .eq("client_id", id);

    const currentIds = new Set((currentReps ?? []).map((r) => r.user_id));
    const desiredIds = new Set(representative_ids);

    const toDelete = [...currentIds].filter((uid) => !desiredIds.has(uid));
    const toInsert = [...desiredIds].filter((uid) => !currentIds.has(uid));

    if (toDelete.length > 0) {
      await supabase
        .from("client_representatives")
        .delete()
        .eq("client_id", id)
        .in("user_id", toDelete);
    }
    if (toInsert.length > 0) {
      await supabase
        .from("client_representatives")
        .insert(toInsert.map((uid) => ({ client_id: id, user_id: uid })));
    }

    return NextResponse.json({ data: updated, error: null });
  } catch (err) {
    const message = err instanceof Error ? err.message : "Internal server error";
    return NextResponse.json({ data: null, error: message }, { status: 500 });
  }
}
