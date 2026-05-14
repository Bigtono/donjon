<?php
// compendium/races.php — Liste des races
require_once '../include/db.php';
require_once '../include/auth.php';
require_once '../include/helpers.php';

requireAuth();

$page_title = 'Races';
$js_module  = 'compendium';
$css_module = 'compendium';

$ruleset_id  = (int)($_SESSION['ruleset_var_id'] ?? 1);
$ruleset_rep = $_SESSION['rulesetRep'] ?? 'DD3.5';

// ============================================================
// Filtres
// ============================================================

$filtres = [
  [
    'type'         => 'select',
    'name'         => 'f_rat_id',
    'label'        => 'Type de race',
    'champ'        => 'ra.ra_rat_id',
    'query'        => 'SELECT rat_id val, rat_nom lab
                       FROM   dd_race_type
                       WHERE  rat_ruleset_var_id = ?
                       ORDER  BY rat_nom',
    'query_params' => [$ruleset_id],
  ],
];

// Filtre modificateur de niveau — DD3.5 uniquement
if ($ruleset_rep === 'DD3.5'):
  $filtres[] = [
    'type'  => 'checkbox',
    'name'  => 'f_mod_niveau',
    'label' => 'Avec modif. de niveau',
    'champ' => 'ra.ra_mod_niveau',
    'sql'   => 'ra.ra_mod_niveau > 0',
  ];
endif;

// ============================================================
// Configuration de la liste
// ============================================================

$listConfig = [
  'entite'        => 'race',
  'from'          => 'dd_races ra
                      LEFT JOIN dd_race_type rat
                             ON rat.rat_id = ra.ra_rat_id
                      LEFT JOIN dd_ressources res
                             ON res.res_id = ra.ra_res_id',
  'champ_id'      => 'ra.ra_id',
  'champ_res'     => 'ra.ra_res_id',
  'champ_ruleset' => 'ra.ra_ruleset_var_id',
  'tri_defaut'    => 'ra.ra_rat_id ASC, ra.ra_nom ASC',
  'colonnes'      => [
    [
      'sql'    => 'ra.ra_nom',
      'champ'  => 'ra_nom',
      'label'  => 'Nom',
      'mobile' => true,
      'tri'    => true,
    ],
    [
      'sql'    => 'rat.rat_nom',
      'champ'  => 'rat_nom',
      'label'  => 'Type de race',
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
  'filtres'      => $filtres,
  'url_detail'   => BASE_URL . '/include/ajax/detail-pp/race.php',
  'url_modifier' => BASE_URL . '/include/ajax/modifier/race.php',
  'url_enreg'    => BASE_URL . '/compendium/enregistrement.php',
  'bulk_actions' => [
    ['valeur' => 'supprimer', 'label' => 'Supprimer la sélection'],
  ],
];

require_once '../include/header.php';
?>

<div class="flex-between mb-md">
  <h1>Races
    <span class="site-header__ruleset"><?= h($ruleset_rep) ?></span>
  </h1>
</div>

<?php
require_once '../include/compendium-liste.php';
require_once '../include/footer.php';
?>
