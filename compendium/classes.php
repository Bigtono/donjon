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

// clt_id=5 → 'Sous-classe' (DD2024) — même convention que cla_clt_id===2/5
// ailleurs dans le projet (cf. dd_classe_type, pas de constante partagée).
$CLT_SOUS_CLASSE = 5;

// ============================================================
// Filtres
// ============================================================

// Le critère "Classe parente" n'est proposé que lorsque le type "Sous-classe"
// est sélectionné. Sur tout autre type, il est retiré du formulaire ET du GET
// pour ne pas se propager dans les liens de tri et de pagination.
$type_choisi    = intParam($_GET['f_clt_id'] ?? 0);
$filtre_parente = ($type_choisi === $CLT_SOUS_CLASSE);
if (!$filtre_parente):
  unset($_GET['f_cla_par']);
endif;

$filtres = [
  [
    'type'            => 'select',
    'name'            => 'f_clt_id',
    'label'           => 'Type de classe',
    'champ'           => 'cla.cla_clt_id',
    'query'           => 'SELECT clt_id val, clt_nom lab
                          FROM   dd_classe_type
                          WHERE  clt_ruleset_var_id = ?
                          ORDER  BY clt_nom',
    'query_params'    => [$ruleset_id],
    // Recharge la liste dès le changement de type : c'est ce qui fait
    // apparaître (ou disparaître) le critère "Classe parente" ci-dessous.
    'submit_onchange' => true,
  ],
];

if ($filtre_parente):
  $filtres[] = [
    'type'         => 'select',
    'name'         => 'f_cla_par',
    'label'        => 'Classe parente',
    'champ'        => 'cla.cla_cla_id',
    // Seules les classes ayant au moins une sous-classe en base sont proposées.
    'query'        => 'SELECT par.cla_id val, par.cla_nom lab
                       FROM   dd_classes par
                       WHERE  par.cla_ruleset_var_id = ?
                         AND  par.cla_clt_id <> ?
                         AND  EXISTS (SELECT 1 FROM dd_classes sc
                                      WHERE sc.cla_cla_id = par.cla_id)
                       ORDER  BY par.cla_nom',
    'query_params' => [$ruleset_id, $CLT_SOUS_CLASSE],
  ];
endif;

// Type de magie : DD3.5 seulement. DD2024 ne distingue plus profane et divin,
// cla_mag_id n'y est plus qu'un drapeau 0/1 (D-MAG2) — le critère listerait des
// valeurs dd_typemagie que plus aucune classe ne porte.
if ($ruleset_id === 1):
  $filtres[] = [
    'type'         => 'select',
    'name'         => 'f_mag_id',
    'label'        => 'Type de magie',
    'champ'        => 'cla.cla_mag_id',
    'query'        => 'SELECT mag_id val, mag_nom lab
                       FROM   dd_typemagie
                       WHERE  mag_ruleset_var_id = ?
                       ORDER  BY mag_nom',
    'query_params' => [$ruleset_id],
  ];
else:
  unset($_GET['f_mag_id']);
endif;

// Profil d'incantation (SP-MA0) — proposé dans les deux rulesets, avec la
// valeur hors-ruleset écartée : « Répertoire spontané » n'existe qu'en DD3.5,
// « Magie de pacte » qu'en DD2024 (METIER_7_SORTS.md §6).
$filtres[] = [
  'type'         => 'select',
  'name'         => 'f_profinc',
  'label'        => "Profil d'incantation",
  'champ'        => 'cla.cla_profil_incantation',
  'query'        => 'SELECT var_id val, var_valeur lab
                     FROM   dd_variables
                     WHERE  var_cat = \'profinc\' AND var_id <> ?
                     ORDER  BY var_ordre, var_valeur',
  'query_params' => [$ruleset_id === 1 ? PROFINC_PACTE : PROFINC_REPERTOIRE],
];

// ============================================================
// Configuration de la liste
// ============================================================

$listConfig = [
  'entite'        => 'classe',
  'from'          => 'dd_classes cla
                      LEFT JOIN dd_classe_type clt ON clt.clt_id   = cla.cla_clt_id
                      LEFT JOIN dd_typemagie   mag ON mag.mag_id   = cla.cla_mag_id
                      LEFT JOIN dd_variables profinc ON profinc.var_id = cla.cla_profil_incantation
                      LEFT JOIN dd_ressources  res ON res.res_id   = cla.cla_res_id
                      LEFT JOIN dd_classes  clapar ON clapar.cla_id = cla.cla_cla_id',
  'champ_id'      => 'cla.cla_id',
  'champ_res'     => 'cla.cla_res_id',
  'champ_ruleset' => 'cla.cla_ruleset_var_id',
  'champ_public'    => 'cla.cla_public',
  'champ_visible'   => 'cla.cla_visible',
  'champ_res_owner' => 'res.res_j_id',
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
      // Sous-classe (DD2024) : la classe de base est rappelée entre parenthèses.
      // Les autres types n'ont pas de cla_cla_id → libellé du type seul.
      'sql'    => "CONCAT(clt.clt_nom,
                     IF(clapar.cla_nom IS NULL, '', CONCAT(' (', clapar.cla_nom, ')')))",
      'champ'  => 'clt_nom',
      'label'  => 'Type',
      'mobile' => false,
      'tri'    => true,
    ],
    [
      // DD3.5 : abréviation du type de magie (Prof / Div).
      // DD2024 : la distinction n'existe plus — on affiche le profil d'incantation.
      'sql'    => $ruleset_id === 1 ? 'mag.mag_abreviation' : 'profinc.var_valeur',
      'champ'  => $ruleset_id === 1 ? 'mag_abreviation' : 'var_valeur',
      'label'  => $ruleset_id === 1 ? 'Magie' : 'Incantation',
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
