<?php
// admin/utilisateurs.php — Gestion des utilisateurs
require_once '../include/db.php';
require_once '../include/auth.php';
require_once '../include/helpers.php';

requireAdmin();

$page_title = 'Utilisateurs';
$js_module  = 'admin';
$css_module = 'admin';

// ============================================================
// Fonctions de rendu personnalisées — déclarées avant l'include
// ============================================================

function renderDroits(array $ligne): string
{
  $badges = [];
  if ((int)$ligne['j_admin']):
    $badges[] = '<span class="badge badge--admin">Admin</span>';
  endif;
  if ((int)$ligne['j_compendium_manager']):
    $badges[] = '<span class="badge badge--compendium">Compendium</span>';
  endif;
  return !empty($badges)
    ? implode(' ', $badges)
    : '<span class="text-muted">—</span>';
}

function rowClassUtilisateur(array $ligne): string
{
  return (int)$ligne['j_visible'] === 0 ? 'admin-ligne--inactif' : '';
}

function confirmerUtilisateur(array $ligne): string
{
  if ((int)$ligne['j_visible'] === 0):
    return 'Supprimer définitivement cet utilisateur ? Ses données de jeu seront conservées.';
  endif;
  return 'Désactiver cet utilisateur ? Ses données de jeu sont conservées.';
}

function menuExtraUtilisateur(array $ligne, int $id): string
{
  if ((int)$ligne['j_visible'] === 0):
    return '<button class="comp-menu-item comp-menu-item--success"
      onclick="compToggleMenu(' . $id . '); adminReactiver(' . $id . ')">
      <i class=\"fa fa-user-check\"></i> Réactiver
    </button>';
  endif;
  return '';
}

// ============================================================
// Configuration de la liste
// ============================================================

$adminListConfig = [
  'entite'      => 'utilisateur',
  'from'        => 'dd_joueurs j',
  'champ_id'    => 'j.j_id',
  'colonnes'    => [
    [
      'sql'    => "CONCAT(j.j_prenom, ' ', j.j_nom)",
      'champ'  => 'prenom_nom',
      'label'  => 'Nom',
      'mobile' => true,
      'tri'    => true,
    ],
    [
      'sql'    => 'j.j_pseudo',
      'champ'  => 'j_pseudo',
      'label'  => 'Pseudo',
      'mobile' => false,
      'tri'    => true,
    ],
    [
      'sql'    => 'j.j_email',
      'champ'  => 'j_email',
      'label'  => 'Email',
      'mobile' => false,
      'tri'    => true,
    ],
    [
      'sql'    => "''",
      'champ'  => 'droits',
      'label'  => 'Droits',
      'mobile' => false,
      'tri'    => false,
      'render' => 'renderDroits',
    ],
  ],
  'select_extra' => [
    'j.j_admin AS j_admin',
    'j.j_compendium_manager AS j_compendium_manager',
    'j.j_visible AS j_visible',
  ],
  'filtres'      => [
    [
      'type'        => 'select_static',
      'name'        => 'f_visible',
      'label'       => 'Statut',
      'champ_where' => 'j.j_visible',
      'valeurs'     => [
        ['val' => '',  'lab' => '— Tous —'],
        ['val' => '1', 'lab' => 'Actifs'],
        ['val' => '0', 'lab' => 'Désactivés'],
      ],
    ],
  ],
  'url_detail'           => BASE_URL . '/include/ajax/detail-pp/utilisateur.php',
  'url_modifier'         => BASE_URL . '/include/ajax/modifier/utilisateur.php',
  'url_enreg'            => BASE_URL . '/admin/enregistrement.php',
  'bulk_actions'         => [
    ['valeur' => 'bulk_desactiver', 'label' => 'Désactiver la sélection'],
  ],
  'action_supprimer'     => 'desactiver',
  'label_supprimer'      => 'Désactiver',
  'confirm_callback'     => 'confirmerUtilisateur',
  'menu_extra_callback'  => 'menuExtraUtilisateur',
  'row_class_callback'   => 'rowClassUtilisateur',
];

require_once '../include/header.php';
?>

<div class="flex-between mb-md">
  <h1>Utilisateurs</h1>
  <a href="<?= BASE_URL ?>/admin/index.php" class="btn btn-secondary btn-sm">
    <i class="fa fa-arrow-left"></i> Admin
  </a>
</div>

<?php
require_once '../include/admin-liste.php';
require_once '../include/footer.php';
?>
