<?php
// include/ajax/modifier/campagne.php
// Formulaire de création / modification d'une campagne.
// Appelé via ouvrirModifier() — pas de layout header/footer.
//
// Paramètres GET :
//   id (int) — camp_id à modifier (0 = création)

require_once __DIR__ . '/../../db.php';
require_once __DIR__ . '/../../auth.php';
require_once __DIR__ . '/../../helpers.php';

requireAuth();

$id   = intParam($_GET['id'] ?? 0);
$j_id = (int)$_SESSION['j_id'];

// ============================================================
// Chargement de la campagne ou valeurs vides (création)
// ============================================================

$camp = [
  'camp_id'             => 0,
  'camp_nom'            => '',
  'camp_resume'         => '',
  'camp_description'    => '',
  'camp_ruleset_var_id' => (int)($_SESSION['ruleset_var_id'] ?? 1),
  'camp_un_id'          => 0,
];

if ($id > 0):
  // Contrôle de propriété avant toute édition.
  if (!isMJ($db, $id)):
    http_response_code(403);
    echo '<p class="erreur">Accès refusé.</p>';
    exit;
  endif;
  $stmt = $db->prepare('SELECT * FROM dd_campagnes WHERE camp_id = ? AND camp_supprime = 0');
  $stmt->execute([$id]);
  $row = $stmt->fetch();
  if (!$row):
    http_response_code(404);
    echo '<p class="erreur">Campagne introuvable.</p>';
    exit;
  endif;
  $camp = $row;
endif;

$ruleset_id = (int)$camp['camp_ruleset_var_id'];

// ============================================================
// Listes de référence
// ============================================================

// Univers accessibles : les miens + les univers publics.
$stmt_un = $db->prepare('
  SELECT un_id, un_nom
  FROM   dd_univers
  WHERE  un_j_id = ? OR un_public = 1
  ORDER  BY un_nom ASC
');
$stmt_un->execute([$j_id]);
$univers = $stmt_un->fetchAll();

// Sources : ressources du ruleset de la campagne (globales).
// Cochées si déjà rattachées (édition uniquement).
$sources = [];
$sources_actives = [];
if ($id > 0):
  $stmt_src = $db->prepare('
    SELECT res_id, res_nom, res_abreviation
    FROM   dd_ressources
    WHERE  res_ruleset_var_id = ? AND res_j_id IS NULL
    ORDER  BY res_nom ASC
  ');
  $stmt_src->execute([$ruleset_id]);
  $sources = $stmt_src->fetchAll();

  $stmt_act = $db->prepare('SELECT cs_res_id FROM dd_campagnes_sources WHERE cs_camp_id = ?');
  $stmt_act->execute([$id]);
  $sources_actives = array_map('intval', $stmt_act->fetchAll(PDO::FETCH_COLUMN));
endif;

$titre = $id > 0 ? 'Modifier ' . h($camp['camp_nom']) : 'Nouvelle campagne';
?>

<div class="modif-form">
  <h3 class="modif-form__title"><?= $titre ?></h3>

  <form id="form-campagne" method="POST" action="<?= BASE_URL ?>/campagnes/enregistrement.php?ajax=1">
    <?= csrfField() ?>
    <input type="hidden" name="action"  value="enregistrerCampagne">
    <input type="hidden" name="camp_id" value="<?= (int)$camp['camp_id'] ?>">

    <!-- ====================================================
         SECTION 1 — Données de base
         ==================================================== -->
    <div class="modif-section">
      <div class="modif-section__header">
        <span class="modif-section__label">Section 1 — Données de base</span>
      </div>

      <div class="modif-grid">

        <div class="form-group modif-grid__full">
          <label for="camp_nom">Nom <span class="required">*</span></label>
          <input type="text" id="camp_nom" name="camp_nom"
                 value="<?= h($camp['camp_nom']) ?>" required maxlength="150">
        </div>

        <div class="form-group">
          <label for="camp_ruleset_var_id">Ruleset <span class="required">*</span></label>
          <?php if ($id > 0): ?>
            <?php // Ruleset maître : non modifiable après création ?>
            <input type="text" value="<?= libVar($db, $ruleset_id) ?>" disabled>
            <input type="hidden" name="camp_ruleset_var_id" value="<?= $ruleset_id ?>">
            <p class="form-hint">Le ruleset d'une campagne ne peut pas être modifié.</p>
          <?php else: ?>
            <?= optionListVar($db, 'ruleset', 'camp_ruleset_var_id', $ruleset_id) ?>
          <?php endif ?>
        </div>

        <div class="form-group">
          <label for="camp_un_id">Univers</label>
          <select id="camp_un_id" name="camp_un_id">
            <option value="">— Aucun —</option>
            <?php foreach ($univers as $un): ?>
              <option value="<?= (int)$un['un_id'] ?>"
                <?= (int)$camp['camp_un_id'] === (int)$un['un_id'] ? 'selected' : '' ?>>
                <?= h($un['un_nom']) ?>
              </option>
            <?php endforeach ?>
          </select>
        </div>

        <div class="form-group modif-grid__full">
          <label for="camp_resume">Résumé court</label>
          <input type="text" id="camp_resume" name="camp_resume"
                 value="<?= h($camp['camp_resume'] ?? '') ?>" maxlength="255">
        </div>

      </div><!-- .modif-grid -->

      <div class="form-group">
        <label for="camp_description">Description</label>
        <textarea id="camp_description" name="camp_description"
                  class="tinymce-full"><?= $camp['camp_description'] ?? '' ?></textarea>
      </div>

    </div><!-- .modif-section -->

    <!-- ====================================================
         SECTION 2 — Sources (édition uniquement)
         ==================================================== -->
    <?php if ($id === 0): ?>
      <div class="modif-section">
        <div class="modif-section__header">
          <span class="modif-section__label">Section 2 — Sources</span>
        </div>
        <p class="form-hint" style="margin:.5rem 0;">
          Enregistrez d'abord la campagne, puis revenez ici pour sélectionner ses sources.
        </p>
      </div>
    <?php else: ?>
      <div class="modif-section">
        <div class="modif-section__header">
          <span class="modif-section__label">Section 2 — Sources</span>
        </div>
        <?php if (empty($sources)): ?>
          <p class="form-hint" style="margin:.5rem 0;">
            Aucune ressource disponible pour ce ruleset.
          </p>
        <?php else: ?>
          <p class="form-hint" style="margin:.5rem 0;">
            Les sources cochées priment sur la sélection personnelle dans cette campagne.
          </p>
          <div class="camp-sources-grid">
            <?php foreach ($sources as $src): ?>
              <label class="camp-source-item">
                <input type="checkbox" name="sources[]" value="<?= (int)$src['res_id'] ?>"
                  <?= in_array((int)$src['res_id'], $sources_actives, true) ? 'checked' : '' ?>>
                <span><?= h($src['res_nom']) ?></span>
              </label>
            <?php endforeach ?>
          </div>
        <?php endif ?>
      </div>
    <?php endif ?>

    <!-- ====================================================
         BOUTONS
         ==================================================== -->
    <div class="modif-actions">
      <button type="button" class="btn btn-primary" onclick="campagneForm.soumettre()">
        <i class="fa fa-save"></i> Enregistrer
      </button>
      <button type="button" class="btn btn-secondary" onclick="fermerModification()">
        <i class="fa fa-times"></i> Annuler
      </button>
    </div>

  </form>
</div>

<!-- TinyMCE -->
<script src="https://cdn.jsdelivr.net/npm/tinymce@6/tinymce.min.js"></script>
<script>
// ============================================================
// IIFE — isolation du scope (formulaire injecté via innerHTML).
// L'objet campagneForm est exposé sur window pour les onclick="".
// ============================================================
(function() {
  'use strict';

  // ---- TinyMCE : configuration complète (images autorisées) ----
  (function initTMCE() {
    if (typeof tinymce === 'undefined') { setTimeout(initTMCE, 100); return; }
    tinymce.remove('#camp_description');
    tinymce.init({
      selector:    '#camp_description',
      language:    'fr_FR',
      menubar:     false,
      plugins:     'lists link image table',
      toolbar:     'bold italic underline | bullist numlist | h2 h3 | link image table | removeformat',
      height:      360,
      skin:        'oxide-dark',
      content_css: 'dark',
      promotion:   false,
      branding:    false,
      base_url:    'https://cdn.jsdelivr.net/npm/tinymce@6',
      suffix:      '.min',
      images_upload_url: '<?= BASE_URL ?>/include/ajax/upload-image.php',
      images_upload_credentials: true,
      automatic_uploads: true,
    });
  })();

  function tmceGet(id) {
    if (typeof tinymce !== 'undefined') {
      const ed = tinymce.get(id);
      if (ed && ed.initialized) return ed.getContent();
    }
    const el = document.getElementById(id);
    return el ? el.value : '';
  }

  function soumettre() {
    const form = document.getElementById('form-campagne');
    if (!form) return;

    const nom = document.getElementById('camp_nom').value.trim();
    if (!nom) { alert('Le nom de la campagne est obligatoire.'); return; }

    // Synchroniser TinyMCE avant l'envoi.
    const descEl = document.getElementById('camp_description');
    if (descEl) descEl.value = tmceGet('camp_description');

    fetch(form.getAttribute('action'), {
      method: 'POST',
      body:   new FormData(form),
    })
    .then(r => r.json())
    .then(data => {
      if (data.ok) {
        fermerModification();
        // Ouvre la fiche détail en contexte 'liste' pour que fermerDetailPP()
        // déclenche rafraichirListe() via _pendingListRefresh.
        if (data.id) {
          actualiserPage(campUrlDetail, { id: data.id }, 'liste');
        }
        // _pendingListRefresh est déclaré avec let au niveau global de main.js
        // (classic script) : accessible depuis tout autre classic script.
        _pendingListRefresh = true;
      } else {
        alert(data.erreur || "Erreur lors de l'enregistrement.");
      }
    })
    .catch(err => alert('Erreur : ' + err));
  }

  window.campagneForm = { soumettre: soumettre };

})(); // fin IIFE
</script>
