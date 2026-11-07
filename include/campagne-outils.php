<?php
// include/campagne-outils.php — Colonne d'outils des pages du module Campagnes (SP-CP).
//
// Fragment inclus par les sous-pages de la campagne (via include/campagne-entete.php,
// SP-CP9), scenario.php, chapitre.php et rencontre.php, à l'intérieur de
// <aside class="camp-page__outils">.
//
// Vocation : rassembler les aides de jeu utilisées pendant une partie : les
// notes du MJ (SP-NO3) et l'écran du MJ (SP-TB8 : tableaux de règles disposés
// par campagne, table dd_campagnes_ecran). Les pages qui incluent ce fragment
// sont réservées au MJ de la campagne et à l'admin.
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

  <?php // Notes du MJ de la campagne (SP-NO3) ?>
  <a class="camp-outil" href="<?= BASE_URL ?>/campagnes/notes.php?f_campagne=<?= (int)($outils_camp_id ?? 0) ?>">
    <i class="fa fa-sticky-note" aria-hidden="true"></i>
    Notes
  </a>

  <?php // Écran du MJ (SP-TB8) — surcouche plein écran, js/ecran-mj.js ?>
  <button type="button" class="camp-outil"
          data-ecran-mj-ouvrir="<?= (int)($outils_camp_id ?? 0) ?>"
          title="Tableaux de règles choisis pour cette campagne">
    <i class="fa fa-chalkboard" aria-hidden="true"></i>
    Écran du MJ
  </button>

</div>
<?php // defer : exécuté après main.js (chargé sans defer en pied de page) ?>
<script src="<?= assetUrl('js/ecran-mj.js') ?>" defer></script>
