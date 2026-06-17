<?php
// include/ajax/modifier/competence.php
// Formulaire de création/modification d'une compétence
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
$comp = [
  'comp_id'             => 0,
  'comp_nom'            => '',
  'comp_car_id'         => '',
  'comp_formation'      => 0,
  'comp_malusArmure'    => 0,
  'comp_description'    => '',
  'comp_res_id'         => '',
];

if ($id > 0):
  $stmt = $db->prepare('SELECT * FROM dd_competences WHERE comp_id = ?');
  $stmt->execute([$id]);
  $row = $stmt->fetch();
  if ($row) $comp = $row;
endif;

// Caractéristiques (dd_caracteristiques)
$caracteristiques = $db->query(
  'SELECT car_id, car_nom FROM dd_caracteristiques ORDER BY car_nom'
)->fetchAll();

// Ressources actives
$sources = [];
if (!empty($res_ids)):
  $ph   = resIdsPlaceholders($res_ids);
  $stmt = $db->prepare("SELECT res_id, res_nom FROM dd_ressources WHERE res_id IN ($ph) ORDER BY res_nom");
  $stmt->execute($res_ids);
  $sources = $stmt->fetchAll();
endif;

$titre = $id > 0 ? 'Modifier ' . h($comp['comp_nom']) : 'Nouvelle compétence';
?>

<div class="modif-form">
  <h3 class="modif-form__title"><?= $titre ?></h3>

  <form id="form-competence" method="POST"
        action="<?= BASE_URL ?>/compendium/enregistrement.php?ajax=1">
    <?= csrfField() ?>
    <input type="hidden" name="entite"              value="competence">
    <input type="hidden" name="action"              value="sauvegarder">
    <input type="hidden" name="comp_id"             value="<?= (int)$comp['comp_id'] ?>">
    <input type="hidden" name="comp_ruleset_var_id" value="<?= $ruleset_id ?>">

    <div class="modif-section">
      <div class="modif-grid">

        <!-- Nom -->
        <div class="form-group modif-grid__full">
          <label for="comp_nom">Nom <span class="required">*</span></label>
          <input type="text" id="comp_nom" name="comp_nom"
                 value="<?= h($comp['comp_nom']) ?>" required maxlength="100">
        </div>

        <!-- Caractéristique associée -->
        <div class="form-group">
          <label for="comp_car_id">Caractéristique <span class="required">*</span></label>
          <select id="comp_car_id" name="comp_car_id" required>
            <option value="">— Choisir —</option>
            <?php foreach ($caracteristiques as $car): ?>
              <option value="<?= (int)$car['car_id'] ?>"
                <?= (int)$comp['comp_car_id'] === (int)$car['car_id'] ? 'selected' : '' ?>>
                <?= h($car['car_nom']) ?>
              </option>
            <?php endforeach ?>
          </select>
        </div>

        <!-- Source -->
        <div class="form-group">
          <label for="comp_res_id">Source <span class="required">*</span></label>
          <select id="comp_res_id" name="comp_res_id" required>
            <option value="">— Choisir —</option>
            <?php foreach ($sources as $src): ?>
              <option value="<?= (int)$src['res_id'] ?>"
                <?= (int)$comp['comp_res_id'] === (int)$src['res_id'] ? 'selected' : '' ?>>
                <?= h($src['res_nom']) ?>
              </option>
            <?php endforeach ?>
          </select>
        </div>

        <!-- Formation requise -->
        <div class="form-group">
          <label class="form-label--checkbox">
            <input type="checkbox" name="comp_formation" value="1"
              <?= $comp['comp_formation'] ? 'checked' : '' ?>>
            Formation requise
          </label>
        </div>

        <!-- Malus d'armure -->
        <div class="form-group">
          <label for="comp_malusArmure">Malus d'armure</label>
          <input type="number" id="comp_malusArmure" name="comp_malusArmure"
                 value="<?= (int)$comp['comp_malusArmure'] ?>" min="0" max="99">
        </div>

      </div><!-- .modif-grid -->
    </div><!-- .modif-section -->

    <!-- Description TinyMCE -->
    <div class="modif-section">
      <div class="form-group">
        <label for="comp_description">Description</label>
        <textarea id="comp_description" name="comp_description"
                  class="tinymce-basic"><?= $comp['comp_description'] ?? '' ?></textarea>
      </div>
    </div>

    <!-- Boutons -->
    <div class="modif-actions">
      <button type="button" class="btn btn-primary" onclick="soumettreCompetence()">
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
  tinymce.remove('#comp_description');
  tinymce.init({
    selector:      '#comp_description',
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
