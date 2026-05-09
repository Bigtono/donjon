// js/main.js — Fonctions transverses Codex DD
// Chargé sur toutes les pages après le contenu

'use strict';

// ============================================================
// CSRF
// ============================================================

function getCsrfToken() {
  const meta = document.querySelector('meta[name="csrf-token"]');
  return meta ? meta.getAttribute('content') : '';
}

// ============================================================
// BLOCS REPLIABLES (burger)
// ============================================================

function togglePlus(id) {
  const el = document.getElementById(id);
  if (!el) return;
  el.classList.toggle('noDisplay');
}

// ============================================================
// PATTERN DETAIL-PP / MODIFICATION
// Contexte d'ouverture de detail-pp :
//   'liste'   — ouvert depuis une liste compendium
//   'externe' — ouvert depuis toute autre page (défaut)
// Détermine ce qui est rafraîchi après une modification.
// ============================================================

let _detailPpContext = 'externe';
let _detailPpUrl = '';
let _detailPpParams = {};

// Charge du contenu HTML dans #detail-pp via GET
// Les endpoints detail-pp sont des lectures — params passés dans l'URL
function actualiserPage(url, params = {}, context = 'externe') {
  _detailPpContext = context;
  _detailPpUrl = url;
  _detailPpParams = params;

  const panel = document.getElementById('detail-pp');
  if (!panel) return;

  panel.classList.remove('noDisplay');
  panel.innerHTML = '<div class="loading"><i class="fa fa-spinner fa-spin"></i> Chargement…</div>';

  // GET — params ajoutés dans l'URL
  const fullUrl = Object.keys(params).length > 0
    ? url + '?' + new URLSearchParams(params).toString()
    : url;

  fetch(fullUrl)
    .then(r => {
      if (!r.ok) throw new Error('Erreur ' + r.status);
      return r.text();
    })
    .then(html => { panel.innerHTML = html; })
    .catch(err => { panel.innerHTML = '<p class="erreur">' + err + '</p>'; });
}

// Charge du contenu HTML dans #modification via GET
// N'affecte PAS #detail-pp
function actualiserPageModif(url, params = {}) {
  const panel = document.getElementById('modification');
  if (!panel) return;

  panel.classList.remove('noDisplay');
  panel.innerHTML = '<div class="loading"><i class="fa fa-spinner fa-spin"></i> Chargement…</div>';

  // GET — le formulaire de modification est aussi une lecture initiale
  const fullUrl = Object.keys(params).length > 0
    ? url + '?' + new URLSearchParams(params).toString()
    : url;

  fetch(fullUrl)
    .then(r => {
      if (!r.ok) throw new Error('Erreur ' + r.status);
      return r.text();
    })
    .then(html => { panel.innerHTML = html; })
    .catch(err => { panel.innerHTML = '<p class="erreur">' + err + '</p>'; });
}

// Ouvre le formulaire de modification depuis un bouton dans detail-pp
function ouvrirModifier(url, id) {
  actualiserPageModif(url, { id: id });
}

// Ferme #modification sans toucher à #detail-pp
function fermerModification() {
  const panel = document.getElementById('modification');
  if (panel) {
    panel.classList.add('noDisplay');
    panel.innerHTML = '';
  }
}

// Ferme #detail-pp
function fermerDetailPP() {
  const panel = document.getElementById('detail-pp');
  if (panel) {
    panel.classList.add('noDisplay');
    panel.innerHTML = '';
  }
}

// ============================================================
// APRÈS MODIFICATION — appelé par enregistrement.php (mode AJAX)
// data = { ok, id, url_detail }
// ============================================================

function apresModification(data) {
  fermerModification();
  // Rafraîchit toujours detail-pp
  actualiserPage(data.url_detail, { id: data.id }, _detailPpContext);
  // Rafraîchit la liste si ouvert depuis une liste compendium
  if (_detailPpContext === 'liste') {
    rafraichirListe();
  }
}

function rafraichirListe() {
  window.location.reload();
}

// ============================================================
// REQUÊTE POST AJAX (pour enregistrement.php)
// Utilisé uniquement pour les soumissions de formulaires (écriture)
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
