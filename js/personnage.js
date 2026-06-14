// js/personnage.js — Interactions du module Personnages.
// Chargé uniquement sur les pages du module ($js_module = 'personnage').
// perUrlDetail / perUrlModifier / perUrlEnreg / perUrlFiche injectés en inline par index.php.
//
// SOUS-PHASE 3.0 : socle — menu contextuel + suppression inline depuis la liste.
// Les éditeurs DOM (classes, compétences, dons, NLS, sorts) seront ajoutés
// dans les sous-phases 3.2 à 3.6.
'use strict';

// ============================================================
// MENU CONTEXTUEL — miroir de campToggleMenu (campagne.js)
// Aucune de ces fonctions n'est chargée sur les pages personnages.
// ============================================================

function perToggleMenu(id) {
  const menu = document.getElementById('comp-menu-' + id);
  if (!menu) return;

  document.querySelectorAll('.comp-menu-dropdown').forEach(m => {
    if (m !== menu) m.classList.add('noDisplay');
  });
  menu.classList.toggle('noDisplay');

  if (!menu.classList.contains('noDisplay')) {
    setTimeout(() => {
      document.addEventListener('click', function handler(e) {
        if (!menu.contains(e.target)) {
          menu.classList.add('noDisplay');
          document.removeEventListener('click', handler);
        }
      });
    }, 0);
  }
}

// ============================================================
// SUPPRESSION INLINE PERSONNAGE (depuis la liste index.php)
// ============================================================

function perDemanderSuppression(id) {
  const row     = document.getElementById('per-row-' + id);
  const confirm = document.getElementById('per-confirm-' + id);
  if (!row || !confirm) return;

  row.dataset.backup = row.innerHTML;
  const nbCols = row.querySelectorAll('td').length;
  row.innerHTML = `<td colspan="${nbCols}" class="comp-confirm-row">${confirm.innerHTML}</td>`;
}

async function perConfirmerSuppression(id) {
  try {
    const data = await postAjax(perUrlEnreg, { action: 'supprimerPersonnage', id: id });
    if (data.ok) {
      rafraichirListe();
    } else {
      alert(data.erreur || 'Erreur lors de la suppression.');
      perAnnulerSuppression(id);
    }
  } catch (err) {
    alert('Erreur : ' + err);
    perAnnulerSuppression(id);
  }
}

function perAnnulerSuppression(id) {
  const row = document.getElementById('per-row-' + id);
  if (row && row.dataset.backup) row.innerHTML = row.dataset.backup;
}

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
// ÉDITEUR CLASSES INLINE (3.2)
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
      if (btn) btn.innerHTML = '<i class="fa fa-times"></i> Annuler';
    } else {
      lecture.classList.remove('noDisplay');
      edition.classList.add('noDisplay');
      if (btn) btn.innerHTML = '<i class="fa fa-edit"></i> Modifier';
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
    if (btn)     btn.innerHTML = '<i class="fa fa-edit"></i> Modifier';
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
