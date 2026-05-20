# Feature Specification: Clients UI

**Feature Branch**: `002-clients-ui`  
**Created**: 2026-04-21  
**Status**: Draft  
**Input**: User description: "Create new UI components: add 'Clients' button in header that opens a clients dashboard with a table view. Client names should be clickable and open a profile page with more details. On the clients dashboard there should be a button to create a new client. Users should be able to edit the client from the profile page. Ignore permissions for now."

## User Scenarios & Testing _(mandatory)_

### User Story 1 - View Clients Dashboard (Priority: P1)

A logged-in user clicks the "Clients" link in the navigation header and is taken to the Clients dashboard, which displays all clients in a sortable table. The table shows the client name, account manager, and sales executive. Each row's client name is a clickable link.

**Why this priority**: This is the entry point for all client-related workflows. Without the dashboard, no other client feature is accessible.

**Independent Test**: Can be tested by navigating to `/protected/clients` and verifying the table renders with client data from the database.

**Acceptance Scenarios**:

1. **Given** a logged-in user is on any protected page, **When** they click "Clients" in the nav header, **Then** they are navigated to the Clients dashboard page.
2. **Given** the Clients dashboard is open, **When** the page loads, **Then** a table is displayed listing all clients with columns: Name, Account Manager, Sales Executive.
3. **Given** the Clients dashboard is open and no clients exist, **When** the page loads, **Then** an empty-state message is shown (e.g., "No clients yet").

---

### User Story 2 - View Client Profile (Priority: P2)

A user clicks on a client's name in the dashboard table and is taken to a client profile page that shows the full details of that client, including name, website link, account manager, sales executive, and assigned representatives.

**Why this priority**: Viewing the profile is the prerequisite for editing; also the primary read path for client data.

**Independent Test**: Can be tested independently by navigating directly to `/protected/clients/[id]` and verifying all client fields are shown.

**Acceptance Scenarios**:

1. **Given** the Clients dashboard is displayed, **When** the user clicks a client name, **Then** they are navigated to that client's profile page at `/protected/clients/[id]`.
2. **Given** a client profile page is open, **When** it loads, **Then** all client fields are visible: name, link (if set), account manager, sales executive (if set), and the list of representatives.
3. **Given** a client profile page is open, **When** the client has no website link, **Then** the link field is either hidden or shows a placeholder (e.g., "—").

---

### User Story 3 - Create New Client (Priority: P3)

From the Clients dashboard, the user clicks a "New Client" button which opens a form (modal or page) to enter the client details. On submit, the new client is saved and appears in the table.

**Why this priority**: Required for populating the system with client data, but read-only browsing works without it.

**Independent Test**: Can be tested by clicking "New Client," filling the required fields, submitting, and verifying the new row appears in the dashboard table.

**Acceptance Scenarios**:

1. **Given** the Clients dashboard is open, **When** the user clicks "New Client," **Then** a form is presented with fields: Name (required), Website Link (optional), Account Manager (required, user picker), Sales Executive (optional, user picker).
2. **Given** the create form is open and the user submits with all required fields, **When** the server accepts the data, **Then** the new client is saved, the form closes, and the dashboard table refreshes to include the new client.
3. **Given** the create form is open, **When** the user submits with a missing required field (e.g., Name), **Then** an inline validation error is shown and the form is not submitted.

---

### User Story 4 - Edit Client from Profile (Priority: P4)

From the client profile page the user clicks an "Edit" button. The profile fields become editable (inline or via a modal). On save the updated data is persisted and reflected on the profile page.

**Why this priority**: Editing depends on the profile view being built first; lower priority than creation but closes the full CRUD loop.

**Independent Test**: Can be tested by opening a client profile, clicking "Edit," changing a field, saving, and verifying the updated value is shown.

**Acceptance Scenarios**:

1. **Given** a client profile page is open, **When** the user clicks "Edit," **Then** the client fields become editable.
2. **Given** the edit form is populated, **When** the user changes a value and clicks "Save," **Then** the changes are persisted and the profile page shows the updated data.
3. **Given** the edit form is open, **When** the user clicks "Cancel," **Then** the form closes without saving any changes.
4. **Given** the edit form is open, **When** the user clears a required field (e.g., Name) and saves, **Then** an inline validation error is shown and the save is not executed.

---

### Edge Cases

- What happens when a client ID in the URL does not exist? → A "not found" message or redirect to the dashboard.
- What happens if the database returns an error on save? → A user-friendly error toast/message is shown and the form stays open.
- What happens when no users exist to assign as account manager? → The user picker shows an empty state with guidance.
- What happens when the client name exceeds a reasonable character limit? → Inline validation error before submission.

## Requirements _(mandatory)_

### Functional Requirements

- **FR-001**: The navigation header on protected pages MUST include a "Clients" link that navigates to the Clients dashboard.
- **FR-002**: The Clients dashboard MUST display all clients in a table with columns: Name (clickable), Account Manager, Sales Executive.
- **FR-003**: The Clients dashboard MUST include a "New Client" button that opens a client creation form.
- **FR-004**: The client creation form MUST capture: Name (required), Website Link (optional), Account Manager (required — selected from existing users), Sales Executive (optional — selected from existing users).
- **FR-005**: On successful submission of the creation form, the new client MUST be persisted and appear in the dashboard table without a full page reload.
- **FR-006**: Each client name in the dashboard table MUST be a link that navigates to that client's profile page.
- **FR-007**: The client profile page MUST display: Name, Website Link, Account Manager, Sales Executive, and the list of Representatives.
- **FR-008**: The client profile page MUST include an "Edit" button that enables editing of all client fields.
- **FR-009**: On saving edits, the updated client data MUST be persisted and reflected on the profile page.
- **FR-010**: All forms MUST validate required fields client-side before submission and display inline error messages for invalid inputs.
- **FR-011**: Server-side errors during create or update MUST be surfaced to the user as readable error messages (toast or inline).
- **FR-012**: Navigating to a client profile URL for a non-existent client ID MUST display a "not found" message or redirect to the dashboard.

### Key Entities _(include if feature involves data)_

- **Client**: Central entity for this feature — see [`domain/client-management/entities/client.md`](/domain/client-management/entities/client.md). Fields: `name`, `link`, `account_manager_id`, `sales_executive_id`. Join table `client_representatives` stores additional representative users.
- **User**: Referenced by `account_manager_id`, `sales_executive_id`, and `client_representatives`. Needed for user pickers in the create/edit forms — see [`domain/core/entities/`](/domain/core/entities/).

## Success Criteria _(mandatory)_

### Measurable Outcomes

- **SC-001**: A user can navigate from any protected page to the Clients dashboard in one click.
- **SC-002**: The Clients dashboard loads and displays all clients within 2 seconds under normal network conditions.
- **SC-003**: A user can create a new client (fill form, submit, see it in the table) in under 2 minutes.
- **SC-004**: A user can open a client profile and update a field in under 1 minute.
- **SC-005**: All required-field validation errors are visible to the user before any data is sent to the server.
- **SC-006**: 100% of client profile links in the table navigate to the correct profile page.

## Assumptions

- Permissions are explicitly out of scope for this feature — all authenticated users can view, create, and edit all clients.
- The existing protected layout (with its navigation header) will be updated to include the "Clients" link; no new layout is introduced.
- User picker for account manager / sales executive / representatives will draw from the existing `users` table without additional filtering.
- Representatives management (adding/removing from the join table) is in scope for the edit form.
- The create/edit form will be presented as a dialog/modal overlaid on the dashboard or profile page — no separate route needed for the form.
- Mobile responsiveness follows existing app conventions (table may scroll horizontally on small screens).
- The feature targets the `app/protected/` route segment, consistent with the existing authenticated area.
