# Project Context

## Overview
**Ghar ka Menu** is a Flutter + Supabase mobile application designed to solve a very specific, recurring family problem: *"Aaj lunch mein kya pakega?"* (What's for lunch today?), and the common disputes about meal repetition.

## Why it exists
To provide a transparent, 7-day shared lunch menu for a single household. It replaces WhatsApp groups by offering a structured schedule, an inventory of household dishes, and smart rotation recommendations based on when a dish was last cooked.

## Target Users
- **Planners**: The 1 or 2 family members who actually decide the menu and manage the kitchen.
- **Members**: Rest of the family who just want to know what is being served.

## Primary Workflows
1. **Weekly Planning**: The planner opens the app once a week, views the upcoming 7 empty days, and assigns dishes from a sorted recommendation list that highlights dishes that haven't been cooked in a long time.
2. **Daily Awareness**: Every evening (e.g., 8:00 PM), the app sends a push notification to all members announcing tomorrow's lunch, allowing them to verify ingredients or just be informed.
3. **Auto-Tracking**: The app automatically assumes a scheduled dish was cooked when the day passes, updating the dish's history to improve future recommendations.

## Scope & Constraints
**In Scope (v1):**
- Household join via code.
- Categories & Dishes CRUD operations.
- 7-day rolling planner.
- Last-cooked tracking + Recommendation sorting.
- Day-before push alerts.
- 30-day history log.

**Out of Scope (v1):**
- Breakfast / Dinner tracking (lunch only).
- Side dishes / multiple dishes per day.
- Ingredient checklists / grocery lists.
- Cooking recipes / steps.
- Family voting.
- Multiple households per user.
- AI suggestions.

## Current Status
- UI/UX wireframes (HTML/CSS) are complete.
- Functional specifications are defined.
- Flutter implementation is pending.
