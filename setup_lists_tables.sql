-- Run this once in the Supabase SQL editor.
--
-- The Specialization admin list is backed by the app's REAL tables
-- (`specialties`, `specialty_group_map`), not a separate website-only table,
-- so admin edits/deletes here are reflected in the mobile app too.
--
-- specialist_profiles.specialization (text) already has a FK to specialties.name,
-- and specialist_profiles.specialty_id (int) already has a FK to specialties.id.
-- Neither is touched by this script.

-- 1. Add an admin-manageable active flag to the existing `specialties` table.
--    Additive + defaulted, so existing rows/behavior are unaffected.
--    (Grouping is NOT a new column — it already lives in `specialty_group_map`,
--    which the admin page reads/writes directly via `review_groups`.)
alter table specialties add column if not exists is_active boolean not null default true;

-- 2. specialties/specialty_group_map currently only have a SELECT policy for
--    logged-in users. Add what's missing:
--    - anon read access, so the public registration page (not yet logged in)
--      can populate the specialization dropdown
--    - admin write access, so the new admin Lists page can add/edit/delete
create policy "Public can view active specialties"
  on specialties for select
  to anon
  using (is_active = true);

create policy "Admins can manage specialties"
  on specialties for all
  to authenticated
  using (exists (select 1 from profiles where id = auth.uid() and role = 'admin'))
  with check (exists (select 1 from profiles where id = auth.uid() and role = 'admin'));

create policy "Admins can manage specialty group map"
  on specialty_group_map for all
  to authenticated
  using (exists (select 1 from profiles where id = auth.uid() and role = 'admin'))
  with check (exists (select 1 from profiles where id = auth.uid() and role = 'admin'));

-- 3. Make specialty_group_map rows disappear automatically when their
--    specialty is deleted (works no matter how the delete happens — admin
--    panel, SQL editor, another client — not just from our own app code).
do $$
declare
  fk_name text;
begin
  select tc.constraint_name into fk_name
  from information_schema.table_constraints tc
  join information_schema.key_column_usage kcu on tc.constraint_name = kcu.constraint_name
  where tc.constraint_type = 'FOREIGN KEY'
    and tc.table_name = 'specialty_group_map'
    and kcu.column_name = 'specialty_id';

  if fk_name is not null then
    execute format('alter table specialty_group_map drop constraint %I', fk_name);
  end if;

  alter table specialty_group_map
    add constraint specialty_group_map_specialty_id_fkey
    foreign key (specialty_id) references specialties(id) on delete cascade;
end $$;

-- Note: specialist_profiles.specialty_id / .specialization are intentionally
-- left as-is (default RESTRICT). Deleting a specialty that's still assigned
-- to a specialist will fail with a foreign-key error rather than silently
-- orphaning/blanking their profile — the admin page surfaces that as a
-- friendly message asking to reassign the specialist first.

-- 4. `review_groups` already has a SELECT policy for authenticated users
--    (used by the admin page's Group dropdown). Add admin write access too,
--    so the admin page's "Manage Groups" panel can add/edit/delete groups.
create policy "Admins can manage review groups"
  on review_groups for all
  to authenticated
  using (exists (select 1 from profiles where id = auth.uid() and role = 'admin'))
  with check (exists (select 1 from profiles where id = auth.uid() and role = 'admin'));

-- 5. The `specializations` table created earlier is superseded by `specialties`.
--    Nothing in the codebase references it after this change — safe to drop.
drop table if exists specializations;

-- 6. An earlier draft of this script added `display_order` to `specialties`
--    before grouping moved to `specialty_group_map` + `review_groups` instead.
--    It's unused now — drop it if present.
alter table specialties drop column if exists display_order;

-- 7. The existing rows in `specialties` and `review_groups` were originally
--    seeded with explicit id values rather than through their id sequences,
--    so the sequences still think the next id is 1 — colliding with existing
--    rows the moment the admin panel tries to insert a new one ("duplicate
--    key value violates unique constraint ..._pkey"). Resync both sequences
--    to the actual current max id.
select setval('specialties_id_seq', (select max(id) from specialties));
select setval('review_groups_id_seq', (select max(id) from review_groups));

-- 8. `group_secondary_map` (primary_group_id -> review_groups.id,
--    secondary_group_id -> review_groups.id, both ON DELETE CASCADE already)
--    currently only has a SELECT policy for authenticated users. Add admin
--    write access so the "Manage Groups" panel can set secondary-group links.
create policy "Admins can manage group secondary map"
  on group_secondary_map for all
  to authenticated
  using (exists (select 1 from profiles where id = auth.uid() and role = 'admin'))
  with check (exists (select 1 from profiles where id = auth.uid() and role = 'admin'));
