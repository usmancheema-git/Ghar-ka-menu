-- Production hardening for households created with 001_initial_schema.sql.

create or replace function public.create_household(
  p_name text,
  p_user_name text,
  p_join_code text
)
returns table (id uuid, name text, join_code text, role public.member_role)
language plpgsql
security definer
set search_path = public
as $$
declare
  created_household public.households;
  category_name text;
begin
  if auth.uid() is null then
    raise exception 'Authentication required';
  end if;

  insert into public.households(name, join_code)
  values (trim(p_name), trim(p_join_code))
  returning * into created_household;

  insert into public.members(id, household_id, name, role)
  values (auth.uid(), created_household.id, trim(p_user_name), 'planner');

  foreach category_name in array array['Sabzi', 'Daal', 'Chawal', 'Gosht', 'Murgh', 'Special']
  loop
    insert into public.categories(household_id, name, sort_order)
    values (created_household.id, category_name, array_position(
      array['Sabzi', 'Daal', 'Chawal', 'Gosht', 'Murgh', 'Special'],
      category_name
    ));
  end loop;

  return query
  select created_household.id, created_household.name,
         created_household.join_code, 'planner'::public.member_role;
end;
$$;

create or replace function public.update_member_role(
  p_household_id uuid,
  p_member_id uuid,
  p_role public.member_role
)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.is_household_planner(p_household_id) then
    raise exception 'Only household planners can change roles';
  end if;

  update public.members
  set role = p_role
  where id = p_member_id and household_id = p_household_id;

  if not found then
    raise exception 'Member not found';
  end if;
end;
$$;

revoke all on function public.update_member_role(uuid, uuid, public.member_role) from public;
grant execute on function public.update_member_role(uuid, uuid, public.member_role) to authenticated;

drop policy if exists members_update_self on public.members;

-- Alert jobs run each minute in UTC and only send to households whose configured
-- alert_time matches the current UTC minute.
