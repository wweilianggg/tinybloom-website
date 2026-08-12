// js/admin-sidebar.js

// Builds the admin sidebar HTML and highlights the current page's link.
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

// Injects the admin sidebar into every admin page on load.
document.addEventListener('DOMContentLoaded', () => {
  const placeholder = document.getElementById('admin-sidebar-placeholder');
  if (placeholder) {
    const page = window.location.pathname.split('/').pop() || 'index.html';
    placeholder.outerHTML = getAdminSidebar(page);
  }
});

// Shows a small popup message at the bottom of the screen for a few seconds.
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

// Logs the admin out and sends them to the login page.
async function adminSignOut() {
  await supabaseClient.auth.signOut();
  window.location.href = '../login.html';
}
