// js/regles.js — Module Règles (Codex DD v2)
// Dépend de main.js (actualiserPageSub, fermerDetailPP, ouvrirModifier, postAjax, confirmer).
// BASE_URL et REGLES_* sont injectés par les pages PHP.
'use strict';

// ============================================================
// TOGGLE SOMMAIRE (mobile)
// ============================================================

document.addEventListener('DOMContentLoaded', function () {
  var toggle  = document.getElementById('regles-sommaire-toggle');
  var aside   = document.getElementById('regles-sommaire-aside');
  var inner   = document.getElementById('regles-sommaire-inner');

  if (toggle && aside && inner) {
    toggle.addEventListener('click', function () {
      var ouvert = toggle.getAttribute('aria-expanded') === 'true';
      toggle.setAttribute('aria-expanded', String(!ouvert));
      inner.classList.toggle('regles-sommaire__inner--visible', !ouvert);
    });
  }

  // ============================================================
  // HANDLER DÉLÉGUÉ — .glossaire-lien
  // Ouvre la définition d'un terme dans #detail-pp-sub.
  // Un clic dans le sous-panneau rappelle actualiserPageSub()
  // et remplace le contenu sur place (pas d'empilement).
  // Référence : doc/ARCHITECTURE_0_REFERENCE.md §9b + §12
  // ============================================================

  document.addEventListener('click', function (e) {
    var lien = e.target.closest('.glossaire-lien');
    if (!lien) return;
    e.preventDefault();
    var slug = lien.getAttribute('data-glossaire-slug');
    if (!slug) return;
    if (typeof actualiserPageSub === 'function') {
      actualiserPageSub(
        BASE_URL + '/include/ajax/detail-pp-sub/glossaire.php',
        { slug: slug }
      );
    }
  });

  // ============================================================
  // SURLIGNAGE DU TERME DE RECHERCHE
  // Appliqué côté JS sur les nœuds texte du DOM pour ne jamais
  // casser le HTML TinyMCE (pas de str_replace côté serveur).
  // Référence : DECISIONS_LOG — surlignage recherche JS uniquement
  // ============================================================

  if (typeof REGLES_TERME_SURLIGNÉ !== 'undefined' && REGLES_TERME_SURLIGNÉ) {
    var zone = document.getElementById('regles-texte');
    if (zone) _surlignerDom(zone, REGLES_TERME_SURLIGNÉ);
  }

  // ============================================================
  // DRAG & DROP — réordonnancement du sous-sommaire
  // ============================================================

  if (typeof REGLES_PEUT_EDITER !== 'undefined' && REGLES_PEUT_EDITER) {
    _initDragDrop();
  }
});

// ============================================================
// SURLIGNAGE DOM (texte uniquement, hors balises)
// ============================================================

function _surlignerDom(container, terme) {
  if (!terme) return;
  var walker = document.createTreeWalker(
    container,
    NodeFilter.SHOW_TEXT,
    {
      acceptNode: function (node) {
        // Ignore les textes dans les balises <a> et <mark>
        var parent = node.parentNode;
        if (parent && (parent.tagName === 'A' || parent.tagName === 'MARK')) {
          return NodeFilter.FILTER_REJECT;
        }
        return NodeFilter.FILTER_ACCEPT;
      }
    }
  );

  var nodesATraiter = [];
  var noeud;
  while ((noeud = walker.nextNode())) nodesATraiter.push(noeud);

  var re = new RegExp('(' + _escapeRegex(terme) + ')', 'gi');
  nodesATraiter.forEach(function (textNode) {
    if (!re.test(textNode.textContent)) return;
    re.lastIndex = 0;
    var frag = document.createDocumentFragment();
    var dernier = 0;
    var texte   = textNode.textContent;
    var m;
    while ((m = re.exec(texte)) !== null) {
      if (m.index > dernier) {
        frag.appendChild(document.createTextNode(texte.slice(dernier, m.index)));
      }
      var mark = document.createElement('mark');
      mark.className = 'regles-surligné';
      mark.textContent = m[1];
      frag.appendChild(mark);
      dernier = re.lastIndex;
    }
    if (dernier < texte.length) {
      frag.appendChild(document.createTextNode(texte.slice(dernier)));
    }
    textNode.parentNode.replaceChild(frag, textNode);
  });
}

function _escapeRegex(s) {
  return s.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
}

// ============================================================
// SUPPRESSION — confirmation inline
// ============================================================

function reglesConfirmerSuppression(id, aDesEnfants) {
  if (aDesEnfants) {
    alert('Ce nœud contient des sous-éléments. Déplacez-les ou supprimez-les d\'abord.');
    return;
  }
  var msg = 'Supprimer définitivement ce nœud ? Cette action est irréversible.';
  confirmer(msg, function () {
    reglesSupprimer(id);
  });
}

function reglesSupprimer(id) {
  var url   = BASE_URL + '/regles/enregistrement.php?ajax=1';
  var csrf  = document.querySelector('meta[name="csrf-token"]');
  var token = csrf ? csrf.getAttribute('content') : '';

  var data = new URLSearchParams({
    action:     'supprimer',
    csrf_token: token,
    reg_id:     id,
  });

  fetch(url, {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: data.toString(),
  })
  .then(function (r) { return r.json(); })
  .then(function (res) {
    if (res.ok) {
      window.location.href = BASE_URL + '/regles/index.php';
    } else {
      alert(res.erreur || 'Erreur lors de la suppression.');
    }
  })
  .catch(function (e) { alert('Erreur réseau : ' + e); });
}

// ============================================================
// DRAG & DROP réordonnancement des enfants
// Utilise HTML5 drag-and-drop natif sur la liste .regles-sous-sommaire__liste.
// Persiste via regles/enregistrement.php?action=reordonner (JSON).
// ============================================================

function _initDragDrop() {
  var liste = document.querySelector('.regles-sous-sommaire__liste');
  if (!liste) return;

  var items = Array.from(liste.querySelectorAll('.regles-sous-sommaire__item'));
  var dragSrc = null;

  items.forEach(function (item) {
    item.setAttribute('draggable', 'true');

    item.addEventListener('dragstart', function (e) {
      dragSrc = item;
      e.dataTransfer.effectAllowed = 'move';
      item.classList.add('drag-en-cours');
    });

    item.addEventListener('dragend', function () {
      item.classList.remove('drag-en-cours');
      liste.querySelectorAll('.drag-survol').forEach(function (el) {
        el.classList.remove('drag-survol');
      });
    });

    item.addEventListener('dragover', function (e) {
      e.preventDefault();
      e.dataTransfer.dropEffect = 'move';
      if (item !== dragSrc) item.classList.add('drag-survol');
    });

    item.addEventListener('dragleave', function () {
      item.classList.remove('drag-survol');
    });

    item.addEventListener('drop', function (e) {
      e.stopPropagation();
      item.classList.remove('drag-survol');
      if (!dragSrc || dragSrc === item) return;

      // Réinsère dragSrc avant item dans le DOM
      liste.insertBefore(dragSrc, item);

      // Persiste le nouvel ordre
      _persistOrdre(liste);
    });
  });
}

function _persistOrdre(liste) {
  var parentId = (typeof REGLES_ID_COURANT !== 'undefined') ? REGLES_ID_COURANT : 0;
  var items    = Array.from(liste.querySelectorAll('.regles-sous-sommaire__item'));
  var payload  = items.map(function (el, idx) {
    var lien = el.querySelector('.regles-sous-sommaire__lien');
    if (!lien) return null;
    // L'id est encodé dans l'URL : .../regle.php?id=XX
    var m = (lien.getAttribute('href') || '').match(/[?&]id=(\d+)/);
    if (!m) return null;
    return { id: parseInt(m[1], 10), parent: parentId, ordre: idx };
  }).filter(Boolean);

  if (!payload.length) return;

  var csrf  = document.querySelector('meta[name="csrf-token"]');
  var token = csrf ? csrf.getAttribute('content') : '';
  var url   = BASE_URL + '/regles/enregistrement.php?ajax=1';

  var data = new URLSearchParams({
    action:      'reordonner',
    csrf_token:  token,
    ordre_json:  JSON.stringify(payload),
  });

  fetch(url, {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: data.toString(),
  })
  .then(function (r) { return r.json(); })
  .then(function (res) {
    if (!res.ok) console.error('Réordonnancement échoué :', res.erreur);
  })
  .catch(function (e) { console.error('Réordonnancement réseau :', e); });
}
