# Dish Detail Screen

## Screen ID
S4

## Purpose
Shows the profile view of a single dish, including its stats, ingredients, and planner notes.

## User Flow
- User opens the detail screen to read about the dish they are going to eat or cook.

## Entry Points
- S2 Week View (tapping a filled day card)
- S5 Dishes Manager (tapping a dish card)

## Exit Points
- S2 Week View or S5 Dishes Manager (via back button)

## Prototype
`s4_dish_detail/index.html`

## Layout Structure
- **Header**: Back button, Dish Category, Dish Name.
- **Stats Row**: Last Cooked, Times Cooked.
- **Ingredients Section**: Text paragraph.
- **Notes Section**: Text paragraph.

## Components
- Stat Cards (Metrics)
- Information Blocks (Title + Text)

## Visual Requirements
- Clean, readable typography.
- Ingredients are displayed as simple informational text (not a checklist).

## Interactions
- Tap back button to return.

## Functional Behavior
- Displays static data fetched from the `dishes` table.
- Does not have edit functionality directly on this screen.

## Navigation
- Back to previous screen.

## Data Requirements
- `dishes` (name, category_id, ingredients_text, notes, last_cooked_on, times_cooked)

## API Requirements
- Read single `dish` from Supabase (or passed via state routing).

## State Requirements
- Loading (if fetching directly)
- Success (displaying details)
- Error (if dish not found)

## Validation
- N/A

## Permissions
- Accessible to both Planners and Members.

## Edge Cases
- Dish has no ingredients or notes (should hide the section or display "None provided").

## Acceptance Criteria
- All dish details are displayed accurately.
- Missing optional fields do not break the layout.
