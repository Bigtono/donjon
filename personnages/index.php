<?php
// personnages/index.php — Liste des personnages, filtrée par ruleset actif.
//
// Depuis SP-RS6b, cette page délègue au moteur de liste partagé
// include/compendium-liste.php, comme les 9 listes du compendium et — depuis
// SP-TB10 — tableaux/index.php. Les clés génériques du moteur portent les
// spécificités du module : pas de sources (champ_res absent), pas de filtre
// homebrew (champ_camp=false), scope propriétaire par extra_where, clic de
// ligne vers la fiche (url_ligne) et suppression AJAX vers l'action
// supprimerPersonnage.
//
// SP-PE9 : un administrateur voit tous les personnages du ruleset actif, quel
// que soit leur propriétaire (extra_where levé), avec une colonne et un filtre
// « Joueur » qui n'apparaissent que pour lui. Les accès unitaires (fiche,
// détail, formulaire, enregistrement) reposent déjà sur canAccess(), qui
// autorise l'admin : aucune règle de droit n'est ajoutée ici.
require_once '../include/db.php';
require_once '../include/auth.php';
require_once '../include/helpers.php';

requireAuth();

$page_title = 'Personnages';
$js_module  = 'personnage';
$css_module = 'personnages';

$j_id       = (int)$_SESSION['j_id'];
$ruleset_id = (int)($_SESSION['ruleset_var_id'] ?? 1);
$est_admin  = isAdmin();

require_once '../include/header.php';
?>

<script>
  var perUrlDetail   = <?= json_encode(BASE_URL . '/include/ajax/detail-pp/personnage.php') ?>;
  var perUrlModifier = <?= json_encode(BASE_URL . '/include/ajax/modifier/personnage.php') ?>;
  var perUrlEnreg    = <?= json_encode(BASE_URL . '/personnages/enregistrement.php?ajax=1') ?>;
  var perUrlFiche    = <?= json_encode(BASE_URL . '/personnages/fiche.php') ?>;
</script>

<?php
// Le ruleset actif n'est plus rappelé ici : il est déjà affiché dans le header
// (badge .site-header__ruleset). Bouton d'ajout réduit à son icône (SP-RS6a).
?>
<div class="flex-between mb-md">
  <h1>
    Personnages
    <?php if ($est_admin): ?>
      <span class="text-muted text-sm">(tous les joueurs)</span>
    <?php endif ?>
  </h1>
  <button class="btn btn-primary btn-sm" onclick="ouvrirModifier(perUrlModifier, 0)"
          title="Nouveau personnage" aria-label="Nouveau personnage">
    <i class="fa fa-plus"></i>
  </button>
</div>

<?php
// ============================================================
// CONFIGURATION DU MOTEUR DE LISTE
// ============================================================

// Colonnes — « Joueur » n'est insérée (juste après le nom) que pour l'admin.
$colonnes = [
  ['sql' => 'pe.pe_nom', 'champ' => 'pe_nom', 'label' => 'Nom', 'mobile' => true, 'tri' => true],
];

if ($est_admin):
  $colonnes[] = [
    'sql'    => 'jo.j_pseudo',
    'champ'  => 'joueur_pseudo',
    'label'  => 'Joueur',
    'mobile' => false,
    'tri'    => true,
  ];
endif;

$colonnes[] = [
  'sql'    => "CONCAT(COALESCE(ra_base.ra_nom, '—'),
                      IF(ra_arc.ra_nom IS NULL, '', CONCAT(' / ', ra_arc.ra_nom)))",
  'champ'  => 'race_nom',
  'label'  => 'Race',
  'mobile' => false,
  'tri'    => true,
];

$colonnes[] = [
  'sql'    => '(SELECT GROUP_CONCAT(CONCAT(cla.cla_nom, " ", pc.pc_niveau)
                         ORDER BY cla.cla_nom SEPARATOR " / ")
                  FROM dd_personnages_classes pc
                  JOIN dd_classes cla ON cla.cla_id = pc.pc_cla_id
                 WHERE pc.pc_pe_id = pe.pe_id)',
  'champ'  => 'classes_libelle',
  'label'  => 'Classes',
  'mobile' => false,
  'tri'    => false,
];

$colonnes[] = ['sql' => 'al.al_abreviation', 'champ' => 'alignement', 'label' => 'Alignement', 'mobile' => false, 'tri' => true];
$colonnes[] = ['sql' => 'camp.camp_nom', 'champ' => 'campagne_nom', 'label' => 'Campagne en cours', 'mobile' => false, 'tri' => true];

// Filtre Campagne — le joueur ne voit que ses campagnes ; l'admin voit toutes
// celles du ruleset, suffixées du pseudo du MJ pour départager les homonymes.
if ($est_admin):
  $camp_query  = "SELECT camp.camp_id AS val,
                         CONCAT(camp.camp_nom, ' (', jmj.j_pseudo, ')') AS lab
                    FROM dd_campagnes camp
                    JOIN dd_joueurs jmj ON jmj.j_id = camp.camp_j_id
                   WHERE camp.camp_ruleset_var_id = ? AND camp.camp_supprime = 0
                   ORDER BY camp.camp_nom, jmj.j_pseudo";
  $camp_params = [$ruleset_id];
else:
  $camp_query  = 'SELECT camp_id AS val, camp_nom AS lab
                    FROM dd_campagnes
                   WHERE camp_j_id = ? AND camp_ruleset_var_id = ? AND camp_supprime = 0
                   ORDER BY camp_nom';
  $camp_params = [$j_id, $ruleset_id];
endif;

$filtres = [
  [
    'type'         => 'select',
    'name'         => 'f_camp_id',
    'label'        => 'Campagne',
    'champ'        => 'pe.pe_camp_id',
    'query'        => $camp_query,
    'query_params' => $camp_params,
  ],
  [
    'type'         => 'exists',
    'name'         => 'f_cla_id',
    'label'        => 'Classe',
    'sql'          => 'EXISTS (SELECT 1 FROM dd_personnages_classes pc
                                WHERE pc.pc_pe_id = pe.pe_id AND pc.pc_cla_id = ?)',
    'query'        => 'SELECT cla_id AS val, cla_nom AS lab
                         FROM dd_classes
                        WHERE cla_ruleset_var_id = ?
                        ORDER BY cla_nom',
    'query_params' => [$ruleset_id],
  ],
];

// Filtre Joueur — admin seulement, limité aux joueurs ayant au moins un
// personnage dans le ruleset actif.
if ($est_admin):
  $filtres[] = [
    'type'         => 'select',
    'name'         => 'f_j_id',
    'label'        => 'Joueur',
    'champ'        => 'pe.pe_j_id',
    'query'        => 'SELECT DISTINCT jf.j_id AS val, jf.j_pseudo AS lab
                         FROM dd_joueurs jf
                         JOIN dd_personnages pf ON pf.pe_j_id = jf.j_id
                                               AND pf.pe_ruleset_var_id = ?
                        ORDER BY jf.j_pseudo',
    'query_params' => [$ruleset_id],
  ];
endif;

$listConfig = [
  'entite'        => 'personnage',
  'titre'         => 'Personnages',

  'from' => '
    dd_personnages pe
    LEFT JOIN dd_races       ra_base ON ra_base.ra_id = pe.pe_ra_id
    LEFT JOIN dd_races       ra_arc  ON ra_arc.ra_id  = pe.pe_arc_id AND pe.pe_arc_id > 0
    LEFT JOIN dd_alignements al      ON al.al_id      = pe.pe_al_id
    LEFT JOIN dd_campagnes   camp    ON camp.camp_id  = pe.pe_camp_id
    LEFT JOIN dd_joueurs     jo      ON jo.j_id       = pe.pe_j_id
  ',
  'champ_id'      => 'pe.pe_id',
  'champ_ruleset' => 'pe.pe_ruleset_var_id',

  // Pas de dd_ressources sur les personnages : le moteur n'applique donc ni
  // filtre sources ni bouton Sources (champ_res absent).
  // Pas de filtre homebrew non plus : pe_camp_id désigne la campagne en cours,
  // pas une appartenance à un recueil maison.
  'champ_camp'    => false,

  'colonnes' => $colonnes,
  'filtres'  => $filtres,

  // Un clic sur la ligne ouvre la fiche complète, pas un panneau de détail.
  'url_ligne'    => BASE_URL . '/personnages/fiche.php?id={id}',
  'url_detail'   => BASE_URL . '/include/ajax/detail-pp/personnage.php',
  'url_modifier' => BASE_URL . '/include/ajax/modifier/personnage.php',
  'url_enreg'    => BASE_URL . '/personnages/enregistrement.php?ajax=1',

  // Toute ligne listée est accessible à l'utilisateur (propriétaire via
  // extra_where, ou admin) : le menu ⋮ est ouvert sans passer par le droit
  // d'édition du compendium.
  'edition_libre' => true,
  // Le bouton d'ajout est déjà dans la ligne de titre.
  'avec_ajout'    => false,
  'bulk_actions'  => [],
  // enregistrement.php du module attend une action nommée en JSON.
  'suppression'   => ['mode' => 'ajax', 'action' => 'supprimerPersonnage', 'param' => 'id'],
];

// Scope propriétaire — la liste ne montre que les personnages du joueur.
// L'admin voit tout le ruleset : aucune clause propriétaire n'est posée.
if (!$est_admin):
  $listConfig['extra_where']  = 'pe.pe_j_id = ?';
  $listConfig['extra_params'] = [$j_id];
endif;

require_once '../include/compendium-liste.php';

require_once '../include/footer.php';
?>
