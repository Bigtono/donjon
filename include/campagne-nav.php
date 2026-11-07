<?php
// include/campagne-nav.php — Sous-menu horizontal d'une campagne (SP-CP9).
//
// Même composant que le sous-menu du personnage (.page-nav, css/modules.css) :
// chaque section est une vraie page, avec son URL.
//
// Attendus avant l'inclusion :
//   $id             camp_id
//   $nav_courante   description | personnages | scenarios

$nav_camp_id = (int)$id;

$nav_items = [
  'description' => ['campagne.php',             'fa-scroll',    'Description'],
  'personnages' => ['campagne-personnages.php', 'fa-users',     'Personnages'],
  'scenarios'   => ['campagne-scenarios.php',   'fa-book-open', 'Scénarios'],
];
?>
<nav class="page-nav" aria-label="Sections de la campagne">
  <?php foreach ($nav_items as $cle => [$page, $icone, $libelle]): ?>
    <?php $actif = ($cle === ($nav_courante ?? 'description')); ?>
    <a href="<?= BASE_URL ?>/campagnes/<?= $page ?>?id=<?= $nav_camp_id ?>"
       class="page-nav__item<?= $actif ? ' est-actif' : '' ?>"
       <?= $actif ? 'aria-current="page"' : '' ?>
       title="<?= h($libelle) ?>">
      <i class="fa <?= $icone ?>"></i>
      <span class="page-nav__lbl"><?= h($libelle) ?></span>
    </a>
  <?php endforeach ?>
</nav>
