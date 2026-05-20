import { Badge } from "@/components/ui/badge";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import type { ClientWithRelations } from "@/lib/clients/types";

interface ClientProfileCardProps {
  client: ClientWithRelations;
}

export function ClientProfileCard({ client }: ClientProfileCardProps) {
  return (
    <Card>
      <CardHeader>
        <CardTitle className="text-xl">{client.name}</CardTitle>
      </CardHeader>
      <CardContent className="space-y-4">
        <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
          <div>
            <p className="text-sm font-medium text-muted-foreground">Website</p>
            {client.link ? (
              <a
                href={client.link}
                target="_blank"
                rel="noreferrer"
                className="text-sm hover:underline text-primary"
              >
                {client.link}
              </a>
            ) : (
              <p className="text-sm">—</p>
            )}
          </div>

          <div>
            <p className="text-sm font-medium text-muted-foreground">Account Manager</p>
            <p className="text-sm">{client.account_manager?.name ?? "—"}</p>
          </div>

          <div>
            <p className="text-sm font-medium text-muted-foreground">Sales Executive</p>
            <p className="text-sm">{client.sales_executive?.name ?? "—"}</p>
          </div>

          <div>
            <p className="text-sm font-medium text-muted-foreground">Representatives</p>
            {client.representatives.length > 0 ? (
              <div className="flex flex-wrap gap-1 mt-1">
                {client.representatives.map((rep) => (
                  <Badge key={rep.id} variant="secondary">
                    {rep.name}
                  </Badge>
                ))}
              </div>
            ) : (
              <p className="text-sm">—</p>
            )}
          </div>
        </div>
      </CardContent>
    </Card>
  );
}
