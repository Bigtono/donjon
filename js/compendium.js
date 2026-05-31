// ============================================================
// FILTRE MOBILE — toggle repliable
// ============================================================

function toggleFiltresMobile() {
  const content = document.getElementById('comp-filtre-content');
  const btn = document.getElementById('filtre-toggle-btn');
  if (!content || !btn) return;

  const isOpen = !content.classList.contains('is-closed');
  if (isOpen) {
    content.classList.add('is-closed');
    btn.classList.remove('is-open');
    btn.setAttribute('aria-expanded', 'false');
  } else {
    content.classList.remove('is-closed');
    btn.classList.add('is-open');
    btn.setAttribute('aria-expanded', 'true');
  }
}

// Initialisation : masqué en mobile par défaut
document.addEventListener('DOMContentLoaded', () => {
  if (window.innerWidth <= 991) {
    const content = document.getElementById('comp-filtre-content');
    if (content) content.classList.add('is-closed');
  }

  // Ferme le menu sources si clic extérieur
  document.addEventListener('click', e => {
    document.querySelectorAll('.comp-filtre-sources-menu').forEach(menu => {
      if (!menu.classList.contains('noDisplay') &&
        !menu.parentElement.contains(e.target)) {
        const entite = menu.id.replace('sources-menu-', '');
        fermerSources(entite);
      }
    });
  });
});

// ============================================================
// SOURCES — menu contextuel + badge
// ============================================================

function toggleSources(entite) {
  const menu = document.getElementById('sources-menu-' + entite);
  const btn = document.getElementById('sources-btn-' + entite);
  const chevron = document.getElementById('sources-chevron-' + entite);
  if (!menu) return;

  const isOpen = !menu.classList.contains('noDisplay');
  if (isOpen) {
    fermerSources(entite);
  } else {
    menu.classList.remove('noDisplay');
    if (btn) btn.classList.add('is-open');
    if (chevron) chevron.style.transform = 'rotate(180deg)';
  }
}

function fermerSources(entite) {
  const menu = document.getElementById('sources-menu-' + entite);
  const btn = document.getElementById('sources-btn-' + entite);
  const chevron = document.getElementById('sources-chevron-' + entite);
  if (menu) menu.classList.add('noDisplay');
  if (btn) btn.classList.remove('is-open');
  if (chevron) chevron.style.transform = '';
}

function majSourcesBadge(entite) {
  const menu = document.getElementById('sources-menu-' + entite);
  const badge = document.getElementById('sources-badge-' + entite);
  if (!menu || !badge) return;

  const checked = menu.querySelectorAll('input[type="checkbox"]:checked').length;
  badge.textContent = checked;
  badge.style.display = checked > 0 ? 'inline-flex' : 'none';
}

// js/compendium.js — Fonctions communes aux listes du compendium
'use strict';

// ============================================================
// MENU LIGNE (⋮)
// ============================================================

function compToggleMenu(id) {
  const menu = document.getElementById('comp-menu-' + id);
  if (!menu) return;

  // Ferme tous les autres menus ouverts
  document.querySelectorAll('.comp-menu-dropdown').forEach(m => {
    if (m !== menu) m.classList.add('noDisplay');
  });
  menu.classList.toggle('noDisplay');

  // Ferme au clic extérieur
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
// SUPPRESSION INLINE
// ============================================================

function compDemanderSuppression(id) {
  // Masque la ligne normale, affiche la confirmation
  const row = document.getElementById('row-' + id);
  const confirm = document.getElementById('comp-confirm-' + id);
  if (!row || !confirm) return;

  // Stocke le contenu original des cellules pour restauration
  row.dataset.backup = row.innerHTML;
  // Vide la ligne et insère la confirmation sur toute la largeur
  const nbCols = row.querySelectorAll('td').length;
  row.innerHTML = `<td colspan="${nbCols}" class="comp-confirm-row">
    ${confirm.innerHTML}
  </td>`;
}

// Ré-initialise en lisant les templates (plus simple : rechargement de la ligne)
function compAnnulerSuppression(id) {
  // Simple : recharge la page pour restaurer l'état (les filtres GET sont préservés)
  window.location.reload();
}

function compConfirmerSuppression(id) {
  const form = document.getElementById('comp-bulk-form');
  if (!form) return;

  document.getElementById('comp-bulk-action-hidden').value = 'supprimer';
  document.getElementById('comp-bulk-ids').innerHTML =
    `<input type="hidden" name="ids[]" value="${id}">`;

  form.submit();
}

// ============================================================
// SÉLECTION MULTIPLE ET BARRE BULK
// ============================================================

document.addEventListener('DOMContentLoaded', () => {
  const selectAll = document.getElementById('comp-select-all');
  const bulkBar = document.getElementById('comp-bulk-bar');

  if (selectAll) {
    selectAll.addEventListener('change', () => {
      document.querySelectorAll('.comp-check').forEach(cb => {
        cb.checked = selectAll.checked;
      });
      compMajBulkBar();
    });
  }

  // Délégation sur le tbody pour les checkboxes individuelles
  document.addEventListener('change', e => {
    if (e.target.classList.contains('comp-check')) compMajBulkBar();
  });
});

function compMajBulkBar() {
  const checked = document.querySelectorAll('.comp-check:checked');
  const bulkBar = document.getElementById('comp-bulk-bar');
  const counter = document.getElementById('comp-bulk-count');

  if (!bulkBar) return;
  bulkBar.style.display = checked.length > 0 ? 'flex' : 'none';
  if (counter) counter.textContent = checked.length;

  // Sync select-all
  const total = document.querySelectorAll('.comp-check').length;
  const selAll = document.getElementById('comp-select-all');
  if (selAll) selAll.checked = checked.length === total && total > 0;
}

function compDeselectionnerTout() {
  document.querySelectorAll('.comp-check, #comp-select-all').forEach(cb => {
    cb.checked = false;
  });
  compMajBulkBar();
}

function compSoumettreAction() {
  const action = document.getElementById('comp-bulk-action')?.value;
  if (!action) {
    alert('Choisissez une action.');
    return;
  }

  const checked = document.querySelectorAll('.comp-check:checked');
  if (checked.length === 0) {
    alert('Sélectionnez au moins un élément.');
    return;
  }

  // Confirmation pour suppression
  if (action === 'supprimer') {
    if (!confirm(`Supprimer ${checked.length} élément(s) ? Cette action est irréversible.`))
      return;
  }

  // Construit les ids cachés
  const container = document.getElementById('comp-bulk-ids');
  container.innerHTML = '';
  checked.forEach(cb => {
    const input = document.createElement('input');
    input.type = 'hidden';
    input.name = 'ids[]';
    input.value = cb.dataset.id;
    container.appendChild(input);
  });

  document.getElementById('comp-bulk-action-hidden').value = action;
  document.getElementById('comp-bulk-form').submit();
}

// ============================================================
// RAFRAÎCHISSEMENT LISTE (appelé par apresModification)
// ============================================================

function rafraichirListe() {
  window.location.reload();
}

// ============================================================
// SOUMISSION FORMULAIRE SORT (appelé depuis modifier/sort.php)
// ============================================================

function soumettreSort() {
  const form = document.getElementById('form-sort');
  if (!form) return;

  // Récupère le contenu TinyMCE explicitement avant de construire FormData
  // (triggerSave seul peut manquer de temps pour synchroniser)
  if (typeof tinymce !== 'undefined') {
    const editor = tinymce.get('so_description');
    if (editor) {
      document.getElementById('so_description').value = editor.getContent();
    }
  }

  // FormData directement — pas de conversion URLSearchParams
  // qui corromprait le HTML (<, >, & encodés différemment)
  const formData = new FormData(form);

  fetch(form.getAttribute('action'), {
    method: 'POST',
    body: formData,
    // Pas de Content-Type manuel — le navigateur gère multipart + boundary
  })
    .then(r => r.json())
    .then(data => {
      if (data.ok) {
        apresModification(data);
      } else {
        alert(data.erreur || "Erreur lors de l'enregistrement.");
      }
    })
    .catch(err => alert("Erreur : " + err));
}

// ============================================================
// SOUMISSION FORMULAIRE DON (appelé depuis modifier/don.php)
// ============================================================

function soumettreDon() {
  const form = document.getElementById('form-don');
  if (!form) return;

  if (typeof tinymce !== 'undefined') {
    const editor = tinymce.get('do_texte');
    if (editor) document.getElementById('do_texte').value = editor.getContent();
  }

  fetch(form.getAttribute('action'), {
    method: 'POST',
    body: new FormData(form),
  })
    .then(r => r.json())
    .then(data => {
      if (data.ok) {
        apresModification(data);
      } else {
        alert(data.erreur || "Erreur lors de l'enregistrement.");
      }
    })
    .catch(err => alert('Erreur : ' + err));
}

// ============================================================
// SOUMISSION FORMULAIRE COMPÉTENCE (appelé depuis modifier/competence.php)
// ============================================================

function soumettreCompetence() {
  const form = document.getElementById('form-competence');
  if (!form) return;

  if (typeof tinymce !== 'undefined') {
    const editor = tinymce.get('comp_description');
    if (editor) document.getElementById('comp_description').value = editor.getContent();
  }

  fetch(form.getAttribute('action'), {
    method: 'POST',
    body: new FormData(form),
  })
    .then(r => r.json())
    .then(data => {
      if (data.ok) {
        apresModification(data);
      } else {
        alert(data.erreur || "Erreur lors de l'enregistrement.");
      }
    })
    .catch(err => alert('Erreur : ' + err));
}

// ============================================================
// OBJET MAGIQUE — Affichage conditionnel des sections
// Appelé au changement de catégorie ou de format
// Dépend de OM_CAT_CALCULE (map injecté par modifier/objet.php)
// ============================================================

function omToggleSections(source) {
  // source = 'categorie' quand appelé depuis onchange du select catégorie
  //        = undefined   quand appelé depuis onchange du select format
  //                       ou à l'initialisation du formulaire
  const selCat = document.getElementById('om_com_id');
  const selFom = document.getElementById('om_fom_id');
  if (!selCat) return; // page sans formulaire objet

  const comId = parseInt(selCat.value, 10) || 0;
  const estCalcule = (typeof OM_CAT_CALCULE !== 'undefined') && !!OM_CAT_CALCULE[comId];

  // Quand l'utilisateur change de catégorie, repositionner le select format
  // sur la valeur par défaut de la nouvelle catégorie (com_est_calcule).
  // Quand il change le format lui-même, ou à l'init, on respecte la valeur actuelle.
  if (source === 'categorie' && selFom) {
    selFom.value = estCalcule ? '1' : '2';
  }

  const fomId = selFom ? parseInt(selFom.value, 10) : 2;
  const modeAuto = estCalcule && fomId === 1;

  // Groupes liés au format auto
  const grpSort = document.getElementById('grp-sort-lie');
  const grpNls = document.getElementById('grp-nls');
  const grpMod = document.getElementById('grp-modificateurs');
  const secDesc = document.getElementById('section-description');

  // Catégories avec sort lié (baguettes=4, parchemins=14, potions=15)
  // L'info vient du serveur via OM_CAT_CALCULE ; on distingue armes/armures
  // (modificateurs, pas de sort) des autres catégories calculées.
  const CATS_AVEC_SORT = [4, 14, 15]; // IDs stables DD3.5
  const avecSort = modeAuto && CATS_AVEC_SORT.includes(comId);
  const avecMod = modeAuto && (comId === 2 || comId === 3);

  if (grpSort) grpSort.style.display = avecSort ? '' : 'none';
  if (grpNls) grpNls.style.display = avecSort ? '' : 'none';
  if (grpMod) grpMod.style.display = avecMod ? '' : 'none';

  // Description : visible si format libre — préservée en base même en mode auto
  if (secDesc) secDesc.style.display = modeAuto ? 'none' : '';
}

// ============================================================
// OBJET MAGIQUE — Autocomplétion du champ "sort lié"
// Initialisée par modifier/objet.php après injection du HTML
// ============================================================

function initSortAutocomplete() {
  const input = document.getElementById('om_so_search');
  const hidden = document.getElementById('om_so_id');
  const list = document.getElementById('om_so_list');
  const clearBtn = document.getElementById('om_so_clear');

  if (!input || !hidden || !list) return;

  const rulesetId = (typeof OM_RULESET_ID !== 'undefined') ? OM_RULESET_ID : 1;
  const resIds = document.getElementById('om_active_res_ids')?.value ?? '';

  let debounceTimer = null;
  let activeIndex = -1;

  // ---- Fetch ----

  function fetchSuggestions(q) {
    const params = new URLSearchParams({ q, ruleset: rulesetId, res_ids: resIds });
    fetch(BASE_URL + '/include/ajax/autocomplete-sorts.php?' + params.toString())
      .then(function (r) { return r.json(); })
      .then(function (data) { renderList(data, q); })
      .catch(function () { closeList(); });
  }

  // ---- Rendu ----

  function renderList(items, q) {
    list.innerHTML = '';
    activeIndex = -1;

    if (items.length === 0) {
      const li = document.createElement('li');
      li.className = 'autocomplete-empty';
      li.textContent = 'Aucun sort trouvé';
      list.appendChild(li);
      list.hidden = false;
      return;
    }

    items.forEach(function (item, i) {
      const li = document.createElement('li');
      li.className = 'autocomplete-item';
      li.dataset.id = item.id;
      li.dataset.label = item.label;
      li.innerHTML = highlightMatch(item.label, q);
      li.addEventListener('mousedown', function (e) {
        e.preventDefault(); // évite blur avant click
        selectItem(item.id, item.label);
      });
      list.appendChild(li);
    });

    list.hidden = false;
  }

  function highlightMatch(label, q) {
    if (!q) return escHtml(label);
    const escaped = q.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
    return escHtml(label).replace(
      new RegExp('(' + escaped.replace(/[.*+?^${}()|[\]\\]/g, '\\$&') + ')', 'gi'),
      '<em>$1</em>'
    );
  }

  function escHtml(str) {
    const d = document.createElement('div');
    d.textContent = str;
    return d.innerHTML;
  }

  // ---- Sélection ----

  function selectItem(id, label) {
    hidden.value = id;
    input.value = label;
    if (clearBtn) clearBtn.classList.remove('noDisplay');
    closeList();
  }

  function closeList() {
    list.hidden = true;
    list.innerHTML = '';
    activeIndex = -1;
  }

  function updateActive(newIndex) {
    const items = list.querySelectorAll('.autocomplete-item');
    items.forEach(function (el, i) {
      el.classList.toggle('is-active', i === newIndex);
    });
    activeIndex = newIndex;
  }

  // ---- Événements ----

  input.addEventListener('input', function () {
    const q = input.value.trim();
    hidden.value = 0; // invalider la sélection en cours
    if (clearBtn && !q) clearBtn.classList.add('noDisplay');
    clearTimeout(debounceTimer);
    if (q.length < 2) { closeList(); return; }
    debounceTimer = setTimeout(function () { fetchSuggestions(q); }, 250);
  });

  input.addEventListener('keydown', function (e) {
    const items = list.querySelectorAll('.autocomplete-item');
    if (e.key === 'ArrowDown') {
      e.preventDefault();
      updateActive(Math.min(activeIndex + 1, items.length - 1));
    } else if (e.key === 'ArrowUp') {
      e.preventDefault();
      updateActive(Math.max(activeIndex - 1, 0));
    } else if (e.key === 'Enter' && activeIndex >= 0) {
      e.preventDefault();
      const el = items[activeIndex];
      if (el) selectItem(el.dataset.id, el.dataset.label);
    } else if (e.key === 'Escape') {
      closeList();
    }
  });

  // Fermeture au clic extérieur
  document.addEventListener('click', function (e) {
    const wrap = input.closest('.autocomplete-wrap');
    if (wrap && !wrap.contains(e.target)) closeList();
  });

  // Bouton d'effacement
  if (clearBtn) {
    clearBtn.addEventListener('click', function () {
      hidden.value = 0;
      input.value = '';
      clearBtn.classList.add('noDisplay');
      closeList();
    });
  }
}

// ============================================================
// SOUMISSION FORMULAIRE OBJET MAGIQUE
// ============================================================

function soumettreObjet() {
  const form = document.getElementById('form-objet');
  if (!form) return;

  if (typeof tinymce !== 'undefined') {
    const editor = tinymce.get('om_description');
    if (editor) document.getElementById('om_description').value = editor.getContent();
  }

  fetch(form.getAttribute('action'), {
    method: 'POST',
    body: new FormData(form),
  })
    .then(function (r) { return r.json(); })
    .then(function (data) {
      if (data.ok) {
        apresModification(data);
      } else {
        alert(data.erreur || "Erreur lors de l'enregistrement.");
      }
    })
    .catch(function (err) { alert('Erreur : ' + err); });
}

// ============================================================
// MONSTRE — soumission du formulaire (texte brut, pas de TinyMCE)
// ============================================================
function soumettreMonstre() {
  const form = document.getElementById('form-monstre');
  if (!form) return;

  fetch(form.getAttribute('action'), {
    method: 'POST',
    body: new FormData(form),
  })
    .then(r => r.json())
    .then(data => {
      if (data.ok) {
        apresModification(data);
      } else {
        alert(data.erreur || "Erreur lors de l'enregistrement.");
      }
    })
    .catch(err => alert('Erreur : ' + err));
}

// ============================================================
// MONSTRE — liens cliquables du bloc de stats (.mo-lien)
// Le span ne porte que data-type / data-id ; l'URL de l'endpoint
// detail-pp est résolue ici, et la base est lue sur le conteneur
// (.mo-stats[data-detail-base]) -> aucune dépendance à un BASE_URL global.
// Délégation : un seul écouteur pour tous les monstres affichés.
// ============================================================
var MO_LIEN_FICHIERS = {
  don: 'don.php',
  competence: 'competence.php',
  sort: 'sort.php',
  objet: 'objet.php',
  capacite: 'capacite.php',
  race: 'race.php',
  classe: 'classe.php',
  regle: 'regle',
  glossaire: 'glossaire',
};

document.addEventListener('click', function (e) {
  const lien = e.target.closest('.mo-lien');
  if (!lien) return;
  const type = lien.dataset.type;
  const id   = parseInt(lien.dataset.id, 10);
  if (!id) return;

  // Reconstruire BASE_URL depuis data-detail-base
  // data-detail-base = "http://localhost/donjon/include/ajax/detail-pp/"
  const cont       = lien.closest('[data-detail-base]');
  const detailBase = cont ? cont.dataset.detailBase : '';
  // Retirer "/include/ajax/detail-pp/" pour obtenir la racine
  const appBase    = detailBase.replace(/\/include\/ajax\/detail-pp\/$/, '');

  // Regle : nouvelle page
  if (type === 'regle') {
    window.open(appBase + '/regles/regle.php?id=' + id, '_blank');
    return;
  }
  // Glossaire : sub-panel
  if (type === 'glossaire') {
    if (typeof actualiserPageSub === 'function') {
      actualiserPageSub(appBase + '/include/ajax/detail-pp-sub/glossaire.php', { id: id });
    }
    return;
  }
  // Autres types compendium : sub-panel standard
  const fichier = MO_LIEN_FICHIERS[type];
  if (!fichier) return;
  if (typeof actualiserPageSub === 'function') {
    actualiserPageSub(detailBase + fichier, { id: id });
  }
});
