<?php
// compendium/classes.php — Liste des classes de personnage
require_once '../include/db.php';
require_once '../include/auth.php';
require_once '../include/helpers.php';

requireAuth();

$page_title  = 'Classes';
$js_module   = 'compendium';
$css_module  = 'compendium';

$ruleset_id  = (int)($_SESSION['ruleset_var_id'] ?? 1);
$ruleset_rep = $_SESSION['rulesetRep'] ?? 'DD3.5';

// ============================================================
// Filtres
// ============================================================

$filtres = [
  [
    'type'         => 'select',
    'name'         => 'f_clt_id',
    'label'        => 'Type de classe',
    'champ'        => 'cla.cla_clt_id',
    'query'        => 'SELECT clt_id val, clt_nom lab
                       FROM   dd_classe_type
                       ORDER  BY clt_nom',
    'query_params' => [],
  ],
  [
    'type'         => 'select',
    'name'         => 'f_mag_id',
    'label'        => 'Type de magie',
    'champ'        => 'cla.cla_mag_id',
    'query'        => 'SELECT mag_id val, mag_nom lab
                       FROM   dd_typemagie
                       WHERE  mag_ruleset_var_id = ?
                       ORDER  BY mag_nom',
    'query_params' => [$ruleset_id],
  ],
];

// ============================================================
// Configuration de la liste
// ============================================================

$listConfig = [
  'entite'        => 'classe',
  'from'          => 'dd_classes cla
                      LEFT JOIN dd_classe_type clt ON clt.clt_id   = cla.cla_clt_id
                      LEFT JOIN dd_typemagie   mag ON mag.mag_id   = cla.cla_mag_id
                      LEFT JOIN dd_ressources  res ON res.res_id   = cla.cla_res_id',
  'champ_id'      => 'cla.cla_id',
  'champ_res'     => 'cla.cla_res_id',
  'champ_ruleset' => 'cla.cla_ruleset_var_id',
  'tri_defaut'    => 'cla.cla_clt_id ASC, cla.cla_nom ASC',
  'colonnes'      => [
    [
      'sql'    => 'cla.cla_nom',
      'champ'  => 'cla_nom',
      'label'  => 'Nom',
      'mobile' => true,
      'tri'    => true,
    ],
    [
      'sql'    => 'clt.clt_nom',
      'champ'  => 'clt_nom',
      'label'  => 'Type',
      'mobile' => false,
      'tri'    => true,
    ],
    [
      'sql'    => 'mag.mag_abreviation',
      'champ'  => 'mag_abreviation',
      'label'  => 'Magie',
      'mobile' => false,
      'tri'    => false,
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
  'url_detail'   => BASE_URL . '/include/ajax/detail-pp/classe.php',
  'url_modifier' => BASE_URL . '/include/ajax/modifier/classe.php',
  'url_enreg'    => BASE_URL . '/compendium/enregistrement.php',
  'bulk_actions' => [
    ['valeur' => 'supprimer', 'label' => 'Supprimer la sélection'],
  ],
];

require_once '../include/header.php';
?>

<div class="flex-between mb-md">
  <h1>Classes
    <span class="site-header__ruleset"><?= h($ruleset_rep) ?></span>
  </h1>
</div>

<?php
require_once '../include/compendium-liste.php';
require_once '../include/footer.php';
?>
