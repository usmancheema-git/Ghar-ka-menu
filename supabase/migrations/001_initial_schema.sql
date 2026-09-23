create extension if not exists pgcrypto;

do $$
begin
  create type public.member_role as enum ('planner', 'member');
exception
  when duplicate_object then null;
end $$;

do $$
begin
  create type public.day_plan_status as enum ('planned', 'cooked', 'cancelled');
exception
  when duplicate_object then null;
end $$;

create table if not exists public.households (
  id uuid primary key default gen_random_uuid(),
  name text not null check (length(trim(name)) > 0),
  join_code text not null unique check (join_code ~ '^[0-9]{6}$'),
  alert_time time not null default '20:00',
  created_at timestamptz not null default now()
);

create table if not exists public.members (
  id uuid primary key references auth.users(id) on delete cascade,
  household_id uuid not null references public.households(id) on delete cascade,
  name text not null check (length(trim(name)) > 0),
  role public.member_role not null default 'member',
  fcm_token text,
  created_at timestamptz not null default now()
);

create table if not exists public.categories (
  id uuid primary key default gen_random_uuid(),
  household_id uuid not null references public.households(id) on delete cascade,
  name text not null check (length(trim(name)) > 0),
  sort_order integer not null default 0,
  unique (household_id, name)
);

create table if not exists public.dishes (
  id uuid primary key default gen_random_uuid(),
  household_id uuid not null references public.households(id) on delete cascade,
  category_id uuid not null references public.categories(id) on delete restrict,
  name text not null check (length(trim(name)) > 0),
  ingredients_text text,
  notes text,
  last_cooked_on date,
  times_cooked integer not null default 0 check (times_cooked >= 0)
);

create table if not exists public.day_plans (
  id uuid primary key default gen_random_uuid(),
  household_id uuid not null references public.households(id) on delete cascade,
  date date not null,
  dish_id uuid references public.dishes(id) on delete set null,
  status public.day_plan_status not null default 'planned',
  unique (household_id, date)
);

create index if not exists members_household_id_idx on public.members(household_id);
create index if not exists categories_household_id_idx on public.categories(household_id);
create index if not exists dishes_household_id_idx on public.dishes(household_id);
create index if not exists day_plans_household_date_idx on public.day_plans(household_id, date);

create or replace function public.is_household_member(target_household uuid)
returns boolean
language sql
security definer
set search_path = public
stable
as $$
  select exists (
    select 1 from public.members
    where id = auth.uid() and household_id = target_household
  );
$$;

create or replace function public.is_household_planner(target_household uuid)
returns boolean
language sql
security definer
set search_path = public
stable
as $$
  select exists (
    select 1 from public.members
    where id = auth.uid()
      and household_id = target_household
      and role = 'planner'
  );
$$;

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
begin
  if auth.uid() is null then
    raise exception 'Authentication required';
  end if;

  insert into public.households(name, join_code)
  values (trim(p_name), trim(p_join_code))
  returning * into created_household;

  insert into public.members(id, household_id, name, role)
  values (auth.uid(), created_household.id, trim(p_user_name), 'planner');

  return query
  select created_household.id, created_household.name,
         created_household.join_code, 'planner'::public.member_role;
end;
$$;

create or replace function public.join_household(
  p_join_code text,
  p_user_name text
)
returns table (id uuid, name text, join_code text, role public.member_role)
language plpgsql
security definer
set search_path = public
as $$
declare
  target_household public.households;
begin
  if auth.uid() is null then
    raise exception 'Authentication required';
  end if;

  select * into target_household
  from public.households
  where join_code = trim(p_join_code);

  if target_household.id is null then
    raise exception 'That join code does not match a household';
  end if;

  insert into public.members(id, household_id, name, role)
  values (auth.uid(), target_household.id, trim(p_user_name), 'member')
  on conflict (id) do update
  set household_id = excluded.household_id,
      name = excluded.name,
      role = 'member';

  return query
  select target_household.id, target_household.name,
         target_household.join_code, 'member'::public.member_role;
end;
$$;

revoke all on function public.create_household(text, text, text) from public;
revoke all on function public.join_household(text, text) from public;
grant execute on function public.create_household(text, text, text) to authenticated;
grant execute on function public.join_household(text, text) to authenticated;

alter table public.households enable row level security;
alter table public.members enable row level security;
alter table public.categories enable row level security;
alter table public.dishes enable row level security;
alter table public.day_plans enable row level security;

drop policy if exists households_select_member on public.households;
create policy households_select_member on public.households
for select using (public.is_household_member(id));

drop policy if exists households_update_planner on public.households;
create policy households_update_planner on public.households
for update using (public.is_household_planner(id))
with check (public.is_household_planner(id));

drop policy if exists members_select_household on public.members;
create policy members_select_household on public.members
for select using (public.is_household_member(household_id));

drop policy if exists members_update_self on public.members;
create policy members_update_self on public.members
for update using (id = auth.uid())
with check (id = auth.uid());

drop policy if exists categories_select_member on public.categories;
create policy categories_select_member on public.categories
for select using (public.is_household_member(household_id));

drop policy if exists categories_write_planner on public.categories;
create policy categories_write_planner on public.categories
for all using (public.is_household_planner(household_id))
with check (public.is_household_planner(household_id));

drop policy if exists dishes_select_member on public.dishes;
create policy dishes_select_member on public.dishes
for select using (public.is_household_member(household_id));

drop policy if exists dishes_write_planner on public.dishes;
create policy dishes_write_planner on public.dishes
for all using (public.is_household_planner(household_id))
with check (public.is_household_planner(household_id));

drop policy if exists day_plans_select_member on public.day_plans;
create policy day_plans_select_member on public.day_plans
for select using (public.is_household_member(household_id));

drop policy if exists day_plans_write_planner on public.day_plans;
create policy day_plans_write_planner on public.day_plans
for all using (public.is_household_planner(household_id))
with check (public.is_household_planner(household_id));

create or replace function public.rollover_yesterday_plans()
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
  changed_count integer := 0;
  plan_row record;
begin
  for plan_row in
    select id, dish_id
    from public.day_plans
    where date = current_date - 1
      and status = 'planned'
      and dish_id is not null
  loop
    update public.day_plans
    set status = 'cooked'
    where id = plan_row.id;

    update public.dishes
    set last_cooked_on = current_date - 1,
        times_cooked = times_cooked + 1
    where id = plan_row.dish_id;

    changed_count := changed_count + 1;
  end loop;

  return changed_count;
end;
$$;

revoke all on function public.rollover_yesterday_plans() from public;
grant execute on function public.rollover_yesterday_plans() to service_role;

alter publication supabase_realtime add table public.households;
alter publication supabase_realtime add table public.members;
alter publication supabase_realtime add table public.categories;
alter publication supabase_realtime add table public.dishes;
alter publication supabase_realtime add table public.day_plans;

-- Enable pg_cron in the Supabase dashboard and schedule this function daily:
-- select cron.schedule('ghar-ka-menu-rollover', '5 0 * * *', $$select public.rollover_yesterday_plans();$$);
