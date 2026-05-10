// js/compendium.js — Fonctions communes aux listes du compendium
'use strict';

// ============================================================
// MENU LIGNE (⋮)
// ============================================================

function compToggleMenu(id) {
  const menu = document.getElementById('comp-menu-' + id);
  if (!menu) return;

  // Ferme tous les autres menus ouverts
  document.querySelectorAll('.comp-menu-dropdown').forEach(m => {
    if (m !== menu) m.classList.add('noDisplay');
  });
  menu.classList.toggle('noDisplay');

  // Ferme au clic extérieur
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
// SUPPRESSION INLINE
// ============================================================

function compDemanderSuppression(id) {
  // Masque la ligne normale, affiche la confirmation
  const row     = document.getElementById('row-' + id);
  const confirm = document.getElementById('comp-confirm-' + id);
  if (!row || !confirm) return;

  // Stocke le contenu original des cellules pour restauration
  row.dataset.backup = row.innerHTML;
  // Vide la ligne et insère la confirmation sur toute la largeur
  const nbCols = row.querySelectorAll('td').length;
  row.innerHTML = `<td colspan="${nbCols}" class="comp-confirm-row">
    ${confirm.innerHTML}
  </td>`;
}

// Ré-initialise en lisant les templates (plus simple : rechargement de la ligne)
function compAnnulerSuppression(id) {
  // Simple : recharge la page pour restaurer l'état (les filtres GET sont préservés)
  window.location.reload();
}

function compConfirmerSuppression(id) {
  const form = document.getElementById('comp-bulk-form');
  if (!form) return;

  document.getElementById('comp-bulk-action-hidden').value = 'supprimer';
  document.getElementById('comp-bulk-ids').innerHTML =
    `<input type="hidden" name="ids[]" value="${id}">`;

  form.submit();
}

// ============================================================
// SÉLECTION MULTIPLE ET BARRE BULK
// ============================================================

document.addEventListener('DOMContentLoaded', () => {
  const selectAll = document.getElementById('comp-select-all');
  const bulkBar   = document.getElementById('comp-bulk-bar');

  if (selectAll) {
    selectAll.addEventListener('change', () => {
      document.querySelectorAll('.comp-check').forEach(cb => {
        cb.checked = selectAll.checked;
      });
      compMajBulkBar();
    });
  }

  // Délégation sur le tbody pour les checkboxes individuelles
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

  // Sync select-all
  const total   = document.querySelectorAll('.comp-check').length;
  const selAll  = document.getElementById('comp-select-all');
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

  // Confirmation pour suppression
  if (action === 'supprimer') {
    if (!confirm(`Supprimer ${checked.length} élément(s) ? Cette action est irréversible.`))
      return;
  }

  // Construit les ids cachés
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
// RAFRAÎCHISSEMENT LISTE (appelé par apresModification)
// ============================================================

function rafraichirListe() {
  window.location.reload();
}

// ============================================================
// SOUMISSION FORMULAIRE SORT (appelé depuis modifier/sort.php)
// ============================================================

function soumettreSort() {
  if (typeof tinymce !== 'undefined') tinymce.triggerSave();

  const form = document.getElementById('form-sort');
  if (!form) return;

  const data   = new FormData(form);
  const params = new URLSearchParams(data);
  // Le token CSRF est déjà dans le formulaire via csrfField()
  // Ne pas l'ajouter une seconde fois (PHP prendrait la dernière valeur)

  fetch(form.getAttribute('action'), {
    method:  'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body:    params.toString(),
  })
  .then(r => r.json())
  .then(data => {
    if (data.ok) {
      apresModification(data);
    } else {
      alert(data.erreur || "Erreur lors de l'enregistrement.");
    }
  })
  .catch(err => alert("Erreur : " + err));
}
