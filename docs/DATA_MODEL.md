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

## Open Questions / Decisions Required
- How is the S1 Onboarding Google Sign-In mapped to the `members` table? We need to ensure the Auth User ID syncs with the `members.id`.
