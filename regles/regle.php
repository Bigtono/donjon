<?php
// regles/regle.php — Vue d'un nœud de règle (chapitre, règle ou terme de glossaire)
//
// Paramètres GET :
//   id  (int)    — reg_id du nœud à afficher
//   q   (string) — terme de recherche à surligner (optionnel, depuis recherche.php)
//
// Référence : doc/ARCHITECTURE_0_REFERENCE.md §9b

require_once '../include/db.php';
require_once '../include/auth.php';
require_once '../include/helpers.php';
require_once '../include/regles-arbre.php';

requireAuth();

$id          = intParam($_GET['id'] ?? 0);
$q           = strParam($_GET['q'] ?? '');
$ruleset_id  = (int)($_SESSION['ruleset_var_id'] ?? 1);
$ruleset_rep = $_SESSION['rulesetRep'] ?? 'DD3.5';
$peut_editer = canEditCompendium();

if (!$id):
  header('Location: ' . BASE_URL . '/regles/index.php');
  exit;
endif;

// ============================================================
// Chargement arbre + nœud courant
// ============================================================
$arbre = chargerArbreRegles($db, $ruleset_id, $peut_editer);

if (!isset($arbre['nodes'][$id])):
  http_response_code(404);
  $page_title = 'Règle introuvable';
  require_once '../include/header.php';
  echo '<p class="erreur">Cette règle est introuvable ou n\'est pas disponible.</p>';
  require_once '../include/footer.php';
  exit;
endif;

$noeud = $arbre['nodes'][$id];

// ============================================================
// Navigation : fil d'Ariane, précédent/suivant
// ============================================================
$ariane       = filAriane($arbre, $id);
$ordre_lecture = reglesOrdreLecture($arbre);
$id_prec      = reglesPrec($ordre_lecture, $id);
$id_suiv      = reglesSuiv($ordre_lecture, $id);

$noeud_prec = $id_prec ? $arbre['nodes'][$id_prec] : null;
$noeud_suiv = $id_suiv ? $arbre['nodes'][$id_suiv] : null;

// ============================================================
// Enfants directs (pour le sous-sommaire de la page)
// ============================================================
$ids_enfants = $arbre['enfants'][$id] ?? [];
$enfants = [];
foreach ($ids_enfants as $eid):
  $enfants[] = $arbre['nodes'][$eid];
endforeach;

// ============================================================
// Meta page
// ============================================================
$page_title = h($noeud['reg_nom']) . ' — Règles de jeu';
$js_module  = 'regles';
$css_module = 'regles';

require_once '../include/header.php';
?>

<div class="regles-layout">

  <?php // ---- Colonne sommaire ---- ?>
  <aside class="regles-sommaire-aside" id="regles-sommaire-aside">
    <button class="regles-sommaire__toggle-mobile" id="regles-sommaire-toggle"
            aria-expanded="false" title="Afficher / masquer le sommaire">
      <i class="fa fa-bars"></i> Sommaire
    </button>
    <div class="regles-sommaire__inner" id="regles-sommaire-inner">
      <?= rendreSommaire($arbre, $id) ?>
    </div>
  </aside>

  <?php // ---- Contenu principal ---- ?>
  <article class="regles-contenu" id="regles-contenu">

    <?php // ---- Barre outils (recherche + boutons éditeur) ---- ?>
    <div class="regles-toolbar">
      <form class="regles-recherche-form" action="<?= BASE_URL ?>/regles/recherche.php" method="get"
            role="search" aria-label="Rechercher dans les règles">
        <input type="text" name="q" class="regles-recherche-input"
               placeholder="Rechercher une règle…"
               value="<?= h($q) ?>" autocomplete="off">
        <button type="submit" class="btn btn--sm" title="Rechercher">
          <i class="fa fa-search"></i>
        </button>
      </form>

      <?php if ($peut_editer): ?>
        <div class="regles-toolbar__actions">
          <button class="btn btn--sm btn--secondary"
                  onclick="ouvrirModifier('<?= BASE_URL ?>/include/ajax/modifier/regle.php', <?= $id ?>)"
                  title="Modifier ce nœud">
            <i class="fa fa-edit"></i> Modifier
          </button>
          <button class="btn btn--sm btn--secondary"
                  onclick="ouvrirModifier('<?= BASE_URL ?>/include/ajax/modifier/regle.php', 0, <?= $id ?>)"
                  title="Ajouter un enfant">
            <i class="fa fa-plus"></i> Ajouter ici
          </button>
          <button class="btn btn--sm btn--danger"
                  onclick="reglesConfirmerSuppression(<?= $id ?>, <?= $enfants ? 'true' : 'false' ?>)"
                  title="Supprimer">
            <i class="fa fa-trash"></i>
          </button>
        </div>
      <?php endif ?>
    </div>

    <?php // ---- Fil d'Ariane ---- ?>
    <?php if (count($ariane) > 1): ?>
      <nav class="regles-ariane" aria-label="Fil d'Ariane">
        <?php foreach ($ariane as $i => $aid):
          $an = $arbre['nodes'][$aid];
          $dernier = $i === count($ariane) - 1;
        ?>
          <?php if ($i > 0): ?>
            <span class="regles-ariane__sep" aria-hidden="true"> › </span>
          <?php endif ?>
          <?php if ($dernier): ?>
            <span class="regles-ariane__courant"><?= h($an['reg_nom']) ?></span>
          <?php else: ?>
            <a href="<?= BASE_URL ?>/regles/regle.php?id=<?= (int)$aid ?>"
               class="regles-ariane__lien"><?= h($an['reg_nom']) ?></a>
          <?php endif ?>
        <?php endforeach ?>
      </nav>
    <?php endif ?>

    <?php // ---- En-tête du nœud ---- ?>
    <header class="regles-noeud__header">
      <h1 class="regles-noeud__titre">
        <?= h($noeud['reg_nom']) ?>
        <?php if ($noeud['reg_type'] === 'glossaire'): ?>
          <span class="regles-badge regles-badge--glossaire">Glossaire</span>
        <?php endif ?>
        <?php if (!$noeud['reg_visible']): ?>
          <span class="regles-badge regles-badge--brouillon">Brouillon</span>
        <?php endif ?>
      </h1>
    </header>

    <?php // ---- Corps texte ---- ?>
    <?php if ($noeud['reg_texte']): ?>
      <div class="regles-noeud__texte" id="regles-texte">
        <?= $noeud['reg_texte'] ?>
      </div>
    <?php elseif (empty($enfants) && $peut_editer): ?>
      <p class="regles-vide">
        Ce nœud n'a pas encore de contenu.
        <a href="#" onclick="ouvrirModifier('<?= BASE_URL ?>/include/ajax/modifier/regle.php', <?= $id ?>); return false;">
          Ajouter du contenu
        </a>
      </p>
    <?php endif ?>

    <?php // ---- Sous-sommaire des enfants ---- ?>
    <?php if (!empty($enfants)): ?>
      <section class="regles-sous-sommaire" aria-label="Sections de ce chapitre">
        <ul class="regles-sous-sommaire__liste">
          <?php foreach ($enfants as $enf): ?>
            <li class="regles-sous-sommaire__item<?= $enf['reg_type'] === 'glossaire' ? ' regles-sous-sommaire__item--glossaire' : '' ?>">
              <a href="<?= BASE_URL ?>/regles/regle.php?id=<?= (int)$enf['reg_id'] ?>"
                 class="regles-sous-sommaire__lien">
                <?= h($enf['reg_nom']) ?>
              </a>
              <?php if (!$enf['reg_visible']): ?>
                <span class="regles-badge regles-badge--brouillon">Brouillon</span>
              <?php endif ?>
              <?php if (!empty($arbre['enfants'][(int)$enf['reg_id']])): ?>
                <span class="regles-sous-sommaire__nb-enfants">
                  <?= count($arbre['enfants'][(int)$enf['reg_id']]) ?>
                </span>
              <?php endif ?>
            </li>
          <?php endforeach ?>
        </ul>

        <?php if ($peut_editer): ?>
          <div class="regles-sous-sommaire__actions">
            <button class="btn btn--sm btn--secondary"
                    onclick="ouvrirModifier('<?= BASE_URL ?>/include/ajax/modifier/regle.php', 0, <?= $id ?>)"
                    title="Ajouter une section ici">
              <i class="fa fa-plus"></i> Ajouter une section
            </button>
          </div>
        <?php endif ?>
      </section>
    <?php endif ?>

    <?php // ---- Navigation précédent / suivant ---- ?>
    <nav class="regles-pagination" aria-label="Navigation précédent / suivant">
      <div class="regles-pagination__prec">
        <?php if ($noeud_prec): ?>
          <a href="<?= BASE_URL ?>/regles/regle.php?id=<?= (int)$id_prec ?>"
             class="regles-pagination__lien" rel="prev">
            <i class="fa fa-chevron-left" aria-hidden="true"></i>
            <span>
              <small>Précédent</small>
              <?= h($noeud_prec['reg_nom']) ?>
            </span>
          </a>
        <?php endif ?>
      </div>

      <div class="regles-pagination__accueil">
        <a href="<?= BASE_URL ?>/regles/index.php" class="regles-pagination__lien" title="Retour à l'accueil des règles">
          <i class="fa fa-list" aria-hidden="true"></i>
        </a>
      </div>

      <div class="regles-pagination__suiv">
        <?php if ($noeud_suiv): ?>
          <a href="<?= BASE_URL ?>/regles/regle.php?id=<?= (int)$id_suiv ?>"
             class="regles-pagination__lien" rel="next">
            <span>
              <small>Suivant</small>
              <?= h($noeud_suiv['reg_nom']) ?>
            </span>
            <i class="fa fa-chevron-right" aria-hidden="true"></i>
          </a>
        <?php endif ?>
      </div>
    </nav>

  </article><?php // .regles-contenu ?>
</div><?php // .regles-layout ?>

<script>
  var BASE_URL = <?= json_encode(BASE_URL) ?>;
  var REGLES_PEUT_EDITER = <?= $peut_editer ? 'true' : 'false' ?>;
  var REGLES_ID_COURANT  = <?= $id ?>;
  var REGLES_URL_ENREG   = <?= json_encode(BASE_URL . '/regles/enregistrement.php') ?>;
  var REGLES_URL_GLOSSAIRE = <?= json_encode(BASE_URL . '/include/ajax/detail-pp-sub/glossaire.php') ?>;
  <?php if ($q): ?>
  var REGLES_TERME_SURLIGNÉ = <?= json_encode($q) ?>;
  <?php endif ?>
</script>

<?php require_once '../include/footer.php'; ?>
