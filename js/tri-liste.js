// js/tri-liste.js — Réordonnancement par glisser-déposer (SP-CP1)
// Composant transverse, chargé sur toutes les pages (include/footer.php).
// Aucune dépendance au module Campagnes : utilisable partout où une liste
// porte un ordre d'affichage stocké en base.
'use strict';

// ============================================================
// CONTRAT HTML
// ============================================================
//
//   <tbody class="tri-liste"
//          data-tri-url="/donjon/campagnes/enregistrement.php?ajax=1"
//          data-tri-action="reordonnerRencontres"
//          data-tri-parent="42">          ← id du parent (facultatif mais
//     <tr data-tri-id="7">                  attendu par les actions campagnes)
//       <td class="tri-poignee"><i class="fa fa-grip-vertical"></i></td>
//       …
//     </tr>
//   </tbody>
//
// - Le conteneur porte data-tri-url : c'est lui qui délimite le lot trié.
// - Chaque enfant DIRECT triable porte data-tri-id.
// - La prise se fait uniquement sur .tri-poignee : les cellules restent
//   cliquables pour naviguer, et un glissement accidentel est impossible.
// - Le POST envoie { action, parent_id, ids } où ids = les data-tri-id dans
//   le nouvel ordre, séparés par des virgules. Le serveur écrit le rang.
//
// Fonctionne sur <tbody>/<tr> comme sur <div>/<div> — le moteur ne connaît
// que « un conteneur, des enfants directs identifiés ».
//
// Pointer Events (et non l'API drag&drop HTML5) : un seul jeu d'événements
// pour souris et tactile, et setPointerCapture() garantit de recevoir tous
// les déplacements même quand le curseur sort de la ligne saisie.

var _triLigne     = null;  // ligne en cours de déplacement
var _triConteneur = null;  // son conteneur
var _triOrdreInit = '';    // ordre au moment de la prise, pour ne rien poster si rien n'a bougé
var _triPointerId = null;

// Ids des enfants directs triables, dans l'ordre du DOM.
function _triIds(conteneur) {
  return Array.prototype.map.call(
    conteneur.querySelectorAll(':scope > [data-tri-id]'),
    function (el) { return el.getAttribute('data-tri-id'); }
  );
}

document.addEventListener('pointerdown', function (e) {
  var poignee = e.target.closest ? e.target.closest('.tri-poignee') : null;
  if (!poignee) return;

  var ligne = poignee.closest('[data-tri-id]');
  if (!ligne) return;
  var conteneur = ligne.parentNode;
  if (!conteneur || !conteneur.hasAttribute('data-tri-url')) return;

  _triLigne     = ligne;
  _triConteneur = conteneur;
  _triOrdreInit = _triIds(conteneur).join(',');
  _triPointerId = e.pointerId;

  ligne.classList.add('tri-ligne--saisie');
  conteneur.classList.add('tri-liste--actif');
  // La capture est posée sur la poignée : le pointeur peut ensuite sortir de
  // la ligne (et même du conteneur) sans qu'on perde les pointermove.
  if (poignee.setPointerCapture) poignee.setPointerCapture(e.pointerId);
  e.preventDefault(); // pas de sélection de texte ni de scroll tactile pendant la prise
});

document.addEventListener('pointermove', function (e) {
  if (!_triLigne || e.pointerId !== _triPointerId) return;

  // Première ligne (hors ligne saisie) dont on n'a pas encore dépassé le
  // milieu : la ligne saisie vient s'insérer juste avant. Si aucune, elle va
  // en fin de liste. Déplacement réel dans le DOM — le rendu suit tout seul.
  var cible = null;
  var freres = _triConteneur.querySelectorAll(':scope > [data-tri-id]');
  for (var i = 0; i < freres.length; i++) {
    if (freres[i] === _triLigne) continue;
    var box = freres[i].getBoundingClientRect();
    if (e.clientY < box.top + box.height / 2) { cible = freres[i]; break; }
  }

  if (cible) {
    if (cible !== _triLigne.nextSibling) _triConteneur.insertBefore(_triLigne, cible);
  } else if (_triLigne !== _triConteneur.lastElementChild) {
    _triConteneur.appendChild(_triLigne);
  }
});

function _triRelacher() {
  if (!_triLigne) return;

  var ligne     = _triLigne;
  var conteneur = _triConteneur;
  var ordreInit = _triOrdreInit;

  _triLigne = _triConteneur = null;
  _triPointerId = null;
  ligne.classList.remove('tri-ligne--saisie');
  conteneur.classList.remove('tri-liste--actif');

  var ids = _triIds(conteneur);
  if (ids.join(',') === ordreInit) return; // reposée au même endroit : rien à écrire

  var donnees = {
    action: conteneur.getAttribute('data-tri-action'),
    ids:    ids.join(','),
  };
  var parent = conteneur.getAttribute('data-tri-parent');
  if (parent) donnees.parent_id = parent;

  postAjax(conteneur.getAttribute('data-tri-url'), donnees)
    .then(function (data) {
      if (data.ok) {
        notifier('Ordre enregistré');
      } else {
        // L'ordre affiché ne correspond plus à la base : on recharge plutôt
        // que de laisser l'utilisateur travailler sur un classement faux.
        notifier(data.erreur || "Ordre non enregistré", 'erreur');
        setTimeout(function () { window.location.reload(); }, 1200);
      }
    })
    .catch(function (err) {
      notifier('Ordre non enregistré : ' + err, 'erreur');
      setTimeout(function () { window.location.reload(); }, 1200);
    });
}

document.addEventListener('pointerup', _triRelacher);
document.addEventListener('pointercancel', _triRelacher);
