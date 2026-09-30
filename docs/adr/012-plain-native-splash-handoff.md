# ADR 012: Plain native splash, Flutter intro

## Status
Accepted

## Decision
Native splash shows only `brandCream` / dark splash colour. No logo bitmap on Android 12+ (transparent system splash image). Flutter `/splash` matches the colour then animates the mark.

## Consequences
Seamless handoff; intro assets load after first frame.
