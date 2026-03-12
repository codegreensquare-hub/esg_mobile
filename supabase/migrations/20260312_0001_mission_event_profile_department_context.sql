-- Add active profile and department context to throttled mission events.

drop function if exists public.log_mission_impression(uuid, int);

create or replace function public.log_mission_impression(
  p_mission uuid,
  p_profile_used uuid default null,
  p_department uuid default null,
  p_sub_department uuid default null,
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
    and mi.profile_used is not distinct from p_profile_used
    and mi.department is not distinct from p_department
    and mi.sub_department is not distinct from p_sub_department
    and mi.created_at >= (v_now - make_interval(mins => p_threshold_minutes))
  limit 1;

  if found then
    return false;
  end if;

  insert into mission_impression (
    mission,
    "user",
    profile_used,
    department,
    sub_department
  )
  values (
    p_mission,
    v_user_id,
    p_profile_used,
    p_department,
    p_sub_department
  );

  return true;
end;
$$;

revoke all on function public.log_mission_impression(uuid, uuid, uuid, uuid, int) from public;
grant execute on function public.log_mission_impression(uuid, uuid, uuid, uuid, int) to authenticated;

drop function if exists public.log_mission_click(uuid, int);

create or replace function public.log_mission_click(
  p_mission uuid,
  p_profile_used uuid default null,
  p_department uuid default null,
  p_sub_department uuid default null,
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
    and mc.profile_used is not distinct from p_profile_used
    and mc.department is not distinct from p_department
    and mc.sub_department is not distinct from p_sub_department
    and mc.created_at >= (v_now - make_interval(mins => p_threshold_minutes))
  limit 1;

  if found then
    return false;
  end if;

  insert into mission_click (
    mission,
    "user",
    profile_used,
    department,
    sub_department
  )
  values (
    p_mission,
    v_user_id,
    p_profile_used,
    p_department,
    p_sub_department
  );

  return true;
end;
$$;

revoke all on function public.log_mission_click(uuid, uuid, uuid, uuid, int) from public;
grant execute on function public.log_mission_click(uuid, uuid, uuid, uuid, int) to authenticated;