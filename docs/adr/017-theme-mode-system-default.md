# ADR 017: Three-way theme mode with System default

## Status

Accepted

## Decision

Users choose **System**, **Light**, or **Dark**. Default and fallback for corrupt storage is **System** (`ThemeMode.system`), so the app follows `platformBrightness` live without a manual observer.
