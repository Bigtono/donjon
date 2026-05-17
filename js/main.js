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
// PATTERN DETAIL-PP / MODIFICATION
// ============================================================

// Charge #detail-pp via GET — lecture seule
function actualiserPage(url, params = {}, context = 'externe') {
  _detailPpContext = context;
  _detailPpUrl = url;
  _detailPpParams = params;

  const panel = document.getElementById('detail-pp');
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
      panel.innerHTML = closeBtn + html;
    })
    .catch(err => { panel.innerHTML = '<p class="erreur">' + err + '</p>'; });
}

// Charge #modification via GET — lecture initiale du formulaire
function actualiserPageModif(url, params = {}) {
  const panel = document.getElementById('modification');
  const backdrop = document.getElementById('modification-backdrop');
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
  const panel = document.getElementById('modification');
  const backdrop = document.getElementById('modification-backdrop');
  if (panel) { panel.classList.add('noDisplay'); panel.innerHTML = ''; }
  if (backdrop) backdrop.classList.add('noDisplay');
}

// Ferme #detail-pp (et #modification et #detail-pp-sub si ouverts)
function fermerDetailPP() {
  const panel = document.getElementById('detail-pp');
  const backdrop = document.getElementById('detail-pp-backdrop');
  if (panel) { panel.classList.add('noDisplay'); panel.innerHTML = ''; }
  if (backdrop) backdrop.classList.add('noDisplay');
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
// dans une fiche (capacité, compétence, sort…) sans fermer
// le panel principal.
// ============================================================

// Charge #detail-pp-sub via GET — lecture seule
function actualiserPageSub(url, params = {}) {
  const panel = document.getElementById('detail-pp-sub');
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
    })
    .catch(err => { panel.innerHTML = '<p class="erreur">' + err + '</p>'; });
}

// Ferme #detail-pp-sub sans toucher au panel principal
function fermerSubPanel() {
  const panel = document.getElementById('detail-pp-sub');
  const backdrop = document.getElementById('detail-pp-sub-backdrop');
  if (panel) { panel.classList.add('noDisplay'); panel.innerHTML = ''; }
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
    // Pose le flag : liste à recharger à la fermeture de detail-pp
    // On l'active dès qu'il existe une liste sur la page courante
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
