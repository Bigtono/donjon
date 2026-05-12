<?php
// include/ajax/detail-pp/don.php
// Retourne le HTML de détail d'un don pour #detail-pp
// Paramètres GET : id (int)

require_once __DIR__ . '/../../db.php';
require_once __DIR__ . '/../../auth.php';
require_once __DIR__ . '/../../helpers.php';

requireAuth();

$id      = intParam($_GET['id'] ?? $_POST['id'] ?? 0);
$ruleset = $_SESSION['rulesetRep'] ?? 'DD3.5';

if (!$id):
  http_response_code(400);
  echo '<p class="erreur">Identifiant manquant.</p>';
  exit;
endif;

$stmt = $db->prepare('
  SELECT do.*,
         dad.dado_nom,
         res.res_nom,
         camp.camp_nom,
         var.var_valeur AS ruleset_label
  FROM   dd_dons do
  LEFT JOIN dd_data_don   dad  ON dad.dado_id  = do.do_dado_id
  LEFT JOIN dd_ressources res  ON res.res_id   = do.do_res_id
  LEFT JOIN dd_campagnes  camp ON camp.camp_id = do.do_camp_id
  LEFT JOIN dd_variables  var  ON var.var_id   = do.do_ruleset_var_id
  WHERE  do.do_id = ?
');
$stmt->execute([$id]);
$don = $stmt->fetch();

if (!$don):
  http_response_code(404);
  echo '<p class="erreur">Don introuvable.</p>';
  exit;
endif;
?>

<div class="sort-detail">

  <!-- En-tête : nom + bouton modifier -->
  <div class="sort-detail__header">
    <h2 class="sort-detail__nom">
      <?= h($don['do_nom']) ?>
      <?php if (canEditCompendium()): ?>
        <button class="sort-detail__edit-btn"
                onclick="ouvrirModifier('<?= BASE_URL ?>/include/ajax/modifier/don.php', <?= $id ?>)"
                title="Modifier ce don">
          <i class="fa fa-edit"></i>
        </button>
      <?php endif ?>
    </h2>

    <?php // Catégorie + prérequis DD2024 ?>
    <p class="sort-detail__college">
      <?php if ($don['dado_nom']): ?>
        <?= h($don['dado_nom']) ?>
      <?php endif ?>
      <?php if ($ruleset === 'DD2024' && $don['do_conditions']): ?>
        <?= $don['dado_nom'] ? ' · ' : '' ?>
        <em><?= h($don['do_conditions']) ?></em>
      <?php endif ?>
    </p>
  </div>

  <!-- Description -->
  <?php if ($don['do_texte']): ?>
    <div class="sort-detail__description">
      <?= $don['do_texte'] ?>
    </div>
  <?php endif ?>

  <!-- Pied de fiche -->
  <div class="sort-detail__footer">
    <span class="sort-detail__source">
      <i class="fa fa-book"></i> <?= h($don['res_nom']) ?>
    </span>
    <?php if ($don['do_camp_id'] && $don['camp_nom']): ?>
      <span class="sort-detail__homebrew">
        <i class="fa fa-flask"></i> <?= h($don['camp_nom']) ?>
      </span>
    <?php endif ?>
    <span class="sort-detail__ruleset"><?= h($don['ruleset_label']) ?></span>
  </div>

</div>
