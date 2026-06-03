<?php
// compendium/historiques.php — Liste des historiques (DD2024 uniquement)
require_once '../include/db.php';
require_once '../include/auth.php';
require_once '../include/helpers.php';

requireAuth();

// Conditionné au ruleset DD2024
$ruleset_rep = $_SESSION['rulesetRep'] ?? 'DD3.5';
if ($ruleset_rep !== 'DD2024'):
  $_SESSION['flash_message'] = [
    'type' => 'error',
    'text' => 'Les historiques sont réservés au ruleset DD2024.',
  ];
  header('Location: ' . BASE_URL . '/compendium/index.php');
  exit;
endif;

$page_title  = 'Historiques';
$js_module   = 'compendium';
$css_module  = 'compendium';

$ruleset_id  = (int)($_SESSION['ruleset_var_id'] ?? 2);

// ============================================================
// Configuration de la liste
// ============================================================

$listConfig = [
  'entite'        => 'historique',
  'from'          => 'dd_historiques hi
                      LEFT JOIN dd_ressources res ON res.res_id = hi.hi_res_id',
  'champ_id'      => 'hi.hi_id',
  'champ_res'     => 'hi.hi_res_id',
  'champ_ruleset' => 'hi.hi_ruleset_var_id',
  'colonnes'      => [
    [
      'sql'    => 'hi.hi_nom',
      'champ'  => 'hi_nom',
      'label'  => 'Nom',
      'mobile' => true,
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
  'filtres'      => [],
  'url_detail'   => BASE_URL . '/include/ajax/detail-pp/historique.php',
  'url_modifier' => BASE_URL . '/include/ajax/modifier/historique.php',
  'url_enreg'    => BASE_URL . '/compendium/enregistrement.php',
  'bulk_actions' => [
    ['valeur' => 'supprimer', 'label' => 'Supprimer la sélection'],
  ],
];

require_once '../include/header.php';
?>

<div class="flex-between mb-md">
  <h1>Historiques
    <span class="site-header__ruleset"><?= h($ruleset_rep) ?></span>
  </h1>
</div>

<?php
require_once '../include/compendium-liste.php';
require_once '../include/footer.php';
?>
