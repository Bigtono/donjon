<?php
// compendium/dons.php — Liste des dons
require_once '../include/db.php';
require_once '../include/auth.php';
require_once '../include/helpers.php';

requireAuth();

$page_title  = 'Dons';
$js_module   = 'compendium';
$css_module  = 'compendium';

$ruleset_id  = (int)($_SESSION['ruleset_var_id'] ?? 1);
$ruleset_rep = $_SESSION['rulesetRep'] ?? 'DD3.5';

// ============================================================
// Filtres spécifiques — catégorie de don (commun aux deux rulesets)
// ============================================================

$filtres = [
  [
    'type'         => 'select',
    'name'         => 'f_dado_id',
    'label'        => 'Catégorie',
    'champ'        => 'do.do_dado_id',
    'query'        => 'SELECT dado_id val, dado_nom lab FROM dd_data_don ORDER BY dado_nom',
    'query_params' => [],
  ],
];

// ============================================================
// Configuration de la liste
// ============================================================

$listConfig = [
  'entite'        => 'don',
  'from'          => 'dd_dons do
                      LEFT JOIN dd_data_don   dad ON dad.dado_id = do.do_dado_id
                      LEFT JOIN dd_ressources res ON res.res_id  = do.do_res_id',
  'champ_id'      => 'do.do_id',
  'champ_res'     => 'do.do_res_id',
  'champ_ruleset' => 'do.do_ruleset_var_id',
  'colonnes'      => [
    ['sql' => 'do.do_nom',           'champ' => 'do_nom',        'label' => 'Nom',       'mobile' => true,  'tri' => true],
    ['sql' => 'dad.dado_nom',        'champ' => 'dado_nom',      'label' => 'Catégorie', 'mobile' => false, 'tri' => true],
    ['sql' => 'res.res_abreviation', 'champ' => 'res_abreviation','label' => 'Source',   'mobile' => false, 'tri' => false],
  ],
  'filtres'      => $filtres,
  'url_detail'   => BASE_URL . '/include/ajax/detail-pp/don.php',
  'url_modifier' => BASE_URL . '/include/ajax/modifier/don.php',
  'url_enreg'    => BASE_URL . '/compendium/enregistrement.php',
  'bulk_actions' => [
    ['valeur' => 'supprimer', 'label' => 'Supprimer la sélection'],
  ],
];

require_once '../include/header.php';
?>

<div class="flex-between mb-md">
  <h1>Dons
    <span class="site-header__ruleset"><?= h($ruleset_rep) ?></span>
  </h1>
</div>

<?php
require_once '../include/compendium-liste.php';
require_once '../include/footer.php';
?>
