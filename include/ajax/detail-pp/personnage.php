<?php
// include/ajax/detail-pp/personnage.php
// Affichage détail d'un personnage dans un panel detail-pp.
// Sera appelé en contexte 'externe' depuis le module Campagnes (Phase 4)
// pour afficher la fiche condensée d'un perso dans une campagne.
//
// SOUS-PHASE 3.0 : placeholder. Vue détaillée développée en 3.1+ (en
// pratique : un résumé de la fiche pour consultation par le MJ).
require_once '../../../include/db.php';
require_once '../../../include/auth.php';
require_once '../../../include/helpers.php';
require_once '../../../include/personnage_helpers.php';

requireAuth();

$pe_id = intParam($_GET['id'] ?? 0);
$perso = getPersonnageContext($db, $pe_id);

if (!$perso):
  echo '<div class="alert alert-danger">Personnage introuvable ou accès refusé.</div>';
  exit;
endif;
?>

<div class="detail-pp-entete">
  <h2><?= h($perso['pe_nom']) ?>
    <span class="text-muted text-sm">(<?= h($perso['ruleset_label']) ?>)</span>
  </h2>
</div>

<div class="alert alert-info">
  <strong>Vue détail à venir.</strong>
  L'affichage détaillé du personnage en panel detail-pp sera développé
  en sous-phase 3.1.
</div>

<div class="mt-md">
  <a href="<?= BASE_URL ?>/personnages/fiche.php?id=<?= (int)$perso['pe_id'] ?>" class="btn btn-primary btn-sm">
    <i class="fa fa-external-link"></i> Ouvrir la fiche complète
  </a>
</div>
