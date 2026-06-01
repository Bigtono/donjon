<?php
// include/ajax/detail-pp/campagne.php
// Retourne le HTML de détail d'une campagne pour #detail-pp.
// Paramètres GET : id (int) — camp_id

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
  SELECT camp.*, var.var_valeur AS ruleset_label, un.un_nom AS univers_nom
  FROM   dd_campagnes camp
  LEFT JOIN dd_variables var ON var.var_id = camp.camp_ruleset_var_id
  LEFT JOIN dd_univers   un  ON un.un_id   = camp.camp_un_id
  WHERE  camp.camp_id = ? AND camp.camp_supprime = 0
');
$stmt->execute([$id]);
$camp = $stmt->fetch();

if (!$camp):
  http_response_code(404);
  echo '<p class="erreur">Campagne introuvable.</p>';
  exit;
endif;

if (!isMJ($db, $id)):
  http_response_code(403);
  echo '<p class="erreur">Accès refusé.</p>';
  exit;
endif;

// Sources
$stmt_src = $db->prepare('
  SELECT res.res_nom FROM dd_campagnes_sources cs
  JOIN   dd_ressources res ON res.res_id = cs.cs_res_id
  WHERE  cs.cs_camp_id = ? ORDER BY res.res_nom ASC
');
$stmt_src->execute([$id]);
$sources = $stmt_src->fetchAll(PDO::FETCH_COLUMN);

// Scénarios avec compteurs
$stmt_sce = $db->prepare('
  SELECT sce.sce_id, sce.sce_nom, sce.sce_ordre,
         COUNT(DISTINCT scc.scc_id) AS nb_chapitres,
         COUNT(DISTINCT re.re_id)   AS nb_rencontres
  FROM   dd_scenarios sce
  LEFT JOIN dd_scenarios_chapitres scc ON scc.scc_sce_id = sce.sce_id AND scc.scc_supprime = 0
  LEFT JOIN dd_rencontres re ON re.re_scc_id = scc.scc_id AND re.re_supprime = 0
  WHERE  sce.sce_camp_id = ? AND sce.sce_supprime = 0
  GROUP  BY sce.sce_id
  ORDER  BY sce.sce_ordre ASC, sce.sce_nom ASC
');
$stmt_sce->execute([$id]);
$scenarios = $stmt_sce->fetchAll();

$base_enreg    = BASE_URL . '/campagnes/enregistrement.php?ajax=1';
$base_modifier = BASE_URL . '/include/ajax/modifier';
$base_detail   = BASE_URL . '/include/ajax/detail-pp';
?>

<div class="camp-detail" data-camp-id="<?= $id ?>">

  <!-- En-tête -->
  <div class="camp-detail__header">
    <h2 class="camp-detail__nom">
      <?= h($camp['camp_nom']) ?>
      <button class="sort-detail__edit-btn"
              onclick="ouvrirModifier('<?= $base_modifier ?>/campagne.php', <?= $id ?>)"
              title="Modifier cette campagne">
        <i class="fa fa-edit"></i>
      </button>
    </h2>
    <div class="camp-detail__meta">
      <span class="camp-detail__ruleset"><?= h($camp['ruleset_label'] ?? '') ?></span>
      <?php if ($camp['univers_nom']): ?>
        <span class="camp-detail__univers">
          <i class="fa fa-globe"></i> <?= h($camp['univers_nom']) ?>
        </span>
      <?php endif ?>
    </div>
  </div>

  <?php if (!empty($camp['camp_resume'])): ?>
    <p class="camp-detail__resume"><?= h($camp['camp_resume']) ?></p>
  <?php endif ?>

  <?php if (!empty($camp['camp_description'])): ?>
    <div class="camp-detail__description"><?= $camp['camp_description'] ?></div>
  <?php endif ?>

  <!-- Sources -->
  <div class="camp-detail__section">
    <h3 class="camp-detail__section-title">Sources</h3>
    <?php if (empty($sources)): ?>
      <p class="text-muted">Aucune source spécifique — la sélection personnelle s'applique.</p>
    <?php else: ?>
      <ul class="camp-detail__sources">
        <?php foreach ($sources as $src_nom): ?>
          <li><i class="fa fa-book"></i> <?= h($src_nom) ?></li>
        <?php endforeach ?>
      </ul>
    <?php endif ?>
  </div>

  <!-- Scénarios -->
  <div class="camp-detail__section">
    <div class="camp-section__header">
      <h3 class="camp-detail__section-title">Scénarios</h3>
      <button class="btn btn-primary btn-sm"
              onclick="actualiserPageModif('<?= $base_modifier ?>/scenario.php?camp_id=<?= $id ?>', {id:0})">
        <i class="fa fa-plus"></i> Nouveau
      </button>
    </div>

    <?php if (empty($scenarios)): ?>
      <p class="text-muted">Aucun scénario pour le moment.</p>
    <?php else: ?>
      <table class="camp-sous-liste">
        <thead>
          <tr>
            <th class="col-action"></th>
            <th>Scénario</th>
            <th class="camp-liste__col-num">Chapitres</th>
            <th class="camp-liste__col-num">Rencontres</th>
          </tr>
        </thead>
        <tbody>
          <?php foreach ($scenarios as $sce): ?>
            <?php $sid = (int)$sce['sce_id'] ?>

            <tr id="camp-sce-row-<?= $sid ?>">

              <!-- Menu contextuel -->
              <td class="col-action">
                <div class="comp-menu-ligne">
                  <button class="btn btn-icon btn-sm comp-menu-btn"
                          onclick="campToggleMenu('sce-<?= $sid ?>')"
                          title="Actions">⋮</button>
                  <div id="comp-menu-sce-<?= $sid ?>" class="comp-menu-dropdown noDisplay">
                    <button class="comp-menu-item"
                            onclick="campToggleMenu('sce-<?= $sid ?>');
                                     ouvrirModifier('<?= $base_modifier ?>/scenario.php?camp_id=<?= $id ?>', <?= $sid ?>)">
                      <i class="fa fa-edit"></i> Modifier
                    </button>
                    <button class="comp-menu-item comp-menu-item--danger"
                            onclick="campToggleMenu('sce-<?= $sid ?>');
                                     campSceDemanderSuppression(<?= $sid ?>, <?= $id ?>)">
                      <i class="fa fa-trash"></i> Supprimer
                    </button>
                  </div>
                </div>
                <!-- Template confirmation -->
                <div id="camp-sce-confirm-<?= $sid ?>" class="comp-confirm-suppr noDisplay">
                  <span>Supprimer « <?= h($sce['sce_nom']) ?> » ?</span>
                  <button class="btn btn-danger btn-sm"
                          onclick="campSceConfirmerSuppression(<?= $sid ?>)">Oui</button>
                  <button class="btn btn-secondary btn-sm"
                          onclick="campSceAnnulerSuppression(<?= $sid ?>)">Non</button>
                </div>
              </td>

              <!-- Cellule nom — clic → sub-panel scénario -->
              <td onclick="actualiserPageSub('<?= $base_detail ?>/scenario.php', {id:<?= $sid ?>})"
                  style="cursor:pointer">
                <?= h($sce['sce_nom']) ?>
              </td>
              <td class="camp-liste__col-num"
                  onclick="actualiserPageSub('<?= $base_detail ?>/scenario.php', {id:<?= $sid ?>})"
                  style="cursor:pointer">
                <?= (int)$sce['nb_chapitres'] ?>
              </td>
              <td class="camp-liste__col-num"
                  onclick="actualiserPageSub('<?= $base_detail ?>/scenario.php', {id:<?= $sid ?>})"
                  style="cursor:pointer">
                <?= (int)$sce['nb_rencontres'] ?>
              </td>

            </tr>

          <?php endforeach ?>
        </tbody>
      </table>
    <?php endif ?>
  </div>

  <!-- Suppression de la campagne -->
  <div class="camp-detail__actions">
    <button class="btn btn-danger btn-sm"
            data-camp-id="<?= $id ?>"
            data-camp-nom="<?= h($camp['camp_nom']) ?>"
            onclick="campagneListe.supprimer(
              parseInt(this.dataset.campId),
              this.dataset.campNom
            )">
      <i class="fa fa-trash"></i> Supprimer la campagne
    </button>
  </div>

</div>
