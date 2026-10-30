-- 0025: Hashed 6-digit email OTP challenges (signup verify + password reset).
-- Written only by the email-otp Edge Function (service_role).

create table if not exists public.email_otp_challenges (
  id uuid primary key default gen_random_uuid(),
  email text not null,
  purpose text not null check (purpose in ('signup', 'password_reset')),
  code_hash text not null,
  expires_at timestamptz not null,
  attempt_count int not null default 0,
  consumed_at timestamptz,
  created_at timestamptz not null default now()
);

create index if not exists email_otp_challenges_lookup_idx
  on public.email_otp_challenges (email, purpose, created_at desc);

alter table public.email_otp_challenges enable row level security;

revoke all on table public.email_otp_challenges from public, anon, authenticated;
grant all on table public.email_otp_challenges to service_role;
