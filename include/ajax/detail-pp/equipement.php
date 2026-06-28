<?php
// include/ajax/detail-pp/equipement.php
// Retourne le HTML de détail d'un équipement pour #detail-pp
// Paramètres GET : id (int)

require_once __DIR__ . '/../../db.php';
require_once __DIR__ . '/../../auth.php';
require_once __DIR__ . '/../../helpers.php';

requireAuth();

$id = intParam($_GET['id'] ?? $_POST['id'] ?? 0);

if (!$id):
  http_response_code(400);
  echo '<p class="erreur">Identifiant manquant.</p>';
  exit;
endif;

$stmt = $db->prepare('
  SELECT eqt.*,
         res.res_nom,
         camp.camp_nom,
         var.var_valeur AS ruleset_label
  FROM   dd_equipements eqt
  LEFT JOIN dd_ressources res  ON res.res_id   = eqt.eqt_res_id
  LEFT JOIN dd_campagnes  camp ON camp.camp_id = eqt.eqt_camp_id
  LEFT JOIN dd_variables  var  ON var.var_id   = eqt.eqt_ruleset_var_id
  WHERE  eqt.eqt_id = ?
');
$stmt->execute([$id]);
$equipement = $stmt->fetch();

if (!$equipement):
  http_response_code(404);
  echo '<p class="erreur">Équipement introuvable.</p>';
  exit;
endif;
?>

<div class="sort-detail">

  <!-- En-tête : nom + bouton modifier -->
  <div class="sort-detail__header">
    <h2 class="sort-detail__nom">
      <?= h($equipement['eqt_nom']) ?>
      <?php if (canEditCompendium()): ?>
        <button class="sort-detail__edit-btn"
                onclick="ouvrirModifier('<?= BASE_URL ?>/include/ajax/modifier/equipement.php', <?= $id ?>)"
                title="Modifier cet équipement">
          <i class="fa fa-edit"></i>
        </button>
      <?php endif ?>
    </h2>
  </div>

  <!-- Description -->
  <?php if ($equipement['eqt_description']): ?>
    <div class="sort-detail__description">
      <?= $equipement['eqt_description'] ?>
    </div>
  <?php endif ?>

  <!-- Pied de fiche -->
  <div class="sort-detail__footer">
    <span class="sort-detail__source">
      <i class="fa fa-book"></i> <?= h($equipement['res_nom']) ?>
    </span>
    <?php if ($equipement['eqt_camp_id'] && $equipement['camp_nom']): ?>
      <span class="sort-detail__homebrew">
        <i class="fa fa-flask"></i> <?= h($equipement['camp_nom']) ?>
      </span>
    <?php endif ?>
    <span class="sort-detail__ruleset"><?= h($equipement['ruleset_label']) ?></span>
  </div>

</div>
