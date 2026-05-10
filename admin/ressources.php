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

// Message de confirmation de suppression : affiche les compteurs
function confirmerRessource(array $ligne): string
{
  $nb_classes = (int)($ligne['nb_classes'] ?? 0);
  $nb_races   = (int)($ligne['nb_races']   ?? 0);
  $nb_sorts   = (int)($ligne['nb_sorts']   ?? 0);
  $total      = $nb_classes + $nb_races + $nb_sorts;

  if ($total > 0):
    $details = [];
    if ($nb_classes) $details[] = $nb_classes . ' classe' . ($nb_classes > 1 ? 's' : '');
    if ($nb_races)   $details[] = $nb_races   . ' race'   . ($nb_races   > 1 ? 's' : '');
    if ($nb_sorts)   $details[] = $nb_sorts   . ' sort'   . ($nb_sorts   > 1 ? 's' : '');
    return '<span class="text-danger"><i class="fa fa-exclamation-triangle"></i> '
      . 'Cette ressource contient ' . implode(', ', $details)
      . ' — la suppression sera refusée.</span>';
  endif;

  return 'Supprimer cette ressource ?';
}

// Rendu du nombre avec mise en évidence si > 0
function renderNbAvecBadge(array $ligne, string $champ): string
{
  $nb = (int)($ligne[$champ] ?? 0);
  if ($nb === 0) return '<span class="text-muted">0</span>';
  return '<span class="badge badge--count">' . $nb . '</span>';
}

function renderNbClasses(array $ligne): string  { return renderNbAvecBadge($ligne, 'nb_classes'); }
function renderNbRaces(array $ligne): string    { return renderNbAvecBadge($ligne, 'nb_races');   }
function renderNbSorts(array $ligne): string    { return renderNbAvecBadge($ligne, 'nb_sorts');   }

// ============================================================
// Configuration de la liste
// ============================================================

$adminListConfig = [
  'entite'   => 'ressource',
  'from'     => 'dd_ressources res
                 JOIN dd_variables var ON var.var_id = res.res_ruleset_var_id',
  'champ_id' => 'res.res_id',
  'colonnes' => [
    [
      'sql'    => 'res.res_nom',
      'champ'  => 'res_nom',
      'label'  => 'Nom',
      'mobile' => true,
      'tri'    => true,
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
      'sql'    => '(SELECT COUNT(*) FROM dd_classes
                    WHERE cla_res_id = res.res_id AND cla_camp_id IS NULL)',
      'champ'  => 'nb_classes',
      'label'  => 'Classes',
      'mobile' => false,
      'tri'    => false,
      'render' => 'renderNbClasses',
    ],
    [
      'sql'    => '(SELECT COUNT(*) FROM dd_races WHERE ra_res_id = res.res_id)',
      'champ'  => 'nb_races',
      'label'  => 'Races',
      'mobile' => false,
      'tri'    => false,
      'render' => 'renderNbRaces',
    ],
    [
      'sql'    => '(SELECT COUNT(*) FROM dd_sorts
                    WHERE so_res_id = res.res_id AND so_camp_id IS NULL)',
      'champ'  => 'nb_sorts',
      'label'  => 'Sorts',
      'mobile' => false,
      'tri'    => false,
      'render' => 'renderNbSorts',
    ],
  ],
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
  'url_detail'          => BASE_URL . '/include/ajax/detail-pp/ressource.php',
  'url_modifier'        => BASE_URL . '/include/ajax/modifier/ressource.php',
  'url_enreg'           => BASE_URL . '/admin/enregistrement.php',
  'bulk_actions'        => [], // pas de suppression groupée pour les ressources
  'avec_supprimer'      => true,
  'label_supprimer'     => 'Supprimer',
  'action_supprimer'    => 'supprimer',
  'confirm_callback'    => 'confirmerRessource',
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
