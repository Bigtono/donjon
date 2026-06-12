<?php
// include/ajax/detail-pp/chapitre.php
// Retourne le HTML de détail d'un chapitre pour #detail-pp (navigation interne).
// Paramètres GET : id (int) — scc_id

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
  SELECT scc.*,
         sce.sce_id, sce.sce_nom,
         camp.camp_id, camp.camp_nom
  FROM   dd_scenarios_chapitres scc
  JOIN   dd_scenarios sce   ON sce.sce_id   = scc.scc_sce_id
  JOIN   dd_campagnes camp  ON camp.camp_id  = sce.sce_camp_id
  WHERE  scc.scc_id = ? AND scc.scc_supprime = 0
    AND  sce.sce_supprime = 0 AND camp.camp_supprime = 0
');
$stmt->execute([$id]);
$scc = $stmt->fetch();

if (!$scc):
  http_response_code(404);
  echo '<p class="erreur">Chapitre introuvable.</p>';
  exit;
endif;

if (!isMJ($db, (int)$scc['camp_id'])):
  http_response_code(403);
  echo '<p class="erreur">Accès refusé.</p>';
  exit;
endif;

// Rencontres du chapitre
$stmt_re = $db->prepare('
  SELECT re_id, re_nom, re_code,
         (SELECT COUNT(*) FROM dd_oppositions WHERE opp_re_id = re.re_id) AS nb_oppositions
  FROM   dd_rencontres re
  WHERE  re.re_scc_id = ? AND re.re_supprime = 0
  ORDER  BY re.re_nom ASC
');
$stmt_re->execute([$id]);
$rencontres = $stmt_re->fetchAll();

$base_modifier = BASE_URL . '/include/ajax/modifier';
?>

<div class="camp-detail" data-scc-id="<?= $id ?>"
     data-sce-id="<?= (int)$scc['sce_id'] ?>"
     data-camp-id="<?= (int)$scc['camp_id'] ?>">

  <!-- En-tête -->
  <div class="camp-detail__header">
    <h2 class="camp-detail__nom">
      <?= h($scc['scc_nom']) ?>
      <?php if (!empty($scc['scc_abreviation'])): ?>
        <span class="text-muted" style="font-size:.75em; font-weight:400;">
          (<?= h($scc['scc_abreviation']) ?>)
        </span>
      <?php endif ?>
      <button class="sort-detail__edit-btn"
              onclick="actualiserPageModif('<?= $base_modifier ?>/chapitre.php',
                       {id:<?= $id ?>, sce_id:<?= (int)$scc['sce_id'] ?>})"
              title="Modifier ce chapitre">
        <i class="fa fa-edit"></i>
      </button>
    </h2>
    <?php if ((int)$scc['scc_ordre'] > 0): ?>
      <span class="text-muted" style="font-size:.85em;">Ordre : <?= (int)$scc['scc_ordre'] ?></span>
    <?php endif ?>
  </div>

  <?php if (!empty($scc['scc_description'])): ?>
    <div class="camp-detail__description"><?= h($scc['scc_description']) ?></div>
  <?php endif ?>

  <!-- Rencontres -->
  <div class="camp-detail__section">
    <div class="camp-section__header">
      <h3 class="camp-detail__section-title">Rencontres</h3>
      <button class="btn btn-primary btn-sm"
              onclick="actualiserPageModif('<?= $base_modifier ?>/rencontre.php',
                       {id:0, scc_id:<?= $id ?>})">
        <i class="fa fa-plus"></i> Nouvelle
      </button>
    </div>

    <?php if (empty($rencontres)): ?>
      <p class="text-muted">Aucune rencontre pour le moment.</p>
    <?php else: ?>
      <table class="camp-sous-liste">
        <thead>
          <tr>
            <th class="col-action"></th>
            <th>Rencontre</th>
            <th style="width:80px">Code</th>
            <th class="camp-liste__col-num">Oppositions</th>
          </tr>
        </thead>
        <tbody>
          <?php foreach ($rencontres as $re): ?>
            <?php $rid = (int)$re['re_id'] ?>

            <tr id="camp-re-row-<?= $rid ?>">

              <!-- Menu contextuel -->
              <td class="col-action">
                <div class="comp-menu-ligne">
                  <button class="btn btn-icon btn-sm comp-menu-btn"
                          onclick="campToggleMenu('re-<?= $rid ?>')"
                          title="Actions">⋮</button>
                  <div id="comp-menu-re-<?= $rid ?>" class="comp-menu-dropdown noDisplay">
                    <button class="comp-menu-item"
                            onclick="campToggleMenu('re-<?= $rid ?>');
                                     actualiserPageModif('<?= $base_modifier ?>/rencontre.php',
                                     {id:<?= $rid ?>, scc_id:<?= $id ?>})">
                      <i class="fa fa-edit"></i> Modifier
                    </button>
                    <button class="comp-menu-item comp-menu-item--danger"
                            onclick="campToggleMenu('re-<?= $rid ?>');
                                     campReDemanderSuppression(<?= $rid ?>, <?= $id ?>)">
                      <i class="fa fa-trash"></i> Supprimer
                    </button>
                  </div>
                </div>
                <!-- Template confirmation -->
                <div id="camp-re-confirm-<?= $rid ?>" class="comp-confirm-suppr noDisplay">
                  <span>Supprimer « <?= h($re['re_nom']) ?> » ?</span>
                  <button class="btn btn-danger btn-sm"
                          onclick="campReConfirmerSuppression(<?= $rid ?>)">Oui</button>
                  <button class="btn btn-secondary btn-sm"
                          onclick="campReAnnulerSuppression(<?= $rid ?>)">Non</button>
                </div>
              </td>

              <!-- Clic → navigation interne vers la fiche rencontre (SP3) -->
              <td style="cursor:pointer"
                  onclick="naviguerDetailPP('<?= BASE_URL ?>/include/ajax/detail-pp/rencontre.php',
                           {id:<?= $rid ?>})">
                <?= h($re['re_nom']) ?>
              </td>
              <td class="text-muted" style="font-size:.85em; cursor:pointer"
                  onclick="naviguerDetailPP('<?= BASE_URL ?>/include/ajax/detail-pp/rencontre.php',
                           {id:<?= $rid ?>})">
                <?= $re['re_code'] ? h($re['re_code']) : '—' ?>
              </td>
              <td class="camp-liste__col-num" style="cursor:pointer"
                  onclick="naviguerDetailPP('<?= BASE_URL ?>/include/ajax/detail-pp/rencontre.php',
                           {id:<?= $rid ?>})">
                <?= (int)$re['nb_oppositions'] ?>
              </td>

            </tr>

          <?php endforeach ?>
        </tbody>
      </table>
    <?php endif ?>
  </div>

</div>
