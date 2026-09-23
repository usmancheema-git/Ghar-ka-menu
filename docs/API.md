# API & External Services

This project does not use a traditional REST API. It uses **Supabase** via the Flutter SDK.

## Supabase Implementation
- **Base connection**: Configured via Supabase URL and Anon Key.
- **Authentication**: Uses Supabase email/password authentication. Users can create an account or sign in, then create or join a household.
- **Data Access**: Direct PostgREST queries using the `supabase_flutter` package.

## Edge Functions & Scheduled Jobs
- **Daily Roll-over Job**:
  - Automatically runs at midnight.
  - Queries `day_plans` where `date = yesterday` and `status = 'planned'`.
  - Updates status to `cooked`.
  - Updates `last_cooked_on` and increments `times_cooked` on the respective `dishes`.
- **FCM Push Alerts Job**:
  - Runs periodically (or triggered based on household `alert_time`).
  - Fetches tomorrow's `day_plans` for each household.
  - Sends push notifications to `fcm_token` of members via Firebase Cloud Messaging.
  - If no dish is planned, sends a reminder alert to the planner.

## Deployment
- Apply `supabase/migrations/001_initial_schema.sql`, then `supabase/migrations/002_production_hardening.sql` to create tables, RLS policies, onboarding RPCs, realtime publication, rollover, default categories, and planner-only role updates.
- Deploy `supabase/functions/send-menu-alerts/index.ts` as the `send-menu-alerts` Edge Function.
- Configure `SUPABASE_SERVICE_ROLE_KEY` and `FCM_SERVER_KEY` as function secrets.
- Enable the Email provider in Supabase Auth. Configure email confirmation according to the desired development/production policy.
- Schedule the rollover function daily with `pg_cron`, and invoke `send-menu-alerts` at the household notification cadence.
- Schedule `send-menu-alerts` every minute with `pg_cron`; it sends only to households whose `alert_time` matches the current UTC minute.
- Add Firebase Messaging to the mobile targets and call `HouseholdRepository.updateCurrentMemberToken` after permission/token refresh.
