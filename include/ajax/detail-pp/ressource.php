<?php
// include/ajax/detail-pp/ressource.php
// Retourne le HTML de détail d'une ressource pour #detail-pp
// Paramètres GET : id (int) — res_id

require_once __DIR__ . '/../../db.php';
require_once __DIR__ . '/../../auth.php';
require_once __DIR__ . '/../../helpers.php';

requireAdmin();

$id = intParam($_GET['id'] ?? 0);

if (!$id):
  http_response_code(400);
  echo '<p class="erreur">Identifiant manquant.</p>';
  exit;
endif;

$stmt = $db->prepare('
  SELECT res.*,
         var.var_valeur AS ruleset_label,
         prop.j_pseudo  AS proprietaire_pseudo
  FROM   dd_ressources res
  JOIN   dd_variables  var  ON var.var_id   = res.res_ruleset_var_id
  LEFT JOIN dd_joueurs prop ON prop.j_id    = res.res_j_id
  WHERE  res.res_id = ?
');
$stmt->execute([$id]);
$res = $stmt->fetch();

if (!$res):
  http_response_code(404);
  echo '<p class="erreur">Ressource introuvable.</p>';
  exit;
endif;

// ============================================================
// Comptage des dépendances (périmètre complet compendium)
// ============================================================

$compteurs      = compterContenuRessource($db, $id);
$total_lies     = array_sum($compteurs);
$peut_supprimer = ($total_lies === 0);
?>

<div class="admin-detail">

  <div class="admin-detail__header">
    <h2 class="admin-detail__titre">
      <?= h($res['res_nom']) ?>
      <button class="sort-detail__edit-btn"
              onclick="ouvrirModifier('<?= BASE_URL ?>/include/ajax/modifier/ressource.php', <?= $id ?>)"
              title="Modifier cette ressource">
        <i class="fa fa-edit"></i>
      </button>
    </h2>
    <p class="admin-detail__pseudo">
      <span class="badge badge--ruleset"><?= h($res['ruleset_label']) ?></span>
      <span class="badge badge--abrev"><?= h($res['res_abreviation']) ?></span>
      <?php if ((int)$res['res_selection']): ?>
        <span class="badge badge--actif">Actif par défaut</span>
      <?php endif ?>
    </p>
  </div>

  <div class="admin-detail__body">

    <?php if ($res['res_proprietaire_pseudo'] ?? $res['proprietaire_pseudo'] ?? null): ?>
      <div class="sort-detail__row">
        <span class="sort-detail__label">Propriétaire (homebrew)</span>
        <span class="sort-detail__value"><?= h($res['proprietaire_pseudo']) ?></span>
      </div>
    <?php endif ?>

    <?php if ($res['res_editeur']): ?>
      <div class="sort-detail__row">
        <span class="sort-detail__label">Éditeur</span>
        <span class="sort-detail__value"><?= h($res['res_editeur']) ?></span>
      </div>
    <?php endif ?>

  </div>

  <?php // ---- Dépendances compendium ---- ?>
  <div class="admin-detail__deps">
    <h3 class="admin-detail__deps-titre">Contenu rattaché</h3>

    <div class="admin-detail__deps-grid">
      <?php foreach (contenuRessourceTables() as $cle => $t): ?>
        <div class="admin-detail__dep-item <?= $compteurs[$cle] > 0 ? 'admin-detail__dep-item--has-data' : '' ?>">
          <span class="admin-detail__dep-label"><?= h($t['label']) ?></span>
          <span class="admin-detail__dep-nb <?= $compteurs[$cle] > 0 ? 'badge badge--count' : 'text-muted' ?>">
            <?= $compteurs[$cle] ?>
          </span>
        </div>
      <?php endforeach ?>
    </div>

    <?php if ($peut_supprimer): ?>
      <p class="admin-detail__can-delete">
        <i class="fa fa-check-circle"></i>
        Aucun contenu rattaché — suppression possible.
      </p>
    <?php else: ?>
      <p class="admin-detail__cannot-delete">
        <i class="fa fa-lock"></i>
        Suppression impossible tant que du contenu est rattaché.
      </p>
    <?php endif ?>
  </div>

  <?php if ($res['res_description']): ?>
    <div class="admin-detail__description">
      <?= $res['res_description'] ?>
    </div>
  <?php endif ?>

</div>
