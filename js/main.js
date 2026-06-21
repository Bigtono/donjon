// js/main.js — Fonctions transverses Codex DD
'use strict';

// ============================================================
// CSRF
// ============================================================

function getCsrfToken() {
  const meta = document.querySelector('meta[name="csrf-token"]');
  return meta ? meta.getAttribute('content') : '';
}

// ============================================================
// CONTEXTE DETAIL-PP
// 'liste'   = ouvert depuis une liste compendium
// 'externe' = ouvert depuis toute autre page (défaut)
// ============================================================

let _detailPpContext = 'externe';
let _detailPpUrl = '';
let _detailPpParams = {};
let _pendingListRefresh = false;

// Pile de navigation interne de #detail-pp.
// Chaque entrée : { url: string, params: object }
// Utilisée par naviguerDetailPP() / retourDetailPP().
let _detailPpStack = [];

// ============================================================
// BLOCS REPLIABLES (burger)
// ============================================================

function togglePlus(id) {
  const el = document.getElementById(id);
  if (!el) return;
  el.classList.toggle('noDisplay');
}

// Accordion exclusif : ferme tous les autres dans le même groupe avant d'ouvrir
function togglePlusExclusif(id, groupSelector) {
  const target = document.getElementById(id);
  if (!target) return;
  const isOpen = !target.classList.contains('noDisplay');

  // Ferme tous les accordions du groupe
  const parent = groupSelector ? document.querySelector(groupSelector) : document.body;
  if (parent) {
    parent.querySelectorAll('.accordion-content').forEach(el => {
      el.classList.add('noDisplay');
    });
  }
  // Ouvre uniquement si l'élément était fermé
  if (!isOpen) target.classList.remove('noDisplay');
}

// ============================================================
// CONTEXTE DE NAVIGATION (HEADER)
// ============================================================

// Ouvre directement un niveau de la hiérarchie Campagne → Scénario → Chapitre
// depuis un bouton du header, en reconstruisant toute la chaîne d'ancêtres
// dans _detailPpStack — pour que le bouton ← Retour reste cohérent une fois
// revenu dans le panneau. `chain` = [{url, params}, ...] du niveau racine
// jusqu'au niveau cible (fourni côté serveur par include/header.php).
function ouvrirContextePP(chain) {
  if (!Array.isArray(chain) || chain.length === 0) return;
  _detailPpContext = 'externe';
  _detailPpStack    = chain;
  const cible = chain[chain.length - 1];
  _chargerDetailPP(cible.url, cible.params, chain.length > 1);
}

// ============================================================
// PATTERN DETAIL-PP / MODIFICATION
// ============================================================

// Charge #detail-pp via GET — lecture seule.
// Réinitialise la pile : point d'entrée depuis une liste.
function actualiserPage(url, params = {}, context = 'externe') {
  _detailPpContext = context;
  _detailPpUrl     = url;
  _detailPpParams  = params;
  _detailPpStack   = [{ url, params }];

  _chargerDetailPP(url, params, false);
}

// Navigation interne dans #detail-pp (campagne → scénario → rencontre).
// Empile l'entrée courante et charge la nouvelle vue.
// Le bouton ✕ Fermer reste présent ; un bouton ← Retour est ajouté si pile > 1.
function naviguerDetailPP(url, params = {}) {
  _detailPpStack.push({ url, params });
  _chargerDetailPP(url, params, true);
}

// Retour arrière dans la pile de navigation interne.
// Dépile l'entrée courante et recharge l'entrée précédente.
function retourDetailPP() {
  if (_detailPpStack.length <= 1) {
    fermerDetailPP();
    return;
  }
  _detailPpStack.pop();
  const prev = _detailPpStack[_detailPpStack.length - 1];
  _chargerDetailPP(prev.url, prev.params, _detailPpStack.length > 1);
}

// Recharge le panel #detail-pp actuellement affiché (sommet de la pile),
// sans modifier l'historique de navigation (contrairement à naviguerDetailPP,
// qui empile une nouvelle entrée). Utile après une action déclenchée depuis
// un sous-panneau (#detail-pp-sub) qui modifie des données affichées dans
// #detail-pp en dessous — ex : modifier une opposition depuis sa fiche
// détail doit rafraîchir la liste des oppositions de la rencontre affichée.
function rafraichirDetailPPCourant() {
  if (_detailPpStack.length === 0) return;
  const top = _detailPpStack[_detailPpStack.length - 1];
  _chargerDetailPP(top.url, top.params, _detailPpStack.length > 1);
}

// Worker interne — construit l'URL, fait le fetch, injecte le HTML.
// withBack=true → ajoute le bouton ← Retour sous le bouton ✕.
function _chargerDetailPP(url, params, withBack) {
  const panel    = document.getElementById('detail-pp');
  const backdrop = document.getElementById('detail-pp-backdrop');
  if (!panel) return;

  if (backdrop) backdrop.classList.remove('noDisplay');
  panel.classList.remove('noDisplay');
  panel.innerHTML = '<div class="loading"><i class="fa fa-spinner fa-spin"></i> Chargement…</div>';

  const fullUrl = Object.keys(params).length > 0
    ? url + '?' + new URLSearchParams(params).toString()
    : url;

  fetch(fullUrl)
    .then(r => { if (!r.ok) throw new Error('Erreur ' + r.status); return r.text(); })
    .then(html => {
      const closeBtn = '<button class="overlay-close" onclick="fermerDetailPP()" title="Fermer">'
        + '<i class="fa fa-times"></i></button>';
      const backBtn = withBack
        ? '<button class="overlay-back" onclick="retourDetailPP()" title="Retour">'
          + '<i class="fa fa-arrow-left"></i> Retour</button>'
        : '';
      panel.innerHTML = closeBtn + backBtn + html;
      actualiserContexteHeader();
    })
    .catch(err => { panel.innerHTML = '<p class="erreur">' + err + '</p>'; });
}

// Recharge le bloc de contexte du header (boutons retour rapide) sans
// recharger la page — appelé après chaque consultation dans #detail-pp,
// puisque la session (last_camp_id / last_sce_id / ...) vient d'être mise à
// jour côté serveur par ce même chargement.
function actualiserContexteHeader() {
  const zone = document.getElementById('site-header-context-zone');
  if (!zone) return;
  fetch(BASE_URL + '/include/ajax/header-context.php')
    .then(r => r.text())
    .then(html => { zone.innerHTML = html; })
    .catch(() => {});
}

// Charge #modification via GET — lecture initiale du formulaire
function actualiserPageModif(url, params = {}) {
  const panel    = document.getElementById('modification');
  const backdrop = document.getElementById('modification-backdrop');
  if (!panel) return;

  if (backdrop) backdrop.classList.remove('noDisplay');
  panel.classList.remove('noDisplay');
  panel.innerHTML = '<div class="loading"><i class="fa fa-spinner fa-spin"></i> Chargement…</div>';

  const fullUrl = Object.keys(params).length > 0
    ? url + (url.includes('?') ? '&' : '?') + new URLSearchParams(params).toString()
    : url;

  fetch(fullUrl)
    .then(r => { if (!r.ok) throw new Error('Erreur ' + r.status); return r.text(); })
    .then(html => {
      panel.innerHTML = html;
      // Les <script> injectés via innerHTML ne s'exécutent pas — on les recrée
      panel.querySelectorAll('script').forEach(ancien => {
        const nouveau = document.createElement('script');
        Array.from(ancien.attributes).forEach(a => nouveau.setAttribute(a.name, a.value));
        nouveau.textContent = ancien.textContent;
        ancien.parentNode.replaceChild(nouveau, ancien);
      });
    })
    .catch(err => { panel.innerHTML = '<p class="erreur">' + err + '</p>'; });
}

// Ouvre le formulaire de modification depuis detail-pp
function ouvrirModifier(url, id) {
  actualiserPageModif(url, { id: id });
}

// Ferme #modification sans toucher à #detail-pp
function fermerModification() {
  const panel    = document.getElementById('modification');
  const backdrop = document.getElementById('modification-backdrop');
  if (panel)    { panel.classList.add('noDisplay'); panel.innerHTML = ''; }
  if (backdrop) backdrop.classList.add('noDisplay');
}

// Ferme #detail-pp (et #modification et #detail-pp-sub si ouverts)
function fermerDetailPP() {
  const panel    = document.getElementById('detail-pp');
  const backdrop = document.getElementById('detail-pp-backdrop');
  if (panel)    { panel.classList.add('noDisplay'); panel.innerHTML = ''; }
  if (backdrop) backdrop.classList.add('noDisplay');
  _detailPpStack = [];
  fermerSubPanel();
  fermerModification();
  if (_pendingListRefresh) {
    _pendingListRefresh = false;
    rafraichirListe();
  }
}

// ============================================================
// SOUS-PANEL — detail-pp-sub
// S'affiche au-dessus du detail-pp courant.
// Utilisé pour afficher le détail d'un élément référencé
// dans une fiche (capacité, compétence, sort, opposition…)
// sans fermer le panel principal.
// ============================================================

// Charge #detail-pp-sub via GET — lecture seule
function actualiserPageSub(url, params = {}) {
  const panel    = document.getElementById('detail-pp-sub');
  const backdrop = document.getElementById('detail-pp-sub-backdrop');
  if (!panel) return;

  if (backdrop) backdrop.classList.remove('noDisplay');
  panel.classList.remove('noDisplay');
  panel.innerHTML = '<div class="loading"><i class="fa fa-spinner fa-spin"></i> Chargement…</div>';

  const fullUrl = Object.keys(params).length > 0
    ? url + '?' + new URLSearchParams(params).toString()
    : url;

  fetch(fullUrl)
    .then(r => { if (!r.ok) throw new Error('Erreur ' + r.status); return r.text(); })
    .then(html => {
      const closeBtn = '<button class="overlay-close" onclick="fermerSubPanel()" title="Fermer">'
        + '<i class="fa fa-times"></i></button>';
      panel.innerHTML = closeBtn + html;
      // Les <script> injectés via innerHTML ne s'exécutent pas — on les recrée
      panel.querySelectorAll('script').forEach(ancien => {
        const nouveau = document.createElement('script');
        Array.from(ancien.attributes).forEach(a => nouveau.setAttribute(a.name, a.value));
        nouveau.textContent = ancien.textContent;
        ancien.parentNode.replaceChild(nouveau, ancien);
      });
    })
    .catch(err => { panel.innerHTML = '<p class="erreur">' + err + '</p>'; });
}

// Ferme #detail-pp-sub sans toucher au panel principal
function fermerSubPanel() {
  const panel    = document.getElementById('detail-pp-sub');
  const backdrop = document.getElementById('detail-pp-sub-backdrop');
  if (panel)    { panel.classList.add('noDisplay'); panel.innerHTML = ''; }
  if (backdrop) backdrop.classList.add('noDisplay');
}

// ============================================================
// POST AJAX — écriture vers enregistrement.php
// ============================================================

async function postAjax(url, data = {}) {
  const body = new URLSearchParams(data);
  body.append('csrf_token', getCsrfToken());
  const response = await fetch(url, {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: body.toString(),
  });
  if (!response.ok) throw new Error('Erreur ' + response.status);
  return response.json();
}

// Appelé après enregistrement AJAX — data = { ok, id, url_detail }
function apresModification(data) {
  fermerModification();
  if (data.url_detail) {
    actualiserPage(data.url_detail, { id: data.id }, _detailPpContext);
    if (document.getElementById('comp-liste-' + (typeof compEntite !== 'undefined' ? compEntite : ''))) {
      _pendingListRefresh = true;
    }
  }
}

function rafraichirListe() {
  window.location.reload();
}

// ============================================================
// MESSAGES FLASH (disparition automatique)
// ============================================================

document.addEventListener('DOMContentLoaded', () => {
  const flash = document.querySelector('.flash-message');
  if (flash) {
    setTimeout(() => flash.classList.add('flash-message--hidden'), 3500);
  }
});

// ============================================================
// CONFIRMATION AVANT ACTION DESTRUCTIVE
// ============================================================

function confirmer(message, callback) {
  if (window.confirm(message)) callback();
}

// ============================================================
// MONSTRE / OPPOSITION — liens cliquables du bloc de stats (.mo-lien)
// Le span ne porte que data-type / data-id ; l'URL de l'endpoint
// detail-pp est résolue ici, et la base est lue sur le conteneur
// (.mo-stats[data-detail-base]) -> aucune dépendance à un BASE_URL global.
// Délégation : un seul écouteur pour tous les blocs de stats affichés
// (compendium ET oppositions de campagne — d'où la présence ici, dans
// main.js, chargé sur toutes les pages, plutôt que dans compendium.js).
// ============================================================
var MO_LIEN_FICHIERS = {
  don: 'don.php',
  competence: 'competence.php',
  sort: 'sort.php',
  objet: 'objet.php',
  capacite: 'capacite.php',
  race: 'race.php',
  classe: 'classe.php',
  regle: 'regle',
  glossaire: 'glossaire',
};

document.addEventListener('click', function (e) {
  const lien = e.target.closest('.mo-lien');
  if (!lien) return;
  const type = lien.dataset.type;
  const id   = parseInt(lien.dataset.id, 10);
  if (!id) return;

  // Reconstruire BASE_URL depuis data-detail-base
  // data-detail-base = "http://localhost/donjon/include/ajax/detail-pp/"
  const cont       = lien.closest('[data-detail-base]');
  const detailBase = cont ? cont.dataset.detailBase : '';
  // Retirer "/include/ajax/detail-pp/" pour obtenir la racine
  const appBase    = detailBase.replace(/\/include\/ajax\/detail-pp\/$/, '');

  // Regle : nouvelle page
  if (type === 'regle') {
    window.open(appBase + '/regles/regle.php?id=' + id, '_blank');
    return;
  }
  // Glossaire : sub-panel
  if (type === 'glossaire') {
    if (typeof actualiserPageSub === 'function') {
      actualiserPageSub(appBase + '/include/ajax/detail-pp-sub/glossaire.php', { id: id });
    }
    return;
  }
  // Autres types compendium : sub-panel standard
  const fichier = MO_LIEN_FICHIERS[type];
  if (!fichier) return;
  if (typeof actualiserPageSub === 'function') {
    actualiserPageSub(detailBase + fichier, { id: id });
  }
});
