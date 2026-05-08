<?php
// compendium/sorts.php — Liste des sorts
require_once '../include/db.php';
require_once '../include/auth.php';
require_once '../include/helpers.php';

requireAuth();

$page_title = 'Sorts';
$js_module  = 'compendium';

$ruleset_id  = (int)($_SESSION['ruleset_var_id'] ?? 1);
$ruleset_rep = $_SESSION['rulesetRep'] ?? 'DD3.5';

// ============================================================
// Filtres spécifiques (conditionnels selon le ruleset)
// ============================================================

// Filtre classe lanceur de sort — commun aux deux rulesets
// Utilise EXISTS pour éviter les doublons (un sort peut appartenir
// à plusieurs classes)
$filtres = [
  [
    'type'         => 'exists',
    'name'         => 'f_cla_id',
    'label'        => 'Classe',
    'sql'          => 'EXISTS (
                         SELECT 1 FROM dd_sortclasse
                         WHERE  sc_so_id = so.so_id
                           AND  sc_cla_id = ?
                       )',
    'query'        => 'SELECT cla_id val, cla_nom lab
                       FROM   dd_classes
                       WHERE  cla_mag_id > 0
                         AND  cla_ruleset_var_id = ?
                         AND  cla_clt_id = 1
                       ORDER  BY cla_nom',
    'query_params' => [$ruleset_id],
  ],
];

// ============================================================
// Configuration de la liste
// ============================================================

$listConfig = [
  'entite'        => 'sort',
  'from'          => 'dd_sorts so
                      LEFT JOIN dd_colleges co
                             ON co.co_id = so.so_co_id
                      LEFT JOIN dd_ressources res
                             ON res.res_id = so.so_res_id',
  'champ_id'      => 'so.so_id',
  'champ_res'     => 'so.so_res_id',
  'champ_ruleset' => 'so.so_ruleset_var_id',
  'colonnes'      => [
    [
      'sql'    => 'so.so_nom',
      'champ'  => 'so_nom',
      'label'  => 'Nom',
      'mobile' => true,
      'tri'    => true,
    ],
    [
      'sql'    => 'co.co_nom',
      'champ'  => 'co_nom',
      'label'  => 'École',
      'mobile' => false,
      'tri'    => true,
    ],
    [
      'sql'    => 'res.res_abreviation',
      'champ'  => 'res_abreviation',
      'label'  => 'Source',
      'mobile' => false,
      'tri'    => false,
    ],
  ],
  'filtres'       => $filtres,
  'url_detail'    => BASE_URL . '/include/ajax/detail-pp/sort.php',
  'url_modifier'  => BASE_URL . '/include/ajax/modifier/sort.php',
  'url_enreg'     => BASE_URL . '/compendium/enregistrement.php',
  'bulk_actions'  => [
    ['valeur' => 'supprimer', 'label' => 'Supprimer la sélection'],
  ],
];

require_once '../include/header.php';
?>

<div class="flex-between mb-md">
  <h1>Sorts
    <span class="site-header__ruleset"><?= h($ruleset_rep) ?></span>
  </h1>
</div>

<?php
require_once '../include/compendium-liste.php';
require_once '../include/footer.php';
?>
