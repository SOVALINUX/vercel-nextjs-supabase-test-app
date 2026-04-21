import { z } from "zod";
import type { Database } from "@/lib/supabase/database.types";

export type ClientRow = Database["public"]["Tables"]["clients"]["Row"];
export type UserRow = Database["public"]["Tables"]["users"]["Row"];

export type UserPickerOption = Pick<UserRow, "id" | "name">;

export type ClientWithRelations = ClientRow & {
  account_manager: UserPickerOption | null;
  sales_executive: UserPickerOption | null;
  representatives: UserPickerOption[];
};

export const clientFormSchema = z.object({
  name: z.string().min(1, "Name is required").max(200, "Name is too long"),
  link: z
    .string()
    .optional()
    .refine(
      (v) => !v || /^https?:\/\/.+/.test(v),
      { message: "Must be a valid URL" },
    ),
  account_manager_id: z.string().uuid("Account manager is required"),
  sales_executive_id: z.string().optional(),
  representative_ids: z.array(z.string().uuid()),
});

export type ClientFormValues = z.infer<typeof clientFormSchema>;

/** Normalise form values before sending to the API: convert empty strings to undefined/null. */
export function normaliseClientPayload(values: ClientFormValues): ClientFormValues {
  return {
    ...values,
    link: values.link === "" ? undefined : values.link,
    sales_executive_id: values.sales_executive_id === "" ? undefined : values.sales_executive_id,
  };
}
