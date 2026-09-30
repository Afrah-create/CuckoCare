# Navigation manual QA (Android)

Run on a physical device with **3-button** and **gesture** navigation.

## Tabs
- [ ] Open app signed in → lands on **Today**
- [ ] Switch across all five tabs; each root shows the bottom bar (or rail on wide layout)
- [ ] From **Batches**, open sample batch → back returns to list (does **not** exit app)
- [ ] On **Feed** root, back switches to **Today** (not exit)
- [ ] On **Today** root, back exits the app (no double-tap dialog)

## Re-tap tab
- [ ] Batches → open detail → tap **Batches** again → pops to list
- [ ] Today → scroll down → tap **Today** again → scrolls to top

## Auth
- [ ] Sign out → login screen; back does not return to farm data
- [ ] Sign in → Today; back exits (not login)

## More / profile
- [ ] More → Farm profile → save or close with back
- [ ] More → Sync diagnostics → back to More

## Deep link (when wired)
- [ ] Notification `/batches/1/vaccinations/9` → back to batch → back to list → back to Today → exit

## Process death
- [ ] Drill into batch detail, kill app from recents, reopen → restored tab/stack where possible

## Wide layout
- [ ] Emulator width ≥ 600dp shows **NavigationRail** with same behaviour as bar
