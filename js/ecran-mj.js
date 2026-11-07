// js/ecran-mj.js — Écran du MJ (SP-TB8).
//
// Surcouche plein écran #ecran-mj (z-index 190, sous #detail-pp : les liens des
// cellules ouvrent leur fiche par-dessus). Chargé par include/campagne-outils.php.
//
// Modèle : l'ordre des .ecran-mj__item dans la grille est l'ORDRE GLOBAL de
// placement. Chaque élément porte data-col (colonne de départ) et data-largeur
// (1 ou 2). placer() pose les éléments dans cet ordre, chacun au plus haut des
// colonnes qu'il couvre — voir doc/ARCHITECTURE_0_REFERENCE.md §9c.
//
// Deux modes : consultation (repliage seul, non enregistré) et organisation
// (classe .ecran-mj--orga : glisser-déposer, colonnes, largeur, retrait, ajout,
// duplication), conclu par Enregistrer ou Annuler.
//
// API globale (appelée par les sous-panneaux) :
//   ecranMJOuvrir(campId) · ecranMJAjouter(ids) · ecranMJCharger(source, from)

(function () {
  var URL_ECRAN = function () { return BASE_URL + '/include/ajax/ecran-mj.php'; };
  var URL_SUB   = function (f) { return BASE_URL + '/include/ajax/detail-pp-sub/' + f; };
  var URL_ENREG = function () { return BASE_URL + '/campagnes/enregistrement.php?ajax=1'; };
  var ECART     = 16; // px entre colonnes et entre tableaux (= --sp-md)

  var racine   = null; // #ecran-mj
  var campId   = 0;
  var colonnes = 3;
  var modifie  = false;
  var glisse   = null; // élément en cours de déplacement
  var rafId    = 0;

  // ── Accès DOM ────────────────────────────────────────────────────────────
  function grille()   { return racine ? racine.querySelector('.ecran-mj__grille') : null; }
  function elements() { var g = grille(); return g ? Array.from(g.querySelectorAll(':scope > .ecran-mj__item')) : []; }
  function enOrga()   { return racine && racine.classList.contains('ecran-mj--orga'); }

  function marquerModifie() { modifie = true; }

  // ── Placement ────────────────────────────────────────────────────────────
  // Hauteurs courantes des colonnes après placement, réutilisées par l'ajout
  // (colonne la plus courte).
  var hauteurs = [];

  function placer() {
    var g = grille();
    if (!g) return;
    var items = elements();
    racine.classList.toggle('ecran-mj--vide', items.length === 0);

    var larg = g.clientWidth;
    var colW = (larg - ECART * (colonnes - 1)) / colonnes;
    hauteurs = [];
    for (var i = 0; i < colonnes; i++) hauteurs.push(0);

    items.forEach(function (it) {
      var L = Math.min(parseInt(it.getAttribute('data-largeur'), 10) === 2 ? 2 : 1, colonnes);
      var c = parseInt(it.getAttribute('data-col'), 10) || 0;
      // Hors limite (colonnes réduites, largeur 2 en dernière colonne) : ramené.
      c = Math.max(0, Math.min(c, colonnes - L));
      it.setAttribute('data-col', c);

      it.style.width = (L * colW + (L - 1) * ECART) + 'px';
      it.style.left  = (c * (colW + ECART)) + 'px';
      var haut = 0;
      for (var k = c; k < c + L; k++) haut = Math.max(haut, hauteurs[k]);
      it.style.top = haut + 'px';
      var bas = haut + it.offsetHeight + ECART;
      for (var k2 = c; k2 < c + L; k2++) hauteurs[k2] = bas;

      var lib = it.querySelector('.ecran-mj__largeur-lib');
      if (lib) lib.textContent = L;
    });

    g.style.height = Math.max.apply(null, hauteurs.concat([0])) + 'px';
    placerBandes(colW);
  }

  // Bandes de colonnes : cibles de dépôt du vide d'une colonne, visibles en
  // mode organisation.
  function placerBandes(colW) {
    var g = grille();
    var bandes = Array.from(g.querySelectorAll(':scope > .ecran-mj__bande'));
    while (bandes.length < colonnes) {
      var b = document.createElement('div');
      b.className = 'ecran-mj__bande';
      g.insertBefore(b, g.firstChild);
      bandes.push(b);
    }
    bandes.forEach(function (b, i) {
      if (i >= colonnes) { b.remove(); return; }
      b.setAttribute('data-col', i);
      b.style.left  = (i * (colW + ECART)) + 'px';
      b.style.width = colW + 'px';
    });
  }

  function replacerBientot() {
    if (rafId) cancelAnimationFrame(rafId);
    rafId = requestAnimationFrame(function () { rafId = 0; placer(); });
  }

  // ── Ouverture / fermeture ────────────────────────────────────────────────
  function ouvrir(id) {
    campId = parseInt(id, 10) || 0;
    if (!campId) return;
    if (!racine) {
      racine = document.createElement('div');
      racine.id = 'ecran-mj';
      racine.className = 'ecran-mj';
      racine.setAttribute('role', 'dialog');
      racine.setAttribute('aria-label', 'Écran du MJ');
      document.body.appendChild(racine);
      racine.addEventListener('click', surClic);
      racine.addEventListener('change', surChangement);
      brancherGlisser();
    }
    document.body.classList.add('ecran-mj-ouvert');
    racine.classList.remove('noDisplay');
    charger();
  }

  // (Re)charge la disposition enregistrée — ouverture et « Annuler ».
  function charger() {
    racine.classList.remove('ecran-mj--orga');
    racine.innerHTML = '<div class="loading"><i class="fa fa-spinner fa-spin"></i> Chargement…</div>';
    fetch(URL_ECRAN() + '?camp_id=' + encodeURIComponent(campId))
      .then(function (r) { if (!r.ok) throw new Error('Erreur ' + r.status); return r.text(); })
      .then(function (html) {
        racine.innerHTML = html;
        var cfg = racine.querySelector('.ecran-mj__config');
        colonnes = cfg ? (JSON.parse(cfg.textContent).colonnes || 3) : 3;
        modifie = false;
        placer();
        // Les tableaux se mettent en page après le chargement des polices.
        if (document.fonts && document.fonts.ready) document.fonts.ready.then(replacerBientot);
      })
      .catch(function (err) {
        racine.innerHTML = '<p class="erreur">' + err.message + '</p>'
          + '<button type="button" class="btn btn-secondary btn-sm" data-ecran-action="fermer">Fermer</button>';
      });
  }

  function fermer() {
    if (!racine) return;
    if (modifie && !confirm('Les modifications de l\'écran ne sont pas enregistrées. Fermer quand même ?')) return;
    modifie = false;
    racine.classList.add('noDisplay');
    racine.innerHTML = '';
    document.body.classList.remove('ecran-mj-ouvert');
  }

  function ouvert() { return racine && !racine.classList.contains('noDisplay'); }

  // ── Actions ──────────────────────────────────────────────────────────────
  function passerEnOrga() {
    racine.classList.add('ecran-mj--orga');
    replacerBientot();
  }

  function surClic(e) {
    var btn = e.target.closest('[data-ecran-action]');
    if (!btn || !racine.contains(btn)) return;
    var action = btn.getAttribute('data-ecran-action');
    var item   = btn.closest('.ecran-mj__item');

    switch (action) {
      case 'fermer':    fermer(); break;
      case 'organiser': passerEnOrga(); break;
      case 'annuler':
        if (!modifie || confirm('Abandonner les modifications ?')) { modifie = false; charger(); }
        break;
      case 'enregistrer': enregistrer(btn); break;
      case 'ajouter':
        passerEnOrga();
        actualiserPageSub(URL_SUB('ecran-mj-picker.php'), {
          camp_id: campId,
          exclus: elements().map(function (it) { return it.getAttribute('data-tab-id'); }).join(',')
        });
        break;
      case 'dupliquer':
        passerEnOrga();
        actualiserPageSub(URL_SUB('ecran-mj-dupliquer.php'), { camp_id: campId });
        break;
      case 'proposee':
        passerEnOrga();
        ecranMJCharger('proposee');
        break;
      case 'replier':
        if (!item) return;
        var replie = item.classList.toggle('ecran-mj__item--replie');
        btn.setAttribute('aria-expanded', replie ? 'false' : 'true');
        if (enOrga()) marquerModifie();
        replacerBientot();
        break;
      case 'largeur':
        if (!item) return;
        item.setAttribute('data-largeur', item.getAttribute('data-largeur') === '2' ? '1' : '2');
        marquerModifie();
        replacerBientot();
        break;
      case 'retirer':
        if (!item) return;
        item.remove();
        marquerModifie();
        replacerBientot();
        break;
    }
  }

  function surChangement(e) {
    if (e.target.matches('[data-ecran-champ="colonnes"]')) {
      colonnes = parseInt(e.target.value, 10) || 3;
      marquerModifie();
      placer();
    }
  }

  function enregistrer(btn) {
    var payload = elements().map(function (it) {
      return {
        tab_id:  parseInt(it.getAttribute('data-tab-id'), 10),
        col:     parseInt(it.getAttribute('data-col'), 10) || 0,
        largeur: it.getAttribute('data-largeur') === '2' ? 2 : 1,
        replie:  it.classList.contains('ecran-mj__item--replie') ? 1 : 0
      };
    });
    btn.disabled = true;
    postAjax(URL_ENREG(), {
      action:   'enregistrerEcranMJ',
      camp_id:  campId,
      colonnes: colonnes,
      elements: JSON.stringify(payload)
    })
      .then(function (data) {
        btn.disabled = false;
        if (!data.ok) { alert(data.erreur || 'Échec de l\'enregistrement.'); return; }
        modifie = false;
        racine.classList.remove('ecran-mj--orga');
        replacerBientot();
      })
      .catch(function (err) { btn.disabled = false; alert(err.message); });
  }

  // ── Préremplissage (ajout, sélection proposée, duplication) ──────────────
  function fragment(params) {
    params.camp_id = campId;
    return fetch(URL_ECRAN() + '?' + new URLSearchParams(params).toString())
      .then(function (r) { return r.json(); })
      .then(function (data) {
        if (!data.ok) throw new Error(data.erreur || 'Erreur');
        var tmp = document.createElement('div');
        tmp.innerHTML = data.html;
        data.items = Array.from(tmp.children);
        return data;
      });
  }

  // Ajoute des tableaux, chacun en bas de la colonne la plus courte.
  window.ecranMJAjouter = function (ids) {
    if (!ouvert() || !ids || !ids.length) return;
    fragment({ vue: 'elements', ids: ids.join(',') })
      .then(function (data) {
        var g = grille();
        placer();
        data.items.forEach(function (it) {
          var min = 0;
          for (var i = 1; i < hauteurs.length; i++) if (hauteurs[i] < hauteurs[min]) min = i;
          it.setAttribute('data-col', min);
          g.appendChild(it);
          placer();
        });
        marquerModifie();
      })
      .catch(function (err) { alert(err.message); });
  };

  // Remplace la disposition en cours : 'proposee' ou 'camp' (from = campagne source).
  window.ecranMJCharger = function (source, from) {
    if (!ouvert()) return;
    if (elements().length && !confirm('Remplacer la disposition en cours ?')) return;
    var params = source === 'camp' ? { vue: 'camp', from: from } : { vue: 'proposee', colonnes: colonnes };
    fragment(params)
      .then(function (data) {
        var g = grille();
        elements().forEach(function (it) { it.remove(); });
        data.items.forEach(function (it) { g.appendChild(it); });
        if (data.colonnes) {
          colonnes = data.colonnes;
          var sel = racine.querySelector('[data-ecran-champ="colonnes"]');
          if (sel) sel.value = colonnes;
        }
        racine.classList.add('ecran-mj--orga');
        marquerModifie();
        placer();
      })
      .catch(function (err) { alert(err.message); });
  };

  // ── Glisser-déposer (HTML5 natif, comme js/regles.js) ────────────────────
  // L'élément n'est déplaçable que saisi par sa poignée : sinon sélectionner du
  // texte dans une cellule lancerait un déplacement.
  function nettoyerCibles() {
    racine.querySelectorAll('.ecran-mj__cible--avant, .ecran-mj__cible--apres, .ecran-mj__bande--survol')
      .forEach(function (el) {
        el.classList.remove('ecran-mj__cible--avant', 'ecran-mj__cible--apres', 'ecran-mj__bande--survol');
      });
  }

  function brancherGlisser() {
    racine.addEventListener('mousedown', function (e) {
      if (!enOrga()) return;
      var p = e.target.closest('.ecran-mj__poignee');
      if (p) p.closest('.ecran-mj__item').setAttribute('draggable', 'true');
    });
    racine.addEventListener('mouseup', function () {
      elements().forEach(function (it) { it.removeAttribute('draggable'); });
    });

    racine.addEventListener('dragstart', function (e) {
      var it = e.target.closest && e.target.closest('.ecran-mj__item');
      if (!it || !enOrga()) { e.preventDefault(); return; }
      glisse = it;
      e.dataTransfer.effectAllowed = 'move';
      e.dataTransfer.setData('text/plain', it.getAttribute('data-tab-id'));
      requestAnimationFrame(function () { it.classList.add('ecran-mj__item--glisse'); });
    });

    racine.addEventListener('dragend', function () {
      if (glisse) {
        glisse.classList.remove('ecran-mj__item--glisse');
        glisse.removeAttribute('draggable');
      }
      glisse = null;
      nettoyerCibles();
    });

    racine.addEventListener('dragover', function (e) {
      if (!glisse) return;
      var cible = e.target.closest('.ecran-mj__item, .ecran-mj__bande');
      if (!cible || cible === glisse) return;
      e.preventDefault();
      e.dataTransfer.dropEffect = 'move';
      nettoyerCibles();
      if (cible.classList.contains('ecran-mj__bande')) {
        cible.classList.add('ecran-mj__bande--survol');
      } else {
        var r = cible.getBoundingClientRect();
        cible.classList.add(e.clientY < r.top + r.height / 2 ? 'ecran-mj__cible--avant' : 'ecran-mj__cible--apres');
      }
    });

    racine.addEventListener('drop', function (e) {
      if (!glisse) return;
      var cible = e.target.closest('.ecran-mj__item, .ecran-mj__bande');
      if (!cible || cible === glisse) return;
      e.preventDefault();
      var g = grille();

      if (cible.classList.contains('ecran-mj__bande')) {
        // Vide d'une colonne : en bas de cette colonne, donc en fin d'ordre global.
        glisse.setAttribute('data-col', cible.getAttribute('data-col'));
        g.appendChild(glisse);
      } else {
        // Sur un tableau : même colonne, juste avant ou juste après lui.
        var r = cible.getBoundingClientRect();
        var avant = e.clientY < r.top + r.height / 2;
        glisse.setAttribute('data-col', cible.getAttribute('data-col'));
        g.insertBefore(glisse, avant ? cible : cible.nextSibling);
      }
      nettoyerCibles();
      marquerModifie();
      placer();
    });
  }

  // ── Branchements globaux ─────────────────────────────────────────────────
  window.ecranMJOuvrir = ouvrir;

  document.addEventListener('click', function (e) {
    var b = e.target.closest('[data-ecran-mj-ouvrir]');
    if (b) ouvrir(b.getAttribute('data-ecran-mj-ouvrir'));
  });

  // Échap ferme l'écran, sauf si un panneau est ouvert par-dessus : il est
  // alors à lui de se fermer.
  document.addEventListener('keydown', function (e) {
    if (e.key !== 'Escape' || !ouvert()) return;
    var dessus = ['detail-pp', 'detail-pp-sub', 'modification'].some(function (id) {
      var p = document.getElementById(id);
      return p && !p.classList.contains('noDisplay');
    });
    if (!dessus) fermer();
  });

  window.addEventListener('resize', function () { if (ouvert()) replacerBientot(); });
})();
