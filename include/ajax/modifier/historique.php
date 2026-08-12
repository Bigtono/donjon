<?php
// include/ajax/modifier/historique.php
// Formulaire de création/modification d'un historique (DD2024)
// Paramètres GET : id (int, 0 = création)

require_once __DIR__ . '/../../db.php';
require_once __DIR__ . '/../../auth.php';
require_once __DIR__ . '/../../helpers.php';

requireAuth();
if (!canEditCompendium()):
  http_response_code(403);
  echo '<p class="erreur">Accès refusé.</p>';
  exit;
endif;

$id         = intParam($_GET['id'] ?? 0);
$ruleset_id = (int)($_SESSION['ruleset_var_id'] ?? 2);
$uid        = (int)($_SESSION['j_id'] ?? 0);
$res_ids    = getActiveResIds($db);

// Valeurs par défaut (création)
$historique = [
  'hi_id'              => 0,
  'hi_nom'             => '',
  'hi_description'     => '',
  'hi_res_id'          => '',
  'hi_camp_id'         => '',
  'hi_public'          => 0,
  'hi_visible'         => 1,
];

if ($id > 0):
  $stmt = $db->prepare('SELECT * FROM dd_historiques WHERE hi_id = ?');
  $stmt->execute([$id]);
  $row = $stmt->fetch();
  if ($row) $historique = $row;
endif;

// Ressources actives — scindées en 2 groupes pour le select du formulaire :
// sources officielles (res_j_id IS NULL) vs supplément personnel de
// l'utilisateur courant (le seul supplément qu'il a le droit d'alimenter).
$sources_officielles = [];
if (!empty($res_ids)):
  $ph   = resIdsPlaceholders($res_ids);
  $stmt = $db->prepare("
    SELECT res_id, res_nom
    FROM   dd_ressources
    WHERE  res_id IN ($ph) AND res_j_id IS NULL
    ORDER  BY res_nom
  ");
  $stmt->execute($res_ids);
  $sources_officielles = $stmt->fetchAll();
endif;

// Supplément de l'utilisateur courant : peut ne pas encore exister. Dans ce
// cas, l'option du select porte la valeur sentinelle 'supplement' ; la
// ressource sera créée à la volée au save (getOrCreateUserSupplement()).
$hi_supplement_res_id = getUserSupplementResId($db, $uid, $ruleset_id);
$hi_supplement_nom    = '';
if ($hi_supplement_res_id !== null):
  $stmt = $db->prepare('SELECT res_nom FROM dd_ressources WHERE res_id = ?');
  $stmt->execute([$hi_supplement_res_id]);
  $hi_supplement_nom = (string)$stmt->fetchColumn();
else:
  $stmt = $db->prepare('SELECT j_pseudo FROM dd_joueurs WHERE j_id = ?');
  $stmt->execute([$uid]);
  $pseudo = $stmt->fetchColumn();
  $hi_supplement_nom = 'Supplément de ' . ($pseudo !== false ? $pseudo : 'utilisateur');
endif;

// Valeur actuellement sélectionnée par le formulaire pour hi_res_id
$hi_res_id_select = (string)$historique['hi_res_id'];
if ($hi_supplement_res_id !== null && (int)$historique['hi_res_id'] === $hi_supplement_res_id):
  $hi_res_id_select = 'supplement';
endif;

// Campagnes de l'utilisateur (homebrew)
$campagnes = [];
if (!empty($_SESSION['j_mode_campagne'])):
  [$owWhere, $owParams] = ownerFilter('camp');
  $stmt = $db->prepare("SELECT camp_id, camp_nom FROM dd_campagnes WHERE $owWhere ORDER BY camp_nom");
  $stmt->execute($owParams);
  $campagnes = $stmt->fetchAll();
endif;

$titre = $id > 0 ? 'Modifier ' . h($historique['hi_nom']) : 'Nouvel historique';
?>

<div class="modif-form">
  <h3 class="modif-form__title"><?= $titre ?></h3>

  <form id="form-historique" method="POST"
        action="<?= BASE_URL ?>/compendium/enregistrement.php?ajax=1">
    <?= csrfField() ?>
    <input type="hidden" name="entite"              value="historique">
    <input type="hidden" name="action"              value="sauvegarder">
    <input type="hidden" name="hi_id"               value="<?= (int)$historique['hi_id'] ?>">
    <input type="hidden" name="hi_ruleset_var_id"   value="<?= $ruleset_id ?>">

    <div class="modif-section">
      <div class="modif-grid">

        <!-- Nom -->
        <div class="form-group modif-grid__full">
          <label for="hi_nom">Nom <span class="required">*</span></label>
          <input type="text" id="hi_nom" name="hi_nom"
                 value="<?= h($historique['hi_nom']) ?>" required maxlength="150">
        </div>

        <!-- Source -->
        <div class="form-group">
          <label for="hi_res_id">Source <span class="required">*</span></label>
          <select id="hi_res_id" name="hi_res_id" required>
            <option value="">— Choisir —</option>
            <optgroup label="Sources officielles">
              <?php foreach ($sources_officielles as $src): ?>
                <option value="<?= (int)$src['res_id'] ?>" data-supplement="0"
                  <?= $hi_res_id_select === (string)$src['res_id'] ? 'selected' : '' ?>>
                  <?= h($src['res_nom']) ?>
                </option>
              <?php endforeach ?>
            </optgroup>
            <optgroup label="Mon supplément">
              <option value="supplement" data-supplement="1"
                <?= $hi_res_id_select === 'supplement' ? 'selected' : '' ?>>
                <?= h($hi_supplement_nom) ?>
              </option>
            </optgroup>
          </select>
        </div>

        <!-- Visibilité (supplément uniquement) -->
        <div class="form-group" id="hi-supplement-visibilite" hidden>
          <label class="form-label--checkbox">
            <input type="checkbox" id="hi_public" name="hi_public" value="1"
              <?= (int)$historique['hi_public'] === 1 ? 'checked' : '' ?>>
            Partagé (visible des autres utilisateurs ayant ce supplément comme source)
          </label>
          <label class="form-label--checkbox">
            <input type="checkbox" id="hi_visible" name="hi_visible" value="1"
              <?= (int)$historique['hi_visible'] === 1 ? 'checked' : '' ?>>
            Visible (décoché = brouillon masqué, accessible via « Afficher mes brouillons »)
          </label>
          <span class="form-hint">Une entrée partagée est forcément visible.</span>
        </div>

        <!-- Campagne homebrew -->
        <?php if (!empty($campagnes)): ?>
          <div class="form-group">
            <label for="hi_camp_id">Campagne (homebrew)</label>
            <select id="hi_camp_id" name="hi_camp_id">
              <option value="">— Compendium global —</option>
              <?php foreach ($campagnes as $camp): ?>
                <option value="<?= (int)$camp['camp_id'] ?>"
                  <?= (int)$historique['hi_camp_id'] === (int)$camp['camp_id'] ? 'selected' : '' ?>>
                  <?= h($camp['camp_nom']) ?>
                </option>
              <?php endforeach ?>
            </select>
          </div>
        <?php endif ?>

      </div><!-- .modif-grid -->
    </div><!-- .modif-section -->

    <!-- Description TinyMCE avec tables -->
    <div class="modif-section">
      <div class="form-group">
        <label for="hi_description">Description<?= aideIcone('texte-parsers') ?></label>
        <textarea id="hi_description" name="hi_description"
                  class="tinymce-historique"><?= $historique['hi_description'] ?? '' ?></textarea>
      </div>
    </div>

    <!-- Boutons -->
    <div class="modif-actions">
      <button type="button" class="btn btn-primary" onclick="soumettreHistorique()">
        <i class="fa fa-save"></i> Enregistrer
      </button>
      <button type="button" class="btn btn-secondary" onclick="fermerModification()">
        <i class="fa fa-times"></i> Annuler
      </button>
    </div>

  </form>
</div>

<script>
(function () {
  var selectRes  = document.getElementById('hi_res_id');
  var blocVisib  = document.getElementById('hi-supplement-visibilite');
  var chkPublic  = document.getElementById('hi_public');
  var chkVisible = document.getElementById('hi_visible');

  if (!selectRes || !blocVisib) return;

  function appliquerContrainte() {
    if (chkPublic.checked) {
      chkVisible.checked = true;
      chkVisible.disabled = true;
    } else {
      chkVisible.disabled = false;
    }
  }

  function actualiserAffichage() {
    var option = selectRes.options[selectRes.selectedIndex];
    var estSupplement = option && option.getAttribute('data-supplement') === '1';
    blocVisib.hidden = !estSupplement;
    if (estSupplement) appliquerContrainte();
  }

  selectRes.addEventListener('change', actualiserAffichage);
  if (chkPublic) chkPublic.addEventListener('change', appliquerContrainte);

  actualiserAffichage();
}());
</script>

<!-- TinyMCE via jsDelivr -->
<script src="https://cdn.jsdelivr.net/npm/tinymce@6/tinymce.min.js"></script>
<script>
(function initTMCE() {
  if (typeof tinymce === 'undefined') { setTimeout(initTMCE, 100); return; }
  var isLight = document.body.classList.contains('theme-light');
  tinymce.remove('#hi_description');
  tinymce.init({
    selector:      '#hi_description',
    language:      'fr_FR',
    menubar:       false,
    plugins:       'lists link table code',
    toolbar:       'styles | bold italic underline | bullist numlist | link unlink table | tableau | removeformat | code',
    // Bouton d'insertion d'un tableau dd_tableaux (SP-TB7) —
    // implémentation partagée dans js/main.js
    setup: function (editor) {
      if (typeof tableauxInitBouton === 'function') tableauxInitBouton(editor);
    },
    height:        400,
    skin:          isLight ? 'oxide' : 'oxide-dark',
    content_css:   isLight ? 'default' : 'dark',
    content_style: isLight
      ? 'body { background:#eae6dd; color:#2a2015; font-family:inherit; font-size:14px; }'
      : 'body { background:#0f3460; color:#e0e0e0; font-family:inherit; font-size:14px; }',
    promotion:     false,
    branding:      false,
    base_url:      'https://cdn.jsdelivr.net/npm/tinymce@6',
    suffix:        '.min',
  });
})();

function soumettreHistorique() {
  if (typeof tinymce !== 'undefined') tinymce.triggerSave();
  var form = document.getElementById('form-historique');
  var action = form.getAttribute('action');
  var data = new FormData(form);

  fetch(action, { method: 'POST', body: data })
    .then(function(r) { return r.json(); })
    .then(function(json) {
      if (json.ok) {
        apresModification(json);
      } else {
        alert(json.erreur || 'Erreur lors de l\'enregistrement.');
      }
    })
    .catch(function() {
      alert('Erreur réseau.');
    });
}
</script>
