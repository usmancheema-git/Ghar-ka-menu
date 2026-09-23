# Data Model

All data is stored in Supabase (PostgreSQL).

## Tables

### 1. `households`
- `id` (UUID, PK)
- `name` (String, required)
- `join_code` (String/6-digit, unique, required)
- `alert_time` (Time, default '20:00')
- `created_at` (Timestamp)

### 2. `members`
- `id` (UUID, PK - maps to auth.users)
- `household_id` (UUID, FK -> households)
- `name` (String, required)
- `role` (Enum: `planner` | `member`)
- `fcm_token` (String, nullable)

### 3. `categories`
- `id` (UUID, PK)
- `household_id` (UUID, FK -> households)
- `name` (String, required)
- `sort_order` (Integer)

### 4. `dishes`
- `id` (UUID, PK)
- `household_id` (UUID, FK -> households)
- `category_id` (UUID, FK -> categories)
- `name` (String, required)
- `ingredients_text` (Text, optional)
- `notes` (Text, optional)
- `last_cooked_on` (Date, optional, maintained by system)
- `times_cooked` (Integer, default 0, maintained by system)

### 5. `day_plans`
- `id` (UUID, PK)
- `household_id` (UUID, FK -> households)
- `date` (Date, unique per household)
- `dish_id` (UUID, FK -> dishes)
- `status` (Enum: `planned` | `cooked` | `cancelled`)

## RLS Rules
- All reads and writes are scoped by `household_id`.
- Members (`role = 'member'`) have `SELECT` access only for `categories`, `dishes`, and `day_plans`.
- Planners (`role = 'planner'`) have `ALL` access for `categories`, `dishes`, and `day_plans`.

## Implementation Notes
- `members.id` maps directly to `auth.users.id`.
- Household creation and joining use the security-definer RPCs `create_household` and `join_household` in `supabase/migrations/001_initial_schema.sql`.
- `day_plans.dish_id` is nullable so deleting a dish can leave an unassigned day.
- Realtime is enabled for household, member, category, dish, and day-plan changes by the migration.
- Apply `002_production_hardening.sql` after the initial migration to seed default categories and restrict role changes to planners through `update_member_role`.
