# Technology Stack

| Technology | Purpose | Justification | Restrictions |
|---|---|---|---|
| **Flutter** | Mobile Framework | Required cross-platform tool for the project. | - |
| **Dart** | Programming Language | Core language for Flutter. | - |
| **flutter_bloc** | State Management | Separation of business logic from UI. Predictable state transitions. | Do not use Provider or Riverpod. Stick to BLoC. |
| **get_it** | Dependency Injection | Service locator to provide repositories to BLoCs without context overhead. | - |
| **go_router** | Routing | Declarative routing supporting deep linking and auth guards. | Do not use Navigator 1.0 (push/pop manually) for major screen transitions. |
| **Supabase** | Backend/Database | Provides PostgreSQL, Auth (anonymous/phone/Google), RLS, and Edge Functions easily. | Do not use Firebase (except for FCM) or custom backends. |
| **FCM (Firebase Cloud Messaging)** | Push Notifications | Delivers "Kal ka menu" alerts to devices. | Only used for push notifications. |

## Do NOT Use
- Local SQL databases (SQLite, Hive) - everything lives in Supabase.
- Complex animation libraries - use standard implicit animations if needed.
