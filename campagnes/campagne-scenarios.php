<?php
// campagnes/campagne-scenarios.php — Page d'une campagne, onglet Scénarios (SP-CP9).
// Liste des scénarios avec compteurs, ordre manuel par glisser-déposer (SP-CP).
// Paramètre GET : id (int) — camp_id

require_once __DIR__ . '/../include/campagne-contexte.php';

$stmt_sce = $db->prepare('
  SELECT sce.sce_id, sce.sce_nom,
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

$page_title = 'Scénarios — ' . $camp['camp_nom'];

require_once '../include/header.php';

$nav_courante = 'scenarios';
require __DIR__ . '/../include/campagne-entete.php';
?>

    <div class="camp-detail__section">
      <div class="camp-section__header">
        <h2 class="camp-detail__section-title">Scénarios</h2>
        <button class="btn btn-primary btn-sm"
                onclick="actualiserPageModif('<?= $base_modifier ?>/scenario.php', {id:0, camp_id:<?= $id ?>})">
          <i class="fa fa-plus"></i> Nouveau
        </button>
      </div>

      <?php if (empty($scenarios)): ?>
        <p class="text-muted">Aucun scénario pour le moment.</p>
      <?php else: ?>
        <table class="camp-sous-liste">
          <thead>
            <tr>
              <th class="camp-sous-liste__col-poignee"></th>
              <th class="col-action"></th>
              <th>Scénario</th>
              <th class="camp-liste__col-num">Chapitres</th>
              <th class="camp-liste__col-num">Rencontres</th>
            </tr>
          </thead>
          <tbody class="tri-liste"
                 data-tri-url="<?= h($url_enreg) ?>"
                 data-tri-action="reordonnerScenarios"
                 data-tri-parent="<?= $id ?>">
            <?php foreach ($scenarios as $sce): ?>
              <?php
                $sid     = (int)$sce['sce_id'];
                $url_sce = BASE_URL . '/campagnes/scenario.php?id=' . $sid;
              ?>

              <tr id="camp-sce-row-<?= $sid ?>" data-tri-id="<?= $sid ?>"
                  data-href="<?= h($url_sce) ?>">

                <td class="tri-poignee" title="Glisser pour réordonner">
                  <i class="fa fa-grip-vertical" aria-hidden="true"></i>
                </td>

                <!-- Menu contextuel -->
                <td class="col-action">
                  <div class="comp-menu-ligne">
                    <button class="btn btn-icon btn-sm comp-menu-btn"
                            onclick="campToggleMenu('sce-<?= $sid ?>')"
                            title="Actions">⋮</button>
                    <div id="comp-menu-sce-<?= $sid ?>" class="comp-menu-dropdown noDisplay">
                      <button class="comp-menu-item"
                              onclick="campToggleMenu('sce-<?= $sid ?>');
                                       actualiserPageModif('<?= $base_modifier ?>/scenario.php', {id:<?= $sid ?>, camp_id:<?= $id ?>})">
                        <i class="fa fa-edit"></i> Modifier
                      </button>
                      <button class="comp-menu-item comp-menu-item--danger"
                              onclick="campToggleMenu('sce-<?= $sid ?>');
                                       campSceDemanderSuppression(<?= $sid ?>)">
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

                <td><a href="<?= h($url_sce) ?>"><?= h($sce['sce_nom']) ?></a></td>
                <td class="camp-liste__col-num"><?= (int)$sce['nb_chapitres'] ?></td>
                <td class="camp-liste__col-num"><?= (int)$sce['nb_rencontres'] ?></td>

              </tr>

            <?php endforeach ?>
          </tbody>
        </table>
      <?php endif ?>
    </div>

  </section>

</div>

<?php require_once '../include/footer.php'; ?>
