// js/campagne.js — Interactions du module Campagnes.
// Chargé uniquement sur les pages du module ($js_module = 'campagne').
// campUrlDetail / campUrlModifier / campUrlEnreg injectés en inline par index.php.
'use strict';

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
// SUPPRESSION INLINE SCÉNARIO (depuis detail-pp — vue campagne)
// ============================================================

function campSceDemanderSuppression(sceId, campId) {
  const row     = document.getElementById('camp-sce-row-' + sceId);
  const confirm = document.getElementById('camp-sce-confirm-' + sceId);
  if (!row || !confirm) return;

  row.dataset.backup = row.innerHTML;
  row.dataset.campId = campId;
  const nbCols = row.querySelectorAll('td').length;
  row.innerHTML = `<td colspan="${nbCols}" class="comp-confirm-row">${confirm.innerHTML}</td>`;
}

async function campSceConfirmerSuppression(sceId) {
  const row    = document.getElementById('camp-sce-row-' + sceId);
  const campId = parseInt(row ? row.dataset.campId : 0);
  try {
    const data = await postAjax(campUrlEnreg, { action: 'supprimerScenario', id: sceId });
    if (data.ok) {
      // Retour à la racine de la pile (vue campagne) et refresh liste.
      actualiserPage(campUrlDetail, { id: campId }, _detailPpContext);
      _pendingListRefresh = true;
    } else {
      alert(data.erreur || 'Erreur lors de la suppression.');
      campSceAnnulerSuppression(sceId);
    }
  } catch (err) {
    alert('Erreur : ' + err);
    campSceAnnulerSuppression(sceId);
  }
}

function campSceAnnulerSuppression(sceId) {
  const row = document.getElementById('camp-sce-row-' + sceId);
  if (row && row.dataset.backup) row.innerHTML = row.dataset.backup;
}

// ============================================================
// SUPPRESSION INLINE CHAPITRE (depuis detail-pp — vue scénario)
// ============================================================

function campSccDemanderSuppression(sccId, sceId) {
  const row     = document.getElementById('camp-scc-row-' + sccId);
  const confirm = document.getElementById('camp-scc-confirm-' + sccId);
  if (!row || !confirm) return;

  row.dataset.backup = row.innerHTML;
  row.dataset.sceId  = sceId;
  const nbCols = row.querySelectorAll('td').length;
  row.innerHTML = `<td colspan="${nbCols}" class="comp-confirm-row">${confirm.innerHTML}</td>`;
}

async function campSccConfirmerSuppression(sccId) {
  const row   = document.getElementById('camp-scc-row-' + sccId);
  const sceId = parseInt(row ? row.dataset.sceId : 0);
  const urlSce = campUrlDetail.replace('/campagne.php', '/scenario.php');
  try {
    const data = await postAjax(campUrlEnreg, { action: 'supprimerChapitre', id: sccId });
    if (data.ok) {
      // Rafraîchit la vue scénario dans #detail-pp (navigation interne).
      naviguerDetailPP(urlSce, { id: sceId });
    } else {
      alert(data.erreur || 'Erreur lors de la suppression.');
      campSccAnnulerSuppression(sccId);
    }
  } catch (err) {
    alert('Erreur : ' + err);
    campSccAnnulerSuppression(sccId);
  }
}

function campSccAnnulerSuppression(sccId) {
  const row = document.getElementById('camp-scc-row-' + sccId);
  if (row && row.dataset.backup) row.innerHTML = row.dataset.backup;
}

// ============================================================
// SUPPRESSION INLINE RENCONTRE (depuis detail-pp — vue chapitre)
// ============================================================

function campReDemanderSuppression(reId, sccId) {
  const row     = document.getElementById('camp-re-row-' + reId);
  const confirm = document.getElementById('camp-re-confirm-' + reId);
  if (!row || !confirm) return;

  row.dataset.backup = row.innerHTML;
  row.dataset.sccId  = sccId;
  const nbCols = row.querySelectorAll('td').length;
  row.innerHTML = `<td colspan="${nbCols}" class="comp-confirm-row">${confirm.innerHTML}</td>`;
}

async function campReConfirmerSuppression(reId) {
  const row   = document.getElementById('camp-re-row-' + reId);
  const sccId = parseInt(row ? row.dataset.sccId : 0);
  const urlScc = campUrlDetail.replace('/campagne.php', '/chapitre.php');
  try {
    const data = await postAjax(campUrlEnreg, { action: 'supprimerRencontre', id: reId });
    if (data.ok) {
      // Rafraîchit la vue chapitre dans #detail-pp.
      naviguerDetailPP(urlScc, { id: sccId });
    } else {
      alert(data.erreur || 'Erreur lors de la suppression.');
      campReAnnulerSuppression(reId);
    }
  } catch (err) {
    alert('Erreur : ' + err);
    campReAnnulerSuppression(reId);
  }
}

function campReAnnulerSuppression(reId) {
  const row = document.getElementById('camp-re-row-' + reId);
  if (row && row.dataset.backup) row.innerHTML = row.dataset.backup;
}

// ============================================================
// SUPPRESSION INLINE OPPOSITION (depuis detail-pp — vue rencontre)
// ============================================================

function campOppDemanderSuppression(oppId, reId) {
  const row     = document.getElementById('camp-opp-row-' + oppId);
  const confirm = document.getElementById('camp-opp-confirm-' + oppId);
  if (!row || !confirm) return;

  row.dataset.backup = row.innerHTML;
  row.dataset.reId   = reId;
  const nbCols = row.querySelectorAll('td').length;
  row.innerHTML = `<td colspan="${nbCols}" class="comp-confirm-row">${confirm.innerHTML}</td>`;
}

async function campOppConfirmerSuppression(oppId) {
  const row  = document.getElementById('camp-opp-row-' + oppId);
  const reId = parseInt(row ? row.dataset.reId : 0);
  const urlRe = campUrlDetail.replace('/campagne.php', '/rencontre.php');
  try {
    const data = await postAjax(campUrlEnreg, { action: 'supprimerOpposition', id: oppId });
    if (data.ok) {
      // Rafraîchit la vue rencontre dans #detail-pp.
      naviguerDetailPP(urlRe, { id: reId });
    } else {
      alert(data.erreur || 'Erreur lors de la suppression.');
      campOppAnnulerSuppression(oppId);
    }
  } catch (err) {
    alert('Erreur : ' + err);
    campOppAnnulerSuppression(oppId);
  }
}

function campOppAnnulerSuppression(oppId) {
  const row = document.getElementById('camp-opp-row-' + oppId);
  if (row && row.dataset.backup) row.innerHTML = row.dataset.backup;
}

// ============================================================
// SUPPRESSION CAMPAGNE depuis la fiche détail (#detail-pp)
// Utilise confirm() natif (pas de ligne à remplacer dans un panel).
// ============================================================

const campagneListe = {
  supprimer(id, nom) {
    const message = 'Supprimer la campagne « ' + nom + ' » ?\n\n'
      + 'Ses scénarios, rencontres et oppositions seront également supprimés. '
      + 'Cette action est définitive.';
    confirmer(message, async () => {
      try {
        const data = await postAjax(campUrlEnreg, { action: 'supprimerCampagne', id: id });
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

  // Position : sous le bouton de menu ayant déclenché l'ouverture.
  // Calcul via getBoundingClientRect() (viewport-relatif, fiable quels que
  // soient les ancêtres positionnés intermédiaires — ex: .comp-menu-ligne)
  // puis conversion en coordonnées relatives à #detail-pp, qui est
  // l'ancêtre positionné réel du popup (position:fixed + transform sur
  // .overlay-panel -> devient le containing block ; offsetTop/offsetLeft
  // façon mo-tag-popup ne conviendrait pas ici à cause de .comp-menu-ligne
  // qui s'interpose comme offsetParent du bouton).
  const btn   = event.target.closest('button') || event.target;
  const panel = document.getElementById('detail-pp');
  if (panel) {
    const panelRect = panel.getBoundingClientRect();
    const btnRect   = btn.getBoundingClientRect();
    popup.style.top  = (btnRect.bottom - panelRect.top  + panel.scrollTop  + 4) + 'px';
    popup.style.left = (btnRect.left   - panelRect.left + panel.scrollLeft)     + 'px';
  }
  popup.hidden = false;

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
        rafraichirDetailPPCourant();
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
