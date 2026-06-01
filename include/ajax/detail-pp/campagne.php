<?php
// include/ajax/detail-pp/campagne.php
// Retourne le HTML de détail d'une campagne pour #detail-pp.
// Appelé via actualiserPage() — pas de layout header/footer.
//
// Paramètres GET :
//   id (int) — camp_id de la campagne à afficher

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

// ============================================================
// Données principales (scope propriétaire : on ne lit que ses campagnes)
// ============================================================

$stmt = $db->prepare('
  SELECT camp.*,
         var.var_valeur AS ruleset_label,
         un.un_nom       AS univers_nom
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

// Accès : seul le MJ propriétaire (ou un admin) consulte la fiche.
if (!isMJ($db, $id)):
  http_response_code(403);
  echo '<p class="erreur">Accès refusé.</p>';
  exit;
endif;

$est_mj = isMJ($db, $id);

// ============================================================
// Sources actives de la campagne
// ============================================================

$stmt_src = $db->prepare('
  SELECT res.res_nom
  FROM   dd_campagnes_sources cs
  JOIN   dd_ressources res ON res.res_id = cs.cs_res_id
  WHERE  cs.cs_camp_id = ?
  ORDER  BY res.res_nom ASC
');
$stmt_src->execute([$id]);
$sources = $stmt_src->fetchAll(PDO::FETCH_COLUMN);

// ============================================================
// Compteurs
// ============================================================

$stmt_n = $db->prepare('
  SELECT COUNT(*) FROM dd_scenarios WHERE sce_camp_id = ? AND sce_supprime = 0
');
$stmt_n->execute([$id]);
$nb_scenarios = (int)$stmt_n->fetchColumn();

$stmt_p = $db->prepare('SELECT COUNT(*) FROM dd_campagnes_personnages WHERE cp_camp_id = ?');
$stmt_p->execute([$id]);
$nb_personnages = (int)$stmt_p->fetchColumn();
?>

<div class="camp-detail">

  <div class="camp-detail__header">
    <h2 class="camp-detail__nom">
      <?= h($camp['camp_nom']) ?>
      <?php if ($est_mj): ?>
        <button class="sort-detail__edit-btn"
                onclick="ouvrirModifier('<?= BASE_URL ?>/include/ajax/modifier/campagne.php', <?= $id ?>)"
                title="Modifier cette campagne">
          <i class="fa fa-edit"></i>
        </button>
      <?php endif ?>
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
    <div class="camp-detail__description">
      <?= $camp['camp_description'] // HTML TinyMCE — affiché brut ?>
    </div>
  <?php endif ?>

  <div class="camp-detail__stats">
    <span class="camp-detail__stat">
      <i class="fa fa-scroll"></i> <?= $nb_scenarios ?> scénario<?= $nb_scenarios > 1 ? 's' : '' ?>
    </span>
    <span class="camp-detail__stat">
      <i class="fa fa-users"></i> <?= $nb_personnages ?> personnage<?= $nb_personnages > 1 ? 's' : '' ?>
    </span>
  </div>

  <?php // ---- Sources de la campagne ?>
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

  <?php // ---- Scénarios (à venir SP2) ?>
  <div class="camp-detail__section">
    <h3 class="camp-detail__section-title">Scénarios</h3>
    <p class="text-muted"><em>Gestion des scénarios — à venir.</em></p>
  </div>

  <?php // ---- Actions ?>
  <?php if ($est_mj): ?>
    <div class="camp-detail__actions">
      <button class="btn btn-danger btn-sm"
              onclick="campagneListe.supprimer(<?= $id ?>, <?= json_encode($camp['camp_nom']) ?>)">
        <i class="fa fa-trash"></i> Supprimer la campagne
      </button>
    </div>
  <?php endif ?>

</div>
