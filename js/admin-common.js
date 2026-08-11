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

// Reusable in-page confirmation modal — replaces the native browser confirm()
// popup used across the admin pages. Injects its own markup into <body> on
// first use, so any admin page can call it with no extra HTML required.
// Usage: if (!await showConfirm('Delete this item?')) return;
//        if (!await showConfirm('Delete this item?', { title: 'Delete Qualification', confirmLabel: 'Delete' })) return;
let __confirmModalResolve = null;
function showConfirm(message, options = {}) {
  const title = options.title || 'Confirm';
  const confirmLabel = options.confirmLabel || 'Confirm';
  const danger = options.danger !== false;

  let modal = document.getElementById('__confirm-modal');
  if (!modal) {
    modal = document.createElement('div');
    modal.id = '__confirm-modal';
    modal.style.cssText = 'display:none;position:fixed;inset:0;background:rgba(44,36,32,0.4);z-index:10000;align-items:center;justify-content:center';
    modal.innerHTML = `
      <div class="card" style="width:420px;max-width:90%">
        <h3 style="font-family:'Playfair Display',serif;font-size:1.15rem;margin-bottom:0.75rem" id="__confirm-title">Confirm</h3>
        <p style="font-size:0.9rem;color:var(--text-mid);margin-bottom:1.5rem" id="__confirm-message"></p>
        <div style="display:flex;justify-content:flex-end;gap:0.75rem">
          <button class="btn btn-ghost" id="__confirm-cancel-btn">Cancel</button>
          <button class="btn btn-primary" id="__confirm-ok-btn">Confirm</button>
        </div>
      </div>`;
    document.body.appendChild(modal);
    modal.addEventListener('click', e => { if (e.target === modal) closeConfirmModal(false); });
    document.getElementById('__confirm-cancel-btn').onclick = () => closeConfirmModal(false);
    document.getElementById('__confirm-ok-btn').onclick = () => closeConfirmModal(true);
  }

  document.getElementById('__confirm-title').textContent = title;
  document.getElementById('__confirm-message').textContent = message;
  const okBtn = document.getElementById('__confirm-ok-btn');
  okBtn.textContent = confirmLabel;
  okBtn.style.background = danger ? '#c0392b' : '';
  okBtn.style.borderColor = danger ? '#c0392b' : '';

  modal.style.display = 'flex';
  return new Promise(resolve => { __confirmModalResolve = resolve; });
}
function closeConfirmModal(result) {
  const modal = document.getElementById('__confirm-modal');
  if (modal) modal.style.display = 'none';
  if (__confirmModalResolve) { __confirmModalResolve(result); __confirmModalResolve = null; }
}
