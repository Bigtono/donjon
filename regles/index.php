<?php
// regles/index.php — Accueil du module Règles
// Affiche : barre de recherche, sommaire complet, accès rapide aux chapitres racines.
// Référence : doc/ARCHITECTURE_0_REFERENCE.md §9b

require_once '../include/db.php';
require_once '../include/auth.php';
require_once '../include/helpers.php';
require_once '../include/regles-arbre.php';

requireAuth();

$page_title = 'Règles de jeu';
$js_module  = 'regles';
$css_module = 'regles';

$ruleset_id  = (int)($_SESSION['ruleset_var_id'] ?? 1);
$ruleset_rep = $_SESSION['rulesetRep'] ?? 'DD3.5';
$peut_editer = canEditCompendium();

// Chargement de l'arbre complet (brouillons visibles pour les éditeurs)
$arbre       = chargerArbreRegles($db, $ruleset_id, $peut_editer);
$sommaire    = rendreSommaire($arbre, null);

require_once '../include/header.php';
?>

<div class="regles-layout">

  <?php // ---- Colonne sommaire ---- ?>
  <aside class="regles-sommaire-aside" id="regles-sommaire-aside">
    <button class="regles-sommaire__toggle-mobile" id="regles-sommaire-toggle"
            aria-expanded="false" aria-controls="regles-sommaire-aside"
            title="Afficher / masquer le sommaire">
      <i class="fa fa-bars"></i> Sommaire
    </button>

    <div class="regles-sommaire__inner" id="regles-sommaire-inner">
      <?= $sommaire ?>
    </div>
  </aside>

  <?php // ---- Contenu principal ---- ?>
  <div class="regles-contenu" id="regles-contenu">

    <div class="regles-toolbar">
      <h1 class="regles-titre">
        Règles de jeu
        <span class="site-header__ruleset"><?= h($ruleset_rep) ?></span>
      </h1>

      <?php // ---- Barre de recherche ---- ?>
      <form class="regles-recherche-form" action="<?= BASE_URL ?>/regles/recherche.php" method="get"
            role="search" aria-label="Rechercher dans les règles">
        <input type="text" name="q" class="regles-recherche-input"
               placeholder="Rechercher une règle…"
               value="" autocomplete="off" aria-label="Terme à rechercher">
        <button type="submit" class="btn btn--sm" title="Rechercher">
          <i class="fa fa-search"></i>
        </button>
      </form>

      <?php if ($peut_editer): ?>
        <button class="btn btn--sm btn--secondary"
                onclick="ouvrirModifier('<?= BASE_URL ?>/include/ajax/modifier/regle.php', 0)"
                title="Ajouter un chapitre racine">
          <i class="fa fa-plus"></i> Nouveau chapitre
        </button>
      <?php endif ?>
    </div>

    <?php // ---- Chapitres racines (tuiles d'accès rapide) ---- ?>
    <section class="regles-accueil">
      <div class="regles-chapitres-grille">
        <?php foreach ($arbre['racines'] as $rid):
          $r = $arbre['nodes'][$rid];
          $nb_enfants = count($arbre['enfants'][$rid] ?? []);
        ?>
          <a href="<?= BASE_URL ?>/regles/regle.php?id=<?= (int)$rid ?>"
             class="regles-chapitre-card<?= $r['reg_visible'] ? '' : ' regles-chapitre-card--masque' ?>">
            <span class="regles-chapitre-card__nom"><?= h($r['reg_nom']) ?></span>
            <?php if ($nb_enfants > 0): ?>
              <span class="regles-chapitre-card__compte"><?= $nb_enfants ?> section<?= $nb_enfants > 1 ? 's' : '' ?></span>
            <?php endif ?>
            <?php if (!$r['reg_visible']): ?>
              <span class="regles-badge regles-badge--brouillon">Brouillon</span>
            <?php endif ?>
          </a>
        <?php endforeach ?>
      </div>
    </section>

    <?php if (empty($arbre['racines'])): ?>
      <p class="regles-vide">
        Aucune règle n'est encore disponible pour ce ruleset.
        <?php if ($peut_editer): ?>
          Commencez par
          <a href="#" onclick="ouvrirModifier('<?= BASE_URL ?>/include/ajax/modifier/regle.php', 0); return false;">
            créer un premier chapitre
          </a>.
        <?php endif ?>
      </p>
    <?php endif ?>

  </div><?php // .regles-contenu ?>
</div><?php // .regles-layout ?>

<?php
// Injecter BASE_URL pour regles.js
?>
<script>
  var BASE_URL = <?= json_encode(BASE_URL) ?>;
  var REGLES_PEUT_EDITER = <?= $peut_editer ? 'true' : 'false' ?>;
</script>

<?php require_once '../include/footer.php'; ?>
