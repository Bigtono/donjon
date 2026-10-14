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
// SP-CP : ouvrirContextePP() a été retirée. Les niveaux de campagne du fil
// d'Ariane sont maintenant de simples liens vers campagnes/{niveau}.php —
// plus de pile à reconstruire côté client (cf. include/header-context.php).

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

// Chrome commun aux trois panneaux (SP-RS4). En desktop la barre est en
// `display: contents` : les boutons restent flottants (position: absolute) aux
// coins du panneau, exactement comme avant. Sous 992px elle devient une vraie
// barre d'en-tête dans le flux, avec des cibles de 44px — les boutons ne
// recouvrent alors plus le titre du contenu. Voir css/main.css et doc §10g.
function barrePanneau(boutons) {
  return '<div class="overlay-panel__bar">' + boutons + '</div>';
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
      panel.innerHTML = barrePanneau(backBtn + closeBtn)
        + '<div class="overlay-panel__inner">' + html + '</div>';
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
    .then(html => {
      zone.innerHTML = html;
      contexteHeaderCadrer();
    })
    .catch(() => {});
}

// Fil d'Ariane du header (≤991px) : amène le niveau courant — le plus profond,
// donc le dernier — à l'écran. Sans effet en desktop, où la barre ne défile pas.
function contexteHeaderCadrer() {
  const bar = document.querySelector('.site-header__context');
  if (!bar) return;
  bar.scrollLeft = bar.scrollWidth;
}

document.addEventListener('DOMContentLoaded', contexteHeaderCadrer);

// Les <script> injectés via innerHTML ne s'exécutent pas : on les recrée.
//
// Un script EXTERNE déjà chargé dans la page n'est pas rechargé. Sans cela,
// chaque ouverture d'un formulaire retéléchargeait TinyMCE, qui remplaçait
// l'objet global `tinymce` APRÈS que le script du formulaire y eut créé ses
// éditeurs : `tinymce.get()` ne les voyait plus, et la saisie d'un champ riche
// n'était pas recopiée dans son <textarea> à l'envoi — perdue, dès la deuxième
// ouverture sans rechargement de la page. Les scripts en ligne, eux, sont
// réexécutés à chaque fois : ils initialisent le fragment injecté.
const _scriptsExternesCharges = new Set();

function executerScriptsInjectes(conteneur) {
  conteneur.querySelectorAll('script').forEach(ancien => {
    if (ancien.src) {
      // Déjà chargé par un panneau précédent (dont le DOM a disparu depuis :
      // d'où le Set), ou par la page elle-même.
      const dejaCharge = _scriptsExternesCharges.has(ancien.src)
        || Array.from(document.scripts).some(s => s.src === ancien.src && !conteneur.contains(s));
      if (dejaCharge) {
        ancien.remove();
        return;
      }
      _scriptsExternesCharges.add(ancien.src);
    }
    const nouveau = document.createElement('script');
    Array.from(ancien.attributes).forEach(a => nouveau.setAttribute(a.name, a.value));
    nouveau.textContent = ancien.textContent;
    ancien.parentNode.replaceChild(nouveau, ancien);
  });
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
      // Bouton Fermer (SP-RS4) : #modification n'en avait aucun. Sur mobile le
      // panneau couvre tout l'écran, il ne reste aucun backdrop à toucher.
      const closeBtn = '<button class="overlay-close" onclick="fermerModification()" title="Fermer">'
        + '<i class="fa fa-times"></i></button>';
      panel.innerHTML = barrePanneau(closeBtn)
        + '<div class="overlay-panel__inner">' + html + '</div>';
      executerScriptsInjectes(panel);
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
      panel.innerHTML = barrePanneau(closeBtn)
        + '<div class="overlay-panel__inner">' + html + '</div>';
      executerScriptsInjectes(panel);
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
// NOTIFICATION D'ENREGISTREMENT AUTOMATIQUE — notifier() (SP-CP1)
// ============================================================
// Composant transverse : à appeler dès qu'une donnée est écrite SANS que
// l'utilisateur ait cliqué sur « Enregistrer » (glisser-déposer d'ordre,
// sélecteur de dons, rattachement de campagne…). Une écriture invisible doit
// laisser une trace visible, sinon rien ne distingue « enregistré » de
// « perdu ».
//
// À ne PAS utiliser pour les commits explicites de formulaire : ceux-là ont
// déjà leur retour (fermeture du panneau + rechargement, ou .flash-message).
//
// La pastille se pose en bas à droite, empilable, effacement automatique —
// même famille visuelle que le badge de debug (css/modules.css § TOAST).
//   notifier('Ordre enregistré');
//   notifier('Erreur : ordre non enregistré', 'erreur');

var TOAST_DUREE = 2500;

function notifier(message, type) {
  if (!message) return;

  var zone = document.getElementById('toast-zone');
  if (!zone) {
    zone = document.createElement('div');
    zone.id = 'toast-zone';
    zone.className = 'toast-zone';
    document.body.appendChild(zone);
  }

  var toast = document.createElement('div');
  toast.className = 'toast toast--' + (type || 'ok');
  var icones = { ok: 'fa-check', erreur: 'fa-triangle-exclamation', info: 'fa-circle-info' };
  toast.innerHTML = '<i class="fa ' + (icones[type] || icones.ok) + '" aria-hidden="true"></i>'
                  + '<span class="toast__texte"></span>';
  toast.querySelector('.toast__texte').textContent = message;
  zone.appendChild(toast);

  // Retrait en deux temps : classe de sortie, puis suppression du nœud à la
  // fin de la transition (transitionend n'est pas garanti si l'onglet passe en
  // arrière-plan — d'où le setTimeout de sécurité).
  setTimeout(function () {
    toast.classList.add('toast--sortie');
    setTimeout(function () { if (toast.parentNode) toast.parentNode.removeChild(toast); }, 400);
  }, TOAST_DUREE);
}

// ============================================================
// CONFIRMATION AVANT ACTION DESTRUCTIVE
// ============================================================

// siRefus est optionnel : il permet à l'appelant de rétablir l'état de l'UI
// quand l'utilisateur renonce (ligne de liste dépliée en demande de
// confirmation, par exemple).
function confirmer(message, callback, siRefus) {
  if (window.confirm(message)) callback();
  else if (typeof siRefus === 'function') siRefus();
}

// ============================================================
// TAG DE TABLEAU — copie dans le presse-papiers (SP-TB)
// Promue depuis js/regles.js en SP-TB10 : le tag s'affiche dans la fiche
// détail d'un tableau et dans son formulaire, tous deux injectés en AJAX sur
// n'importe quelle page — y compris hors module Règles, où js/regles.js n'est
// pas chargé et où l'appel échouait silencieusement.
// ============================================================

function copierTagTableau(el) {
  var texte = (el.textContent || '').trim();
  if (!texte) return;

  var confirmerVisuel = function () {
    var avant = el.getAttribute('title');
    el.classList.add('reg-tab-liste__tag--copie');
    el.setAttribute('title', 'Copié !');
    setTimeout(function () {
      el.classList.remove('reg-tab-liste__tag--copie');
      el.setAttribute('title', avant || '');
    }, 1200);
  };

  if (navigator.clipboard && navigator.clipboard.writeText) {
    navigator.clipboard.writeText(texte).then(confirmerVisuel, function () {});
    return;
  }
  // Repli : sélection du contenu, l'utilisateur fait Ctrl+C
  var plage = document.createRange();
  plage.selectNodeContents(el);
  var sel = window.getSelection();
  sel.removeAllRanges();
  sel.addRange(plage);
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
  equipement: 'equipement.php',
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

// ============================================================
// TABLEAUX — bouton d'insertion d'un tag [[tab:slug]] dans TinyMCE (SP-TB4/TB7)
//
// Ici plutôt que dans un formulaire : le bouton équipe l'éditeur de règle ET
// les huit éditeurs du compendium (sort, classe ×2, race ×2, don, compétence,
// objet, historique, équipement). Une définition par formulaire aurait été
// recopiée neuf fois.
//
// Le picker s'ouvre dans #detail-pp-sub (z-index 300), au-dessus de
// #modification (250) qui porte le formulaire : la saisie en cours n'est
// jamais remplacée. C'est pourquoi le picker ne propose pas de créer un
// tableau — cf. ARCHITECTURE §9c.
//
// Usage dans un tinymce.init() :
//   toolbar: '… | tableau | …',
//   setup: function (editor) { tableauxInitBouton(editor); }
// ============================================================

// Éditeur ayant ouvert le picker. Mémorisé au clic : au moment de l'insertion
// le focus est passé au sous-panneau, tinymce.activeEditor n'est plus fiable.
var TAB_EDITEUR_ACTIF = null;

function tableauxInitBouton(editor) {
  editor.ui.registry.addButton('tableau', {
    icon: 'table-row-properties',
    tooltip: 'Insérer un tableau de règles',
    onAction: function () {
      TAB_EDITEUR_ACTIF = editor.id;
      if (typeof actualiserPageSub === 'function') {
        actualiserPageSub(BASE_URL + '/include/ajax/detail-pp-sub/tableaux-picker.php', {});
      }
    }
  });
}

// Appelée par le picker. Le tag occupe son propre paragraphe : un <table> rendu
// à l'intérieur d'un <p> est du HTML invalide — le navigateur ferme le
// paragraphe et la mise en page casse (cf. resoudreTagsTableaux(), passe 1).
function insererTableauDansEditeur(slug) {
  if (!slug || !TAB_EDITEUR_ACTIF) return;
  var bloc = '<p>[[tab:' + slug + ']]</p>';
  var ed   = (typeof tinymce !== 'undefined') ? tinymce.get(TAB_EDITEUR_ACTIF) : null;

  if (ed && ed.initialized) {
    ed.insertContent(bloc);
  } else {
    // Repli : TinyMCE absent ou pas encore initialisé
    var ta = document.getElementById(TAB_EDITEUR_ACTIF);
    if (ta) ta.value += '\n' + bloc;
  }
  if (typeof fermerSubPanel === 'function') fermerSubPanel();
}

// ============================================================
// GLOSSAIRE — renvois inline dans les textes de règles (.glossaire-lien)
// Ancres produites par include/glossaire-parser.php (SP-GL) ou écrites à la
// main dans reg_texte. Elles portent data-glossaire-slug et ouvrent la
// définition dans #detail-pp-sub ; un clic depuis le sous-panneau rappelle
// actualiserPageSub() et remplace le contenu sur place (pas d'empilement).
//
// Ici plutôt que dans regles.js : ces ancres apparaissent aussi dans
// #detail-pp (fiche règle ouverte depuis une campagne) et dans les
// définitions du glossaire elles-mêmes, où regles.js n'est pas chargé.
// Référence : doc/ARCHITECTURE_0_REFERENCE.md §9d + §12
// ============================================================
document.addEventListener('click', function (e) {
  const lien = e.target.closest('.glossaire-lien');
  if (!lien) return;
  e.preventDefault();

  const slug = lien.dataset.glossaireSlug;
  if (!slug) return;

  // Base résolue comme pour .mo-lien : conteneur data-detail-base si présent
  // (contexte detail-pp), sinon le BASE_URL global posé par footer.php.
  const cont       = lien.closest('[data-detail-base]');
  const detailBase = cont ? cont.dataset.detailBase : '';
  const appBase    = detailBase
    ? detailBase.replace(/\/include\/ajax\/detail-pp\/$/, '')
    : (typeof BASE_URL !== 'undefined' ? BASE_URL : '');

  if (typeof actualiserPageSub === 'function') {
    actualiserPageSub(appBase + '/include/ajax/detail-pp-sub/glossaire.php', { slug: slug });
  }
});

// ============================================================
// AIDE CONTEXTUELLE (.aide-icone)
// La bulle est créée en enfant direct de <body> (jamais nichée dans
// #modification / #detail-pp-sub, qui ont un transform — containing block
// des descendants position:fixed) pour rester correctement positionnée et
// non rognée quelle que soit la couche d'affichage qui l'a déclenchée.
// Cache le HTML par clé pour éviter un fetch répété sur la même bulle.
// ============================================================
var _aideCache = {};
var _aideBulleEl = null;

function _fermerAideBulle() {
  if (_aideBulleEl) {
    _aideBulleEl.remove();
    _aideBulleEl = null;
  }
}

function _positionnerAideBulle(bulle, icone) {
  const rect = icone.getBoundingClientRect();
  bulle.style.visibility = 'hidden';
  document.body.appendChild(bulle);
  const largeur = bulle.offsetWidth;
  let left = rect.left;
  if (left + largeur > window.innerWidth - 8) {
    left = window.innerWidth - largeur - 8;
  }
  bulle.style.left = Math.max(8, left) + 'px';
  bulle.style.top  = (rect.bottom + 6) + 'px';
  bulle.style.visibility = '';
}

function _ouvrirAideBulle(icone, cle) {
  const bulle = document.createElement('div');
  bulle.id = 'aide-bulle';
  bulle.innerHTML = _aideCache[cle];
  _aideBulleEl = bulle;
  _positionnerAideBulle(bulle, icone);
}

document.addEventListener('click', function (e) {
  const icone = e.target.closest('.aide-icone');

  if (!icone) {
    if (_aideBulleEl && !e.target.closest('#aide-bulle')) {
      _fermerAideBulle();
    }
    return;
  }

  e.preventDefault();
  e.stopPropagation();

  // Re-clic sur la même icône : ferme la bulle déjà ouverte
  if (_aideBulleEl && _aideBulleEl.dataset.aideOuvrante === icone.dataset.aide) {
    _fermerAideBulle();
    return;
  }
  _fermerAideBulle();

  const cle = icone.dataset.aide;
  if (_aideCache[cle] !== undefined) {
    _ouvrirAideBulle(icone, cle);
    _aideBulleEl.dataset.aideOuvrante = cle;
    return;
  }

  fetch(BASE_URL + '/include/ajax/aide.php?cle=' + encodeURIComponent(cle))
    .then(r => r.text())
    .then(html => {
      _aideCache[cle] = html;
      _ouvrirAideBulle(icone, cle);
      _aideBulleEl.dataset.aideOuvrante = cle;
    });
});

document.addEventListener('keydown', function (e) {
  if (e.key === 'Escape' && _aideBulleEl) {
    _fermerAideBulle();
  }
  if ((e.key === 'Enter' || e.key === ' ') && e.target.classList.contains('aide-icone')) {
    e.preventDefault();
    e.target.click();
  }
});

// Ferme la bulle si la couche qui la contient scrolle, pour éviter qu'elle
// reste figée à une position obsolète (capture:true = capte le scroll de
// n'importe quel conteneur scrollable ancestor, pas seulement window).
document.addEventListener('scroll', function () {
  if (_aideBulleEl) _fermerAideBulle();
}, true);

// ============================================================
// MENU PRINCIPAL DÉROULANT (mobile / tablette, ≤ 991px)
// Le bouton #site-nav-toggle et le panneau #site-nav occupent toute la
// largeur d'affichage ; au-dessus de 991px la nav redevient horizontale
// et l'état ouvert/fermé est réinitialisé.
// ============================================================

var NAV_BREAKPOINT = 991;

function toggleMenuPrincipal(forceOuvrir) {
  const nav = document.getElementById('site-nav');
  const btn = document.getElementById('site-nav-toggle');
  if (!nav || !btn) return;

  const ouvrir = (typeof forceOuvrir === 'boolean')
    ? forceOuvrir
    : !nav.classList.contains('is-open');

  nav.classList.toggle('is-open', ouvrir);
  btn.setAttribute('aria-expanded', ouvrir ? 'true' : 'false');
}

function fermerMenuPrincipal() {
  toggleMenuPrincipal(false);
}

// Fermeture au clic hors du header
document.addEventListener('click', function (e) {
  const nav = document.getElementById('site-nav');
  if (!nav || !nav.classList.contains('is-open')) return;
  if (e.target && e.target.closest && e.target.closest('.site-header')) return;
  fermerMenuPrincipal();
});

// Fermeture à la touche Échap
document.addEventListener('keydown', function (e) {
  if (e.key === 'Escape') fermerMenuPrincipal();
});

// Retour en affichage desktop : on réinitialise l'état du menu
window.addEventListener('resize', function () {
  if (window.innerWidth > NAV_BREAKPOINT) fermerMenuPrincipal();
});

// ============================================================
// MODE DEBUG — badge dimensions du viewport
// Rendu par include/header.php lorsque $_SESSION['debug_ui'] est actif
// (bascule dans admin/index.php). Un clic fait tourner le badge entre
// les quatre coins, position mémorisée en localStorage.
// ============================================================

var DEBUG_COINS = ['', 'debug-viewport--right', 'debug-viewport--top debug-viewport--right', 'debug-viewport--top'];

function _debugMajBadge() {
  const badge = document.getElementById('debug-viewport');
  if (!badge) return;

  const l = window.innerWidth;
  const h = window.innerHeight;
  const dpr = window.devicePixelRatio || 1;
  const paliers = (badge.dataset.breakpoints || '')
    .split(',')
    .map(v => parseInt(v, 10))
    .filter(v => !isNaN(v));

  let html = '<span class="debug-viewport__dim">' + l + ' × ' + h + '</span>';
  html += '<span>dpr ' + (Math.round(dpr * 100) / 100) + '</span>';
  paliers.forEach(bp => {
    const actif = l <= bp;
    html += '<span class="debug-viewport__bp' + (actif ? ' debug-viewport__bp--on' : '') + '">≤' + bp + '</span>';
  });
  badge.innerHTML = html;
}

function _debugAppliquerCoin(index) {
  const badge = document.getElementById('debug-viewport');
  if (!badge) return;
  badge.classList.remove('debug-viewport--right', 'debug-viewport--top');
  DEBUG_COINS[index].split(' ').filter(c => c).forEach(c => badge.classList.add(c));
}

document.addEventListener('DOMContentLoaded', function () {
  const badge = document.getElementById('debug-viewport');
  if (!badge) return;

  let coin = parseInt(localStorage.getItem('debugViewportCoin') || '0', 10);
  if (isNaN(coin) || coin < 0 || coin >= DEBUG_COINS.length) coin = 0;
  _debugAppliquerCoin(coin);
  _debugMajBadge();

  badge.addEventListener('click', function () {
    coin = (coin + 1) % DEBUG_COINS.length;
    localStorage.setItem('debugViewportCoin', String(coin));
    _debugAppliquerCoin(coin);
  });

  window.addEventListener('resize', _debugMajBadge);
  window.addEventListener('orientationchange', _debugMajBadge);
});

// ============================================================
// BARRE DE FILTRAGE — toggle mobile (composant partagé)
// Déplacé de js/compendium.js le 2026-08-22 (SP-RS3b) : le composant sert
// aussi au module Personnages, qui ne charge pas compendium.js.
// Une seule barre de filtrage par page — d'où les identifiants fixes
// #comp-filtre-content et #filtre-toggle-btn.
// ============================================================

function toggleFiltresMobile() {
  const content = document.getElementById('comp-filtre-content');
  const btn = document.getElementById('filtre-toggle-btn');
  if (!content || !btn) return;

  const isOpen = !content.classList.contains('is-closed');
  if (isOpen) {
    content.classList.add('is-closed');
    btn.classList.remove('is-open');
    btn.setAttribute('aria-expanded', 'false');
  } else {
    content.classList.remove('is-closed');
    btn.classList.add('is-open');
    btn.setAttribute('aria-expanded', 'true');
  }
}

// Initialisation : replié en mobile par défaut
document.addEventListener('DOMContentLoaded', function () {
  if (window.innerWidth <= 991) {
    const content = document.getElementById('comp-filtre-content');
    if (content) content.classList.add('is-closed');
  }
});

// ============================================================
// RELEVÉ D'AFFICHAGE (SP-RS5)
// Transmet une fois par session authentifiée les caractéristiques réelles du
// navigateur, pour arbitrer les paliers responsive sur des mesures plutôt que
// sur des hypothèses. Émis seulement si RELEVE_DEVICE (posé par footer.php) ;
// le serveur pose ensuite un drapeau de session.
// Aucune donnée personnelle supplémentaire n'est envoyée.
// ============================================================

function releveDevice() {
  if (typeof RELEVE_DEVICE === 'undefined' || !RELEVE_DEVICE) return;

  const nav = navigator;
  const uaData = nav.userAgentData || null;

  const donnees = {
    vp_w: window.innerWidth,
    vp_h: window.innerHeight,
    dpr: window.devicePixelRatio || 1,
    screen_w: (window.screen && window.screen.width) || '',
    screen_h: (window.screen && window.screen.height) || '',
    // Orientation déduite du viewport, et non de screen.orientation : c'est
    // la mesure qui décide réellement du palier CSS appliqué.
    orientation: window.innerWidth >= window.innerHeight ? 'landscape' : 'portrait',
    touch: nav.maxTouchPoints || 0,
    plateforme: (uaData && uaData.platform) || '',
    langue: nav.language || '',
    ua: nav.userAgent || '',
    csrf_token: getCsrfToken()
  };

  fetch(BASE_URL + '/include/ajax/releve-device.php', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams(donnees).toString()
  })
    .then(() => { RELEVE_DEVICE = false; })
    .catch(() => {});
}

document.addEventListener('DOMContentLoaded', releveDevice);

// ============================================================
// MOTEUR DE LISTE — comportements communs (SP-RS6b)
// Promus depuis js/compendium.js et js/admin.js, qui en portaient deux copies
// quasi identiques, et js/personnage.js une troisième sous le préfixe per*.
// Servent désormais les listes du compendium, des règles, de l'administration
// et des personnages.
//
// Variables injectées par le moteur PHP dans la page :
//   compUrlEnreg, compEntite, compUrlModifier, compUrlDetail
//   compSupprimerAction (optionnel — admin-liste.php)
//   compSuppression     (optionnel — {mode:'ajax', action:'...', param:'...'})
// ============================================================

// Menu ⋮ d'une ligne. `btn` est optionnel : quand il est fourni, le menu est
// positionné en fixed depuis le bouton et recadré dans le viewport (SP-RS3) ;
// sans lui, il reste positionné par le CSS de la page appelante.
function compToggleMenu(id, btn) {
  const menu = document.getElementById('comp-menu-' + id);
  if (!menu) return;

  document.querySelectorAll('.comp-menu-dropdown').forEach(m => {
    if (m !== menu) m.classList.add('noDisplay');
  });

  if (!menu.classList.contains('noDisplay')) {
    menu.classList.add('noDisplay');
    return;
  }

  // Affiché avant mesure : offsetWidth/offsetHeight valent 0 sous .noDisplay
  menu.classList.remove('noDisplay');

  if (btn) {
    const rect  = btn.getBoundingClientRect();
    const marge = 8;
    let left = rect.left;
    let top  = rect.bottom;

    if (left + menu.offsetWidth > window.innerWidth - marge) {
      left = window.innerWidth - menu.offsetWidth - marge;
    }
    if (left < marge) left = marge;
    if (top + menu.offsetHeight > window.innerHeight - marge) {
      top = Math.max(marge, rect.top - menu.offsetHeight);
    }

    menu.style.top  = top + 'px';
    menu.style.left = left + 'px';
  }

  setTimeout(() => {
    document.addEventListener('click', function handler(e) {
      if (!menu.contains(e.target)) {
        menu.classList.add('noDisplay');
        document.removeEventListener('click', handler);
      }
    });
  }, 0);
}

// Suppression inline — remplace la ligne par sa demande de confirmation
function compDemanderSuppression(id) {
  const row     = document.getElementById('row-' + id);
  const confirm = document.getElementById('comp-confirm-' + id);
  if (!row || !confirm) return;

  row.dataset.backup = row.innerHTML;
  const nbCols = row.querySelectorAll('td').length;
  row.innerHTML = `<td colspan="${nbCols}" class="comp-confirm-row">
    ${confirm.innerHTML}
  </td>`;
}

function compAnnulerSuppression(id) {
  // Rechargement plutôt que restauration du backup : les filtres GET sont
  // préservés et l'état de la ligne redevient exact.
  window.location.reload();
}

function compConfirmerSuppression(id) {
  // Mode AJAX : la page cible expose une action nommée qui répond en JSON
  // (module Personnages). Mode formulaire : contrat historique du compendium
  // et de l'administration, POST de ids[] vers enregistrement.php.
  if (typeof compSuppression !== 'undefined' && compSuppression && compSuppression.mode === 'ajax') {
    const charge = { action: compSuppression.action };
    charge[compSuppression.param || 'id'] = id;

    // confirmation_requise : le serveur refuse la suppression tant que
    // l'utilisateur n'a pas vu l'avertissement (SP-TB10 — un tableau encore
    // inséré quelque part). On réémet la requête avec force=1 après accord.
    const envoyer = (force) => {
      postAjax(compUrlEnreg, force ? { ...charge, force: 1 } : charge)
        .then(data => {
          if (data.ok) { rafraichirListe(); return; }
          if (data.confirmation_requise && !force) {
            confirmer(data.erreur, () => envoyer(true), () => compAnnulerSuppression(id));
            return;
          }
          alert(data.erreur || 'Erreur lors de la suppression.');
          compAnnulerSuppression(id);
        })
        .catch(err => {
          alert('Erreur : ' + err);
          compAnnulerSuppression(id);
        });
    };

    envoyer(false);
    return;
  }

  const form = document.getElementById('comp-bulk-form');
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

// Duplique une seule ligne (menu ⋮ — cf. $listConfig['action_dupliquer']).
// Réutilise le formulaire de la suppression ; pas de confirmation, l'action
// n'est pas destructive.
function compDupliquer(id) {
  const form = document.getElementById('comp-bulk-form');
  if (!form) return;

  document.getElementById('comp-bulk-action-hidden').value = 'dupliquer';
  document.getElementById('comp-bulk-ids').innerHTML =
    `<input type="hidden" name="ids[]" value="${id}">`;
  form.submit();
}

// --- Sélection multiple et barre d'actions groupées -------------------------

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

  // Confirmation systématique (comportement de l'administration), avec un
  // message explicite pour la suppression (comportement du compendium).
  const message = action === 'supprimer'
    ? `Supprimer ${checked.length} élément(s) ? Cette action est irréversible.`
    : `Appliquer "${action}" sur ${checked.length} élément(s) ?`;
  if (!confirm(message)) return;

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

function rafraichirListe() {
  window.location.reload();
}

// Sélection multiple : câblage des cases à cocher
document.addEventListener('DOMContentLoaded', function () {
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
    if (e.target.classList && e.target.classList.contains('comp-check')) compMajBulkBar();
  });
});
