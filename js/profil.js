// js/profil.js — Navigation sections profil

'use strict';

function showSection(id, btn) {
  // Masque toutes les sections
  document.querySelectorAll('.profil-section').forEach(s => s.classList.add('noDisplay'));
  // Retire l'état actif de tous les boutons
  document.querySelectorAll('.profil-nav__btn').forEach(b => b.classList.remove('active'));

  // Affiche la section cible
  const target = document.getElementById('section-' + id);
  if (target) target.classList.remove('noDisplay');

  // Active le bouton cliqué
  if (btn) btn.classList.add('active');
}

// À l'init : si erreur PHP sur une section précise, afficher la bonne section
document.addEventListener('DOMContentLoaded', () => {
  const flash = document.querySelector('.flash-message--error');
  if (!flash) return;

  // Détecte quelle section était active au POST (via le champ hidden)
  const form = document.querySelector('form');
  if (!form) return;
  const section = form.querySelector('input[name="section"]');
  if (!section) return;

  const id  = section.value;
  const btn = document.querySelector(`.profil-nav__btn[onclick*="${id}"]`);
  showSection(id, btn);
});
