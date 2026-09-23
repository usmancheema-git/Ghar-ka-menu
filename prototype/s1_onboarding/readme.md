# Onboarding Screen

## Screen ID
S1

## Purpose
This screen handles the entry flow for a user using Supabase email/password authentication and a household join code.

## User Flow
- **Planner**: Creates or signs in to an email account, creates a new household, gives it a name, and gets a unique 6-digit join code.
- **Member**: Creates or signs in to an email account, enters the 6-digit join code shared by the Planner, and joins the household.

## Entry Points
- App Start (Unauthenticated state)

## Exit Points
- S2 Week View (upon successful household creation or joining)

## Prototype
`s1_onboarding/index.html`

## Layout Structure
- App Logo & Branding at the top.
- Email and password fields with sign-in and account creation actions.
- After Sign-In: Signed-in user bar (avatar, name, email).
- Card A (Setup New Household) section.
- Text Divider ("OR").
- Card B (Join Household) section.

## Components
- Brand Logo
- Primary Buttons (Email Sign-In, Account Creation, Create, Join)
- Input Fields (Household Name, Join Code)
- Text Dividers

## Visual Requirements
- Follow `docs/UI_SYSTEM.md` for colors and button heights.
- Ensure proper spacing between the two main action cards.

## Interactions
- Tapping "Sign In with Email" authenticates the existing account.
- Tapping "Create Email Account" creates a Supabase Auth account.
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
- Supabase Auth (Email Provider)
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
- Email confirmation is required when enabled in Supabase Auth.

## Acceptance Criteria
- Planner can successfully create a household and is redirected to S2.
- Member can successfully join an existing household and is redirected to S2.
- Appropriate error messages are shown for invalid join codes.
