<?php
// include/ajax/modifier/categorie-note.php
// Formulaire de création/modification d'une catégorie de notes (SP-NO6)
// Paramètres GET : id (int) — tyno_id (0 = création)

require_once __DIR__ . '/../../db.php';
require_once __DIR__ . '/../../auth.php';
require_once __DIR__ . '/../../helpers.php';

requireAdmin();

$id = intParam($_GET['id'] ?? 0);

$tyno = [
  'tyno_id'             => 0,
  'tyno_nom'            => '',
  'tyno_ruleset_var_id' => (int)($_SESSION['ruleset_var_id'] ?? 1),
  'tyno_ordre'          => '',
];
$nb_notes = 0;

if ($id > 0):
  $stmt = $db->prepare('SELECT * FROM dd_types_notes WHERE tyno_id = ?');
  $stmt->execute([$id]);
  $row = $stmt->fetch();
  if ($row) $tyno = $row;
  $stmt = $db->prepare('SELECT COUNT(*) FROM dd_notes WHERE no_tyno_id = ?');
  $stmt->execute([$id]);
  $nb_notes = (int)$stmt->fetchColumn();
endif;

$rulesets = $db->query(
  "SELECT var_id, var_valeur FROM dd_variables
   WHERE var_cat = 'ruleset' ORDER BY var_ordre"
)->fetchAll();

$titre = $id > 0 ? 'Modifier ' . h($tyno['tyno_nom']) : 'Nouvelle catégorie de notes';
?>

<div class="modif-form">
  <h3 class="modif-form__title"><?= $titre ?></h3>

  <form id="form-categorie-note" method="POST"
        action="<?= BASE_URL ?>/admin/enregistrement.php?ajax=1">
    <?= csrfField() ?>
    <input type="hidden" name="entite"  value="categorie-note">
    <input type="hidden" name="action"  value="sauvegarder">
    <input type="hidden" name="tyno_id" value="<?= (int)$tyno['tyno_id'] ?>">

    <div class="modif-section">
      <div class="modif-grid">

        <div class="form-group modif-grid__full">
          <label for="tyno_nom">Nom <span class="required">*</span></label>
          <input type="text" id="tyno_nom" name="tyno_nom"
                 value="<?= h($tyno['tyno_nom']) ?>" required maxlength="80"
                 placeholder="Ex : Rumeurs et légendes">
        </div>

        <div class="form-group">
          <label for="tyno_ruleset_var_id">Ruleset <span class="required">*</span></label>
          <?php if ($nb_notes > 0): ?>
            <?php // Une note employant la catégorie doit garder le ruleset de sa campagne ?>
            <input type="hidden" name="tyno_ruleset_var_id" value="<?= (int)$tyno['tyno_ruleset_var_id'] ?>">
          <?php endif ?>
          <select id="tyno_ruleset_var_id" <?= $nb_notes > 0 ? 'disabled' : 'name="tyno_ruleset_var_id"' ?> required>
            <?php foreach ($rulesets as $rs): ?>
              <option value="<?= (int)$rs['var_id'] ?>"
                <?= (int)$tyno['tyno_ruleset_var_id'] === (int)$rs['var_id'] ? 'selected' : '' ?>>
                <?= h($rs['var_valeur']) ?>
              </option>
            <?php endforeach ?>
          </select>
          <?php if ($nb_notes > 0): ?>
            <small class="text-muted"><?= $nb_notes ?> note<?= $nb_notes > 1 ? 's' : '' ?> : ruleset verrouillé.</small>
          <?php endif ?>
        </div>

        <div class="form-group">
          <label for="tyno_ordre">Ordre d'affichage</label>
          <input type="number" id="tyno_ordre" name="tyno_ordre" min="0" max="65535"
                 value="<?= h((string)$tyno['tyno_ordre']) ?>"
                 placeholder="Vide = en dernier">
        </div>

      </div>
    </div>

    <div class="modif-actions">
      <button type="button" class="btn btn-primary" onclick="soumettreCategorieNote()">
        <i class="fa fa-save"></i> Enregistrer
      </button>
      <button type="button" class="btn btn-secondary" onclick="fermerModification()">
        <i class="fa fa-times"></i> Annuler
      </button>
    </div>
  </form>
</div>

<script>
var soumettreCategorieNote = function () {
  var form = document.getElementById('form-categorie-note');
  if (!form || !form.reportValidity()) return;
  fetch(form.getAttribute('action'), { method: 'POST', body: new FormData(form) })
    .then(function (r) { return r.json(); })
    .then(function (data) {
      if (data.ok) apresModification(data);
      else alert(data.erreur || 'Erreur lors de l\'enregistrement.');
    })
    .catch(function (err) { alert('Erreur : ' + err); });
};
</script>
