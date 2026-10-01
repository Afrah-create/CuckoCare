# Layout system

CucoCare chooses layout from **window size classes**, not `Orientation`.

## Size classes

| Width | Class |
| --- | --- |
| &lt; 600 dp | compact |
| 600–839 dp | medium |
| ≥ 840 dp | expanded |

| Height | Class |
| --- | --- |
| &lt; 480 dp | compact |
| 480–899 dp | medium |
| ≥ 900 dp | expanded |

## Profiles

| Profile | Rule |
| --- | --- |
| `phonePortrait` | width compact |
| `phoneLandscape` | width ≥ 600 and height compact |
| `tablet` | width ≥ 600 and height ≥ 480 |
| `cramped` | width &lt; 320 or height &lt; 240 |

Access tokens via `context.layout` from `LayoutScope` (installed in `MaterialApp.builder`).

## Building screens

- Wrap page bodies with `ContentFrame` or apply its margins and use `ContentFrame.scrollBottomInset` on scroll views.
- Use `TwoPane` for primary/secondary content on `phoneLandscape` and `tablet`.
- Auth flows use `AuthScaffold`.
- Tab roots in `phoneLandscape` hide the top app bar; sync and account live on the navigation rail.

See `lib/app/layout/` for breakpoints, tokens, and helpers.
