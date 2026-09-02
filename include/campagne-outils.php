<?php
// include/campagne-outils.php — Colonne d'outils des pages du module Campagnes (SP-CP).
//
// Fragment inclus par campagnes/campagne.php, scenario.php, chapitre.php et
// rencontre.php, à l'intérieur de <aside class="camp-page__outils">.
//
// Vocation : rassembler les aides de jeu utilisées pendant une partie. Elles
// restent à développer — seul l'écran du MJ est déjà identifié (SP-TB8, table
// dd_tableaux, colonnes tab_ecran_mj / tab_ecran_ordre). Le bouton est affiché
// mais inerte tant que la page n'existe pas : mieux vaut annoncer l'outil que
// laisser la colonne vide.
//
// Variables attendues :
//   $outils_camp_id (int) — campagne du niveau affiché, pour les futurs outils
?>
<button type="button" class="camp-outils__toggle"
        onclick="campToggleOutils(this)" aria-expanded="false">
  <i class="fa fa-toolbox" aria-hidden="true"></i>
  Outils
  <i class="fa fa-chevron-down camp-outils__toggle-chevron" aria-hidden="true"></i>
</button>

<div class="camp-outils__corps" data-camp-id="<?= (int)($outils_camp_id ?? 0) ?>">

  <p class="camp-outils__titre">Outils</p>

  <button type="button" class="camp-outil camp-outil--inactif" disabled
          title="Écran du MJ — en cours de développement (SP-TB8)">
    <i class="fa fa-chalkboard" aria-hidden="true"></i>
    Écran du MJ
  </button>

</div>
