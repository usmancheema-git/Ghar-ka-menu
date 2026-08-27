# AGENT.md — Ghar ka Menu

## 1. Session Rules
- **Read AGENT.md** before working.
- **Do not invent functionality** or UI screens that are not defined in the project specs.
- **Scope is locked**: Do not add breakfast/dinner, side dishes, or ingredient checklists. Keep it small.
- **Do not change established architecture** (Flutter + BLoC + Supabase) without documenting in `DECISIONS.md`.
- **Do not introduce new dependencies** unless strictly required and justified.
- **Follow the documented UI system** (see `docs/UI_SYSTEM.md`). Use existing HTML/CSS prototypes as a visual reference.
- **Follow screen specifications** before modifying screen UI/logic.

## 2. Project Snapshot
- **App Name**: Ghar ka Menu
- **Purpose**: Shared family lunch planner. Allows a single household to view the next 7 days' menu, tracked by a planner. Resolves the daily "Aaj kya pakega?" question.
- **Target Users**: Joint families (Planners and Members).
- **Current State**: v1 specification complete. Implementation in progress — S1 Onboarding, S2 Week View, S3 Assign Dish, S4 Dish Profile, S5 Dishes Manager, and S6 Add/Edit Dish are built (running on an in-memory mock store while Supabase is wired up). S7 History and S8 Settings remain.
- **Major Features**: Household join via code, 7-day rolling lunch planner, auto-cooked tracking, recommendation sorting (days since last cooked).

## 3. Technology Stack
| Layer | Technology | Purpose |
|------|------------|---------|
| Mobile App | Flutter | Cross-platform framework |
| State Mgmt | flutter_bloc | Predictable state container |
| DI | get_it | Service locator for dependency injection |
| Routing | go_router | Declarative routing |
| Backend & DB| Supabase | PostgreSQL, Auth, RLS, Edge functions |
| Push | FCM | Daily push notifications for menu reminders |

## 4. Documentation Map
### Always relevant
- `AGENT.md`: Rules and general guidelines.
- `docs/PROJECT_CONTEXT.md`: High-level summary of the app and constraints.

### Read when working on a specific area
- `docs/ARCHITECTURE.md`: Project structure, layers, and dependency rules.
- `docs/TECH_STACK.md`: Detailed library choices.
- `docs/DATA_MODEL.md`: Supabase schemas and models.
- `docs/API.md`: Supabase config and edge functions.
- `docs/BUSINESS_RULES.md`: Core logic and constraints.

### Design references
- `docs/UI_SYSTEM.md`: Colors, typography, spacing, and styles.
- `docs/NAVIGATION.md`: Routes and navigation flows.

### Deep/reference documentation
- `docs/DECISIONS.md`: ADRs for major architecture changes.
- `docs/BUILD_ORDER.md`: The required sequence of implementation.
- Screen readmes (`s1_onboarding/readme.md`, etc.).

## 5. How to Work on a Feature
1. Review `AGENT.md`.
2. Check `docs/ARCHITECTURE.md` and `docs/BUSINESS_RULES.md`.
3. Check the specific feature's docs (e.g., `docs/DATA_MODEL.md`).
4. Read the relevant screen's `readme.md`.
5. Check the `index.html` and `styles.css` prototype for the visual layout.
6. Implement logic and UI.
7. Verify functionality and UI match prototype.
8. Update documentation if necessary.

## 6. Screen Implementation Rules
Before implementing a screen, the agent MUST inspect:
- The screen's `readme.md` specification.
- The corresponding `index.html` / `styles.css` prototype.
- `docs/UI_SYSTEM.md` for global styling tokens.
- `docs/NAVIGATION.md` for routing logic.
- `docs/DATA_MODEL.md` for required data.

The agent MUST preserve:
- Layout hierarchy and visual relationships.
- Existing text labels and spacing.
- Specified user interactions and navigation.
- Loading/Empty/Error states where defined.

The agent MUST NOT invent UI, functionality, or extra data fields.

## 7. Before Implementation Checklist
- [ ] Relevant feature documentation reviewed
- [ ] Screen README reviewed
- [ ] Prototype inspected (`index.html` & `styles.css`)
- [ ] Navigation flows understood
- [ ] Data / Supabase requirements understood
- [ ] Reusable components identified
- [ ] UI states (loading, error, empty) defined
- [ ] No unnecessary dependencies introduced

## 8. Documentation Update Rules
| Change | Documentation to Update |
|---|---|
| New screen | `docs/NAVIGATION.md`, create screen README |
| Database change | `docs/DATA_MODEL.md` |
| UI token/style change | `docs/UI_SYSTEM.md` |
| Architecture change | `docs/ARCHITECTURE.md`, `docs/DECISIONS.md` |
| New business rule | `docs/BUSINESS_RULES.md` |

## 9. Coding Conventions
- **Files**: `snake_case` for files (`assign_dish_screen.dart`).
- **Classes**: `PascalCase` (`AssignDishScreen`).
- **Widgets**: Extract reusable widgets into separate files if used across screens.
- **State Management**: Use `flutter_bloc` with events and states explicitly defined.
- **Architecture Layers**: Separate UI (`presentation`), BLoC (`application`), Repositories (`domain`), and Supabase interaction (`infrastructure`).

## 10. Forbidden Patterns
- DO NOT put business logic inside UI widgets (use BLoC).
- DO NOT make direct Supabase calls from UI widgets (use Repositories).
- DO NOT bypass the DI container (`get_it`).
- DO NOT use generic state management (like `setState` for complex global data).
- DO NOT invent out-of-scope features (e.g., breakfast, multi-household).

## 11. Definition of Done
- Functionality is implemented as per docs.
- UI visually matches the provided HTML/CSS prototype.
- State transitions (loading, error, success) work.
- Navigation logic is correct.
- No breaking changes in unrelated features.
- Documentation updated (if applicable).
