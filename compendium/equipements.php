<?php
// compendium/equipements.php — Liste des équipements
require_once '../include/db.php';
require_once '../include/auth.php';
require_once '../include/helpers.php';
require_once '../include/liste-parser.php';

requireAuth();

$page_title  = 'Équipements';
$js_module   = 'compendium';
$css_module  = 'compendium';

$ruleset_id  = (int)($_SESSION['ruleset_var_id'] ?? 1);
$ruleset_rep = $_SESSION['rulesetRep'] ?? 'DD3.5';

// ============================================================
// Colonnes calculées en PHP : prix et poids ne sont pas triables en SQL
// (valeur numérique OU texte d'affichage). 'valeurs' doit couvrir toute
// l'entité du ruleset, pas seulement la page.
// ============================================================

$stmt = $db->prepare('
  SELECT eqt_id, eqt_prix_pc, eqt_prix_txt, eqt_poids_g, eqt_poids_txt
  FROM   dd_equipements
  WHERE  eqt_ruleset_var_id = ?
');
$stmt->execute([$ruleset_id]);
$valeurs_prix  = [];
$valeurs_poids = [];
foreach ($stmt->fetchAll() as $r):
  $valeurs_prix[(int)$r['eqt_id']]  = formaterPrixPc($r['eqt_prix_pc'] !== null ? (int)$r['eqt_prix_pc'] : null, $r['eqt_prix_txt']);
  $valeurs_poids[(int)$r['eqt_id']] = formaterPoidsG($r['eqt_poids_g'] !== null ? (int)$r['eqt_poids_g'] : null, $r['eqt_poids_txt']);
endforeach;

// ============================================================
// Filtre Famille — inclut les sous-catégories (« Armes » = toutes les armes).
// Le moteur n'applique que « champ = valeur » aux filtres select : on passe donc
// par le type 'exists', dont la clause SQL est libre, avec la liste des
// descendants calculée ici (entiers uniquement — aucune valeur GET dans le SQL).
// ============================================================

$arbre       = catEquipementArbre($db, $ruleset_id);
$fam_get     = intParam($_GET['f_eqt_cae_id'] ?? 0);
$ids_famille = isset($arbre['noeuds'][$fam_get]) ? catEquipementDescendants($arbre, $fam_get) : [0];

// ============================================================
// Configuration de la liste
// ============================================================

$listConfig = [
  'entite'        => 'equipement',
  'from'          => 'dd_equipements eqt
                      LEFT JOIN dd_categorie_equipement cae ON cae.cae_id = eqt.eqt_cae_id
                      LEFT JOIN dd_ressources res ON res.res_id = eqt.eqt_res_id',
  'champ_id'      => 'eqt.eqt_id',
  'champ_res'     => 'eqt.eqt_res_id',
  'champ_ruleset' => 'eqt.eqt_ruleset_var_id',
  'champ_camp'    => 'eqt.eqt_camp_id',
  'champ_public'    => 'eqt.eqt_public',
  'champ_visible'   => 'eqt.eqt_visible',
  'champ_res_owner' => 'res.res_j_id',
  'extra_where'   => canEditCompendium() ? '' : 'eqt.eqt_visible = 1',
  'colonnes'      => [
    ['sql' => 'eqt.eqt_nom',         'champ' => 'eqt_nom',         'label' => 'Nom',     'mobile' => true,  'tri' => true],
    ['sql' => 'cae.cae_nom',         'champ' => 'cae_nom',         'label' => 'Famille', 'mobile' => false, 'tri' => true],
    ['valeurs' => $valeurs_prix,     'champ' => 'eqt_prix',        'label' => 'Prix',    'mobile' => false, 'tri' => false],
    ['valeurs' => $valeurs_poids,    'champ' => 'eqt_poids',       'label' => 'Poids',   'mobile' => false, 'tri' => false],
    ['sql' => 'res.res_abreviation', 'champ' => 'res_abreviation', 'label' => 'Source',  'mobile' => false, 'tri' => false],
  ],
  'filtres'      => [
    [
      'type'         => 'exists',
      'name'         => 'f_eqt_cae_id',
      'label'        => 'Famille',
      'sql'          => 'eqt.eqt_cae_id IN (' . implode(',', array_map('intval', $ids_famille)) . ') AND ? <> 0',
      'query'        => "SELECT c.cae_id val, CONCAT_WS(' › ', p2.cae_nom, p1.cae_nom, c.cae_nom) lab
                         FROM dd_categorie_equipement c
                         LEFT JOIN dd_categorie_equipement p1 ON p1.cae_id = c.cae_cae_id
                         LEFT JOIN dd_categorie_equipement p2 ON p2.cae_id = p1.cae_cae_id
                         WHERE c.cae_ruleset_var_id = :ruleset_id
                         ORDER BY lab",
      'query_params' => [':ruleset_id' => $ruleset_id],
    ],
  ],
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
