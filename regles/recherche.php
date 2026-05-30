<?php
// regles/recherche.php — Recherche dans les règles
//
// Paramètre GET :
//   q (string) — terme recherché
//
// Moteur : MATCH...AGAINST (FULLTEXT) avec repli LIKE si terme court.
// Résultats enrichis : fil d'Ariane + extrait surligné.
//
// Référence : doc/ARCHITECTURE_0_REFERENCE.md §9b

require_once '../include/db.php';
require_once '../include/auth.php';
require_once '../include/helpers.php';
require_once '../include/regles-arbre.php';

requireAuth();

$q           = strParam($_GET['q'] ?? '');
$ruleset_id  = (int)($_SESSION['ruleset_var_id'] ?? 1);
$ruleset_rep = $_SESSION['rulesetRep'] ?? 'DD3.5';
$peut_editer = canEditCompendium();

$page_title = 'Recherche — Règles de jeu';
$js_module  = 'regles';
$css_module = 'regles';

// ============================================================
// Recherche (uniquement si terme fourni)
// ============================================================
$resultats   = [];
$erreur      = '';
$mode_search = ''; // 'fulltext' | 'like' | ''

if ($q !== ''):
  // FULLTEXT nécessite ≥ 3 caractères (innodb_ft_min_token_size = 3 par défaut)
  $q_clean = trim($q);
  $utiliser_fulltext = mb_strlen($q_clean) >= 3;

  $cond_visible = $peut_editer ? '' : 'AND r.reg_visible = 1';

  try {
    if ($utiliser_fulltext):
      // Tentative FULLTEXT BOOLEAN MODE
      $stmt = $db->prepare("
        SELECT r.reg_id, r.reg_nom, r.reg_texte, r.reg_type, r.reg_visible,
               MATCH(r.reg_nom, r.reg_texte) AGAINST (? IN BOOLEAN MODE) AS score
        FROM   dd_regles r
        WHERE  r.reg_ruleset_var_id = ?
          $cond_visible
          AND MATCH(r.reg_nom, r.reg_texte) AGAINST (? IN BOOLEAN MODE)
        ORDER  BY score DESC
        LIMIT  50
      ");
      $stmt->execute([$q_clean, $ruleset_id, $q_clean]);
      $resultats = $stmt->fetchAll();
      $mode_search = 'fulltext';
    endif;

    // Repli LIKE si terme court ou aucun résultat FULLTEXT
    if (empty($resultats)):
      $pattern = '%' . $q_clean . '%';
      $stmt = $db->prepare("
        SELECT r.reg_id, r.reg_nom, r.reg_texte, r.reg_type, r.reg_visible,
               0 AS score
        FROM   dd_regles r
        WHERE  r.reg_ruleset_var_id = ?
          $cond_visible
          AND (r.reg_nom LIKE ? OR r.reg_texte LIKE ?)
        ORDER  BY r.reg_type = 'glossaire' DESC, r.reg_nom ASC
        LIMIT  50
      ");
      $stmt->execute([$ruleset_id, $pattern, $pattern]);
      $resultats = $stmt->fetchAll();
      $mode_search = 'like';
    endif;
  } catch (PDOException $e) {
    error_log('Recherche règles : ' . $e->getMessage());
    $erreur = 'Une erreur est survenue lors de la recherche.';
  }
endif;

// ============================================================
// Chargement de l'arbre pour les fils d'Ariane
// ============================================================
$arbre = (!empty($resultats) || $q !== '')
  ? chargerArbreRegles($db, $ruleset_id, $peut_editer)
  : ['nodes' => [], 'enfants' => [], 'racines' => []];

// ============================================================
// Helpers affichage
// ============================================================

function _extraitTexte(string $html, string $q, int $longueur = 200): string
{
  // Retire les balises HTML
  $texte = strip_tags($html);
  // Cherche la position du terme
  $pos = mb_stripos($texte, $q);
  if ($pos === false):
    $debut = 0;
  else:
    $debut = max(0, $pos - 60);
  endif;
  $extrait = mb_substr($texte, $debut, $longueur);
  if ($debut > 0) $extrait = '…' . $extrait;
  if (mb_strlen($texte) > $debut + $longueur) $extrait .= '…';
  return $extrait;
}

function _surlignerExtrait(string $extrait, string $q): string
{
  if ($q === '') return htmlspecialchars($extrait, ENT_QUOTES, 'UTF-8');
  $qEsc   = preg_quote($q, '/');
  $result = preg_replace_callback(
    '/(' . $qEsc . ')/ui',
    fn($m) => '<mark class="regles-surligné">' . htmlspecialchars($m[1], ENT_QUOTES, 'UTF-8') . '</mark>',
    htmlspecialchars($extrait, ENT_QUOTES, 'UTF-8')
  );
  return $result ?? htmlspecialchars($extrait, ENT_QUOTES, 'UTF-8');
}

require_once '../include/header.php';
?>

<div class="regles-layout">

  <?php // ---- Sommaire (latéral) ---- ?>
  <aside class="regles-sommaire-aside" id="regles-sommaire-aside">
    <button class="regles-sommaire__toggle-mobile" id="regles-sommaire-toggle"
            aria-expanded="false" title="Afficher / masquer le sommaire">
      <i class="fa fa-bars"></i> Sommaire
    </button>
    <div class="regles-sommaire__inner" id="regles-sommaire-inner">
      <?= rendreSommaire($arbre, null) ?>
    </div>
  </aside>

  <?php // ---- Contenu ---- ?>
  <div class="regles-contenu" id="regles-contenu">

    <div class="regles-toolbar">
      <h1 class="regles-titre">
        Recherche
        <span class="site-header__ruleset"><?= h($ruleset_rep) ?></span>
      </h1>

      <form class="regles-recherche-form" action="<?= BASE_URL ?>/regles/recherche.php" method="get"
            role="search" aria-label="Rechercher dans les règles">
        <input type="text" name="q" class="regles-recherche-input"
               placeholder="Rechercher une règle…"
               value="<?= h($q) ?>" autocomplete="off" autofocus>
        <button type="submit" class="btn btn--sm" title="Rechercher">
          <i class="fa fa-search"></i>
        </button>
      </form>
    </div>

    <?php if ($erreur): ?>
      <p class="erreur"><?= h($erreur) ?></p>

    <?php elseif ($q === ''): ?>
      <p class="regles-vide">Saisissez un terme pour rechercher dans les règles.</p>

    <?php elseif (empty($resultats)): ?>
      <p class="regles-vide">
        Aucun résultat pour <strong><?= h($q) ?></strong>.
      </p>

    <?php else: ?>
      <p class="regles-recherche__meta">
        <?= count($resultats) ?> résultat<?= count($resultats) > 1 ? 's' : '' ?>
        pour <strong><?= h($q) ?></strong>
        <span class="regles-recherche__mode">
          (<?= $mode_search === 'fulltext' ? 'recherche plein texte' : 'recherche approchée' ?>)
        </span>
      </p>

      <ul class="regles-recherche__liste">
        <?php foreach ($resultats as $r):
          $rid    = (int)$r['reg_id'];
          $ariane = filAriane($arbre, $rid);
          $extrait = $r['reg_texte']
            ? _extraitTexte($r['reg_texte'], $q)
            : '';
        ?>
          <li class="regles-recherche__item<?= $r['reg_type'] === 'glossaire' ? ' regles-recherche__item--glossaire' : '' ?>">

            <?php // ---- Fil d'Ariane du résultat ---- ?>
            <?php if (count($ariane) > 1): ?>
              <div class="regles-recherche__ariane">
                <?php foreach ($ariane as $i => $aid):
                  if ($i === count($ariane) - 1) break; // on s'arrête avant le nœud lui-même
                  $an = $arbre['nodes'][$aid];
                ?>
                  <?php if ($i > 0): ?>
                    <span aria-hidden="true"> › </span>
                  <?php endif ?>
                  <a href="<?= BASE_URL ?>/regles/regle.php?id=<?= (int)$aid ?>">
                    <?= h($an['reg_nom']) ?>
                  </a>
                <?php endforeach ?>
              </div>
            <?php endif ?>

            <?php // ---- Lien principal vers le nœud ---- ?>
            <a href="<?= BASE_URL ?>/regles/regle.php?id=<?= $rid ?>&amp;q=<?= urlencode($q) ?>"
               class="regles-recherche__titre">
              <?= _surlignerExtrait($r['reg_nom'], $q) ?>
              <?php if ($r['reg_type'] === 'glossaire'): ?>
                <span class="regles-badge regles-badge--glossaire">Glossaire</span>
              <?php endif ?>
              <?php if (!$r['reg_visible']): ?>
                <span class="regles-badge regles-badge--brouillon">Brouillon</span>
              <?php endif ?>
            </a>

            <?php // ---- Extrait surligné ---- ?>
            <?php if ($extrait): ?>
              <p class="regles-recherche__extrait">
                <?= _surlignerExtrait($extrait, $q) ?>
              </p>
            <?php endif ?>

          </li>
        <?php endforeach ?>
      </ul>
    <?php endif ?>

  </div><?php // .regles-contenu ?>
</div><?php // .regles-layout ?>

<script>
  var BASE_URL = <?= json_encode(BASE_URL) ?>;
  var REGLES_PEUT_EDITER = <?= $peut_editer ? 'true' : 'false' ?>;
</script>

<?php require_once '../include/footer.php'; ?>
