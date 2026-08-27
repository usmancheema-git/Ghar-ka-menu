# API & External Services

This project does not use a traditional REST API. It uses **Supabase** via the Flutter SDK.

## Supabase Implementation
- **Base connection**: Configured via Supabase URL and Anon Key.
- **Authentication**: Supports Google Sign-In and anonymous auth (or custom token based on the onboarding flow).
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

## Open Questions / Decisions Required
- Is the Push Alert job going to be a Supabase Cron (`pg_cron`) triggering an Edge Function? (Likely yes, needs final setup definition).
- Does the S1 Onboarding Google Sign-In replace Anonymous auth? (Needs confirmation on auth setup in Supabase dashboard).
