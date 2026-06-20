<?php
// include/ajax/detail-pp/monstre.php
// Fiche détail d'un monstre pour #detail-pp
// Paramètres GET : id (int)
//
// mo_stats est stocké en TEXTE BRUT. Le formatage (mise en page + liens
// cliquables vers dons/sorts/objets/etc.) est calculé À L'AFFICHAGE par
// rendreStatsMonstre() — les liens restent donc toujours à jour.

require_once __DIR__ . '/../../db.php';
require_once __DIR__ . '/../../auth.php';
require_once __DIR__ . '/../../helpers.php';
require_once __DIR__ . '/../../monstre-parser.php';

requireAuth();

$id = intParam($_GET['id'] ?? $_POST['id'] ?? 0);

if (!$id):
  http_response_code(400);
  echo '<p class="erreur">Identifiant manquant.</p>';
  exit;
endif;

$stmt = $db->prepare('
  SELECT
    mo.*,
    mocat.mocat_nom,
    mogr.mogr_nom,
    res.res_nom,
    res.res_j_id,
    var.var_valeur AS ruleset_label
  FROM   dd_monstres               mo
  LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
  LEFT JOIN dd_monstres_groupes    mogr  ON mogr.mogr_id   = mo.mo_mogr_id
  LEFT JOIN dd_ressources          res   ON res.res_id     = mo.mo_res_id
  LEFT JOIN dd_variables           var   ON var.var_id     = mo.mo_ruleset_var_id
  WHERE  mo.mo_id = ?
');
$stmt->execute([$id]);
$mo = $stmt->fetch();

if (!$mo):
  http_response_code(404);
  echo '<p class="erreur">Monstre introuvable.</p>';
  exit;
endif;

$uid = (int)($_SESSION['j_id'] ?? 0);

$ruleset_rep = $_SESSION['rulesetRep'] ?? 'DD3.5';
$est_dd2024  = (int)$mo['mo_ruleset_var_id'] !== 1;

// Analyse + rendu du bloc de stats sur la base des sources actives du lecteur
$res_ids = getActiveResIds($db);
$rendu   = rendreStatsMonstre($db, $mo['mo_stats'], (int)$mo['mo_ruleset_var_id'], $res_ids);

// Méta sous le titre : catégorie · groupe (DD2024) · FP
$meta = [];
if ($mo['mocat_nom'])               $meta[] = h($mo['mocat_nom']);
if ($est_dd2024 && $mo['mogr_nom']) $meta[] = h($mo['mogr_nom']);
if ($mo['mo_fp_id'] !== null && $mo['mo_fp_id'] !== ''):
  $meta[] = 'FP ' . h((string)$mo['mo_fp_id']);
endif;

// Base d'URL des fiches liées, lue côté JS sur le conteneur (découplage BASE_URL)
$detail_base = BASE_URL . '/include/ajax/detail-pp/';
?>

<div class="sort-detail monstre-detail">

  <div class="sort-detail__header">
    <h2 class="sort-detail__nom">
      <?= h($mo['mo_nom']) ?>
      <?php if (canEditCompendiumEntry($db, $mo['res_j_id'] !== null ? (int)$mo['res_j_id'] : null)): ?>
        <button class="sort-detail__edit-btn"
                onclick="ouvrirModifier('<?= BASE_URL ?>/include/ajax/modifier/monstre.php', <?= $id ?>)"
                title="Modifier ce monstre">
          <i class="fa fa-edit"></i>
        </button>
      <?php endif ?>
    </h2>

    <?php if (!empty($meta)): ?>
      <p class="sort-detail__college"><?= implode(' · ', $meta) ?></p>
    <?php endif ?>
  </div>

  <?php if ($rendu['html'] !== ''): ?>
    <div class="sort-detail__description mo-stats"
         data-detail-base="<?= h($detail_base) ?>">
      <?= $rendu['html'] ?>
    </div>
  <?php else: ?>
    <p class="text-muted">Aucune statistique renseignée.</p>
  <?php endif ?>

  <div class="sort-detail__footer">
    <span class="sort-detail__source">
      <i class="fa fa-book"></i> <?= h($mo['res_nom']) ?>
    </span>
    <span class="sort-detail__ruleset"><?= h($mo['ruleset_label']) ?></span>
  </div>

</div>
