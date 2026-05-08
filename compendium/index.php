<?php
// compendium/index.php — Accueil du compendium
require_once '../include/db.php';
require_once '../include/auth.php';
require_once '../include/helpers.php';

requireAuth();

$page_title = 'Compendium';
$js_module  = '';
$ruleset_rep = $_SESSION['rulesetRep'] ?? 'DD3.5';

require_once '../include/header.php';
?>

<div class="flex-between mb-md">
  <h1>Compendium</h1>
  <span class="site-header__ruleset"><?= h($ruleset_rep) ?></span>
</div>

<div class="dashboard-grid">

  <a href="<?= BASE_URL ?>/compendium/classes.php" class="dashboard-card">
    <i class="fa fa-shield-alt"></i>
    <span>Classes</span>
  </a>

  <a href="<?= BASE_URL ?>/compendium/sorts.php" class="dashboard-card">
    <i class="fa fa-magic"></i>
    <span>Sorts</span>
  </a>

  <a href="<?= BASE_URL ?>/compendium/dons.php" class="dashboard-card">
    <i class="fa fa-star"></i>
    <span>Dons</span>
  </a>

  <a href="<?= BASE_URL ?>/compendium/races.php" class="dashboard-card">
    <i class="fa fa-dragon"></i>
    <span>Races</span>
  </a>

  <a href="<?= BASE_URL ?>/compendium/competences.php" class="dashboard-card">
    <i class="fa fa-tools"></i>
    <span>Compétences</span>
  </a>

  <a href="<?= BASE_URL ?>/compendium/objets.php" class="dashboard-card">
    <i class="fa fa-gem"></i>
    <span>Objets magiques</span>
  </a>

</div>

<?php
require_once '../include/footer.php';
?>
