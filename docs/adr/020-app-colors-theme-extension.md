# ADR 020: Semantic tokens via ThemeExtension with lerp

## Status

Accepted

## Decision

`AppColors` extends `ThemeExtension<AppColors>` with `copyWith` and `lerp` for animated theme transitions. Widgets use semantic tokens and `StatusChip` (icon + label) for state colours; no brightness branching in feature code.
