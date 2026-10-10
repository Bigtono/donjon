<?php
// personnages/possessions.php — Objets magiques et équipement (sous-page).
//
// Emplacement réservé. Remplace l'ancien placeholder objets.php lors du passage
// au sous-menu (2026-09-01). Le contenu viendra quand la modélisation de
// l'équipement sera arbitrée — cf. SP-E6, dont le schéma actuel
// (eqt_nom, eqt_description) ne porte ni dégâts, ni propriétés, ni prix.
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

$classes     = getPersonnageClasses($db, (int)$perso['pe_id']);
$nav_lanceur = false;
foreach ($classes as $c):
  if ((int)$c['cla_mag_id'] > 0) { $nav_lanceur = true; break; }
endforeach;

$page_title   = 'Possessions — ' . $perso['pe_nom'];
$js_module    = 'personnage';
$css_module   = 'personnages';
$nav_courante = 'possessions';

require_once '../include/header.php';
?>

<div class="per-fiche">

  <div class="per-fiche__header">
    <h1 class="per-fiche__nom"><?= h($perso['pe_nom']) ?></h1>
  </div>

  <?php require __DIR__ . '/../include/personnage-nav.php'; ?>

  <section class="per-fiche__bloc">
    <header class="per-fiche__bloc-header">
      <h2 class="per-fiche__bloc-titre">
        <i class="fa fa-sack-xmark"></i> Possessions
      </h2>
    </header>
    <div class="per-fiche__bloc-body">
      <p class="text-muted text-sm">
        Objets magiques et équipement du personnage — fonctionnalité à venir.
      </p>
    </div>
  </section>

</div>

<?php require_once '../include/footer.php'; ?>
