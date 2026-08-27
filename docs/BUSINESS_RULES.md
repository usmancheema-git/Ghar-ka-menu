# Business Rules

## User Roles & Permissions
- **Planner**: Has full permissions. Can create/edit/delete dishes, categories, and day plans. Can switch to Member role for testing.
- **Member**: Has read-only permissions. Cannot edit day plans or manage dishes.

## Menu Planning
- A single day can have only ONE dish assigned (no side dishes, no multi-course logic in v1).
- The planner covers a rolling 7-day window (Today + next 6 days).
- Days can be left empty ("Unassigned" / eating out).

## Dish Recommendation & Sorting
When assigning a dish to a day, the list is sorted by:
- **Score = Days since last cooked**.
- Dishes never cooked have infinite score (appear at the top).
- If a dish is already planned in the current 7-day rolling window, it must display a "Repeat Warning" (amber tag), but the planner is NOT blocked from assigning it anyway.

## Day Rollover & Auto-Cooked Tracking
- At the end of the day, any dish planned for that day is automatically marked as `Cooked`.
- When marked `Cooked` (automatically or manually), the dish's `last_cooked_on` is updated to that date, and `times_cooked` increments by 1.
- Planners can manually cancel a day's meal if they ate out. In this case, `last_cooked_on` and `times_cooked` do NOT update.

## Categories Deletion
- A category cannot be deleted if there are dishes assigned to it. It must be empty first.
