# TinyBloom — Setup & Deployment Guide

## 📁 Project Structure
```
tinybloom/
├── index.html              ← Home (marketing landing page)
├── features.html           ← Features page
├── subscriptions.html      ← Pricing page
├── testimonials.html       ← Testimonials page
├── faq.html                ← FAQ page
├── register.html           ← Public registration (all user types)
├── login.html              ← Admin-only login
├── reset-password.html     ← Password reset
├── admin-setup.html        ← ONE-TIME admin account creation
├── dashboard.html          ← User dashboard (post-login)
├── css/style.css
├── js/
│   ├── supabase.js         ← Supabase config (ADD YOUR KEYS HERE)
│   ├── nav.js              ← Shared navbar/footer for public pages
│   ├── admin-common.js     ← Shared utilities for admin pages
│   └── testimonials-data.js← Shared testimonials loader (home + testimonials page)
├── admin/                  ← Admin panel (requires admin login)
│   ├── index.html
│   ├── users.html
│   ├── content.html
│   ├── testimonials.html
│   ├── faqs.html
│   ├── consultations.html
│   └── settings.html
└── supabase_schema.sql     ← Full database schema
```

---

## 🚀 Quick Start (4 Steps)

### Step 1 — Add your Supabase keys
Open `js/supabase.js` and replace:
```javascript
const SUPABASE_URL = 'https://YOUR_PROJECT_ID.supabase.co';
const SUPABASE_ANON_KEY = 'YOUR_ANON_KEY_HERE';
```
Find these at: Supabase → Project Settings → API

### Step 2 — Run the database schema
Go to Supabase → SQL Editor, paste the entire contents of `supabase_schema.sql`, and click Run.

### Step 3 — Upload to GitHub & enable Pages
- Create a GitHub repo, upload all files to the root
- Settings → Pages → Source: main branch / root → Save
- Your site: `https://YOUR_USERNAME.github.io/YOUR_REPO/`

### Step 4 — Create your admin account
Visit: `https://YOUR_SITE/admin-setup.html`
- Enter your name, email, and choose a password
- Enter setup key: **`tinybloom-setup-2024`**
- Click Create — the page locks itself after first use

Then log in at: `https://YOUR_SITE/login.html`

---

## ⚙️ Supabase URL Config (important for password reset)
Go to Supabase → Authentication → URL Configuration:
- **Site URL:** `https://YOUR_USERNAME.github.io/YOUR_REPO`
- **Redirect URLs:** `https://YOUR_USERNAME.github.io/YOUR_REPO/**`

---

## 👥 User Roles
| Role | Access |
|------|--------|
| `admin` | Full admin panel, manage all content and users |
| `free_user` | Basic features via mobile app |
| `premium_user` | All premium features via mobile app |
| `next_of_kin` | View linked user's updates |
| `specialist` | Accept consultations |
| `volunteer` | Offer free advice |

Public visitors (not logged in) can browse the marketing site and register.
Only admins see the login page and admin panel.
