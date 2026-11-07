<?php
// include/ajax/detail-pp/objet.php
// Retourne le HTML de détail d'un objet magique pour #detail-pp
// Paramètres GET : id (int)

require_once __DIR__ . '/../../db.php';
require_once __DIR__ . '/../../auth.php';
require_once __DIR__ . '/../../helpers.php';
// Tag [[tab:slug]] dans les champs texte du compendium (SP-TB7)
require_once __DIR__ . '/../../tableau-parser.php';
// Prix des potions, baguettes et parchemins à sort lié (SP-PO7)
require_once __DIR__ . '/../../objet-compose.php';

requireAuth();

$id = intParam($_GET['id'] ?? $_POST['id'] ?? 0);

if (!$id):
  http_response_code(400);
  echo '<p class="erreur">Identifiant manquant.</p>';
  exit;
endif;

$stmt = $db->prepare('
  SELECT
    om.*,
    com.com_nom,
    com.com_est_calcule,
    com.com_slug,
    res.res_nom,
    res.res_j_id,
    omr.omr_nom AS rarete_nom,
    camp.camp_nom
  FROM   dd_objets_magiques            om
  LEFT JOIN dd_categorie_objet_magique com  ON com.com_id  = om.om_com_id
  LEFT JOIN dd_ressources              res  ON res.res_id  = om.om_res_id
  LEFT JOIN dd_objets_magiques_rarete  omr  ON omr.omr_id  = om.om_rarete
  LEFT JOIN dd_campagnes               camp ON camp.camp_id = om.om_camp_id
  WHERE  om.om_id = ?
');
$stmt->execute([$id]);
$om = $stmt->fetch();

if (!$om):
  http_response_code(404);
  echo '<p class="erreur">Objet magique introuvable.</p>';
  exit;
endif;

// Masquage si invisible — sauf pour l'éditeur global ou le propriétaire de
// l'entrée (canEditCompendiumEntry, cohérent avec le mécanisme Supplément).
$om_res_j_id = $om['res_j_id'] !== null ? (int)$om['res_j_id'] : null;
if (!canEditCompendiumEntry($db, $om_res_j_id) && !(int)$om['om_visible']):
  http_response_code(403);
  echo '<p class="erreur">Accès refusé.</p>';
  exit;
endif;

$ruleset_rep = $_SESSION['rulesetRep'] ?? 'DD3.5';

// Le calcul auto NLS/prix est DD3.5 uniquement, pour les catégories marquées
// com_est_calcule=1 et avec le format "auto" (om_fom_id=1) : potion, baguette ou parchemin
// à sort lié. Le prix vient du moteur de composition (SP-PO7, include/objet-compose.php),
// le même que celui du compositeur de possessions. Les armes et armures magiques ne passent
// plus par ici : leurs catégories ne sont pas calculées, elles se composent depuis l'inventaire.
$cat_compose = ['potions-et-huiles' => 'potion', 'baguettes' => 'baguette', 'parchemins' => 'parchemin'];
$calcule = $ruleset_rep === 'DD3.5'
  && (int)$om['com_est_calcule'] === 1
  && (int)$om['om_fom_id'] === 1
  && isset($cat_compose[$om['com_slug'] ?? ''])
  && $om['om_so_id'];

$contenu_description = $om['om_description'] ?? '';

if ($calcule):
  $stmt_so = $db->prepare('
    SELECT so.so_id, so.so_nom, co.co_nom AS college
    FROM   dd_sorts   so
    LEFT JOIN dd_colleges co ON co.co_id = so.so_co_id
    WHERE  so.so_id = ?
  ');
  $stmt_so->execute([(int)$om['om_so_id']]);
  $so = $stmt_so->fetch();
  // Liste de classe la plus avantageuse (niveau le plus bas) ; NLS saisi, relevé au minimum
  $listes = $so ? sortListesClasses($db, (int)$so['so_id']) : [];

  if ($so && $listes):
    $cat = $cat_compose[$om['com_slug']];
    $nls = max((int)$om['om_so_niveau'], $listes[0]['nls_min']);
    $calc = composerObjet($db, ['cat' => $cat, 'sorts' => [[
      'so_id' => (int)$so['so_id'], 'cla_id' => $listes[0]['cla_id'], 'nls' => $nls,
    ]]]);

    $college   = h($so['college'] ?? '');
    $so_nom    = h($so['so_nom']);
    $lien_sort = '<span class="om-lien-sort"'
      . ' onclick="actualiserPageSub(\''
      . BASE_URL . '/include/ajax/detail-pp/sort.php\', {id:' . (int)$so['so_id'] . '})">'
      . $so_nom . '</span>';
    $phrase = [
      'potion'    => 'Cette potion ou huile reproduit les effets du sort ' . $lien_sort . '.',
      'baguette'  => 'Cette baguette possède 50 charges du sort ' . $lien_sort . ', lancé au niveau ' . $nls . ' de lanceur de sorts.',
      'parchemin' => 'Ce parchemin permet de lancer le sort ' . $lien_sort . ' au niveau ' . $nls . ' de lanceur de sorts.',
    ][$cat];
    $don = [
      'potion' => 'Préparation de potions', 'baguette' => 'Création de baguettes magiques', 'parchemin' => 'Écriture de parchemins',
    ][$cat];

    $contenu_description = '<p>' . $phrase . '</p>'
      . '<p>' . ($college ? $college . ' ; ' : '')
      . 'NLS ' . $nls . ' ; ' . $don . ', ' . $so_nom . ' ; '
      . 'Prix ' . h(formaterPrixPo($calc['prix_pc'])) . ' ; '
      . 'Coût ' . h(formaterPrixPo($calc['cout_pc'])) . ', ' . (int)$calc['cout_px'] . ' PX.</p>';
    if (!$calc['ok']):
      // Objet hérité qui enfreint les règles (sort trop puissant pour une potion…) : signalé, pas masqué
      $contenu_description .= '<p class="form-hint">' . h(implode(' ', $calc['erreurs'])) . '</p>';
    endif;
  elseif ($so && trim((string)$contenu_description) === ''):
    // Sort rattaché à aucune liste de classe : niveau inconnu, prix incalculable
    $contenu_description = '<p class="form-hint">Sort lié : ' . h($so['so_nom'])
      . '. Il ne figure dans aucune liste de classe : prix et NLS ne peuvent pas être calculés.</p>';
  endif;
endif;
?>

<div class="sort-detail">

  <!-- En-tête : nom + bouton modifier -->
  <div class="sort-detail__header">
    <h2 class="sort-detail__nom">
      <?= h($om['om_nom']) ?>
      <?php if (!$om['om_visible']): ?>
        <span class="badge-invisible" title="Masqué aux joueurs">
          <i class="fa fa-eye-slash"></i>
        </span>
      <?php endif ?>
      <?php if (canEditCompendiumEntry($db, $om_res_j_id)): ?>
        <button class="sort-detail__edit-btn"
                onclick="ouvrirModifier('<?= BASE_URL ?>/include/ajax/modifier/objet.php', <?= $id ?>)"
                title="Modifier cet objet magique">
          <i class="fa fa-edit"></i>
        </button>
      <?php endif ?>
    </h2>

    <!-- Sous-titre : catégorie + variantes + modificateur -->
    <?php
    $meta = [];
    if ($om['com_nom'])          $meta[] = h($om['com_nom']);
    if ($om['om_variantes'])     $meta[] = h($om['om_variantes']);
    if ($om['om_modificateurs'] > 0) $meta[] = '+' . (int)$om['om_modificateurs'];
    if ($ruleset_rep === 'DD2024' && $om['rarete_nom'])       $meta[] = h($om['rarete_nom']);
    if ($ruleset_rep === 'DD2024' && (int)$om['om_harmonisation'] === 1) $meta[] = 'Harmonisation requise';
    ?>
    <?php if (!empty($meta)): ?>
      <p class="sort-detail__college">
        <?= implode(' · ', $meta) ?>
      </p>
    <?php endif ?>
  </div>

  <!-- Description -->
  <?php if ($contenu_description): ?>
    <div class="sort-detail__description">
      <?= rendreTexteEnrichi($db, $contenu_description) ?>
    </div>
  <?php endif ?>

  <!-- Pied de fiche -->
  <div class="sort-detail__footer">
    <span class="sort-detail__source">
      <i class="fa fa-book"></i> <?= h($om['res_nom']) ?>
    </span>
    <?php if ($om['om_camp_id'] && $om['camp_nom']): ?>
      <span class="sort-detail__homebrew">
        <i class="fa fa-flask"></i> <?= h($om['camp_nom']) ?>
      </span>
    <?php endif ?>
  </div>

</div>
