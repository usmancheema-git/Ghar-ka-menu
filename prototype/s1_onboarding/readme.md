# Onboarding Screen

## Screen ID
S1

## Purpose
This screen handles the entry flow for a user. It uses a Household Code Model to avoid complex email/password setups.

## User Flow
- **Planner**: Clicks Google Sign-In, creates a new household, gives it a name, and gets a unique 6-digit join code.
- **Member**: Clicks Google Sign-In, enters the 6-digit join code shared by the Planner, and joins the household.

## Entry Points
- App Start (Unauthenticated state)

## Exit Points
- S2 Week View (upon successful household creation or joining)

## Prototype
`s1_onboarding/index.html`

## Layout Structure
- App Logo & Branding at the top.
- Google Sign-In Button (initially).
- After Sign-In: Signed-in user bar (avatar, name, email).
- Card A (Setup New Household) section.
- Text Divider ("OR").
- Card B (Join Household) section.

## Components
- Brand Logo
- Primary Button (Google Sign-In, Create, Join)
- Input Fields (Household Name, Join Code)
- Text Dividers

## Visual Requirements
- Follow `docs/UI_SYSTEM.md` for colors and button heights.
- Ensure proper spacing between the two main action cards.

## Interactions
- Tapping "Google Sign-In" triggers auth popup/flow.
- Entering text in Household Name and tapping "Create & Become Planner".
- Entering 6-digit code in Join Code and tapping "Join as Member".

## Functional Behavior
- Creates user in Supabase Auth.
- If creating: inserts new row in `households` table, creates user in `members` table with `planner` role.
- If joining: checks if `join_code` exists in `households`, if yes, creates user in `members` table with `member` role.

## Navigation
- Redirects to `/home` (S2) on success.

## Data Requirements
- `households` (name, join_code)
- `members` (name, role, household_id)

## API Requirements
- Supabase Auth (Google Provider)
- PostgREST queries to insert/select households.

## State Requirements
- Initial (Unauthenticated)
- Loading (during sign-in or database insertion)
- Error (invalid join code, network error)
- Success (redirect to S2)

## Validation
- Household Name must not be empty.
- Join Code must be exactly 6 digits.

## Permissions
- None required to access this screen.

## Edge Cases
- Invalid join code entered.
- User closes Google Sign-In modal prematurely.

## Acceptance Criteria
- Planner can successfully create a household and is redirected to S2.
- Member can successfully join an existing household and is redirected to S2.
- Appropriate error messages are shown for invalid join codes.
