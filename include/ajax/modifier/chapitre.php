<?php
// include/ajax/modifier/chapitre.php
// Formulaire de création / modification d'un chapitre.
// Paramètres GET : id (int) — scc_id (0 = création), sce_id (requis si id=0)

require_once __DIR__ . '/../../db.php';
require_once __DIR__ . '/../../auth.php';
require_once __DIR__ . '/../../helpers.php';

requireAuth();

$id     = intParam($_GET['id']     ?? 0);
$sce_id = intParam($_GET['sce_id'] ?? 0);

$scc = [
  'scc_id'          => 0,
  'scc_nom'         => '',
  'scc_abreviation' => '',
  'scc_ordre'       => 0,
  'scc_description' => '',
  'scc_sce_id'      => $sce_id,
];

if ($id > 0):
  $stmt = $db->prepare('
    SELECT scc.* FROM dd_scenarios_chapitres scc
    JOIN   dd_scenarios sce  ON sce.sce_id  = scc.scc_sce_id
    JOIN   dd_campagnes camp ON camp.camp_id = sce.sce_camp_id
    WHERE  scc.scc_id = ? AND scc.scc_supprime = 0
      AND  sce.sce_supprime = 0 AND camp.camp_supprime = 0
  ');
  $stmt->execute([$id]);
  $row = $stmt->fetch();
  if (!$row):
    http_response_code(404);
    echo '<p class="erreur">Chapitre introuvable.</p>';
    exit;
  endif;
  // Contrôle propriété : remonte jusqu'au camp_id.
  $stmt2 = $db->prepare('
    SELECT camp.camp_id FROM dd_scenarios sce
    JOIN   dd_campagnes camp ON camp.camp_id = sce.sce_camp_id
    WHERE  sce.sce_id = ?
  ');
  $stmt2->execute([(int)$row['scc_sce_id']]);
  $camp_id_check = (int)$stmt2->fetchColumn();
  if (!isMJ($db, $camp_id_check)):
    http_response_code(403);
    echo '<p class="erreur">Accès refusé.</p>';
    exit;
  endif;
  $scc    = $row;
  $sce_id = (int)$row['scc_sce_id'];
else:
  if (!$sce_id):
    http_response_code(400);
    echo '<p class="erreur">sce_id manquant.</p>';
    exit;
  endif;
  $stmt = $db->prepare('
    SELECT camp.camp_id FROM dd_scenarios sce
    JOIN   dd_campagnes camp ON camp.camp_id = sce.sce_camp_id
    WHERE  sce.sce_id = ? AND sce.sce_supprime = 0 AND camp.camp_supprime = 0
  ');
  $stmt->execute([$sce_id]);
  $row = $stmt->fetch();
  if (!$row || !isMJ($db, (int)$row['camp_id'])):
    http_response_code(403);
    echo '<p class="erreur">Accès refusé.</p>';
    exit;
  endif;
endif;

$titre = $id > 0 ? 'Modifier ' . h($scc['scc_nom']) : 'Nouveau chapitre';
?>

<div class="modif-form">
  <h3 class="modif-form__title"><?= $titre ?></h3>

  <form id="form-chapitre" method="POST"
        action="<?= BASE_URL ?>/campagnes/enregistrement.php?ajax=1"
        data-sce-id="<?= $sce_id ?>">
    <?= csrfField() ?>
    <input type="hidden" name="action"  value="enregistrerChapitre">
    <input type="hidden" name="scc_id"  value="<?= (int)$scc['scc_id'] ?>">
    <input type="hidden" name="sce_id"  value="<?= $sce_id ?>">

    <div class="modif-section">
      <div class="modif-section__header">
        <span class="modif-section__label">Données du chapitre</span>
      </div>

      <div class="modif-grid">

        <div class="form-group modif-grid__full">
          <label for="scc_nom">Nom <span class="required">*</span></label>
          <input type="text" id="scc_nom" name="scc_nom"
                 value="<?= h($scc['scc_nom']) ?>" required maxlength="150">
        </div>

        <div class="form-group">
          <label for="scc_abreviation">Abréviation <span class="form-hint">(10 car. max)</span></label>
          <input type="text" id="scc_abreviation" name="scc_abreviation"
                 value="<?= h($scc['scc_abreviation'] ?? '') ?>" maxlength="10" style="width:120px;">
        </div>

        <div class="form-group">
          <label for="scc_ordre">Ordre d'affichage</label>
          <input type="number" id="scc_ordre" name="scc_ordre"
                 value="<?= (int)$scc['scc_ordre'] ?>" min="0" step="1" style="width:80px;">
        </div>

        <div class="form-group modif-grid__full">
          <label for="scc_description">Description</label>
          <textarea id="scc_description" name="scc_description"
                    rows="4"><?= h($scc['scc_description'] ?? '') ?></textarea>
        </div>

      </div>
    </div>

    <div class="modif-actions">
      <button type="button" class="btn btn-primary" onclick="chapitreForm.soumettre()">
        <i class="fa fa-save"></i> Enregistrer
      </button>
      <button type="button" class="btn btn-secondary" onclick="fermerModification()">
        <i class="fa fa-times"></i> Annuler
      </button>
    </div>

  </form>
</div>

<script>
(function() {
  'use strict';

  const SCC_ID          = <?= (int)$scc['scc_id'] ?>;
  const SCE_ID          = <?= $sce_id ?>;
  const URL_SCC_DETAIL  = <?= json_encode(BASE_URL . '/include/ajax/detail-pp/chapitre.php') ?>;
  const URL_SCE_DETAIL  = <?= json_encode(BASE_URL . '/include/ajax/detail-pp/scenario.php') ?>;

  function soumettre() {
    const form = document.getElementById('form-chapitre');
    if (!form) return;

    const nom = document.getElementById('scc_nom').value.trim();
    if (!nom) { alert('Le nom du chapitre est obligatoire.'); return; }

    fetch(form.getAttribute('action'), { method: 'POST', body: new FormData(form) })
      .then(r => r.json())
      .then(data => {
        if (data.ok) {
          fermerModification();
          if (SCC_ID > 0) {
            // Modification : rafraîchit la vue chapitre courante dans #detail-pp.
            naviguerDetailPP(URL_SCC_DETAIL, { id: SCC_ID });
          } else {
            // Création : remonte à la vue scénario parent.
            naviguerDetailPP(URL_SCE_DETAIL, { id: SCE_ID });
          }
        } else {
          alert(data.erreur || "Erreur lors de l'enregistrement.");
        }
      })
      .catch(err => alert('Erreur : ' + err));
  }

  window.chapitreForm = { soumettre: soumettre };

})();
</script>
