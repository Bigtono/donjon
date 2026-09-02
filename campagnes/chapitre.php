<?php
// campagnes/chapitre.php — Page d'un chapitre (SP-CP).
// Remplace include/ajax/detail-pp/chapitre.php.
// Paramètre GET : id (int) — scc_id

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
  SELECT scc.*,
         sce.sce_id, sce.sce_nom,
         camp.camp_id, camp.camp_nom
  FROM   dd_scenarios_chapitres scc
  JOIN   dd_scenarios sce  ON sce.sce_id   = scc.scc_sce_id
  JOIN   dd_campagnes camp ON camp.camp_id = sce.sce_camp_id
  WHERE  scc.scc_id = ? AND scc.scc_supprime = 0
    AND  sce.sce_supprime = 0 AND camp.camp_supprime = 0
');
$stmt->execute([$id]);
$scc = $stmt->fetch();

if (!$scc || !isMJ($db, (int)$scc['camp_id'])):
  $_SESSION['flash_message'] = ['type' => 'error', 'text' => 'Chapitre introuvable ou accès refusé.'];
  header('Location: ' . BASE_URL . '/campagnes/index.php');
  exit;
endif;

$camp_id = (int)$scc['camp_id'];
$sce_id  = (int)$scc['sce_id'];

setLastChapitre($camp_id, $scc['camp_nom'], $sce_id, $scc['sce_nom'], $id, $scc['scc_nom']);

// Rencontres du chapitre — ordre manuel (SP-CP, colonne re_ordre).
$stmt_re = $db->prepare('
  SELECT re_id, re_nom, re_code,
         (SELECT COUNT(*) FROM dd_oppositions
           WHERE opp_re_id = re.re_id AND opp_supprime = 0) AS nb_oppositions
  FROM   dd_rencontres re
  WHERE  re.re_scc_id = ? AND re.re_supprime = 0
  ORDER  BY re.re_ordre ASC, re.re_nom ASC
');
$stmt_re->execute([$id]);
$rencontres = $stmt_re->fetchAll();

$page_title     = $scc['scc_nom'];
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

  <section class="camp-page__contenu" data-scc-id="<?= $id ?>"
           data-sce-id="<?= $sce_id ?>" data-camp-id="<?= $camp_id ?>">

    <div class="camp-page__titre-bar">
      <div>
        <h1 class="camp-page__titre">
          <?php if (!empty($scc['scc_abreviation'])): ?>
            <span class="camp-page__code"><?= h($scc['scc_abreviation']) ?> :</span>
          <?php endif ?>
          <?= h($scc['scc_nom']) ?>
          <button class="sort-detail__edit-btn"
                  onclick="actualiserPageModif('<?= $base_modifier ?>/chapitre.php',
                           {id:<?= $id ?>, sce_id:<?= $sce_id ?>})"
                  title="Modifier ce chapitre">
            <i class="fa fa-edit"></i>
          </button>
        </h1>
      </div>
      <div class="camp-page__titre-actions">
        <a class="btn btn-secondary btn-sm" href="<?= BASE_URL ?>/campagnes/scenario.php?id=<?= $sce_id ?>">
          <i class="fa fa-arrow-left"></i> <?= h($scc['sce_nom']) ?>
        </a>
      </div>
    </div>

    <?php if (!empty($scc['scc_description'])): ?>
      <div class="camp-detail__section">
        <div class="camp-section__header">
          <h2 class="camp-detail__section-title">Description</h2>
          <button type="button" class="accordion-trigger" onclick="togglePlus('chapitre-description')"
                  title="Replier / déplier">
            <i class="fa fa-bars"></i>
          </button>
        </div>
        <div id="chapitre-description" class="accordion-content">
          <div class="camp-detail__description"><?= $scc['scc_description'] ?></div>
        </div>
      </div>
    <?php endif ?>

    <!-- Rencontres -->
    <div class="camp-detail__section">
      <div class="camp-section__header">
        <h2 class="camp-detail__section-title">Rencontres</h2>
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
              <th class="camp-sous-liste__col-poignee"></th>
              <th class="col-action"></th>
              <th>Rencontre</th>
              <th class="camp-liste__col-num">Oppositions</th>
            </tr>
          </thead>
          <tbody class="tri-liste"
                 data-tri-url="<?= h($url_enreg) ?>"
                 data-tri-action="reordonnerRencontres"
                 data-tri-parent="<?= $id ?>">
            <?php foreach ($rencontres as $re): ?>
              <?php
                $rid    = (int)$re['re_id'];
                $url_re = BASE_URL . '/campagnes/rencontre.php?id=' . $rid;
              ?>

              <tr id="camp-re-row-<?= $rid ?>" data-tri-id="<?= $rid ?>"
                  data-href="<?= h($url_re) ?>">

                <td class="tri-poignee" title="Glisser pour réordonner">
                  <i class="fa fa-grip-vertical" aria-hidden="true"></i>
                </td>

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
                                       campReDemanderSuppression(<?= $rid ?>)">
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

                <?php // Code en préfixe du nom (SP-CP) : la colonne dédiée a disparu. ?>
                <td>
                  <a href="<?= h($url_re) ?>">
                    <?php if (!empty($re['re_code'])): ?>
                      <span class="camp-sous-liste__code"><?= h($re['re_code']) ?> :</span>
                    <?php endif ?>
                    <?= h($re['re_nom']) ?>
                  </a>
                </td>
                <td class="camp-liste__col-num"><?= (int)$re['nb_oppositions'] ?></td>

              </tr>

            <?php endforeach ?>
          </tbody>
        </table>
      <?php endif ?>
    </div>

  </section>

</div>

<?php require_once '../include/footer.php'; ?>
