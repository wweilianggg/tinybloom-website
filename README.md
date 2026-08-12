# TinyBloom Website

The public website and admin panel for TinyBloom, a pregnancy support app. Plain HTML/JS, backed by Supabase (database, auth, storage, and two Edge Functions).

## Structure

- **Public pages** (repo root) — `index.html`, `features.html`, `subscriptions.html`, `testimonials.html`, `faq.html`, `register.html`, `login.html`, `reset-password.html`, `payment.html`, `download.html`, and a few post-signup pages.
- **`admin/`** — the admin panel: dashboard, user/application management, page content editors, and lookup list editors (specializations, hospitals, etc.).
- **`js/`** — shared scripts. `js/app.js` is a bundled copy of the others and is what every page actually loads, so any change to a script also needs to be made there.
- **`css/style.css`** — all styling.
- **`supabase/functions/`** — two Edge Functions: one creates specialist/volunteer accounts pending approval, the other deletes a user's account (including their login) when an admin removes them.
- **SQL files** in the repo root — run these in the Supabase SQL Editor to set up tables and seed starting data.

## Setup

1. **Connect Supabase** — open `js/supabase.js` (and the matching block near the top of `js/app.js`) and set your project's URL and anon key. Find these under Supabase → Project Settings → API.
2. **Set up the database** — run each `.sql` file in the repo root in the Supabase SQL Editor.
3. **Deploy the Edge Functions** — `supabase functions deploy create-pending-account` and `supabase functions deploy delete-user-account`, or paste each `index.ts` into Supabase Dashboard → Edge Functions.
4. **Host the site** — push to a GitHub repo and enable GitHub Pages (Settings → Pages → Source: main branch / root).
5. **Set Auth redirect URLs** — Supabase → Authentication → URL Configuration → set Site URL and Redirect URLs to your deployed site's address.
6. **Create the first admin** — Supabase → Authentication → Users → add a user manually, then make sure their row in the `profiles` table has `role` set to `admin`.

## User roles

| Role | Access |
|---|---|
| `admin` | Full admin panel |
| `free_user` / `premium_user` | Regular app users (mums) |
| `next_of_kin` | Linked to a mum's account |
| `specialist` | Doctor/specialist — needs admin approval before logging in |
| `volunteer` | Volunteer — needs admin approval before logging in |

Anyone can browse the public site and register. Only admins log in through `login.html` and reach `admin/`.
