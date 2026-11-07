<?php
// include/ajax/detail-pp/possession.php
// Fiche d'un objet composé de l'inventaire (SP-PO8) pour #detail-pp : objet de base,
// bonus, propriétés ou sorts, NLS, prix, coût de création et PX figés à la composition.
// Paramètres GET : id (pp_id)
// Droit : peutGererPersonnage sur le personnage qui le possède (D-PO18).

require_once __DIR__ . '/../../db.php';
require_once __DIR__ . '/../../auth.php';
require_once __DIR__ . '/../../helpers.php';
require_once __DIR__ . '/../../personnage_helpers.php';
require_once __DIR__ . '/../../liste-parser.php';

requireAuth();

$id = intParam($_GET['id'] ?? $_POST['id'] ?? 0);

$stmt = $db->prepare('
  SELECT pp.*, pe.pe_id, pe.pe_nom, pe.pe_j_id, pe.pe_affecte_par_j_id,
         eqt.eqt_nom
    FROM dd_personnages_possessions pp
    JOIN dd_personnages pe ON pe.pe_id = pp.pp_pe_id
    LEFT JOIN dd_equipements eqt ON eqt.eqt_id = pp.pp_eqt_id
   WHERE pp.pp_id = ? AND pp.pp_type = \'compose\'
');
$stmt->execute([$id]);
$pp = $stmt->fetch();

if (!$pp || !peutGererPersonnage($db, $pp)):
  http_response_code(404);
  echo '<p class="erreur">Objet introuvable ou accès refusé.</p>';
  exit;
endif;

$stmt = $db->prepare('
  SELECT ppe.*, om.om_nom, so.so_nom, cla.cla_nom
    FROM dd_personnages_possessions_elements ppe
    LEFT JOIN dd_objets_magiques om  ON om.om_id   = ppe.ppe_om_id
    LEFT JOIN dd_sorts           so  ON so.so_id   = ppe.ppe_so_id
    LEFT JOIN dd_classes         cla ON cla.cla_id = ppe.ppe_cla_id
   WHERE ppe.ppe_pp_id = ?
   ORDER BY ppe.ppe_tete, ppe.ppe_ordre, ppe.ppe_id
');
$stmt->execute([$id]);
$elements = $stmt->fetchAll();

$cats   = possessionComposeCategories();
$double = $pp['pp_bonus_tete2'] !== null;
$meta   = [$cats[$pp['pp_compose_cat']] ?? 'Objet composé'];
if ($pp['pp_bonus'] !== null && (int)$pp['pp_bonus'] > 0):
  $meta[] = '+' . (int)$pp['pp_bonus'] . ($double ? '/+' . (int)$pp['pp_bonus_tete2'] : '');
elseif ((int)$pp['pp_maitre'] === 1 && in_array($pp['pp_compose_cat'], ['arme', 'armure', 'bouclier'], true)):
  $meta[] = 'De maître';
endif;
if ($pp['pp_nls'] !== null) $meta[] = 'NLS ' . (int)$pp['pp_nls'];
?>

<div class="sort-detail">

  <div class="sort-detail__header">
    <h2 class="sort-detail__nom"><?= h($pp['pp_nom'] ?: 'Objet composé') ?></h2>
    <p class="sort-detail__college"><?= h(implode(' · ', $meta)) ?></p>
  </div>

  <div class="sort-detail__description">
    <?php if ($pp['pp_eqt_id']): ?>
      <p>
        <strong>Objet de base :</strong>
        <?php if ($pp['eqt_nom'] !== null): ?>
          <span class="om-lien-sort"
                onclick="actualiserPageSub(<?= h(json_encode(BASE_URL . '/include/ajax/detail-pp/equipement.php')) ?>, {id: <?= (int)$pp['pp_eqt_id'] ?>})"><?= h($pp['eqt_nom']) ?></span>
        <?php else: ?>
          <span class="text-muted">retiré du compendium</span>
        <?php endif ?>
      </p>
    <?php endif ?>

    <?php if ($elements): ?>
      <ul>
        <?php foreach ($elements as $e): ?>
          <li>
            <?php if ($e['ppe_type'] === 'propriete'): ?>
              <?php if ($double): ?>Tête <?= (int)$e['ppe_tete'] ?> : <?php endif ?>
              <span class="om-lien-sort"
                    onclick="actualiserPageSub(<?= h(json_encode(BASE_URL . '/include/ajax/detail-pp/objet.php')) ?>, {id: <?= (int)$e['ppe_om_id'] ?>})"><?= h($e['om_nom'] ?? 'Propriété retirée') ?></span>
              <?= $e['ppe_parametre'] !== null ? '(' . h($e['ppe_parametre']) . ')' : '' ?>
            <?php else: ?>
              <span class="om-lien-sort"
                    onclick="actualiserPageSub(<?= h(json_encode(BASE_URL . '/include/ajax/detail-pp/sort.php')) ?>, {id: <?= (int)$e['ppe_so_id'] ?>})"><?= h($e['so_nom'] ?? 'Sort retiré') ?></span>
              — niveau <?= (int)$e['ppe_niveau'] ?><?= $e['cla_nom'] ? ' (' . h($e['cla_nom']) . ')' : '' ?>, NLS <?= (int)$e['ppe_nls'] ?>
              <?php if ((int)$e['ppe_utilise'] === 1): ?><span class="text-muted">— utilisé</span><?php endif ?>
            <?php endif ?>
          </li>
        <?php endforeach ?>
      </ul>
    <?php endif ?>

    <p>
      <?php if ($pp['pp_charges'] !== null): ?>Charges : <?= (int)$pp['pp_charges'] ?> ; <?php endif ?>
      Prix <?= $pp['pp_prix_pc'] !== null ? h(formaterPrixPo((int)$pp['pp_prix_pc'])) : '—' ?><?= (int)$pp['pp_quantite'] > 1 ? ' pièce' : '' ?> ;
      Coût de création<?= (int)$pp['pp_quantite'] > 1 ? ' (lot entier, à la composition)' : '' ?> <?= $pp['pp_cout_pc'] !== null ? h(formaterPrixPo((int)$pp['pp_cout_pc'])) : '—' ?>,
      <?= (int)$pp['pp_cout_px'] ?> PX.
    </p>

    <?php if (trim((string)$pp['pp_notes']) !== ''): ?>
      <p><?= nl2br(h($pp['pp_notes'])) ?></p>
    <?php endif ?>
  </div>

  <div class="sort-detail__footer">
    <span class="sort-detail__source"><i class="fa fa-user"></i> <?= h($pp['pe_nom']) ?></span>
  </div>

</div>
