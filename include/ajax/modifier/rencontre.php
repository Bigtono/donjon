<?php
// include/ajax/modifier/rencontre.php
// Formulaire de création / modification d'une rencontre.
// Paramètres GET : id (int) — re_id (0 = création), scc_id (requis si id=0)

require_once __DIR__ . '/../../db.php';
require_once __DIR__ . '/../../auth.php';
require_once __DIR__ . '/../../helpers.php';

requireAuth();

$id     = intParam($_GET['id']     ?? 0);
$scc_id = intParam($_GET['scc_id'] ?? 0);

$re = [
  're_id'          => 0,
  're_nom'         => '',
  're_code'        => '',
  're_description' => '',
  're_composition' => '',
  're_scc_id'      => $scc_id,
];

// Fonction utilitaire : remonte camp_id depuis scc_id
function getCampIdFromScc(PDO $db, int $scc_id): int {
  $stmt = $db->prepare('
    SELECT camp.camp_id FROM dd_scenarios_chapitres scc
    JOIN   dd_scenarios sce  ON sce.sce_id  = scc.scc_sce_id
    JOIN   dd_campagnes camp ON camp.camp_id = sce.sce_camp_id
    WHERE  scc.scc_id = ? AND scc.scc_supprime = 0
      AND  sce.sce_supprime = 0 AND camp.camp_supprime = 0
  ');
  $stmt->execute([$scc_id]);
  return (int)$stmt->fetchColumn();
}

if ($id > 0):
  $stmt = $db->prepare('
    SELECT re.* FROM dd_rencontres re
    WHERE  re.re_id = ? AND re.re_supprime = 0
  ');
  $stmt->execute([$id]);
  $row = $stmt->fetch();
  if (!$row):
    http_response_code(404);
    echo '<p class="erreur">Rencontre introuvable.</p>';
    exit;
  endif;
  $camp_id = getCampIdFromScc($db, (int)$row['re_scc_id']);
  if (!isMJ($db, $camp_id)):
    http_response_code(403);
    echo '<p class="erreur">Accès refusé.</p>';
    exit;
  endif;
  $re     = $row;
  $scc_id = (int)$row['re_scc_id'];
else:
  if (!$scc_id):
    http_response_code(400);
    echo '<p class="erreur">scc_id manquant.</p>';
    exit;
  endif;
  $camp_id = getCampIdFromScc($db, $scc_id);
  if (!$camp_id || !isMJ($db, $camp_id)):
    http_response_code(403);
    echo '<p class="erreur">Accès refusé.</p>';
    exit;
  endif;
endif;

$titre = $id > 0 ? 'Modifier ' . h($re['re_nom']) : 'Nouvelle rencontre';
?>

<div class="modif-form">
  <h3 class="modif-form__title"><?= $titre ?></h3>

  <form id="form-rencontre" method="POST"
        action="<?= BASE_URL ?>/campagnes/enregistrement.php?ajax=1">
    <?= csrfField() ?>
    <input type="hidden" name="action"  value="enregistrerRencontre">
    <input type="hidden" name="re_id"   value="<?= (int)$re['re_id'] ?>">
    <input type="hidden" name="scc_id"  value="<?= $scc_id ?>">

    <div class="modif-section">
      <div class="modif-section__header">
        <span class="modif-section__label">Données de la rencontre</span>
      </div>

      <div class="modif-grid">

        <div class="form-group modif-grid__full">
          <label for="re_nom">Nom <span class="required">*</span></label>
          <input type="text" id="re_nom" name="re_nom"
                 value="<?= h($re['re_nom']) ?>" required maxlength="150">
        </div>

        <div class="form-group">
          <label for="re_code">Code de référence <span class="form-hint">(20 car. max)</span></label>
          <input type="text" id="re_code" name="re_code"
                 value="<?= h($re['re_code'] ?? '') ?>" maxlength="20" style="width:140px;">
        </div>

      </div>

      <div class="form-group">
        <label for="re_composition">Composition
          <span class="form-hint">— effectifs, disposition, vagues…</span>
        </label>
        <textarea id="re_composition" name="re_composition"
                  class="tinymce-full"><?= h($re['re_composition'] ?? '') ?></textarea>
      </div>

      <div class="form-group">
        <label for="re_description">Description</label>
        <textarea id="re_description" name="re_description"
                  class="tinymce-full"><?= h($re['re_description'] ?? '') ?></textarea>
      </div>

    </div>

    <div class="modif-actions">
      <button type="button" class="btn btn-primary" onclick="rencontreForm.soumettre()">
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

  const RE_ID          = <?= (int)$re['re_id'] ?>;
  const SCC_ID         = <?= $scc_id ?>;
  const URL_RE_DETAIL  = <?= json_encode(BASE_URL . '/include/ajax/detail-pp/rencontre.php') ?>;
  const URL_SCC_DETAIL = <?= json_encode(BASE_URL . '/include/ajax/detail-pp/chapitre.php') ?>;

  (function initTMCE() {
    if (typeof tinymce === 'undefined') { setTimeout(initTMCE, 100); return; }
    var isLight = document.body.classList.contains('theme-light');
    var contentStyle = isLight
      ? 'body { background:#eae6dd; color:#2a2015; font-family:inherit; font-size:14px; }'
      : 'body { background:#0f3460; color:#e0e0e0; font-family:inherit; font-size:14px; }';

    // Composition — toolbar légère (texte structuré, pas d'image ni de table)
    tinymce.remove('#re_composition');
    tinymce.init({
      selector:      '#re_composition',
      language:      'fr_FR',
      menubar:       false,
      plugins:       'lists link code',
      toolbar:       'styles | bold italic underline | bullist numlist | link unlink | removeformat | code',
      height:        180,
      skin:          isLight ? 'oxide' : 'oxide-dark',
      content_css:   isLight ? 'default' : 'dark',
      content_style: contentStyle,
      promotion:     false,
      branding:      false,
      base_url:      'https://cdn.jsdelivr.net/npm/tinymce@6',
      suffix:        '.min',
    });

    // Description — toolbar complète avec image et table
    tinymce.remove('#re_description');
    tinymce.init({
      selector:      '#re_description',
      language:      'fr_FR',
      menubar:       false,
      plugins:       'lists link image table code',
      toolbar:       'styles | bold italic underline | bullist numlist | link unlink image table | removeformat | code',
      height:        320,
      skin:          isLight ? 'oxide' : 'oxide-dark',
      content_css:   isLight ? 'default' : 'dark',
      content_style: contentStyle,
      promotion:     false,
      branding:      false,
      base_url:      'https://cdn.jsdelivr.net/npm/tinymce@6',
      suffix:        '.min',
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
    const form = document.getElementById('form-rencontre');
    if (!form) return;

    const nom = document.getElementById('re_nom').value.trim();
    if (!nom) { alert('Le nom de la rencontre est obligatoire.'); return; }

    const descEl = document.getElementById('re_description');
    if (descEl) descEl.value = tmceGet('re_description');

    const compEl = document.getElementById('re_composition');
    if (compEl) compEl.value = tmceGet('re_composition');

    fetch(form.getAttribute('action'), { method: 'POST', body: new FormData(form) })
      .then(r => r.json())
      .then(data => {
        if (data.ok) {
          fermerModification();
          if (RE_ID > 0) {
            // Modification : rafraîchit la vue rencontre courante.
            naviguerDetailPP(URL_RE_DETAIL, { id: RE_ID });
          } else {
            // Création : remonte à la vue chapitre parent.
            naviguerDetailPP(URL_SCC_DETAIL, { id: SCC_ID });
          }
        } else {
          alert(data.erreur || "Erreur lors de l'enregistrement.");
        }
      })
      .catch(err => alert('Erreur : ' + err));
  }

  window.rencontreForm = { soumettre: soumettre };

})();
</script>
