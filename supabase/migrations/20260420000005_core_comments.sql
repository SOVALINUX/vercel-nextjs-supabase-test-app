create type public.comment_visibility as enum ('public', 'restricted');

create table public.comments (
  id          uuid                     primary key default gen_random_uuid(),
  body        text                     not null,
  author_id   uuid                     not null references public.users (id),
  entity_type text                     not null,
  entity_id   uuid                     not null,
  visibility  public.comment_visibility not null default 'public',
  -- base entity audit fields
  _created_at timestamptz              not null default now(),
  _created_by uuid                     not null references auth.users (id),
  _updated_at timestamptz,
  _updated_by uuid                     references auth.users (id),
  _deleted    boolean                  not null default false,
  constraint comments_body_not_empty check (trim(body) <> '')
);

-- Index for efficient lookup of all comments on a given entity.
create index comments_entity_idx on public.comments (entity_type, entity_id)
  where _deleted = false;

alter table public.comments enable row level security;

-- Public comments: visible to all authenticated users.
-- Restricted comments: visible only to the author.
-- Super-admin visibility for restricted comments is enforced at the application layer
-- (RLS cannot query user_roles without a stable function; keep RLS simple).
create policy "comments: select public or own"
  on public.comments for select
  to authenticated
  using (
    _deleted = false
    and (
      visibility = 'public'
      or author_id = auth.uid()
    )
  );

create policy "comments: author can insert"
  on public.comments for insert
  to authenticated
  with check (author_id = auth.uid() and _created_by = auth.uid());

-- Comments are immutable after creation (v1); no update policy.

-- Soft-delete only, by author.
create policy "comments: author can soft-delete"
  on public.comments for update
  to authenticated
  using (author_id = auth.uid())
  with check (_deleted = true);

create policy "comments: no hard delete"
  on public.comments for delete
  using (false);
