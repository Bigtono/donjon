<?php
// include/ajax/detail-pp-sub/opposition.php
// Fiche détail d'une opposition en sous-panneau (#detail-pp-sub).
// Paramètres GET : id (int) — opp_id

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
  SELECT opp.*,
         re.re_id, re.re_nom,
         scc.scc_id,
         sce.sce_id,
         camp.camp_id
  FROM   dd_oppositions opp
  JOIN   dd_rencontres re ON re.re_id = opp.opp_re_id
  JOIN   dd_scenarios_chapitres scc ON scc.scc_id = re.re_scc_id
  JOIN   dd_scenarios sce  ON sce.sce_id  = scc.scc_sce_id
  JOIN   dd_campagnes camp ON camp.camp_id = sce.sce_camp_id
  WHERE  opp.opp_id = ? AND opp.opp_supprime = 0
    AND  re.re_supprime = 0 AND scc.scc_supprime = 0
    AND  sce.sce_supprime = 0 AND camp.camp_supprime = 0
');
$stmt->execute([$id]);
$opp = $stmt->fetch();

if (!$opp):
  http_response_code(404);
  echo '<p class="erreur">Opposition introuvable.</p>';
  exit;
endif;

if (!isMJ($db, (int)$opp['camp_id'])):
  http_response_code(403);
  echo '<p class="erreur">Accès refusé.</p>';
  exit;
endif;

$base_modifier = BASE_URL . '/include/ajax/modifier';
?>

<div class="camp-detail" data-opp-id="<?= $id ?>" data-re-id="<?= (int)$opp['re_id'] ?>">

  <div class="camp-detail__header">
    <h2 class="camp-detail__nom">
      <?= h($opp['opp_nom']) ?>
      <button class="sort-detail__edit-btn"
              onclick="actualiserPageModif('<?= $base_modifier ?>/opposition.php',
                       {id:<?= $id ?>, re_id:<?= (int)$opp['re_id'] ?>})"
              title="Modifier cette opposition">
        <i class="fa fa-edit"></i>
      </button>
    </h2>
    <?php if (!empty($opp['opp_mocat_nom'])): ?>
      <span class="text-muted"><?= h($opp['opp_mocat_nom']) ?></span>
    <?php endif ?>
  </div>

  <?php if (!empty($opp['opp_stats'])): ?>
    <pre class="opp-stats"><?= h($opp['opp_stats']) ?></pre>
  <?php else: ?>
    <p class="text-muted">Aucune statistique renseignée.</p>
  <?php endif ?>

  <div class="camp-detail__actions">
    <button class="btn btn-danger btn-sm"
            onclick="campOppDemanderSuppression(<?= $id ?>, <?= (int)$opp['re_id'] ?>)">
      <i class="fa fa-trash"></i> Supprimer
    </button>
  </div>

</div>
