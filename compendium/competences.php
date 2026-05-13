<?php
// compendium/competences.php — Liste des compétences
require_once '../include/db.php';
require_once '../include/auth.php';
require_once '../include/helpers.php';

requireAuth();

$page_title  = 'Compétences';
$js_module   = 'compendium';
$css_module  = 'compendium';

$ruleset_id  = (int)($_SESSION['ruleset_var_id'] ?? 1);
$ruleset_rep = $_SESSION['rulesetRep'] ?? 'DD3.5';

// ============================================================
// Filtres spécifiques
// comp_car_id → dd_caracteristiques (filtre SELECT via query)
// comp_formation → formation requise (filtre booléen, valeur 1 uniquement —
//   le moteur ignore val=0, donc "sans formation" n'est pas filtrable)
// ============================================================

$filtres = [
  [
    'type'         => 'select',
    'name'         => 'f_comp_car_id',
    'label'        => 'Caractéristique',
    'champ'        => 'comp.comp_car_id',
    'query'        => 'SELECT car_id val, car_nom lab FROM dd_caracteristiques ORDER BY car_nom',
    'query_params' => [],
  ],
  [
    'type'         => 'select',
    'name'         => 'f_comp_formation',
    'label'        => 'Formation',
    'champ'        => 'comp.comp_formation',
    'query'        => "SELECT 1 val, 'Formation requise' lab",
    'query_params' => [],
  ],
];

// ============================================================
// Configuration de la liste
// JOIN dd_caracteristiques pour afficher car_nom dans la colonne
// champ_camp => false : dd_competences n'a pas de comp_camp_id
//   (évite que le moteur n'ajoute comp.comp_camp_id IS NULL)
// ============================================================

$listConfig = [
  'entite'        => 'competence',
  'from'          => 'dd_competences comp
                      LEFT JOIN dd_caracteristiques car ON car.car_id  = comp.comp_car_id
                      LEFT JOIN dd_ressources       res ON res.res_id  = comp.comp_res_id',
  'champ_id'      => 'comp.comp_id',
  'champ_res'     => 'comp.comp_res_id',
  'champ_ruleset' => 'comp.comp_ruleset_var_id',
  'champ_camp'    => false,
  'colonnes'      => [
    ['sql' => 'comp.comp_nom', 'champ' => 'comp_nom', 'label' => 'Nom',              'mobile' => true,  'tri' => true],
    ['sql' => 'car.car_nom',   'champ' => 'car_nom',  'label' => 'Caractéristique',  'mobile' => false, 'tri' => true],
    ['sql' => 'res.res_abreviation', 'champ' => 'res_abreviation', 'label' => 'Source', 'mobile' => false, 'tri' => false],
  ],
  'filtres'       => $filtres,
  'url_detail'    => BASE_URL . '/include/ajax/detail-pp/competence.php',
  'url_modifier'  => BASE_URL . '/include/ajax/modifier/competence.php',
  'url_enreg'     => BASE_URL . '/compendium/enregistrement.php',
  'bulk_actions'  => [
    ['valeur' => 'supprimer', 'label' => 'Supprimer la sélection'],
  ],
];

require_once '../include/header.php';
?>

<div class="flex-between mb-md">
  <h1>Compétences
    <span class="site-header__ruleset"><?= h($ruleset_rep) ?></span>
  </h1>
</div>

<?php
require_once '../include/compendium-liste.php';
require_once '../include/footer.php';
?>
