<?php
// regles/tableaux.php — Liste des tableaux de données du ruleset actif (SP-TB3)
//
// Paramètres GET :
//   q      (string) — filtre texte sur le nom / le slug
//   ecran  (1)      — n'affiche que les tableaux retenus pour l'écran du MJ
//
// Le moteur compendium-liste.php ne s'applique pas au module Règles
// (scoping ruleset seul, pas de sources actives) — cf. ARCHITECTURE §9b.
//
// Référence : doc/ARCHITECTURE_0_REFERENCE.md §9c

require_once '../include/db.php';
require_once '../include/auth.php';
require_once '../include/helpers.php';
require_once '../include/tableau-parser.php';

requireAuth();

$q           = strParam($_GET['q'] ?? '');
$ecran_seul  = isset($_GET['ecran']);
$ruleset_id  = (int)($_SESSION['ruleset_var_id'] ?? 1);
$ruleset_rep = $_SESSION['rulesetRep'] ?? 'DD3.5';
$peut_editer = canEditCompendium();

// ============================================================
// Chargement
// ============================================================
$where  = ['tab_ruleset_var_id = ?'];
$params = [$ruleset_id];

if (!$peut_editer):
  $where[] = 'tab_visible = 1';
endif;
if ($q !== ''):
  $where[] = '(tab_nom LIKE ? OR tab_slug LIKE ?)';
  $params[] = '%' . $q . '%';
  $params[] = '%' . $q . '%';
endif;
if ($ecran_seul):
  $where[] = 'tab_ecran_mj = 1';
endif;

$stmt = $db->prepare('
  SELECT t.tab_id, t.tab_slug, t.tab_nom, t.tab_contenu, t.tab_ecran_mj,
         t.tab_ecran_ordre, t.tab_visible, res.res_nom
  FROM   dd_tableaux t
  LEFT   JOIN dd_ressources res ON res.res_id = t.tab_res_id
  WHERE  ' . implode(' AND ', $where) . '
  ORDER  BY t.tab_ecran_mj DESC, t.tab_ecran_ordre ASC, t.tab_nom ASC
');
$stmt->execute($params);
$tableaux = $stmt->fetchAll();

// ============================================================
// Comptage des usages — une seule requête, comptage en PHP
// ============================================================
// Un tableau peut être référencé par plusieurs règles (« Bonus de maîtrise »
// l'est par deux) : le compte sert d'alerte avant suppression.
$stmt_txt = $db->prepare('
  SELECT reg_texte FROM dd_regles
  WHERE  reg_ruleset_var_id = ? AND reg_texte LIKE ?
');
$stmt_txt->execute([$ruleset_id, '%[[tab:%']);
$corpus = implode("\n", array_column($stmt_txt->fetchAll(), 'reg_texte'));

$usages = [];
foreach ($tableaux as $t):
  $usages[$t['tab_id']] = substr_count($corpus, '[[tab:' . $t['tab_slug'] . ']]');
endforeach;

$page_title = 'Tableaux de règles';
$js_module  = 'regles';
$css_module = 'regles';

require_once '../include/header.php';
?>

<div class="regles-layout regles-layout--pleine">
  <div class="regles-contenu">

    <div class="regles-toolbar">
      <h1 class="regles-titre">
        Tableaux de règles
        <span class="site-header__ruleset"><?= h($ruleset_rep) ?></span>
      </h1>

      <form class="regles-recherche-form" method="get" role="search">
        <input type="text" name="q" class="regles-recherche-input"
               placeholder="Rechercher un tableau…"
               value="<?= h($q) ?>" autocomplete="off">
        <?php if ($ecran_seul): ?>
          <input type="hidden" name="ecran" value="1">
        <?php endif ?>
        <button type="submit" class="btn btn--sm" title="Rechercher">
          <i class="fa fa-search"></i>
        </button>
      </form>

      <div class="regles-toolbar__actions">
        <a class="btn btn--sm <?= $ecran_seul ? 'btn--primary' : 'btn--secondary' ?>"
           href="?<?= $ecran_seul ? '' : 'ecran=1' ?>"
           title="Filtrer sur les tableaux de l'écran du MJ">
          <i class="fa fa-star"></i> Écran du MJ
        </a>
        <a class="btn btn--sm btn--secondary" href="<?= BASE_URL ?>/regles/index.php">
          <i class="fa fa-book-open"></i> Règles
        </a>
        <?php if ($peut_editer): ?>
          <button class="btn btn--sm btn--primary"
                  onclick="ouvrirModifier('<?= BASE_URL ?>/include/ajax/modifier/tableau.php', 0)"
                  title="Nouveau tableau">
            <i class="fa fa-plus"></i> Nouveau tableau
          </button>
        <?php endif ?>
      </div>
    </div>

    <?php if (empty($tableaux)): ?>
      <p class="regles-vide">
        Aucun tableau pour ce ruleset<?= $q !== '' ? ' avec ce filtre' : '' ?>.
        <?php if ($peut_editer): ?>
          <a href="#" onclick="ouvrirModifier('<?= BASE_URL ?>/include/ajax/modifier/tableau.php', 0); return false;">
            Créer le premier
          </a>.
        <?php endif ?>
      </p>
    <?php else: ?>

      <table class="table-std reg-tab-liste">
        <thead>
          <tr>
            <th>Nom</th>
            <th>Tag à insérer</th>
            <th class="reg-tab__c--center">Colonnes</th>
            <th class="reg-tab__c--center">Usages</th>
            <th class="reg-tab__c--center">Écran MJ</th>
            <th>Source</th>
            <?php if ($peut_editer): ?><th></th><?php endif ?>
          </tr>
        </thead>
        <tbody>
          <?php foreach ($tableaux as $t): ?>
            <?php
              $struct = tableauParser((string)$t['tab_contenu']);
              $nb_use = $usages[$t['tab_id']] ?? 0;
            ?>
            <tr class="reg-tab-liste__ligne<?= $t['tab_visible'] ? '' : ' reg-tab-liste__ligne--masque' ?>">
              <td class="reg-tab-liste__nom"
                  onclick="actualiserPage('<?= BASE_URL ?>/include/ajax/detail-pp/tableau.php', {id: <?= (int)$t['tab_id'] ?>}, 'liste')">
                <?= h($t['tab_nom']) ?>
                <?php if (!$t['tab_visible']): ?>
                  <span class="regles-badge regles-badge--brouillon">Brouillon</span>
                <?php endif ?>
              </td>
              <td>
                <code class="reg-tab-liste__tag"
                      onclick="reglesCopierTag(this)"
                      title="Cliquer pour copier">[[tab:<?= h($t['tab_slug']) ?>]]</code>
              </td>
              <td class="reg-tab__c--center"><?= $struct['nb_cols'] ?></td>
              <td class="reg-tab__c--center">
                <?php if ($nb_use === 0): ?>
                  <span class="text-muted" title="Ce tableau n'est référencé par aucune règle">—</span>
                <?php else: ?>
                  <?= $nb_use ?>
                <?php endif ?>
              </td>
              <td class="reg-tab__c--center">
                <?php if ($t['tab_ecran_mj']): ?>
                  <i class="fa fa-star" title="Écran du MJ — position <?= (int)$t['tab_ecran_ordre'] ?>"></i>
                <?php endif ?>
              </td>
              <td class="text-muted"><?= h((string)($t['res_nom'] ?? '')) ?></td>
              <?php if ($peut_editer): ?>
                <td class="col-action">
                  <button class="btn btn-icon btn--sm"
                          onclick="ouvrirModifier('<?= BASE_URL ?>/include/ajax/modifier/tableau.php', <?= (int)$t['tab_id'] ?>)"
                          title="Modifier"><i class="fa fa-edit"></i></button>
                  <button class="btn btn-icon btn--sm"
                          onclick="tableauConfirmerSuppression(<?= (int)$t['tab_id'] ?>, <?= $nb_use ?>)"
                          title="Supprimer"><i class="fa fa-trash"></i></button>
                </td>
              <?php endif ?>
            </tr>
          <?php endforeach ?>
        </tbody>
      </table>

    <?php endif ?>

  </div>
</div>

<script>
  var BASE_URL = <?= json_encode(BASE_URL) ?>;
  var REGLES_PEUT_EDITER = <?= $peut_editer ? 'true' : 'false' ?>;
  var TABLEAUX_URL_ENREG = <?= json_encode(BASE_URL . '/regles/tableaux-enregistrement.php') ?>;
</script>

<?php require_once '../include/footer.php'; ?>
