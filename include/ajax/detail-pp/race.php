<?php
// include/ajax/detail-pp/race.php
// Retourne le HTML de détail d'une race pour #detail-pp
// Appelé via actualiserPage() — pas de layout header/footer
//
// Paramètres GET :
//   id (int) — ra_id de la race à afficher

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

// ============================================================
// Données principales de la race
// ============================================================

$stmt = $db->prepare('
  SELECT ra.*,
         rat.rat_nom,
         res.res_nom,
         camp.camp_nom,
         var.var_valeur AS ruleset_label
  FROM   dd_races ra
  LEFT JOIN dd_race_type  rat  ON rat.rat_id   = ra.ra_rat_id
  LEFT JOIN dd_ressources res  ON res.res_id   = ra.ra_res_id
  LEFT JOIN dd_campagnes  camp ON camp.camp_id = ra.ra_camp_id
  LEFT JOIN dd_variables  var  ON var.var_id   = ra.ra_ruleset_var_id
  WHERE  ra.ra_id = ?
');
$stmt->execute([$id]);
$ra = $stmt->fetch();

if (!$ra):
  http_response_code(404);
  echo '<p class="erreur">Race introuvable.</p>';
  exit;
endif;

// ============================================================
// Capacités raciales (ordonnées par cr_ordre)
// ============================================================

$stmt_cap = $db->prepare('
  SELECT cap.cap_nom, cap.cap_description, cap.cap_type
  FROM   dd_race_capacite cr
  JOIN   dd_capacites_speciales cap ON cap.cap_id = cr.cr_cap_id
  WHERE  cr.cr_ra_id = ?
  ORDER  BY cr.cr_ordre ASC, cap.cap_nom ASC
');
$stmt_cap->execute([$id]);
$capacites = $stmt_cap->fetchAll();
?>

<div class="race-detail">

  <?php // ---- En-tête + bouton Modifier ?>
  <div class="sort-detail__header">
    <h2 class="sort-detail__nom">
      <?= h($ra['ra_nom']) ?>
      <?php if (canEditCompendium()): ?>
        <button class="sort-detail__edit-btn"
                onclick="ouvrirModifier('<?= BASE_URL ?>/include/ajax/modifier/race.php', <?= $id ?>)"
                title="Modifier cette race">
          <i class="fa fa-edit"></i>
        </button>
      <?php endif ?>
    </h2>

    <?php if ($ruleset === 'DD3.5'): ?>
      <p class="sort-detail__college"><?= h($ra['rat_nom']) ?></p>
    <?php endif ?>
  </div>

  <?php // ---- Corps de la fiche ?>
  <div class="sort-detail__body">

    <?php // ---- Modificateur de niveau [DD3.5] ?>
    <?php if ($ruleset === 'DD3.5' && (int)$ra['ra_mod_niveau'] > 0): ?>
      <div class="sort-detail__row">
        <span class="sort-detail__label">Modificateur de niveau</span>
        <span class="sort-detail__value">+<?= (int)$ra['ra_mod_niveau'] ?></span>
      </div>
    <?php endif ?>

  </div>

  <?php // ---- Description ?>
  <?php if ($ra['ra_description']): ?>
    <div class="sort-detail__description" style="margin: 1rem 0;">
      <?= $ra['ra_description'] ?>
    </div>
  <?php endif ?>

  <?php // ---- Capacités raciales ?>
  <?php if (!empty($capacites)): ?>
    <div class="race-detail__capacites" style="margin-top: 1rem;">
      <?php foreach ($capacites as $cap): ?>
        <div class="race-detail__capacite" style="margin-bottom: 0.75rem;">
          <div class="race-detail__capacite-nom">
            <strong><?= h($cap['cap_nom']) ?></strong>
            <?php if ($ruleset === 'DD3.5' && $cap['cap_type']): ?>
              <span class="race-detail__cap-type">(<?= h($cap['cap_type']) ?>)</span>
            <?php endif ?>
          </div>
          <?php if ($cap['cap_description']): ?>
            <div class="race-detail__capacite-desc">
              <?= $cap['cap_description'] ?>
            </div>
          <?php endif ?>
        </div>
      <?php endforeach ?>
    </div>
  <?php endif ?>

  <?php // ---- Pied de fiche : source, campagne, ruleset ?>
  <div class="sort-detail__footer" style="margin-top: 1rem;">
    <span class="sort-detail__source">
      <i class="fa fa-book"></i> <?= h($ra['res_nom']) ?>
    </span>
    <?php if ($ra['ra_camp_id'] && $ra['camp_nom']): ?>
      <span class="sort-detail__homebrew">
        <i class="fa fa-flask"></i> <?= h($ra['camp_nom']) ?>
      </span>
    <?php endif ?>
    <span class="sort-detail__ruleset">
      <?= h($ra['ruleset_label']) ?>
    </span>
  </div>

</div>
