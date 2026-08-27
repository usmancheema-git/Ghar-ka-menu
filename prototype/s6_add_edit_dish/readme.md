# Add/Edit Dish Form Screen

## Screen ID
S6

## Purpose
A form used by Planners to either define a new dish preset or edit an existing one.

## User Flow
- Planner fills out the dish details (Name, Category, Ingredients, Notes).
- Planner saves the form to update the database.

## Entry Points
- S5 Dishes Manager (via '+' button or 'Edit' icon)

## Exit Points
- S5 Dishes Manager (after save or back)

## Prototype
`s6_add_edit_dish/index.html`

## Layout Structure
- **Header**: Back button, Dynamic Title ("Add New Dish" / "Edit Preset Dish").
- **Form**:
  - Dish Name (Input)
  - Category (Dropdown)
  - Ingredients (Textarea)
  - Special Notes (Textarea)
- **Footer**: Save Button.

## Components
- Text Inputs
- Select/Dropdown
- Primary Action Button

## Visual Requirements
- Form inputs must match the UI System.

## Interactions
- Entering text in fields.
- Selecting a category from the dropdown.
- Tapping 'Save' submits the form.

## Functional Behavior
- Validates required fields before submission.
- If Add mode: Inserts a new row into `dishes`.
- If Edit mode: Updates the existing row in `dishes`.

## Navigation
- Returns to S5 upon successful save.

## Data Requirements
- `categories` (to populate dropdown).
- Existing `dish` data (if in Edit mode).

## API Requirements
- Read `categories`.
- Insert or Update `dishes`.

## State Requirements
- Loading (submitting data)
- Success
- Error (validation or network failure)

## Validation
- **Dish Name**: Required, cannot be empty.
- **Category**: Required, must be selected.

## Permissions
- **Planner Only**.

## Edge Cases
- Network failure during save.

## Acceptance Criteria
- Required fields are enforced.
- New dishes appear in S5 after saving.
- Edited dishes reflect changes in S5 after saving.
