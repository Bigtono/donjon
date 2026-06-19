<?php
// include/ajax/modifier/scenario.php
// Formulaire de création / modification d'un scénario.
// Paramètres GET : id (int) — sce_id (0 = création), camp_id (int, requis si id=0)

require_once __DIR__ . '/../../db.php';
require_once __DIR__ . '/../../auth.php';
require_once __DIR__ . '/../../helpers.php';

requireAuth();

$id      = intParam($_GET['id']      ?? 0);
$camp_id = intParam($_GET['camp_id'] ?? 0);

// Chargement ou valeurs vides
$sce = [
  'sce_id'          => 0,
  'sce_nom'         => '',
  'sce_ordre'       => 0,
  'sce_description' => '',
  'sce_camp_id'     => $camp_id,
];

if ($id > 0):
  $stmt = $db->prepare('
    SELECT sce.* FROM dd_scenarios sce
    JOIN   dd_campagnes camp ON camp.camp_id = sce.sce_camp_id
    WHERE  sce.sce_id = ? AND sce.sce_supprime = 0 AND camp.camp_supprime = 0
  ');
  $stmt->execute([$id]);
  $row = $stmt->fetch();
  if (!$row):
    http_response_code(404);
    echo '<p class="erreur">Scénario introuvable.</p>';
    exit;
  endif;
  if (!isMJ($db, (int)$row['sce_camp_id'])):
    http_response_code(403);
    echo '<p class="erreur">Accès refusé.</p>';
    exit;
  endif;
  $sce     = $row;
  $camp_id = (int)$row['sce_camp_id'];
else:
  if (!$camp_id || !isMJ($db, $camp_id)):
    http_response_code(403);
    echo '<p class="erreur">Accès refusé.</p>';
    exit;
  endif;
endif;

$titre = $id > 0 ? 'Modifier ' . h($sce['sce_nom']) : 'Nouveau scénario';
?>

<div class="modif-form">
  <h3 class="modif-form__title"><?= $titre ?></h3>

  <form id="form-scenario" method="POST"
        action="<?= BASE_URL ?>/campagnes/enregistrement.php?ajax=1"
        data-camp-id="<?= $camp_id ?>">
    <?= csrfField() ?>
    <input type="hidden" name="action"   value="enregistrerScenario">
    <input type="hidden" name="sce_id"   value="<?= (int)$sce['sce_id'] ?>">
    <input type="hidden" name="camp_id"  value="<?= $camp_id ?>">

    <div class="modif-section">
      <div class="modif-section__header">
        <span class="modif-section__label">Données du scénario</span>
      </div>

      <div class="modif-grid">

        <div class="form-group modif-grid__full">
          <label for="sce_nom">Nom <span class="required">*</span></label>
          <input type="text" id="sce_nom" name="sce_nom"
                 value="<?= h($sce['sce_nom']) ?>" required maxlength="150">
        </div>

        <div class="form-group">
          <label for="sce_ordre">Ordre d'affichage</label>
          <input type="number" id="sce_ordre" name="sce_ordre"
                 value="<?= (int)$sce['sce_ordre'] ?>" min="0" step="1" style="width:80px;">
        </div>

      </div>

      <div class="form-group">
        <label for="sce_description">Description</label>
        <textarea id="sce_description" name="sce_description"
                  class="tinymce-full"><?= h($sce['sce_description'] ?? '') ?></textarea>
      </div>

    </div>

    <div class="modif-actions">
      <button type="button" class="btn btn-primary" onclick="scenarioForm.soumettre()">
        <i class="fa fa-save"></i> Enregistrer
      </button>
      <button type="button" class="btn btn-secondary" onclick="fermerModification()">
        <i class="fa fa-times"></i> Annuler
      </button>
    </div>

  </form>
</div>

<script src="https://cdn.jsdelivr.net/npm/tinymce@6/tinymce.min.js"></script>
<script>
(function() {
  'use strict';

  const CAMP_ID = <?= $camp_id ?>;
  const SCE_ID  = <?= (int)$sce['sce_id'] ?>;

  (function initTMCE() {
    if (typeof tinymce === 'undefined') { setTimeout(initTMCE, 100); return; }
    var isLight = document.body.classList.contains('theme-light');
    tinymce.remove('#sce_description');
    tinymce.init({
      selector:    '#sce_description',
      language:    'fr_FR',
      menubar:     false,
      plugins:       'lists link image table code',
      toolbar:       'styles | bold italic underline | bullist numlist | link unlink image table | removeformat | code',
      height:        300,
      skin:          isLight ? 'oxide' : 'oxide-dark',
      content_css:   isLight ? 'default' : 'dark',
      content_style: isLight
        ? 'body { background:#eae6dd; color:#2a2015; font-family:inherit; font-size:14px; }'
        : 'body { background:#0f3460; color:#e0e0e0; font-family:inherit; font-size:14px; }',
      promotion:   false,
      branding:    false,
      base_url:    'https://cdn.jsdelivr.net/npm/tinymce@6',
      suffix:      '.min',
      images_upload_url:         '<?= BASE_URL ?>/include/ajax/upload-image.php',
      images_upload_credentials: true,
      automatic_uploads:         true,
    });
  })();

  function tmceGet(id) {
    if (typeof tinymce !== 'undefined') {
      const ed = tinymce.get(id);
      if (ed && ed.initialized) return ed.getContent();
    }
    const el = document.getElementById(id);
    return el ? el.value : '';
  }

  function soumettre() {
    const form = document.getElementById('form-scenario');
    if (!form) return;

    const nom = document.getElementById('sce_nom').value.trim();
    if (!nom) { alert('Le nom du scénario est obligatoire.'); return; }

    const descEl = document.getElementById('sce_description');
    if (descEl) descEl.value = tmceGet('sce_description');

    fetch(form.getAttribute('action'), { method: 'POST', body: new FormData(form) })
      .then(r => r.json())
      .then(data => {
        if (data.ok) {
          fermerModification();
          if (SCE_ID > 0) {
            // Modification : rafraîchit la vue scénario courante dans #detail-pp.
            // retourDetailPP() rechargerait la campagne — on veut rester sur le scénario.
            const urlSce = campUrlDetail.replace('/campagne.php', '/scenario.php');
            naviguerDetailPP(urlSce, { id: SCE_ID });
          } else {
            // Création : remonte à la vue campagne (racine de la pile).
            actualiserPage(campUrlDetail, { id: CAMP_ID }, _detailPpContext);
            _pendingListRefresh = true;
          }
        } else {
          alert(data.erreur || "Erreur lors de l'enregistrement.");
        }
      })
      .catch(err => alert('Erreur : ' + err));
  }

  window.scenarioForm = { soumettre: soumettre };

})();
</script>
