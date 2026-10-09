<?php
// include/personnage-nav.php — Sous-menu horizontal du module Personnages.
//
// Le découpage en cinq pages remplace la fiche unique devenue trop longue
// (retour du 2026-09-01). Chaque section est une VRAIE PAGE, avec son URL :
// même parti que SP-CP pour les Campagnes, et pour la même raison — la fiche
// chargeait déjà tout le référentiel des compétences du ruleset, y empiler la
// Magie aurait pénalisé le téléphone.
//
// Attendus avant l'inclusion :
//   $perso            tableau du personnage (getPersonnageContext)
//   $nav_courante     clé de la page en cours : fiche | magie | possessions
//                     | background | campagnes
//   $nav_lanceur      (optionnel) bool — masque l'onglet Magie si false
//
// Sur téléphone, les libellés disparaissent au profit des seules icônes : cinq
// libellés ne tiennent pas sur une ligne, et un menu qui se replie sur deux
// lignes mange la hauteur utile.

$nav_pe_id   = (int)$perso['pe_id'];
$nav_lanceur = $nav_lanceur ?? true;

$nav_items = [
  'fiche'       => ['fiche.php',       'fa-user',          'Fiche'],
  'magie'       => ['magie.php',       'fa-hat-wizard',    'Magie'],
  'possessions' => ['possessions.php', 'fa-sack-xmark',    'Possessions'],
  'background'  => ['background.php',  'fa-feather',       'Background'],
  'campagnes'   => ['campagnes.php',   'fa-map',           'Campagnes'],
];
?>
<nav class="per-nav" aria-label="Sections du personnage">
  <?php foreach ($nav_items as $cle => [$page, $icone, $libelle]): ?>
    <?php if ($cle === 'magie' && !$nav_lanceur) continue; ?>
    <?php $actif = ($cle === ($nav_courante ?? 'fiche')); ?>
    <a href="<?= BASE_URL ?>/personnages/<?= $page ?>?id=<?= $nav_pe_id ?>"
       class="per-nav__item<?= $actif ? ' est-actif' : '' ?>"
       <?= $actif ? 'aria-current="page"' : '' ?>
       title="<?= h($libelle) ?>">
      <i class="fa <?= $icone ?>"></i>
      <span class="per-nav__lbl"><?= h($libelle) ?></span>
    </a>
  <?php endforeach ?>
</nav>
