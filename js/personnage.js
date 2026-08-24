// js/personnage.js — Interactions du module Personnages.
// Chargé uniquement sur les pages du module ($js_module = 'personnage').
// perUrlDetail / perUrlModifier / perUrlEnreg / perUrlFiche injectés en inline par index.php.
//
// SP-PE0 : socle — menu contextuel + suppression inline depuis la liste.
// SP-PE2 : éditeur DOM Classes inline.
// SP-PE3 : éditeur DOM Compétences inline.
// Les éditeurs DOM restants (dons, NLS, sorts) seront ajoutés
// en SP-PE4 à SP-PE7.
'use strict';

// ============================================================
// MENU LIGNE ET SUPPRESSION INLINE DE LA LISTE
// Supprimés le 2026-08-22 (SP-RS6b) : la liste est rendue par le moteur
// partagé, qui appelle compToggleMenu() / compDemanderSuppression() de
// js/main.js. Ces fonctions per* n'avaient plus qu'un appelant.
// ============================================================

// ============================================================
// SUPPRESSION PERSONNAGE depuis la fiche détail (#detail-pp)
// Utilise confirm() natif (pas de ligne à remplacer dans un panel).
// ============================================================

const personnageListe = {
  supprimer(id, nom) {
    const message = 'Supprimer le personnage « ' + nom + ' » ?\n\n'
      + 'Ses classes, compétences, dons et sorts associés seront également supprimés. '
      + 'Cette action est définitive.';
    confirmer(message, async () => {
      try {
        const data = await postAjax(perUrlEnreg, { action: 'supprimerPersonnage', id: id });
        if (data.ok) {
          fermerDetailPP();
          rafraichirListe();
        } else {
          alert(data.erreur || 'Erreur lors de la suppression.');
        }
      } catch (err) {
        alert('Erreur : ' + err);
      }
    });
  },
};

// ============================================================
// ÉDITEUR CLASSES INLINE (SP-PE2)
// Gère le bloc Classes de la fiche personnage :
//   - Bascule entre mode lecture et mode édition
//   - Construit les lignes DOM dynamiquement
//   - Commit vers enregistrement.php (action enregistrerClasses)
//
// Dépend des variables injectées par fiche.php :
//   perPeId, perRuleset, perClassesInitiales,
//   perClassesDisponibles, perDomaines, perUrlEnreg
// ============================================================

const classesEditor = (function() {
  'use strict';

  let _etatEdition = false;
  // Copie locale de l'état de l'éditeur (lignes en cours d'édition)
  let _lignes = [];

  // ---- Construction du select Classe ----------------------------

  function _buildSelectClasse(cla_id_selectionne) {
    const sel = document.createElement('select');
    sel.className = 'per-classes-editor__select-classe';
    sel.name = 'classe_select'; // pas transmis, sert juste à l'UI

    const opt0 = document.createElement('option');
    opt0.value = '0';
    opt0.textContent = '— Choisir —';
    sel.appendChild(opt0);

    // Grouper par type (base / prestige)
    const base     = perClassesDisponibles.filter(c => c.clt_id === 1);
    const prestige = perClassesDisponibles.filter(c => c.clt_id === 2);
    const autres   = perClassesDisponibles.filter(c => c.clt_id !== 1 && c.clt_id !== 2);

    function addGroup(label, items) {
      if (!items.length) return;
      const grp = document.createElement('optgroup');
      grp.label = label;
      items.forEach(c => {
        const opt = document.createElement('option');
        opt.value = c.id;
        opt.textContent = c.nom;
        if (c.id === cla_id_selectionne) opt.selected = true;
        grp.appendChild(opt);
      });
      sel.appendChild(grp);
    }

    addGroup('Classes de base', base);
    addGroup('Classes de prestige', prestige);
    if (autres.length) addGroup('Autres', autres);

    return sel;
  }

  // ---- Construction du select Domaine ---------------------------

  function _buildSelectDomaine(do_id_selectionne, name) {
    const sel = document.createElement('select');
    sel.className = 'per-classes-editor__select-domaine';
    sel.name = name;

    const opt0 = document.createElement('option');
    opt0.value = '0';
    opt0.textContent = '— Domaine —';
    sel.appendChild(opt0);

    perDomaines.forEach(d => {
      const opt = document.createElement('option');
      opt.value = d.id;
      opt.textContent = d.nom;
      if (d.id === do_id_selectionne) opt.selected = true;
      sel.appendChild(opt);
    });

    return sel;
  }

  // ---- Rendu d'une ligne d'édition ------------------------------

  function _renderLigne(idx, data) {
    const li = document.createElement('li');
    li.className = 'per-classes-editor__ligne';
    li.dataset.idx = idx;

    // Select classe
    const selClasse = _buildSelectClasse(data.cla_id);
    selClasse.addEventListener('change', function() {
      _lignes[idx].cla_id = parseInt(this.value, 10) || 0;
      // Recalculer l'affichage des domaines
      const meta = perClassesDisponibles.find(c => c.id === _lignes[idx].cla_id);
      _lignes[idx].domaineDivin = meta ? meta.domaineDivin : false;
      _lignes[idx].niveauMax    = meta ? meta.niveauMax    : 20;
      _actualiserLigneDOM(li, idx);
    });
    li.appendChild(selClasse);

    // Input niveau
    const wrapNiv = document.createElement('span');
    wrapNiv.className = 'per-classes-editor__niv-wrap';
    wrapNiv.textContent = 'Niv. ';
    const inputNiv = document.createElement('input');
    inputNiv.type        = 'number';
    inputNiv.min         = '1';
    inputNiv.max         = data.niveauMax || 20;
    inputNiv.value       = data.niveau || 1;
    inputNiv.className   = 'per-classes-editor__input-niv';
    inputNiv.inputMode   = 'numeric';
    inputNiv.addEventListener('change', function() {
      _lignes[idx].niveau = parseInt(this.value, 10) || 1;
    });
    wrapNiv.appendChild(inputNiv);
    li.appendChild(wrapNiv);

    // Domaines (DD3.5, conditionnels)
    if (perRuleset === 'DD3.5') {
      const wrapDo = document.createElement('span');
      wrapDo.className = 'per-classes-editor__domaines';
      if (data.domaineDivin) {
        const sel1 = _buildSelectDomaine(data.do_id_1 || 0, 'do1_' + idx);
        sel1.addEventListener('change', function() { _lignes[idx].do_id_1 = parseInt(this.value, 10) || 0; });
        const sel2 = _buildSelectDomaine(data.do_id_2 || 0, 'do2_' + idx);
        sel2.addEventListener('change', function() { _lignes[idx].do_id_2 = parseInt(this.value, 10) || 0; });
        wrapDo.appendChild(sel1);
        wrapDo.appendChild(sel2);
      }
      wrapDo.dataset.domine = data.domaineDivin ? '1' : '0';
      li.appendChild(wrapDo);
    }

    // Bouton supprimer
    const btnDel = document.createElement('button');
    btnDel.type      = 'button';
    btnDel.className = 'btn btn-icon btn-sm btn-danger per-classes-editor__btn-del';
    btnDel.title     = 'Supprimer cette classe';
    btnDel.innerHTML = '<i class="fa fa-trash"></i>';
    btnDel.addEventListener('click', function() {
      _lignes.splice(idx, 1);
      _renderToutesLignes();
    });
    li.appendChild(btnDel);

    return li;
  }

  // Mise à jour d'une seule ligne après changement de classe
  function _actualiserLigneDOM(li, idx) {
    const data    = _lignes[idx];
    const inputNiv = li.querySelector('.per-classes-editor__input-niv');
    if (inputNiv) inputNiv.max = data.niveauMax || 20;

    if (perRuleset === 'DD3.5') {
      const wrapDo = li.querySelector('.per-classes-editor__domaines');
      if (wrapDo) {
        wrapDo.innerHTML = '';
        wrapDo.dataset.domine = data.domaineDivin ? '1' : '0';
        if (data.domaineDivin) {
          const sel1 = _buildSelectDomaine(0, 'do1_' + idx);
          sel1.addEventListener('change', function() { _lignes[idx].do_id_1 = parseInt(this.value, 10) || 0; });
          const sel2 = _buildSelectDomaine(0, 'do2_' + idx);
          sel2.addEventListener('change', function() { _lignes[idx].do_id_2 = parseInt(this.value, 10) || 0; });
          wrapDo.appendChild(sel1);
          wrapDo.appendChild(sel2);
          _lignes[idx].do_id_1 = 0;
          _lignes[idx].do_id_2 = 0;
        }
      }
    }
  }

  function _renderToutesLignes() {
    const container = document.getElementById('classes-editor-lignes');
    if (!container) return;
    container.innerHTML = '';
    const ul = document.createElement('ul');
    ul.className = 'per-classes-editor__liste';
    _lignes.forEach((data, idx) => {
      ul.appendChild(_renderLigne(idx, data));
    });
    container.appendChild(ul);
  }

  // ---- API publique ---------------------------------------------

  function init() {
    // Initialisé avec les données de fiche.php (perClassesInitiales)
    _lignes = (perClassesInitiales || []).map(c => ({
      cla_id:       c.cla_id,
      cla_nom:      c.cla_nom,
      clt_id:       c.clt_id,
      niveau:       c.niveau,
      niveauMax:    c.niveauMax,
      domaineDivin: c.domaineDivin,
      do_id_1:      c.do_id_1 || 0,
      do_id_2:      c.do_id_2 || 0,
    }));
  }

  function basculerEdition() {
    _etatEdition = !_etatEdition;
    const lecture = document.getElementById('classes-lecture');
    const edition = document.getElementById('classes-edition');
    const btn     = document.getElementById('btn-editer-classes');
    if (!lecture || !edition) return;

    if (_etatEdition) {
      init();
      _renderToutesLignes();
      lecture.classList.add('noDisplay');
      edition.classList.remove('noDisplay');
      if (btn) btn.innerHTML = '<i class="fa fa-times"></i><span class="per-btn-label">Annuler</span>';
    } else {
      lecture.classList.remove('noDisplay');
      edition.classList.add('noDisplay');
      if (btn) btn.innerHTML = '<i class="fa fa-edit"></i><span class="per-btn-label">Modifier</span>';
      _cacherMsg();
    }
  }

  function ajouterLigne() {
    const meta = perClassesDisponibles[0] || {};
    _lignes.push({
      cla_id:       0,
      niveau:       1,
      niveauMax:    meta.niveauMax || 20,
      domaineDivin: false,
      do_id_1:      0,
      do_id_2:      0,
    });
    _renderToutesLignes();
    // Focus sur le dernier select ajouté
    const lignes = document.querySelectorAll('.per-classes-editor__ligne');
    if (lignes.length) {
      const last = lignes[lignes.length - 1];
      const sel  = last.querySelector('select');
      if (sel) sel.focus();
    }
  }

  function annuler() {
    _etatEdition = false;
    const lecture = document.getElementById('classes-lecture');
    const edition = document.getElementById('classes-edition');
    const btn     = document.getElementById('btn-editer-classes');
    if (lecture) lecture.classList.remove('noDisplay');
    if (edition) edition.classList.add('noDisplay');
    if (btn)     btn.innerHTML = '<i class="fa fa-edit"></i><span class="per-btn-label">Modifier</span>';
    _cacherMsg();
  }

  async function enregistrer() {
    // Construire le payload
    const lignesValides = _lignes.filter(l => l.cla_id > 0);
    if (!lignesValides.length) {
      _afficherMsg('Au moins une classe est obligatoire.', 'erreur');
      return;
    }

    // Vérifier les doublons
    const ids = lignesValides.map(l => l.cla_id);
    if (new Set(ids).size !== ids.length) {
      _afficherMsg('Une classe ne peut figurer qu\'une seule fois.', 'erreur');
      return;
    }

    const formData = new FormData();
    formData.append('action',  'enregistrerClasses');
    formData.append('pe_id',   perPeId);
    // CSRF token lu depuis la meta tag (même pattern que postAjax dans main.js)
    const csrfMeta = document.querySelector('meta[name="csrf-token"]');
    if (csrfMeta) formData.append('csrf_token', csrfMeta.getAttribute('content'));

    lignesValides.forEach((l, i) => {
      formData.append('classes[' + i + '][cla_id]',  l.cla_id);
      formData.append('classes[' + i + '][niveau]',  l.niveau);
      formData.append('classes[' + i + '][do_id_1]', l.do_id_1 || 0);
      formData.append('classes[' + i + '][do_id_2]', l.do_id_2 || 0);
    });

    try {
      const resp = await fetch(perUrlEnreg, { method: 'POST', body: formData });
      const data = await resp.json();
      if (data.ok) {
        _afficherMsg('Enregistré.', 'ok');
        // Recharger la page pour mettre à jour le mode lecture
        setTimeout(() => { window.location.reload(); }, 600);
      } else {
        _afficherMsg(data.erreur || 'Erreur.', 'erreur');
      }
    } catch(e) {
      _afficherMsg('Erreur réseau : ' + e, 'erreur');
    }
  }

  function _afficherMsg(txt, type) {
    const el = document.getElementById('classes-msg');
    if (!el) return;
    el.textContent = txt;
    el.className   = 'per-classes-commit__msg per-classes-commit__msg--' + type;
    el.classList.remove('noDisplay');
  }

  function _cacherMsg() {
    const el = document.getElementById('classes-msg');
    if (el) el.classList.add('noDisplay');
  }

  return { basculerEdition, ajouterLigne, annuler, enregistrer };

})();

// ============================================================
// ÉDITEUR COMPÉTENCES INLINE (SP-PE3)
// Gère le bloc Compétences de la fiche personnage :
//   - Bascule entre mode lecture et mode édition
//   - Construit le tableau complet du ruleset (36 lignes en DD3.5,
//     18 en DD2024), filtrable par nom
//   - Total recalculé à la volée à chaque saisie
//   - Commit vers enregistrement.php (action enregistrerCompetences)
//
// Saisie déclarative : aucune règle de jeu n'est appliquée (archi §7.1).
// Le plafond MAX_RANGS est une borne technique, pas le maximum de rangs
// autorisé par les règles DD3.5.
//
// Dépend des variables injectées par fiche.php :
//   perPeId, perRuleset, perCompetencesInitiales, perBonusMaitrise, perUrlEnreg
// ============================================================

const competencesEditor = (function() {
  'use strict';

  const MAX_RANGS = 99;

  let _etatEdition = false;
  // Copie locale de l'état de l'éditeur (une entrée par compétence du ruleset)
  let _lignes = [];

  // ---- Calculs d'affichage --------------------------------------

  function _total(ligne) {
    if (perRuleset === 'DD2024') {
      return ligne.mod + perBonusMaitrise * Math.min(Math.max(ligne.maitrise, 0), 2);
    }
    return ligne.mod + ligne.maitrise;
  }

  function _formatMod(valeur) {
    return (valeur >= 0 ? '+' : '') + valeur;
  }

  function _actualiserTotal(idx) {
    const cell = document.querySelector(
      '.per-comp-editor__ligne[data-idx="' + idx + '"] .per-comp-editor__total'
    );
    if (cell) cell.textContent = _formatMod(_total(_lignes[idx]));
  }

  // ---- Champ de saisie de la maîtrise ---------------------------

  function _buildChampMaitrise(idx, data) {
    // DD2024 : sélecteur 0 / 1 / 2 (aucune, maîtrise, expertise)
    if (perRuleset === 'DD2024') {
      const sel = document.createElement('select');
      sel.className = 'per-comp-editor__select';
      [[0, '—'], [1, 'Maîtrise'], [2, 'Expertise']].forEach(function(paire) {
        const opt = document.createElement('option');
        opt.value       = paire[0];
        opt.textContent = paire[1];
        if (paire[0] === data.maitrise) opt.selected = true;
        sel.appendChild(opt);
      });
      sel.addEventListener('change', function() {
        _lignes[idx].maitrise = parseInt(this.value, 10) || 0;
        _actualiserTotal(idx);
      });
      return sel;
    }

    // DD3.5 : nombre de rangs
    const input = document.createElement('input');
    input.type      = 'number';
    input.min       = '0';
    input.max       = String(MAX_RANGS);
    input.value     = data.maitrise;
    input.inputMode = 'numeric';
    input.className = 'per-comp-editor__input';
    input.addEventListener('input', function() {
      let v = parseInt(this.value, 10);
      if (isNaN(v) || v < 0) v = 0;
      if (v > MAX_RANGS)     v = MAX_RANGS;
      _lignes[idx].maitrise = v;
      _actualiserTotal(idx);
    });
    return input;
  }

  // ---- Rendu du tableau -----------------------------------------

  function _renderLigne(idx, data) {
    const tr = document.createElement('tr');
    tr.className = 'per-comp-editor__ligne';
    tr.dataset.idx = idx;
    tr.dataset.nom = data.nom.toLowerCase();

    // Nom + drapeaux DD3.5
    const tdNom = document.createElement('td');
    tdNom.className = 'per-comp-table__nom';
    tdNom.textContent = data.nom;
    if (data.formation) {
      const f = document.createElement('span');
      f.className   = 'per-comp__flag';
      f.title       = 'Formation requise';
      f.textContent = 'F';
      tdNom.appendChild(document.createTextNode(' '));
      tdNom.appendChild(f);
    }
    if (data.malusArmure) {
      const a = document.createElement('span');
      a.className   = 'per-comp__flag';
      a.title       = 'Soumise au malus d\'armure';
      a.textContent = 'A';
      tdNom.appendChild(document.createTextNode(' '));
      tdNom.appendChild(a);
    }
    tr.appendChild(tdNom);

    // Caractéristique associée + son modificateur.
    // Certaines compétences n'en ont aucune (« Langue » en DD3.5) → « — ».
    const tdCarac = document.createElement('td');
    if (data.carac) {
      tdCarac.textContent = data.carac + ' ';
      const spanMod = document.createElement('span');
      spanMod.className   = 'text-muted';
      spanMod.textContent = _formatMod(data.mod);
      tdCarac.appendChild(spanMod);
    } else {
      const spanVide = document.createElement('span');
      spanVide.className   = 'text-muted';
      spanVide.title       = 'Aucune caractéristique associée';
      spanVide.textContent = '—';
      tdCarac.appendChild(spanVide);
    }
    tr.appendChild(tdCarac);

    // Saisie — colonne élargie (classe dédiée, pas .col-stat qui plafonne à 46px)
    const tdSaisie = document.createElement('td');
    tdSaisie.className = 'per-comp-table__saisie';
    tdSaisie.appendChild(_buildChampMaitrise(idx, data));
    tr.appendChild(tdSaisie);

    // Total
    const tdTotal = document.createElement('td');
    tdTotal.className   = 'per-comp-editor__total per-comp-table__total';
    tdTotal.textContent = _formatMod(_total(data));
    tr.appendChild(tdTotal);

    return tr;
  }

  function _renderTable() {
    const container = document.getElementById('competences-editor-lignes');
    if (!container) return;
    container.innerHTML = '';

    if (!_lignes.length) {
      const p = document.createElement('p');
      p.className   = 'text-muted';
      p.textContent = 'Aucune compétence disponible pour ce ruleset avec les sources actives.';
      container.appendChild(p);
      return;
    }

    const wrap  = document.createElement('div');
    wrap.className = 'table-dd-wrap';
    const table = document.createElement('table');
    table.className = 'table-dd per-comp-table';

    const thead = document.createElement('thead');
    thead.innerHTML =
      '<tr>' +
        '<th class="per-comp-table__nom">Compétence</th>' +
        '<th class="col-stat">Carac</th>' +
        '<th class="per-comp-table__saisie">' + (perRuleset === 'DD2024' ? 'Maîtrise' : 'Rangs') + '</th>' +
        '<th class="col-stat">Total</th>' +
      '</tr>';
    table.appendChild(thead);

    const tbody = document.createElement('tbody');
    _lignes.forEach(function(data, idx) {
      tbody.appendChild(_renderLigne(idx, data));
    });
    table.appendChild(tbody);

    wrap.appendChild(table);
    container.appendChild(wrap);
  }

  // ---- API publique ---------------------------------------------

  function init() {
    _lignes = (perCompetencesInitiales || []).map(function(c) {
      return {
        comp_id:     c.comp_id,
        nom:         c.nom,
        carac:       c.carac,
        mod:         c.mod,
        formation:   c.formation,
        malusArmure: c.malusArmure,
        maitrise:    c.maitrise,
      };
    });
  }

  function basculerEdition() {
    _etatEdition = !_etatEdition;
    const lecture = document.getElementById('competences-lecture');
    const edition = document.getElementById('competences-edition');
    const btn     = document.getElementById('btn-editer-competences');
    if (!lecture || !edition) return;

    if (_etatEdition) {
      init();
      _renderTable();
      lecture.classList.add('noDisplay');
      edition.classList.remove('noDisplay');
      if (btn) btn.innerHTML = '<i class="fa fa-times"></i><span class="per-btn-label">Annuler</span>';
    } else {
      lecture.classList.remove('noDisplay');
      edition.classList.add('noDisplay');
      if (btn) btn.innerHTML = '<i class="fa fa-edit"></i><span class="per-btn-label">Modifier</span>';
      _cacherMsg();
    }
  }

  // Filtre local sur le nom — masque les lignes, ne touche pas à _lignes
  function filtrer(terme) {
    const q = (terme || '').trim().toLowerCase();
    document.querySelectorAll('.per-comp-editor__ligne').forEach(function(tr) {
      const visible = !q || tr.dataset.nom.indexOf(q) !== -1;
      tr.classList.toggle('noDisplay', !visible);
    });
  }

  function annuler() {
    _etatEdition = false;
    const lecture = document.getElementById('competences-lecture');
    const edition = document.getElementById('competences-edition');
    const btn     = document.getElementById('btn-editer-competences');
    const filtre  = document.getElementById('competences-filtre');
    if (lecture) lecture.classList.remove('noDisplay');
    if (edition) edition.classList.add('noDisplay');
    if (btn)     btn.innerHTML = '<i class="fa fa-edit"></i><span class="per-btn-label">Modifier</span>';
    if (filtre)  filtre.value = '';
    _cacherMsg();
  }

  async function enregistrer() {
    // Seules les lignes réellement maîtrisées sont transmises (cf. archi §7.5).
    // Une liste vide est valide : elle efface toutes les compétences du personnage.
    const lignesSaisies = _lignes.filter(function(l) { return l.maitrise > 0; });

    const formData = new FormData();
    formData.append('action', 'enregistrerCompetences');
    formData.append('pe_id',  perPeId);
    // CSRF token lu depuis la meta tag (même pattern que postAjax dans main.js)
    const csrfMeta = document.querySelector('meta[name="csrf-token"]');
    if (csrfMeta) formData.append('csrf_token', csrfMeta.getAttribute('content'));

    lignesSaisies.forEach(function(l, i) {
      formData.append('competences[' + i + '][comp_id]',  l.comp_id);
      formData.append('competences[' + i + '][maitrise]', l.maitrise);
    });

    try {
      const resp = await fetch(perUrlEnreg, { method: 'POST', body: formData });
      const data = await resp.json();
      if (data.ok) {
        _afficherMsg('Enregistré.', 'ok');
        // Recharger la page pour mettre à jour le mode lecture
        setTimeout(function() { window.location.reload(); }, 600);
      } else {
        _afficherMsg(data.erreur || 'Erreur.', 'erreur');
      }
    } catch(e) {
      _afficherMsg('Erreur réseau : ' + e, 'erreur');
    }
  }

  function _afficherMsg(txt, type) {
    const el = document.getElementById('competences-msg');
    if (!el) return;
    el.textContent = txt;
    el.className   = 'per-classes-commit__msg per-classes-commit__msg--' + type;
    el.classList.remove('noDisplay');
  }

  function _cacherMsg() {
    const el = document.getElementById('competences-msg');
    if (el) el.classList.add('noDisplay');
  }

  return { basculerEdition, filtrer, annuler, enregistrer };

})();

// ============================================================
// SÉLECTEUR DE DONS (SP-PE4)
// S'ouvre dans #detail-pp, en deux volets : liste filtrable à gauche
// (ascenseur propre), fiche du don cliqué à droite.
//
// Le panneau gère lui-même son ouverture et sa fermeture plutôt que de passer
// par actualiserPage() : il doit rester ouvert entre les choix, recharger la
// fiche en sortant si quelque chose a changé, et actualiserPage() n'exécute
// pas les <script> injectés — l'initialisation ne peut donc pas venir du HTML.
//
// Chaque ajout / retrait écrit immédiatement en base ; le compteur affiche le
// total renvoyé par le serveur, jamais une valeur extrapolée côté client.
//
// Dépend des variables injectées par fiche.php :
//   perPeId, perUrlDonsPicker, perUrlDonDetail, perUrlEnreg
// ============================================================

const donsPicker = (function() {
  'use strict';

  let _modifie = false;   // au moins une écriture → la fiche sera rechargée

  function _panel()    { return document.getElementById('detail-pp'); }
  function _backdrop() { return document.getElementById('detail-pp-backdrop'); }

  function _csrf() {
    const meta = document.querySelector('meta[name="csrf-token"]');
    return meta ? meta.getAttribute('content') : '';
  }

  // ---- Ouverture / fermeture ------------------------------------

  function ouvrir() {
    const panel = _panel();
    const bd    = _backdrop();
    if (!panel) return;

    _modifie = false;
    if (bd) bd.classList.remove('noDisplay');
    panel.classList.remove('noDisplay');
    panel.innerHTML = '<div class="loading"><i class="fa fa-spinner fa-spin"></i> Chargement…</div>';

    fetch(perUrlDonsPicker + '?pe_id=' + encodeURIComponent(perPeId))
      .then(function(r) { if (!r.ok) throw new Error('Erreur ' + r.status); return r.text(); })
      .then(function(html) {
        panel.innerHTML =
          '<button class="overlay-close" onclick="donsPicker.fermer()" title="Fermer">'
          + '<i class="fa fa-times"></i></button>'
          + '<div class="overlay-panel__inner">' + html + '</div>';
        filtrer();
      })
      .catch(function(e) {
        panel.innerHTML = '<p class="erreur">' + e + '</p>';
      });
  }

  function fermer() {
    const panel = _panel();
    const bd    = _backdrop();
    if (panel) { panel.classList.add('noDisplay'); panel.innerHTML = ''; }
    if (bd)    bd.classList.add('noDisplay');
    // Le bloc Dons de la fiche est rendu côté serveur : on ne le resynchronise
    // qu'à la fermeture, et seulement si quelque chose a bougé.
    if (_modifie) window.location.reload();
  }

  // ---- Filtrage local (nom + catégorie) -------------------------

  function filtrer() {
    const champQ   = document.getElementById('dons-picker-q');
    const champCat = document.getElementById('dons-picker-cat');
    const q        = champQ   ? champQ.value.trim().toLowerCase() : '';
    const cat      = champCat ? parseInt(champCat.value, 10) || 0 : 0;

    let visibles = 0;
    document.querySelectorAll('.dons-picker__item').forEach(function(li) {
      const okNom = !q   || li.dataset.nom.indexOf(q) !== -1;
      const okCat = !cat || parseInt(li.dataset.cat, 10) === cat;
      const ok    = okNom && okCat;
      li.classList.toggle('noDisplay', !ok);
      if (ok) visibles++;
    });

    const decompte = document.getElementById('dons-picker-decompte');
    if (decompte) {
      decompte.textContent = visibles + (visibles > 1 ? ' dons affichés' : ' don affiché');
    }
  }

  // ---- Volet droit : fiche du don -------------------------------

  function voir(doId) {
    const zone = document.getElementById('dons-picker-detail');
    if (!zone) return;

    document.querySelectorAll('.dons-picker__item').forEach(function(li) {
      li.classList.toggle('is-courant', parseInt(li.dataset.doId, 10) === doId);
    });

    zone.innerHTML = '<div class="loading"><i class="fa fa-spinner fa-spin"></i> Chargement…</div>';
    fetch(perUrlDonDetail + '?id=' + encodeURIComponent(doId))
      .then(function(r) { if (!r.ok) throw new Error('Erreur ' + r.status); return r.text(); })
      .then(function(html) {
        zone.innerHTML = html;
        zone.scrollTop = 0;
        _poserBoutonDetail(doId);
      })
      .catch(function(e) { zone.innerHTML = '<p class="erreur">' + e + '</p>'; });
  }

  // Ajoute le bouton d'ajout / retrait à droite du nom, dans la fiche du don.
  // Posé en JS plutôt que dans detail-pp/don.php : ce fichier est partagé avec
  // le compendium et n'a pas à connaître la notion de personnage.
  function _poserBoutonDetail(doId) {
    const zone = document.getElementById('dons-picker-detail');
    const titre = zone ? zone.querySelector('.sort-detail__nom') : null;
    if (!titre) return;

    const ancien = titre.querySelector('.dons-picker__btn-detail');
    if (ancien) ancien.remove();

    const btn = document.createElement('button');
    btn.type      = 'button';
    btn.className = 'dons-picker__btn dons-picker__btn-detail';
    btn.addEventListener('click', function() { basculer(doId); });
    titre.appendChild(btn);
    _majBoutonDetail(doId);
  }

  function _majBoutonDetail(doId) {
    const btn = document.querySelector('.dons-picker__btn-detail');
    if (!btn) return;
    const li = document.querySelector('.dons-picker__item[data-do-id="' + doId + '"]');
    const possede = li ? li.classList.contains('is-possede') : false;
    btn.classList.toggle('dons-picker__btn--retirer', possede);
    btn.title     = possede ? 'Retirer ce don' : 'Ajouter ce don';
    btn.innerHTML = '<i class="fa ' + (possede ? 'fa-trash' : 'fa-plus') + '"></i>'
                  + '<span class="dons-picker__btn-lbl">' + (possede ? 'Supprimer' : 'Ajouter') + '</span>';
  }

  // ---- Ajout / retrait ------------------------------------------

  async function basculer(doId) {
    const li = document.querySelector('.dons-picker__item[data-do-id="' + doId + '"]');
    if (!li) return;

    const possede = li.classList.contains('is-possede');
    const btnListe = li.querySelector('.dons-picker__btn');
    if (btnListe) btnListe.disabled = true;

    const fd = new FormData();
    fd.append('action', possede ? 'supprimerDon' : 'ajouterDon');
    fd.append('pe_id',  perPeId);
    fd.append('do_id',  doId);
    fd.append('csrf_token', _csrf());

    try {
      const resp = await fetch(perUrlEnreg, { method: 'POST', body: fd });
      const data = await resp.json();
      if (!data.ok) {
        alert(data.erreur || 'Erreur lors de l\'enregistrement.');
        return;
      }
      _modifie = true;
      li.classList.toggle('is-possede', data.possede);
      _majBoutonListe(li, data.possede);
      _majBoutonDetail(doId);
      _majCompteur(data.total);
    } catch (e) {
      alert('Erreur réseau : ' + e);
    } finally {
      if (btnListe) btnListe.disabled = false;
    }
  }

  function _majBoutonListe(li, possede) {
    const btn = li.querySelector('.dons-picker__btn');
    if (!btn) return;
    btn.classList.toggle('dons-picker__btn--retirer', possede);
    btn.title     = possede ? 'Retirer ce don' : 'Ajouter ce don';
    btn.innerHTML = '<i class="fa ' + (possede ? 'fa-trash' : 'fa-plus') + '"></i>'
                  + '<span class="dons-picker__btn-lbl">' + (possede ? 'Supprimer' : 'Ajouter') + '</span>';
  }

  // Le total vient du serveur : le compteur ne dérive jamais de l'état local.
  function _majCompteur(total) {
    const val = document.getElementById('dons-picker-compteur');
    const lbl = document.getElementById('dons-picker-compteur-lbl');
    if (val) val.textContent = total;
    if (lbl) lbl.textContent = total > 1 ? 'dons choisis' : 'don choisi';
  }

  return { ouvrir, fermer, filtrer, voir, basculer };

})();

// ============================================================
// ÉDITEUR DE CAMPAGNES (SP-PE5)
// Éditeur inline du bloc Campagnes, à écriture immédiate : chaque clic
// (rattacher, détacher, désigner la campagne en cours, clore une
// participation) part en base sans bouton « Enregistrer », comme le
// sélecteur de dons — ce sont des appartenances, pas des valeurs saisies.
//
// Le mode lecture est rendu côté serveur : on ne recharge la fiche qu'à la
// fermeture de l'éditeur, et seulement si quelque chose a bougé.
//
// L'état affiché vient toujours de la réponse du serveur (campagne en cours
// comprise) : une action peut en déplacer une autre — désigner une campagne
// en cours en destitue une, clore une participation efface le raccourci —
// et l'éditeur ne doit jamais extrapoler ces effets de bord.
//
// Dépend des variables injectées par fiche.php :
//   perPeId, perUrlEnreg, perCampagnesEditeur, perCampCourante
// ============================================================

const campagnesEditor = (function() {
  'use strict';

  let _etatEdition = false;
  let _modifie     = false;   // au moins une écriture → la fiche sera rechargée
  let _lignes      = [];      // copie locale de l'état des campagnes

  function _csrf() {
    const meta = document.querySelector('meta[name="csrf-token"]');
    return meta ? meta.getAttribute('content') : '';
  }

  // ---- Bascule lecture / édition --------------------------------

  function basculerEdition() {
    _etatEdition = !_etatEdition;

    const lecture = document.getElementById('campagnes-lecture');
    const edition = document.getElementById('campagnes-edition');
    const btn     = document.getElementById('btn-editer-campagnes');

    if (_etatEdition) {
      _init();
      if (lecture) lecture.classList.add('noDisplay');
      if (edition) edition.classList.remove('noDisplay');
      if (btn)     btn.innerHTML = '<i class="fa fa-times"></i><span class="per-btn-label">Fermer</span>';
    } else {
      fermer();
    }
  }

  function fermer() {
    _etatEdition = false;
    const lecture = document.getElementById('campagnes-lecture');
    const edition = document.getElementById('campagnes-edition');
    const btn     = document.getElementById('btn-editer-campagnes');
    if (lecture) lecture.classList.remove('noDisplay');
    if (edition) edition.classList.add('noDisplay');
    if (btn)     btn.innerHTML = '<i class="fa fa-edit"></i><span class="per-btn-label">Modifier</span>';
    _cacherMsg();

    // Le bloc en lecture est rendu par le serveur : on ne le resynchronise
    // qu'en sortant, et uniquement si une écriture a eu lieu.
    if (_modifie) window.location.reload();
  }

  function _init() {
    const source = (typeof perCampagnesEditeur !== 'undefined') ? perCampagnesEditeur : [];
    _lignes = source.map(function(c) {
      return {
        id:       c.id,
        nom:      c.nom,
        resume:   c.resume,
        univers:  c.univers,
        rattache: !!c.rattache,
        actif:    !!c.actif,
        courante: !!c.courante
      };
    });
    _render();
  }

  // ---- Rendu ----------------------------------------------------

  function _bouton(libelle, icone, classes, onClick) {
    const btn = document.createElement('button');
    btn.type      = 'button';
    btn.className = 'btn btn-sm ' + classes;
    btn.innerHTML = '<i class="fa ' + icone + '"></i> ';
    btn.appendChild(document.createTextNode(libelle));
    btn.addEventListener('click', onClick);
    return btn;
  }

  function _renderLigne(ligne) {
    const div = document.createElement('div');
    div.className = 'per-camp-editor__ligne'
                  + (ligne.rattache ? ' is-rattachee' : '')
                  + (ligne.courante ? ' is-courante'  : '');
    div.dataset.campId = ligne.id;

    // Colonne identité : nom + badges + univers + résumé
    const info = document.createElement('div');
    info.className = 'per-camp-editor__info';

    const titre = document.createElement('div');
    titre.className = 'per-camp-editor__nom';
    titre.appendChild(document.createTextNode(ligne.nom));

    if (ligne.courante) {
      const b = document.createElement('span');
      b.className   = 'per-camp__badge per-camp__badge--courante';
      b.textContent = 'En cours';
      titre.appendChild(b);
    } else if (ligne.rattache && !ligne.actif) {
      const b = document.createElement('span');
      b.className   = 'per-camp__badge';
      b.textContent = 'Participation terminée';
      titre.appendChild(b);
    }

    if (ligne.univers) {
      const u = document.createElement('span');
      u.className   = 'per-camp__univers text-muted';
      u.textContent = ligne.univers;
      titre.appendChild(u);
    }
    info.appendChild(titre);

    if (ligne.resume) {
      const p = document.createElement('p');
      p.className   = 'per-camp__resume text-muted text-sm';
      p.textContent = ligne.resume;
      info.appendChild(p);
    }
    div.appendChild(info);

    // Colonne actions
    const actions = document.createElement('div');
    actions.className = 'per-camp-editor__actions';

    if (!ligne.rattache) {
      actions.appendChild(_bouton('Rattacher', 'fa-plus', 'btn-primary', function() {
        _action('rattacherCampagne', ligne.id);
      }));
    } else {
      if (ligne.courante) {
        actions.appendChild(_bouton('Plus en cours', 'fa-map-signs', 'btn-secondary', function() {
          // camp_id = 0 : le personnage n'a plus de campagne en cours
          _action('definirCampagneCourante', 0);
        }));
      } else {
        actions.appendChild(_bouton('Campagne en cours', 'fa-map', 'btn-secondary', function() {
          _action('definirCampagneCourante', ligne.id);
        }));
      }

      actions.appendChild(_bouton(
        ligne.actif ? 'Clore la participation' : 'Reprendre',
        ligne.actif ? 'fa-flag-checkered' : 'fa-undo',
        'btn-secondary',
        function() { _action('basculerParticipationCampagne', ligne.id); }
      ));

      actions.appendChild(_bouton('Détacher', 'fa-trash', 'btn-danger', function() {
        _action('detacherCampagne', ligne.id);
      }));
    }

    div.appendChild(actions);
    return div;
  }

  function _render() {
    const zone = document.getElementById('campagnes-editor-lignes');
    if (!zone) return;
    zone.innerHTML = '';
    _lignes.forEach(function(ligne) {
      zone.appendChild(_renderLigne(ligne));
    });
  }

  // ---- Écriture -------------------------------------------------

  async function _action(action, campId) {
    const zone = document.getElementById('campagnes-editor-lignes');
    if (zone) zone.querySelectorAll('button').forEach(function(b) { b.disabled = true; });

    const fd = new FormData();
    fd.append('action',  action);
    fd.append('pe_id',   perPeId);
    fd.append('camp_id', campId);
    fd.append('csrf_token', _csrf());

    try {
      const resp = await fetch(perUrlEnreg, { method: 'POST', body: fd });
      const data = await resp.json();

      if (!data.ok) {
        _afficherMsg(data.erreur || 'Erreur lors de l\'enregistrement.', 'erreur');
        return;
      }

      _modifie = true;
      _appliquerEtat(action, data);
      _render();
      _afficherMsg('Enregistré.', 'ok');
    } catch (e) {
      _afficherMsg('Erreur réseau : ' + e, 'erreur');
    } finally {
      if (zone) zone.querySelectorAll('button').forEach(function(b) { b.disabled = false; });
    }
  }

  // La campagne en cours vient du serveur et s'applique à toutes les lignes :
  // en désigner une nouvelle en destitue forcément une autre.
  function _appliquerEtat(action, data) {
    const courante = parseInt(data.camp_courante, 10) || 0;

    _lignes.forEach(function(l) {
      l.courante = (l.id === courante);
    });

    const cible = _lignes.find(function(l) { return l.id === parseInt(data.camp_id, 10); });
    if (!cible) return;

    if (action === 'detacherCampagne') {
      cible.rattache = false;
      cible.actif    = true;   // état par défaut si la campagne est re-rattachée
    } else {
      cible.rattache = !!data.rattache;
      cible.actif    = parseInt(data.actif, 10) === 1;
    }
  }

  // ---- Messages -------------------------------------------------

  function _afficherMsg(txt, type) {
    const el = document.getElementById('campagnes-msg');
    if (!el) return;
    el.textContent = txt;
    el.className   = 'per-classes-commit__msg per-classes-commit__msg--' + type;
    el.classList.remove('noDisplay');
  }

  function _cacherMsg() {
    const el = document.getElementById('campagnes-msg');
    if (el) el.classList.add('noDisplay');
  }

  return { basculerEdition, fermer };

})();

// ============================================================
// BLOC REPLIABLE DE LA FICHE (SP-RS6d)
// Utilisé par le bloc Mode jeu, replié par défaut. Le chevron pivote et
// aria-expanded suit l'état réel du corps du bloc.
// ============================================================

function perReplierBloc(idCorps, btn) {
  const corps = document.getElementById(idCorps);
  if (!corps) return;

  const ouvert = corps.classList.toggle('noDisplay') === false;
  if (btn) {
    btn.setAttribute('aria-expanded', ouvert ? 'true' : 'false');
    btn.classList.toggle('is-open', ouvert);
  }
}
