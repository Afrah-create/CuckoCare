# ADR 018: Load theme preference before runApp; native splash limitation

## Status

Accepted

## Decision

`main()` loads `ThemePreferenceRepository.load()` before `runApp` and overrides `initialThemeModeProvider` so the first Flutter frame uses the saved mode.

The **native** splash screen follows the **OS** theme only. If the in-app preference differs from system, background colour may mismatch briefly until Flutter paints.
