<?php
// personnages/background.php — Background du personnage (sous-page).
//
// Extrait de fiche.php lors du passage au sous-menu (retour 2026-09-01).
// Le texte est du HTML TinyMCE : affiché tel quel, sans h().
require_once '../include/db.php';
require_once '../include/auth.php';
require_once '../include/helpers.php';
require_once '../include/personnage_helpers.php';

requireAuth();

$pe_id = intParam($_GET['id'] ?? 0);
$perso = getPersonnageContext($db, $pe_id);

if (!$perso):
  header('Location: ' . BASE_URL . '/personnages/');
  exit;
endif;

setLastPersonnage((int)$perso['pe_id'], (int)$perso['pe_ruleset_var_id']);

$ruleset_id  = (int)$perso['pe_ruleset_var_id'];
$ruleset_rep = ($ruleset_id === 2) ? 'DD2024' : 'DD3.5';
$classes     = getPersonnageClasses($db, (int)$perso['pe_id']);

// L'onglet Magie n'est proposé qu'aux lanceurs — cla_mag_id > 0 les identifie
// dans les deux rulesets, seule la plage de valeurs diffère (D-MAG2).
$nav_lanceur = false;
foreach ($classes as $c):
  if ((int)$c['cla_mag_id'] > 0) { $nav_lanceur = true; break; }
endforeach;

$page_title   = 'Background — ' . $perso['pe_nom'];
$js_module    = 'personnage';
$css_module   = 'personnages';
$nav_courante = 'background';

require_once '../include/header.php';
?>

<div class="per-fiche">

  <div class="per-fiche__header">
    <h1 class="per-fiche__nom"><?= h($perso['pe_nom']) ?></h1>
    <a href="<?= BASE_URL ?>/personnages/fiche.php?id=<?= (int)$perso['pe_id'] ?>"
       class="btn btn-secondary btn-sm">
      <i class="fa fa-pen"></i>
      
    </a>
  </div>

  <?php require __DIR__ . '/../include/personnage-nav.php'; ?>

  <section class="per-fiche__bloc">
    <header class="per-fiche__bloc-header">
      <h2 class="per-fiche__bloc-titre">
        <i class="fa fa-book-open"></i> Background
      </h2>
    </header>
    <div class="per-fiche__bloc-body per-fiche__bloc-body--html">
      <?php if (!empty($perso['pe_background'])): ?>
        <?= $perso['pe_background'] ?>
      <?php else: ?>
        <p class="text-muted text-sm">
          Aucun background saisi. Il se renseigne depuis le formulaire de modification du personnage.
        </p>
      <?php endif ?>
    </div>
  </section>

</div>

<?php require_once '../include/footer.php'; ?>
