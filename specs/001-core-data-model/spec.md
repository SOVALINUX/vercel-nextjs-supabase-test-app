# Feature Specification: Core Data Model — Users, Roles, Clients, Employees, Opportunities

**Feature Branch**: `001-core-data-model`
**Created**: 2026-04-20
**Status**: Draft
**Input**: User description: "Describe the data model for users, roles, and clients. For users,
we should have id, name, and email. For roles, we should have the super admin role with all the
permissions and also the role account manager. For clients, we should have id, name, and link
(e.g., sales executives, account manager, and list of account representatives). For employees,
create some basic data model. For opportunities, create some data model. All tables should have
system metadata like id, created_by, created_at, updated_by, and updated_at."

## User Scenarios & Testing _(mandatory)_

### User Story 1 — System Administrator Manages Users and Roles (Priority: P1)

A Super Admin logs into the system and can create, view, edit, and deactivate user accounts.
They assign roles to users (Super Admin or Account Manager). The system enforces that each user
has exactly one role.

**Why this priority**: Users and roles are the foundation of the entire system. No other entity
can be securely accessed without an authenticated, role-assigned user.

**Independent Test**: Can be tested by creating a user, assigning a role, verifying the user
record persists with the correct role, and verifying a user without a role cannot access protected
resources.

**Acceptance Scenarios**:

1. **Given** a Super Admin is authenticated, **When** they create a new user with name, email,
   and role, **Then** the user record is stored with all system metadata populated (id,
   created_by, created_at, updated_by, updated_at).
2. **Given** a user record exists, **When** a Super Admin updates the user's role, **Then**
   updated_by and updated_at are refreshed automatically.
3. **Given** a user record exists, **When** a Super Admin deactivates the user, **Then** the
   user can no longer authenticate and the record reflects the inactive status.

---

### User Story 2 — Account Manager Views and Manages Client Records (Priority: P2)

An Account Manager logs in and can view the list of clients. They can create a new client record
with name and website link, and assign a sales executive, an account manager, and one or more
account representatives to it.

**Why this priority**: Clients are the primary business entity. Account Managers need this data
to perform their day-to-day work.

**Independent Test**: Can be tested by creating a client, assigning staff contacts, and verifying
the full client profile (including linked contacts) is retrievable.

**Acceptance Scenarios**:

1. **Given** an Account Manager is authenticated, **When** they create a client with name, link,
   sales executive, account manager, and at least one account representative, **Then** the client
   record is saved with all system metadata.
2. **Given** a client exists, **When** an Account Manager updates the assigned account manager,
   **Then** updated_by and updated_at are refreshed.
3. **Given** a client record, **When** the Account Manager views it, **Then** they see the full
   profile including all linked contacts.

---

### User Story 3 — Account Manager Manages Employee Records (Priority: P3)

An Account Manager can create and update employee profiles, capturing the basic attributes needed
for staffing and supply-demand matching.

**Why this priority**: Employees are the supply side of the replenishment model. Their profiles
must exist before staffing assignments or opportunity matching can occur.

**Independent Test**: Can be tested by creating an employee record and verifying all fields and
system metadata are persisted correctly.

**Acceptance Scenarios**:

1. **Given** an authenticated Account Manager, **When** they create an employee with all required
   fields, **Then** the record is saved with system metadata.
2. **Given** an employee record, **When** the Account Manager updates any field, **Then**
   updated_by and updated_at are refreshed.

---

### User Story 4 — Account Manager Records an Opportunity (Priority: P4)

An Account Manager creates an opportunity linked to a client, specifying demand details such as
role needed, headcount, target start date, and current status.

**Why this priority**: Opportunities represent the demand side of the replenishment model and
enable the supply-demand matching workflow.

**Independent Test**: Can be tested by creating an opportunity linked to an existing client and
verifying the record and its metadata are stored correctly.

**Acceptance Scenarios**:

1. **Given** an authenticated Account Manager and an existing client, **When** they create an
   opportunity with required fields, **Then** the record is saved with a reference to the client
   and system metadata.
2. **Given** an opportunity, **When** its status changes, **Then** updated_by and updated_at
   refresh automatically.

---

### Edge Cases

- What happens when a user is assigned a role that does not exist?
- What happens when a client is created without a sales executive (optional contact)?
- How does the system handle duplicate email addresses for users or employees?
- What happens when an opportunity is linked to a deleted or inactive client?
- What happens when updated_by references a user who has since been deactivated?

## Requirements _(mandatory)_

### Functional Requirements

- **FR-001**: System MUST store each user with: id, name, email (unique), role reference, active
  status, and standard system metadata.
- **FR-002**: System MUST prevent duplicate user emails.
- **FR-003**: System MUST support exactly two roles at launch: Super Admin (all permissions) and
  Account Manager (client, employee, and opportunity management permissions).
- **FR-004**: System MUST store each role with: id, name, description, and system metadata.
- **FR-005**: System MUST store each client with: id, name, website link, references to a sales
  executive (optional), an account manager, and a list of account representatives, plus system
  metadata.
- **FR-006**: System MUST store each employee with: id, first name, last name, email, job title,
  department, employment status, and system metadata.
- **FR-007**: System MUST store each opportunity with: id, title, client reference, role/skill
  needed, headcount quantity, target start date, status, and system metadata.
- **FR-008**: System MUST automatically populate created_by and created_at on record creation
  without requiring manual input from the user.
- **FR-009**: System MUST automatically populate updated_by and updated_at on any record update.
- **FR-010**: System MUST enforce that only authenticated users can create, read, update, or
  deactivate any record.
- **FR-011**: System MUST enforce role-based access: Super Admin can manage all entities; Account
  Manager can manage clients, employees, and opportunities but cannot manage users or roles.

### Key Entities

Full data model definitions live in the `domain/` folder alongside this spec:

| Entity          | File                                                                                         | Summary                                                                                                                       |
| --------------- | -------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| **Base Entity** | [/domain/base-entity.md](/domain/base-entity.md)                                             | Shared audit fields inherited by all entities (`id`, `created_by`, `created_at`, `updated_by`, `updated_at`).                 |
| **User**        | [/domain/core/entities/user.md](/domain/core/entities/user.md)                               | Authenticated identity. Has a name, unique email, a single role, and an active status.                                        |
| **Role**        | [/domain/core/entities/role.md](/domain/core/entities/role.md)                               | Named permission profile. Seeded at launch: `super_admin` and `account_manager`.                                              |
| **Client**      | [/domain/client-management/entities/client.md](/domain/client-management/entities/client.md) | Business organisation. Carries a name, link, and references to sales executive, account manager, and account representatives. |
| **Employee**    | [/domain/staffing/entities/employee.md](/domain/staffing/entities/employee.md)               | Internal staff member (supply side). Name, email, job title, department, and active status.                                   |
| **Opportunity** | [/domain/staffing/entities/opportunity.md](/domain/staffing/entities/opportunity.md)         | Open demand item linked to a client. Title, role needed, quantity, start date, and status enum.                               |

## Success Criteria _(mandatory)_

### Measurable Outcomes

- **SC-001**: All five entity types (users, roles, clients, employees, opportunities) can be
  created, read, updated, and deactivated/closed by an authorised user.
- **SC-002**: System metadata (created_by, created_at, updated_by, updated_at) is automatically
  populated on every write without manual input.
- **SC-003**: A Super Admin can perform any operation on any entity; an Account Manager is
  blocked from user and role management with a clear access-denied response.
- **SC-004**: Attempting to create a user or employee with a duplicate email produces a clear
  error message, not a silent failure.
- **SC-005**: All records remain consistent and queryable after concurrent create and update
  operations by multiple users.

## Assumptions

- All five entities are backed by persistent storage with row-level access control enabled
  (enforced at the database layer, not only in application code).
- `created_by` and `updated_by` are always the id of the currently authenticated user; the
  system injects this automatically — users never set it manually.
- The system is single-tenant for this phase; multi-tenancy is out of scope.
- User authentication (login/logout/session management) is handled by the existing auth
  infrastructure; this spec covers only the data model and access rules.
- `sales_executive_id` on clients is nullable — not every client has an assigned sales executive
  at creation time.
- Employee email and user email are independent fields; an employee may or may not have a
  corresponding user account in the system.
- Soft delete (is_active / status flags) is preferred over hard delete for users, employees, and
  opportunities to preserve audit history.
- The two initial roles (`super_admin`, `account_manager`) are seeded via migration; no UI for
  creating custom roles is required in this iteration.
- Website link on client records is a free-text URL field; format validation (valid URL) is
  enforced but the system does not follow or verify the link.
