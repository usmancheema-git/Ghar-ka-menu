# Ghar ka Menu — Project Context (v1)

> **Purpose:** Feature clarity + flow for a family weekly lunch menu app. Personal/portfolio project — deliberately weekend-sized. Scope is locked small; anything not listed under "In scope" is out.
>
> **Working name:** Ghar ka Menu (final naam baad mein)
> **Owner:** Awais
> **Status:** v1 spec — not started

---

## 1. What this app is

Flutter + Supabase app for a **joint family's shared lunch planning**. One shared household, next 7 days ka lunch menu sab ke phone pe visible. Ek din pehle alert: "kal ye dish banni hai — ingredients check kar lo." Har dish ka **last-cooked history** track hota hai, jis se app rotation-based recommendations deti hai.

**Core problem solved:** "Aaj kya pakega?" ka daily decision — aur "pichle hafte bhi to yehi bana tha" ka jhagra.

---

## 2. Users & roles

| Role | Kaun | Powers |
|---|---|---|
| **Planner** | Jo menu decide karta/karti hai (1-2 log) | Dishes/categories manage, week plan, mark cooked |
| **Member** | Baaki family | View-only: menu dekhna, alerts receive karna |

- No email/password complexity in v1. **Household code join model:** planner household banata hai, 6-digit code share karta hai, members code se join karte hain.
- Ek user = ek household (v1).

---

## 3. Core concepts

### 3.1 Categories
Dishes ko organize karne ka top level. Seed defaults (editable):

- Sabzi
- Daal
- Chawal (biryani, pulao, sada chawal)
- Gosht (beef/mutton)
- Murgh (chicken)
- Special (haleem, nihari, etc.)

Planner apni categories add/rename/delete kar sakta hai. Delete tabhi jab category empty ho.

### 3.2 Dishes (presets)
Har dish ek category ke under. Fields:

| Field | Required | Notes |
|---|---|---|
| name | ✅ | e.g., "Bhindi", "Chicken Biryani" |
| category | ✅ | FK → categories |
| ingredients | ❌ | Simple text list (checklist nahi, v1 mein sirf display) |
| notes | ❌ | e.g., "Dado wali recipe", "raat ko gosht nikalna hai" |
| last_cooked_on | auto | App maintain karti hai (see 5.2) |
| times_cooked | auto | Counter, recommendations + stats ke liye |

App **seed dish pack** ke sath ship hogi (~40-50 common Pakistani dishes, categories ke sath) taake pehle din khali na lage. Planner sab edit/delete kar sakta hai.

### 3.3 Week plan
- Planning unit: **1 din = 1 lunch = 1 dish** (v1 mein ek hi dish per day; "sath mein raita bhi" type combos out of scope).
- Rolling 7-day view: aaj + agle 6 din.
- Kisi bhi din pe tap → dish assign/change karo.
- Din khali bhi reh sakta hai ("bahar se ayega" / abhi decide nahi hua).

---

## 4. Screens & flow

### 4.1 Screen list (total 8 — is se zyada nahi)

| # | Screen | Kya hai |
|---|---|---|
| S1 | Onboarding | Create household (planner) ya Join via code (member) |
| S2 | **Week View (home)** | 7 din ki vertical list, har din pe dish card. Aaj highlighted. |
| S3 | Assign Dish | Day pe tap → category tabs → dish list (recommendation-sorted) → select |
| S4 | Dish Detail | Ingredients, notes, last cooked, history |
| S5 | Dishes Manager | Categories + dishes CRUD (planner only) |
| S6 | Add/Edit Dish | Form |
| S7 | History | Pichle 30 din kya paka — simple list |
| S8 | Settings | Household code, members list, notification time, role |

### 4.2 Primary flows

**Flow A — Weekly planning (planner, hafte mein 1 baar, ~5 min):**
```
Week View → khali din pe tap → Assign Dish screen
→ category chuno → recommended list mein se dish select
→ wapas Week View → agla din → repeat
```

**Flow B — Daily cycle (automatic):**
```
Raat 8 baje (configurable): kal wali dish ka alert sab members ko
→ "Kal: Chicken Biryani — ingredients check kar lo" (tap → Dish Detail)
Agle din dopahar: dish "cooked" mark hoti hai (see 5.2)
→ last_cooked_on update → recommendations improve
```

**Flow C — Member ka daily use (~10 seconds):**
```
App kholo → Week View → aaj ka khana dekha → band
```

Yeh Flow C hi asli test hai: WhatsApp pe "aaj kya bana hai?" poochne se tez hona chahiye.

---

## 5. Feature logic

### 5.1 Recommendations ("kaafi din se nahi bani")
Assign Dish screen (S3) pe dishes ka sort order — yehi app ka differentiator hai:

```
score = days_since_last_cooked   (kabhi nahi bani = infinity, sab se upar)
sort: score DESC within selected category
```

Display rules:
- Har dish card pe badge: **"12 din pehle"** / **"kabhi nahi bani"**
- **Repeat warning:** agar dish pichle 7 din mein ban chuki hai → card pe amber tag *"is hafte ban chuki hai"* (block nahi karna, sirf batana — biryani do dafa bhi chal jati hai)
- Optional v1.1: Week View pe khali din ke liye "Suggest" button → top-scored dish har category se 1-1.

**No ML, no AI in v1.** Sirf date math. Yeh kaafi hai aur yehi WhatsApp se behtar hai — WhatsApp yaad nahi rakhta ke pichle mangal ko bhi bhindi bani thi.

### 5.2 Cooked tracking
- Jab din guzar jata hai aur us din pe dish assigned thi → **auto-mark cooked** (server-side, day rollover pe): `last_cooked_on` + `times_cooked` update, history entry create.
- Planner manually bhi toggle kar sakta hai ("aaj yeh nahi bani, mehmaan aa gaye the") → us din ki entry cancel, dish ka last_cooked untouched.
- Simple rakhna hai: koi rating, koi photo, koi review nahi.

### 5.3 Alerts
| Alert | Kab | Kis ko |
|---|---|---|
| Kal ka menu | Raat 8:00 PM (configurable per household) | Sab members |
| Khali kal | Agar kal ka din unassigned hai → sirf planner ko: "kal ka menu set karo" | Planner |

- Push via FCM (supabase edge function / scheduled job → FCM).
- In-app Week View hamesha source of truth; notification sirf pointer hai.

---

## 6. Data model (5 tables)

```
households      id, name, join_code, alert_time, created_at
members         id, household_id, name, role (planner|member), fcm_token
categories      id, household_id, name, sort_order
dishes          id, household_id, category_id, name, ingredients_text,
                notes, last_cooked_on, times_cooked
day_plans       id, household_id, date (unique per household), dish_id,
                status (planned|cooked|cancelled)
```

- `last_cooked_on` / `times_cooked` denormalized on `dishes` — history `day_plans` se reconstruct ho sakti hai lekin sort ke liye direct column tez hai.
- RLS: har row household_id se scoped. Planner-only writes on categories/dishes/day_plans.

---

## 7. Tech stack

Livestock app wala hi stack — zero new learning:

| Layer | Choice |
|---|---|
| Mobile | Flutter, flutter_bloc, get_it, go_router |
| Backend | Supabase (PostgreSQL + RLS + Auth anonymous/phone) |
| Push | FCM + Supabase scheduled edge function |
| Architecture | Feature-first, lekin **livestock jitni ceremony nahi** — chhota project hai, 3 features (household, dishes, planner) kaafi hain |

---

## 8. Scope

### In scope (v1)
- Household create/join via code
- Categories + dishes CRUD, seed pack
- 7-day rolling lunch planner
- Last-cooked tracking + recommendation sort + repeat warning
- Day-before alert + empty-day reminder
- 30-day history

### Out of scope (v1) — likh ke lock kar rahe hain
- Breakfast/dinner (lunch only — yehi problem hai)
- Multiple dishes per day / side dishes
- Ingredient checklist with ticking, grocery list, quantities
- Recipes / cooking steps
- Voting ("kal kya banaye?" polls) — tempting hai, v2 candidate
- Multiple households per user
- AI suggestions
- Web app

### v2 candidates (sirf agar family actually use kare 1 mahina)
1. Family voting on tomorrow's dish
2. Grocery checklist from ingredients
3. "Suggest full week" button (auto-fill rotation)

---

## 9. Build order (weekend-sized check)

| Phase | Kya | Estimate |
|---|---|---|
| 1 | Supabase schema + RLS + seed pack | 0.5 din |
| 2 | Household onboarding + Week View (read-only) | 1 din |
| 3 | Dishes manager + Assign flow + recommendations | 1 din |
| 4 | Cooked rollover + history | 0.5 din |
| 5 | FCM alerts | 0.5 din |
| **Total** | | **~3.5 din** |

Agar estimate 5 din cross kare to scope wapas kaato — yeh product bet nahi hai, personal tool hai.

---

*Document version: 1.0 — July 15, 2026*
