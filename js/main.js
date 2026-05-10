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
let _detailPpUrl     = '';
let _detailPpParams  = {};

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
// ============================================================

// Charge #detail-pp via GET — lecture seule
function actualiserPage(url, params = {}, context = 'externe') {
  _detailPpContext = context;
  _detailPpUrl     = url;
  _detailPpParams  = params;

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
      panel.innerHTML = closeBtn + html;
    })
    .catch(err => { panel.innerHTML = '<p class="erreur">' + err + '</p>'; });
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
    ? url + '?' + new URLSearchParams(params).toString()
    : url;

  fetch(fullUrl)
    .then(r => { if (!r.ok) throw new Error('Erreur ' + r.status); return r.text(); })
    .then(html => { panel.innerHTML = html; })
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
  if (backdrop)   backdrop.classList.add('noDisplay');
}

// Ferme #detail-pp (et #modification si ouvert)
function fermerDetailPP() {
  const panel    = document.getElementById('detail-pp');
  const backdrop = document.getElementById('detail-pp-backdrop');
  if (panel)    { panel.classList.add('noDisplay'); panel.innerHTML = ''; }
  if (backdrop)   backdrop.classList.add('noDisplay');
  fermerModification();
}

// ============================================================
// POST AJAX — écriture vers enregistrement.php
// ============================================================

async function postAjax(url, data = {}) {
  const body = new URLSearchParams(data);
  body.append('csrf_token', getCsrfToken());
  const response = await fetch(url, {
    method:  'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body:    body.toString(),
  });
  if (!response.ok) throw new Error('Erreur ' + response.status);
  return response.json();
}

// Appelé après enregistrement AJAX — data = { ok, id, url_detail }
function apresModification(data) {
  fermerModification();
  actualiserPage(data.url_detail, { id: data.id }, _detailPpContext);
  if (_detailPpContext === 'liste') rafraichirListe();
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
