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

setLastCampagne($id, $camp['camp_nom']);

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

// Personnages rattachés (SP-PE5) — lecture seule.
// La source de vérité du rattachement est dd_campagnes_personnages ; le
// marqueur « en cours » se lit sur le raccourci pe_camp_id du personnage.
$stmt_per = $db->prepare('
  SELECT pe.pe_id,
         pe.pe_nom,
         pe.pe_j_id,
         ra.ra_nom,
         cp.cp_actif,
         (pe.pe_camp_id = ?) AS est_courante,
         (SELECT GROUP_CONCAT(CONCAT(cla.cla_nom, \' \', pc.pc_niveau)
                   ORDER BY cla.cla_nom SEPARATOR \' / \')
            FROM dd_personnages_classes pc
            JOIN dd_classes cla ON cla.cla_id = pc.pc_cla_id
           WHERE pc.pc_pe_id = pe.pe_id) AS classes_txt
  FROM   dd_campagnes_personnages cp
  JOIN   dd_personnages pe ON pe.pe_id = cp.cp_pe_id
  LEFT JOIN dd_races ra ON ra.ra_id = pe.pe_ra_id
  WHERE  cp.cp_camp_id = ?
  ORDER  BY est_courante DESC, pe.pe_nom ASC
');
$stmt_per->execute([$id, $id]);
$personnages = $stmt_per->fetchAll();

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
              onclick="actualiserPageModif('<?= $base_modifier ?>/campagne.php', {id:<?= $id ?>})"
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

  <!-- Scénarios -->
  <div class="camp-detail__section">
    <div class="camp-section__header">
      <h3 class="camp-detail__section-title">Scénarios</h3>
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
                                     actualiserPageModif('<?= $base_modifier ?>/scenario.php', {id:<?= $sid ?>, camp_id:<?= $id ?>})">
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

              <!-- Clic → navigation interne vers la fiche scénario -->
              <td onclick="naviguerDetailPP('<?= $base_detail ?>/scenario.php', {id:<?= $sid ?>})"
                  style="cursor:pointer">
                <?= h($sce['sce_nom']) ?>
              </td>
              <td class="camp-liste__col-num"
                  onclick="naviguerDetailPP('<?= $base_detail ?>/scenario.php', {id:<?= $sid ?>})"
                  style="cursor:pointer">
                <?= (int)$sce['nb_chapitres'] ?>
              </td>
              <td class="camp-liste__col-num"
                  onclick="naviguerDetailPP('<?= $base_detail ?>/scenario.php', {id:<?= $sid ?>})"
                  style="cursor:pointer">
                <?= (int)$sce['nb_rencontres'] ?>
              </td>

            </tr>

          <?php endforeach ?>
        </tbody>
      </table>
    <?php endif ?>
  </div>

  <!-- Personnages (SP-PE5) -->
  <div class="camp-detail__section">
    <h3 class="camp-detail__section-title">Personnages</h3>

    <?php if (empty($personnages)): ?>
      <p class="text-muted">
        Aucun personnage rattaché. Le rattachement se fait depuis la fiche du personnage.
      </p>
    <?php else: ?>
      <table class="camp-sous-liste">
        <thead>
          <tr>
            <th>Personnage</th>
            <th>Classes</th>
            <th>Statut</th>
          </tr>
        </thead>
        <tbody>
          <?php foreach ($personnages as $p): ?>
            <?php
              // La fiche détail d'un personnage est réservée à son propriétaire
              // (canAccess) : on ne rend cliquables que ceux qui s'ouvriront.
              $lisible = canAccess((int)$p['pe_j_id']);
              $onclick = $lisible
                ? 'naviguerDetailPP(\'' . $base_detail . '/personnage.php\', {id:' . (int)$p['pe_id'] . '})'
                : '';
            ?>
            <tr>
              <td <?= $lisible ? 'onclick="' . h($onclick) . '" style="cursor:pointer"' : '' ?>>
                <?= h($p['pe_nom']) ?>
                <?php if (!empty($p['ra_nom'])): ?>
                  <span class="text-muted text-sm"><?= h($p['ra_nom']) ?></span>
                <?php endif ?>
              </td>
              <td class="text-muted">
                <?= $p['classes_txt'] ? h($p['classes_txt']) : '—' ?>
              </td>
              <td>
                <?php if ((int)$p['est_courante'] === 1): ?>
                  <span class="per-camp__badge per-camp__badge--courante">En cours</span>
                <?php elseif ((int)$p['cp_actif'] !== 1): ?>
                  <span class="per-camp__badge">Terminée</span>
                <?php else: ?>
                  <span class="text-muted">—</span>
                <?php endif ?>
              </td>
            </tr>
          <?php endforeach ?>
        </tbody>
      </table>
    <?php endif ?>
  </div>

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
