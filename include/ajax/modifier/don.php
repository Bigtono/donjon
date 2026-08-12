<?php
// include/ajax/modifier/don.php
// Formulaire de création/modification d'un don
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
$ruleset    = $_SESSION['rulesetRep'] ?? 'DD3.5';
$ruleset_id = (int)($_SESSION['ruleset_var_id'] ?? 1);
$uid        = (int)($_SESSION['j_id'] ?? 0);
$res_ids    = getActiveResIds($db);

// Valeurs par défaut (création)
$don = [
  'do_id'            => 0,
  'do_nom'           => '',
  'do_dado_id'       => '',
  'do_conditions'    => '',
  'do_texte'         => '',
  'do_resume'        => '',
  'do_res_id'        => '',
  'do_camp_id'       => '',
  'do_public'        => 0,
  'do_visible'       => 1,
];

if ($id > 0):
  $stmt = $db->prepare('SELECT * FROM dd_dons WHERE do_id = ?');
  $stmt->execute([$id]);
  $row = $stmt->fetch();
  if ($row) $don = $row;
endif;

// Catégories de dons
$stmt = $db->prepare(
  'SELECT dado_id, dado_nom FROM dd_data_don WHERE dado_ruleset_var_id = ? ORDER BY dado_nom'
);
$stmt->execute([$ruleset_id]);
$categories = $stmt->fetchAll();

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
$don_supplement_res_id = getUserSupplementResId($db, $uid, $ruleset_id);
$don_supplement_nom    = '';
if ($don_supplement_res_id !== null):
  $stmt = $db->prepare('SELECT res_nom FROM dd_ressources WHERE res_id = ?');
  $stmt->execute([$don_supplement_res_id]);
  $don_supplement_nom = (string)$stmt->fetchColumn();
else:
  $stmt = $db->prepare('SELECT j_pseudo FROM dd_joueurs WHERE j_id = ?');
  $stmt->execute([$uid]);
  $pseudo = $stmt->fetchColumn();
  $don_supplement_nom = 'Supplément de ' . ($pseudo !== false ? $pseudo : 'utilisateur');
endif;

// Valeur actuellement sélectionnée par le formulaire pour do_res_id
$do_res_id_select = (string)$don['do_res_id'];
if ($don_supplement_res_id !== null && (int)$don['do_res_id'] === $don_supplement_res_id):
  $do_res_id_select = 'supplement';
endif;

// Campagnes de l'utilisateur
$campagnes = [];
if (!empty($_SESSION['j_mode_campagne'])):
  [$owWhere, $owParams] = ownerFilter('camp');
  $stmt = $db->prepare("SELECT camp_id, camp_nom FROM dd_campagnes WHERE $owWhere ORDER BY camp_nom");
  $stmt->execute($owParams);
  $campagnes = $stmt->fetchAll();
endif;

$titre = $id > 0 ? 'Modifier ' . h($don['do_nom']) : 'Nouveau don';
?>

<div class="modif-form">
  <h3 class="modif-form__title"><?= $titre ?></h3>

  <form id="form-don" method="POST"
        action="<?= BASE_URL ?>/compendium/enregistrement.php?ajax=1">
    <?= csrfField() ?>
    <input type="hidden" name="entite"           value="don">
    <input type="hidden" name="action"           value="sauvegarder">
    <input type="hidden" name="do_id"            value="<?= (int)$don['do_id'] ?>">
    <input type="hidden" name="do_ruleset_var_id" value="<?= $ruleset_id ?>">

    <div class="modif-section">
      <div class="modif-grid">

        <!-- Nom -->
        <div class="form-group modif-grid__full">
          <label for="do_nom">Nom <span class="required">*</span></label>
          <input type="text" id="do_nom" name="do_nom"
                 value="<?= h($don['do_nom']) ?>" required maxlength="150">
        </div>

        <!-- Prérequis DD2024 -->
        <?php if ($ruleset === 'DD2024'): ?>
          <div class="form-group modif-grid__full">
            <label for="do_conditions">Prérequis</label>
            <input type="text" id="do_conditions" name="do_conditions"
                   value="<?= h($don['do_conditions'] ?? '') ?>"
                   placeholder="Ex : niveau 4 ou supérieur, Force 13 ou plus">
          </div>
        <?php endif ?>

        <!-- Catégorie -->
        <div class="form-group">
          <label for="do_dado_id">Catégorie</label>
          <select id="do_dado_id" name="do_dado_id">
            <option value="">— Aucune —</option>
            <?php foreach ($categories as $cat): ?>
              <option value="<?= (int)$cat['dado_id'] ?>"
                <?= (int)$don['do_dado_id'] === (int)$cat['dado_id'] ? 'selected' : '' ?>>
                <?= h($cat['dado_nom']) ?>
              </option>
            <?php endforeach ?>
          </select>
        </div>

        <!-- Source -->
        <div class="form-group">
          <label for="do_res_id">Source <span class="required">*</span></label>
          <select id="do_res_id" name="do_res_id" required>
            <option value="">— Choisir —</option>
            <optgroup label="Sources officielles">
              <?php foreach ($sources_officielles as $src): ?>
                <option value="<?= (int)$src['res_id'] ?>" data-supplement="0"
                  <?= $do_res_id_select === (string)$src['res_id'] ? 'selected' : '' ?>>
                  <?= h($src['res_nom']) ?>
                </option>
              <?php endforeach ?>
            </optgroup>
            <optgroup label="Mon supplément">
              <option value="supplement" data-supplement="1"
                <?= $do_res_id_select === 'supplement' ? 'selected' : '' ?>>
                <?= h($don_supplement_nom) ?>
              </option>
            </optgroup>
          </select>
        </div>

        <!-- Visibilité (supplément uniquement) -->
        <div class="form-group" id="do-supplement-visibilite" hidden>
          <label class="form-label--checkbox">
            <input type="checkbox" id="do_public" name="do_public" value="1"
              <?= (int)$don['do_public'] === 1 ? 'checked' : '' ?>>
            Partagé (visible des autres utilisateurs ayant ce supplément comme source)
          </label>
          <label class="form-label--checkbox">
            <input type="checkbox" id="do_visible" name="do_visible" value="1"
              <?= (int)$don['do_visible'] === 1 ? 'checked' : '' ?>>
            Visible (décoché = brouillon masqué, accessible via « Afficher mes brouillons »)
          </label>
          <span class="form-hint">Une entrée partagée est forcément visible.</span>
        </div>

        <!-- Campagne homebrew -->
        <?php if (!empty($campagnes)): ?>
          <div class="form-group">
            <label for="do_camp_id">Campagne (homebrew)</label>
            <select id="do_camp_id" name="do_camp_id">
              <option value="">— Compendium global —</option>
              <?php foreach ($campagnes as $camp): ?>
                <option value="<?= (int)$camp['camp_id'] ?>"
                  <?= (int)$don['do_camp_id'] === (int)$camp['camp_id'] ? 'selected' : '' ?>>
                  <?= h($camp['camp_nom']) ?>
                </option>
              <?php endforeach ?>
            </select>
          </div>
        <?php endif ?>

      </div><!-- .modif-grid -->
    </div><!-- .modif-section -->

    <!-- Description TinyMCE -->
    <div class="modif-section">
      <div class="form-group">
        <label for="do_texte">Description<?= aideIcone('texte-parsers') ?></label>
        <textarea id="do_texte" name="do_texte"
                  class="tinymce-basic"><?= $don['do_texte'] ?? '' ?></textarea>
      </div>
    </div>

    <!-- Résumé -->
    <div class="modif-section">
      <div class="form-group">
        <label for="do_resume">Résumé
          <span class="form-hint" style="font-weight:normal;">
            (usage futur dans les listes)
          </span>
        </label>
        <textarea id="do_resume" name="do_resume"
                  rows="3"><?= h($don['do_resume'] ?? '') ?></textarea>
      </div>
    </div>

    <!-- Boutons -->
    <div class="modif-actions">
      <button type="button" class="btn btn-primary" onclick="soumettreDon()">
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
  // Affiche/masque le bloc public/visible selon le groupe de la source
  // sélectionnée (officielle vs supplément personnel), et applique la
  // contrainte client _public=1 => _visible coché + désactivé.
  var selectRes  = document.getElementById('do_res_id');
  var blocVisib  = document.getElementById('do-supplement-visibilite');
  var chkPublic  = document.getElementById('do_public');
  var chkVisible = document.getElementById('do_visible');

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
  tinymce.remove('#do_texte');
  tinymce.init({
    selector:      '#do_texte',
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
</script>
