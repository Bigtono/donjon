<?php
// personnages/objets.php — Objets magiques du personnage (placeholder).
//
// Hors périmètre Phase 3 (cf. DECISIONS_LOG, arbitrage [D] :
// analyse métier non fiabilisée, dépend de la section compendium Objets
// magiques). Aucune table créée pour l'instant.
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

$page_title = 'Objets magiques — ' . $perso['pe_nom'];
$js_module  = 'personnage';
$css_module = 'personnages';

require_once '../include/header.php';
?>

<div class="flex-between mb-md">
  <h1>Objets magiques — <?= h($perso['pe_nom']) ?></h1>
  <a href="<?= BASE_URL ?>/personnages/fiche.php?id=<?= (int)$perso['pe_id'] ?>" class="btn btn-link btn-sm">
    <i class="fa fa-arrow-left"></i> Retour fiche
  </a>
</div>

<div class="alert alert-info">
  <strong>Fonctionnalité à venir.</strong>
  La gestion des objets magiques du personnage sera développée
  ultérieurement, une fois l'analyse métier fiabilisée et la section
  compendium Objets magiques stabilisée.
</div>

<?php require_once '../include/footer.php'; ?>
