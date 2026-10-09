<?php
// admin/migrations.php — État et application des migrations SQL (SP-DP5)
//
// Même écran en local et en production : il montre l'état de LA base de
// l'environnement consulté. En production, le déployeur applique les
// migrations tout seul (admin/migrations-auto.php) ; cet écran sert de
// contrôle et de secours (migration en échec, migration jouée à la main).
require_once '../include/db.php';
require_once '../include/auth.php';
require_once '../include/helpers.php';
require_once '../include/migrations.php';

requireAdmin();

// --- Actions ----------------------------------------------------------------
if ($_SERVER['REQUEST_METHOD'] === 'POST'):
  verifyCsrf();
  $action = strParam($_POST['action'] ?? '');

  if ($action === 'appliquer'):
    @set_time_limit(300);
    $resultat = migrationsAppliquerEnAttente($db);
    $nb       = count($resultat['appliquees']);
    if ($resultat['ok']):
      $_SESSION['flash_message'] = [
        'type' => 'success',
        'text' => $nb === 0
          ? 'Aucune migration en attente.'
          : $nb . ' migration' . ($nb > 1 ? 's appliquées.' : ' appliquée.'),
      ];
    else:
      $_SESSION['flash_message'] = [
        'type' => 'error',
        'text' => ($nb > 0 ? $nb . ' migration(s) appliquée(s), puis échec sur ' : 'Échec sur ')
          . $resultat['echec']['fichier'] . ' : ' . $resultat['echec']['erreur'],
      ];
    endif;

  elseif ($action === 'marquer'):
    $fichier = strParam($_POST['fichier'] ?? '');
    $_SESSION['flash_message'] = migrationsMarquer($db, $fichier)
      ? ['type' => 'success', 'text' => $fichier . ' marquée comme appliquée.']
      : ['type' => 'error', 'text' => 'Impossible de marquer ' . $fichier . '.'];
  endif;

  header('Location: ' . BASE_URL . '/admin/migrations.php');
  exit;
endif;

// --- Lecture ----------------------------------------------------------------
$etat        = migrationsEtat($db);
$en_attente  = array_values(array_filter($etat, fn($m) => $m['statut'] === 'en_attente'));
$nb_modifies = count(array_filter($etat, fn($m) => $m['modifiee']));

// Ordre d'affichage : les plus récentes en tête, là où se joue l'actualité.
$etat_affiche = array_reverse($etat);

$statuts = [
  'en_attente'        => ['libelle' => 'En attente', 'badge' => 'badge--count'],
  MIGRATION_EXECUTEE  => ['libelle' => 'Exécutée', 'badge' => 'badge--actif'],
  MIGRATION_REFERENCE => ['libelle' => 'Référence', 'badge' => 'badge--ruleset'],
  MIGRATION_MARQUEE   => ['libelle' => 'Marquée', 'badge' => 'badge--ruleset'],
];

$page_title = 'Migrations SQL';
$css_module = 'admin';

require_once '../include/header.php';
?>

<div class="flex-between mb-md">
  <h1>Migrations SQL</h1>
</div>

<p class="text-muted mb-md">
  Base de cet environnement — <strong><?= DEV_MODE ? 'local' : 'production' ?></strong>.
  Une migration est un fichier <code>sql/AAAA-MM-JJ_*.sql</code>, jouée une seule fois, dans l'ordre
  des dates. Les migrations antérieures au moteur (2026-10-07) sont inscrites comme « référence »
  sans être rejouées. En production, le déploiement applique les migrations en attente tout seul.
</p>

<div class="migrations-bilan mb-md">
  <span><strong><?= count($etat) ?></strong> migrations</span>
  <span><strong><?= count($en_attente) ?></strong> en attente</span>
  <?php if ($nb_modifies > 0): ?>
    <span class="migrations-bilan__alerte">
      <i class="fa fa-triangle-exclamation"></i>
      <strong><?= $nb_modifies ?></strong> retouchée<?= $nb_modifies > 1 ? 's' : '' ?> après application
    </span>
  <?php endif ?>
</div>

<?php if (!empty($en_attente)): ?>
  <form method="POST" action="<?= BASE_URL ?>/admin/migrations.php" class="mb-md"
        onsubmit="return confirm('Appliquer <?= count($en_attente) ?> migration(s) sur la base <?= DEV_MODE ? 'locale' : 'de PRODUCTION' ?> ?');">
    <?= csrfField() ?>
    <input type="hidden" name="action" value="appliquer">
    <button type="submit" class="btn btn-primary">
      <i class="fa fa-play"></i>
      Appliquer <?= count($en_attente) === 1 ? 'la migration en attente' : 'les ' . count($en_attente) . ' migrations en attente' ?>
    </button>
    <p class="form-hint">
      Dans l'ordre, arrêt à la première erreur. MySQL n'annule pas un <code>ALTER TABLE</code> :
      une migration en échec peut rester partiellement appliquée.
    </p>
  </form>
<?php endif ?>

<div class="comp-liste-wrapper">
  <table class="comp-liste">
    <thead>
      <tr>
        <th>Fichier</th>
        <th>Statut</th>
        <th>Date</th>
        <th>Durée</th>
        <th></th>
      </tr>
    </thead>
    <tbody>
      <?php foreach ($etat_affiche as $m): ?>
        <?php $statut = $statuts[$m['statut']] ?? ['libelle' => $m['statut'], 'badge' => 'badge--ruleset'] ?>
        <tr>
          <td class="col-primary migrations-fichier"><?= h($m['fichier']) ?></td>
          <td>
            <span class="badge <?= h($statut['badge']) ?>"><?= h($statut['libelle']) ?></span>
            <?php if ($m['modifiee']): ?>
              <span class="badge badge--admin" title="Le fichier a changé depuis son application. Il ne sera pas rejoué.">Retouchée</span>
            <?php endif ?>
          </td>
          <td><?= $m['date'] ? h(date('d/m/Y H:i', strtotime($m['date']))) : '—' ?></td>
          <td><?= $m['duree_ms'] !== null ? (int)$m['duree_ms'] . ' ms' : '—' ?></td>
          <td>
            <?php if ($m['statut'] === 'en_attente'): ?>
              <form method="POST" action="<?= BASE_URL ?>/admin/migrations.php"
                    onsubmit="return confirm('Déclarer <?= h($m['fichier']) ?> comme déjà appliquée, sans l\'exécuter ?');">
                <?= csrfField() ?>
                <input type="hidden" name="action" value="marquer">
                <input type="hidden" name="fichier" value="<?= h($m['fichier']) ?>">
                <button type="submit" class="btn btn-secondary btn-sm" title="Jouée à la main (phpMyAdmin) : l'inscrire sans l'exécuter">
                  Marquer comme appliquée
                </button>
              </form>
            <?php endif ?>
          </td>
        </tr>
      <?php endforeach ?>
    </tbody>
  </table>
</div>

<?php
require_once '../include/footer.php';
?>
