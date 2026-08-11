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
