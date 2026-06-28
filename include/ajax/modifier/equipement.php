<?php
// include/ajax/modifier/equipement.php
// Formulaire de création/modification d'un équipement
// Paramètres GET : id (int, 0 = création)

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
$ruleset_id = (int)($_SESSION['ruleset_var_id'] ?? 1);
$res_ids    = getActiveResIds($db);

// Valeurs par défaut (création)
$equipement = [
  'eqt_id'          => 0,
  'eqt_nom'         => '',
  'eqt_description' => '',
  'eqt_visible'     => 1,
  'eqt_res_id'      => '',
  'eqt_camp_id'     => '',
];

if ($id > 0):
  $stmt = $db->prepare('SELECT * FROM dd_equipements WHERE eqt_id = ?');
  $stmt->execute([$id]);
  $row = $stmt->fetch();
  if ($row) $equipement = $row;
endif;

// Ressources actives
$sources = [];
if (!empty($res_ids)):
  $ph   = resIdsPlaceholders($res_ids);
  $stmt = $db->prepare("SELECT res_id, res_nom FROM dd_ressources WHERE res_id IN ($ph) ORDER BY res_nom");
  $stmt->execute($res_ids);
  $sources = $stmt->fetchAll();
endif;

// Campagnes de l'utilisateur
$campagnes = [];
if (!empty($_SESSION['j_mode_campagne'])):
  [$owWhere, $owParams] = ownerFilter('camp');
  $stmt = $db->prepare("SELECT camp_id, camp_nom FROM dd_campagnes WHERE $owWhere ORDER BY camp_nom");
  $stmt->execute($owParams);
  $campagnes = $stmt->fetchAll();
endif;

$titre = $id > 0 ? 'Modifier ' . h($equipement['eqt_nom']) : 'Nouvel équipement';
?>

<div class="modif-form">
  <h3 class="modif-form__title"><?= $titre ?></h3>

  <form id="form-equipement" method="POST"
        action="<?= BASE_URL ?>/compendium/enregistrement.php?ajax=1">
    <?= csrfField() ?>
    <input type="hidden" name="entite"            value="equipement">
    <input type="hidden" name="action"            value="sauvegarder">
    <input type="hidden" name="eqt_id"            value="<?= (int)$equipement['eqt_id'] ?>">
    <input type="hidden" name="eqt_ruleset_var_id" value="<?= $ruleset_id ?>">

    <div class="modif-section">
      <div class="modif-grid">

        <!-- Nom -->
        <div class="form-group modif-grid__full">
          <label for="eqt_nom">Nom <span class="required">*</span></label>
          <input type="text" id="eqt_nom" name="eqt_nom"
                 value="<?= h($equipement['eqt_nom']) ?>" required maxlength="150">
        </div>

        <!-- Source -->
        <div class="form-group">
          <label for="eqt_res_id">Source <span class="required">*</span></label>
          <select id="eqt_res_id" name="eqt_res_id" required>
            <option value="">— Choisir —</option>
            <?php foreach ($sources as $src): ?>
              <option value="<?= (int)$src['res_id'] ?>"
                <?= (int)$equipement['eqt_res_id'] === (int)$src['res_id'] ? 'selected' : '' ?>>
                <?= h($src['res_nom']) ?>
              </option>
            <?php endforeach ?>
          </select>
        </div>

        <!-- Campagne homebrew -->
        <?php if (!empty($campagnes)): ?>
          <div class="form-group">
            <label for="eqt_camp_id">Campagne (homebrew)</label>
            <select id="eqt_camp_id" name="eqt_camp_id">
              <option value="">— Compendium global —</option>
              <?php foreach ($campagnes as $camp): ?>
                <option value="<?= (int)$camp['camp_id'] ?>"
                  <?= (int)$equipement['eqt_camp_id'] === (int)$camp['camp_id'] ? 'selected' : '' ?>>
                  <?= h($camp['camp_nom']) ?>
                </option>
              <?php endforeach ?>
            </select>
          </div>
        <?php endif ?>

        <!-- Visibilité -->
        <div class="form-group">
          <label for="eqt_visible">
            <input type="checkbox" id="eqt_visible" name="eqt_visible" value="1"
              <?= (int)$equipement['eqt_visible'] === 1 ? 'checked' : '' ?>>
            Visible aux joueurs
          </label>
        </div>

      </div><!-- .modif-grid -->
    </div><!-- .modif-section -->

    <!-- Description TinyMCE -->
    <div class="modif-section">
      <div class="form-group">
        <label for="eqt_description">Description</label>
        <textarea id="eqt_description" name="eqt_description"
                  class="tinymce-basic"><?= $equipement['eqt_description'] ?? '' ?></textarea>
      </div>
    </div>

    <!-- Boutons -->
    <div class="modif-actions">
      <button type="button" class="btn btn-primary" onclick="soumettreEquipement()">
        <i class="fa fa-save"></i> Enregistrer
      </button>
      <button type="button" class="btn btn-secondary" onclick="fermerModification()">
        <i class="fa fa-times"></i> Annuler
      </button>
    </div>

  </form>
</div>

<!-- TinyMCE via jsDelivr -->
<script src="https://cdn.jsdelivr.net/npm/tinymce@6/tinymce.min.js"></script>
<script>
(function initTMCE() {
  if (typeof tinymce === 'undefined') { setTimeout(initTMCE, 100); return; }
  var isLight = document.body.classList.contains('theme-light');
  tinymce.remove('#eqt_description');
  tinymce.init({
    selector:      '#eqt_description',
    language:      'fr_FR',
    menubar:       false,
    plugins:       'lists link table code',
    toolbar:       'styles | bold italic underline | bullist numlist | link unlink table | removeformat | code',
    height:        400,
    skin:          isLight ? 'oxide' : 'oxide-dark',
    content_css:   isLight ? 'default' : 'dark',
    content_style: isLight
      ? 'body { background:#eae6dd; color:#2a2015; font-family:inherit; font-size:14px; }'
      : 'body { background:#0f3460; color:#e0e0e0; font-family:inherit; font-size:14px; }',
    promotion:     false,
    branding:      false,
    base_url:      'https://cdn.jsdelivr.net/npm/tinymce@6',
    suffix:        '.min',
  });
})();
</script>
