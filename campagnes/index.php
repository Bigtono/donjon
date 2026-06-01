<?php
// campagnes/index.php — Liste des campagnes du MJ courant.
// Liste dédiée (pas le moteur compendium-liste) : scope strict par propriétaire.
require_once '../include/db.php';
require_once '../include/auth.php';
require_once '../include/helpers.php';

requireAuth();

$page_title = 'Campagnes';
$js_module  = 'campagne';
$css_module = 'campagnes';

$j_id = (int)$_SESSION['j_id'];

$stmt = $db->prepare('
  SELECT camp.camp_id,
         camp.camp_nom,
         camp.camp_resume,
         var.var_valeur AS ruleset_label,
         un.un_nom      AS univers_nom,
         (SELECT COUNT(*) FROM dd_scenarios sce
           WHERE sce.sce_camp_id = camp.camp_id AND sce.sce_supprime = 0) AS nb_scenarios,
         (SELECT COUNT(*) FROM dd_campagnes_personnages cp
           WHERE cp.cp_camp_id = camp.camp_id) AS nb_personnages
  FROM   dd_campagnes camp
  LEFT JOIN dd_variables var ON var.var_id = camp.camp_ruleset_var_id
  LEFT JOIN dd_univers   un  ON un.un_id   = camp.camp_un_id
  WHERE  camp.camp_j_id = ? AND camp.camp_supprime = 0
  ORDER  BY camp.camp_nom ASC
');
$stmt->execute([$j_id]);
$campagnes = $stmt->fetchAll();

require_once '../include/header.php';
?>

<script>
  var campUrlDetail   = <?= json_encode(BASE_URL . '/include/ajax/detail-pp/campagne.php') ?>;
  var campUrlModifier = <?= json_encode(BASE_URL . '/include/ajax/modifier/campagne.php') ?>;
  var campUrlEnreg    = <?= json_encode(BASE_URL . '/campagnes/enregistrement.php?ajax=1') ?>;
</script>

<div class="flex-between mb-md">
  <h1>Campagnes</h1>
  <button class="btn btn-primary btn-sm" onclick="ouvrirModifier(campUrlModifier, 0)">
    <i class="fa fa-plus"></i> Nouvelle campagne
  </button>
</div>

<?php if (empty($campagnes)): ?>

  <p class="text-muted">Aucune campagne pour le moment. Créez-en une pour commencer.</p>

<?php else: ?>

  <div class="table-scroll">
    <table class="camp-liste">
      <thead>
        <tr>
          <th class="col-action"></th>
          <th>Nom</th>
          <th class="camp-liste__col-sec">Ruleset</th>
          <th class="camp-liste__col-sec">Univers</th>
          <th class="camp-liste__col-num">Scénarios</th>
          <th class="camp-liste__col-num">Personnages</th>
        </tr>
      </thead>
      <tbody>

        <?php foreach ($campagnes as $camp): ?>
          <?php $cid = (int)$camp['camp_id'] ?>

          <tr id="camp-row-<?= $cid ?>">

            <!-- Menu contextuel -->
            <td class="col-action">
              <div class="comp-menu-ligne">
                <button class="btn btn-icon btn-sm comp-menu-btn"
                        onclick="campToggleMenu(<?= $cid ?>)"
                        title="Actions">⋮</button>
                <div id="comp-menu-<?= $cid ?>" class="comp-menu-dropdown noDisplay">
                  <button class="comp-menu-item"
                          onclick="campToggleMenu(<?= $cid ?>); ouvrirModifier(campUrlModifier, <?= $cid ?>)">
                    <i class="fa fa-edit"></i> Modifier
                  </button>
                  <button class="comp-menu-item comp-menu-item--danger"
                          onclick="campToggleMenu(<?= $cid ?>); campDemanderSuppression(<?= $cid ?>)">
                    <i class="fa fa-trash"></i> Supprimer
                  </button>
                </div>
              </div>
              <!-- Template de confirmation inline -->
              <div id="camp-confirm-<?= $cid ?>" class="comp-confirm-suppr noDisplay">
                <span>Supprimer « <?= h($camp['camp_nom']) ?> » et tout son contenu ?</span>
                <button class="btn btn-danger btn-sm"
                        onclick="campConfirmerSuppression(<?= $cid ?>)">Oui</button>
                <button class="btn btn-secondary btn-sm"
                        onclick="campAnnulerSuppression(<?= $cid ?>)">Non</button>
              </div>
            </td>

            <!-- Cellules données — clic → fiche détail -->
            <td class="camp-liste__nom"
                onclick="actualiserPage(campUrlDetail, {id: <?= $cid ?>}, 'liste')"
                style="cursor:pointer">
              <?= h($camp['camp_nom']) ?>
              <?php if (!empty($camp['camp_resume'])): ?>
                <span class="camp-liste__resume"><?= h($camp['camp_resume']) ?></span>
              <?php endif ?>
            </td>
            <td class="camp-liste__col-sec"
                onclick="actualiserPage(campUrlDetail, {id: <?= $cid ?>}, 'liste')"
                style="cursor:pointer">
              <?= h($camp['ruleset_label'] ?? '') ?>
            </td>
            <td class="camp-liste__col-sec"
                onclick="actualiserPage(campUrlDetail, {id: <?= $cid ?>}, 'liste')"
                style="cursor:pointer">
              <?= $camp['univers_nom'] ? h($camp['univers_nom']) : '<span class="text-muted">—</span>' ?>
            </td>
            <td class="camp-liste__col-num"
                onclick="actualiserPage(campUrlDetail, {id: <?= $cid ?>}, 'liste')"
                style="cursor:pointer">
              <?= (int)$camp['nb_scenarios'] ?>
            </td>
            <td class="camp-liste__col-num"
                onclick="actualiserPage(campUrlDetail, {id: <?= $cid ?>}, 'liste')"
                style="cursor:pointer">
              <?= (int)$camp['nb_personnages'] ?>
            </td>

          </tr>

        <?php endforeach ?>

      </tbody>
    </table>
  </div>

<?php endif ?>

<?php require_once '../include/footer.php'; ?>
