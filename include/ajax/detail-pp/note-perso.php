<?php
// include/ajax/detail-pp/note-perso.php
// Lecture d'une note par le joueur (SP-NO4), dans #detail-pp.
// Ne contient que ce que le personnage peut lire (getNotesPersonnage, SP-NO1) :
// ni les sections inaccessibles, ni leurs conditions, ni les autres destinataires.
// Ouvrir la note la marque lue — seulement pour le propriétaire du personnage :
// un administrateur qui consulte la fiche ne doit pas effacer la pastille.
// Paramètres GET : pe_id (int), id (int) — no_id

require_once __DIR__ . '/../../db.php';
require_once __DIR__ . '/../../auth.php';
require_once __DIR__ . '/../../helpers.php';
require_once __DIR__ . '/../../personnage_helpers.php';
require_once __DIR__ . '/../../tableau-parser.php'; // rendreTexteEnrichi()

requireAuth();

$pe_id = intParam($_GET['pe_id'] ?? 0);
$id    = intParam($_GET['id'] ?? 0);
$perso = getPersonnageContext($db, $pe_id);
$note  = ($perso && $id > 0) ? (getNotesPersonnage($db, $perso, ['no_id' => $id])[0] ?? null) : null;

if (!$note):
  http_response_code(404);
  echo '<p class="erreur">Note introuvable.</p>';
  exit;
endif;

if ((int)$perso['pe_j_id'] === (int)$_SESSION['j_id'] && $note['pno_lu_date'] === null):
  $db->prepare('UPDATE dd_personnages_notes SET pno_lu_date = NOW() WHERE pno_no_id = ? AND pno_pe_id = ?')
     ->execute([$id, $pe_id]);
endif;

$ruleset_id = (int)$perso['pe_ruleset_var_id'];
?>

<div class="sort-detail per-note">

  <div class="sort-detail__header">
    <h2 class="sort-detail__nom"><?= h($note['no_nom']) ?></h2>
    <p class="sort-detail__college">
      <?= h($note['tyno_nom'] ?? '') ?>
      · <?= h($note['camp_nom']) ?><?= $note['sce_nom'] !== null ? ' › ' . h($note['sce_nom']) : '' ?>
      · <?= h(date('d/m/Y', strtotime($note['no_date']))) ?>
    </p>
    <?php if ($note['tags']): ?>
      <p class="per-notes__tags">
        <?php foreach ($note['tags'] as $t): ?>
          <span class="per-notes__tag"><?= h($t['tag_nom']) ?></span>
        <?php endforeach ?>
      </p>
    <?php endif ?>
  </div>

  <?php if (!texteRicheVide($note['no_texte'])): ?>
    <div class="sort-detail__description">
      <?= rendreTexteEnrichi($db, $note['no_texte'], $ruleset_id) ?>
    </div>
  <?php endif ?>

  <?php foreach ($note['sections'] as $s): ?>
    <section class="per-note__section">
      <?php if ($s['noc_titre'] !== null && $s['noc_titre'] !== ''): ?>
        <h3 class="per-note__section-titre"><?= h($s['noc_titre']) ?></h3>
      <?php endif ?>
      <div class="sort-detail__description">
        <?= rendreTexteEnrichi($db, $s['noc_texte'], $ruleset_id) ?>
      </div>
    </section>
  <?php endforeach ?>

  <div class="sort-detail__footer">
    <span class="sort-detail__source"><i class="fa fa-feather"></i> Reçue le <?= h(date('d/m/Y', strtotime($note['pno_date']))) ?></span>
    <span class="sort-detail__ruleset"><?= $ruleset_id === 2 ? 'DD2024' : 'DD3.5' ?></span>
  </div>

</div>
