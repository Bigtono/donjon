<?php
// compendium/equipements.php — Liste des équipements
require_once '../include/db.php';
require_once '../include/auth.php';
require_once '../include/helpers.php';

requireAuth();

$page_title  = 'Équipements';
$js_module   = 'compendium';
$css_module  = 'compendium';

$ruleset_id  = (int)($_SESSION['ruleset_var_id'] ?? 1);
$ruleset_rep = $_SESSION['rulesetRep'] ?? 'DD3.5';

// ============================================================
// Configuration de la liste
// ============================================================

$listConfig = [
  'entite'        => 'equipement',
  'from'          => 'dd_equipements eqt
                      LEFT JOIN dd_ressources res ON res.res_id = eqt.eqt_res_id',
  'champ_id'      => 'eqt.eqt_id',
  'champ_res'     => 'eqt.eqt_res_id',
  'champ_ruleset' => 'eqt.eqt_ruleset_var_id',
  'colonnes'      => [
    ['sql' => 'eqt.eqt_nom',         'champ' => 'eqt_nom',         'label' => 'Nom',    'mobile' => true,  'tri' => true],
    ['sql' => 'res.res_abreviation', 'champ' => 'res_abreviation', 'label' => 'Source', 'mobile' => false, 'tri' => false],
  ],
  'filtres'      => [],
  'url_detail'   => BASE_URL . '/include/ajax/detail-pp/equipement.php',
  'url_modifier' => BASE_URL . '/include/ajax/modifier/equipement.php',
  'url_enreg'    => BASE_URL . '/compendium/enregistrement.php',
  'bulk_actions' => [
    ['valeur' => 'supprimer', 'label' => 'Supprimer la sélection'],
  ],
];

require_once '../include/header.php';
?>

<div class="flex-between mb-md">
  <h1>Équipements
    <span class="site-header__ruleset"><?= h($ruleset_rep) ?></span>
  </h1>
</div>

<?php
require_once '../include/compendium-liste.php';
require_once '../include/footer.php';
?>
