// js/personnage.js — Interactions du module Personnages.
// Chargé uniquement sur les pages du module ($js_module = 'personnage').
// perUrlDetail / perUrlModifier / perUrlEnreg / perUrlFiche injectés en inline par index.php.
//
// SP-PE0 : socle — menu contextuel + suppression inline depuis la liste.
// SP-PE2 : éditeur DOM Classes inline.
// SP-PE3 : éditeur DOM Compétences inline.
// SP-PE4 : sélecteur de dons deux volets (donsPicker).
// SP-PE5 : éditeur de rattachement aux campagnes (campagnesEditor).
// SP-PE6 : éditeur NLS prestige DD3.5 (nlsEditor).
// Reste : sorts (SP-PE7 — vue Magie).
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

// Bascule l'apparence d'un bouton « Modifier » d'en-tête de bloc.
//
// Depuis SP-PE10h ces boutons n'ont plus que leur icône : le title est leur
// seul libellé, il doit donc suivre la bascule. Le title d'origine est relevé
// au premier passage et restauré au retour en lecture — « Modifier les
// compétences » est plus utile qu'un « Modifier » générique (SP-PE10i).
function perBasculerBoutonEditer(btn, enEdition) {
  if (!btn) return;
  if (!btn.dataset.titreLecture) btn.dataset.titreLecture = btn.title || 'Modifier';
  btn.innerHTML = enEdition ? '<i class="fa fa-times"></i>' : '<i class="fa fa-edit"></i>';
  btn.title     = enEdition ? 'Annuler la modification' : btn.dataset.titreLecture;
}

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
      if (btn) perBasculerBoutonEditer(btn, true);
    } else {
      lecture.classList.remove('noDisplay');
      edition.classList.add('noDisplay');
      if (btn) perBasculerBoutonEditer(btn, false);
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
    if (btn)     perBasculerBoutonEditer(btn, false);
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
      // Mêmes abréviations qu'en lecture (SP-PE10j) : la colonne de saisie
      // n'a pas à être plus large que celle qu'elle remplace.
      [[0, '—'], [1, 'M.'], [2, 'E']].forEach(function(paire) {
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
      if (btn) perBasculerBoutonEditer(btn, true);
    } else {
      lecture.classList.remove('noDisplay');
      edition.classList.add('noDisplay');
      if (btn) perBasculerBoutonEditer(btn, false);
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
    if (btn)     perBasculerBoutonEditer(btn, false);
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
      // Écriture immédiate, sans bouton Enregistrer : elle doit laisser une
      // trace visible (composant notifier(), SP-CP1 — voir doc §12b).
      notifier(data.possede ? 'Don ajouté' : 'Don retiré');
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
      if (btn)     perBasculerBoutonEditer(btn, true);
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
    if (btn)     perBasculerBoutonEditer(btn, false);
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
      // Écriture immédiate : pastille globale plutôt qu'un message local, pour
      // que le retour soit le même partout dans le site (SP-CP1, doc §12b).
      // _afficherMsg reste employée pour les erreurs, qui doivent rester
      // affichées près de l'éditeur.
      notifier('Enregistré');
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
// ÉDITEUR NLS PRESTIGE (SP-PE6 — DD3.5)
// Gère le bloc NLS prestige de la fiche : un tableau par classe de
// prestige influant sur le NLS, un select de classe de base lanceuse
// compatible par niveau. Commit global du bloc (action enregistrerNls),
// comme Classes et Compétences — DELETE + INSERT côté serveur.
//
// Saisie déclarative : un niveau peut rester « À affecter » (archi §7.5d).
// Un niveau dont aucun drapeau cn_niveauSort* n'est levé ne fait pas
// progresser le NLS : ligne grisée, sans select.
//
// Dépend des variables injectées par fiche.php :
//   perPeId, perUrlEnreg, perNlsBases, perNlsPrestiges
// ============================================================

const nlsEditor = (function() {
  'use strict';

  let _etatEdition = false;
  // Copie locale : [{pc_id, nom, niveau, niveaux: {n: {arcane, divin,
  // effectif, base_pc_id}}}] — niveaux est un objet (clés JSON "1".."n").
  let _prestiges = [];

  function _csrf() {
    const meta = document.querySelector('meta[name="csrf-token"]');
    return meta ? meta.getAttribute('content') : '';
  }

  // Classes de base compatibles avec les drapeaux d'un niveau :
  // effectif → toutes les lanceuses ; arcane → cla_mag_id = 1 ;
  // divin → cla_mag_id = 2. Les drapeaux se cumulent (union).
  function _basesCompatibles(niv) {
    return (perNlsBases || []).filter(function(b) {
      if (niv.effectif) return true;
      if (niv.arcane && b.mag_id === 1) return true;
      if (niv.divin  && b.mag_id === 2) return true;
      return false;
    });
  }

  // ---- Rendu ----------------------------------------------------

  function _buildSelectBase(prestige, n, niv) {
    const sel = document.createElement('select');
    sel.className = 'per-comp-editor__select';

    const opt0 = document.createElement('option');
    opt0.value = '0';
    opt0.textContent = '— À affecter —';
    sel.appendChild(opt0);

    _basesCompatibles(niv).forEach(function(b) {
      const opt = document.createElement('option');
      opt.value = b.pc_id;
      opt.textContent = b.nom;
      if (b.pc_id === niv.base_pc_id) opt.selected = true;
      sel.appendChild(opt);
    });

    sel.addEventListener('change', function() {
      niv.base_pc_id = parseInt(this.value, 10) || 0;
    });
    return sel;
  }

  function _renderPrestige(prestige) {
    const div = document.createElement('div');
    div.className = 'per-nls__classe';

    const h3 = document.createElement('h3');
    h3.className = 'per-nls__titre';
    h3.textContent = prestige.nom + ' ';
    const spanNiv = document.createElement('span');
    spanNiv.className = 'per-classes__niveau';
    spanNiv.textContent = 'niv. ' + prestige.niveau;
    h3.appendChild(spanNiv);
    div.appendChild(h3);

    const wrap  = document.createElement('div');
    wrap.className = 'table-dd-wrap';
    const table = document.createElement('table');
    table.className = 'table-dd per-nls-table';

    const thead = document.createElement('thead');
    thead.innerHTML =
      '<tr>' +
        '<th class="col-stat">Niveau</th>' +
        '<th class="per-nls-table__prog">Progression</th>' +
        '<th class="per-nls-table__classe">Classe de base affectée</th>' +
      '</tr>';
    table.appendChild(thead);

    const tbody = document.createElement('tbody');
    Object.keys(prestige.niveaux).forEach(function(n) {
      const niv = prestige.niveaux[n];
      const progresse = !!(niv.arcane || niv.divin || niv.effectif);

      const tr = document.createElement('tr');

      const tdNiv = document.createElement('td');
      tdNiv.textContent = n;
      tr.appendChild(tdNiv);

      const tdProg = document.createElement('td');
      tdProg.className = 'per-nls-table__prog';
      if (progresse) {
        const parts = [];
        if (niv.effectif) parts.push('Effectif');
        if (niv.arcane)   parts.push('Arcane');
        if (niv.divin)    parts.push('Divin');
        tdProg.textContent = parts.join(' + ');
      } else {
        const span = document.createElement('span');
        span.className   = 'text-muted';
        span.textContent = '—';
        tdProg.appendChild(span);
      }
      tr.appendChild(tdProg);

      const tdClasse = document.createElement('td');
      tdClasse.className = 'per-nls-table__classe';
      if (progresse) {
        tdClasse.appendChild(_buildSelectBase(prestige, n, niv));
      } else {
        const span = document.createElement('span');
        span.className   = 'text-muted';
        span.textContent = 'Sans progression de NLS';
        tdClasse.appendChild(span);
      }
      tr.appendChild(tdClasse);

      tbody.appendChild(tr);
    });
    table.appendChild(tbody);

    wrap.appendChild(table);
    div.appendChild(wrap);
    return div;
  }

  function _render() {
    const zone = document.getElementById('nls-editor-lignes');
    if (!zone) return;
    zone.innerHTML = '';
    _prestiges.forEach(function(p) {
      zone.appendChild(_renderPrestige(p));
    });
  }

  // ---- API publique ---------------------------------------------

  function _init() {
    // Copie profonde : annuler ne doit pas garder les choix abandonnés
    _prestiges = JSON.parse(JSON.stringify(perNlsPrestiges || []));
  }

  function basculerEdition() {
    _etatEdition = !_etatEdition;
    const lecture = document.getElementById('nls-lecture');
    const edition = document.getElementById('nls-edition');
    const btn     = document.getElementById('btn-editer-nls');
    if (!lecture || !edition) return;

    if (_etatEdition) {
      // Le bloc est replié par défaut : on l'ouvre, sinon l'éditeur se
      // chargerait dans un corps masqué (SP-PE10n).
      perDeplierBloc('bloc-nls-body', 'btn-replier-nls');
      _init();
      _render();
      lecture.classList.add('noDisplay');
      edition.classList.remove('noDisplay');
      if (btn) perBasculerBoutonEditer(btn, true);
    } else {
      annuler();
    }
  }

  function annuler() {
    _etatEdition = false;
    const lecture = document.getElementById('nls-lecture');
    const edition = document.getElementById('nls-edition');
    const btn     = document.getElementById('btn-editer-nls');
    if (lecture) lecture.classList.remove('noDisplay');
    if (edition) edition.classList.add('noDisplay');
    if (btn)     perBasculerBoutonEditer(btn, false);
    _cacherMsg();
  }

  async function enregistrer() {
    const formData = new FormData();
    formData.append('action', 'enregistrerNls');
    formData.append('pe_id',  perPeId);
    // CSRF token lu depuis la meta tag (même pattern que postAjax dans main.js)
    const csrfMeta = document.querySelector('meta[name="csrf-token"]');
    if (csrfMeta) formData.append('csrf_token', csrfMeta.getAttribute('content'));

    // Seules les affectations réellement saisies sont transmises : un niveau
    // laissé « À affecter » n'envoie rien, l'enregistrement reste valide.
    let i = 0;
    _prestiges.forEach(function(p) {
      Object.keys(p.niveaux).forEach(function(n) {
        const niv = p.niveaux[n];
        if (niv.base_pc_id > 0) {
          formData.append('nls[' + i + '][pc_prestige]', p.pc_id);
          formData.append('nls[' + i + '][niveau]',      n);
          formData.append('nls[' + i + '][pc_base]',     niv.base_pc_id);
          i++;
        }
      });
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
    const el = document.getElementById('nls-msg');
    if (!el) return;
    el.textContent = txt;
    el.className   = 'per-classes-commit__msg per-classes-commit__msg--' + type;
    el.classList.remove('noDisplay');
  }

  function _cacherMsg() {
    const el = document.getElementById('nls-msg');
    if (el) el.classList.add('noDisplay');
  }

  return { basculerEdition, annuler, enregistrer };

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

// Déplie un bloc replié, sans le replier s'il est déjà ouvert.
//
// Un bloc replié par défaut (SP-PE10n) garde son bouton Modifier accessible
// dans l'en-tête : sans cela, ouvrir l'éditeur reviendrait à le charger dans
// un corps masqué, et le clic n'aurait aucun effet visible.
function perDeplierBloc(idCorps, idBtn) {
  const corps = document.getElementById(idCorps);
  if (!corps || !corps.classList.contains('noDisplay')) return;
  perReplierBloc(idCorps, document.getElementById(idBtn));
}

// ============================================================
// ONGLETS DES LISTES DE SORTS (SP-PE10r)
// Un jeu d'onglets par bloc de classe de la vue Magie. L'onglet actif est
// gardé par bloc en sessionStorage : le sélecteur de sorts recharge la page à
// sa fermeture, et sans cela on retomberait toujours sur « Préparés ».
// Stockage indisponible (navigation privée…) : on reste sur le premier onglet.
// ============================================================

const perOnglets = (function() {

  function _cle(bloc) {
    return 'perMagieOnglet:' + (typeof perPeId !== 'undefined' ? perPeId : 0)
         + ':' + bloc.dataset.onglets;
  }

  function activer(bloc, cle, memoriser) {
    const onglets = bloc.querySelectorAll('.per-magie__onglet');
    let trouve = false;
    onglets.forEach(function(o) { if (o.dataset.onglet === cle) trouve = true; });
    if (!trouve) return;

    onglets.forEach(function(o) {
      const actif = o.dataset.onglet === cle;
      o.classList.toggle('est-actif', actif);
      o.setAttribute('aria-selected', actif ? 'true' : 'false');
      o.tabIndex = actif ? 0 : -1;
    });
    bloc.querySelectorAll('.per-magie__panneau, .per-magie__outils').forEach(function(el) {
      el.hidden = el.dataset.onglet !== cle;
    });
    if (memoriser) {
      try { sessionStorage.setItem(_cle(bloc), cle); } catch (e) { /* stockage indisponible */ }
    }
  }

  function _init() {
    document.querySelectorAll('.per-magie__onglets').forEach(function(bloc) {
      let memo = null;
      try { memo = sessionStorage.getItem(_cle(bloc)); } catch (e) { memo = null; }
      if (memo) activer(bloc, memo, false);

      bloc.addEventListener('click', function(e) {
        const o = e.target.closest('.per-magie__onglet');
        if (o && bloc.contains(o)) activer(bloc, o.dataset.onglet, true);
      });

      // Flèches gauche / droite entre onglets (motif ARIA tablist).
      bloc.addEventListener('keydown', function(e) {
        const o = e.target.closest('.per-magie__onglet');
        if (!o || (e.key !== 'ArrowLeft' && e.key !== 'ArrowRight')) return;
        const liste = Array.from(bloc.querySelectorAll('.per-magie__onglet'));
        const i = liste.indexOf(o);
        const suivant = liste[(i + (e.key === 'ArrowRight' ? 1 : liste.length - 1)) % liste.length];
        activer(bloc, suivant.dataset.onglet, true);
        suivant.focus();
        e.preventDefault();
      });
    });
  }

  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', _init);
  else _init();

  return { activer };
})();

// ============================================================
// SÉLECTEUR DE SORTS (SP-PE7b)
// ============================================================
//
// Même motif que donsPicker : deux volets dans #detail-pp, écriture immédiate au
// clic, panneau qui reste ouvert pour enchaîner les choix (Q8, D-MAG13).
//
// Deux différences tenant aux règles :
//   * il est TOUJOURS PORTÉ PAR CLASSE (pc_id) — en multiclassage, une écriture
//     ne doit jamais toucher la liste d'une autre classe ;
//   * il a deux modes, « repertoire » et « prepare », dont le réservoir diffère
//     selon le profil d'incantation (voir l'en-tête de sorts-picker.php).
//
// Globals attendus, injectés par personnages/magie.php :
//   perPeId, perUrlEnreg, perUrlSortsPicker, perUrlSortDetail
const sortsPicker = (function() {
  'use strict';

  let _modifie = false;   // au moins une écriture → la page sera rechargée

  function _panel()    { return document.getElementById('detail-pp'); }
  function _backdrop() { return document.getElementById('detail-pp-backdrop'); }
  function _racine()   { return document.querySelector('.sorts-picker'); }

  // ---- Ouverture / fermeture ------------------------------------

  function ouvrir(pcId, mode) {
    const panel = _panel();
    const bd    = _backdrop();
    if (!panel) return;

    _modifie = false;
    if (bd) bd.classList.remove('noDisplay');
    panel.classList.remove('noDisplay');
    panel.innerHTML = '<div class="loading"><i class="fa fa-spinner fa-spin"></i> Chargement…</div>';

    const url = perUrlSortsPicker
      + '?pe_id=' + encodeURIComponent(perPeId)
      + '&pc_id=' + encodeURIComponent(pcId)
      + '&mode='  + encodeURIComponent(mode || 'repertoire');

    fetch(url)
      .then(function(r) { if (!r.ok) throw new Error('Erreur ' + r.status); return r.text(); })
      .then(function(html) {
        panel.innerHTML =
          '<button class="overlay-close" onclick="sortsPicker.fermer()" title="Fermer">'
          + '<i class="fa fa-times"></i></button>'
          + '<div class="overlay-panel__inner">' + html + '</div>';
        filtrer();
        _majCompteurs();
      })
      .catch(function(e) { panel.innerHTML = '<p class="erreur">' + e + '</p>'; });
  }

  function fermer() {
    const panel = _panel();
    const bd    = _backdrop();
    if (panel) { panel.classList.add('noDisplay'); panel.innerHTML = ''; }
    if (bd)    bd.classList.add('noDisplay');
    // Les sections de la page sont rendues côté serveur (emplacements, compteurs,
    // sorts toujours préparés) : on ne les resynchronise qu'à la fermeture, et
    // seulement si quelque chose a bougé.
    if (_modifie) window.location.reload();
  }

  // ---- Filtrage local (nom + niveau de sort) --------------------

  function filtrer() {
    const champQ   = document.getElementById('sorts-picker-q');
    const champNiv = document.getElementById('sorts-picker-niv');
    const champMi  = document.getElementById('sorts-picker-miens');
    const q        = champQ   ? champQ.value.trim().toLowerCase() : '';
    const niv      = champNiv ? champNiv.value : '';
    // « Les siens seulement » : la liste de classe fait plus de mille entrées
    // chez un magicien ; retrouver ce qu'on possède déjà y est pénible.
    const miens    = champMi ? champMi.checked : false;

    let visibles = 0;
    // Un niveau encore représenté garde son en-tête ; les autres s'effacent.
    const niveauxVus = {};
    document.querySelectorAll('.sorts-picker__item').forEach(function(li) {
      const okNom = !q   || li.dataset.nom.indexOf(q) !== -1;
      const okNiv = niv === '' || li.dataset.niv === niv;
      const okMi  = !miens || li.classList.contains('est-choisi');
      const ok    = okNom && okNiv && okMi;
      li.classList.toggle('noDisplay', !ok);
      if (ok) { visibles++; niveauxVus[li.dataset.niv] = true; }
    });

    // L'en-tête de niveau remplace la pastille que portait chaque ligne
    // (SP-PE10f) : il ne doit pas survivre au filtrage de son groupe.
    document.querySelectorAll('.sorts-picker__entete').forEach(function(li) {
      li.classList.toggle('noDisplay', !niveauxVus[li.dataset.entete]);
    });

    const d = document.getElementById('sorts-picker-decompte');
    if (d) d.textContent = visibles + ' sort' + (visibles > 1 ? 's' : '');
  }

  // ---- Fiche du sort --------------------------------------------
  //
  // Sur ordinateur, elle s'affiche dans le volet droit, à côté de la liste.
  // Sur téléphone ce volet est masqué (SP-PE10d) : il mangeait plus de la
  // moitié de la largeur alors que le choix se fait dans la liste. La fiche
  // s'ouvre alors dans #detail-pp-sub, PAR-DESSUS le sélecteur, qui reste
  // ouvert et retrouve sa place à la fermeture du sous-panneau.
  function _estCompact() {
    return window.matchMedia('(max-width: 991px)').matches;
  }

  function voir(soId) {
    document.querySelectorAll('.sorts-picker__item').forEach(function(li) {
      li.classList.toggle('is-courant', parseInt(li.dataset.id, 10) === soId);
    });

    if (_estCompact()) {
      actualiserPageSub(perUrlSortDetail, { id: soId });
      return;
    }

    const zone = document.getElementById('sorts-picker-detail');
    if (!zone) return;

    zone.innerHTML = '<div class="loading"><i class="fa fa-spinner fa-spin"></i> Chargement…</div>';
    fetch(perUrlSortDetail + '?id=' + encodeURIComponent(soId))
      .then(function(r) { if (!r.ok) throw new Error('Erreur ' + r.status); return r.text(); })
      .then(function(html) { zone.innerHTML = html; zone.scrollTop = 0; })
      .catch(function(e) { zone.innerHTML = '<p class="erreur">' + e + '</p>'; });
  }

  // ---- Compteurs de préparation ---------------------------------
  //
  // Recalculés depuis le DOM plutôt que depuis la réponse serveur : le serveur
  // renvoie un total par classe, alors qu'en DD3.5 il faut un décompte PAR
  // NIVEAU DE SORT — c'est le nombre d'emplacements de chaque niveau qui borne
  // la préparation, pas un plafond global. Compter les éléments cochés est
  // exact et évite un aller-retour par clic.
  function _majCompteurs() {
    const r = _racine();
    if (!r || r.dataset.mode !== 'prepare') return;

    // Somme des exemplaires d'une sélection de lignes. En DD3.5 un sort se
    // prépare plusieurs fois (data-nb) ; ailleurs, une ligne retenue vaut 1.
    function _total(sel) {
      let n = 0;
      r.querySelectorAll(sel).forEach(function(li) {
        n += Math.max(1, parseInt(li.dataset.nb, 10) || 1);
      });
      return n;
    }

    // DD2024 — plafond global, en sorts DISTINCTS. Les sorts mineurs (niveau 0)
    // sont connus, pas préparés : ils n'y comptent pas (SP-PE10s).
    const global = r.querySelector('[data-restant-global]');
    if (global && r.dataset.plafond !== '') {
      const max     = parseInt(r.dataset.plafond, 10) || 0;
      const choisis = r.querySelectorAll('.sorts-picker__item.est-choisi:not([data-niv="0"])').length;
      const reste   = Math.max(0, max - choisis);
      global.textContent = reste;
      global.closest('.sorts-picker__compteur')
            .classList.toggle('est-plein', reste === 0);
      return;
    }

    // DD3.5 — un compteur par niveau de sort
    let plafonds = {};
    try { plafonds = JSON.parse(r.dataset.plafondsNiveau || '{}'); } catch (e) { plafonds = {}; }
    Object.keys(plafonds).forEach(function(n) {
      const cible = r.querySelector('[data-restant="' + n + '"]');
      if (!cible) return;
      // Un emplacement par exemplaire préparé : c'est la somme qui compte.
      const choisis = _total('.sorts-picker__item.est-choisi[data-niv="' + n + '"]');
      const reste = Math.max(0, parseInt(plafonds[n], 10) - choisis);
      cible.textContent = reste;
      const jeton = cible.closest('.sorts-picker__jeton');
      if (jeton) jeton.classList.toggle('est-plein', reste === 0);
    });
  }

  // ---- Écritures ------------------------------------------------

  function _contexte() {
    const r = _racine();
    return r ? { pc: r.dataset.pc, cla: r.dataset.cla, mode: r.dataset.mode } : null;
  }

  async function basculer(soId) {
    const ctx = _contexte();
    const li  = document.querySelector('.sorts-picker__item[data-id="' + soId + '"]');
    if (!ctx || !li) return;

    const choisi = li.classList.contains('est-choisi');
    let action;
    if (ctx.mode === 'prepare') action = choisi ? 'retirerPrepare' : 'preparerSort';
    else                        action = choisi ? 'retirerSort'    : 'ajouterSort';

    try {
      const data = await postAjax(perUrlEnreg, {
        action: action, pe_id: perPeId, pc_id: ctx.pc, cla_id: ctx.cla, so_id: soId
      });
      if (!data.ok) { notifier(data.erreur || 'Échec de l\'enregistrement', 'erreur'); return; }

      _modifie = true;
      li.dataset.nb = choisi ? 0 : 1;
      li.classList.toggle('est-choisi', !choisi);
      const icone = li.querySelector('.dons-picker__toggle i');
      if (icone) icone.className = 'fa fa-' + (choisi ? 'plus' : 'minus');
      _majBoutonGrimoire(li, soId, !choisi);
      _majCompteurs();
      // « Les siens seulement » actif : un sort retiré doit disparaître aussitôt.
      const champMi = document.getElementById('sorts-picker-miens');
      if (champMi && champMi.checked) filtrer();
      notifier(choisi ? 'Sort retiré' : 'Sort ajouté');
    } catch (e) {
      notifier('Erreur réseau', 'erreur');
    }
  }

  // ---- Quantité préparée (DD3.5) --------------------------------
  //
  // En DD3.5, préparer n'est pas un oui/non : un magicien mémorise plusieurs
  // fois le même sort, chaque exemplaire occupant un emplacement de son niveau.
  // La ligne porte donc un compteur, et chaque clic vaut UN exemplaire — le
  // serveur incrémente ou décrémente `pesp_nb`, et supprime la ligne au dernier
  // retrait (SP-PE10e).
  //
  // Rien n'interdit de dépasser le nombre d'emplacements : la page est une aide
  // de jeu, pas un moteur de règles (§7.1). Le jeton du niveau vire au rouge,
  // et c'est tout.
  function ajouterUn(soId) { return _ajuster(soId, +1); }
  function retirerUn(soId) { return _ajuster(soId, -1); }

  async function _ajuster(soId, delta) {
    const ctx = _contexte();
    const li  = document.querySelector('.sorts-picker__item[data-id="' + soId + '"]');
    if (!ctx || !li) return;

    const avant = Math.max(0, parseInt(li.dataset.nb, 10) || 0);
    if (delta < 0 && avant === 0) return;

    try {
      const data = await postAjax(perUrlEnreg, {
        action: delta > 0 ? 'preparerSort' : 'retirerPrepare',
        pe_id: perPeId, pc_id: ctx.pc, cla_id: ctx.cla, so_id: soId
      });
      if (!data.ok) { notifier(data.erreur || 'Echec de l\'enregistrement', 'erreur'); return; }

      _modifie = true;
      // Le serveur fait foi : lui seul sait ce que la ligne porte vraiment.
      const nb = (typeof data.nb === 'number') ? data.nb : Math.max(0, avant + delta);
      _poserQuantite(li, nb);
      _majCompteurs();
      const champMi = document.getElementById('sorts-picker-miens');
      if (champMi && champMi.checked) filtrer();
      notifier(delta > 0 ? 'Sort préparé' : 'Exemplaire retiré');
    } catch (e) {
      notifier('Erreur réseau', 'erreur');
    }
  }

  function _poserQuantite(li, nb) {
    li.dataset.nb = nb;
    li.classList.toggle('est-choisi', nb > 0);
    const lbl = li.querySelector('[data-nb-lbl]');
    if (lbl) lbl.textContent = nb;
    const moins = li.querySelector('.sorts-picker__moins');
    if (moins) moins.disabled = (nb === 0);
  }

  // Le bouton « recopier dans le grimoire » n'a de sens que sur un sort retenu :

  // on ne recopie pas un sort qu'on ne connaît pas. Il n'était posé qu'au rendu
  // serveur, si bien qu'un sort tout juste ajouté n'en avait pas tant que le
  // panneau n'était pas rouvert (SP-PE10d). Il suit maintenant l'état du sort.
  //
  // Un sort ajouté ici ne l'est jamais déjà recopié (`pes_compris = 0`) : le
  // bouton naît donc toujours sur « livre ouvert ».
  function _majBoutonGrimoire(li, soId, retenu) {
    const r = _racine();
    if (!r || r.dataset.mode !== 'repertoire' || r.dataset.grimoire !== '1') return;

    const existant = li.querySelector('.dons-picker__grimoire');
    if (!retenu) { if (existant) existant.remove(); return; }
    if (existant) return;

    const btn = document.createElement('button');
    btn.type      = 'button';
    btn.className = 'btn btn-sm dons-picker__toggle dons-picker__grimoire';
    btn.title     = 'Recopier dans le grimoire';
    btn.onclick   = function() { grimoire(soId); };
    btn.innerHTML = '<i class="fa fa-book-open"></i>';
    li.appendChild(btn);
  }

  // « Recopier dans le grimoire » et son inverse : un sort CONNU n'est
  // préparable qu'une fois COMPRIS (lecture A, D-MAG6).
  async function grimoire(soId) {
    const ctx = _contexte();
    const li  = document.querySelector('.sorts-picker__item[data-id="' + soId + '"]');
    if (!ctx || !li) return;

    // Ciblé par sa classe : le bouton n'est plus forcément le second
    // enfant depuis qu'il est posé et retiré dynamiquement.
    const btn    = li.querySelector('.dons-picker__grimoire');
    const dedans = btn && btn.querySelector('i').classList.contains('fa-book');

    try {
      const data = await postAjax(perUrlEnreg, {
        action: 'basculerGrimoire', pe_id: perPeId, pc_id: ctx.pc,
        so_id: soId, compris: dedans ? 0 : 1
      });
      if (!data.ok) { notifier(data.erreur || 'Échec de l\'enregistrement', 'erreur'); return; }

      _modifie = true;
      if (btn) {
        btn.querySelector('i').className = 'fa fa-book' + (data.compris ? '' : '-open');
        btn.title = data.compris ? 'Retirer du grimoire' : 'Recopier dans le grimoire';
      }
      notifier(data.compris ? 'Recopié dans le grimoire' : 'Retiré du grimoire');
    } catch (e) {
      notifier('Erreur réseau', 'erreur');
    }
  }

  // Contrepartie de l'écriture immédiate : refaire sa liste du matin en un geste
  // plutôt qu'un sort à la fois. Ne touche pas les sorts toujours préparés.
  async function reinitialiser(claId, nomClasse) {
    if (!confirm('Vider la liste des sorts préparés de ' + nomClasse + ' ?\n'
               + 'Les sorts toujours préparés sont conservés.')) return;
    try {
      const data = await postAjax(perUrlEnreg, {
        action: 'reinitialiserPrepares', pe_id: perPeId, cla_id: claId
      });
      if (!data.ok) { notifier(data.erreur || 'Échec', 'erreur'); return; }
      notifier(data.supprimes + ' sort(s) retiré(s)');
      window.location.reload();
    } catch (e) {
      notifier('Erreur réseau', 'erreur');
    }
  }

  return { ouvrir, fermer, filtrer, voir, basculer, ajouterUn, retirerUn,
           grimoire, reinitialiser };
})();
