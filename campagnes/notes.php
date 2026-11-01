<?php
// campagnes/notes.php — Notes du MJ (SP-NO3).
// Liste des notes des campagnes du MJ dans le ruleset courant, par le moteur
// include/compendium-liste.php en mode hors compendium (SP-RS6b).
//
// Paramètres GET (en plus de ceux du moteur) :
//   f_campagne — campagne (défaut : la dernière campagne consultée, si elle est au MJ ;
//                « — Campagne — » = toutes)
//   f_sce, f_tyno, f_tag — scénario, catégorie, mot-clé
// Tri par défaut : date décroissante.

require_once '../include/db.php';
require_once '../include/auth.php';
require_once '../include/helpers.php';

requireAuth();

$j_id       = (int)$_SESSION['j_id'];
$ruleset_id = (int)($_SESSION['ruleset_var_id'] ?? 1);

// Campagnes du MJ dans le ruleset courant
$stmt = $db->prepare('
  SELECT camp_id, camp_nom FROM dd_campagnes
   WHERE camp_j_id = ? AND camp_ruleset_var_id = ? AND camp_supprime = 0
ORDER BY camp_nom
');
$stmt->execute([$j_id, $ruleset_id]);
$campagnes_mj = $stmt->fetchAll(PDO::FETCH_KEY_PAIR);

// Campagne par défaut : la dernière consultée, si elle appartient au MJ. Un
// choix explicite (même « toutes », valeur vide) l'emporte.
if (!isset($_GET['f_campagne'])):
  $derniere = (int)($_SESSION['last_camp_id'] ?? 0);
  $_GET['f_campagne'] = isset($campagnes_mj[$derniere]) ? (string)$derniere : '';
endif;
$camp_courante = intParam($_GET['f_campagne']);
if (!isset($campagnes_mj[$camp_courante])) $camp_courante = 0;

if (!isset($_GET['sort_col'])):
  $_GET['sort_col'] = 'no_date';
  $_GET['sort_dir'] = 'desc';
endif;

$page_title = 'Notes';
$js_module  = 'campagne';
$css_module = 'campagnes';

require_once '../include/header.php';

$filtres = [
  [
    'type'            => 'select',
    'name'            => 'f_campagne',
    'champ'           => 'n.no_camp_id',
    'label'           => 'Campagne',
    'submit_onchange' => true,
    'query'           => 'SELECT camp_id AS val, camp_nom AS lab FROM dd_campagnes
                           WHERE camp_j_id = ? AND camp_ruleset_var_id = ? AND camp_supprime = 0
                        ORDER BY camp_nom',
    'query_params'    => [$j_id, $ruleset_id],
  ],
  [
    'type'         => 'select',
    'name'         => 'f_sce',
    'champ'        => 'n.no_sce_id',
    'label'        => 'Scénario',
    // Scénarios de la campagne choisie, ou de toutes les campagnes du MJ.
    'query'        => 'SELECT sce.sce_id AS val,
                              ' . ($camp_courante ? 'sce.sce_nom' : "CONCAT(camp.camp_nom, ' — ', sce.sce_nom)") . ' AS lab
                         FROM dd_scenarios sce
                         JOIN dd_campagnes camp ON camp.camp_id = sce.sce_camp_id
                        WHERE camp.camp_j_id = ? AND camp.camp_ruleset_var_id = ? AND camp.camp_supprime = 0
                          AND sce.sce_supprime = 0' . ($camp_courante ? ' AND camp.camp_id = ?' : '') . '
                     ORDER BY camp.camp_nom, sce.sce_ordre, sce.sce_nom',
    'query_params' => $camp_courante ? [$j_id, $ruleset_id, $camp_courante] : [$j_id, $ruleset_id],
  ],
  [
    'type'         => 'select',
    'name'         => 'f_tyno',
    'champ'        => 'n.no_tyno_id',
    'label'        => 'Catégorie',
    'query'        => 'SELECT tyno_id AS val, tyno_nom AS lab FROM dd_types_notes
                        WHERE tyno_ruleset_var_id = ? ORDER BY tyno_ordre, tyno_nom',
    'query_params' => [$ruleset_id],
  ],
  [
    // Mots-clés : relation N-N, filtrée par EXISTS (pas de doublon de ligne).
    'type'         => 'exists',
    'name'         => 'f_tag',
    'label'        => 'Mot-clé',
    'sql'          => 'EXISTS (SELECT 1 FROM dd_notes_tags nt WHERE nt.notag_no_id = n.no_id AND nt.notag_tag_id = ?)',
    'query'        => 'SELECT DISTINCT t.tag_id AS val, t.tag_nom AS lab
                         FROM dd_tags t
                         JOIN dd_notes_tags nt ON nt.notag_tag_id = t.tag_id
                         JOIN dd_notes n2      ON n2.no_id = nt.notag_no_id AND n2.no_supprime = 0
                        WHERE t.tag_j_id = ?
                     ORDER BY t.tag_nom',
    'query_params' => [$j_id],
  ],
];

$listConfig = [
  'entite'        => 'note',
  'titre'         => 'Notes',

  'from' => '
    dd_notes n
    JOIN      dd_campagnes   camp ON camp.camp_id = n.no_camp_id
    LEFT JOIN dd_scenarios   sce  ON sce.sce_id   = n.no_sce_id AND sce.sce_supprime = 0
    LEFT JOIN dd_types_notes tyno ON tyno.tyno_id = n.no_tyno_id
  ',
  'champ_id'      => 'n.no_id',
  'champ_ruleset' => 'camp.camp_ruleset_var_id',
  // Pas de dd_ressources (champ_res absent) ni de filtre homebrew.
  'champ_camp'    => false,

  'colonnes' => [
    ['sql' => 'DATE(n.no_date)', 'champ' => 'no_date', 'label' => 'Date', 'mobile' => false, 'tri' => true],
    ['sql' => 'n.no_nom', 'champ' => 'no_nom', 'label' => 'Titre', 'mobile' => true, 'tri' => true],
    ['sql' => 'tyno.tyno_nom', 'champ' => 'tyno_nom', 'label' => 'Catégorie', 'mobile' => false, 'tri' => true],
    ['sql' => "COALESCE(sce.sce_nom, '—')", 'champ' => 'sce_nom', 'label' => 'Scénario', 'mobile' => false, 'tri' => true],
    ['sql' => 'camp.camp_nom', 'champ' => 'camp_nom', 'label' => 'Campagne', 'mobile' => false, 'tri' => true],
    ['sql' => '(SELECT COUNT(*) FROM dd_notes_contenus noc WHERE noc.noc_no_id = n.no_id)',
     'champ' => 'nb_sections', 'label' => 'Sections', 'mobile' => false, 'tri' => true],
    ['sql' => '(SELECT COUNT(*) FROM dd_personnages_notes pno WHERE pno.pno_no_id = n.no_id)',
     'champ' => 'nb_dest', 'label' => 'Destinataires', 'mobile' => false, 'tri' => true],
  ],
  'filtres' => $filtres,

  // Recherche : titre, tronc commun et sections (le MJ voit tout).
  'champs_recherche' => [
    'n.no_nom',
    'n.no_texte',
    '(SELECT GROUP_CONCAT(CONCAT_WS(\' \', noc.noc_titre, noc.noc_texte) SEPARATOR \' \')
        FROM dd_notes_contenus noc WHERE noc.noc_no_id = n.no_id)',
  ],

  'url_detail'   => BASE_URL . '/include/ajax/detail-pp/note.php',
  'url_modifier' => BASE_URL . '/include/ajax/modifier/note.php',
  'url_enreg'    => BASE_URL . '/campagnes/enregistrement.php?ajax=1',

  // La liste est restreinte aux campagnes du MJ (extra_where) : menu ⋮ ouvert.
  'edition_libre' => true,
  // Bouton d'ajout dans la ligne de titre : il a besoin d'une campagne.
  'avec_ajout'    => false,
  // Actions groupées (SP-NO9) : chacune ouvre un panneau qui liste la sélection,
  // porte le choix et sert d'écran de validation (include/ajax/modifier/notes-groupe.php).
  'bulk_actions'  => [
    ['valeur' => 'supprimer',   'label' => 'Supprimer'],
    ['valeur' => 'campagne',    'label' => 'Changer de campagne'],
    ['valeur' => 'categorie',   'label' => 'Changer de catégorie'],
    ['valeur' => 'personnages', 'label' => 'Ajouter ou retirer des destinataires'],
  ],
  'bulk_panneau'  => BASE_URL . '/include/ajax/modifier/notes-groupe.php',
  'suppression'   => ['mode' => 'ajax', 'action' => 'supprimerNote', 'param' => 'id'],

  'extra_where'  => 'camp.camp_j_id = ? AND camp.camp_supprime = 0 AND n.no_supprime = 0',
  'extra_params' => [$j_id],
];
?>

<div class="flex-between mb-md">
  <h1>Notes <span class="text-muted text-sm">(<?= $ruleset_id === 2 ? 'DD2024' : 'DD3.5' ?>)</span></h1>
  <div class="flex flex-gap">
    <?php if ($camp_courante): ?>
      <a class="btn btn-secondary btn-sm" href="<?= BASE_URL ?>/campagnes/campagne.php?id=<?= $camp_courante ?>">
        <i class="fa fa-arrow-left"></i> <?= h($campagnes_mj[$camp_courante]) ?>
      </a>
      <button class="btn btn-primary btn-sm"
              onclick="actualiserPageModif('<?= BASE_URL ?>/include/ajax/modifier/note.php', {id: 0, camp_id: <?= $camp_courante ?>})">
        <i class="fa fa-plus"></i> Nouvelle note
      </button>
    <?php elseif (!empty($campagnes_mj)): ?>
      <span class="text-muted text-sm">Choisissez une campagne pour ajouter une note.</span>
    <?php endif; ?>
  </div>
</div>

<?php if (empty($campagnes_mj)): ?>
  <p class="text-muted">Vous n'êtes MJ d'aucune campagne dans ce ruleset.</p>
<?php else: ?>
  <?php require_once '../include/compendium-liste.php'; ?>
<?php endif; ?>

<?php require_once '../include/footer.php'; ?>
