<?php
// admin/index.php — Tableau de bord de la zone d'administration
require_once '../include/db.php';
require_once '../include/auth.php';
require_once '../include/helpers.php';

requireAdmin();

// --- Mode debug UI ---------------------------------------------------------
// Bascule stockée en session uniquement (aucune colonne en base) : outil de
// mise au point de l'UI responsive, réinitialisé à chaque déconnexion.
if ($_SERVER['REQUEST_METHOD'] === 'POST' && ($_POST['section'] ?? '') === 'debug'):
  verifyCsrf();
  $_SESSION['debug_ui'] = !empty($_POST['debug_ui']);
  $_SESSION['flash_message'] = [
    'type' => 'info',
    'text' => $_SESSION['debug_ui']
      ? 'Mode debug activé — le badge de dimensions s\'affiche sur toutes les pages.'
      : 'Mode debug désactivé.',
  ];
  header('Location: ' . BASE_URL . '/admin/index.php');
  exit;
endif;

// --- Déploiement (SP-DP) ----------------------------------------------------
// Module local : son dossier n'est jamais transféré, la tuile n'apparaît donc
// qu'en local — et encore faut-il que la requête vienne du poste lui-même.
$deploiement_disponible = false;
if (is_file(__DIR__ . '/deploiement/lib.php')):
  require_once __DIR__ . '/deploiement/lib.php';
  $deploiement_disponible = deploiementEstLocal();
endif;

$page_title = 'Administration';
$js_module  = 'admin';
$css_module = 'admin';

require_once '../include/header.php';
?>

<div class="flex-between mb-md">
  <h1>Administration</h1>
</div>

<div class="dashboard-grid">

  <a href="<?= BASE_URL ?>/admin/utilisateurs.php" class="dashboard-card dashboard-card--admin">
    <i class="fa fa-users"></i>
    <span>Utilisateurs</span>
  </a>

  <a href="<?= BASE_URL ?>/admin/ressources.php" class="dashboard-card dashboard-card--admin">
    <i class="fa fa-book-open"></i>
    <span>Ressources</span>
  </a>

  <a href="<?= BASE_URL ?>/admin/connexions.php" class="dashboard-card dashboard-card--admin">
    <i class="fa fa-mobile-screen"></i>
    <span>Relevés d'affichage</span>
  </a>

  <a href="<?= BASE_URL ?>/admin/migrations.php" class="dashboard-card dashboard-card--admin">
    <i class="fa fa-database"></i>
    <span>Migrations SQL</span>
  </a>

  <?php if ($deploiement_disponible): ?>
    <a href="<?= BASE_URL ?>/admin/deploiement/index.php" class="dashboard-card dashboard-card--admin">
      <i class="fa fa-cloud-arrow-up"></i>
      <span>Déploiement</span>
    </a>
    <a href="<?= BASE_URL ?>/admin/deploiement/export-classes.php" class="dashboard-card dashboard-card--admin">
      <i class="fa fa-file-export"></i>
      <span>Export de classes</span>
    </a>
  <?php endif ?>

</div>

<section class="admin-outils">
  <h2>Outils de développement</h2>

  <form method="POST" action="<?= BASE_URL ?>/admin/index.php">
    <?= csrfField() ?>
    <input type="hidden" name="section" value="debug">

    <div class="form-group">
      <label class="toggle-label">
        <span>Mode debug — dimensions d'écran</span>
        <input type="checkbox" name="debug_ui" value="1"
               <?= !empty($_SESSION['debug_ui']) ? 'checked' : '' ?>>
        <span class="toggle-switch"></span>
      </label>
      <p class="form-hint">
        Affiche en permanence un badge indiquant la largeur et la hauteur du viewport,
        la densité de pixels et les paliers responsive actifs (991 / 768 / 479 px).
        Visible uniquement par les administrateurs, jusqu'à la déconnexion.
        Un clic sur le badge le déplace d'un coin à l'autre.
      </p>
    </div>

    <div class="form-actions">
      <button type="submit" class="btn btn-primary">
        <i class="fa fa-bug"></i> Appliquer
      </button>
    </div>
  </form>
</section>

<?php
require_once '../include/footer.php';
?>
