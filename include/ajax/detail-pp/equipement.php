<?php
// include/ajax/detail-pp/equipement.php
// Retourne le HTML de détail d'un équipement pour #detail-pp
// Paramètres GET : id (int)

require_once __DIR__ . '/../../db.php';
require_once __DIR__ . '/../../auth.php';
require_once __DIR__ . '/../../helpers.php';
// Tag [[tab:slug]] dans les champs texte du compendium (SP-TB7) + familles et formats (SP-PO0)
require_once __DIR__ . '/../../tableau-parser.php';

requireAuth();

$id = intParam($_GET['id'] ?? $_POST['id'] ?? 0);

if (!$id):
  http_response_code(400);
  echo '<p class="erreur">Identifiant manquant.</p>';
  exit;
endif;

$stmt = $db->prepare('
  SELECT eqt.*,
         res.res_nom,
         res.res_j_id,
         camp.camp_nom,
         var.var_valeur AS ruleset_label
  FROM   dd_equipements eqt
  LEFT JOIN dd_ressources res  ON res.res_id   = eqt.eqt_res_id
  LEFT JOIN dd_campagnes  camp ON camp.camp_id = eqt.eqt_camp_id
  LEFT JOIN dd_variables  var  ON var.var_id   = eqt.eqt_ruleset_var_id
  WHERE  eqt.eqt_id = ?
');
$stmt->execute([$id]);
$equipement = $stmt->fetch();

if (!$equipement):
  http_response_code(404);
  echo '<p class="erreur">Équipement introuvable.</p>';
  exit;
endif;

// Masquage si invisible — sauf pour l'éditeur global ou le propriétaire de
// l'entrée (canEditCompendiumEntry, cohérent avec le mécanisme Supplément).
$eqt_res_j_id = $equipement['res_j_id'] !== null ? (int)$equipement['res_j_id'] : null;
if (!canEditCompendiumEntry($db, $eqt_res_j_id) && !(int)$equipement['eqt_visible']):
  http_response_code(403);
  echo '<p class="erreur">Accès refusé.</p>';
  exit;
endif;

// Famille (chemin complet) et bloc de données : prix, poids, puis attributs de la famille
$arbre   = catEquipementArbre($db, (int)$equipement['eqt_ruleset_var_id']);
$cae_id  = (int)$equipement['eqt_cae_id'];
$chemin  = [];
foreach (catEquipementChaine($arbre, $cae_id) as $anc) $chemin[] = $arbre['noeuds'][$anc]['cae_nom'];

$attrs   = equipementAttributs($equipement);
$donnees = [];
foreach (catEquipementColonnes($arbre, $cae_id) as $col):
  $valeur = equipementValeurColonne($equipement, $attrs, (string)$col['k']);
  if ($valeur === '—') continue;   // une donnée absente n'a pas à occuper la fiche
  $donnees[] = [(string)$col['l'], $valeur];
endforeach;
?>

<div class="sort-detail">

  <!-- En-tête : nom + bouton modifier -->
  <div class="sort-detail__header">
    <h2 class="sort-detail__nom">
      <?= h($equipement['eqt_nom']) ?>
      <?php if (!$equipement['eqt_visible']): ?>
        <span class="badge-invisible" title="Masqué aux joueurs">
          <i class="fa fa-eye-slash"></i>
        </span>
      <?php endif ?>
      <?php if (canEditCompendiumEntry($db, $eqt_res_j_id)): ?>
        <button class="sort-detail__edit-btn"
                onclick="ouvrirModifier('<?= BASE_URL ?>/include/ajax/modifier/equipement.php', <?= $id ?>)"
                title="Modifier cet équipement">
          <i class="fa fa-edit"></i>
        </button>
      <?php endif ?>
    </h2>
    <?php if (!empty($chemin)): ?>
      <p class="sort-detail__college"><?= h(implode(' › ', $chemin)) ?></p>
    <?php endif ?>
  </div>

  <!-- Données chiffrées -->
  <?php if (!empty($donnees)): ?>
    <div class="eqt-donnees">
      <?php foreach ($donnees as [$label, $valeur]): ?>
        <div class="eqt-donnees__item">
          <span class="eqt-donnees__label"><?= h($label) ?></span>
          <span class="eqt-donnees__valeur"><?= h($valeur) ?></span>
        </div>
      <?php endforeach ?>
    </div>
  <?php endif ?>

  <!-- Description -->
  <?php if ($equipement['eqt_description']): ?>
    <div class="sort-detail__description">
      <?= rendreTexteEnrichi($db, $equipement['eqt_description'], (int)$equipement['eqt_ruleset_var_id']) ?>
    </div>
  <?php endif ?>

  <!-- Pied de fiche -->
  <div class="sort-detail__footer">
    <span class="sort-detail__source">
      <i class="fa fa-book"></i> <?= h($equipement['res_nom']) ?>
    </span>
    <?php if ($equipement['eqt_camp_id'] && $equipement['camp_nom']): ?>
      <span class="sort-detail__homebrew">
        <i class="fa fa-flask"></i> <?= h($equipement['camp_nom']) ?>
      </span>
    <?php endif ?>
    <span class="sort-detail__ruleset"><?= h($equipement['ruleset_label']) ?></span>
  </div>

</div>
