<?php
// include/onglets-nav.php — Barre d'onglets EN PAGE des pages Campagnes (SP-CP10).
//
// Même composant visuel que le sous-menu des sous-pages (.page-nav,
// css/modules.css), mais les onglets sont des boutons : ils montrent un
// panneau de la page sans la recharger. js/campagne.js bascule les panneaux
// [data-panneau-de="<clé>"] et mémorise le choix en session (memoriserOnglet).
// Le serveur rend directement l'onglet mémorisé : pas de clignotement.
//
// Attendus avant l'inclusion :
//   $cle_onglets  clé de mémoire, « sce-12 », « scc-4 », « re-7 »
//   $onglet       clé de l'onglet ouvert (ongletMemorise())
//   $onglets      [clé => [icône, libellé, compte]] — compte affiché s'il est > 0
?>
<nav class="page-nav" role="tablist" aria-label="Sections de la page"
     data-onglets="<?= h($cle_onglets) ?>">
  <?php foreach ($onglets as $cle => $def): ?>
    <?php [$icone, $libelle] = $def; $compte = (int)($def[2] ?? 0); $actif = ($cle === $onglet); ?>
    <button type="button" role="tab" data-onglet="<?= h($cle) ?>"
            class="page-nav__item<?= $actif ? ' est-actif' : '' ?>"
            aria-selected="<?= $actif ? 'true' : 'false' ?>" title="<?= h($libelle) ?>">
      <i class="fa <?= h($icone) ?>"></i>
      <span class="page-nav__lbl"><?= h($libelle) ?></span>
      <?php if ($compte > 0): ?>
        <span class="page-nav__compte"><?= $compte ?></span>
      <?php endif ?>
    </button>
  <?php endforeach ?>
</nav>
