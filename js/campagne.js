// js/campagne.js — Interactions du module Campagnes.
// Chargé uniquement sur les pages du module ($js_module = 'campagne').
// campUrlModifier / campUrlEnreg injectés en inline par chaque page.
//
// SP-CP : le module a quitté #detail-pp pour une navigation pleine page
// (campagnes/campagne.php, scenario.php, chapitre.php, rencontre.php). Toutes
// les écritures se concluent donc par un rechargement de la page courante —
// et non plus par un rechargement de panneau. Une seule règle, valable partout :
// on reste sur la page d'où l'action est partie.
'use strict';

// ============================================================
// NAVIGATION — lignes cliquables (tr[data-href])
// ============================================================
// Les cellules de données mènent à la page de l'élément. Un vrai lien reste
// posé sur le nom (clic milieu, copie d'adresse, clavier) ; ce handler étend
// simplement la zone cliquable au reste de la ligne. Les zones interactives
// (poignée de tri, menu ⋮, boutons, liens) sont exclues — sans quoi ouvrir le
// menu d'actions déclencherait une navigation.

document.addEventListener('click', function (e) {
  const ligne = e.target.closest('tr[data-href]');
  if (!ligne) return;
  if (e.target.closest('a, button, input, .col-action, .tri-poignee')) return;
  window.location.href = ligne.dataset.href;
});

// ============================================================
// COLONNE D'OUTILS — repli sous 992px
// ============================================================
// Desktop : la colonne est toujours dépliée (le bouton est masqué en CSS).
// Sous 992px elle est repliée par défaut et ce bouton la déplie.

function campToggleOutils(btn) {
  const aside = btn.closest('.camp-page__outils');
  if (!aside) return;
  const ouvert = aside.classList.toggle('est-ouvert');
  btn.setAttribute('aria-expanded', ouvert ? 'true' : 'false');
}

// ============================================================
// MENU CONTEXTUEL — miroir de compToggleMenu (compendium.js)
// compToggleMenu n'est pas chargé sur les pages campagnes.
// ============================================================

function campToggleMenu(id) {
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
// SUPPRESSION INLINE CAMPAGNE (depuis la liste index.php)
// ============================================================

function campDemanderSuppression(id) {
  const row     = document.getElementById('camp-row-' + id);
  const confirm = document.getElementById('camp-confirm-' + id);
  if (!row || !confirm) return;

  row.dataset.backup = row.innerHTML;
  const nbCols = row.querySelectorAll('td').length;
  row.innerHTML = `<td colspan="${nbCols}" class="comp-confirm-row">${confirm.innerHTML}</td>`;
}

async function campConfirmerSuppression(id) {
  try {
    const data = await postAjax(campUrlEnreg, { action: 'supprimerCampagne', id: id });
    if (data.ok) {
      rafraichirListe();
    } else {
      alert(data.erreur || 'Erreur lors de la suppression.');
      campAnnulerSuppression(id);
    }
  } catch (err) {
    alert('Erreur : ' + err);
    campAnnulerSuppression(id);
  }
}

function campAnnulerSuppression(id) {
  const row = document.getElementById('camp-row-' + id);
  if (row && row.dataset.backup) row.innerHTML = row.dataset.backup;
}

// ============================================================
// SUPPRESSION INLINE DES SOUS-NIVEAUX
// ============================================================
// Scénario, chapitre, rencontre : mêmes gestes, mêmes conventions de nommage
// (#camp-{prefixe}-row-{id} / #camp-{prefixe}-confirm-{id}), d'où une fabrique
// plutôt que quatre triplets de fonctions recopiés. La suppression part
// toujours de la liste de la page PARENTE : un rechargement suffit, l'élément
// disparaît de la liste et on reste où l'on était (SP-CP).

function _campFabriqueSuppression(prefixe, action) {
  const idLigne  = (id) => 'camp-' + prefixe + '-row-' + id;
  const idConfirm = (id) => 'camp-' + prefixe + '-confirm-' + id;

  // Remplace la ligne par sa demande de confirmation, en gardant de quoi la
  // rétablir si l'utilisateur renonce.
  function demander(id) {
    const row     = document.getElementById(idLigne(id));
    const confirm = document.getElementById(idConfirm(id));
    if (!row || !confirm) return;

    row.dataset.backup = row.innerHTML;
    const nbCols = row.querySelectorAll('td').length;
    row.innerHTML = `<td colspan="${nbCols}" class="comp-confirm-row">${confirm.innerHTML}</td>`;
  }

  function annuler(id) {
    const row = document.getElementById(idLigne(id));
    if (row && row.dataset.backup) row.innerHTML = row.dataset.backup;
  }

  async function confirmer(id) {
    try {
      const data = await postAjax(campUrlEnreg, { action: action, id: id });
      if (data.ok) {
        window.location.reload();
      } else {
        alert(data.erreur || 'Erreur lors de la suppression.');
        annuler(id);
      }
    } catch (err) {
      alert('Erreur : ' + err);
      annuler(id);
    }
  }

  return { demander, confirmer, annuler };
}

const _campSuppSce = _campFabriqueSuppression('sce', 'supprimerScenario');
const _campSuppScc = _campFabriqueSuppression('scc', 'supprimerChapitre');
const _campSuppRe  = _campFabriqueSuppression('re',  'supprimerRencontre');

function campSceDemanderSuppression(id)  { _campSuppSce.demander(id); }
function campSceConfirmerSuppression(id) { _campSuppSce.confirmer(id); }
function campSceAnnulerSuppression(id)   { _campSuppSce.annuler(id); }

function campSccDemanderSuppression(id)  { _campSuppScc.demander(id); }
function campSccConfirmerSuppression(id) { _campSuppScc.confirmer(id); }
function campSccAnnulerSuppression(id)   { _campSuppScc.annuler(id); }

function campReDemanderSuppression(id)   { _campSuppRe.demander(id); }
function campReConfirmerSuppression(id)  { _campSuppRe.confirmer(id); }
function campReAnnulerSuppression(id)    { _campSuppRe.annuler(id); }

// ============================================================
// SUPPRESSION OPPOSITION (page rencontre)
// ============================================================
// Les oppositions ne sont plus des lignes de tableau mais des cartes dépliées
// (SP-CP) : pas de ligne à remplacer par une demande de confirmation inline,
// d'où confirm() natif — comme le faisait déjà la fiche en sous-panneau.

function campOppDemanderSuppression(oppId) {
  confirmer('Supprimer cette opposition ?', async () => {
    try {
      const data = await postAjax(campUrlEnreg, { action: 'supprimerOpposition', id: oppId });
      if (data.ok) {
        window.location.reload();
      } else {
        alert(data.erreur || 'Erreur lors de la suppression.');
      }
    } catch (err) {
      alert('Erreur : ' + err);
    }
  });
}

// ============================================================
// SUPPRESSION CAMPAGNE depuis sa page
// ============================================================
// Seul cas où l'on ne recharge pas : la page supprimée n'existe plus, on
// remonte à la liste.

const campagneListe = {
  supprimer(id, nom) {
    const message = 'Supprimer la campagne « ' + nom + ' » ?\n\n'
      + 'Ses scénarios, rencontres et oppositions seront également supprimés. '
      + 'Cette action est définitive.';
    confirmer(message, async () => {
      try {
        const data = await postAjax(campUrlEnreg, { action: 'supprimerCampagne', id: id });
        if (data.ok) {
          window.location.href = BASE_URL + '/campagnes/index.php';
        } else {
          alert(data.erreur || 'Erreur lors de la suppression.');
        }
      } catch (err) {
        alert('Erreur : ' + err);
      }
    });
  },
};

// ============================================================
// TRANSFÉRER / DUPLIQUER UNE OPPOSITION — popup contextuel
// SP-T0 (2026-06-21) : limité à une autre rencontre de la MÊME campagne.
// SP-T1 (planifié, non codé) : extension vers une rencontre d'une autre
// campagne — cf. ARCHITECTURE_0_REFERENCE.md § Plan Transfert/Duplication
// d'opposition (SP-T). Le footer du popup réserve déjà la place pour cette
// évolution (texte d'intention, non cliquable).
// ============================================================

let _transfertOppId  = null;
let _transfertAction = null; // 'transferer' | 'dupliquer'

function _campEsc(s) {
  const d = document.createElement('div');
  d.textContent = s == null ? '' : String(s);
  return d.innerHTML;
}

function campOppOuvrirTransfertPopup(event, oppId, currentReId, campId, action) {
  const popup = document.getElementById('camp-transfer-popup');
  const titre = document.getElementById('camp-transfer-popup-titre');
  const body  = document.getElementById('camp-transfer-popup-body');
  if (!popup || !titre || !body) return;

  _transfertOppId  = oppId;
  _transfertAction = action;

  titre.textContent = action === 'transferer' ? 'Transférer vers…' : 'Dupliquer vers…';
  body.innerHTML = '<p class="camp-transfer-popup__msg">Chargement…</p>';

  // Position : près du point de clic, en position:fixed (viewport).
  // On utilise event.clientX/Y (coordonnées viewport du clic) plutôt que
  // getBoundingClientRect() du bouton, parce que campToggleMenu() (appelé
  // dans le même onclick, avant cette fonction) masque le menu déroulant
  // (display:none via noDisplay) AVANT que le JS de positionnement s'exécute :
  // le bouton "Transférer/Dupliquer" est alors non-rendu, getBoundingClientRect()
  // retourne {top:0,left:0,...} → popup calé en coin (bug constaté 2026-06-21).
  // clientX/Y proviennent de l'objet event AVANT que le DOM change — toujours
  // fiables. Décalage de +4px vers le bas, aligné à gauche du point de clic.
  const cx = event.clientX;
  const cy = event.clientY;
  const vw = window.innerWidth;
  const vh = window.innerHeight;
  popup.style.position = 'fixed';
  // Calcul provisoire pour mesurer la largeur réelle du popup
  popup.style.top  = '-9999px';
  popup.style.left = '-9999px';
  popup.hidden = false;
  const pw = popup.offsetWidth  || 260;
  const ph = popup.offsetHeight || 200;
  // Repositionner : rester dans le viewport (marge 8px)
  const top  = Math.min(cy + 4,  vh - ph - 8);
  const left = Math.max(8, Math.min(cx, vw - pw - 8));
  popup.style.top  = top  + 'px';
  popup.style.left = left + 'px';

  let url = BASE_URL + '/include/ajax/liste-rencontres-campagne.php?camp_id=' + campId;
  if (action === 'transferer') url += '&exclude_re_id=' + currentReId;

  fetch(url)
    .then(r => r.json())
    .then(data => {
      if (!data.groupes || data.groupes.length === 0) {
        body.innerHTML = '<p class="camp-transfer-popup__msg">Aucune autre rencontre disponible.</p>';
        return;
      }
      let html = '';
      data.groupes.forEach(g => {
        html += '<div class="camp-transfer-popup__groupe">' + _campEsc(g.sce_nom)
              + ' › ' + _campEsc(g.scc_nom) + '</div>';
        g.rencontres.forEach(r => {
          const code = r.re_code
            ? ' <span class="text-muted">[' + _campEsc(r.re_code) + ']</span>'
            : '';
          html += '<button type="button" class="camp-transfer-popup__item" '
                + 'onclick="campOppConfirmerTransfert(' + r.re_id + ')">'
                + _campEsc(r.re_nom) + code + '</button>';
        });
      });
      body.innerHTML = html;
    })
    .catch(() => {
      body.innerHTML = '<p class="camp-transfer-popup__msg erreur">Erreur de chargement.</p>';
    });

  // Fermeture au clic extérieur — enregistrement différé (même pattern que
  // campToggleMenu()) pour ne pas capter le clic qui vient d'ouvrir le popup.
  setTimeout(() => {
    document.addEventListener('click', function handler(e) {
      if (!popup.contains(e.target)) {
        campFermerTransfertPopup();
        document.removeEventListener('click', handler);
      }
    });
  }, 0);
}

function campOppConfirmerTransfert(destReId) {
  if (!_transfertOppId || !_transfertAction) return;
  const action = _transfertAction === 'transferer' ? 'transfererOpposition' : 'dupliquerOpposition';
  postAjax(campUrlEnreg, { action: action, opp_id: _transfertOppId, dest_re_id: destReId })
    .then(data => {
      campFermerTransfertPopup();
      if (data.ok) {
        window.location.reload();
      } else {
        alert(data.erreur || 'Erreur.');
      }
    })
    .catch(err => { campFermerTransfertPopup(); alert('Erreur : ' + err); });
}

function campFermerTransfertPopup() {
  const popup = document.getElementById('camp-transfer-popup');
  if (popup) { popup.hidden = true; popup.querySelector('#camp-transfer-popup-body').innerHTML = ''; }
  _transfertOppId  = null;
  _transfertAction = null;
}
