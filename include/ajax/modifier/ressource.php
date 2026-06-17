<?php
// include/ajax/modifier/ressource.php
// Retourne le HTML du formulaire de création/modification d'une ressource
// Paramètres GET : id (int) — res_id (0 = création)

require_once __DIR__ . '/../../db.php';
require_once __DIR__ . '/../../auth.php';
require_once __DIR__ . '/../../helpers.php';

requireAdmin();

$id = intParam($_GET['id'] ?? 0);

// Valeurs par défaut (création)
$res = [
  'res_id'             => 0,
  'res_nom'            => '',
  'res_abreviation'    => '',
  'res_ruleset_var_id' => 0,
  'res_selection'      => 0,
  'res_editeur'        => '',
  'res_pages'          => '',
  'res_description'    => '',
];

if ($id > 0):
  $stmt = $db->prepare('SELECT * FROM dd_ressources WHERE res_id = ?');
  $stmt->execute([$id]);
  $row = $stmt->fetch();
  if ($row) $res = $row;
endif;

// Rulesets disponibles
$rulesets = $db->query(
  "SELECT var_id, var_valeur FROM dd_variables
   WHERE var_cat = 'ruleset' ORDER BY var_ordre"
)->fetchAll();

$titre = $id > 0 ? 'Modifier ' . h($res['res_nom']) : 'Nouvelle ressource';
?>

<div class="modif-form">
  <h3 class="modif-form__title"><?= $titre ?></h3>

  <form id="form-ressource" method="POST"
        action="<?= BASE_URL ?>/admin/enregistrement.php?ajax=1">
    <?= csrfField() ?>
    <input type="hidden" name="entite"  value="ressource">
    <input type="hidden" name="action"  value="sauvegarder">
    <input type="hidden" name="res_id"  value="<?= (int)$res['res_id'] ?>">

    <?php // ---- Identification ---- ?>
    <div class="modif-section">
      <div class="modif-grid">

        <div class="form-group modif-grid__full">
          <label for="res_nom">
            Nom complet <span class="required">*</span>
          </label>
          <input type="text" id="res_nom" name="res_nom"
                 value="<?= h($res['res_nom']) ?>" required maxlength="150"
                 placeholder="Ex: Manuel des Joueurs">
        </div>

        <div class="form-group">
          <label for="res_abreviation">
            Abréviation <span class="required">*</span>
          </label>
          <input type="text" id="res_abreviation" name="res_abreviation"
                 value="<?= h($res['res_abreviation']) ?>" required maxlength="20"
                 placeholder="Ex: MJ">
        </div>

        <div class="form-group">
          <label for="res_ruleset_var_id">
            Ruleset <span class="required">*</span>
          </label>
          <select id="res_ruleset_var_id" name="res_ruleset_var_id" required>
            <option value="">— Choisir —</option>
            <?php foreach ($rulesets as $rs): ?>
              <option value="<?= (int)$rs['var_id'] ?>"
                <?= (int)$res['res_ruleset_var_id'] === (int)$rs['var_id'] ? 'selected' : '' ?>>
                <?= h($rs['var_valeur']) ?>
              </option>
            <?php endforeach ?>
          </select>
        </div>

        <div class="form-group" style="align-self: center;">
          <label class="modif-check">
            <input type="checkbox" name="res_selection" value="1"
                   <?= (int)$res['res_selection'] ? 'checked' : '' ?>>
            Actif par défaut dans les sélections
          </label>
        </div>

      </div>
    </div>

    <?php // ---- Informations éditoriales ---- ?>
    <div class="modif-section">
      <div class="modif-section__header">
        <span class="modif-section__label">Informations éditoriales</span>
        <button type="button" class="accordion-trigger"
                onclick="togglePlusExclusif('bloc-editorial', '#form-ressource')">
          <i class="fa fa-bars"></i>
        </button>
      </div>
      <div id="bloc-editorial" class="accordion-content noDisplay">
        <div class="box-data">
          <div class="modif-grid">

            <div class="form-group">
              <label for="res_editeur">Éditeur</label>
              <input type="text" id="res_editeur" name="res_editeur"
                     value="<?= h($res['res_editeur'] ?? '') ?>" maxlength="255"
                     placeholder="Ex: Wizards of the Coast">
            </div>

            <div class="form-group">
              <label for="res_pages">Nombre de pages</label>
              <input type="number" id="res_pages" name="res_pages"
                     value="<?= h($res['res_pages'] ?? '') ?>" min="0" max="9999">
            </div>

          </div>
        </div>
      </div>
    </div>

    <?php // ---- Description ---- ?>
    <div class="modif-section">
      <div class="form-group">
        <label for="res_description">Description</label>
        <textarea id="res_description" name="res_description"
                  class="tinymce-basic"><?= $res['res_description'] ?? '' ?></textarea>
      </div>
    </div>

    <div class="modif-actions">
      <button type="button" class="btn btn-primary"
              onclick="soumettreRessource()">
        <i class="fa fa-save"></i> Enregistrer
      </button>
      <button type="button" class="btn btn-secondary"
              onclick="fermerModification()">
        <i class="fa fa-times"></i> Annuler
      </button>
    </div>

  </form>
</div>

<script src="https://cdn.jsdelivr.net/npm/tinymce@6/tinymce.min.js"></script>
<script>
(function initTMCE() {
  if (typeof tinymce === 'undefined') { setTimeout(initTMCE, 100); return; }
  var isLight = document.body.classList.contains('theme-light');
  tinymce.remove('#res_description');
  tinymce.init({
    selector:      '#res_description',
    language:      'fr_FR',
    menubar:       false,
    plugins:       'lists link table code',
    toolbar:       'styles | bold italic underline | bullist numlist | link unlink table | removeformat | code',
    height:        250,
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
