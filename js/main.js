// js/main.js — Fonctions transverses Codex DD
// Chargé sur toutes les pages après le contenu

'use strict';

// ============================================================
// CSRF — récupère le token depuis le cookie de session
// (le token est injecté dans chaque page via un meta tag)
// ============================================================

function getCsrfToken() {
  const meta = document.querySelector('meta[name="csrf-token"]');
  return meta ? meta.getAttribute('content') : '';
}

// ============================================================
// BLOCS REPLIABLES (burger)
// ============================================================

// togglePlus(id) — affiche/masque un bloc accordion
function togglePlus(id) {
  const el = document.getElementById(id);
  if (!el) return;
  el.classList.toggle('noDisplay');
}

// ============================================================
// PATTERN DETAIL-PP / MODIFICATION
// ============================================================

// Charge du contenu HTML dans #detail-pp via AJAX
function actualiserPage(url, params = {}) {
  const panel = document.getElementById('detail-pp');
  if (!panel) return;

  panel.classList.remove('noDisplay');
  panel.innerHTML = '<div class="loading"><i class="fa fa-spinner fa-spin"></i> Chargement…</div>';

  fetchPanel(url, params)
    .then(html => { panel.innerHTML = html; })
    .catch(err => { panel.innerHTML = '<p class="erreur">' + err + '</p>'; });
}

// Charge du contenu HTML dans #modification via AJAX
// N'affecte PAS #detail-pp
function actualiserPageModif(url, params = {}) {
  const panel = document.getElementById('modification');
  if (!panel) return;

  panel.classList.remove('noDisplay');
  panel.innerHTML = '<div class="loading"><i class="fa fa-spinner fa-spin"></i> Chargement…</div>';

  fetchPanel(url, params)
    .then(html => { panel.innerHTML = html; })
    .catch(err => { panel.innerHTML = '<p class="erreur">' + err + '</p>'; });
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

// Requête AJAX commune (GET ou POST selon params)
async function fetchPanel(url, params = {}) {
  const isPost = Object.keys(params).length > 0;
  let response;

  if (isPost) {
    const body = new URLSearchParams(params);
    body.append('csrf_token', getCsrfToken());
    response = await fetch(url, {
      method:  'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body:    body.toString(),
    });
  }
  else {
    response = await fetch(url);
  }

  if (!response.ok) throw new Error('Erreur ' + response.status);
  return response.text();
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
