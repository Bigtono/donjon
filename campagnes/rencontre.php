<?php
// campagnes/rencontre.php — Page d'une rencontre (SP-CP).
// Remplace include/ajax/detail-pp/rencontre.php.
//
// SP-CP10 : contenu en onglets dans la page — Description, Composition,
// Oppositions. L'onglet ouvert est mémorisé en session pour cette rencontre
// (clé « re-<id> ») et rouvert à la visite suivante.
//
// SP-CP11 : dans l'onglet Oppositions, une fiche par opposition, choisie dans
// un sous-menu (clé « re-<id>-opp »), et le suivi des PV de chaque créature :
// bandeau commun à toute la rencontre au-dessus des fiches, repris dans la
// fiche de chaque opposition (include/opposition-pv.php).
//
// Le bloc de stats reste rendu déplié : en partie, le MJ lit ses créatures sans
// un clic. Le sous-panneau sert au monstre d'origine du compendium (liens
// .mo-lien du bloc de stats).
//
// Paramètre GET : id (int) — re_id

require_once '../include/db.php';
require_once '../include/auth.php';
require_once '../include/helpers.php';
require_once '../include/monstre-parser.php';
require_once '../include/opposition-pv.php';

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
  SELECT opp_id, opp_nom, opp_mocat_nom, opp_stats, opp_nombre, opp_pv_max
  FROM   dd_oppositions
  WHERE  opp_re_id = ? AND opp_supprime = 0
  ORDER  BY opp_ordre ASC, opp_nom ASC
');
$stmt_opp->execute([$id]);
$oppositions = $stmt_opp->fetchAll();

// Créatures et PV courants (SP-CP11), calculés une fois pour le bandeau et
// les fiches. Totaux de la rencontre : seules les créatures aux PV max connus.
$pv_courants = chargerPvOppositions($db, array_column($oppositions, 'opp_id'));
$creatures   = [];
$total_pv    = 0;
$total_max   = 0;
foreach ($oppositions as $opp):
  $oid = (int)$opp['opp_id'];
  $creatures[$oid] = creaturesOpposition($opp, $pv_courants[$oid] ?? []);
  foreach ($creatures[$oid] as $c):
    if ($c['max'] <= 0) continue;
    $total_pv  += max(0, $c['pv']);
    $total_max += $c['max'];
  endforeach;
endforeach;

// Onglets mémorisés (SP-CP10)
$cle_onglets = 're-' . $id;
$onglet      = ongletMemorise($cle_onglets, ['description', 'composition', 'oppositions'], 'description');
$opp_ids_txt = array_map('strval', array_column($oppositions, 'opp_id'));
$cle_opp     = $cle_onglets . '-opp';
$opp_active  = ongletMemorise($cle_opp, $opp_ids_txt, $opp_ids_txt[0] ?? '');

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

$onglets = [
  'description' => ['fa-scroll',       'Description', 0],
  'composition' => ['fa-people-group', 'Composition', 0],
  'oppositions' => ['fa-dragon',       'Oppositions', count($oppositions)],
];

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

    <?php require __DIR__ . '/../include/onglets-nav.php'; ?>

    <!-- Description -->
    <div class="onglet-panneau" role="tabpanel" data-panneau-de="<?= h($cle_onglets) ?>"
         data-panneau="description" <?= $onglet !== 'description' ? 'hidden' : '' ?>>
      <?php if (!empty($re['re_description'])): ?>
        <div class="camp-detail__description"><?= $re['re_description'] ?></div>
      <?php else: ?>
        <p class="text-muted">Aucune description pour le moment.</p>
      <?php endif ?>
    </div>

    <!-- Composition -->
    <div class="onglet-panneau" role="tabpanel" data-panneau-de="<?= h($cle_onglets) ?>"
         data-panneau="composition" <?= $onglet !== 'composition' ? 'hidden' : '' ?>>
      <?php if (!empty($re['re_composition'])): ?>
        <div class="camp-detail__description"><?= $re['re_composition'] ?></div>
      <?php else: ?>
        <p class="text-muted">Aucune composition renseignée.</p>
      <?php endif ?>
    </div>

    <!-- Oppositions -->
    <div class="onglet-panneau" role="tabpanel" data-panneau-de="<?= h($cle_onglets) ?>"
         data-panneau="oppositions" <?= $onglet !== 'oppositions' ? 'hidden' : '' ?>>

      <?php if (empty($oppositions)): ?>
        <p class="text-muted">Aucune opposition pour le moment.</p>
      <?php else: ?>

        <?php // Bandeau commun : toutes les créatures de la rencontre (SP-CP11). ?>
        <section class="camp-pv-bandeau" data-pv-rencontre="<?= $id ?>">
          <header class="camp-pv-bandeau__entete">
            <h2 class="camp-pv-bandeau__titre">
              <i class="fa fa-heart-pulse" aria-hidden="true"></i> Points de vie
            </h2>
            <?php if ($total_max > 0): ?>
              <span class="camp-pv-bandeau__total">
                Total <b data-pv-total><?= $total_pv ?></b> / <?= $total_max ?>
              </span>
            <?php endif ?>
            <button type="button" class="btn btn-secondary btn-sm"
                    onclick="campPvReinitialiser(<?= $id ?>)"
                    title="Remettre toutes les créatures à leurs PV max">
              <i class="fa fa-rotate-left"></i> Réinitialiser
            </button>
          </header>
          <div class="camp-pv-bandeau__liste">
            <?php foreach ($oppositions as $opp): ?>
              <?php foreach ($creatures[(int)$opp['opp_id']] as $c): ?>
                <?= rendrePvCreature((int)$opp['opp_id'], $c) ?>
              <?php endforeach ?>
            <?php endforeach ?>
          </div>
        </section>

        <?php // Sous-menu : une fiche par opposition, réordonnable par la poignée. ?>
        <div class="camp-opp-onglets tri-liste" role="tablist" aria-label="Oppositions"
             data-onglets="<?= h($cle_opp) ?>"
             data-tri-url="<?= h($url_enreg) ?>"
             data-tri-action="reordonnerOppositions"
             data-tri-parent="<?= $id ?>">
          <?php foreach ($oppositions as $opp): ?>
            <?php $oid = (int)$opp['opp_id']; $actif = ((string)$oid === $opp_active); ?>
            <div class="camp-opp-onglet" data-tri-id="<?= $oid ?>">
              <span class="tri-poignee" title="Glisser pour réordonner">
                <i class="fa fa-grip-vertical" aria-hidden="true"></i>
              </span>
              <button type="button" role="tab" data-onglet="<?= $oid ?>"
                      class="camp-opp-onglet__btn<?= $actif ? ' est-actif' : '' ?>"
                      aria-selected="<?= $actif ? 'true' : 'false' ?>">
                <?= h($opp['opp_nom']) ?>
                <?php if ((int)$opp['opp_nombre'] > 1): ?>
                  <span class="camp-opp-onglet__nb">×<?= (int)$opp['opp_nombre'] ?></span>
                <?php endif ?>
              </button>
            </div>
          <?php endforeach ?>
        </div>

        <?php foreach ($oppositions as $opp): ?>
          <?php
            $oid   = (int)$opp['opp_id'];
            $rendu = rendreStatsMonstre($db, $opp['opp_stats'], $ruleset_id, $res_ids);
          ?>
          <article class="camp-opp onglet-panneau" role="tabpanel" id="camp-opp-row-<?= $oid ?>"
                   data-panneau-de="<?= h($cle_opp) ?>" data-panneau="<?= $oid ?>"
                   <?= (string)$oid !== $opp_active ? 'hidden' : '' ?>>

            <div class="camp-opp__header">
              <h3 class="camp-opp__nom">
                <?= h($opp['opp_nom']) ?>
                <?php if ((int)$opp['opp_nombre'] > 1): ?>
                  <span class="camp-opp__nb">(<?= (int)$opp['opp_nombre'] ?>)</span>
                <?php endif ?>
                <?php if (!empty($opp['opp_mocat_nom'])): ?>
                  <span class="camp-opp__cat">— <?= h($opp['opp_mocat_nom']) ?></span>
                <?php endif ?>
                <?php // Accès direct à la modification, comme sur le titre de la rencontre. ?>
                <button class="sort-detail__edit-btn"
                        onclick="actualiserPageModif('<?= $base_modifier ?>/opposition.php',
                                 {id:<?= $oid ?>, re_id:<?= $id ?>})"
                        title="Modifier cette opposition">
                  <i class="fa fa-edit"></i>
                </button>
              </h3>

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

            <?php // PV des créatures de cette opposition, synchronisés avec le bandeau. ?>
            <div class="camp-opp__pv">
              <?php foreach ($creatures[$oid] as $c): ?>
                <?= rendrePvCreature($oid, $c, (int)$opp['opp_nombre'] > 1 ? false : true) ?>
              <?php endforeach ?>
            </div>

            <div class="camp-opp__corps">
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

      <?php endif ?>

      <button type="button" class="btn btn-primary btn-sm camp-opp__ajout"
              onclick="actualiserPageModif('<?= $base_modifier ?>/opposition.php', {id:0, re_id:<?= $id ?>})">
        <i class="fa fa-plus"></i> Nouvelle opposition
      </button>
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
