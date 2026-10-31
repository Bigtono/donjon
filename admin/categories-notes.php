<?php
// admin/categories-notes.php — Catégories de notes, par ruleset (SP-NO6).
// Moteur include/admin-liste.php ; écritures dans admin/enregistrement.php
// (entite = 'categorie-note').
require_once '../include/db.php';
require_once '../include/auth.php';
require_once '../include/helpers.php';

requireAdmin();

$page_title = 'Catégories de notes';
$js_module  = 'admin';
$css_module = 'admin';

// ============================================================
// Fonctions de rendu — déclarées avant l'include
// ============================================================

function renderOrdreCategorie(array $ligne): string
{
  return (string)(int)$ligne['tyno_ordre'];
}

function renderNbNotesCategorie(array $ligne): string
{
  $nb = (int)($ligne['nb_notes'] ?? 0);
  if ($nb === 0) return '<span class="text-muted">0</span>';
  return '<span class="badge badge--count">' . $nb . '</span>';
}

// Une catégorie employée par une note, même supprimée, n'est pas supprimable
function confirmerCategorieNote(array $ligne): string
{
  $nb = (int)($ligne['nb_notes_toutes'] ?? 0);
  if ($nb > 0):
    return '<span class="text-danger"><i class="fa fa-exclamation-triangle"></i> '
      . $nb . ' note' . ($nb > 1 ? 's' : '') . ' dans cette catégorie — la suppression sera refusée.</span>';
  endif;
  return 'Supprimer cette catégorie ?';
}

// ============================================================
// Configuration de la liste
// ============================================================

$adminListConfig = [
  'entite'   => 'categorie-note',
  'from'     => 'dd_types_notes tyno
                 JOIN dd_variables var ON var.var_id = tyno.tyno_ruleset_var_id',
  'champ_id' => 'tyno.tyno_id',
  'colonnes' => [
    [
      // Tri par défaut : ruleset puis ordre d'affichage, en une seule clé
      'sql'    => '(tyno.tyno_ruleset_var_id * 100000 + tyno.tyno_ordre)',
      'champ'  => 'tri_ordre',
      'label'  => 'Ordre',
      'mobile' => false,
      'tri'    => true,
      'render' => 'renderOrdreCategorie',
    ],
    [
      'sql'    => 'tyno.tyno_nom',
      'champ'  => 'tyno_nom',
      'label'  => 'Catégorie',
      'mobile' => true,
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
      'sql'    => '(SELECT COUNT(*) FROM dd_notes n WHERE n.no_tyno_id = tyno.tyno_id AND n.no_supprime = 0)',
      'champ'  => 'nb_notes',
      'label'  => 'Notes',
      'mobile' => false,
      'tri'    => true,
      'render' => 'renderNbNotesCategorie',
    ],
  ],
  'select_extra' => [
    'tyno.tyno_ordre',
    '(SELECT COUNT(*) FROM dd_notes n2 WHERE n2.no_tyno_id = tyno.tyno_id) AS nb_notes_toutes',
  ],
  'filtres'  => [
    [
      'type'        => 'select_static',
      'name'        => 'f_ruleset',
      'label'       => 'Ruleset',
      'champ_where' => 'tyno.tyno_ruleset_var_id',
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
  'url_detail'       => BASE_URL . '/include/ajax/detail-pp/categorie-note.php',
  'url_modifier'     => BASE_URL . '/include/ajax/modifier/categorie-note.php',
  'url_enreg'        => BASE_URL . '/admin/enregistrement.php',
  'bulk_actions'     => [],
  'avec_supprimer'   => true,
  'label_supprimer'  => 'Supprimer',
  'action_supprimer' => 'supprimer',
  'confirm_callback' => 'confirmerCategorieNote',
];

require_once '../include/header.php';
?>

<div class="flex-between mb-md">
  <h1>Catégories de notes</h1>
  <a href="<?= BASE_URL ?>/admin/index.php" class="btn btn-secondary btn-sm">
    <i class="fa fa-arrow-left"></i> Admin
  </a>
</div>

<p class="text-muted text-sm">
  Catégories proposées au MJ dans le formulaire d'une note, selon le ruleset de la campagne.
  Une catégorie employée par une note ne peut être ni supprimée ni changée de ruleset.
</p>

<?php
require_once '../include/admin-liste.php';
require_once '../include/footer.php';
?>
