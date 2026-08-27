# Navigation

## Screens & Routes
| Screen ID | Screen Name | Route | Entry Points | Authentication |
|---|---|---|---|---|
| **S1** | Onboarding | `/onboarding` | App Start (Unauthenticated) | None |
| **S2** | Week View (Home) | `/` or `/home` | App Start (Authenticated), Nav Bar | Required |
| **S3** | Assign Dish | `/assign/:date` | S2 Week View (Empty day / Edit) | Planner Only |
| **S4** | Dish Detail | `/dish/:id` | S2 Week View, S5 Dishes Manager | Required |
| **S5** | Dishes Manager | `/dishes` | Nav Bar | Required |
| **S6** | Add/Edit Dish | `/dishes/new` (add), `/dishes/edit/:id` (edit) | S5 Dishes Manager | Planner Only |
| **S7** | History | `/history` | Nav Bar | Required |
| **S8** | Settings | `/settings` | Nav Bar | Required |

## Navigation Diagram
```text
App Launch
  |
  v
Auth Check --(Not Auth)--> S1 Onboarding
  |
  +--(Auth)--> S2 Week View (Bottom Nav Tab 1)
                  |--> S3 Assign Dish (Modal / Push)
                  |--> S4 Dish Detail (Push)
  |
  +----------> S7 History (Bottom Nav Tab 2)
  |
  +----------> S5 Dishes Manager (Bottom Nav Tab 3)
                  |--> S4 Dish Detail (Push)
                  |--> S6 Add/Edit Dish (Push)
  |
  +----------> S8 Settings (Bottom Nav Tab 4)
```

## Modals & Transitions
- S3 (Assign Dish) and S6 (Add/Edit Dish) should ideally slide up or push normally, with a clear back/close button.
- S6 is reached from S5 two ways: the header **+** button opens `/dishes/new`, a row's pencil opens `/dishes/edit/:id`. A successful save pops back to S5, which reloads its list.
- Bottom navigation is persistent on S2, S7, S5, S8.
