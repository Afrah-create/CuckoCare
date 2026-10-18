---
inclusion: fileMatch
fileMatchPattern: ['lib/**/*.dart']
---

# Layout

- Read layout from `context.layout`. Do not read `MediaQuery.sizeOf`, `MediaQuery.of(context).size`, or `Orientation`.
- Screens use `AppPage` and a `PageLayout` preset. Do not build a `Scaffold` in `lib/features`.
- Breakpoint numbers live in `lib/app/layout/breakpoints.dart`.
- A `LayoutBuilder` may count columns from width. It must not choose the profile, the rail, or the page chrome.
- Do not decide layout from the height inside a `Scaffold`. The keyboard shrinks that height and would flip the layout while someone is typing.
- Grids use `AdaptiveGrid` and `mainAxisExtent`. Forms use `AdaptiveForm`.
- New routes need a sample in `test/layout/route_samples.dart`.
