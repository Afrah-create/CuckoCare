# ADR 021: Flutter handles config changes; orientation not locked

## Status

Accepted

## Decision

`MainActivity` declares full `android:configChanges` so rotation resizes the Flutter view without activity recreation. All orientations are allowed via `kSupportedOrientations` in `bootstrap.dart` only.
