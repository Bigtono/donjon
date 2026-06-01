<?php
// campagnes/index.php — Liste des campagnes du MJ courant
// Liste dédiée (pas le moteur compendium-liste) : scope strict par propriétaire.
require_once '../include/db.php';
require_once '../include/auth.php';
require_once '../include/helpers.php';

requireAuth();

$page_title = 'Campagnes';
$js_module  = 'campagne';
$css_module = 'campagnes';

$j_id = (int)$_SESSION['j_id'];

// Campagnes du joueur (actives uniquement), avec ruleset, univers et compteurs.
$stmt = $db->prepare('
  SELECT camp.camp_id,
         camp.camp_nom,
         camp.camp_resume,
         camp.camp_date_creation,
         var.var_valeur AS ruleset_label,
         un.un_nom       AS univers_nom,
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
  <button class="btn btn-primary btn-sm" onclick="campagneListe.nouvelle()">
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
          <th>Nom</th>
          <th class="camp-liste__col-sec">Ruleset</th>
          <th class="camp-liste__col-sec">Univers</th>
          <th class="camp-liste__col-num">Scénarios</th>
          <th class="camp-liste__col-num">Personnages</th>
        </tr>
      </thead>
      <tbody>
        <?php foreach ($campagnes as $camp): ?>
          <tr class="camp-liste__row"
              onclick="campagneListe.ouvrir(<?= (int)$camp['camp_id'] ?>)">
            <td class="camp-liste__nom">
              <?= h($camp['camp_nom']) ?>
              <?php if (!empty($camp['camp_resume'])): ?>
                <span class="camp-liste__resume"><?= h($camp['camp_resume']) ?></span>
              <?php endif ?>
            </td>
            <td class="camp-liste__col-sec"><?= h($camp['ruleset_label'] ?? '') ?></td>
            <td class="camp-liste__col-sec">
              <?= $camp['univers_nom'] ? h($camp['univers_nom']) : '<span class="text-muted">—</span>' ?>
            </td>
            <td class="camp-liste__col-num"><?= (int)$camp['nb_scenarios'] ?></td>
            <td class="camp-liste__col-num"><?= (int)$camp['nb_personnages'] ?></td>
          </tr>
        <?php endforeach ?>
      </tbody>
    </table>
  </div>

<?php endif ?>

<?php
require_once '../include/footer.php';
?>
