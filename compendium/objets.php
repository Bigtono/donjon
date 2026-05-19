<?php
// compendium/objets.php — Liste des objets magiques
require_once '../include/db.php';
require_once '../include/auth.php';
require_once '../include/helpers.php';

requireAuth();

$page_title  = 'Objets magiques';
$js_module   = 'compendium';
$css_module  = 'compendium';

$ruleset_id  = (int)($_SESSION['ruleset_var_id'] ?? 1);
$ruleset_rep = $_SESSION['rulesetRep'] ?? 'DD3.5';

// ============================================================
// Filtre "Afficher les propriétés spéciales" — DD3.5 uniquement
// Les catégories com_est_propriete = 1 sont masquées par défaut.
// La case cochée (f_om_props=1) les réintègre dans la liste
// et dans le SELECT de catégorie.
// ============================================================

$afficher_props = $ruleset_id === 1
  && isset($_GET['f_om_props'])
  && $_GET['f_om_props'] === '1';

// Clause conditionnelle pour la query du SELECT catégorie
$where_props_cat = (!$afficher_props && $ruleset_id === 1)
  ? 'AND com_est_propriete = 0'
  : '';

// ============================================================
// Filtres spécifiques
// ============================================================

$filtres = [
  [
    'type'         => 'select',
    'name'         => 'f_om_com_id',
    'label'        => 'Catégorie',
    'champ'        => 'om.om_com_id',
    'query'        => "SELECT com_id val, com_nom lab
                       FROM dd_categorie_objet_magique
                       WHERE com_ruleset_var_id = :ruleset_id
                       $where_props_cat
                       ORDER BY com_nom",
    'query_params' => [':ruleset_id' => $ruleset_id],
  ],
];

// Checkbox "Afficher les propriétés spéciales" — DD3.5 uniquement
if ($ruleset_id === 1):
  $filtres[] = [
    'type'    => 'checkbox',
    'name'    => 'f_om_props',
    'label'   => 'Afficher les propriétés spéciales',
    'checked' => $afficher_props,
  ];
endif;

// ============================================================
// Construction de extra_where
// Cumule les clauses métier non portées par les filtres GET :
//   - visibilité (non-éditeurs ne voient que om_visible = 1)
//   - exclusion des propriétés spéciales (par défaut en DD3.5)
// ============================================================

$extra_where_parts = [];

if (!canEditCompendium()):
  $extra_where_parts[] = 'om.om_visible = 1';
endif;

if (!$afficher_props && $ruleset_id === 1):
  $extra_where_parts[] = 'om.om_com_id NOT IN (
    SELECT com_id FROM dd_categorie_objet_magique
    WHERE com_est_propriete = 1
  )';
endif;

$extra_where = implode(' AND ', $extra_where_parts);

// ============================================================
// Configuration de la liste
// ============================================================

$listConfig = [
  'entite'        => 'objet',
  'from'          => 'dd_objets_magiques om
                      LEFT JOIN dd_categorie_objet_magique com ON com.com_id  = om.om_com_id
                      LEFT JOIN dd_ressources              res ON res.res_id  = om.om_res_id',
  'champ_id'      => 'om.om_id',
  'champ_res'     => 'om.om_res_id',
  'champ_ruleset' => 'om.om_ruleset_var_id',
  'champ_camp'    => 'om.om_camp_id',
  'extra_where'   => $extra_where,
  'colonnes'      => [
    ['sql' => 'om.om_nom',           'champ' => 'om_nom',          'label' => 'Nom',       'mobile' => true,  'tri' => true],
    ['sql' => 'com.com_nom',         'champ' => 'com_nom',         'label' => 'Catégorie', 'mobile' => false, 'tri' => true],
    ['sql' => 'res.res_abreviation', 'champ' => 'res_abreviation', 'label' => 'Source',    'mobile' => false, 'tri' => false],
  ],
  'filtres'       => $filtres,
  'url_detail'    => BASE_URL . '/include/ajax/detail-pp/objet.php',
  'url_modifier'  => BASE_URL . '/include/ajax/modifier/objet.php',
  'url_enreg'     => BASE_URL . '/compendium/enregistrement.php',
  'bulk_actions'  => [
    ['valeur' => 'supprimer', 'label' => 'Supprimer la sélection'],
  ],
];

require_once '../include/header.php';
?>

<div class="flex-between mb-md">
  <h1>Objets magiques
    <span class="site-header__ruleset"><?= h($ruleset_rep) ?></span>
  </h1>
</div>

<?php require_once '../include/compendium-liste.php'; ?>
<?php require_once '../include/footer.php'; ?>
