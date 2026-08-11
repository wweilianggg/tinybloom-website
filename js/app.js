/* TinyBloom — Combined JS Bundle */


/* ===== supabase.js ===== */
// js/supabase.js
const SUPABASE_URL = 'https://yznzzhecpbhqtgozxpfg.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inl6bnp6aGVjcGJocXRnb3p4cGZnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODA3NjE4OTYsImV4cCI6MjA5NjMzNzg5Nn0.TYMMyzzcXcvHyB4dxXF2kz_UdK-zA9zqaNCMK7IgSSk';

const { createClient } = supabase;
const supabaseClient = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

function escapeHtml(value) {
  return String(value ?? '').replace(/[&<>"']/g, char => ({
    '&': '&amp;',
    '<': '&lt;',
    '>': '&gt;',
    '"': '&quot;',
    "'": '&#39;'
  }[char]));
}

function escapeJsString(value) {
  return String(value ?? '').replace(/[\\'"\n\r\u2028\u2029]/g, char => ({
    '\\': '\\\\',
    "'": "\\'",
    '"': '\\"',
    '\n': '\\n',
    '\r': '\\r',
    '\u2028': '\\u2028',
    '\u2029': '\\u2029'
  }[char]));
}

function setText(id, value) {
  const el = document.getElementById(id);
  if (el) el.textContent = value;
}

async function getCurrentUser() {
  try {
    const { data: { user } } = await supabaseClient.auth.getUser();
    return user;
  } catch { return null; }
}

async function getCurrentProfile() {
  try {
    const user = await getCurrentUser();
    if (!user) return null;
    const { data } = await supabaseClient
      .from('profiles').select('*').eq('id', user.id).single();
    return data;
  } catch { return null; }
}

async function signOut() {
  await supabaseClient.auth.signOut();
  const isAdminPage = window.location.pathname.includes('/admin/');
  window.location.href = isAdminPage ? '../login.html' : 'index.html';
}

async function updateNavbar() {
  try {
    const profile = await getCurrentProfile();
    const authLinks = document.getElementById('auth-links');
    const userMenu = document.getElementById('user-menu');
    if (!authLinks || !userMenu) return;
    if (profile && profile.role === 'admin') {
      authLinks.style.display = 'none';
      userMenu.style.display = 'flex';
      const nameEl = document.getElementById('nav-user-name');
      if (nameEl) nameEl.textContent = profile.full_name.split(' ')[0];
    } else {
      authLinks.style.display = 'flex';
      userMenu.style.display = 'none';
    }
  } catch {
    const authLinks = document.getElementById('auth-links');
    const userMenu = document.getElementById('user-menu');
    if (authLinks) authLinks.style.display = 'flex';
    if (userMenu) userMenu.style.display = 'none';
  }
}

async function requireAdmin() {
  try {
    const { data: { user }, error: userError } = await supabaseClient.auth.getUser();
    if (userError || !user) { window.location.href = '../login.html'; return null; }
    const { data: profile } = await supabaseClient.from('profiles').select('*').eq('id', user.id).single();
    if (profile?.role === 'admin') return profile;
    await supabaseClient.auth.signOut();
    window.location.href = '../login.html';
    return null;
  } catch (e) {
    console.error('requireAdmin error:', e);
    return null;
  }
}


/* ===== auth-guard.js ===== */
// js/auth-guard.js
// Prevents back-button from returning to login page after login
// and prevents accessing protected pages after logout

(function () {
  // Add no-store cache headers so pages are never cached
  document.addEventListener('DOMContentLoaded', function () {
    const metas = [
      { httpEquiv: 'Cache-Control', content: 'no-store, no-cache, must-revalidate, max-age=0' },
      { httpEquiv: 'Pragma', content: 'no-cache' },
      { httpEquiv: 'Expires', content: '0' }
    ];
    metas.forEach(m => {
      const el = document.createElement('meta');
      el.httpEquiv = m.httpEquiv;
      el.content = m.content;
      document.head.prepend(el);
    });
  });

  // Handle back button (pageshow fires when page is shown from cache)
  window.addEventListener('pageshow', async function (e) {
    // bfcache (back-forward cache) restoration
    if (e.persisted) {
      const path = window.location.pathname;
      const isAdminPage = path.includes('/admin/');
      const isDownloadPage = path.includes('download.html');
      const isLoginPage = path.includes('login.html');

      try {
        const { data: { user } } = await supabaseClient.auth.getUser();

        if (!user) {
          // Not logged in - kick off protected pages
          if (isAdminPage) { window.location.replace('../login.html'); return; }
          if (isDownloadPage) { window.location.replace('login.html'); return; }
        } else {
          // Logged in - don't allow going back to login page
          if (isLoginPage) {
            const { data: profile } = await supabaseClient.from('profiles').select('role').eq('id', user.id).single();
            const isAdmin = profile?.role === 'admin';
            window.location.replace(isAdmin ? 'admin/index.html' : 'download.html');
          }
        }
      } catch (e) {
        // On error just reload fresh
        if (e.persisted) window.location.reload();
      }
    }
  });
})();


/* ===== nav.js ===== */
// js/nav.js — Injects shared navbar and footer, handles mobile menu and auth state

const NAV_HTML = `
<nav class="navbar">
  <a href="index.html" class="nav-brand">TinyBloom</a>
  <div class="nav-menu" id="nav-menu">
    <ul class="nav-links" id="nav-links">
      <li><a href="index.html" id="nav-home">Home</a></li>
      <li><a href="features.html" id="nav-features">Features</a></li>
      <li><a href="subscriptions.html" id="nav-subscriptions">Subscriptions</a></li>
      <li><a href="testimonials.html" id="nav-testimonials">Testimonials</a></li>
      <li><a href="faq.html" id="nav-faq">FAQ</a></li>
    </ul>
    <div class="nav-auth" id="auth-links">
      <a href="register.html" class="btn btn-primary btn-sm">Register</a>
    </div>
    <div class="nav-user" id="user-menu" style="display:none">
      <span class="nav-user-name" id="nav-user-name"></span>
      <a href="admin/index.html" class="btn btn-outline btn-sm" id="admin-nav-btn">Admin Panel</a>
      <button class="btn btn-ghost btn-sm" onclick="signOut()">Sign Out</button>
    </div>
  </div>
  <div class="hamburger" id="hamburger" onclick="toggleMenu()">
    <span></span><span></span><span></span>
  </div>
</nav>`;

const FOOTER_HTML = `
<footer>
  <div class="footer-grid">
    <div>
      <div class="footer-brand">TinyBloom</div>
      <p class="footer-desc" id="footer-tagline">Personalised pregnancy support for every mother. Better outcomes start with better support.</p>
    </div>
    <div>
      <div class="footer-heading">Platform</div>
      <ul class="footer-links">
        <li><a href="features.html">Features</a></li>
        <li><a href="subscriptions.html">Subscriptions</a></li>
        <li><a href="testimonials.html">Testimonials</a></li>
      </ul>
    </div>
    <div>
      <div class="footer-heading">Support</div>
      <ul class="footer-links">
        <li><a href="faq.html">FAQ</a></li>
        <li><a href="mailto:support@tinybloom.com" id="footer-contact-link">Contact Us</a></li>
      </ul>
    </div>
    <div>
      <div class="footer-heading">Join Us</div>
      <ul class="footer-links">
        <li><a href="register.html">Register Free</a></li>
        <li><a href="register.html?plan=premium_monthly">Go Premium</a></li>
      </ul>
    </div>
  </div>
  <div class="footer-bottom">
    &copy; <span id="footer-year">2026</span> TinyBloom. All rights reserved. &nbsp;|&nbsp; <span id="footer-contact-email">support@tinybloom.com</span>
  </div>
</footer>`;

document.addEventListener('DOMContentLoaded', () => {
  const navPlaceholder = document.getElementById('navbar-placeholder');
  const footerPlaceholder = document.getElementById('footer-placeholder');
  if (navPlaceholder) navPlaceholder.outerHTML = NAV_HTML;
  if (footerPlaceholder) footerPlaceholder.outerHTML = FOOTER_HTML;

  // Highlight active nav link
  const path = window.location.pathname.split('/').pop() || 'index.html';
  const idMap = {
    'index.html': 'nav-home', '': 'nav-home',
    'features.html': 'nav-features',
    'subscriptions.html': 'nav-subscriptions',
    'testimonials.html': 'nav-testimonials',
    'faq.html': 'nav-faq',
  };
  const activeId = idMap[path];
  if (activeId) {
    const el = document.getElementById(activeId);
    if (el) el.classList.add('active');
  }

  if (footerPlaceholder) loadFooterContent();

  updateNavbar();
});

async function loadFooterContent() {
  const yearEl = document.getElementById('footer-year');
  if (yearEl) yearEl.textContent = new Date().getFullYear();

  try {
    const { data } = await supabaseClient.from('site_settings').select('setting_key,setting_value')
      .in('setting_key', ['footer_tagline', 'contact_email']);
    const s = {};
    if (data) data.forEach(r => { s[r.setting_key] = r.setting_value; });

    if (s.footer_tagline) {
      const el = document.getElementById('footer-tagline');
      if (el) el.textContent = s.footer_tagline;
    }
    if (s.contact_email) {
      const emailEl = document.getElementById('footer-contact-email');
      if (emailEl) emailEl.textContent = s.contact_email;
      const linkEl = document.getElementById('footer-contact-link');
      if (linkEl) linkEl.href = 'mailto:' + s.contact_email;
    }
  } catch (e) {}
}

function toggleMenu() {
  const menu = document.getElementById('nav-menu');
  if (menu) menu.classList.toggle('open');
}

// Toast utility
function showToast(message, type = '') {
  let toast = document.getElementById('toast');
  if (!toast) {
    toast = document.createElement('div');
    toast.id = 'toast';
    toast.className = 'toast';
    document.body.appendChild(toast);
  }
  toast.textContent = message;
  toast.className = `toast ${type}`;
  setTimeout(() => toast.classList.add('show'), 10);
  setTimeout(() => toast.classList.remove('show'), 3500);
}


/* ===== testimonials-data.js ===== */
// js/testimonials-data.js
// Single source of truth for seeded testimonials shown on both Home and Testimonials pages.
// These match exactly what is inserted into the database via supabase_schema.sql.

const SEED_TESTIMONIALS = [
  {
    reviewer_name: 'Sarah K.',
    review_date: '2026-03-12',
    content: 'This app really helped me stay on track with my pregnancy. The weekly updates and symptom tracking made me feel more prepared and less anxious throughout my journey.',
    rating: 5
  },
  {
    reviewer_name: 'Michael L.',
    review_date: '2026-04-16',
    content: 'I love how easy it is to find reliable information. The articles and tips are simple to understand, and I always feel more confident after reading them.',
    rating: 5
  },
  {
    reviewer_name: 'Lauren M.',
    review_date: '2026-05-10',
    content: 'The personalised tracking feature is so helpful. It feels like the app understands what stage I\'m in and gives me the right guidance at the right time.',
    rating: 5
  }
];

function renderTestimonialCard(t) {
  const dateStr = new Date(t.review_date).toLocaleDateString('en-GB', { day: 'numeric', month: 'long', year: 'numeric' });
  const avatarUrl = t.reviewer_image_url
    || `https://api.dicebear.com/7.x/personas/svg?seed=${encodeURIComponent(t.reviewer_name)}`;
  const safeName = escapeHtml(t.reviewer_name);
  const safeContent = escapeHtml(t.content);
  const safeAvatarUrl = escapeHtml(avatarUrl);
  const safeAvatarFallback = escapeJsString(`https://api.dicebear.com/7.x/initials/svg?seed=${encodeURIComponent(t.reviewer_name)}`);
  const rating = Math.max(0, Math.min(5, Number(t.rating) || 0));
  return `
    <div class="testimonial-card">
      <img src="${safeAvatarUrl}" alt="${safeName}" class="testimonial-avatar"
           onerror="this.src='${safeAvatarFallback}'">
      <div class="testimonial-name">${safeName}</div>
      <div class="testimonial-date">${dateStr}</div>
      <p class="testimonial-text">${safeContent}</p>
      <div class="stars">${'★'.repeat(rating)}${'☆'.repeat(5 - rating)}</div>
    </div>`;
}

// Load from DB, fall back to seeds if DB unreachable or empty
async function loadTestimonialsInto(containerId, limit = null) {
  const container = document.getElementById(containerId);
  if (!container) return;
  try {
    let query = supabaseClient
      .from('testimonials')
      .select('*')
      .eq('is_published', true)
      .order('review_date', { ascending: false });
    if (limit) query = query.limit(limit);
    const { data } = await query;
    if (data && data.length > 0) {
      container.innerHTML = data.map(renderTestimonialCard).join('');
    } else {
      const items = limit ? SEED_TESTIMONIALS.slice(0, limit) : SEED_TESTIMONIALS;
      container.innerHTML = items.map(renderTestimonialCard).join('');
    }
  } catch {
    const items = limit ? SEED_TESTIMONIALS.slice(0, limit) : SEED_TESTIMONIALS;
    container.innerHTML = items.map(renderTestimonialCard).join('');
  }
}

// Load from DB (most recent first) showing pageSize at a time, with a button to reveal more.
async function loadPaginatedTestimonialsInto(containerId, buttonId, pageSize = 9) {
  const container = document.getElementById(containerId);
  const button = document.getElementById(buttonId);
  if (!container) return;

  let allItems = SEED_TESTIMONIALS;
  try {
    const { data } = await supabaseClient
      .from('testimonials')
      .select('*')
      .eq('is_published', true)
      .order('review_date', { ascending: false });
    if (data && data.length > 0) allItems = data;
  } catch { }

  let shown = 0;
  function renderNextPage() {
    const next = allItems.slice(shown, shown + pageSize);
    container.insertAdjacentHTML('beforeend', next.map(renderTestimonialCard).join(''));
    shown += next.length;
    if (button) button.style.display = shown < allItems.length ? 'inline-block' : 'none';
  }

  container.innerHTML = '';
  renderNextPage();
  if (button) button.onclick = renderNextPage;
}


/* ===== admin-sidebar.js ===== */
// js/admin-sidebar.js

function getAdminSidebar(activePage) {
  const pages = [
    { href: 'index.html', icon: '📊', label: 'Dashboard' },
    { href: 'users.html', icon: '👥', label: 'Users' },
    { href: 'applications.html', icon: '📋', label: 'Manage Applications' },
    { divider: true, label: 'PAGE CONTENT' },
    { href: 'page-home.html', icon: '🏠', label: 'Home' },
    { href: 'page-features.html', icon: '✨', label: 'Features' },
    { href: 'page-subscriptions.html', icon: '💰', label: 'Subscriptions' },
    { href: 'page-testimonials.html', icon: '⭐', label: 'Testimonials' },
    { href: 'page-faq.html', icon: '❓', label: 'FAQ' },
    { href: 'page-download.html', icon: '📲', label: 'Download' },
    { divider: true, label: 'APP CONTENT' },
    { href: 'app-logs.html', icon: '📔', label: 'Logs' },
    { divider: true, label: 'SPECIALIST LISTS' },
    { href: 'list-specializations.html', icon: '🩺', label: 'Specialization' },
    { href: 'list-hospitals.html', icon: '🏥', label: 'Hospitals / Clinics' },
    { href: 'list-qualifications.html', icon: '🎓', label: 'Medical Qualifications' },
    { divider: true, label: 'VOLUNTEER LISTS' },
    { href: 'list-expertise.html', icon: '🤝', label: 'Area of Expertise' },
    { href: 'list-organisations.html', icon: '🏢', label: 'Organisations' },
    // { divider: true, label: 'MANAGE' },
    // { href: 'content.html', icon: '📝', label: 'Articles' },
  ];

  const links = pages.map(p => {
    if (p.divider) return `<li style="padding:1rem 0.75rem 0.35rem;font-size:0.68rem;font-weight:700;color:rgba(255,255,255,0.3);text-transform:uppercase;letter-spacing:0.1em">${p.label}</li>`;
    return `<li><a href="${p.href}" ${p.href === activePage ? 'class="active"' : ''}>${p.icon} ${p.label}</a></li>`;
  }).join('');

  return `
  <div class="admin-sidebar">
    <div style="font-family:'Playfair Display',serif;font-size:1.4rem;color:var(--rose);padding:0 0.75rem;margin-bottom:0.25rem;font-weight:700">TinyBloom</div>
    <div style="font-size:0.75rem;font-weight:700;color:rgba(255,255,255,0.45);text-transform:uppercase;letter-spacing:0.1em;padding:0 0.75rem;margin-bottom:1.25rem">Admin Panel</div>
    <ul class="admin-nav">
      ${links}
      <li style="margin-top:2rem"><a href="../index.html">← Back to Site</a></li>
      <li><a href="#" onclick="adminSignOut();return false;">🚪 Sign Out</a></li>
    </ul>
  </div>`;
}

document.addEventListener('DOMContentLoaded', () => {
  const placeholder = document.getElementById('admin-sidebar-placeholder');
  if (placeholder) {
    const page = window.location.pathname.split('/').pop() || 'index.html';
    placeholder.outerHTML = getAdminSidebar(page);
  }
});

function showToast(message, type = '') {
  let toast = document.getElementById('toast');
  if (!toast) {
    toast = document.createElement('div');
    toast.id = 'toast';
    toast.className = 'toast';
    document.body.appendChild(toast);
  }
  toast.textContent = message;
  toast.className = `toast ${type}`;
  setTimeout(() => toast.classList.add('show'), 10);
  setTimeout(() => toast.classList.remove('show'), 3500);
}

async function adminSignOut() {
  await supabaseClient.auth.signOut();
  window.location.href = '../login.html';
}


/* ===== admin-common.js ===== */
// js/admin-common.js — shared utilities for admin pages

function showToast(message, type = '') {
  let toast = document.getElementById('toast');
  if (!toast) {
    toast = document.createElement('div');
    toast.id = 'toast';
    toast.className = 'toast';
    document.body.appendChild(toast);
  }
  toast.textContent = message;
  toast.className = `toast ${type}`;
  setTimeout(() => toast.classList.add('show'), 10);
  setTimeout(() => toast.classList.remove('show'), 3500);
}

async function adminSignOut() {
  await supabaseClient.auth.signOut();
  window.location.href = '../login.html';
}

