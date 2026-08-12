<?php
// include/ajax/modifier/competence.php
// Formulaire de création/modification d'une compétence
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
$ruleset_id = (int)($_SESSION['ruleset_var_id'] ?? 1);
$uid        = (int)($_SESSION['j_id'] ?? 0);
$res_ids    = getActiveResIds($db);

// Valeurs par défaut (création)
$comp = [
  'comp_id'             => 0,
  'comp_nom'            => '',
  'comp_car_id'         => '',
  'comp_formation'      => 0,
  'comp_malusArmure'    => 0,
  'comp_description'    => '',
  'comp_res_id'         => '',
  'comp_public'         => 0,
  'comp_visible'        => 1,
];

if ($id > 0):
  $stmt = $db->prepare('SELECT * FROM dd_competences WHERE comp_id = ?');
  $stmt->execute([$id]);
  $row = $stmt->fetch();
  if ($row) $comp = $row;
endif;

// Caractéristiques (dd_caracteristiques)
$caracteristiques = $db->query(
  'SELECT car_id, car_nom FROM dd_caracteristiques ORDER BY car_nom'
)->fetchAll();

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
$comp_supplement_res_id = getUserSupplementResId($db, $uid, $ruleset_id);
$comp_supplement_nom    = '';
if ($comp_supplement_res_id !== null):
  $stmt = $db->prepare('SELECT res_nom FROM dd_ressources WHERE res_id = ?');
  $stmt->execute([$comp_supplement_res_id]);
  $comp_supplement_nom = (string)$stmt->fetchColumn();
else:
  $stmt = $db->prepare('SELECT j_pseudo FROM dd_joueurs WHERE j_id = ?');
  $stmt->execute([$uid]);
  $pseudo = $stmt->fetchColumn();
  $comp_supplement_nom = 'Supplément de ' . ($pseudo !== false ? $pseudo : 'utilisateur');
endif;

// Valeur actuellement sélectionnée par le formulaire pour comp_res_id
$comp_res_id_select = (string)$comp['comp_res_id'];
if ($comp_supplement_res_id !== null && (int)$comp['comp_res_id'] === $comp_supplement_res_id):
  $comp_res_id_select = 'supplement';
endif;

$titre = $id > 0 ? 'Modifier ' . h($comp['comp_nom']) : 'Nouvelle compétence';
?>

<div class="modif-form">
  <h3 class="modif-form__title"><?= $titre ?></h3>

  <form id="form-competence" method="POST"
        action="<?= BASE_URL ?>/compendium/enregistrement.php?ajax=1">
    <?= csrfField() ?>
    <input type="hidden" name="entite"              value="competence">
    <input type="hidden" name="action"              value="sauvegarder">
    <input type="hidden" name="comp_id"             value="<?= (int)$comp['comp_id'] ?>">
    <input type="hidden" name="comp_ruleset_var_id" value="<?= $ruleset_id ?>">

    <div class="modif-section">
      <div class="modif-grid">

        <!-- Nom -->
        <div class="form-group modif-grid__full">
          <label for="comp_nom">Nom <span class="required">*</span></label>
          <input type="text" id="comp_nom" name="comp_nom"
                 value="<?= h($comp['comp_nom']) ?>" required maxlength="100">
        </div>

        <!-- Caractéristique associée -->
        <div class="form-group">
          <label for="comp_car_id">Caractéristique <span class="required">*</span></label>
          <select id="comp_car_id" name="comp_car_id" required>
            <option value="">— Choisir —</option>
            <?php foreach ($caracteristiques as $car): ?>
              <option value="<?= (int)$car['car_id'] ?>"
                <?= (int)$comp['comp_car_id'] === (int)$car['car_id'] ? 'selected' : '' ?>>
                <?= h($car['car_nom']) ?>
              </option>
            <?php endforeach ?>
          </select>
        </div>

        <!-- Source -->
        <div class="form-group">
          <label for="comp_res_id">Source <span class="required">*</span></label>
          <select id="comp_res_id" name="comp_res_id" required>
            <option value="">— Choisir —</option>
            <optgroup label="Sources officielles">
              <?php foreach ($sources_officielles as $src): ?>
                <option value="<?= (int)$src['res_id'] ?>" data-supplement="0"
                  <?= $comp_res_id_select === (string)$src['res_id'] ? 'selected' : '' ?>>
                  <?= h($src['res_nom']) ?>
                </option>
              <?php endforeach ?>
            </optgroup>
            <optgroup label="Mon supplément">
              <option value="supplement" data-supplement="1"
                <?= $comp_res_id_select === 'supplement' ? 'selected' : '' ?>>
                <?= h($comp_supplement_nom) ?>
              </option>
            </optgroup>
          </select>
        </div>

        <!-- Visibilité (supplément uniquement) -->
        <div class="form-group" id="comp-supplement-visibilite" hidden>
          <label class="form-label--checkbox">
            <input type="checkbox" id="comp_public" name="comp_public" value="1"
              <?= (int)$comp['comp_public'] === 1 ? 'checked' : '' ?>>
            Partagé (visible des autres utilisateurs ayant ce supplément comme source)
          </label>
          <label class="form-label--checkbox">
            <input type="checkbox" id="comp_visible" name="comp_visible" value="1"
              <?= (int)$comp['comp_visible'] === 1 ? 'checked' : '' ?>>
            Visible (décoché = brouillon masqué, accessible via « Afficher mes brouillons »)
          </label>
          <span class="form-hint">Une entrée partagée est forcément visible.</span>
        </div>

        <!-- Formation requise -->
        <div class="form-group">
          <label class="form-label--checkbox">
            <input type="checkbox" name="comp_formation" value="1"
              <?= $comp['comp_formation'] ? 'checked' : '' ?>>
            Formation requise
          </label>
        </div>

        <!-- Malus d'armure -->
        <div class="form-group">
          <label for="comp_malusArmure">Malus d'armure</label>
          <input type="number" id="comp_malusArmure" name="comp_malusArmure"
                 value="<?= (int)$comp['comp_malusArmure'] ?>" min="0" max="99">
        </div>

      </div><!-- .modif-grid -->
    </div><!-- .modif-section -->

    <!-- Description TinyMCE -->
    <div class="modif-section">
      <div class="form-group">
        <label for="comp_description">Description<?= aideIcone('texte-parsers') ?></label>
        <textarea id="comp_description" name="comp_description"
                  class="tinymce-basic"><?= $comp['comp_description'] ?? '' ?></textarea>
      </div>
    </div>

    <!-- Boutons -->
    <div class="modif-actions">
      <button type="button" class="btn btn-primary" onclick="soumettreCompetence()">
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
  var selectRes  = document.getElementById('comp_res_id');
  var blocVisib  = document.getElementById('comp-supplement-visibilite');
  var chkPublic  = document.getElementById('comp_public');
  var chkVisible = document.getElementById('comp_visible');

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
  tinymce.remove('#comp_description');
  tinymce.init({
    selector:      '#comp_description',
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
