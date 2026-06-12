// js/personnage.js — Interactions du module Personnages.
// Chargé uniquement sur les pages du module ($js_module = 'personnage').
// perUrlDetail / perUrlModifier / perUrlEnreg / perUrlFiche injectés en inline par index.php.
//
// SOUS-PHASE 3.0 : socle — menu contextuel + suppression inline depuis la liste.
// Les éditeurs DOM (classes, compétences, dons, NLS, sorts) seront ajoutés
// dans les sous-phases 3.2 à 3.6.
'use strict';

// ============================================================
// MENU CONTEXTUEL — miroir de campToggleMenu (campagne.js)
// Aucune de ces fonctions n'est chargée sur les pages personnages.
// ============================================================

function perToggleMenu(id) {
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
// SUPPRESSION INLINE PERSONNAGE (depuis la liste index.php)
// ============================================================

function perDemanderSuppression(id) {
  const row     = document.getElementById('per-row-' + id);
  const confirm = document.getElementById('per-confirm-' + id);
  if (!row || !confirm) return;

  row.dataset.backup = row.innerHTML;
  const nbCols = row.querySelectorAll('td').length;
  row.innerHTML = `<td colspan="${nbCols}" class="comp-confirm-row">${confirm.innerHTML}</td>`;
}

async function perConfirmerSuppression(id) {
  try {
    const data = await postAjax(perUrlEnreg, { action: 'supprimerPersonnage', id: id });
    if (data.ok) {
      rafraichirListe();
    } else {
      alert(data.erreur || 'Erreur lors de la suppression.');
      perAnnulerSuppression(id);
    }
  } catch (err) {
    alert('Erreur : ' + err);
    perAnnulerSuppression(id);
  }
}

function perAnnulerSuppression(id) {
  const row = document.getElementById('per-row-' + id);
  if (row && row.dataset.backup) row.innerHTML = row.dataset.backup;
}

// ============================================================
// SUPPRESSION PERSONNAGE depuis la fiche détail (#detail-pp)
// Utilise confirm() natif (pas de ligne à remplacer dans un panel).
// ============================================================

const personnageListe = {
  supprimer(id, nom) {
    const message = 'Supprimer le personnage « ' + nom + ' » ?\n\n'
      + 'Ses classes, compétences, dons et sorts associés seront également supprimés. '
      + 'Cette action est définitive.';
    confirmer(message, async () => {
      try {
        const data = await postAjax(perUrlEnreg, { action: 'supprimerPersonnage', id: id });
        if (data.ok) {
          fermerDetailPP();
          rafraichirListe();
        } else {
          alert(data.erreur || 'Erreur lors de la suppression.');
        }
      } catch (err) {
        alert('Erreur : ' + err);
      }
    });
  },
};
