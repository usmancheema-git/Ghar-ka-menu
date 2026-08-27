# History Screen

## Screen ID
S7

## Purpose
Displays a log of past lunches served in the household over the last 30 days, providing transparency and resolving disputes.

## User Flow
- Users scroll through the list to see what they ate over the past month.

## Entry Points
- Bottom Navigation (Tab 2)

## Exit Points
- None specific (handled by Bottom Nav)

## Prototype
`s7_history/index.html`

## Layout Structure
- **Header**: Title, Subtitle.
- **History List**: Scrollable feed of previous lunch assignments.

## Components
- History Item Card (Dish Name, Category, Date, Final State Badge)

## Visual Requirements
- Badges must clearly indicate `Served` vs `Cancelled`.

## Interactions
- Vertical scrolling.

## Functional Behavior
- Queries `day_plans` where date is in the past 30 days.
- Ordered by date descending.

## Navigation
- Bottom Nav handles routing.

## Data Requirements
- `day_plans` (date < today).
- `dishes` (joined to get names).

## API Requirements
- Read past `day_plans` and `dishes`.

## State Requirements
- Loading
- Empty (no history yet)
- Success

## Validation
- N/A

## Permissions
- All roles can view.

## Edge Cases
- App has just been installed, no history exists.

## Acceptance Criteria
- Shows past 30 days of data accurately.
- Accurately reflects Cooked vs Cancelled states.
