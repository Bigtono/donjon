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
  'ra_id'            => 0,
  'ra_nom'           => '',
  'ra_rat_id'        => 0,
  'ra_description'   => '',
  'ra_mod_niveau'    => 0,
  'ra_res_id'        => 0,
  'ra_camp_id'       => 0,
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

// Types de race du ruleset courant
$stmt_rat = $db->prepare('
  SELECT rat_id, rat_nom
  FROM   dd_race_type
  WHERE  rat_ruleset_var_id = ?
  ORDER  BY rat_nom
');
$stmt_rat->execute([$ruleset_id]);
$types_race = $stmt_rat->fetchAll();

// Sources actives
$sources = [];
if (!empty($res_ids)):
  $ph   = resIdsPlaceholders($res_ids);
  $stmt = $db->prepare("SELECT res_id, res_nom FROM dd_ressources WHERE res_id IN ($ph) ORDER BY res_nom");
  $stmt->execute($res_ids);
  $sources = $stmt->fetchAll();
endif;

// Campagnes de l'utilisateur (homebrew)
$campagnes = [];
if (!empty($_SESSION['j_mode_campagne'])):
  [$owWhere, $owParams] = ownerFilter('camp');
  $stmt = $db->prepare("SELECT camp_id, camp_nom FROM dd_campagnes WHERE $owWhere ORDER BY camp_nom");
  $stmt->execute($owParams);
  $campagnes = $stmt->fetchAll();
endif;

$titre = $id > 0 ? 'Modifier ' . h($ra['ra_nom']) : 'Nouvelle race';

// Sérialisation des capacités pour le JS (état initial)
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
    <input type="hidden" name="entite"           value="race">
    <input type="hidden" name="action"           value="sauvegarder">
    <input type="hidden" name="ra_id"            value="<?= (int)$ra['ra_id'] ?>">
    <input type="hidden" name="ra_ruleset_var_id" value="<?= $ruleset_id ?>">
    <input type="hidden" id="capacites_payload"  name="capacites_payload" value="[]">

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
      <div class="modif-section__header" style="display:flex; justify-content:space-between; align-items:center;">
        <span class="modif-section__label">Section 3 — Capacités raciales</span>
        <?php if ($id > 0): ?>
          <button type="button" class="btn btn-secondary btn-sm"
                  onclick="raceNouvelleCapacite()">
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
                <th style="width:30px;"></th><!-- drag handle -->
                <th>Nom</th>
                <?php if ($ruleset === 'DD3.5'): ?>
                  <th style="width:80px;">Type</th>
                <?php endif ?>
                <th>Description</th>
                <th style="width:80px;">Actions</th>
              </tr>
            </thead>
            <tbody id="race-cap-tbody">
              <!-- Rendu par JS depuis capacitesState -->
            </tbody>
          </table>
        </div>
      <?php endif ?>
    </div>

    <!-- ====================================================
         BOUTONS
         ==================================================== -->
    <div class="modif-actions">
      <button type="button" class="btn btn-primary" onclick="soumettreRace()">
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
<div id="race-cap-overlay" style="display:none; position:fixed; inset:0; background:rgba(0,0,0,.45); z-index:1100;">
  <div style="max-width:600px; margin:60px auto; background:#fff; border-radius:6px; padding:20px; max-height:calc(100vh - 120px); overflow:auto;">
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
      <textarea id="ov_cap_description" class="tinymce-basic" rows="6" style="width:100%;"></textarea>
    </div>

    <div style="display:flex; gap:.5rem; margin-top:1rem;">
      <button type="button" class="btn btn-primary" onclick="raceValiderCapacite()">
        <i class="fa fa-check"></i> Valider
      </button>
      <button type="button" class="btn btn-secondary" onclick="raceFermerOverlay()">
        Annuler
      </button>
    </div>
  </div>
</div>

<!-- TinyMCE -->
<script src="https://cdn.jsdelivr.net/npm/tinymce@6/tinymce.min.js"></script>
<script>
(function initTMCE() {
  if (typeof tinymce === 'undefined') { setTimeout(initTMCE, 100); return; }
  ['ra_description', 'ov_cap_description'].forEach(function(sel) {
    tinymce.remove('#' + sel);
  });
  tinymce.init({
    selector:    '#ra_description',
    language:    'fr_FR',
    menubar:     false,
    plugins:     'lists link',
    toolbar:     'bold italic underline | bullist numlist | h2 h3 | link | removeformat',
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
// État des capacités raciales
// ============================================================

const RULESET = <?= json_encode($ruleset) ?>;
const RACE_ID = <?= $id ?>;

// Tableau d'état courant — chaque item : { action, cap_id, cap_nom, cap_description, cap_type, cr_ordre }
let capacitesState = <?= json_encode($capacites_init) ?>;

// Index de l'item en cours d'édition dans l'overlay (-1 = nouvelle)
let overlayEditIndex = -1;

// ============================================================
// Rendu du tableau des capacités
// ============================================================

function raceRendreTableau() {
  const tbody = document.getElementById('race-cap-tbody');
  if (!tbody) return;

  tbody.innerHTML = '';

  capacitesState
    .filter(c => c.action !== 'delete')
    .forEach(function(cap, idx) {
      const realIdx = capacitesState.indexOf(cap);
      const tr = document.createElement('tr');
      tr.dataset.index = realIdx;
      tr.draggable = true;

      let typeCell = '';
      if (RULESET === 'DD3.5') {
        typeCell = '<td>' + escHtml(cap.cap_type || '') + '</td>';
      }

      tr.innerHTML =
        '<td class="drag-handle" style="cursor:grab; text-align:center; color:#999;">&#9776;</td>' +
        '<td>' + escHtml(cap.cap_nom) + '</td>' +
        typeCell +
        '<td><em style="color:#888; font-size:.85em;">' +
          (cap.cap_description ? '(contenu)' : '—') +
        '</em></td>' +
        '<td style="white-space:nowrap;">' +
          '<button type="button" class="btn btn-sm" onclick="raceEditerCapacite(' + realIdx + ')" title="Modifier">' +
            '<i class="fa fa-pencil"></i>' +
          '</button> ' +
          '<button type="button" class="btn btn-sm btn-danger" onclick="raceSupprimerCapacite(' + realIdx + ')" title="Supprimer">' +
            '<i class="fa fa-trash"></i>' +
          '</button>' +
        '</td>';

      tbody.appendChild(tr);
    });

  raceInitDragDrop();
}

function escHtml(str) {
  return String(str)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');
}

// ============================================================
// Drag & drop (natif HTML5)
// ============================================================

let dragSrcIndex = null;

function raceInitDragDrop() {
  const rows = document.querySelectorAll('#race-cap-tbody tr');

  rows.forEach(function(row) {
    row.addEventListener('dragstart', function(e) {
      dragSrcIndex = parseInt(row.dataset.index, 10);
      e.dataTransfer.effectAllowed = 'move';
      row.style.opacity = '.4';
    });

    row.addEventListener('dragend', function() {
      row.style.opacity = '';
    });

    row.addEventListener('dragover', function(e) {
      e.preventDefault();
      e.dataTransfer.dropEffect = 'move';
      return false;
    });

    row.addEventListener('drop', function(e) {
      e.preventDefault();
      const dropIndex = parseInt(row.dataset.index, 10);
      if (dragSrcIndex === null || dragSrcIndex === dropIndex) return;

      // Déplacer l'item dans capacitesState
      const moved = capacitesState.splice(dragSrcIndex, 1)[0];
      const newPos = dragSrcIndex < dropIndex ? dropIndex : dropIndex;
      capacitesState.splice(newPos, 0, moved);

      dragSrcIndex = null;
      raceRendreTableau();
    });
  });
}

// ============================================================
// Overlay — Nouvelle / Modifier capacité
// ============================================================

function raceNouvelleCapacite() {
  overlayEditIndex = -1;
  document.getElementById('race-cap-overlay-titre').textContent = 'Nouvelle capacité raciale';
  document.getElementById('ov_cap_nom').value = '';
  const typeEl = document.getElementById('ov_cap_type');
  if (typeEl) typeEl.value = '';

  // Réinitialise TinyMCE de l'overlay
  const ed = tinymce.get('ov_cap_description');
  if (ed) {
    ed.setContent('');
  } else {
    document.getElementById('ov_cap_description').value = '';
    tinymce.init({
      selector:    '#ov_cap_description',
      language:    'fr_FR',
      menubar:     false,
      plugins:     'lists link',
      toolbar:     'bold italic underline | bullist numlist | link | removeformat',
      height:      220,
      skin:        'oxide-dark',
      content_css: 'dark',
      promotion:   false,
      branding:    false,
      base_url:    'https://cdn.jsdelivr.net/npm/tinymce@6',
      suffix:      '.min',
    });
  }

  document.getElementById('race-cap-overlay').style.display = 'block';
  document.getElementById('ov_cap_nom').focus();
}

function raceEditerCapacite(idx) {
  overlayEditIndex = idx;
  const cap = capacitesState[idx];
  document.getElementById('race-cap-overlay-titre').textContent = 'Modifier la capacité';
  document.getElementById('ov_cap_nom').value = cap.cap_nom;
  const typeEl = document.getElementById('ov_cap_type');
  if (typeEl) typeEl.value = cap.cap_type || '';

  const ed = tinymce.get('ov_cap_description');
  if (ed) {
    ed.setContent(cap.cap_description || '');
  } else {
    document.getElementById('ov_cap_description').value = cap.cap_description || '';
    tinymce.init({
      selector:    '#ov_cap_description',
      language:    'fr_FR',
      menubar:     false,
      plugins:     'lists link',
      toolbar:     'bold italic underline | bullist numlist | link | removeformat',
      height:      220,
      skin:        'oxide-dark',
      content_css: 'dark',
      promotion:   false,
      branding:    false,
      base_url:    'https://cdn.jsdelivr.net/npm/tinymce@6',
      suffix:      '.min',
    });
  }

  document.getElementById('race-cap-overlay').style.display = 'block';
  document.getElementById('ov_cap_nom').focus();
}

function raceFermerOverlay() {
  document.getElementById('race-cap-overlay').style.display = 'none';
}

function raceValiderCapacite() {
  const nom = document.getElementById('ov_cap_nom').value.trim();
  if (!nom) {
    alert('Le nom de la capacité est obligatoire.');
    return;
  }

  // Récupérer le contenu TinyMCE de l'overlay
  let desc = '';
  const ed = tinymce.get('ov_cap_description');
  if (ed) {
    desc = ed.getContent();
  } else {
    desc = document.getElementById('ov_cap_description').value;
  }

  const typeEl = document.getElementById('ov_cap_type');
  const type   = typeEl ? typeEl.value.trim() : '';

  if (overlayEditIndex === -1) {
    // Nouvelle capacité
    capacitesState.push({
      action:          'new',
      cap_id:          null,
      cap_nom:         nom,
      cap_description: desc,
      cap_type:        type,
      cr_ordre:        capacitesState.length,
    });
  } else {
    // Modification d'une existante
    const cap = capacitesState[overlayEditIndex];
    cap.cap_nom         = nom;
    cap.cap_description = desc;
    cap.cap_type        = type;
    // Si c'était 'existing', on passe à 'existing' (l'ordre et le contenu sont à jour)
    // Si c'était 'new', reste 'new'
  }

  raceFermerOverlay();
  raceRendreTableau();
}

function raceSupprimerCapacite(idx) {
  const cap = capacitesState[idx];
  if (!confirm('Supprimer la capacité "' + cap.cap_nom + '" de cette race ?')) return;

  if (cap.action === 'new') {
    // Pas encore en base — on retire simplement du tableau
    capacitesState.splice(idx, 1);
  } else {
    // En base — on marque pour suppression
    cap.action = 'delete';
  }

  raceRendreTableau();
}

// ============================================================
// Soumission du formulaire
// ============================================================

function soumettreRace() {
  const form = document.getElementById('form-race');
  if (!form) return;

  // Synchroniser TinyMCE description principale
  if (typeof tinymce !== 'undefined') {
    const ed = tinymce.get('ra_description');
    if (ed) document.getElementById('ra_description').value = ed.getContent();
  }

  // Mettre à jour cr_ordre depuis l'ordre actuel du tableau DOM
  // (les lignes delete sont absentes du DOM mais présentes dans capacitesState)
  let ordre = 0;
  document.querySelectorAll('#race-cap-tbody tr').forEach(function(row) {
    const idx = parseInt(row.dataset.index, 10);
    if (!isNaN(idx) && capacitesState[idx]) {
      capacitesState[idx].cr_ordre = ordre++;
    }
  });

  // Sérialiser le payload
  document.getElementById('capacites_payload').value = JSON.stringify(capacitesState);

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
// Initialisation
// ============================================================
// Le formulaire est injecté via innerHTML (actualiserPageModif dans main.js).
// DOMContentLoaded ne se redéclenche pas — appel direct.
// Le DOM est déjà présent quand ce script s'exécute.

if (RACE_ID > 0) raceRendreTableau();
</script>
