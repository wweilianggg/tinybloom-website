// js/supabase.js
const SUPABASE_URL = 'https://yznzzhecpbhqtgozxpfg.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inl6bnp6aGVjcGJocXRnb3p4cGZnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODA3NjE4OTYsImV4cCI6MjA5NjMzNzg5Nn0.TYMMyzzcXcvHyB4dxXF2kz_UdK-zA9zqaNCMK7IgSSk';

const { createClient } = supabase;
const supabaseClient = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

// Show/hide password toggle used on login/register/reset-password fields.
// Expects the eye-icon <svg> to have id `${inputId}-eye` and (optionally)
// the toggle <button> to have id `${inputId}-toggle`, matching the markup
// pattern used wherever this is wired up.
function togglePasswordVisibility(inputId) {
  const input = document.getElementById(inputId);
  const icon = document.getElementById(inputId + '-eye');
  if (!input || !icon) return;
  const showing = input.type === 'text';
  input.type = showing ? 'password' : 'text';
  icon.innerHTML = showing
    ? '<path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path><circle cx="12" cy="12" r="3"></circle>'
    : '<path d="M17.94 17.94A10.94 10.94 0 0 1 12 20c-7 0-11-8-11-8a20.3 20.3 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a20.29 20.29 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"></path><line x1="1" y1="1" x2="23" y2="23"></line>';
  const btn = document.getElementById(inputId + '-toggle');
  if (btn) btn.setAttribute('aria-label', showing ? 'Show password' : 'Hide password');
}

// Returns the logged-in Supabase user, or null if nobody's logged in.
async function getCurrentUser() {
  try {
    const { data: { user } } = await supabaseClient.auth.getUser();
    return user;
  } catch { return null; }
}

// Returns the logged-in user's row from the profiles table, or null.
async function getCurrentProfile() {
  try {
    const user = await getCurrentUser();
    if (!user) return null;
    const { data } = await supabaseClient
      .from('profiles').select('*').eq('id', user.id).single();
    return data;
  } catch { return null; }
}

// Logs the user out and sends them back to the login page (or home page for public pages).
async function signOut() {
  await supabaseClient.auth.signOut();
  const isAdminPage = window.location.pathname.includes('/admin/');
  window.location.href = isAdminPage ? '../login.html' : 'index.html';
}

// Shows the "Sign Out" menu for logged-in admins, or the "Register" button for everyone else.
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

// Called at the top of every admin page: sends non-admins back to login, and
// returns the admin's profile if the check passes.
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
