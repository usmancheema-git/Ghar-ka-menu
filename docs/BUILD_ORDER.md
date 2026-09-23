# Build Order

The implementation should follow this strict sequence based on dependencies:

## Phase 1: Project Foundation & Supabase
- Initialize Flutter project with dependencies (`flutter_bloc`, `go_router`, `supabase_flutter`, `get_it`).
- Create Supabase project.
- Define SQL schema (`households`, `members`, `categories`, `dishes`, `day_plans`).
- Implement RLS policies.
- Create seed data pack for categories and common dishes.

## Phase 2: Core Infrastructure & Auth
- Implement generic Repositories for Supabase access.
- Build **S1 Onboarding**.
- Implement Household creation / Join via code logic (with Supabase Email Auth mapping).
- Save user session and route to Home.

## Phase 3: Core App (Read-Only)
- Build **S2 Week View**.
- Implement fetching `day_plans` for the rolling 7 days.
- Build **S4 Dish Detail** screen.
- Implement Bottom Navigation.

## Phase 4: Planner Features (Write)
- Build **S3 Assign Dish**.
- Implement recommendation sorting logic (Days since last cooked).
- Build **S5 Dishes Manager**.
- Build **S6 Add/Edit Dish** form.

## Phase 5: Rollover & History
- Build **S7 History** screen.
- Implement Edge Function / cron for auto-cooked rollover at midnight.
- Implement manual status toggles in Week View.

## Phase 6: Polish & Alerts
- Build **S8 Settings**.
- Configure FCM and setup Edge Function for daily push alerts based on `alert_time`.
- UI polish and consistency check against prototypes.
