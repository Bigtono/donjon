<?php
// include/ajax/modifier/race.php
// Retourne le HTML du formulaire de création/modification d'une race
// Appelé via ouvrirModifier() — pas de layout header/footer
//
// Paramètres GET :
//   id (int) — ra_id de la race à modifier (0 = création)

require_once __DIR__ . '/../../db.php';
require_once __DIR__ . '/../../auth.php';
require_once __DIR__ . '/../../helpers.php';

requireAuth();
if (!canEditCompendium()):
  http_response_code(403);
  echo '<p class="erreur">Accès refusé.</p>';
  exit;
endif;

$id         = intParam($_GET['id'] ?? 0);
$ruleset    = $_SESSION['rulesetRep'] ?? 'DD3.5';
$ruleset_id = (int)($_SESSION['ruleset_var_id'] ?? 1);
$res_ids    = getActiveResIds($db);

// ============================================================
// Chargement de la race existante ou valeurs vides (création)
// ============================================================

$ra = [
  'ra_id'          => 0,
  'ra_nom'         => '',
  'ra_rat_id'      => 0,
  'ra_description' => '',
  'ra_mod_niveau'  => 0,
  'ra_res_id'      => 0,
  'ra_camp_id'     => 0,
];

if ($id > 0):
  $stmt = $db->prepare('SELECT * FROM dd_races WHERE ra_id = ?');
  $stmt->execute([$id]);
  $row = $stmt->fetch();
  if ($row) $ra = $row;
endif;

// ============================================================
// Capacités raciales existantes (section 3)
// ============================================================

$capacites = [];
if ($id > 0):
  $stmt_cap = $db->prepare('
    SELECT cr.cr_cap_id, cr.cr_ordre,
           cap.cap_nom, cap.cap_description, cap.cap_type
    FROM   dd_race_capacite cr
    JOIN   dd_capacites_speciales cap ON cap.cap_id = cr.cr_cap_id
    WHERE  cr.cr_ra_id = ?
    ORDER  BY cr.cr_ordre ASC, cap.cap_nom ASC
  ');
  $stmt_cap->execute([$id]);
  $capacites = $stmt_cap->fetchAll();
endif;

// ============================================================
// Listes de référence
// ============================================================

$stmt_rat = $db->prepare('
  SELECT rat_id, rat_nom
  FROM   dd_race_type
  WHERE  rat_ruleset_var_id = ?
  ORDER  BY rat_nom
');
$stmt_rat->execute([$ruleset_id]);
$types_race = $stmt_rat->fetchAll();

$sources = [];
if (!empty($res_ids)):
  $ph   = resIdsPlaceholders($res_ids);
  $stmt = $db->prepare("SELECT res_id, res_nom FROM dd_ressources WHERE res_id IN ($ph) ORDER BY res_nom");
  $stmt->execute($res_ids);
  $sources = $stmt->fetchAll();
endif;

$campagnes = [];
if (!empty($_SESSION['j_mode_campagne'])):
  [$owWhere, $owParams] = ownerFilter('camp');
  $stmt = $db->prepare("SELECT camp_id, camp_nom FROM dd_campagnes WHERE $owWhere ORDER BY camp_nom");
  $stmt->execute($owParams);
  $campagnes = $stmt->fetchAll();
endif;

$titre = $id > 0 ? 'Modifier ' . h($ra['ra_nom']) : 'Nouvelle race';

// État initial des capacités sérialisé pour le JS
$capacites_init = [];
foreach ($capacites as $cap):
  $capacites_init[] = [
    'action'          => 'existing',
    'cap_id'          => (int)$cap['cr_cap_id'],
    'cap_nom'         => $cap['cap_nom'],
    'cap_description' => $cap['cap_description'] ?? '',
    'cap_type'        => $cap['cap_type'] ?? '',
    'cr_ordre'        => (int)$cap['cr_ordre'],
  ];
endforeach;
?>

<div class="modif-form">
  <h3 class="modif-form__title"><?= $titre ?></h3>

  <form id="form-race" method="POST" action="<?= BASE_URL ?>/compendium/enregistrement.php?ajax=1">
    <?= csrfField() ?>
    <input type="hidden" name="entite"            value="race">
    <input type="hidden" name="action"            value="sauvegarder">
    <input type="hidden" name="ra_id"             value="<?= (int)$ra['ra_id'] ?>">
    <input type="hidden" name="ra_ruleset_var_id" value="<?= $ruleset_id ?>">
    <input type="hidden" id="capacites_payload"   name="capacites_payload" value="[]">

    <!-- ====================================================
         SECTION 1 — Données de base
         ==================================================== -->
    <div class="modif-section">
      <div class="modif-section__header">
        <span class="modif-section__label">Section 1 — Données de base</span>
      </div>

      <div class="modif-grid">

        <div class="form-group modif-grid__full">
          <label for="ra_nom">Nom <span class="required">*</span></label>
          <input type="text" id="ra_nom" name="ra_nom"
                 value="<?= h($ra['ra_nom']) ?>" required maxlength="100">
        </div>

        <div class="form-group">
          <label for="ra_rat_id">Type de race <span class="required">*</span></label>
          <select id="ra_rat_id" name="ra_rat_id" required>
            <option value="">— Choisir —</option>
            <?php foreach ($types_race as $rat): ?>
              <option value="<?= (int)$rat['rat_id'] ?>"
                <?= (int)$ra['ra_rat_id'] === (int)$rat['rat_id'] ? 'selected' : '' ?>>
                <?= h($rat['rat_nom']) ?>
              </option>
            <?php endforeach ?>
          </select>
        </div>

        <div class="form-group">
          <label for="ra_res_id">Source <span class="required">*</span></label>
          <select id="ra_res_id" name="ra_res_id" required>
            <option value="">— Choisir —</option>
            <?php foreach ($sources as $src): ?>
              <option value="<?= (int)$src['res_id'] ?>"
                <?= (int)$ra['ra_res_id'] === (int)$src['res_id'] ? 'selected' : '' ?>>
                <?= h($src['res_nom']) ?>
              </option>
            <?php endforeach ?>
          </select>
        </div>

        <?php if (!empty($campagnes)): ?>
          <div class="form-group">
            <label for="ra_camp_id">Campagne (homebrew)</label>
            <select id="ra_camp_id" name="ra_camp_id">
              <option value="">— Compendium global —</option>
              <?php foreach ($campagnes as $camp): ?>
                <option value="<?= (int)$camp['camp_id'] ?>"
                  <?= (int)$ra['ra_camp_id'] === (int)$camp['camp_id'] ? 'selected' : '' ?>>
                  <?= h($camp['camp_nom']) ?>
                </option>
              <?php endforeach ?>
            </select>
          </div>
        <?php endif ?>

      </div><!-- .modif-grid -->

      <div class="form-group">
        <label for="ra_description">Description</label>
        <textarea id="ra_description" name="ra_description"
                  class="tinymce-basic"><?= $ra['ra_description'] ?? '' ?></textarea>
      </div>

    </div><!-- .modif-section -->

    <!-- ====================================================
         SECTION 2 — Données DD3.5 uniquement
         ==================================================== -->
    <?php if ($ruleset === 'DD3.5'): ?>
    <div class="modif-section">
      <div class="modif-section__header">
        <span class="modif-section__label">Section 2 — DD3.5</span>
      </div>
      <div class="modif-grid">
        <div class="form-group">
          <label for="ra_mod_niveau">Modificateur de niveau global</label>
          <input type="number" id="ra_mod_niveau" name="ra_mod_niveau"
                 value="<?= (int)$ra['ra_mod_niveau'] ?>" min="0" step="1" style="width:80px;">
        </div>
      </div>
    </div>
    <?php endif ?>

    <!-- ====================================================
         SECTION 3 — Capacités raciales
         ==================================================== -->
    <div class="modif-section">
      <div class="modif-section__header"
           style="display:flex; justify-content:space-between; align-items:center;">
        <span class="modif-section__label">Section 3 — Capacités raciales</span>
        <?php if ($id > 0): ?>
          <button type="button" class="btn btn-secondary btn-sm"
                  onclick="raceForm.nouvelleCapacite()">
            <i class="fa fa-plus"></i> Nouvelle capacité
          </button>
        <?php endif ?>
      </div>

      <?php if ($id === 0): ?>
        <p class="form-hint" style="margin:.5rem 0;">
          Enregistrez d'abord la race (Section 1) avant d'ajouter des capacités raciales.
        </p>
      <?php else: ?>
        <div class="table-scroll">
          <table class="table-classe-modif" id="race-cap-table">
            <thead>
              <tr>
                <th style="width:30px;"></th>
                <th>Nom</th>
                <?php if ($ruleset === 'DD3.5'): ?>
                  <th style="width:80px;">Type</th>
                <?php endif ?>
                <th>Description</th>
                <th style="width:80px;">Actions</th>
              </tr>
            </thead>
            <tbody id="race-cap-tbody"></tbody>
          </table>
        </div>
      <?php endif ?>
    </div>

    <!-- ====================================================
         BOUTONS
         ==================================================== -->
    <div class="modif-actions">
      <button type="button" class="btn btn-primary" onclick="raceForm.soumettre()">
        <i class="fa fa-save"></i> Enregistrer
      </button>
      <button type="button" class="btn btn-secondary" onclick="fermerModification()">
        <i class="fa fa-times"></i> Annuler
      </button>
    </div>

  </form>
</div>

<!-- ====================================================
     OVERLAY — Formulaire capacité (nouvelle / modifier)
     ==================================================== -->
<div id="race-cap-overlay"
     style="display:none; position:fixed; inset:0; background:rgba(0,0,0,.45); z-index:1100;">
  <div style="max-width:600px; margin:60px auto; background:#fff; border-radius:6px;
              padding:20px; max-height:calc(100vh - 120px); overflow:auto;">
    <h4 id="race-cap-overlay-titre" style="margin-top:0;">Capacité raciale</h4>

    <div class="form-group">
      <label for="ov_cap_nom">Nom <span class="required">*</span></label>
      <input type="text" id="ov_cap_nom" maxlength="150" style="width:100%;">
    </div>

    <?php if ($ruleset === 'DD3.5'): ?>
    <div class="form-group">
      <label for="ov_cap_type">Type</label>
      <input type="text" id="ov_cap_type" maxlength="50" placeholder="Ex : Ext, Mag, Sur"
             style="width:160px;">
    </div>
    <?php else: ?>
    <input type="hidden" id="ov_cap_type" value="">
    <?php endif ?>

    <div class="form-group">
      <label for="ov_cap_description">Description</label>
      <textarea id="ov_cap_description" rows="6" style="width:100%;"></textarea>
    </div>

    <div style="display:flex; gap:.5rem; margin-top:1rem;">
      <button type="button" class="btn btn-primary" onclick="raceForm.validerCapacite()">
        <i class="fa fa-check"></i> Valider
      </button>
      <button type="button" class="btn btn-secondary" onclick="raceForm.fermerOverlay()">
        Annuler
      </button>
    </div>
  </div>
</div>

<!-- TinyMCE -->
<script src="https://cdn.jsdelivr.net/npm/tinymce@6/tinymce.min.js"></script>
<script>
// ============================================================
// IIFE — isolation complète du scope
//
// Bug corrigé : sans IIFE, les déclarations let/const/function
// restaient dans le scope global de la page. À la 2ème ouverture
// du formulaire (via innerHTML), les redéclarations échouaient
// silencieusement et capacitesState conservait l'état de la
// session précédente (vide ou données d'une autre race).
//
// Solution : tout le code est isolé dans une IIFE. L'objet
// raceForm est exposé sur window pour que les onclick="" HTML
// puissent l'atteindre — il est réécrit à chaque ouverture.
// ============================================================
(function() {
  'use strict';

  // ---- Constantes PHP → JS ----
  const RULESET = <?= json_encode($ruleset) ?>;
  const RACE_ID = <?= $id ?>;

  // ---- État des capacités raciales ----
  // action possible : 'existing' | 'new' | 'update' | 'delete'
  let state = <?= json_encode($capacites_init) ?>;
  let overlayIdx = -1;  // index en cours d'édition dans l'overlay (-1 = nouvelle)
  let dragSrc   = null;

  // ============================================================
  // TinyMCE
  // ============================================================

  (function initTMCE() {
    if (typeof tinymce === 'undefined') { setTimeout(initTMCE, 100); return; }
    tinymce.remove('#ra_description');
    tinymce.remove('#ov_cap_description');
    tinymce.init({
      selector:    '#ra_description',
      language:    'fr_FR',
      menubar:     false,
      plugins:     'lists link table',
      toolbar:     'bold italic underline | bullist numlist | h2 h3 | link table | removeformat',
      height:      300,
      skin:        'oxide-dark',
      content_css: 'dark',
      promotion:   false,
      branding:    false,
      base_url:    'https://cdn.jsdelivr.net/npm/tinymce@6',
      suffix:      '.min',
    });
  })();

  // ============================================================
  // Utilitaires
  // ============================================================

  function esc(str) {
    return String(str)
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;');
  }

  function tmceGet(id) {
    if (typeof tinymce !== 'undefined') {
      const ed = tinymce.get(id);
      if (ed) return ed.getContent();
    }
    const el = document.getElementById(id);
    return el ? el.value : '';
  }

  function tmceSet(id, content) {
    if (typeof tinymce !== 'undefined') {
      const ed = tinymce.get(id);
      if (ed) { ed.setContent(content); return; }
    }
    const el = document.getElementById(id);
    if (el) el.value = content;
  }

  // ============================================================
  // Rendu du tableau des capacités
  // ============================================================

  function rendreTableau() {
    const tbody = document.getElementById('race-cap-tbody');
    if (!tbody) return;

    tbody.innerHTML = '';

    state
      .filter(c => c.action !== 'delete')
      .forEach(function(cap) {
        const realIdx = state.indexOf(cap);
        const tr = document.createElement('tr');
        tr.dataset.index = realIdx;
        tr.draggable = true;

        let typeCell = '';
        if (RULESET === 'DD3.5') {
          typeCell = '<td>' + esc(cap.cap_type || '') + '</td>';
        }

        tr.innerHTML =
          '<td class="drag-handle" style="cursor:grab; text-align:center; color:#999;">&#9776;</td>' +
          '<td>' + esc(cap.cap_nom) + '</td>' +
          typeCell +
          '<td><em style="color:#888; font-size:.85em;">' +
            (cap.cap_description ? '(contenu)' : '—') +
          '</em></td>' +
          '<td style="white-space:nowrap;">' +
            '<button type="button" class="btn btn-sm"' +
              ' onclick="raceForm.editerCapacite(' + realIdx + ')" title="Modifier">' +
              '<i class="fa fa-pencil"></i>' +
            '</button> ' +
            '<button type="button" class="btn btn-sm btn-danger"' +
              ' onclick="raceForm.supprimerCapacite(' + realIdx + ')" title="Supprimer">' +
              '<i class="fa fa-trash"></i>' +
            '</button>' +
          '</td>';

        tbody.appendChild(tr);
      });

    initDragDrop();
  }

  // ============================================================
  // Drag & drop (natif HTML5)
  // ============================================================

  function initDragDrop() {
    document.querySelectorAll('#race-cap-tbody tr').forEach(function(row) {
      row.addEventListener('dragstart', function(e) {
        dragSrc = parseInt(row.dataset.index, 10);
        e.dataTransfer.effectAllowed = 'move';
        row.style.opacity = '.4';
      });
      row.addEventListener('dragend', function() {
        row.style.opacity = '';
      });
      row.addEventListener('dragover', function(e) {
        e.preventDefault();
        e.dataTransfer.dropEffect = 'move';
      });
      row.addEventListener('drop', function(e) {
        e.preventDefault();
        const dropIdx = parseInt(row.dataset.index, 10);
        if (dragSrc === null || dragSrc === dropIdx) return;
        const moved = state.splice(dragSrc, 1)[0];
        state.splice(dragSrc < dropIdx ? dropIdx : dropIdx, 0, moved);
        dragSrc = null;
        rendreTableau();
      });
    });
  }

  // ============================================================
  // Overlay — Nouvelle / Modifier capacité
  // ============================================================

  function ouvrirOverlay(titre, nom, type, desc) {
    document.getElementById('race-cap-overlay-titre').textContent = titre;
    document.getElementById('ov_cap_nom').value = nom;
    const typeEl = document.getElementById('ov_cap_type');
    if (typeEl) typeEl.value = type;

    // Stocker la description dans le textarea brut AVANT l'affichage.
    // TinyMCE de l'overlay (s'il existe) sera réinitialisé proprement.
    // On détruit l'instance TinyMCE existante pour repartir proprement
    // à chaque ouverture — évite les décalages entre instances et textarea.
    if (typeof tinymce !== 'undefined') {
      const ed = tinymce.get('ov_cap_description');
      if (ed) ed.destroy();
    }
    const textarea = document.getElementById('ov_cap_description');
    textarea.value = desc;

    document.getElementById('race-cap-overlay').style.display = 'block';

    // Init TinyMCE après affichage de l'overlay (nécessaire pour le calcul dimensions)
    setTimeout(function() {
      tinymce.init({
        selector:    '#ov_cap_description',
        language:    'fr_FR',
        menubar:     false,
        plugins:     'lists link table',
        toolbar:     'bold italic underline | bullist numlist | link table | removeformat',
        height:      220,
        skin:        'oxide-dark',
        content_css: 'dark',
        promotion:   false,
        branding:    false,
        base_url:    'https://cdn.jsdelivr.net/npm/tinymce@6',
        suffix:      '.min',
        setup: function(ed) {
          ed.on('init', function() {
            // Restaurer le contenu depuis le textarea (valeur posée avant init)
            ed.setContent(textarea.value);
          });
        },
      });
      document.getElementById('ov_cap_nom').focus();
    }, 50);
  }

  function nouvelleCapacite() {
    overlayIdx = -1;
    ouvrirOverlay('Nouvelle capacité raciale', '', '', '');
  }

  function editerCapacite(idx) {
    overlayIdx = idx;
    const cap = state[idx];
    ouvrirOverlay('Modifier la capacité', cap.cap_nom, cap.cap_type || '', cap.cap_description || '');
  }

  function fermerOverlay() {
    // Détruire l'instance TinyMCE de l'overlay à la fermeture
    // pour qu'ouvrirOverlay reparte toujours d'une instance propre.
    if (typeof tinymce !== 'undefined') {
      const ed = tinymce.get('ov_cap_description');
      if (ed) ed.destroy();
    }
    document.getElementById('race-cap-overlay').style.display = 'none';
  }

  function validerCapacite() {
    const nom = document.getElementById('ov_cap_nom').value.trim();
    if (!nom) { alert('Le nom de la capacité est obligatoire.'); return; }

    // Récupérer la description depuis TinyMCE si l'instance est prête,
    // sinon depuis le textarea brut (fallback si init encore en cours).
    let desc = '';
    const ed = (typeof tinymce !== 'undefined') ? tinymce.get('ov_cap_description') : null;
    if (ed && ed.initialized) {
      desc = ed.getContent();
    } else {
      desc = document.getElementById('ov_cap_description').value;
    }

    const typeEl = document.getElementById('ov_cap_type');
    const type   = typeEl ? typeEl.value.trim() : '';

    if (overlayIdx === -1) {
      // Nouvelle capacité
      state.push({
        action:          'new',
        cap_id:          null,
        cap_nom:         nom,
        cap_description: desc,
        cap_type:        type,
        cr_ordre:        state.length,
      });
    } else {
      // Modification : on distingue 'existing' → 'update' pour que le PHP
      // mette à jour dd_capacites_speciales, pas seulement cr_ordre.
      const cap = state[overlayIdx];
      cap.cap_nom         = nom;
      cap.cap_description = desc;
      cap.cap_type        = type;
      if (cap.action === 'existing') cap.action = 'update';
      // 'new' reste 'new' — les données seront insérées au submit.
    }

    fermerOverlay();
    rendreTableau();
  }

  function supprimerCapacite(idx) {
    const cap = state[idx];
    if (!confirm('Supprimer la capacité "' + cap.cap_nom + '" de cette race ?')) return;

    if (cap.action === 'new') {
      state.splice(idx, 1);
    } else {
      cap.action = 'delete';
    }
    rendreTableau();
  }

  // ============================================================
  // Soumission du formulaire
  // ============================================================

  function soumettre() {
    const form = document.getElementById('form-race');
    if (!form) return;

    // Synchroniser TinyMCE description principale
    const descEl = document.getElementById('ra_description');
    if (descEl) descEl.value = tmceGet('ra_description');

    // Recalculer cr_ordre depuis l'ordre DOM courant
    let ordre = 0;
    document.querySelectorAll('#race-cap-tbody tr').forEach(function(row) {
      const idx = parseInt(row.dataset.index, 10);
      if (!isNaN(idx) && state[idx]) {
        state[idx].cr_ordre = ordre++;
      }
    });

    document.getElementById('capacites_payload').value = JSON.stringify(state);

    fetch(form.getAttribute('action'), {
      method: 'POST',
      body:   new FormData(form),
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
  // Exposition sur window pour les onclick="" du HTML
  // (seul point de contact entre le scope IIFE et le monde extérieur)
  // ============================================================

  window.raceForm = {
    nouvelleCapacite: nouvelleCapacite,
    editerCapacite:   editerCapacite,
    fermerOverlay:    fermerOverlay,
    validerCapacite:  validerCapacite,
    supprimerCapacite: supprimerCapacite,
    soumettre:        soumettre,
  };

  // ============================================================
  // Initialisation — appel direct (pas de DOMContentLoaded)
  // Le formulaire est injecté via innerHTML : l'événement ne se
  // redéclenche pas. Le DOM est déjà présent à ce stade.
  // ============================================================

  if (RACE_ID > 0) rendreTableau();

})(); // fin IIFE
</script>
