-- ============================================================================
-- New lookup tables for the Specialist / Volunteer registration dropdowns.
-- Mirrors the shape and RLS pattern of the existing `areas_of_expertise` table.
--
-- Run this in the Supabase SQL Editor (Project > SQL Editor > New query).
-- If your `areas_of_expertise` table uses different RLS policies than what's
-- below, adjust these to match before running — this script assumes:
--   - anyone (anon + authenticated) can read active rows
--   - only users whose profiles.role = 'admin' can insert/update/delete
-- ============================================================================

-- ---------- Hospitals / Clinics ----------
create table if not exists public.hospitals (
  id uuid primary key default gen_random_uuid(),
  label text not null,
  display_order int not null default 0,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

alter table public.hospitals enable row level security;

create policy "Anyone can read hospitals"
  on public.hospitals for select
  using (true);

create policy "Admins can manage hospitals"
  on public.hospitals for all
  using (exists (select 1 from public.profiles where id = auth.uid() and role = 'admin'))
  with check (exists (select 1 from public.profiles where id = auth.uid() and role = 'admin'));

-- ---------- Medical Qualifications ----------
create table if not exists public.medical_qualifications (
  id uuid primary key default gen_random_uuid(),
  label text not null,
  display_order int not null default 0,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

alter table public.medical_qualifications enable row level security;

create policy "Anyone can read medical qualifications"
  on public.medical_qualifications for select
  using (true);

create policy "Admins can manage medical qualifications"
  on public.medical_qualifications for all
  using (exists (select 1 from public.profiles where id = auth.uid() and role = 'admin'))
  with check (exists (select 1 from public.profiles where id = auth.uid() and role = 'admin'));

-- ---------- Volunteer Organisations / Affiliations ----------
create table if not exists public.volunteer_organisations (
  id uuid primary key default gen_random_uuid(),
  label text not null,
  display_order int not null default 0,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

alter table public.volunteer_organisations enable row level security;

create policy "Anyone can read volunteer organisations"
  on public.volunteer_organisations for select
  using (true);

create policy "Admins can manage volunteer organisations"
  on public.volunteer_organisations for all
  using (exists (select 1 from public.profiles where id = auth.uid() and role = 'admin'))
  with check (exists (select 1 from public.profiles where id = auth.uid() and role = 'admin'));

-- ============================================================================
-- Seed data — Singapore hospitals/clinics, medical qualifications, and
-- organisations relevant to pregnancy support. Edit freely via the new
-- Admin > Lists pages after this is loaded; this is just a starting set.
-- ============================================================================

insert into public.hospitals (label, display_order) values
  ('KK Women''s and Children''s Hospital (KKH)', 1),
  ('Singapore General Hospital (SGH) — O&G Department', 2),
  ('National University Hospital (NUH) — Women''s Centre', 3),
  ('Thomson Medical Centre', 4),
  ('Mount Elizabeth Hospital', 5),
  ('Mount Elizabeth Novena Hospital', 6),
  ('Gleneagles Hospital', 7),
  ('Raffles Hospital — Raffles Women''s Centre', 8),
  ('Parkway East Hospital', 9),
  ('Mount Alvernia Hospital', 10),
  ('Sengkang General Hospital', 11),
  ('Ng Teng Fong General Hospital', 12),
  ('Changi General Hospital', 13),
  ('Tan Tock Seng Hospital', 14);

insert into public.medical_qualifications (label, display_order) values
  ('MBBS', 1),
  ('MD (Doctor of Medicine)', 2),
  ('M Med (Obstetrics & Gynaecology)', 3),
  ('MRCOG (Member, Royal College of Obstetricians & Gynaecologists)', 4),
  ('FRCOG (Fellow, Royal College of Obstetricians & Gynaecologists)', 5),
  ('FAMS (Obstetrics & Gynaecology)', 6),
  ('DRCOG (Diploma, Royal College of Obstetricians & Gynaecologists)', 7),
  ('Registered Nurse (RN)', 8),
  ('Registered Midwife (RM)', 9),
  ('Advanced Diploma in Midwifery', 10),
  ('Certified Lactation Consultant (IBCLC)', 11);

insert into public.volunteer_organisations (label, display_order) values
  ('Singapore Red Cross', 1),
  ('Breastfeeding Mothers'' Support Group (Singapore)', 2),
  ('AWARE Singapore', 3),
  ('Tsao Foundation', 4),
  ('Babes Pregnancy Crisis Support', 5),
  ('Health Promotion Board (HPB)', 6),
  ('Singapore Council of Women''s Organisations (SCWO)', 7),
  ('SG Her Empowerment (SHE)', 8),
  ('Filos Community Services', 9),
  ('Beyond Social Services', 10);
