<?php
// include/ajax/detail-pp/capacite.php
// Retourne le HTML de détail d'une capacité spéciale pour #detail-pp-sub
// Appelé via actualiserPageSub() — pas de layout header/footer
//
// Paramètres GET :
//   id (int) — cap_id de la capacité à afficher

require_once __DIR__ . '/../../db.php';
require_once __DIR__ . '/../../auth.php';
require_once __DIR__ . '/../../helpers.php';

requireAuth();

$id      = intParam($_GET['id'] ?? 0);
$ruleset = $_SESSION['rulesetRep'] ?? 'DD3.5';

if (!$id):
  http_response_code(400);
  echo '<p class="erreur">Identifiant manquant.</p>';
  exit;
endif;

// ============================================================
// Données de la capacité spéciale
// ============================================================

$stmt = $db->prepare('
  SELECT cap.*,
         var.var_valeur AS cat_label
  FROM   dd_capacites_speciales cap
  LEFT JOIN dd_variables var ON var.var_id = cap.cap_categorie_var_id
  WHERE  cap.cap_id = ?
');
$stmt->execute([$id]);
$cap = $stmt->fetch();

if (!$cap):
  http_response_code(404);
  echo '<p class="erreur">Capacité introuvable.</p>';
  exit;
endif;

// ============================================================
// Classes qui possèdent cette capacité (avec niveau et précision)
// ============================================================

$stmt_classes = $db->prepare('
  SELECT cla.cla_id, cla.cla_nom, cc.cc_niveau, cc.cc_precision
  FROM   dd_classe_capacite cc
  JOIN   dd_classes cla ON cla.cla_id = cc.cc_cla_id
  WHERE  cc.cc_cap_id = ?
  ORDER  BY cla.cla_nom ASC, cc.cc_niveau ASC
');
$stmt_classes->execute([$id]);
$classes = $stmt_classes->fetchAll();

// ============================================================
// Races qui possèdent cette capacité
// ============================================================

$stmt_races = $db->prepare('
  SELECT ra.ra_id, ra.ra_nom
  FROM   dd_race_capacite cr
  JOIN   dd_races ra ON ra.ra_id = cr.cr_ra_id
  WHERE  cr.cr_cap_id = ?
  ORDER  BY ra.ra_nom ASC
');
$stmt_races->execute([$id]);
$races = $stmt_races->fetchAll();
?>

<div class="sort-detail capacite-detail">

  <div class="sort-detail__header">
    <h3 class="sort-detail__nom" style="font-size:1.1rem;">
      <?= h($cap['cap_nom']) ?>
      <?php if ($cap['cap_type']): ?>
        <span class="cap-type" style="font-size:.85rem; font-weight:normal;">
          (<?= h($cap['cap_type']) ?>)
        </span>
      <?php endif ?>
    </h3>
    <?php if ($cap['cat_label']): ?>
      <p class="sort-detail__college"><?= h($cap['cat_label']) ?></p>
    <?php endif ?>
  </div>

  <?php if ($cap['cap_description']): ?>
    <div class="sort-detail__description" style="margin:.75rem 0;">
      <?= $cap['cap_description'] ?>
    </div>
  <?php endif ?>

  <?php // ---- Classes utilisant cette capacité ?>
  <?php if (!empty($classes)): ?>
    <div class="capacite-detail__usages" style="margin-top:.75rem;">
      <div class="sort-detail__label" style="margin-bottom:.3rem;">Classes</div>
      <?php
      // Regrouper par classe
      $parClasse = [];
      foreach ($classes as $row):
        $cla_id = (int)$row['cla_id'];
        if (!isset($parClasse[$cla_id])):
          $parClasse[$cla_id] = ['nom' => $row['cla_nom'], 'niveaux' => []];
        endif;
        $niv = 'niv. ' . (int)$row['cc_niveau'];
        if ($row['cc_precision']) $niv .= ' (' . $row['cc_precision'] . ')';
        $parClasse[$cla_id]['niveaux'][] = $niv;
      endforeach;
      ?>
      <ul style="margin:.25rem 0; padding-left:1.2rem; font-size:.9rem;">
        <?php foreach ($parClasse as $entry): ?>
          <li>
            <strong><?= h($entry['nom']) ?></strong>
            — <?= implode(', ', $entry['niveaux']) ?>
          </li>
        <?php endforeach ?>
      </ul>
    </div>
  <?php endif ?>

  <?php // ---- Races utilisant cette capacité ?>
  <?php if (!empty($races)): ?>
    <div class="capacite-detail__usages" style="margin-top:.5rem;">
      <div class="sort-detail__label" style="margin-bottom:.3rem;">Races</div>
      <p style="font-size:.9rem; margin:.25rem 0;">
        <?= implode(', ', array_map(fn($r) => h($r['ra_nom']), $races)) ?>
      </p>
    </div>
  <?php endif ?>

</div>
