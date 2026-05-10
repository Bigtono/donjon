<?php
// include/ajax/detail-pp/utilisateur.php
// Retourne le HTML de détail d'un utilisateur pour #detail-pp
// Paramètres GET : id (int) — j_id

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
  SELECT j.*,
         var.var_valeur AS ruleset_label
  FROM   dd_joueurs j
  LEFT JOIN dd_variables var ON var.var_id = j.j_default_ruleset_var_id
  WHERE  j.j_id = ?
');
$stmt->execute([$id]);
$j = $stmt->fetch();

if (!$j):
  http_response_code(404);
  echo '<p class="erreur">Utilisateur introuvable.</p>';
  exit;
endif;

// Comptage des données de jeu
$nb_perso = (int)$db->prepare(
  'SELECT COUNT(*) FROM dd_personnages WHERE pe_j_id = ?'
)->execute([$id]) ? $db->query("SELECT COUNT(*) FROM dd_personnages WHERE pe_j_id = $id")->fetchColumn() : 0;

$stmt_nperso = $db->prepare('SELECT COUNT(*) FROM dd_personnages WHERE pe_j_id = ?');
$stmt_nperso->execute([$id]);
$nb_perso = (int)$stmt_nperso->fetchColumn();

$stmt_ncamps = $db->prepare('SELECT COUNT(*) FROM dd_campagnes WHERE camp_j_id = ?');
$stmt_ncamps->execute([$id]);
$nb_camps = (int)$stmt_ncamps->fetchColumn();
?>

<div class="admin-detail">

  <div class="admin-detail__header">
    <h2 class="admin-detail__titre">
      <?= h($j['j_prenom'] . ' ' . $j['j_nom']) ?>
      <button class="sort-detail__edit-btn"
              onclick="ouvrirModifier('<?= BASE_URL ?>/include/ajax/modifier/utilisateur.php', <?= $id ?>)"
              title="Modifier cet utilisateur">
        <i class="fa fa-edit"></i>
      </button>
    </h2>
    <p class="admin-detail__pseudo">
      <i class="fa fa-at"></i> <?= h($j['j_pseudo']) ?>
      <?php if (!(int)$j['j_visible']): ?>
        <span class="badge badge--inactif">Désactivé</span>
      <?php endif ?>
    </p>
  </div>

  <div class="admin-detail__body">

    <div class="sort-detail__row">
      <span class="sort-detail__label">Email</span>
      <span class="sort-detail__value"><?= h($j['j_email']) ?></span>
    </div>

    <div class="sort-detail__row">
      <span class="sort-detail__label">Droits</span>
      <span class="sort-detail__value">
        <?php if ((int)$j['j_admin']): ?>
          <span class="badge badge--admin">Admin</span>
        <?php endif ?>
        <?php if ((int)$j['j_compendium_manager']): ?>
          <span class="badge badge--compendium">Compendium</span>
        <?php endif ?>
        <?php if (!(int)$j['j_admin'] && !(int)$j['j_compendium_manager']): ?>
          <span class="text-muted">Utilisateur standard</span>
        <?php endif ?>
      </span>
    </div>

    <div class="sort-detail__row">
      <span class="sort-detail__label">Ruleset par défaut</span>
      <span class="sort-detail__value">
        <?= $j['ruleset_label'] ? h($j['ruleset_label']) : '<span class="text-muted">—</span>' ?>
      </span>
    </div>

    <div class="sort-detail__row">
      <span class="sort-detail__label">Inscription</span>
      <span class="sort-detail__value">
        <?= h(date('d/m/Y', strtotime($j['j_date_inscription']))) ?>
      </span>
    </div>

    <div class="sort-detail__row">
      <span class="sort-detail__label">Dernière connexion</span>
      <span class="sort-detail__value">
        <?= $j['j_derniere_connexion']
          ? h(date('d/m/Y H:i', strtotime($j['j_derniere_connexion'])))
          : '<span class="text-muted">Jamais</span>' ?>
      </span>
    </div>

    <div class="sort-detail__row">
      <span class="sort-detail__label">Données de jeu</span>
      <span class="sort-detail__value">
        <?= $nb_perso ?> personnage<?= $nb_perso > 1 ? 's' : '' ?>,
        <?= $nb_camps ?> campagne<?= $nb_camps > 1 ? 's' : '' ?>
      </span>
    </div>

    <div class="sort-detail__row">
      <span class="sort-detail__label">Éléments / page</span>
      <span class="sort-detail__value"><?= (int)$j['j_items_par_page'] ?></span>
    </div>

    <div class="sort-detail__row">
      <span class="sort-detail__label">Mode campagne</span>
      <span class="sort-detail__value">
        <?= (int)$j['j_mode_campagne'] ? 'Activé' : 'Désactivé' ?>
      </span>
    </div>

  </div>

  <?php if ($j['j_notes']): ?>
    <div class="admin-detail__notes">
      <strong>Notes admin :</strong>
      <p><?= h($j['j_notes']) ?></p>
    </div>
  <?php endif ?>

  <div class="admin-detail__actions">
    <?php if ((int)$j['j_visible']): ?>
      <button class="btn btn-warning btn-sm"
              onclick="adminChangerVisibilite(<?= $id ?>, 'desactiver')">
        <i class="fa fa-user-slash"></i> Désactiver
      </button>
    <?php else: ?>
      <button class="btn btn-success btn-sm"
              onclick="adminChangerVisibilite(<?= $id ?>, 'reactiver')">
        <i class="fa fa-user-check"></i> Réactiver
      </button>
    <?php endif ?>
  </div>

</div>
