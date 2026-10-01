# ADR 022: Single lifecycle service and flush coordinator

## Status

Accepted

## Decision

`AppLifecycleService` is the only `AppLifecycleListener`. Features register inactive callbacks or `Flushable` handlers instead of adding their own observers.
