# Architecture Decisions (ADRs)

## ADR-001 — Database Choice
### Context
Need a fast, relational database that syncs seamlessly with mobile clients and supports backend functions for push alerts.
### Decision
Use Supabase (PostgreSQL).
### Reason
Offers built-in RLS (Row Level Security), Auth, and Edge Functions. Perfectly sized for a weekend project while offering robust relational data modeling (households, dishes, plans).
### Alternatives Considered
Firebase Firestore, but the relational requirements (categories -> dishes -> plans) make PostgreSQL a much better fit for sorting and data integrity.
### Consequences
Development must use SQL/PostgREST instead of NoSQL document fetching.

## ADR-002 — State Management
### Context
Need a scalable way to handle state in Flutter without over-engineering.
### Decision
Use `flutter_bloc` with `get_it`.
### Reason
Standard practice for production apps. Keeps UI completely separated from business logic.
### Alternatives Considered
Provider, Riverpod, GetX. Riverpod was considered, but BLoC offers explicit event-to-state mapping which aligns well with the strict business flows in this app.
### Consequences
Requires more boilerplate, but ensures high predictability for state changes (e.g., loading, loaded, error states).

## ADR-003 — Auto-Cooked Rollover
### Context
How do we know a dish was actually cooked so we can update the history/recommendations?
### Decision
System automatically marks yesterday's planned dish as 'Cooked' at midnight, updating the dish's `last_cooked_on` date, unless the planner manually cancelled it.
### Reason
Reduces friction. Family doesn't have to manually check off a "we ate this" button every day.
### Alternatives Considered
Manual check-off button only. However, users forget and the recommendation engine breaks.
### Consequences
Requires a cron job (Edge Function) on Supabase.

## Open Decisions
- Exact mechanism for triggering push notifications based on per-household timezones.
- Email confirmation policy for development versus production.
