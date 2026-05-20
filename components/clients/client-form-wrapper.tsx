"use client";

import { useRouter } from "next/navigation";
import { ClientForm } from "./client-form";
import type { ClientWithRelations, UserPickerOption } from "@/lib/clients/types";

interface ClientFormWrapperProps {
  client?: ClientWithRelations;
  users: UserPickerOption[];
  trigger: React.ReactNode;
}

export function ClientFormWrapper({ client, users, trigger }: ClientFormWrapperProps) {
  const router = useRouter();

  return (
    <ClientForm
      client={client}
      users={users}
      trigger={trigger}
      onSuccess={() => router.refresh()}
    />
  );
}
