# API Contracts: Clients

**Branch**: `002-clients-ui` | **Date**: 2026-04-21

All endpoints are under `app/api/clients/` and require an authenticated session cookie (enforced by Supabase SSR server client). Returns consistent `{ data, error }` JSON.

---

## `GET /api/clients`

List all active clients with their account manager and sales executive names.

**Auth**: Required (session cookie)

**Response 200**:

```json
{
  "data": [
    {
      "id": "uuid",
      "name": "Acme Corp",
      "link": "https://acme.example.com",
      "account_manager": { "id": "uuid", "name": "Alice Smith" },
      "sales_executive": { "id": "uuid", "name": "Bob Jones" } | null,
      "representatives": [{ "id": "uuid", "name": "Carol Lee" }]
    }
  ],
  "error": null
}
```

**Response 401** (no session):

```json
{ "data": null, "error": "Unauthorized" }
```

---

## `POST /api/clients`

Create a new client.

**Auth**: Required

**Request body**:

```json
{
  "name": "New Corp",
  "link": "https://newcorp.com",
  "account_manager_id": "uuid",
  "sales_executive_id": "uuid | null",
  "representative_ids": ["uuid", "uuid"]
}
```

**Validation**:

- `name`: required, non-empty string
- `link`: optional; must be valid URL if provided
- `account_manager_id`: required, must be an existing active user UUID
- `sales_executive_id`: optional
- `representative_ids`: array of user UUIDs (may be empty)

**Response 201**:

```json
{
  "data": { "id": "uuid", "name": "New Corp", "..." },
  "error": null
}
```

**Response 400** (validation failure):

```json
{ "data": null, "error": "Name is required" }
```

**Response 401**: `{ "data": null, "error": "Unauthorized" }`

---

## `GET /api/clients/[id]`

Get a single client with full relations.

**Auth**: Required

**Response 200**:

```json
{
  "data": {
    "id": "uuid",
    "name": "Acme Corp",
    "link": "https://acme.example.com",
    "account_manager": { "id": "uuid", "name": "Alice Smith" },
    "sales_executive": { "id": "uuid", "name": "Bob Jones" } | null,
    "representatives": [{ "id": "uuid", "name": "Carol Lee" }]
  },
  "error": null
}
```

**Response 404**:

```json
{ "data": null, "error": "Client not found" }
```

---

## `PATCH /api/clients/[id]`

Update an existing client. Partial body accepted; only provided fields are updated. `representative_ids` is a replacement list — the Route Handler diffs against current state and reconciles inserts/deletes on `client_representatives`.

**Auth**: Required (RLS enforces `account_manager_id = auth.uid() OR _created_by = auth.uid()`)

**Request body** (all fields optional):

```json
{
  "name": "Acme Corp Updated",
  "link": "https://acme.example.com",
  "account_manager_id": "uuid",
  "sales_executive_id": "uuid | null",
  "representative_ids": ["uuid"]
}
```

**Response 200**:

```json
{
  "data": { "id": "uuid", "..." },
  "error": null
}
```

**Response 403** (RLS violation — user is not manager or creator):

```json
{ "data": null, "error": "Forbidden" }
```

**Response 404**: `{ "data": null, "error": "Client not found" }`
