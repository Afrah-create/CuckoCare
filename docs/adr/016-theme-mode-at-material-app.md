# ADR 016: Theme mode switched only at root MaterialApp

## Status

Accepted

## Context

Feature widgets must not branch on light/dark or read `ThemeMode` directly.

## Decision

`CucoCareApp` is the sole consumer of `themeModeProvider`. All other UI reads `Theme.of(context)`, `context.colors`, and related extensions.

## Consequences

Theme changes propagate through Flutter's theme animation. Router and other long-lived providers are not invalidated by appearance changes.
