<?php
// admin/index.php — Tableau de bord de la zone d'administration
require_once '../include/db.php';
require_once '../include/auth.php';
require_once '../include/helpers.php';

requireAdmin();

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

</div>

<?php
require_once '../include/footer.php';
?>
