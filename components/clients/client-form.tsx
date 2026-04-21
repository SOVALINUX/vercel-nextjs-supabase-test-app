"use client";

import { useState } from "react";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { toast } from "sonner";
import { X } from "lucide-react";

import { Button } from "@/components/ui/button";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog";
import {
  Form,
  FormControl,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from "@/components/ui/form";
import { Input } from "@/components/ui/input";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { Badge } from "@/components/ui/badge";
import { clientFormSchema, normaliseClientPayload, type ClientFormValues, type ClientWithRelations, type UserPickerOption } from "@/lib/clients/types";

interface ClientFormProps {
  client?: ClientWithRelations;
  users: UserPickerOption[];
  trigger: React.ReactNode;
  onSuccess?: () => void;
}

export function ClientForm({ client, users, trigger, onSuccess }: ClientFormProps) {
  const [open, setOpen] = useState(false);
  const isEdit = !!client;

  const form = useForm<ClientFormValues, unknown, ClientFormValues>({
    resolver: zodResolver(clientFormSchema),
    defaultValues: {
      name: client?.name ?? "",
      link: client?.link ?? "",
      account_manager_id: client?.account_manager_id ?? "",
      sales_executive_id: client?.sales_executive_id ?? "",
      representative_ids: client?.representatives.map((r) => r.id) ?? [],
    },
  });

  const representativeIds = form.watch("representative_ids");
  const selectedReps = users.filter((u) => representativeIds.includes(u.id));
  const availableReps = users.filter((u) => !representativeIds.includes(u.id));

  function addRepresentative(userId: string) {
    if (!representativeIds.includes(userId)) {
      form.setValue("representative_ids", [...representativeIds, userId]);
    }
  }

  function removeRepresentative(userId: string) {
    form.setValue(
      "representative_ids",
      representativeIds.filter((id) => id !== userId),
    );
  }

  async function onSubmit(values: ClientFormValues) {
    const url = isEdit ? `/api/clients/${client.id}` : "/api/clients";
    const method = isEdit ? "PATCH" : "POST";

    const res = await fetch(url, {
      method,
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(normaliseClientPayload(values)),
    });

    const json = (await res.json()) as { data: unknown; error: string | null };

    if (!res.ok || json.error) {
      toast.error(json.error ?? "Something went wrong");
      return;
    }

    toast.success(isEdit ? "Client updated" : "Client created");
    setOpen(false);
    form.reset();
    onSuccess?.();
  }

  return (
    <Dialog open={open} onOpenChange={setOpen}>
      <DialogTrigger asChild>{trigger}</DialogTrigger>
      <DialogContent className="max-w-lg">
        <DialogHeader>
          <DialogTitle>{isEdit ? "Edit Client" : "New Client"}</DialogTitle>
        </DialogHeader>

        <Form {...form}>
          <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-4">
            <FormField
              control={form.control}
              name="name"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>Name *</FormLabel>
                  <FormControl>
                    <Input placeholder="Client name" {...field} />
                  </FormControl>
                  <FormMessage />
                </FormItem>
              )}
            />

            <FormField
              control={form.control}
              name="link"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>Website</FormLabel>
                  <FormControl>
                    <Input placeholder="https://example.com" {...field} />
                  </FormControl>
                  <FormMessage />
                </FormItem>
              )}
            />

            <FormField
              control={form.control}
              name="account_manager_id"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>Account Manager *</FormLabel>
                  <Select onValueChange={field.onChange} defaultValue={field.value}>
                    <FormControl>
                      <SelectTrigger>
                        <SelectValue placeholder="Select account manager" />
                      </SelectTrigger>
                    </FormControl>
                    <SelectContent>
                      {users.map((u) => (
                        <SelectItem key={u.id} value={u.id}>
                          {u.name}
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                  <FormMessage />
                </FormItem>
              )}
            />

            <FormField
              control={form.control}
              name="sales_executive_id"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>Sales Executive</FormLabel>
                  <Select
                    onValueChange={field.onChange}
                    defaultValue={field.value ?? ""}
                  >
                    <FormControl>
                      <SelectTrigger>
                        <SelectValue placeholder="Select sales executive (optional)" />
                      </SelectTrigger>
                    </FormControl>
                    <SelectContent>
                      <SelectItem value="">None</SelectItem>
                      {users.map((u) => (
                        <SelectItem key={u.id} value={u.id}>
                          {u.name}
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                  <FormMessage />
                </FormItem>
              )}
            />

            <FormField
              control={form.control}
              name="representative_ids"
              render={() => (
                <FormItem>
                  <FormLabel>Representatives</FormLabel>
                  {selectedReps.length > 0 && (
                    <div className="flex flex-wrap gap-1 mb-2">
                      {selectedReps.map((rep) => (
                        <Badge key={rep.id} variant="secondary" className="gap-1">
                          {rep.name}
                          <button
                            type="button"
                            onClick={() => removeRepresentative(rep.id)}
                            className="ml-1 hover:text-destructive"
                            aria-label={`Remove ${rep.name}`}
                          >
                            <X className="h-3 w-3" />
                          </button>
                        </Badge>
                      ))}
                    </div>
                  )}
                  {availableReps.length > 0 && (
                    <Select onValueChange={addRepresentative} value="">
                      <FormControl>
                        <SelectTrigger>
                          <SelectValue placeholder="Add representative" />
                        </SelectTrigger>
                      </FormControl>
                      <SelectContent>
                        {availableReps.map((u) => (
                          <SelectItem key={u.id} value={u.id}>
                            {u.name}
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                  )}
                  <FormMessage />
                </FormItem>
              )}
            />

            <div className="flex justify-end gap-2 pt-2">
              <Button
                type="button"
                variant="outline"
                onClick={() => setOpen(false)}
              >
                Cancel
              </Button>
              <Button type="submit" disabled={form.formState.isSubmitting}>
                {form.formState.isSubmitting ? "Saving…" : isEdit ? "Save Changes" : "Create Client"}
              </Button>
            </div>
          </form>
        </Form>
      </DialogContent>
    </Dialog>
  );
}
