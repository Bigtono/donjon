<?php
// campagnes/index.php — Liste des campagnes du MJ courant, filtrées par ruleset actif.
// Liste dédiée (pas le moteur compendium-liste) : scope strict par propriétaire.
require_once '../include/db.php';
require_once '../include/auth.php';
require_once '../include/helpers.php';

requireAuth();

$page_title = 'Campagnes';
$js_module  = 'campagne';
$css_module = 'campagnes';

$j_id        = (int)$_SESSION['j_id'];
$ruleset_id  = (int)($_SESSION['ruleset_var_id'] ?? 1);
$ruleset_rep = $_SESSION['rulesetRep'] ?? 'DD3.5';

// Le ruleset d'une campagne est figé à sa création (camp_ruleset_var_id) et
// hérité par tout son contenu — scénarios, chapitres, rencontres, oppositions.
// La liste ne montre donc que les campagnes du ruleset actif : le ruleset est
// affiché dans le titre, pas en colonne (même pattern que personnages/index.php).
$stmt = $db->prepare('
  SELECT camp.camp_id,
         camp.camp_nom,
         camp.camp_resume,
         un.un_nom AS univers_nom,
         (SELECT COUNT(*) FROM dd_scenarios sce
           WHERE sce.sce_camp_id = camp.camp_id AND sce.sce_supprime = 0) AS nb_scenarios,
         (SELECT COUNT(*) FROM dd_campagnes_personnages cp
           WHERE cp.cp_camp_id = camp.camp_id) AS nb_personnages
  FROM   dd_campagnes camp
  LEFT JOIN dd_univers un ON un.un_id = camp.camp_un_id
  WHERE  camp.camp_j_id = ?
    AND  camp.camp_ruleset_var_id = ?
    AND  camp.camp_supprime = 0
  ORDER  BY camp.camp_nom ASC
');
$stmt->execute([$j_id, $ruleset_id]);
$campagnes = $stmt->fetchAll();

require_once '../include/header.php';
?>

<script>
  // SP-CP : la fiche d'une campagne est une page (campagnes/campagne.php),
  // plus un panneau #detail-pp — il n'y a donc plus d'URL de détail à injecter.
  var campUrlModifier = <?= json_encode(BASE_URL . '/include/ajax/modifier/campagne.php') ?>;
  var campUrlEnreg    = <?= json_encode(BASE_URL . '/campagnes/enregistrement.php?ajax=1') ?>;
</script>

<div class="flex-between mb-md">
  <h1>Campagnes <span class="text-muted text-sm">(<?= h($ruleset_rep) ?>)</span></h1>
  <div class="flex flex-gap">
    <?php // Gestionnaire de tableaux — accessible depuis chaque module
    // (SP-TB10) : un tableau se réutilise partout, il n'appartient plus aux
    // règles. Nouvel onglet, pour ne pas perdre la liste en cours. ?>
    <?php if (canEditCompendium()): ?>
      <a class="btn btn-secondary btn-sm" href="<?= BASE_URL ?>/tableaux/index.php"
         target="_blank" rel="noopener" title="Tableaux de données">
        <i class="fa fa-table"></i> Tableaux
      </a>
    <?php endif ?>
    <button class="btn btn-primary btn-sm" onclick="ouvrirModifier(campUrlModifier, 0)">
      <i class="fa fa-plus"></i> Nouvelle campagne
    </button>
  </div>
</div>

<?php if (empty($campagnes)): ?>

  <p class="text-muted">
    Aucune campagne en <?= h($ruleset_rep) ?> pour le moment. Créez-en une pour commencer.
  </p>

<?php else: ?>

  <div class="table-scroll">
    <table class="camp-liste">
      <thead>
        <tr>
          <th class="col-action"></th>
          <th>Nom</th>
          <th class="camp-liste__col-sec">Univers</th>
          <th class="camp-liste__col-num">Scénarios</th>
          <th class="camp-liste__col-num">Personnages</th>
        </tr>
      </thead>
      <tbody>

        <?php foreach ($campagnes as $camp): ?>
          <?php
            $cid      = (int)$camp['camp_id'];
            $url_camp = BASE_URL . '/campagnes/campagne.php?id=' . $cid;
          ?>

          <tr id="camp-row-<?= $cid ?>" data-href="<?= h($url_camp) ?>">

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

            <?php // Cellules données — clic → page de la campagne (data-href sur
                  // la ligne, cf. js/campagne.js). ?>
            <td class="camp-liste__nom">
              <a href="<?= h($url_camp) ?>"><?= h($camp['camp_nom']) ?></a>
              <?php if (!empty($camp['camp_resume'])): ?>
                <span class="camp-liste__resume"><?= h($camp['camp_resume']) ?></span>
              <?php endif ?>
            </td>
            <td class="camp-liste__col-sec">
              <?= $camp['univers_nom'] ? h($camp['univers_nom']) : '<span class="text-muted">—</span>' ?>
            </td>
            <td class="camp-liste__col-num">
              <?= (int)$camp['nb_scenarios'] ?>
            </td>
            <td class="camp-liste__col-num">
              <?= (int)$camp['nb_personnages'] ?>
            </td>

          </tr>

        <?php endforeach ?>

      </tbody>
    </table>
  </div>

<?php endif ?>

<?php require_once '../include/footer.php'; ?>
