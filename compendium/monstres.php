<?php
// compendium/monstres.php — Liste des monstres
require_once '../include/db.php';
require_once '../include/auth.php';
require_once '../include/helpers.php';

requireAuth();

$page_title  = 'Monstres';
$js_module   = 'compendium';
$css_module  = 'compendium';

$ruleset_id  = (int)($_SESSION['ruleset_var_id'] ?? 1);
$ruleset_rep = $_SESSION['rulesetRep'] ?? 'DD3.5';
$est_dd2024  = $ruleset_id !== 1;
$uid         = (int)($_SESSION['j_id'] ?? 0);

// ============================================================
// Filtres
// ============================================================
$filtres = [
  [
    'type'         => 'select',
    'name'         => 'f_mo_mocat',
    'label'        => 'Catégorie',
    'champ'        => 'mo.mo_mocat_id',
    'query'        => "SELECT mocat_id val, mocat_nom lab
                       FROM dd_monstres_categories
                       WHERE mocat_ruleset_var_id = :ruleset_id
                       ORDER BY mocat_nom",
    'query_params' => [':ruleset_id' => $ruleset_id],
  ],
];

// Groupe : concept DD2024 uniquement
if ($est_dd2024):
  $filtres[] = [
    'type'         => 'select',
    'name'         => 'f_mo_mogr',
    'label'        => 'Groupe',
    'champ'        => 'mo.mo_mogr_id',
    'query'        => "SELECT mogr_id val, mogr_nom lab
                       FROM dd_monstres_groupes
                       WHERE mogr_ruleset_var_id = :ruleset_id
                       ORDER BY mogr_nom",
    'query_params' => [':ruleset_id' => $ruleset_id],
  ];
endif;

// FP : référentiel dd_fp, ordonné par valeur ; on filtre sur le libellé stocké
$filtres[] = [
  'type'         => 'select',
  'name'         => 'f_mo_fp',
  'label'        => 'FP',
  'champ'        => 'mo.mo_fp_id',
  'query'        => "SELECT fp_nom val, fp_nom lab FROM dd_fp ORDER BY fp_valeur",
  'query_params' => [],
];

// ============================================================
// Visibilité : gérée par le moteur générique via champ_res / champ_camp
// (mo_res_id, mo_camp_id) — l'ancienne colonne mo_j_id a été supprimée
// de dd_monstres lors de la migration vers le mécanisme de supplément
// utilisateur commun à toutes les entités du compendium.
// ============================================================

// ============================================================
// Colonnes
// ============================================================
$colonnes = [
  ['sql' => 'mo.mo_nom',       'champ' => 'mo_nom',    'label' => 'Nom',       'mobile' => true,  'tri' => true],
  ['sql' => 'mocat.mocat_nom', 'champ' => 'mocat_nom', 'label' => 'Catégorie', 'mobile' => false, 'tri' => true],
];
if ($est_dd2024):
  $colonnes[] = ['sql' => 'mogr.mogr_nom', 'champ' => 'mogr_nom', 'label' => 'Groupe', 'mobile' => false, 'tri' => true];
endif;
$colonnes[] = ['sql' => 'mo.mo_fp_id',         'champ' => 'mo_fp_id',        'label' => 'FP',     'mobile' => false, 'tri' => false];
$colonnes[] = ['sql' => 'res.res_abreviation', 'champ' => 'res_abreviation', 'label' => 'Source', 'mobile' => false, 'tri' => false];

// ============================================================
// Configuration de la liste
// ============================================================
$listConfig = [
  'entite'        => 'monstre',
  'from'          => 'dd_monstres mo
                      LEFT JOIN dd_monstres_categories mocat ON mocat.mocat_id = mo.mo_mocat_id
                      LEFT JOIN dd_monstres_groupes    mogr  ON mogr.mogr_id   = mo.mo_mogr_id
                      LEFT JOIN dd_ressources          res   ON res.res_id     = mo.mo_res_id',
  'champ_id'      => 'mo.mo_id',
  'champ_res'     => 'mo.mo_res_id',
  'champ_ruleset' => 'mo.mo_ruleset_var_id',
  'champ_camp'    => 'mo.mo_camp_id',
  'colonnes'      => $colonnes,
  'filtres'       => $filtres,
  'url_detail'    => BASE_URL . '/include/ajax/detail-pp/monstre.php',
  'url_modifier'  => BASE_URL . '/include/ajax/modifier/monstre.php',
  'url_enreg'     => BASE_URL . '/compendium/enregistrement.php',
  'bulk_actions'  => [
    ['valeur' => 'supprimer', 'label' => 'Supprimer la sélection'],
  ],
];

require_once '../include/header.php';
?>

<div class="flex-between mb-md">
  <h1>Monstres
    <span class="site-header__ruleset"><?= h($ruleset_rep) ?></span>
  </h1>
</div>

<?php require_once '../include/compendium-liste.php'; ?>
<?php require_once '../include/footer.php'; ?>
