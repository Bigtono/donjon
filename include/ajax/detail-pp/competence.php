<?php
// include/ajax/detail-pp/competence.php
// Retourne le HTML de détail d'une compétence pour #detail-pp
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
  SELECT comp.*,
         car.car_nom,
         res.res_nom,
         var.var_valeur AS ruleset_label
  FROM   dd_competences comp
  LEFT JOIN dd_caracteristiques car ON car.car_id = comp.comp_car_id
  LEFT JOIN dd_ressources       res ON res.res_id  = comp.comp_res_id
  LEFT JOIN dd_variables        var ON var.var_id  = comp.comp_ruleset_var_id
  WHERE  comp.comp_id = ?
');
$stmt->execute([$id]);
$competence = $stmt->fetch();

if (!$competence):
  http_response_code(404);
  echo '<p class="erreur">Compétence introuvable.</p>';
  exit;
endif;
?>

<div class="sort-detail">

  <!-- En-tête : nom + bouton modifier -->
  <div class="sort-detail__header">
    <h2 class="sort-detail__nom">
      <?= h($competence['comp_nom']) ?>
      <?php if (canEditCompendium()): ?>
        <button class="sort-detail__edit-btn"
                onclick="ouvrirModifier('<?= BASE_URL ?>/include/ajax/modifier/competence.php', <?= $id ?>)"
                title="Modifier cette compétence">
          <i class="fa fa-edit"></i>
        </button>
      <?php endif ?>
    </h2>

    <!-- Sous-titre : caractéristique + indicateurs -->
    <?php
    $meta = [];
    if ($competence['car_nom'])
      $meta[] = h($competence['car_nom']);
    if ($competence['comp_formation'])
      $meta[] = 'Formation requise';
    if ($competence['comp_malusArmure'])
      $meta[] = 'Malus armure ×' . (int)$competence['comp_malusArmure'];
    ?>
    <?php if (!empty($meta)): ?>
      <p class="sort-detail__college">
        <?= implode(' · ', $meta) ?>
      </p>
    <?php endif ?>
  </div>

  <!-- Description -->
  <?php if ($competence['comp_description']): ?>
    <div class="sort-detail__description">
      <?= $competence['comp_description'] ?>
    </div>
  <?php endif ?>

  <!-- Pied de fiche -->
  <div class="sort-detail__footer">
    <span class="sort-detail__source">
      <i class="fa fa-book"></i> <?= h($competence['res_nom']) ?>
    </span>
    <span class="sort-detail__ruleset"><?= h($competence['ruleset_label']) ?></span>
  </div>

</div>
