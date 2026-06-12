<?php
// personnages/magie.php — Vue dédiée Magie du personnage.
//
// SOUS-PHASE 3.0 : placeholder. Contenu réel développé en sous-phase 3.6 :
// calcul NLS + sorts par jour par classe + listes sorts connus / compris /
// préparés cliquables (detail-pp/sort.php). Liste des sorts bornée par
// getActiveResIds() (chaîne campagne → perso → défaut).
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

$page_title = 'Magie — ' . $perso['pe_nom'];
$js_module  = 'personnage';
$css_module = 'personnages';

require_once '../include/header.php';
?>

<div class="flex-between mb-md">
  <h1>Magie — <?= h($perso['pe_nom']) ?></h1>
  <a href="<?= BASE_URL ?>/personnages/fiche.php?id=<?= (int)$perso['pe_id'] ?>" class="btn btn-link btn-sm">
    <i class="fa fa-arrow-left"></i> Retour fiche
  </a>
</div>

<div class="alert alert-info">
  <strong>Fonctionnalité à venir (sous-phase 3.6).</strong>
  Cette vue affichera, par classe lanceuse de sorts : le nombre de sorts par
  jour par niveau (calcul NLS + bonus de caractéristique + domaines divins),
  les listes des sorts connus, compris et préparés, tous cliquables vers le
  descriptif du compendium.
</div>

<?php require_once '../include/footer.php'; ?>
