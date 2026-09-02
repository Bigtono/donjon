<?php
// campagnes/scenario.php — Page d'un scénario (SP-CP).
// Remplace include/ajax/detail-pp/scenario.php.
// Paramètre GET : id (int) — sce_id

require_once '../include/db.php';
require_once '../include/auth.php';
require_once '../include/helpers.php';

requireAuth();

$id = intParam($_GET['id'] ?? 0);
if (!$id):
  $_SESSION['flash_message'] = ['type' => 'error', 'text' => 'Identifiant manquant.'];
  header('Location: ' . BASE_URL . '/campagnes/index.php');
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

if (!$sce || !isMJ($db, (int)$sce['camp_id'])):
  $_SESSION['flash_message'] = ['type' => 'error', 'text' => 'Scénario introuvable ou accès refusé.'];
  header('Location: ' . BASE_URL . '/campagnes/index.php');
  exit;
endif;

$camp_id = (int)$sce['camp_id'];

setLastScenario($camp_id, $sce['camp_nom'], $id, $sce['sce_nom']);

// Chapitres avec compteur de rencontres — ordre manuel (SP-CP).
$stmt_scc = $db->prepare('
  SELECT scc.scc_id, scc.scc_nom, scc.scc_abreviation,
         COUNT(re.re_id) AS nb_rencontres
  FROM   dd_scenarios_chapitres scc
  LEFT JOIN dd_rencontres re ON re.re_scc_id = scc.scc_id AND re.re_supprime = 0
  WHERE  scc.scc_sce_id = ? AND scc.scc_supprime = 0
  GROUP  BY scc.scc_id
  ORDER  BY scc.scc_ordre ASC, scc.scc_nom ASC
');
$stmt_scc->execute([$id]);
$chapitres = $stmt_scc->fetchAll();

$page_title     = $sce['sce_nom'];
$js_module      = 'campagne';
$css_module     = 'campagnes';
$body_class     = 'camp-plein';
$outils_camp_id = $camp_id;

$base_modifier = BASE_URL . '/include/ajax/modifier';
$url_enreg     = BASE_URL . '/campagnes/enregistrement.php?ajax=1';

require_once '../include/header.php';
?>

<script>
  var campUrlEnreg = <?= json_encode($url_enreg) ?>;
</script>

<div class="camp-page">

  <aside class="camp-page__outils">
    <?php include __DIR__ . '/../include/campagne-outils.php'; ?>
  </aside>

  <section class="camp-page__contenu" data-sce-id="<?= $id ?>" data-camp-id="<?= $camp_id ?>">

    <div class="camp-page__titre-bar">
      <div>
        <h1 class="camp-page__titre">
          <?= h($sce['sce_nom']) ?>
          <button class="sort-detail__edit-btn"
                  onclick="actualiserPageModif('<?= $base_modifier ?>/scenario.php',
                           {id:<?= $id ?>, camp_id:<?= $camp_id ?>})"
                  title="Modifier ce scénario">
            <i class="fa fa-edit"></i>
          </button>
        </h1>
      </div>
      <div class="camp-page__titre-actions">
        <a class="btn btn-secondary btn-sm" href="<?= BASE_URL ?>/campagnes/campagne.php?id=<?= $camp_id ?>">
          <i class="fa fa-arrow-left"></i> <?= h($sce['camp_nom']) ?>
        </a>
      </div>
    </div>

    <?php if (!empty($sce['sce_description'])): ?>
      <div class="camp-detail__description"><?= $sce['sce_description'] ?></div>
    <?php endif ?>

    <!-- Chapitres -->
    <div class="camp-detail__section">
      <div class="camp-section__header">
        <h2 class="camp-detail__section-title">Chapitres</h2>
        <button class="btn btn-primary btn-sm"
                onclick="actualiserPageModif('<?= $base_modifier ?>/chapitre.php',
                         {id:0, sce_id:<?= $id ?>})">
          <i class="fa fa-plus"></i> Nouveau
        </button>
      </div>

      <?php if (empty($chapitres)): ?>
        <p class="text-muted">Aucun chapitre pour le moment.</p>
      <?php else: ?>
        <table class="camp-sous-liste">
          <thead>
            <tr>
              <th class="camp-sous-liste__col-poignee"></th>
              <th class="col-action"></th>
              <th>Chapitre</th>
              <th class="camp-liste__col-num">Rencontres</th>
            </tr>
          </thead>
          <tbody class="tri-liste"
                 data-tri-url="<?= h($url_enreg) ?>"
                 data-tri-action="reordonnerChapitres"
                 data-tri-parent="<?= $id ?>">
            <?php foreach ($chapitres as $scc): ?>
              <?php
                $cid     = (int)$scc['scc_id'];
                $url_scc = BASE_URL . '/campagnes/chapitre.php?id=' . $cid;
              ?>

              <tr id="camp-scc-row-<?= $cid ?>" data-tri-id="<?= $cid ?>"
                  data-href="<?= h($url_scc) ?>">

                <td class="tri-poignee" title="Glisser pour réordonner">
                  <i class="fa fa-grip-vertical" aria-hidden="true"></i>
                </td>

                <!-- Menu contextuel -->
                <td class="col-action">
                  <div class="comp-menu-ligne">
                    <button class="btn btn-icon btn-sm comp-menu-btn"
                            onclick="campToggleMenu('scc-<?= $cid ?>')"
                            title="Actions">⋮</button>
                    <div id="comp-menu-scc-<?= $cid ?>" class="comp-menu-dropdown noDisplay">
                      <button class="comp-menu-item"
                              onclick="campToggleMenu('scc-<?= $cid ?>');
                                       actualiserPageModif('<?= $base_modifier ?>/chapitre.php',
                                       {id:<?= $cid ?>, sce_id:<?= $id ?>})">
                        <i class="fa fa-edit"></i> Modifier
                      </button>
                      <button class="comp-menu-item comp-menu-item--danger"
                              onclick="campToggleMenu('scc-<?= $cid ?>');
                                       campSccDemanderSuppression(<?= $cid ?>)">
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

                <?php // Abréviation en préfixe du nom (SP-CP) : la colonne dédiée a disparu. ?>
                <td>
                  <a href="<?= h($url_scc) ?>">
                    <?php if (!empty($scc['scc_abreviation'])): ?>
                      <span class="camp-sous-liste__code"><?= h($scc['scc_abreviation']) ?> :</span>
                    <?php endif ?>
                    <?= h($scc['scc_nom']) ?>
                  </a>
                </td>
                <td class="camp-liste__col-num"><?= (int)$scc['nb_rencontres'] ?></td>

              </tr>

            <?php endforeach ?>
          </tbody>
        </table>
      <?php endif ?>
    </div>

  </section>

</div>

<?php require_once '../include/footer.php'; ?>
