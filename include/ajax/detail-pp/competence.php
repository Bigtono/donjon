<?php
// include/ajax/detail-pp/competence.php
// Retourne le HTML de détail d'une compétence pour #detail-pp
// Paramètres GET : id (int)

require_once __DIR__ . '/../../db.php';
require_once __DIR__ . '/../../auth.php';
require_once __DIR__ . '/../../helpers.php';
// Tag [[tab:slug]] dans les champs texte du compendium (SP-TB7)
require_once __DIR__ . '/../../tableau-parser.php';

requireAuth();

$id = intParam($_GET['id'] ?? $_POST['id'] ?? 0);

if (!$id):
  http_response_code(400);
  echo '<p class="erreur">Identifiant manquant.</p>';
  exit;
endif;

$stmt = $db->prepare('
  SELECT comp.*,
         mere.comp_nom AS mere_nom,
         car.car_nom,
         res.res_nom,
         res.res_j_id,
         var.var_valeur AS ruleset_label
  FROM   dd_competences comp
  LEFT JOIN dd_competences      mere ON mere.comp_id = comp.comp_parent_id
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

// Domaines d'une compétence mère (SP-CD) : sources actives seulement
$domaines = [];
if ($competence['comp_parent_id'] === null):
  $res_ids = getActiveResIds($db, (int)$competence['comp_ruleset_var_id']);
  $sql     = 'SELECT comp_id, comp_nom FROM dd_competences WHERE comp_parent_id = ?';
  $params  = [$id];
  if (!empty($res_ids)):
    $sql   .= ' AND comp_res_id IN (' . resIdsPlaceholders($res_ids) . ')';
    $params = array_merge($params, $res_ids);
  endif;
  $stmt = $db->prepare($sql . ' ORDER BY comp_nom');
  $stmt->execute($params);
  $domaines = $stmt->fetchAll();
endif;
?>

<div class="sort-detail">

  <!-- En-tête : nom + bouton modifier -->
  <div class="sort-detail__header">
    <h2 class="sort-detail__nom">
      <?= h($competence['comp_nom']) ?>
      <?php if (canEditCompendiumEntry($db, $competence['res_j_id'] !== null ? (int)$competence['res_j_id'] : null)): ?>
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

  <?php if ($competence['comp_parent_id'] !== null): ?>
    <div class="sort-detail__row">
      <span class="sort-detail__label">Domaine de</span>
      <span class="sort-detail__value">
        <span class="lien-sub"
              onclick="naviguerDetailPP('<?= BASE_URL ?>/include/ajax/detail-pp/competence.php', {id:<?= (int)$competence['comp_parent_id'] ?>})"
              title="Voir la compétence mère">
          <?= h($competence['mere_nom'] ?? '') ?>
        </span>
      </span>
    </div>
  <?php elseif (!empty($domaines)): ?>
    <div class="sort-detail__row">
      <span class="sort-detail__label">Domaines</span>
      <span class="sort-detail__value">
        <?php foreach ($domaines as $i => $d): ?>
          <?= $i > 0 ? '·' : '' ?>
          <span class="lien-sub"
                onclick="naviguerDetailPP('<?= BASE_URL ?>/include/ajax/detail-pp/competence.php', {id:<?= (int)$d['comp_id'] ?>})"><?= h($d['comp_nom']) ?></span>
        <?php endforeach ?>
      </span>
    </div>
  <?php endif ?>

  <!-- Description -->
  <?php if ($competence['comp_description']): ?>
    <div class="sort-detail__description">
      <?= rendreTexteEnrichi($db, $competence['comp_description']) ?>
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
