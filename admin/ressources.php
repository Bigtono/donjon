<?php
// admin/ressources.php — Gestion des ressources du compendium
require_once '../include/db.php';
require_once '../include/auth.php';
require_once '../include/helpers.php';

requireAdmin();

$page_title = 'Ressources';
$js_module  = 'admin';
$css_module = 'admin';

// ============================================================
// Fonctions de rendu personnalisées — déclarées avant l'include
// ============================================================

// Rendu du nombre avec mise en évidence si > 0
function renderNbAvecBadge(array $ligne, string $champ): string
{
  $nb = (int)($ligne[$champ] ?? 0);
  if ($nb === 0) return '<span class="text-muted">0</span>';
  return '<span class="badge badge--count">' . $nb . '</span>';
}

// Nom de la ressource, suivi d'une étoile quand elle est active (res_selection = 1,
// contenu affiché dans le compendium). Un supplément de MJ n'est jamais actif : il
// porte à la place son statut public / privé, réglé par le MJ dans son profil (SP-RE).
function renderNomRessource(array $ligne): string
{
  $html = h((string)($ligne['res_nom'] ?? ''));
  if ($ligne['res_j_id'] !== null):
    $html .= (int)$ligne['j_supplement_public'] === 1
      ? ' <span class="badge" title="Supplément de MJ visible de tous">Supplément public</span>'
      : ' <span class="badge" title="Supplément de MJ visible de son MJ, des admins et des joueurs de ses campagnes">Supplément privé</span>';
  elseif ((int)($ligne['res_selection'] ?? 0) === 1):
    $html .= ' <i class="fa fa-star res-etoile" title="Active"></i>';
  endif;
  return $html;
}

// Actions du menu ⋮ de la ligne : Activer / Désactiver (ressources officielles
// seulement), puis Supprimer, qui mène à l'analyse de suppression en cascade de
// la page de la ressource (SP-AD6)
function menuExtraRessource(array $ligne, int $id): string
{
  if ($ligne['res_j_id'] !== null):
    $html = '';
  elseif ((int)($ligne['res_selection'] ?? 0) === 1):
    $html = '<button class="comp-menu-item"
      onclick="compToggleMenu(' . $id . '); adminBasculerRessource(' . $id . ', \'desactiver\')">
      <i class="fa fa-ban"></i> Désactiver
    </button>';
  else:
    $html = '<button class="comp-menu-item comp-menu-item--success"
      onclick="compToggleMenu(' . $id . '); adminBasculerRessource(' . $id . ', \'activer\')">
      <i class="fa fa-star"></i> Activer
    </button>';
  endif;
  $url = BASE_URL . '/admin/ressource.php?id=' . $id . '&suppr=1';
  return $html . '<button class="comp-menu-item comp-menu-item--danger"
    onclick="window.location.href = ' . h(json_encode($url)) . '">
    <i class="fa fa-trash"></i> Supprimer…
  </button>';
}

function renderNbClasses(array $ligne): string  { return renderNbAvecBadge($ligne, 'nb_classes'); }
function renderNbRaces(array $ligne): string    { return renderNbAvecBadge($ligne, 'nb_races');   }
function renderNbSorts(array $ligne): string    { return renderNbAvecBadge($ligne, 'nb_sorts');   }
function renderNbDons(array $ligne): string     { return renderNbAvecBadge($ligne, 'nb_dons');    }
function renderNbObjets(array $ligne): string   { return renderNbAvecBadge($ligne, 'nb_objets');  }

// ============================================================
// Configuration de la liste
// ============================================================

$adminListConfig = [
  'entite'   => 'ressource',
  'from'     => 'dd_ressources res
                 JOIN dd_variables var ON var.var_id = res.res_ruleset_var_id
                 LEFT JOIN dd_joueurs jo ON jo.j_id = res.res_j_id',
  'champ_id' => 'res.res_id',
  'colonnes' => [
    [
      'sql'    => 'res.res_nom',
      'champ'  => 'res_nom',
      'label'  => 'Nom',
      'mobile' => true,
      'tri'    => true,
      'render' => 'renderNomRessource',
    ],
    [
      'sql'    => 'res.res_abreviation',
      'champ'  => 'res_abreviation',
      'label'  => 'Abrév.',
      'mobile' => false,
      'tri'    => true,
    ],
    [
      'sql'    => 'var.var_valeur',
      'champ'  => 'ruleset_nom',
      'label'  => 'Ruleset',
      'mobile' => false,
      'tri'    => true,
    ],
    [
      'sql'    => contenuRessourceSql('nb_classes'),
      'champ'  => 'nb_classes',
      'label'  => 'Classes',
      'mobile' => false,
      'tri'    => false,
      'render' => 'renderNbClasses',
    ],
    [
      'sql'    => contenuRessourceSql('nb_races'),
      'champ'  => 'nb_races',
      'label'  => 'Races',
      'mobile' => false,
      'tri'    => false,
      'render' => 'renderNbRaces',
    ],
    [
      'sql'    => contenuRessourceSql('nb_sorts'),
      'champ'  => 'nb_sorts',
      'label'  => 'Sorts',
      'mobile' => false,
      'tri'    => false,
      'render' => 'renderNbSorts',
    ],
    [
      'sql'    => contenuRessourceSql('nb_dons'),
      'champ'  => 'nb_dons',
      'label'  => 'Dons',
      'mobile' => false,
      'tri'    => false,
      'render' => 'renderNbDons',
    ],
    [
      'sql'    => contenuRessourceSql('nb_objets'),
      'champ'  => 'nb_objets',
      'label'  => 'Objets magiques',
      'mobile' => false,
      'tri'    => false,
      'render' => 'renderNbObjets',
    ],
  ],
  // État d'activation, lu par renderNomRessource() et menuExtraRessource()
  'select_extra' => ['res.res_selection AS res_selection', 'res.res_j_id AS res_j_id',
                     'jo.j_supplement_public AS j_supplement_public'],
  'filtres'  => [
    [
      'type'        => 'select_static',
      'name'        => 'f_ruleset',
      'label'       => 'Ruleset',
      'champ_where' => 'res.res_ruleset_var_id',
      'valeurs'     => array_merge(
        [['val' => '', 'lab' => '— Tous rulesets —']],
        array_map(
          fn($r) => ['val' => (string)$r['var_id'], 'lab' => $r['var_valeur']],
          $db->query(
            "SELECT var_id, var_valeur FROM dd_variables
             WHERE var_cat = 'ruleset' ORDER BY var_ordre"
          )->fetchAll()
        )
      ),
    ],
  ],
  'url_detail'          => '', // plus de panneau : la ressource a sa propre page (SP-AD5)
  'url_page'            => BASE_URL . '/admin/ressource.php',
  'url_modifier'        => BASE_URL . '/include/ajax/modifier/ressource.php',
  'url_enreg'           => BASE_URL . '/admin/enregistrement.php',
  'bulk_actions'        => [], // pas de suppression groupée pour les ressources
  // Suppression en cascade : analyse et confirmation sur la page de la ressource (SP-AD6),
  // via l'entrée « Supprimer… » de menuExtraRessource() — plus de confirmation inline
  'avec_supprimer'      => false,
  'menu_extra_callback' => 'menuExtraRessource',
];

require_once '../include/header.php';
?>

<div class="flex-between mb-md">
  <h1>Ressources</h1>
  <a href="<?= BASE_URL ?>/admin/index.php" class="btn btn-secondary btn-sm">
    <i class="fa fa-arrow-left"></i> Admin
  </a>
</div>

<?php
require_once '../include/admin-liste.php';
require_once '../include/footer.php';
?>
