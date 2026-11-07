<?php
// include/ajax/modifier/notes-groupe.php
// Panneau des actions groupées de la liste des notes du MJ (SP-NO9, D-NO16).
// Ouvert par « Appliquer » de la barre groupée (clé bulk_panneau de campagnes/notes.php).
// Paramètres GET : action — 'supprimer' | 'campagne' | 'categorie' | 'personnages' | 'diffusion' (SP-NO11)
//                  ids    — no_id séparés par des virgules
// Le panneau liste les notes sélectionnées et porte le choix ; l'écriture est faite
// par l'action notesGroupe de campagnes/enregistrement.php.

require_once __DIR__ . '/../../db.php';
require_once __DIR__ . '/../../auth.php';
require_once __DIR__ . '/../../helpers.php';
require_once __DIR__ . '/../../personnage_helpers.php';

requireAuth();

$actions = [
  'supprimer'   => 'Supprimer des notes',
  'campagne'    => 'Changer de campagne',
  'categorie'   => 'Changer de catégorie',
  'personnages' => 'Destinataires',
  'diffusion'   => 'Diffusion',
];
$action = strParam($_GET['action'] ?? '');
$notes  = notesGroupeMJ($db, explode(',', (string)($_GET['ids'] ?? '')));

if (!isset($actions[$action]) || $notes === null):
  echo '<p class="erreur">Sélection invalide ou accès refusé.</p>';
  exit;
endif;

$nb         = count($notes);
$rulesets   = array_unique(array_map('intval', array_column($notes, 'camp_ruleset_var_id')));
$ruleset_id = count($rulesets) === 1 ? reset($rulesets) : 0;
$camp_ids   = array_values(array_unique(array_map('intval', array_column($notes, 'no_camp_id'))));
$erreur     = null;

if ($action === 'campagne' || $action === 'categorie'):
  if (!$ruleset_id):
    $erreur = 'La sélection mélange des rulesets : choisissez des notes d\'un seul ruleset.';
  elseif ($action === 'campagne'):
    // Campagnes du MJ dans le même ruleset : la catégorie des notes reste valable.
    $stmt = $db->prepare('
      SELECT camp_id, camp_nom FROM dd_campagnes
       WHERE camp_j_id = ? AND camp_ruleset_var_id = ? AND camp_supprime = 0
    ORDER BY camp_nom
    ');
    $stmt->execute([(int)$_SESSION['j_id'], $ruleset_id]);
    $choix = $stmt->fetchAll(PDO::FETCH_KEY_PAIR);
  else:
    $stmt = $db->prepare('SELECT tyno_id, tyno_nom FROM dd_types_notes WHERE tyno_ruleset_var_id = ? ORDER BY tyno_ordre, tyno_nom');
    $stmt->execute([$ruleset_id]);
    $choix = $stmt->fetchAll(PDO::FETCH_KEY_PAIR);
  endif;
endif;

if ($action === 'personnages'):
  // Personnages des campagnes des notes, et destinataires actuels de la sélection
  // (un destinataire qui a quitté la campagne doit pouvoir être retiré).
  $ph_c = implode(',', array_fill(0, count($camp_ids), '?'));
  $ph_n = implode(',', array_fill(0, $nb, '?'));
  $stmt = $db->prepare("
    SELECT pe.pe_id, pe.pe_nom,
           (SELECT GROUP_CONCAT(DISTINCT camp.camp_nom ORDER BY camp.camp_nom SEPARATOR ', ')
              FROM dd_campagnes_personnages cp
              JOIN dd_campagnes camp ON camp.camp_id = cp.cp_camp_id
             WHERE cp.cp_pe_id = pe.pe_id AND cp.cp_camp_id IN ($ph_c)) AS campagnes,
           (SELECT COUNT(*) FROM dd_notes n
             WHERE n.no_id IN ($ph_n)
               AND EXISTS (SELECT 1 FROM dd_campagnes_personnages cp
                            WHERE cp.cp_pe_id = pe.pe_id AND cp.cp_camp_id = n.no_camp_id)) AS nb_possibles,
           (SELECT COUNT(*) FROM dd_personnages_notes pno
             WHERE pno.pno_pe_id = pe.pe_id AND pno.pno_no_id IN ($ph_n)) AS nb_recues
      FROM dd_personnages pe
     WHERE EXISTS (SELECT 1 FROM dd_campagnes_personnages cp WHERE cp.cp_pe_id = pe.pe_id AND cp.cp_camp_id IN ($ph_c))
        OR EXISTS (SELECT 1 FROM dd_personnages_notes pno WHERE pno.pno_pe_id = pe.pe_id AND pno.pno_no_id IN ($ph_n))
  ORDER BY pe.pe_nom
  ");
  $ids_notes = array_keys($notes);
  $stmt->execute(array_merge($camp_ids, $ids_notes, $ids_notes, $camp_ids, $ids_notes));
  $personnages = $stmt->fetchAll();
  if (empty($personnages)) $erreur = 'Aucun personnage dans les campagnes de ces notes.';
endif;
?>

<div class="modif-form notes-groupe">
  <h3 class="modif-form__title"><?= h($actions[$action]) ?></h3>
  <p class="note-form__contexte"><?= $nb ?> note<?= $nb > 1 ? 's' : '' ?> sélectionnée<?= $nb > 1 ? 's' : '' ?></p>

  <ul class="notes-groupe__liste">
    <?php foreach ($notes as $n): ?>
      <li><?= h($n['no_nom']) ?><?php if (count($camp_ids) > 1): ?> <span class="text-muted">· <?= h($n['camp_nom']) ?></span><?php endif ?></li>
    <?php endforeach ?>
  </ul>

  <?php if ($erreur !== null): ?>
    <p class="erreur"><?= h($erreur) ?></p>
    <div class="modif-actions">
      <button type="button" class="btn btn-secondary" onclick="fermerModification()">
        <i class="fa fa-times"></i> Fermer
      </button>
    </div>
  <?php else: ?>
    <form id="form-notes-groupe" method="POST" action="<?= BASE_URL ?>/campagnes/enregistrement.php?ajax=1">
      <?= csrfField() ?>
      <input type="hidden" name="action"    value="notesGroupe">
      <input type="hidden" name="operation" value="<?= h($action) ?>">
      <?php foreach (array_keys($notes) as $no_id): ?>
        <input type="hidden" name="ids[]" value="<?= (int)$no_id ?>">
      <?php endforeach ?>

      <?php if ($action === 'supprimer'): ?>
        <p class="notes-groupe__alerte">
          <i class="fa fa-exclamation-triangle"></i>
          Ces notes seront supprimées : elles disparaissent de la liste et leurs destinataires ne les voient plus.
        </p>

      <?php elseif ($action === 'campagne'): ?>
        <div class="form-group">
          <label for="ng_camp_id">Nouvelle campagne <span class="required">*</span></label>
          <select id="ng_camp_id" name="camp_id">
            <option value="">— Choisir —</option>
            <?php foreach ($choix as $id => $nom): ?>
              <option value="<?= (int)$id ?>"><?= h($nom) ?></option>
            <?php endforeach ?>
          </select>
        </div>
        <p class="note-form__aide">Les notes qui changent de campagne perdent leur scénario, et les destinataires
          absents de la nouvelle campagne leur sont retirés. Seules les campagnes du même ruleset sont proposées.</p>

      <?php elseif ($action === 'categorie'): ?>
        <div class="form-group">
          <label for="ng_tyno_id">Nouvelle catégorie <span class="required">*</span></label>
          <select id="ng_tyno_id" name="tyno_id">
            <option value="">— Choisir —</option>
            <?php foreach ($choix as $id => $nom): ?>
              <option value="<?= (int)$id ?>"><?= h($nom) ?></option>
            <?php endforeach ?>
          </select>
        </div>

      <?php elseif ($action === 'diffusion'): ?>
        <?php $nb_camp = count(array_filter($notes, fn($n) => (int)$n['no_diffusion_campagne'] === 1)); ?>
        <p class="note-form__aide">Actuellement : <?= $nb_camp ?> diffusée<?= $nb_camp > 1 ? 's' : '' ?> à toute la campagne,
          <?= $nb - $nb_camp ?> aux personnages choisis.</p>
        <div class="notes-groupe__mode">
          <label><input type="radio" name="diffusion" value="1"> Toute la campagne (y compris les personnages ajoutés plus tard)</label>
          <label><input type="radio" name="diffusion" value="0"> Personnages choisis</label>
        </div>
        <p class="note-form__aide">Vers « Personnages choisis », les personnages actuellement rattachés à la campagne
          deviennent les destinataires de la note. L'état de lecture est conservé dans les deux sens.</p>

      <?php else: ?>
        <?php $nb_camp = count(array_filter($notes, fn($n) => (int)$n['no_diffusion_campagne'] === 1)); ?>
        <?php if ($nb_camp > 0): ?>
          <p class="notes-groupe__alerte">
            <i class="fa fa-info-circle"></i>
            <?= $nb_camp ?> note<?= $nb_camp > 1 ? 's' : '' ?> diffusée<?= $nb_camp > 1 ? 's' : '' ?> à toute la campagne :
            écartée<?= $nb_camp > 1 ? 's' : '' ?> de cette opération.
          </p>
        <?php endif ?>
        <div class="notes-groupe__mode">
          <label><input type="radio" name="mode" value="ajouter" checked> Ajouter aux destinataires</label>
          <label><input type="radio" name="mode" value="retirer"> Retirer des destinataires</label>
        </div>
        <div class="note-form__dests">
          <?php foreach ($personnages as $pe): ?>
            <label class="note-form__dest">
              <input type="checkbox" name="pe_ids[]" value="<?= (int)$pe['pe_id'] ?>">
              <?= h($pe['pe_nom']) ?>
              <?php if (count($camp_ids) > 1 && $pe['campagnes']): ?>
                <span class="note-form__dest-info">(<?= h($pe['campagnes']) ?>)</span>
              <?php elseif (!$pe['campagnes']): ?>
                <span class="note-form__dest-info">(a quitté la campagne)</span>
              <?php endif ?>
              <span class="note-form__dest-info">· reçoit <?= (int)$pe['nb_recues'] ?>/<?= $nb ?></span>
            </label>
          <?php endforeach ?>
        </div>
        <p class="note-form__aide">Un personnage n'est ajouté qu'aux notes de ses campagnes
          (<?= $nb ?> note<?= $nb > 1 ? 's' : '' ?> au plus). Retirer s'applique à toutes les notes sélectionnées.</p>
      <?php endif ?>

      <div class="modif-actions">
        <?php if ($action === 'supprimer'): ?>
          <button type="button" class="btn btn-danger" onclick="notesGroupe.soumettre()">
            <i class="fa fa-trash"></i> Supprimer <?= $nb ?> note<?= $nb > 1 ? 's' : '' ?>
          </button>
        <?php else: ?>
          <button type="button" class="btn btn-primary" onclick="notesGroupe.soumettre()">
            <i class="fa fa-check"></i> Valider
          </button>
        <?php endif ?>
        <button type="button" class="btn btn-secondary" onclick="fermerModification()">
          <i class="fa fa-times"></i> Annuler
        </button>
      </div>
    </form>
  <?php endif ?>
</div>

<script>
(function() {
  function soumettre() {
    var form = document.getElementById('form-notes-groupe');
    if (!form) return;
    var champ = form.querySelector('select');
    if (champ && !champ.value) { alert('Faites un choix dans la liste.'); return; }
    if (form.querySelector('input[name="diffusion"]') && !form.querySelector('input[name="diffusion"]:checked')) {
      alert('Choisissez un mode de diffusion.');
      return;
    }
    if (form.querySelector('input[name="pe_ids[]"]') && !form.querySelector('input[name="pe_ids[]"]:checked')) {
      alert('Cochez au moins un personnage.');
      return;
    }

    fetch(form.getAttribute('action'), { method: 'POST', body: new FormData(form) })
      .then(function(r) { return r.json(); })
      .then(function(data) {
        if (data.ok) {
          fermerModification();
          window.location.reload();
        } else {
          alert(data.erreur || "Erreur lors de l'enregistrement.");
        }
      })
      .catch(function(err) { alert('Erreur : ' + err); });
  }

  window.notesGroupe = { soumettre: soumettre };
})();
</script>
