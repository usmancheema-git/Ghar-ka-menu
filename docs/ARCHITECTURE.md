# Architecture

## 1. Architectural Style
The application uses a **Feature-First / Layered Architecture** adapted for a small-scale Flutter project. Given the weekend-sized scope, it emphasizes simplicity while maintaining a clear separation of concerns using `flutter_bloc`.

## 2. Layers
- **Presentation**: Flutter UI Widgets and Screens. Handles layout, routing, and user interaction. Should be entirely dumb.
- **Application**: BLoCs/Cubits. Handles state transitions and orchestrates calls to repositories based on user actions.
- **Domain/Data**: Repositories. Interfaces and implementations for data access. Manages the business logic for creating, fetching, and manipulating data.
- **Infrastructure**: Supabase Client. Network calls, database queries, and raw data mapping.

*Visual Flow:*
```text
UI (Widgets)
  ↓ triggers events / listens to state
BLoC (State Management)
  ↓ calls
Repository (Domain/Data)
  ↓ queries
Supabase (Infrastructure)
```

## 3. Dependency Rules
- **UI** depends only on **Application (BLoC)**.
- **Application (BLoC)** depends on **Domain/Data (Repositories)**.
- **Domain/Data (Repositories)** depend on **Infrastructure (Supabase/Models)**.
- **Infrastructure** depends on the external Supabase SDK.
- Use `get_it` for Dependency Injection to provide Repositories to BLoCs.

## 4. Forbidden Architecture Patterns
- **Direct DB calls in UI**: Never import Supabase directly into a Widget.
- **Logic in UI**: Do not write data formatting or sorting logic inside the `build` method.
- **Over-engineering**: Do not create complex Use Cases or clean-architecture interactors for this small project. BLoC -> Repository is sufficient.

## 5. Folder Structure
```text
lib/
  ├── core/
  │   ├── constants/
  │   ├── theme/
  │   └── utils/
  ├── config/
  │   ├── router.dart
  │   └── di.dart
  ├── data/
  │   ├── models/
  │   └── repositories/
  ├── presentation/
  │   ├── bloc/
  │   ├── screens/
  │   └── widgets/
  └── main.dart
```
