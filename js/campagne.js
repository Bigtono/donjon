// js/campagne.js — Interactions du module Campagnes.
// Chargé uniquement sur les pages du module ($js_module = 'campagne').
// campUrlModifier / campUrlEnreg injectés en inline par chaque page.
//
// SP-CP : le module a quitté #detail-pp pour une navigation pleine page
// (campagnes/campagne.php et ses sous-pages campagne-personnages.php /
// campagne-scenarios.php — SP-CP9 —, scenario.php, chapitre.php, rencontre.php). Toutes
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

// ============================================================
// PERSONNAGES DE LA CAMPAGNE (SP-PE18)
// Le MJ ajoute ou retire un personnage depuis la page de la campagne. Les
// écritures passent par les actions existantes du module Personnages
// (rattacherCampagne / detacherCampagne), qui contrôlent le droit du MJ.
// ============================================================

function campPersoAjouter(campId) {
  const select = document.getElementById('camp-perso-ajout');
  const peId   = select ? parseInt(select.value, 10) : 0;
  if (!peId) return;
  postAjax(campUrlEnregPer, { action: 'rattacherCampagne', pe_id: peId, camp_id: campId })
    .then(data => {
      if (data.ok) {
        window.location.reload();
      } else {
        alert(data.erreur || 'Erreur.');
      }
    })
    .catch(err => alert('Erreur : ' + err));
}

function campPersoRetirer(campId, peId, peNom) {
  if (!confirm('Retirer « ' + peNom + ' » de la campagne ?')) return;
  postAjax(campUrlEnregPer, { action: 'detacherCampagne', pe_id: peId, camp_id: campId })
    .then(data => {
      if (data.ok) {
        window.location.reload();
      } else {
        alert(data.erreur || 'Erreur.');
      }
    })
    .catch(err => alert('Erreur : ' + err));
}

// ============================================================
// ONGLETS EN PAGE (SP-CP10)
// ============================================================
// Contrat (include/onglets-nav.php, campagnes/rencontre.php) :
//   <nav data-onglets="re-12"> … <button data-onglet="description"> …
//   <div data-panneau-de="re-12" data-panneau="description" [hidden]>
// Le serveur rend déjà l'onglet mémorisé ; le clic bascule les panneaux sans
// recharger, puis mémorise le choix en session (action memoriserOnglet). Une
// mémoire perdue n'est pas une erreur : rien n'est signalé.

document.addEventListener('click', function (e) {
  const btn = e.target.closest('[data-onglets] [data-onglet]');
  if (!btn) return;
  const barre = btn.closest('[data-onglets]');
  campActiverOnglet(barre, btn.dataset.onglet);
});

function campActiverOnglet(barre, valeur) {
  const cle = barre.dataset.onglets;
  barre.querySelectorAll('[data-onglet]').forEach(b => {
    const actif = (b.dataset.onglet === valeur);
    b.classList.toggle('est-actif', actif);
    b.setAttribute('aria-selected', actif ? 'true' : 'false');
  });
  document.querySelectorAll('[data-panneau-de="' + cle + '"]').forEach(p => {
    p.hidden = (p.dataset.panneau !== valeur);
  });
  if (typeof campUrlEnreg !== 'undefined') {
    postAjax(campUrlEnreg, { action: 'memoriserOnglet', cle: cle, valeur: valeur }).catch(() => {});
  }
}

// ============================================================
// SUIVI DES PV DES OPPOSITIONS (SP-CP11)
// ============================================================
// Chaque créature (.camp-pv[data-pv-cle="oppid-rang"]) figure deux fois : dans
// le bandeau commun et dans la fiche de son opposition. Une saisie met à jour
// toutes les copies et le total, puis enregistre ; en cas d'échec, on revient
// à la valeur précédente. « − » (ou Entrée) inflige les dégâts saisis, « + »
// rend des PV, sans dépasser le maximum.

document.addEventListener('click', function (e) {
  const btn = e.target.closest('.camp-pv [data-pv-op]');
  if (!btn) return;
  campPvAppliquer(btn.closest('.camp-pv'), btn.dataset.pvOp);
});

document.addEventListener('keydown', function (e) {
  if (e.key !== 'Enter' || !e.target.classList.contains('camp-pv__delta')) return;
  e.preventDefault();
  campPvAppliquer(e.target.closest('.camp-pv'), e.shiftKey ? 'plus' : 'moins');
});

function campPvAppliquer(bloc, op) {
  const champ = bloc.querySelector('.camp-pv__delta');
  const delta = parseInt(champ.value, 10);
  if (!delta || delta < 0) { champ.focus(); return; }

  const avant = parseInt(bloc.dataset.pv, 10);
  const max   = parseInt(bloc.dataset.pvMax, 10);
  const apres = op === 'plus' ? Math.min(max, avant + delta) : avant - delta;
  champ.value = '';
  if (apres === avant) return;

  campPvAfficher(bloc.dataset.pvCle, apres);
  postAjax(campUrlEnreg, {
    action: 'modifierPvOpposition',
    opp_id: bloc.dataset.pvOpp,
    rang:   bloc.dataset.pvRang,
    pv:     apres,
  }).then(data => {
    if (!data.ok) throw new Error(data.erreur || 'PV non enregistrés.');
  }).catch(err => {
    campPvAfficher(bloc.dataset.pvCle, avant);
    notifier(err.message || 'PV non enregistrés.', 'erreur');
  });
}

// Met à jour toutes les copies d'une créature, puis le total de la rencontre.
function campPvAfficher(cle, pv) {
  document.querySelectorAll('.camp-pv[data-pv-cle="' + cle + '"]').forEach(b => {
    const max = parseInt(b.dataset.pvMax, 10);
    const pct = Math.max(0, Math.min(100, Math.round(pv * 100 / max)));
    b.dataset.pv = pv;
    b.querySelector('.camp-pv__valeur b').textContent = pv;
    b.querySelector('.camp-pv__jauge span').style.width = pct + '%';
    b.classList.toggle('est-hors-combat', pv <= 0);
    b.classList.toggle('est-blesse', pv > 0 && pct <= 50);
  });

  const total = document.querySelector('[data-pv-total]');
  if (!total) return;
  let somme = 0;
  document.querySelectorAll('.camp-pv-bandeau .camp-pv[data-pv-cle]').forEach(b => {
    somme += Math.max(0, parseInt(b.dataset.pv, 10));
  });
  total.textContent = somme;
}

function campPvReinitialiser(reId) {
  confirmer('Remettre toutes les créatures de la rencontre à leurs PV max ?', async () => {
    try {
      const data = await postAjax(campUrlEnreg, { action: 'reinitialiserPvRencontre', re_id: reId });
      if (data.ok) window.location.reload();
      else notifier(data.erreur || 'Réinitialisation impossible.', 'erreur');
    } catch (err) {
      notifier('Erreur : ' + err.message, 'erreur');
    }
  });
}

// ============================================================
// IMAGES DES DESCRIPTIONS — plans en taille réelle (SP-CP12)
// ============================================================
// Une image de description est réduite à la largeur de la colonne ; un plan
// se lit mieux en grand. Le clic l'ouvre seule dans un nouvel onglet, sauf si
// elle est déjà dans un lien (le lien garde la main).

document.addEventListener('click', function (e) {
  const img = e.target.closest('.camp-detail__description img');
  if (!img || img.closest('a')) return;
  window.open(img.currentSrc || img.src, '_blank', 'noopener');
});
