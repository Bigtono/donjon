<?php
// campagnes/rencontre.php — Page d'une rencontre (SP-CP).
// Remplace include/ajax/detail-pp/rencontre.php.
//
// Différence de fond avec l'ancien panneau : les oppositions ne sont plus une
// liste de noms à ouvrir une par une dans #detail-pp-sub. Chaque opposition est
// une carte dont le bloc de stats est rendu déplié — en partie, le MJ lit ses
// créatures sans un clic. Le sous-panneau reste utilisé pour le monstre
// d'origine du compendium (liens .mo-lien du bloc de stats).
//
// Paramètre GET : id (int) — re_id

require_once '../include/db.php';
require_once '../include/auth.php';
require_once '../include/helpers.php';
require_once '../include/monstre-parser.php';

requireAuth();

$id = intParam($_GET['id'] ?? 0);
if (!$id):
  $_SESSION['flash_message'] = ['type' => 'error', 'text' => 'Identifiant manquant.'];
  header('Location: ' . BASE_URL . '/campagnes/index.php');
  exit;
endif;

$stmt = $db->prepare('
  SELECT re.*,
         scc.scc_id, scc.scc_nom,
         sce.sce_id, sce.sce_nom,
         camp.camp_id, camp.camp_nom, camp.camp_ruleset_var_id
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

if (!$re || !isMJ($db, (int)$re['camp_id'])):
  $_SESSION['flash_message'] = ['type' => 'error', 'text' => 'Rencontre introuvable ou accès refusé.'];
  header('Location: ' . BASE_URL . '/campagnes/index.php');
  exit;
endif;

$camp_id = (int)$re['camp_id'];
$sce_id  = (int)$re['sce_id'];
$scc_id  = (int)$re['scc_id'];

setLastRencontre($camp_id, $re['camp_nom'], $sce_id, $re['sce_nom'],
                 $scc_id, $re['scc_nom'], $id, $re['re_nom']);

// Oppositions de la rencontre — ordre manuel (SP-CP, colonne opp_ordre).
$stmt_opp = $db->prepare('
  SELECT opp_id, opp_nom, opp_mocat_nom, opp_stats
  FROM   dd_oppositions
  WHERE  opp_re_id = ? AND opp_supprime = 0
  ORDER  BY opp_ordre ASC, opp_nom ASC
');
$stmt_opp->execute([$id]);
$oppositions = $stmt_opp->fetchAll();

// Bloc de stats : même moteur de rendu que la fiche Monstre du compendium.
// Index scopé au ruleset + sources actives de la CAMPAGNE
// (getActiveResIdsCampagne), pas aux sources personnelles du visiteur —
// l'opposition est un contenu de campagne. Résolu ici une seule fois pour
// toutes les oppositions de la page.
$ruleset_id  = (int)$re['camp_ruleset_var_id'];
$res_ids     = getActiveResIdsCampagne($db, $camp_id, $ruleset_id);
$detail_base = BASE_URL . '/include/ajax/detail-pp/';

$page_title     = $re['re_nom'];
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

  <section class="camp-page__contenu" data-re-id="<?= $id ?>"
           data-scc-id="<?= $scc_id ?>" data-sce-id="<?= $sce_id ?>"
           data-camp-id="<?= $camp_id ?>">

    <div class="camp-page__titre-bar">
      <div>
        <h1 class="camp-page__titre">
          <?php if (!empty($re['re_code'])): ?>
            <span class="camp-page__code"><?= h($re['re_code']) ?> :</span>
          <?php endif ?>
          <?= h($re['re_nom']) ?>
          <button class="sort-detail__edit-btn"
                  onclick="actualiserPageModif('<?= $base_modifier ?>/rencontre.php',
                           {id:<?= $id ?>, scc_id:<?= $scc_id ?>})"
                  title="Modifier cette rencontre">
            <i class="fa fa-edit"></i>
          </button>
        </h1>
      </div>
      <div class="camp-page__titre-actions">
        <a class="btn btn-secondary btn-sm" href="<?= BASE_URL ?>/campagnes/chapitre.php?id=<?= $scc_id ?>">
          <i class="fa fa-arrow-left"></i> <?= h($re['scc_nom']) ?>
        </a>
      </div>
    </div>

    <!-- Description -->
    <?php if (!empty($re['re_description'])): ?>
      <div class="camp-detail__section">
        <div class="camp-section__header">
          <h2 class="camp-detail__section-title">Description</h2>
          <button type="button" class="accordion-trigger" onclick="togglePlus('rencontre-description')"
                  title="Replier / déplier">
            <i class="fa fa-bars"></i>
          </button>
        </div>
        <div id="rencontre-description" class="accordion-content">
          <div class="camp-detail__description"><?= $re['re_description'] ?></div>
        </div>
      </div>
    <?php endif ?>

    <!-- Composition -->
    <?php if (!empty($re['re_composition'])): ?>
      <div class="camp-detail__section">
        <div class="camp-section__header">
          <h2 class="camp-detail__section-title">Composition</h2>
          <button type="button" class="accordion-trigger" onclick="togglePlus('rencontre-composition')"
                  title="Replier / déplier">
            <i class="fa fa-bars"></i>
          </button>
        </div>
        <div id="rencontre-composition" class="accordion-content">
          <div class="camp-detail__description"><?= $re['re_composition'] ?></div>
        </div>
      </div>
    <?php endif ?>

    <!-- Oppositions -->
    <div class="camp-detail__section">
      <div class="camp-section__header">
        <h2 class="camp-detail__section-title">Oppositions</h2>
        <button class="btn btn-primary btn-sm"
                onclick="actualiserPageModif('<?= $base_modifier ?>/opposition.php', {id:0, re_id:<?= $id ?>})">
          <i class="fa fa-plus"></i> Nouvelle
        </button>
      </div>

      <?php if (empty($oppositions)): ?>
        <p class="text-muted">Aucune opposition pour le moment.</p>
      <?php else: ?>
        <div class="camp-opp-liste tri-liste"
             data-tri-url="<?= h($url_enreg) ?>"
             data-tri-action="reordonnerOppositions"
             data-tri-parent="<?= $id ?>">

          <?php foreach ($oppositions as $opp): ?>
            <?php
              $oid   = (int)$opp['opp_id'];
              $rendu = rendreStatsMonstre($db, $opp['opp_stats'], $ruleset_id, $res_ids);
            ?>

            <article class="camp-opp" id="camp-opp-row-<?= $oid ?>" data-tri-id="<?= $oid ?>">

              <div class="camp-opp__header">
                <span class="tri-poignee" title="Glisser pour réordonner">
                  <i class="fa fa-grip-vertical" aria-hidden="true"></i>
                </span>

                <h3 class="camp-opp__nom">
                  <?= h($opp['opp_nom']) ?>
                  <?php if (!empty($opp['opp_mocat_nom'])): ?>
                    <span class="camp-opp__cat">— <?= h($opp['opp_mocat_nom']) ?></span>
                  <?php endif ?>
                </h3>

                <button type="button" class="accordion-trigger"
                        onclick="togglePlus('camp-opp-corps-<?= $oid ?>')"
                        title="Replier / déplier">
                  <i class="fa fa-bars"></i>
                </button>

                <div class="comp-menu-ligne">
                  <button class="btn btn-icon btn-sm comp-menu-btn"
                          onclick="campToggleMenu('opp-<?= $oid ?>')" title="Actions">⋮</button>
                  <div id="comp-menu-opp-<?= $oid ?>" class="comp-menu-dropdown noDisplay">
                    <button class="comp-menu-item"
                            onclick="campToggleMenu('opp-<?= $oid ?>');
                                     actualiserPageModif('<?= $base_modifier ?>/opposition.php',
                                     {id:<?= $oid ?>, re_id:<?= $id ?>})">
                      <i class="fa fa-edit"></i> Modifier
                    </button>
                    <button class="comp-menu-item"
                            onclick="campToggleMenu('opp-<?= $oid ?>');
                                     campOppOuvrirTransfertPopup(event, <?= $oid ?>, <?= $id ?>,
                                     <?= $camp_id ?>, 'transferer')">
                      <i class="fa fa-share"></i> Transférer
                    </button>
                    <button class="comp-menu-item"
                            onclick="campToggleMenu('opp-<?= $oid ?>');
                                     campOppOuvrirTransfertPopup(event, <?= $oid ?>, <?= $id ?>,
                                     <?= $camp_id ?>, 'dupliquer')">
                      <i class="fa fa-copy"></i> Dupliquer
                    </button>
                    <button class="comp-menu-item comp-menu-item--danger"
                            onclick="campToggleMenu('opp-<?= $oid ?>');
                                     campOppDemanderSuppression(<?= $oid ?>)">
                      <i class="fa fa-trash"></i> Supprimer
                    </button>
                  </div>
                </div>
              </div>

              <?php // Déplié par défaut : la lecture des stats ne coûte aucun clic. ?>
              <div id="camp-opp-corps-<?= $oid ?>" class="camp-opp__corps accordion-content">
                <?php if ($rendu['html'] !== ''): ?>
                  <div class="mo-stats" data-detail-base="<?= h($detail_base) ?>">
                    <?= $rendu['html'] ?>
                  </div>
                <?php else: ?>
                  <p class="text-muted">Aucune statistique renseignée.</p>
                <?php endif ?>
              </div>

            </article>

          <?php endforeach ?>

        </div>
      <?php endif ?>
    </div>

  </section>

</div>

<div id="camp-transfer-popup" class="camp-transfer-popup" hidden>
  <div class="camp-transfer-popup__header">
    <span id="camp-transfer-popup-titre" class="camp-transfer-popup__titre">Transférer vers…</span>
    <button type="button" class="camp-transfer-popup__close"
            onclick="campFermerTransfertPopup()">&times;</button>
  </div>
  <div id="camp-transfer-popup-body" class="camp-transfer-popup__body"></div>
  <div class="camp-transfer-popup__footer">
    Vers une autre campagne — bientôt disponible.
  </div>
</div>

<?php require_once '../include/footer.php'; ?>
