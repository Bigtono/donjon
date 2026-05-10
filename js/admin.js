// js/admin.js — Fonctions communes à la zone d'administration
// Action de suppression injectable depuis admin-liste.php via compSupprimerAction
'use strict';

// ============================================================
// MENU LIGNE (⋮) — identique à compendium.js
// ============================================================

function compToggleMenu(id) {
  const menu = document.getElementById('comp-menu-' + id);
  if (!menu) return;

  document.querySelectorAll('.comp-menu-dropdown').forEach(m => {
    if (m !== menu) m.classList.add('noDisplay');
  });
  menu.classList.toggle('noDisplay');

  if (!menu.classList.contains('noDisplay')) {
    setTimeout(() => {
      document.addEventListener('click', function handler(e) {
        if (!menu.contains(e.target)) {
          menu.classList.add('noDisplay');
          document.removeEventListener('click', handler);
        }
      });
    }, 0);
  }
}

// ============================================================
// SUPPRESSION / DÉSACTIVATION INLINE
// ============================================================

function compDemanderSuppression(id) {
  const row     = document.getElementById('row-' + id);
  const confirm = document.getElementById('comp-confirm-' + id);
  if (!row || !confirm) return;

  const nbCols = row.querySelectorAll('td').length;
  row.dataset.backup = row.innerHTML;
  row.innerHTML = `<td colspan="${nbCols}" class="comp-confirm-row">
    ${confirm.innerHTML}
  </td>`;
}

function compAnnulerSuppression(id) {
  window.location.reload();
}

function compConfirmerSuppression(id) {
  const form   = document.getElementById('comp-bulk-form');
  if (!form) return;

  // compSupprimerAction est injecté par admin-liste.php
  const action = (typeof compSupprimerAction !== 'undefined')
    ? compSupprimerAction
    : 'supprimer';

  document.getElementById('comp-bulk-action-hidden').value = action;
  document.getElementById('comp-bulk-ids').innerHTML =
    `<input type="hidden" name="ids[]" value="${id}">`;
  form.submit();
}

// ============================================================
// ACTION RÉACTIVER — depuis detail-pp ou menu ligne
// ============================================================

function adminReactiver(id) {
  const form = document.getElementById('comp-bulk-form');
  if (!form) return;

  document.getElementById('comp-bulk-action-hidden').value = 'reactiver';
  document.getElementById('comp-bulk-ids').innerHTML =
    `<input type="hidden" name="ids[]" value="${id}">`;
  form.submit();
}

// Appelé depuis les boutons dans detail-pp/utilisateur.php
function adminChangerVisibilite(id, action) {
  const form = document.getElementById('comp-bulk-form');
  if (!form) {
    // Si le formulaire n'est pas dans la page courante, rebuild via fetch
    _adminActionDirecte(id, action);
    return;
  }
  document.getElementById('comp-bulk-action-hidden').value = action;
  document.getElementById('comp-bulk-ids').innerHTML =
    `<input type="hidden" name="ids[]" value="${id}">`;
  form.submit();
}

// Action depuis le panel detail-pp (pas de formulaire bulk dans la page)
function _adminActionDirecte(id, action) {
  const csrfToken = getCsrfToken();
  const entite    = (typeof compEntite !== 'undefined') ? compEntite : 'utilisateur';
  const urlEnreg  = (typeof compUrlEnreg !== 'undefined') ? compUrlEnreg : '';

  const formData = new FormData();
  formData.append('csrf_token', csrfToken);
  formData.append('entite', entite);
  formData.append('action', action);
  formData.append('ids[]', id);

  fetch(urlEnreg + '?ajax=1', { method: 'POST', body: formData })
    .then(r => r.json())
    .then(data => {
      if (data.ok) {
        rafraichirListe();
        // Rafraîchit le detail-pp avec le nouveau statut
        if (data.id && compUrlDetail) {
          actualiserPage(compUrlDetail, { id: data.id }, _detailPpContext);
        }
      } else {
        alert(data.erreur || 'Erreur lors de l\'opération.');
      }
    })
    .catch(err => alert('Erreur : ' + err));
}

// ============================================================
// SÉLECTION MULTIPLE ET BARRE BULK
// ============================================================

document.addEventListener('DOMContentLoaded', () => {
  const selectAll = document.getElementById('comp-select-all');
  if (selectAll) {
    selectAll.addEventListener('change', () => {
      document.querySelectorAll('.comp-check').forEach(cb => {
        cb.checked = selectAll.checked;
      });
      compMajBulkBar();
    });
  }

  document.addEventListener('change', e => {
    if (e.target.classList.contains('comp-check')) compMajBulkBar();
  });
});

function compMajBulkBar() {
  const checked = document.querySelectorAll('.comp-check:checked');
  const bulkBar = document.getElementById('comp-bulk-bar');
  const counter = document.getElementById('comp-bulk-count');

  if (!bulkBar) return;
  bulkBar.style.display = checked.length > 0 ? 'flex' : 'none';
  if (counter) counter.textContent = checked.length;

  const total  = document.querySelectorAll('.comp-check').length;
  const selAll = document.getElementById('comp-select-all');
  if (selAll) selAll.checked = checked.length === total && total > 0;
}

function compDeselectionnerTout() {
  document.querySelectorAll('.comp-check, #comp-select-all').forEach(cb => {
    cb.checked = false;
  });
  compMajBulkBar();
}

function compSoumettreAction() {
  const action = document.getElementById('comp-bulk-action')?.value;
  if (!action) {
    alert('Choisissez une action.');
    return;
  }
  const checked = document.querySelectorAll('.comp-check:checked');
  if (checked.length === 0) {
    alert('Sélectionnez au moins un élément.');
    return;
  }
  if (!confirm(`Appliquer "${action}" sur ${checked.length} élément(s) ?`)) return;

  const container = document.getElementById('comp-bulk-ids');
  container.innerHTML = '';
  checked.forEach(cb => {
    const input = document.createElement('input');
    input.type  = 'hidden';
    input.name  = 'ids[]';
    input.value = cb.dataset.id;
    container.appendChild(input);
  });

  document.getElementById('comp-bulk-action-hidden').value = action;
  document.getElementById('comp-bulk-form').submit();
}

// ============================================================
// RAFRAÎCHISSEMENT LISTE
// ============================================================

function rafraichirListe() {
  window.location.reload();
}

// ============================================================
// SOUMISSION FORMULAIRE UTILISATEUR
// ============================================================

function soumettreUtilisateur() {
  const form = document.getElementById('form-utilisateur');
  if (!form) return;

  fetch(form.getAttribute('action'), {
    method: 'POST',
    body:   new FormData(form),
  })
    .then(r => r.json())
    .then(data => {
      if (data.ok) {
        apresModification(data);
      } else {
        alert(data.erreur || 'Erreur lors de l\'enregistrement.');
      }
    })
    .catch(err => alert('Erreur : ' + err));
}

// ============================================================
// SOUMISSION FORMULAIRE RESSOURCE
// ============================================================

function soumettreRessource() {
  const form = document.getElementById('form-ressource');
  if (!form) return;

  // Synchronise TinyMCE avant la collecte FormData
  if (typeof tinymce !== 'undefined') {
    const editor = tinymce.get('res_description');
    if (editor) {
      document.getElementById('res_description').value = editor.getContent();
    }
  }

  fetch(form.getAttribute('action'), {
    method: 'POST',
    body:   new FormData(form),
  })
    .then(r => r.json())
    .then(data => {
      if (data.ok) {
        apresModification(data);
      } else {
        alert(data.erreur || 'Erreur lors de l\'enregistrement.');
      }
    })
    .catch(err => alert('Erreur : ' + err));
}
