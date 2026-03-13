-- Legal guardian info for members under 14 years of age.
-- Populated at the end of the minor signup sub-flow.

create table if not exists public.user_guardian (
  id          uuid        primary key default gen_random_uuid(),
  user_id     uuid        not null references auth.users(id) on delete cascade,
  name        text        not null,
  birthdate   text,
  gender      char(1),
  phone       text,
  created_at  timestamptz not null default now()
);

create index if not exists idx_user_guardian_user_id
  on public.user_guardian (user_id);

comment on table public.user_guardian
  is 'Legal guardian info for members under 14 years of age.';
