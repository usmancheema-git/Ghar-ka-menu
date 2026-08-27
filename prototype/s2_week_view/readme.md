# Week View (Home Screen)

## Screen ID
S2

## Purpose
The primary landing screen of the app. It displays a rolling 7-day view (today and the next 6 days) representing the lunch menu planner.

## User Flow
- Users view the upcoming 7 days to see what's planned.
- Planners tap on an empty day to assign a dish.
- Planners use the ellipsis menu to change a day's status.
- Members tap a day to view dish details.

## Entry Points
- App Start (Authenticated)
- Bottom Navigation (Tab 1)
- Return from S3 (Assign Dish) or S4 (Dish Detail)

## Exit Points
- S3 Assign Dish (via empty day or edit)
- S4 Dish Detail (via tapping a card)

## Prototype
`s2_week_view/index.html`

## Layout Structure
- **Header**: Household Name, current view mode, and active role badge.
- **7-Day Plan List**: Vertical list of 7 cards.
- **Bottom Navigation**: Persistent tab bar.

## Components
- Header Profile
- Role Badge
- Day Card (Date, Status Pill, Dish Info)
- Add Button (Planner only)
- Ellipsis Dropdown Menu (Planner only)

## Visual Requirements
- "Today" card should be visually highlighted (e.g., border color or badge).
- Status pills must have distinct colors (Planned = Blue, Cooked = Green, Cancelled = Red).

## Interactions
- **Planner**: Taps empty day (+) -> navigates to S3.
- **Planner**: Taps ellipsis -> opens context menu (Mark Cooked, Mark Cancelled).
- **All**: Taps a filled Day Card -> navigates to S4.

## Functional Behavior
- Generates exactly 7 date cards starting from Today.
- Merges generated dates with existing `day_plans` from the database.

## Navigation
- To S3 (Assign Dish)
- To S4 (Dish Detail)

## Data Requirements
- `day_plans` (date, dish_id, status) for the household.
- `dishes` (name, category_id) joined with `day_plans`.

## API Requirements
- Read `day_plans` and `dishes` via Supabase.
- Update `day_plans` status via Supabase (if Planner changes status).

## State Requirements
- Loading (fetching plans)
- Success (displaying 7 cards)
- Empty Day (no dish assigned yet)

## Validation
- N/A

## Permissions
- **Planner Mode**: Full edit permissions (Add, Change Status).
- **Member Mode**: Read-only access (tapping opens details).

## Edge Cases
- Network failure while fetching plans.
- Data drift (if day changes while app is open, dates should refresh).

## Acceptance Criteria
- Displays exactly 7 days starting from today.
- Planners see the '+' button on empty days.
- Members cannot see the '+' button or ellipsis menu.
