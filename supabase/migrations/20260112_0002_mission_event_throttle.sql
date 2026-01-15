-- Mission impression/click throttling (15-minute threshold)
-- Adds RPC functions that insert only if no record exists in the last N minutes.

create index if not exists idx_mission_impression_lookup
on public.mission_impression (mission, "user", created_at desc);

create index if not exists idx_mission_click_lookup
on public.mission_click (mission, "user", created_at desc);

create or replace function public.log_mission_impression(
  p_mission uuid,
  p_threshold_minutes int default 15
)
returns boolean
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid := auth.uid();
  v_now timestamptz := now();
begin
  if p_mission is null then
    raise exception 'Mission is required';
  end if;

  if v_user_id is null then
    raise exception 'Not authenticated';
  end if;

  perform 1
  from mission_impression mi
  where mi.mission = p_mission
    and mi."user" = v_user_id
    and mi.created_at >= (v_now - make_interval(mins => p_threshold_minutes))
  limit 1;

  if found then
    return false;
  end if;

  insert into mission_impression (mission, "user")
  values (p_mission, v_user_id);

  return true;
end;
$$;

revoke all on function public.log_mission_impression(uuid, int) from public;
grant execute on function public.log_mission_impression(uuid, int) to authenticated;

create or replace function public.log_mission_click(
  p_mission uuid,
  p_threshold_minutes int default 15
)
returns boolean
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid := auth.uid();
  v_now timestamptz := now();
begin
  if p_mission is null then
    raise exception 'Mission is required';
  end if;

  if v_user_id is null then
    raise exception 'Not authenticated';
  end if;

  perform 1
  from mission_click mc
  where mc.mission = p_mission
    and mc."user" = v_user_id
    and mc.created_at >= (v_now - make_interval(mins => p_threshold_minutes))
  limit 1;

  if found then
    return false;
  end if;

  insert into mission_click (mission, "user")
  values (p_mission, v_user_id);

  return true;
end;
$$;

revoke all on function public.log_mission_click(uuid, int) from public;
grant execute on function public.log_mission_click(uuid, int) to authenticated;
