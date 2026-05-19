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
// Filtres spécifiques
// Catégorie : filtrée par ruleset courant
// Visible   : filtre MJ/admin uniquement (DD3.5 — champ om_visible)
// ============================================================

$filtres = [
  [
    'type'         => 'select',
    'name'         => 'f_om_com_id',
    'label'        => 'Catégorie',
    'champ'        => 'om.om_com_id',
    'query'        => 'SELECT com_id val, com_nom lab
                       FROM dd_categorie_objet_magique
                       WHERE com_ruleset_var_id = :ruleset_id
                       ORDER BY com_nom',
    'query_params' => [':ruleset_id' => $ruleset_id],
  ],
];

// ============================================================
// Configuration de la liste
// champ_camp => 'om.om_camp_id' : les objets supportent le homebrew
// om_visible  : les joueurs non éditeurs ne voient que om_visible = 1
//   → géré via extra_where ci-dessous
// ============================================================

$extra_where = '';
if (!canEditCompendium()):
  $extra_where = 'om.om_visible = 1';
endif;

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
