# ADR 013: Runtime mask tinting

## Status
Accepted

## Decision
Store white RGBA masks in `assets/brand/` and tint with `ColorFiltered` + `BlendMode.srcIn` using `BrandTokens`.

## Consequences
One asset set for light/dark; theme controls ink colour.
