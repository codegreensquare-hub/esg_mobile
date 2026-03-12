-- Comment blocked: user blocks a story comment (hide from me; can unblock).
-- Comment reported: user reports a story comment (flag for moderation).
-- No reason/status on comment_reported for now.

-- comment_blocked: who blocked which comment
create table if not exists public.comment_blocked (
  id uuid primary key default gen_random_uuid(),
  blocker uuid not null references auth.users(id) on delete cascade,
  comment uuid not null references public.story_comment(id) on delete cascade,
  created_at timestamptz not null default now(),
  unique (blocker, comment)
);

create index if not exists idx_comment_blocked_blocker
  on public.comment_blocked (blocker);
create index if not exists idx_comment_blocked_comment
  on public.comment_blocked (comment);

comment on table public.comment_blocked is 'Story comments blocked by a user (can be unblocked).';

-- comment_reported: who reported which comment
create table if not exists public.comment_reported (
  id uuid primary key default gen_random_uuid(),
  reporter uuid not null references auth.users(id) on delete cascade,
  comment_reported uuid not null references public.story_comment(id) on delete cascade,
  created_at timestamptz not null default now(),
  unique (reporter, comment_reported)
);

create index if not exists idx_comment_reported_reporter
  on public.comment_reported (reporter);
create index if not exists idx_comment_reported_comment
  on public.comment_reported (comment_reported);

comment on table public.comment_reported is 'Story comments reported by a user for moderation.';
