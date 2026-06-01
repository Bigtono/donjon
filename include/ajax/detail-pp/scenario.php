<?php
// include/ajax/detail-pp/scenario.php
// Retourne le HTML de détail d'un scénario pour #detail-pp-sub.
// Paramètres GET : id (int) — sce_id

require_once __DIR__ . '/../../db.php';
require_once __DIR__ . '/../../auth.php';
require_once __DIR__ . '/../../helpers.php';

requireAuth();

$id = intParam($_GET['id'] ?? 0);
if (!$id):
  http_response_code(400);
  echo '<p class="erreur">Identifiant manquant.</p>';
  exit;
endif;

$stmt = $db->prepare('
  SELECT sce.*, camp.camp_id, camp.camp_nom
  FROM   dd_scenarios sce
  JOIN   dd_campagnes camp ON camp.camp_id = sce.sce_camp_id
  WHERE  sce.sce_id = ? AND sce.sce_supprime = 0 AND camp.camp_supprime = 0
');
$stmt->execute([$id]);
$sce = $stmt->fetch();

if (!$sce):
  http_response_code(404);
  echo '<p class="erreur">Scénario introuvable.</p>';
  exit;
endif;

if (!isMJ($db, (int)$sce['camp_id'])):
  http_response_code(403);
  echo '<p class="erreur">Accès refusé.</p>';
  exit;
endif;

// Chapitres avec compteur rencontres
$stmt_scc = $db->prepare('
  SELECT scc.scc_id, scc.scc_nom, scc.scc_abreviation, scc.scc_ordre,
         COUNT(re.re_id) AS nb_rencontres
  FROM   dd_scenarios_chapitres scc
  LEFT JOIN dd_rencontres re ON re.re_scc_id = scc.scc_id AND re.re_supprime = 0
  WHERE  scc.scc_sce_id = ? AND scc.scc_supprime = 0
  GROUP  BY scc.scc_id
  ORDER  BY scc.scc_ordre ASC, scc.scc_nom ASC
');
$stmt_scc->execute([$id]);
$chapitres = $stmt_scc->fetchAll();

$base_enreg    = BASE_URL . '/campagnes/enregistrement.php?ajax=1';
$base_modifier = BASE_URL . '/include/ajax/modifier';
?>

<div class="camp-detail" data-sce-id="<?= $id ?>" data-camp-id="<?= (int)$sce['camp_id'] ?>">

  <!-- En-tête -->
  <div class="camp-detail__header">
    <p class="camp-detail__breadcrumb">
      <i class="fa fa-scroll"></i> <?= h($sce['camp_nom']) ?>
    </p>
    <h2 class="camp-detail__nom">
      <?= h($sce['sce_nom']) ?>
      <button class="sort-detail__edit-btn"
              onclick="ouvrirModifier('<?= $base_modifier ?>/scenario.php?camp_id=<?= (int)$sce['camp_id'] ?>', <?= $id ?>)"
              title="Modifier ce scénario">
        <i class="fa fa-edit"></i>
      </button>
    </h2>
    <?php if ((int)$sce['sce_ordre'] > 0): ?>
      <span class="text-muted" style="font-size:.85em;">Ordre : <?= (int)$sce['sce_ordre'] ?></span>
    <?php endif ?>
  </div>

  <?php if (!empty($sce['sce_description'])): ?>
    <div class="camp-detail__description"><?= $sce['sce_description'] ?></div>
  <?php endif ?>

  <!-- Chapitres -->
  <div class="camp-detail__section">
    <div class="camp-section__header">
      <h3 class="camp-detail__section-title">Chapitres</h3>
      <button class="btn btn-primary btn-sm"
              onclick="actualiserPageModif('<?= $base_modifier ?>/chapitre.php?sce_id=<?= $id ?>', {id:0})">
        <i class="fa fa-plus"></i> Nouveau
      </button>
    </div>

    <?php if (empty($chapitres)): ?>
      <p class="text-muted">Aucun chapitre pour le moment.</p>
    <?php else: ?>
      <table class="camp-sous-liste">
        <thead>
          <tr>
            <th class="col-action"></th>
            <th>Chapitre</th>
            <th style="width:60px">Abrév.</th>
            <th class="camp-liste__col-num">Rencontres</th>
          </tr>
        </thead>
        <tbody>
          <?php foreach ($chapitres as $scc): ?>
            <?php $cid = (int)$scc['scc_id'] ?>

            <tr id="camp-scc-row-<?= $cid ?>">

              <!-- Menu contextuel -->
              <td class="col-action">
                <div class="comp-menu-ligne">
                  <button class="btn btn-icon btn-sm comp-menu-btn"
                          onclick="campToggleMenu('scc-<?= $cid ?>')"
                          title="Actions">⋮</button>
                  <div id="comp-menu-scc-<?= $cid ?>" class="comp-menu-dropdown noDisplay">
                    <button class="comp-menu-item"
                            onclick="campToggleMenu('scc-<?= $cid ?>');
                                     ouvrirModifier('<?= $base_modifier ?>/chapitre.php?sce_id=<?= $id ?>', <?= $cid ?>)">
                      <i class="fa fa-edit"></i> Modifier
                    </button>
                    <button class="comp-menu-item comp-menu-item--danger"
                            onclick="campToggleMenu('scc-<?= $cid ?>');
                                     campSccDemanderSuppression(<?= $cid ?>, <?= $id ?>)">
                      <i class="fa fa-trash"></i> Supprimer
                    </button>
                  </div>
                </div>
                <!-- Template confirmation -->
                <div id="camp-scc-confirm-<?= $cid ?>" class="comp-confirm-suppr noDisplay">
                  <span>Supprimer « <?= h($scc['scc_nom']) ?> » ?</span>
                  <button class="btn btn-danger btn-sm"
                          onclick="campSccConfirmerSuppression(<?= $cid ?>)">Oui</button>
                  <button class="btn btn-secondary btn-sm"
                          onclick="campSccAnnulerSuppression(<?= $cid ?>)">Non</button>
                </div>
              </td>

              <td><?= h($scc['scc_nom']) ?></td>
              <td class="text-muted" style="font-size:.85em;">
                <?= $scc['scc_abreviation'] ? h($scc['scc_abreviation']) : '—' ?>
              </td>
              <td class="camp-liste__col-num"><?= (int)$scc['nb_rencontres'] ?></td>

            </tr>

          <?php endforeach ?>
        </tbody>
      </table>
    <?php endif ?>
  </div>

  <!-- Rencontres — à venir SP3 -->
  <div class="camp-detail__section">
    <h3 class="camp-detail__section-title">Rencontres</h3>
    <p class="text-muted"><em>Gestion des rencontres — à venir.</em></p>
  </div>

</div>
