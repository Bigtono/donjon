<?php
// tableaux/index.php — Gestionnaire des tableaux de données (SP-TB10)
//
// Les tableaux ne sont plus une spécificité du module Règles : le tag
// [[tab:slug]] est résolu dans les règles, les monstres et les huit champs
// description du compendium (SP-TB7). Le gestionnaire quitte donc regles/ pour
// un module propre, atteignable depuis les barres d'outils de chaque module.
// regles/tableaux.php ne subsiste que comme redirection.
//
// La liste délègue au moteur partagé include/compendium-liste.php (filtres,
// pagination, tri, menu ⋮, panneau de filtres mobile) au lieu de la table
// maison de SP-TB3, qui n'avait ni pagination ni filtres.
//
// Paramètres GET : voir le moteur (q, f_res[], f_ecran, sort_col, sort_dir, page)
//
// Référence : doc/ARCHITECTURE_0_REFERENCE.md §9c

require_once '../include/db.php';
require_once '../include/auth.php';
require_once '../include/helpers.php';
require_once '../include/tableau-parser.php';

requireAuth();

$page_title = 'Tableaux';

$ruleset_id  = (int)($_SESSION['ruleset_var_id'] ?? 1);
$peut_editer = canEditCompendium();
$ecran_seul  = isset($_GET['f_ecran']);

// Usages : comptés en PHP sur le corpus des champs hôtes (cf.
// compterUsagesTableaux()). Couvre tous les tableaux du ruleset, pas seulement
// la page courante — le moteur y pioche par tab_id.
$usages = compterUsagesTableaux($db, $ruleset_id);

// Restrictions cumulables injectées dans le WHERE du moteur.
$conditions = [];
if (!$peut_editer):
  $conditions[] = 't.tab_visible = 1';
endif;
if ($ecran_seul):
  $conditions[] = 't.tab_ecran_mj = 1';
endif;

require_once '../include/header.php';
?>

<div class="flex-between mb-md">
  <h1>Tableaux</h1>
  <?php if ($peut_editer): ?>
    <button class="btn btn-primary btn-sm"
            onclick="ouvrirModifier('<?= BASE_URL ?>/include/ajax/modifier/tableau.php', 0)"
            title="Nouveau tableau" aria-label="Nouveau tableau">
      <i class="fa fa-plus"></i>
    </button>
  <?php endif ?>
</div>

<?php
// ============================================================
// CONFIGURATION DU MOTEUR DE LISTE
// ============================================================

$colonnes = [
  ['sql' => 't.tab_nom', 'champ' => 'tab_nom', 'label' => 'Nom', 'mobile' => true, 'tri' => true],
  [
    'sql'    => "CONCAT('[[tab:', t.tab_slug, ']]')",
    'champ'  => 'tab_tag',
    'label'  => 'Tag à insérer',
    'mobile' => false,
    'tri'    => true,
  ],
  // Colonne calculée : le comptage ne s'exprime pas en SQL, les champs hôtes
  // n'ayant pas tous le même jeu de caractères (cf. _tabCorpusHotes()).
  [
    'valeurs' => array_map(fn($n) => $n > 0 ? (string)$n : '—', $usages),
    'champ'   => 'tab_usages',
    'label'   => 'Usages',
    'mobile'  => false,
    'tri'     => false,
  ],
  [
    'sql'    => "IF(t.tab_ecran_mj = 1, '★', '')",
    'champ'  => 'tab_ecran',
    'label'  => 'Écran MJ',
    'mobile' => false,
    'tri'    => true,
  ],
  ['sql' => 'res.res_nom', 'champ' => 'res_nom', 'label' => 'Source', 'mobile' => false, 'tri' => true],
];

// Le statut n'a de sens que pour qui voit les brouillons.
if ($peut_editer):
  $colonnes[] = [
    'sql'    => "IF(t.tab_visible = 1, '', 'Brouillon')",
    'champ'  => 'tab_statut',
    'label'  => 'Statut',
    'mobile' => false,
    'tri'    => true,
  ];
endif;

$listConfig = [
  'entite' => 'tableau',
  'titre'  => 'Tableaux',

  'from' => '
    dd_tableaux t
    LEFT JOIN dd_ressources res ON res.res_id = t.tab_res_id
  ',
  'champ_id'      => 't.tab_id',
  'champ_ruleset' => 't.tab_ruleset_var_id',
  'champ_res'     => 't.tab_res_id',
  // tab_camp_id est réservé aux house rules (toujours NULL à ce jour) : on
  // conserve la sémantique du compendium — la liste montre le corpus officiel.
  'champ_camp'    => 't.tab_camp_id',

  // Le slug est recherchable au même titre que le nom : c'est lui qu'on a sous
  // les yeux quand un tag s'affiche en .reg-tab__manquant.
  'champs_recherche' => ['t.tab_nom', 't.tab_slug'],

  'extra_where' => implode(' AND ', $conditions),

  'colonnes' => $colonnes,

  'filtres' => [
    // Type checkbox : le moteur ne l'injecte pas dans le WHERE, son effet passe
    // par extra_where ci-dessus.
    [
      'type'    => 'checkbox',
      'name'    => 'f_ecran',
      'label'   => "Écran du MJ",
      'checked' => $ecran_seul,
    ],
  ],

  'url_detail'   => BASE_URL . '/include/ajax/detail-pp/tableau.php',
  'url_modifier' => BASE_URL . '/include/ajax/modifier/tableau.php',
  'url_enreg'    => BASE_URL . '/tableaux/enregistrement.php?ajax=1',

  // Le bouton d'ajout est déjà dans la ligne de titre ; avec_ajout=false évite
  // en prime que le moteur affiche ici son raccourci « Tableaux », qui
  // pointerait sur la page courante.
  'avec_ajout'   => false,
  'bulk_actions' => [],
  // enregistrement.php attend une action nommée en JSON.
  'suppression'  => ['mode' => 'ajax', 'action' => 'supprimer', 'param' => 'tab_id'],
];

require_once '../include/compendium-liste.php';
?>

<script>
  // Colonne « Tag à insérer » : le moteur rend des cellules en texte échappé.
  // On y replace le <code> cliquable de SP-TB3 — un tag se copie, il ne se lit
  // pas. Handler en capture pour court-circuiter le onclick de ligne du moteur.
  document.addEventListener('DOMContentLoaded', function () {
    document.querySelectorAll('.comp-col--tab_tag').forEach(function (cellule) {
      var texte = (cellule.textContent || '').trim();
      if (!texte) return;

      var code = document.createElement('code');
      code.className = 'reg-tab-liste__tag';
      code.title = 'Cliquer pour copier';
      code.textContent = texte;

      cellule.textContent = '';
      cellule.appendChild(code);

      code.addEventListener('click', function (e) {
        e.stopPropagation();
        copierTagTableau(code);
      }, true);
    });
  });
</script>

<?php require_once '../include/footer.php'; ?>
