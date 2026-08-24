// js/admin.js — Fonctions communes à la zone d'administration
// Action de suppression injectable depuis admin-liste.php via compSupprimerAction
'use strict';

// ============================================================
// MENU LIGNE, SUPPRESSION INLINE, BARRE BULK, rafraichirListe()
// Promus dans js/main.js le 2026-08-22 (SP-RS6b) — une seule implémentation
// pour les listes du compendium, des règles, de l'administration et des
// personnages. compSupprimerAction reste injecté par admin-liste.php.
// ============================================================


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
