# Assign Dish Screen

## Screen ID
S3

## Purpose
Allows the Planner to select a dish from the household's presets to schedule for a specific day.

## User Flow
- Planner views the list of available dishes.
- Planner can filter by category or search by text.
- Planner selects a dish, which assigns it to the previously selected day.

## Entry Points
- S2 Week View (via tapping '+' on an empty day or edit option)

## Exit Points
- S2 Week View (after assigning a dish or pressing back)

## Prototype
`s3_assign_dish/index.html`

## Layout Structure
- **Header**: Back button, Date being planned.
- **Category Tabs**: Horizontal scrollable category list.
- **Search Bar**: Text input for real-time search.
- **Recommendation List**: Vertical list of dish cards.

## Components
- Category Tabs (Pills)
- Search Input
- Assign Dish Card (Dish Name, Category, Days Since Cooked Badge, Repeat Warning Badge)

## Visual Requirements
- Follow prototype for badge styling.
- Repeat warning tag must be visually distinct (e.g., Amber/Yellow).

## Interactions
- Tapping a category tab filters the list.
- Typing in the search bar filters the list.
- Tapping a dish card assigns the dish and returns to S2.

## Functional Behavior
- Dishes are sorted by **Days Since Cooked (Descending)**.
- Dishes never cooked are placed at the top.
- If a dish is already in the `day_plans` for the current 7-day rolling window, a "Repeat Warning" is shown.
- Tapping a dish performs a database insert/update on `day_plans` for the selected date.

## Navigation
- Back to S2 Week View.

## Data Requirements
- `dishes` (all dishes for the household).
- `categories` (to populate tabs).
- `day_plans` (to check for repeat warnings).

## API Requirements
- Read `dishes` and `categories`.
- Upsert `day_plans` with the selected `dish_id` and `date`.

## State Requirements
- Loading (fetching dishes)
- Empty List (no dishes match search/filter)
- Success (displaying dishes)

## Validation
- N/A

## Permissions
- **Planner Only**.

## Edge Cases
- Planner searches for a dish that doesn't exist (show empty state).
- No dishes in the database yet (should prompt to add dishes, or show seed data).

## Acceptance Criteria
- Dishes are correctly sorted by `last_cooked_on`.
- Repeat warning is shown for dishes already planned in the week.
- Assigning a dish updates the week view correctly.
