# Settings Screen

## Screen ID
S8

## Purpose
Handles household configuration, notification timing, role management, and member visibility.

## User Flow
- User views household details (join code).
- User adjusts alert time.
- Planner switches role to member for testing.

## Entry Points
- Bottom Navigation (Tab 4)

## Exit Points
- None specific (handled by Bottom Nav)

## Prototype
`s8_settings/index.html`

## Layout Structure
- **Household Info**: Name, Join Code.
- **Notification Settings**: Alert Time picker.
- **Role Config**: Toggle (Planner <-> Member).
- **Members List**: List of all users in the household.

## Components
- Data Display blocks (Join Code).
- Time Picker input.
- Switch/Toggle.
- List Tiles (Members).

## Visual Requirements
- Join Code should be visually prominent and easy to read/copy.

## Interactions
- Tapping Join Code copies it to clipboard.
- Adjusting alert time.
- Toggling Role.

## Functional Behavior
- Alert time updates `households.alert_time`.
- Role toggle updates `members.role` (for current user).

## Navigation
- Bottom Nav handles routing.

## Data Requirements
- `households` (name, join_code, alert_time).
- `members` (list of all members in household).

## API Requirements
- Read `households` and `members`.
- Update `households` and `members`.

## State Requirements
- Loading
- Success

## Validation
- N/A

## Permissions
- Both roles can view. Only planners should logically change the alert time. Role toggling is allowed for testing.

## Edge Cases
- None.

## Acceptance Criteria
- Join code is clearly displayed.
- Changes to alert time are saved.
- Members list accurately reflects the household users.
