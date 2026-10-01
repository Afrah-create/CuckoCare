# Auth UI notes

Sign-in, create-account, and forgot-password use `AuthShell` + single outer `AuthCard` (see `docs/branding.md`).

## Migrated to `AppTextField` / `PasswordField`

- Login / create-account (`login_form.dart`)
- Forgot password (`forgot_password_form.dart`)

## Still on raw inputs (follow-up)

- Farm setup and other feature forms under `lib/features/**`

## Manual QA checklist

Portrait and both landscape rotations; keyboard on each field; largest font size; dark/light; offline first sign-in; TalkBack on mode switch and fields.
