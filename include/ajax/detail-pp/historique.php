<?php
// include/ajax/detail-pp/historique.php
// Retourne le HTML de détail d'un historique pour #detail-pp
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
  SELECT hi.*,
         res.res_nom,
         camp.camp_nom,
         var.var_valeur AS ruleset_label
  FROM   dd_historiques hi
  LEFT JOIN dd_ressources res  ON res.res_id   = hi.hi_res_id
  LEFT JOIN dd_campagnes  camp ON camp.camp_id = hi.hi_camp_id
  LEFT JOIN dd_variables  var  ON var.var_id   = hi.hi_ruleset_var_id
  WHERE  hi.hi_id = ?
');
$stmt->execute([$id]);
$historique = $stmt->fetch();

if (!$historique):
  http_response_code(404);
  echo '<p class="erreur">Historique introuvable.</p>';
  exit;
endif;
?>

<div class="sort-detail">

  <!-- En-tête : nom + bouton modifier -->
  <div class="sort-detail__header">
    <h2 class="sort-detail__nom">
      <?= h($historique['hi_nom']) ?>
      <?php if (canEditCompendium()): ?>
        <button class="sort-detail__edit-btn"
                onclick="ouvrirModifier('<?= BASE_URL ?>/include/ajax/modifier/historique.php', <?= $id ?>)"
                title="Modifier cet historique">
          <i class="fa fa-edit"></i>
        </button>
      <?php endif ?>
    </h2>
  </div>

  <!-- Description -->
  <?php if ($historique['hi_description']): ?>
    <div class="sort-detail__description">
      <?= $historique['hi_description'] ?>
    </div>
  <?php endif ?>

  <!-- Pied de fiche -->
  <div class="sort-detail__footer">
    <span class="sort-detail__source">
      <i class="fa fa-book"></i> <?= h($historique['res_nom']) ?>
    </span>
    <?php if ($historique['hi_camp_id'] && $historique['camp_nom']): ?>
      <span class="sort-detail__homebrew">
        <i class="fa fa-flask"></i> <?= h($historique['camp_nom']) ?>
      </span>
    <?php endif ?>
    <span class="sort-detail__ruleset"><?= h($historique['ruleset_label']) ?></span>
  </div>

</div>
