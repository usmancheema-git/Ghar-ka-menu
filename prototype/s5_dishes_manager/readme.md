# Dishes Manager Screen

## Screen ID
S5

## Purpose
Provides a dashboard to manage all dish presets. Planners use it for CRUD operations on categories and dishes.

## User Flow
- Users view the library of all available dishes in the household.
- Planners can add new dishes, edit existing ones, or delete them.

## Entry Points
- Bottom Navigation (Tab 3)

## Exit Points
- S4 Dish Detail (tapping a dish)
- S6 Add/Edit Dish (tapping add or edit)

## Prototype
`s5_dishes_manager/index.html`

## Layout Structure
- **Header**: Database size, Add Dish button (Planner only).
- **Category Tabs**: Horizontal scrollable list.
- **Search Bar**: Real-time text search.
- **Dish List**: Vertical list of dishes.

## Components
- Floating Action Button / Add Button
- Category Tabs
- Search Input
- Dish List Item (Dish Name, Category, Times Cooked)
- Action Icons (Edit, Delete)

## Visual Requirements
- Edit/Delete icons should be clearly visible but secondary to the dish name.

## Interactions
- **Planner**: Tapping '+' navigates to S6 (Add).
- **Planner**: Tapping 'Edit' navigates to S6 (Edit with data).
- **Planner**: Tapping 'Delete' prompts for confirmation and deletes the dish.
- **All**: Tapping the card body navigates to S4.

## Functional Behavior
- Displays all dishes in the database.
- Filtering and searching happens locally or via DB queries.
- Deletion removes the dish from the `dishes` table (and cascades/nullifies related `day_plans` depending on DB rules).

## Navigation
- To S4 Dish Detail
- To S6 Add/Edit Dish

## Data Requirements
- `dishes` (fetch all)
- `categories` (fetch all)

## API Requirements
- Read `dishes` and `categories`.
- Delete `dishes`.

## State Requirements
- Loading
- Success
- Empty Database

## Validation
- Confirm before deleting a dish.

## Permissions
- **Planner**: Full CRUD permissions (Add, Edit, Delete buttons visible).
- **Member**: View-only (buttons hidden).

## Edge Cases
- Deleting a dish that is currently scheduled in the Week View.

## Acceptance Criteria
- Planners can manage dishes.
- Members can only view the list.
