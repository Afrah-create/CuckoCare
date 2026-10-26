-- Dev/staging fake vets for Find a Vet. Not for production.
-- Included from tool/generate_seed.dart after programme seed data.

insert into auth.users (
  instance_id,
  id,
  aud,
  role,
  email,
  encrypted_password,
  email_confirmed_at,
  raw_app_meta_data,
  raw_user_meta_data,
  created_at,
  updated_at,
  confirmation_token,
  email_change,
  email_change_token_new,
  recovery_token
)
select
  coalesce((select id from auth.instances limit 1), '00000000-0000-0000-0000-000000000000'::uuid),
  v.id,
  'authenticated',
  'authenticated',
  v.email,
  crypt('dev-only-not-for-prod', gen_salt('bf')),
  now(),
  '{"provider":"email","providers":["email"]}'::jsonb,
  jsonb_build_object('app_role', 'vet', 'display_name', v.display_name),
  now(),
  now(),
  '',
  '',
  '',
  ''
from (
  values
    (
      '11111111-1111-4111-8111-111111111111'::uuid,
      'vet.kampala@example.invalid',
      'Dr. Amina Nalwoga'
    ),
    (
      '22222222-2222-4222-8222-222222222222'::uuid,
      'vet.wakiso@example.invalid',
      'Dr. Peter Okello'
    ),
    (
      '33333333-3333-4333-8333-333333333333'::uuid,
      'vet.mbale@example.invalid',
      'Dr. Sarah Akello'
    ),
    (
      '44444444-4444-4444-8444-444444444444'::uuid,
      'vet.pending@example.invalid',
      'Dr. Pending Verification'
    )
) as v(id, email, display_name)
on conflict (id) do nothing;

update public.vet_profiles vp
set
  display_name = s.display_name,
  organization = s.organization,
  district = s.district,
  phone = s.phone,
  latitude = s.latitude,
  longitude = s.longitude,
  is_verified = s.is_verified,
  is_active = true,
  opted_in = true,
  offers_consultation = true,
  offers_farm_visit = true,
  updated_at = now()
from (
  values
    (
      '11111111-1111-4111-8111-111111111111'::uuid,
      'Dr. Amina Nalwoga',
      'Kampala Vet Clinic',
      'Kampala',
      '+256700000001',
      0.3476,
      32.5825,
      true
    ),
    (
      '22222222-2222-4222-8222-222222222222'::uuid,
      'Dr. Peter Okello',
      'Wakiso Poultry Services',
      'Wakiso',
      '+256700000002',
      0.4044,
      32.4594,
      true
    ),
    (
      '33333333-3333-4333-8333-333333333333'::uuid,
      'Dr. Sarah Akello',
      'Mbale Animal Health',
      'Mbale',
      '+256700000003',
      1.0784,
      34.1750,
      true
    ),
    (
      '44444444-4444-4444-8444-444444444444'::uuid,
      'Dr. Pending Verification',
      'Unlisted Practice',
      'Jinja',
      '+256700000004',
      0.4244,
      33.2041,
      false
    )
) as s(
  user_id, display_name, organization, district, phone, latitude, longitude, is_verified
)
where vp.user_id = s.user_id;
