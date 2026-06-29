// js/auth-guard.js
// Prevents back-button from returning to login page after login
// and prevents accessing protected pages after logout

(function() {
  // Add no-store cache headers so pages are never cached
  document.addEventListener('DOMContentLoaded', function() {
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
  window.addEventListener('pageshow', async function(e) {
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
      } catch(e) {
        // On error just reload fresh
        if (e.persisted) window.location.reload();
      }
    }
  });
})();
