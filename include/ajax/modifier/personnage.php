<?php
// include/ajax/modifier/personnage.php
// Overlay de création / modification d'un personnage.
// Appelé via ouvrirModifier(perUrlModifier, id) depuis la liste ou la fiche.
//
// SOUS-PHASE 3.0 : placeholder.
// Le formulaire réel (identité, race, archétype DD3.5, historique DD2024,
// sexe, alignement, caractéristiques, combat) sera développé en 3.1, puis
// enrichi (classes 3.2, compétences 3.3, dons 3.4, NLS 3.5).
require_once '../../../include/db.php';
require_once '../../../include/auth.php';
require_once '../../../include/helpers.php';
require_once '../../../include/personnage_helpers.php';

requireAuth();

$pe_id = intParam($_GET['id'] ?? 0);
$mode  = ($pe_id > 0) ? 'edition' : 'creation';

if ($mode === 'edition'):
  $perso = getPersonnageContext($db, $pe_id);
  if (!$perso):
    echo '<div class="alert alert-danger">Personnage introuvable ou accès refusé.</div>';
    exit;
  endif;
endif;
?>

<div class="modifier-entete">
  <h2><?= $mode === 'creation' ? 'Nouveau personnage' : 'Modifier — ' . h($perso['pe_nom']) ?></h2>
</div>

<div class="alert alert-info">
  <strong>Formulaire à venir (sous-phase 3.1).</strong>
  Le formulaire complet (identité, race, classe(s), caractéristiques,
  combat) sera implémenté en sous-phase 3.1.
</div>

<div class="flex-between mt-md">
  <button type="button" class="btn btn-secondary btn-sm" onclick="fermerModification()">
    Fermer
  </button>
</div>
