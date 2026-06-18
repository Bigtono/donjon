<?php
// include/ajax/detail-pp/rencontre.php
// Retourne le HTML de détail d'une rencontre pour #detail-pp (navigation interne).
// Paramètres GET : id (int) — re_id

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
  SELECT re.*,
         scc.scc_id, scc.scc_nom,
         sce.sce_id, sce.sce_nom,
         camp.camp_id, camp.camp_nom
  FROM   dd_rencontres re
  JOIN   dd_scenarios_chapitres scc ON scc.scc_id   = re.re_scc_id
  JOIN   dd_scenarios           sce ON sce.sce_id   = scc.scc_sce_id
  JOIN   dd_campagnes          camp ON camp.camp_id = sce.sce_camp_id
  WHERE  re.re_id = ? AND re.re_supprime = 0
    AND  scc.scc_supprime = 0
    AND  sce.sce_supprime = 0
    AND  camp.camp_supprime = 0
');
$stmt->execute([$id]);
$re = $stmt->fetch();

if (!$re):
  http_response_code(404);
  echo '<p class="erreur">Rencontre introuvable.</p>';
  exit;
endif;

if (!isMJ($db, (int)$re['camp_id'])):
  http_response_code(403);
  echo '<p class="erreur">Accès refusé.</p>';
  exit;
endif;

// Oppositions de la rencontre (SP3 — affichage simple pour l'instant)
$stmt_opp = $db->prepare('
  SELECT opp_id, opp_nom, opp_mocat_nom
  FROM   dd_oppositions
  WHERE  opp_re_id = ?
  ORDER  BY opp_nom ASC
');
$stmt_opp->execute([$id]);
$oppositions = $stmt_opp->fetchAll();

$base_modifier = BASE_URL . '/include/ajax/modifier';
?>

<div class="camp-detail" data-re-id="<?= $id ?>"
     data-scc-id="<?= (int)$re['scc_id'] ?>"
     data-sce-id="<?= (int)$re['sce_id'] ?>"
     data-camp-id="<?= (int)$re['camp_id'] ?>">

  <!-- En-tête -->
  <div class="camp-detail__header">
    <h2 class="camp-detail__nom">
      <?= h($re['re_nom']) ?>
      <?php if (!empty($re['re_code'])): ?>
        <span class="text-muted" style="font-size:.75em; font-weight:400;">
          [<?= h($re['re_code']) ?>]
        </span>
      <?php endif ?>
      <button class="sort-detail__edit-btn"
              onclick="actualiserPageModif('<?= $base_modifier ?>/rencontre.php',
                       {id:<?= $id ?>, scc_id:<?= (int)$re['scc_id'] ?>})"
              title="Modifier cette rencontre">
        <i class="fa fa-edit"></i>
      </button>
    </h2>
  </div>

  <!-- Composition (champ texte mis en évidence) -->
  <?php if (!empty($re['re_composition'])): ?>
    <div class="camp-rencontre__composition">
      <?= $re['re_composition'] ?>
    </div>
  <?php endif ?>

  <!-- Description -->
  <?php if (!empty($re['re_description'])): ?>
    <div class="camp-detail__description"><?= $re['re_description'] ?></div>
  <?php endif ?>

  <!-- Oppositions -->
  <div class="camp-detail__section">
    <h3 class="camp-detail__section-title">Oppositions</h3>
    <?php if (empty($oppositions)): ?>
      <p class="text-muted">Aucune opposition — à venir (SP3).</p>
    <?php else: ?>
      <table class="camp-sous-liste">
        <thead>
          <tr>
            <th>Nom</th>
            <th>Type</th>
          </tr>
        </thead>
        <tbody>
          <?php foreach ($oppositions as $opp): ?>
            <tr onclick="actualiserPageSub('<?= BASE_URL ?>/include/ajax/detail-pp-sub/opposition.php',
                         {id:<?= (int)$opp['opp_id'] ?>})"
                style="cursor:pointer">
              <td><?= h($opp['opp_nom']) ?></td>
              <td class="text-muted"><?= $opp['opp_mocat_nom'] ? h($opp['opp_mocat_nom']) : '—' ?></td>
            </tr>
          <?php endforeach ?>
        </tbody>
      </table>
    <?php endif ?>
  </div>

</div>
