<?php
// include/ajax/detail-pp-sub/tableaux-picker.php
// Sélecteur de tableau appelé depuis l'éditeur de règle (SP-TB4).
// S'affiche dans #detail-pp-sub (z-index 300), donc au-dessus de #modification
// (250) qui porte le formulaire de la règle en cours d'édition.
//
// La création d'un tableau n'est PAS proposée ici : le formulaire de création
// occuperait #modification et écraserait la règle en cours de saisie. Le lien
// « Gérer les tableaux » ouvre donc regles/tableaux.php dans un nouvel onglet.
//
// Paramètres GET :
//   q (string) — filtre optionnel
//
// Référence : doc/ARCHITECTURE_0_REFERENCE.md §9c

require_once __DIR__ . '/../../db.php';
require_once __DIR__ . '/../../auth.php';
require_once __DIR__ . '/../../helpers.php';
require_once __DIR__ . '/../../tableau-parser.php';

requireAuth();
if (!canEditCompendium()):
  http_response_code(403);
  echo '<p class="erreur">Accès refusé.</p>';
  exit;
endif;

$q          = strParam($_GET['q'] ?? '');
$ruleset_id = (int)($_SESSION['ruleset_var_id'] ?? 1);

$where  = ['tab_ruleset_var_id = ?'];
$params = [$ruleset_id];
if ($q !== ''):
  $where[]  = '(tab_nom LIKE ? OR tab_slug LIKE ?)';
  $params[] = '%' . $q . '%';
  $params[] = '%' . $q . '%';
endif;

$stmt = $db->prepare('
  SELECT tab_id, tab_slug, tab_nom, tab_contenu, tab_visible
  FROM   dd_tableaux
  WHERE  ' . implode(' AND ', $where) . '
  ORDER  BY tab_nom ASC
  LIMIT  200
');
$stmt->execute($params);
$tableaux = $stmt->fetchAll();
?>

<div class="tableaux-picker">

  <h3 class="overlay-titre">Insérer un tableau</h3>

  <div class="tableaux-picker__recherche">
    <input type="text" class="form-control" id="tab-picker-q"
           placeholder="Filtrer…" value="<?= h($q) ?>" autocomplete="off">
    <a class="btn btn--sm btn--secondary"
       href="<?= BASE_URL ?>/regles/tableaux.php" target="_blank" rel="noopener"
       title="Ouvrir la gestion des tableaux dans un nouvel onglet">
      <i class="fa fa-cog"></i> Gérer
    </a>
  </div>

  <?php if (empty($tableaux)): ?>
    <p class="text-muted">
      Aucun tableau pour ce ruleset<?= $q !== '' ? ' avec ce filtre' : '' ?>.
    </p>
  <?php else: ?>
    <ul class="tableaux-picker__liste">
      <?php foreach ($tableaux as $t): ?>
        <?php $struct = tableauParser((string)$t['tab_contenu']) ?>
        <li class="tableaux-picker__item">
          <button type="button" class="tableaux-picker__btn"
                  data-slug="<?= h($t['tab_slug']) ?>">
            <span class="tableaux-picker__nom">
              <?= h($t['tab_nom']) ?>
              <?php if (!$t['tab_visible']): ?>
                <span class="regles-badge regles-badge--brouillon">Brouillon</span>
              <?php endif ?>
            </span>
            <span class="tableaux-picker__meta">
              <?= $struct['nb_cols'] ?> col. · <?= count($struct['lignes']) ?> lignes
            </span>
            <code class="tableaux-picker__tag">[[tab:<?= h($t['tab_slug']) ?>]]</code>
          </button>
        </li>
      <?php endforeach ?>
    </ul>
  <?php endif ?>

</div>

<script>
  (function () {
    var racine = document.querySelector('.tableaux-picker');
    if (!racine) return;

    // Insertion dans l'éditeur TinyMCE désigné par REGLES_TINYMCE_ACTIF
    racine.addEventListener('click', function (e) {
      var btn = e.target.closest('.tableaux-picker__btn');
      if (!btn) return;
      var slug = btn.getAttribute('data-slug');
      if (slug && typeof window.reglesInsererTableau === 'function') {
        window.reglesInsererTableau(slug);
      }
    });

    // Filtre : recharge le picker sur Entrée
    var champ = document.getElementById('tab-picker-q');
    if (champ) {
      champ.addEventListener('keydown', function (e) {
        if (e.key !== 'Enter') return;
        e.preventDefault();
        actualiserPageSub(
          BASE_URL + '/include/ajax/detail-pp-sub/tableaux-picker.php',
          { q: champ.value }
        );
      });
    }
  }());
</script>
