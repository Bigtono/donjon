<?php
// personnages/fiche.php — Fiche personnage (vue unique responsive).
//
// SOUS-PHASE 3.0 : placeholder.
// Le contenu réel (blocs Mode jeu / Identité / Caracs / Combat / Classes /
// NLS / Compétences / Dons / Campagnes) sera développé en 3.1 → 3.7 en suivant
// l'ordre d'affichage défini dans ARCHITECTURE_REFERENCE.md §7.3.
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

// Mémoriser ce perso comme "dernier consulté" (cohérent avec le module Campagnes)
setLastPersonnage((int)$perso['pe_id']);

$page_title = $perso['pe_nom'];
$js_module  = 'personnage';
$css_module = 'personnages';

require_once '../include/header.php';
?>

<div class="flex-between mb-md">
  <h1><?= h($perso['pe_nom']) ?>
    <span class="text-muted text-sm">(<?= h($perso['ruleset_label']) ?>)</span>
  </h1>
  <div>
    <a href="<?= BASE_URL ?>/personnages/" class="btn btn-link btn-sm">
      <i class="fa fa-arrow-left"></i> Liste
    </a>
    <button class="btn btn-secondary btn-sm"
            onclick="ouvrirModifier(<?= json_encode(BASE_URL . '/include/ajax/modifier/personnage.php') ?>, <?= (int)$perso['pe_id'] ?>)">
      <i class="fa fa-edit"></i> Modifier
    </button>
  </div>
</div>

<div class="alert alert-info">
  <strong>Module en cours de développement.</strong>
  Cette fiche est un placeholder de la sous-phase 3.0 (socle).
  Les blocs Mode jeu, Identité, Caractéristiques, Combat, Classes, NLS,
  Compétences, Dons et Campagnes seront ajoutés progressivement
  dans les sous-phases 3.1 à 3.7.
</div>

<?php require_once '../include/footer.php'; ?>
