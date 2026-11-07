<?php
// include/ajax/detail-pp/categorie-note.php
// Détail d'une catégorie de notes pour #detail-pp (SP-NO6)
// Paramètres GET : id (int) — tyno_id

require_once __DIR__ . '/../../db.php';
require_once __DIR__ . '/../../auth.php';
require_once __DIR__ . '/../../helpers.php';

requireAdmin();

$id = intParam($_GET['id'] ?? 0);

$stmt = $db->prepare('
  SELECT tyno.*,
         (SELECT COUNT(*) FROM dd_notes n WHERE n.no_tyno_id = tyno.tyno_id AND n.no_supprime = 0) AS nb_notes,
         (SELECT COUNT(*) FROM dd_notes n WHERE n.no_tyno_id = tyno.tyno_id AND n.no_supprime = 1) AS nb_supprimees,
         (SELECT COUNT(DISTINCT n.no_camp_id) FROM dd_notes n WHERE n.no_tyno_id = tyno.tyno_id AND n.no_supprime = 0) AS nb_campagnes
    FROM dd_types_notes tyno
   WHERE tyno.tyno_id = ?
');
$stmt->execute([$id]);
$tyno = $stmt->fetch();

if (!$tyno):
  http_response_code(404);
  echo '<p class="erreur">Catégorie introuvable.</p>';
  exit;
endif;
?>

<div class="sort-detail">

  <div class="sort-detail__header">
    <h2 class="sort-detail__nom">
      <?= h($tyno['tyno_nom']) ?>
      <button class="sort-detail__edit-btn"
              onclick="ouvrirModifier('<?= BASE_URL ?>/include/ajax/modifier/categorie-note.php', <?= $id ?>)"
              title="Modifier cette catégorie">
        <i class="fa fa-edit"></i>
      </button>
    </h2>
    <p class="sort-detail__college">Catégorie de notes · ordre <?= (int)$tyno['tyno_ordre'] ?></p>
  </div>

  <table class="table-dd">
    <tbody>
      <tr><th>Notes</th><td><?= (int)$tyno['nb_notes'] ?></td></tr>
      <tr><th>Campagnes concernées</th><td><?= (int)$tyno['nb_campagnes'] ?></td></tr>
      <?php if ((int)$tyno['nb_supprimees'] > 0): ?>
        <tr><th>Notes supprimées</th><td><?= (int)$tyno['nb_supprimees'] ?></td></tr>
      <?php endif ?>
    </tbody>
  </table>

  <div class="sort-detail__footer">
    <span class="sort-detail__source"><i class="fa fa-sticky-note"></i> Module Notes</span>
  </div>

</div>
