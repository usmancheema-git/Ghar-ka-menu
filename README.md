# Ghar ka Menu

Ghar ka Menu is a shared family lunch planner for joint households. It answers the everyday question, *"Aaj lunch mein kya pakega?"* by giving everyone one clear, seven-day lunch schedule instead of relying on scattered WhatsApp messages.

The app lets a household planner manage dishes, assign one lunch dish to each day, and keep a record of what was cooked. Recommendations are sorted by how long it has been since a dish was last cooked, helping families maintain variety without adding unnecessary complexity.

## What It Does

- Create a household or join one with a six-digit code.
- Show today's lunch and the next six days in a rolling week view.
- Manage dish categories and dishes.
- Assign one dish to each lunch day.
- Highlight dishes that have not been cooked recently or have never been cooked.
- Warn when a dish was already cooked during the current week.
- Track cooked dishes and maintain a 30-day history.
- Send a day-before lunch reminder to household members when notifications are connected.

## Users

- **Planner:** manages categories and dishes, plans the week, and can mark meals as cooked or cancelled.
- **Member:** views the household menu and receives menu notifications.

## Current Status

The v1 specification and HTML/CSS screen prototypes are complete. The Flutter implementation currently includes:

- S1 Onboarding
- S2 Week View
- S3 Assign Dish
- S4 Dish Detail
- S5 Dishes Manager
- S6 Add/Edit Dish

These screens currently run with an in-memory mock store while Supabase integration is being completed. S7 History and S8 Settings are still planned.

## Technology

- Flutter and Dart
- `flutter_bloc` for state management
- `go_router` for navigation
- `get_it` for dependency injection
- Supabase for PostgreSQL, authentication, row-level security, and edge functions
- Firebase Cloud Messaging for push notifications

## Project Structure

```text
.
├── app/       Flutter application
├── docs/      Product, architecture, data, API, and UI documentation
└── prototype/ HTML/CSS references for the eight planned screens
```

The Flutter source is in [`app/lib`](app/lib). The main project documentation is in [`docs/PROJECT_CONTEXT.md`](docs/PROJECT_CONTEXT.md), and the original product brief is in [`GHAR_KA_MENU_PROJECT_CONTEXT.md`](GHAR_KA_MENU_PROJECT_CONTEXT.md).

## Run Locally

Prerequisites:

- Flutter SDK with Dart 3.12.2 or newer
- An available Flutter device, emulator, or desktop target

From the repository root:

```bash
cd app
flutter pub get
flutter run
```

Useful checks:

```bash
cd app
flutter analyze
flutter test
```

The current implementation uses mock data, so a Supabase project and credentials are not required to explore the implemented screens.

## Scope

The v1 scope is intentionally small: lunch planning for one household. Breakfast and dinner planning, multiple dishes per day, grocery checklists, recipes, voting, AI suggestions, and multiple households per user are out of scope.

## Documentation

- [`AGENT.md`](AGENT.md): project rules and implementation conventions
- [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md): application layers and boundaries
- [`docs/BUSINESS_RULES.md`](docs/BUSINESS_RULES.md): planning and recommendation logic
- [`docs/DATA_MODEL.md`](docs/DATA_MODEL.md): Supabase tables and relationships
- [`docs/NAVIGATION.md`](docs/NAVIGATION.md): screen routes and flows
- [`docs/UI_SYSTEM.md`](docs/UI_SYSTEM.md): visual design tokens and UI rules
- [`prototype/`](prototype/): screen prototypes

## License

This is a private personal project and is not currently published as an open-source package.
