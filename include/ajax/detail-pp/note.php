<?php
// include/ajax/detail-pp/note.php
// Fiche d'une note pour le MJ (SP-NO3) : tout le contenu, les conditions de
// chaque section, et l'aperçu « vu par » — pour chaque destinataire, les
// sections qu'il peut lire (même moteur que la page du joueur, SP-NO1).
// Paramètres GET : id (int) — no_id

require_once __DIR__ . '/../../db.php';
require_once __DIR__ . '/../../auth.php';
require_once __DIR__ . '/../../helpers.php';
require_once __DIR__ . '/../../personnage_helpers.php';
require_once __DIR__ . '/../../tableau-parser.php'; // rendreTexteEnrichi()

requireAuth();

$id = intParam($_GET['id'] ?? $_POST['id'] ?? 0);

$stmt = $db->prepare('
  SELECT n.*, camp.camp_nom, camp.camp_ruleset_var_id, sce.sce_nom, tyno.tyno_nom
    FROM dd_notes n
    JOIN dd_campagnes camp        ON camp.camp_id = n.no_camp_id
    LEFT JOIN dd_scenarios sce    ON sce.sce_id   = n.no_sce_id AND sce.sce_supprime = 0
    LEFT JOIN dd_types_notes tyno ON tyno.tyno_id = n.no_tyno_id
   WHERE n.no_id = ? AND n.no_supprime = 0 AND camp.camp_supprime = 0
');
$stmt->execute([$id]);
$note = $stmt->fetch();

if (!$note || !isMJ($db, (int)$note['no_camp_id'])):
  http_response_code(404);
  echo '<p class="erreur">Note introuvable ou accès refusé.</p>';
  exit;
endif;

$ruleset_id  = (int)$note['camp_ruleset_var_id'];
$sections    = getSectionsNotes($db, [$id])[$id] ?? [];

$stmt = $db->prepare('SELECT t.tag_nom FROM dd_notes_tags nt JOIN dd_tags t ON t.tag_id = nt.notag_tag_id WHERE nt.notag_no_id = ? ORDER BY t.tag_nom');
$stmt->execute([$id]);
$tags = $stmt->fetchAll(PDO::FETCH_COLUMN);

// Destinataires, et pour chacun les sections accessibles
$stmt = $db->prepare('
  SELECT pe.*, pno.pno_date, pno.pno_lu_date
    FROM dd_personnages_notes pno
    JOIN dd_personnages pe ON pe.pe_id = pno.pno_pe_id
   WHERE pno.pno_no_id = ?
ORDER BY pe.pe_nom
');
$stmt->execute([$id]);
$destinataires = [];
foreach ($stmt->fetchAll() as $pe):
  $bonus = bonusCompetencesPersonnage($db, $pe);
  $rep   = ((int)$pe['pe_ruleset_var_id'] === 2) ? 'DD2024' : 'DD3.5';
  $acces = [];
  foreach ($sections as $s):
    $acces[] = sectionNoteAccessible($s['conditions'], $bonus, $rep);
  endforeach;
  $destinataires[] = ['pe' => $pe, 'acces' => $acces, 'bonus' => $bonus];
endforeach;

$tronc_vide = texteRicheVide($note['no_texte']);

// Libellé d'une condition : « Connaissances (histoire) DD 15 »
function libelleCondition(array $c): string {
  return ($c['comp_nom'] ?? 'Compétence inconnue') . ' DD ' . (int)$c['nocd_dd'];
}
?>

<div class="sort-detail note-detail">

  <div class="sort-detail__header">
    <h2 class="sort-detail__nom">
      <?= h($note['no_nom']) ?>
      <button class="sort-detail__edit-btn"
              onclick="ouvrirModifier('<?= BASE_URL ?>/include/ajax/modifier/note.php', <?= $id ?>)"
              title="Modifier cette note">
        <i class="fa fa-edit"></i>
      </button>
    </h2>
    <p class="sort-detail__college">
      <?= h($note['tyno_nom'] ?? '') ?>
      · <?= h($note['camp_nom']) ?><?= $note['sce_nom'] ? ' › ' . h($note['sce_nom']) : ' (toute la campagne)' ?>
      · <?= h(date('d/m/Y', strtotime($note['no_date']))) ?>
    </p>
    <?php if ($tags): ?>
      <p class="note-detail__tags">
        <?php foreach ($tags as $t): ?>
          <span class="note-detail__tag"><?= h($t) ?></span>
        <?php endforeach; ?>
      </p>
    <?php endif; ?>
  </div>

  <?php if (!$tronc_vide): ?>
    <div class="sort-detail__description note-detail__tronc">
      <?= rendreTexteEnrichi($db, $note['no_texte'], $ruleset_id) ?>
    </div>
  <?php endif; ?>

  <?php foreach ($sections as $i => $s): ?>
    <section class="note-detail__section">
      <div class="note-detail__section-tete">
        <h3 class="note-detail__section-titre"><?= $s['noc_titre'] !== null && $s['noc_titre'] !== '' ? h($s['noc_titre']) : 'Section ' . ($i + 1) ?></h3>
        <?php if (empty($s['conditions'])): ?>
          <span class="note-detail__cond note-detail__cond--libre">Libre</span>
        <?php else: ?>
          <?php foreach ($s['conditions'] as $k => $c): ?>
            <?php if ($k > 0): ?><span class="note-detail__ou">ou</span><?php endif; ?>
            <span class="note-detail__cond"><?= h(libelleCondition($c)) ?></span>
          <?php endforeach; ?>
        <?php endif; ?>
      </div>
      <div class="sort-detail__description">
        <?= rendreTexteEnrichi($db, $s['noc_texte'], $ruleset_id) ?>
      </div>
    </section>
  <?php endforeach; ?>

  <section class="note-detail__vu-par">
    <h3 class="note-detail__section-titre">Vu par</h3>
    <?php if (empty($destinataires)): ?>
      <p class="text-muted">Aucun destinataire : la note n'est diffusée à personne.</p>
    <?php else: ?>
      <div class="note-detail__table-wrap">
        <table class="table-dd note-detail__table">
          <thead>
            <tr>
              <th class="note-detail__col-nom">Personnage</th>
              <th>Lecture</th>
              <?php foreach ($sections as $i => $s): ?>
                <th title="<?= h($s['noc_titre'] ?? '') ?>">S<?= $i + 1 ?></th>
              <?php endforeach; ?>
            </tr>
          </thead>
          <tbody>
            <?php foreach ($destinataires as $d): ?>
              <?php $rien = $tronc_vide && !in_array(true, $d['acces'], true); ?>
              <tr>
                <td class="note-detail__col-nom">
                  <?= h($d['pe']['pe_nom']) ?>
                  <?php if ($rien): ?>
                    <span class="note-detail__alerte" title="Texte commun vide et aucune section accessible : la note n'apparaît pas pour ce personnage">(ne voit rien)</span>
                  <?php endif; ?>
                </td>
                <td><?= $d['pe']['pno_lu_date'] ? h(date('d/m/Y', strtotime($d['pe']['pno_lu_date']))) : '<span class="text-muted">non lue</span>' ?></td>
                <?php foreach ($sections as $i => $s): ?>
                  <?php
                  // Infobulle : meilleur score du personnage parmi les compétences de la section.
                  $infos = [];
                  foreach ($s['conditions'] as $c):
                    $b = $d['bonus'][(int)$c['nocd_comp_id']] ?? null;
                    $infos[] = ($c['comp_nom'] ?? '?') . ' : ' . ($b ? (10 + $b['bonus']) : '—') . ' / ' . (int)$c['nocd_dd'];
                  endforeach;
                  ?>
                  <td title="<?= h(implode(' · ', $infos)) ?>">
                    <?php if ($d['acces'][$i]): ?>
                      <i class="fa fa-check note-detail__oui" aria-label="Accessible"></i>
                    <?php else: ?>
                      <i class="fa fa-times note-detail__non" aria-label="Inaccessible"></i>
                    <?php endif; ?>
                  </td>
                <?php endforeach; ?>
              </tr>
            <?php endforeach; ?>
          </tbody>
        </table>
      </div>
      <p class="text-muted text-sm">Accès d'une section : 10 + bonus total de compétence ≥ DD (survol d'une case pour le détail).</p>
    <?php endif; ?>
  </section>

  <div class="sort-detail__footer">
    <span class="sort-detail__source"><i class="fa fa-feather"></i> <?= $note['no_date_maj'] ? 'Modifiée le ' . h(date('d/m/Y', strtotime($note['no_date_maj']))) : 'Jamais modifiée' ?></span>
    <span class="sort-detail__ruleset"><?= $ruleset_id === 2 ? 'DD2024' : 'DD3.5' ?></span>
  </div>

</div>
