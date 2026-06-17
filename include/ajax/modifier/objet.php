<?php
// include/ajax/modifier/objet.php
// Formulaire de création/modification d'un objet magique
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
$ruleset_rep = $_SESSION['rulesetRep'] ?? 'DD3.5';
$res_ids    = getActiveResIds($db);

// Valeurs par défaut (création)
$om = [
  'om_id'           => 0,
  'om_nom'          => '',
  'om_com_id'       => '',
  'om_fom_id'       => 2,
  'om_so_id'        => null,
  'om_so_niveau'    => 0,
  'om_modificateurs'=> 0,
  'om_variantes'    => '',
  'om_description'  => '',
  'om_visible'      => 1,
  'om_res_id'       => '',
  'om_camp_id'      => null,
];

if ($id > 0):
  $stmt = $db->prepare('SELECT * FROM dd_objets_magiques WHERE om_id = ?');
  $stmt->execute([$id]);
  $row = $stmt->fetch();
  if ($row) $om = $row;
endif;

// Catégories (filtrées par ruleset)
$categories = $db->prepare('
  SELECT com_id, com_nom, com_est_calcule
  FROM   dd_categorie_objet_magique
  WHERE  com_ruleset_var_id = ?
  ORDER  BY com_nom
');
$categories->execute([$ruleset_id]);
$categories = $categories->fetchAll();

// Map com_id → com_est_calcule pour injecter en JS
$cat_calcule_map = [];
foreach ($categories as $cat):
  $cat_calcule_map[(int)$cat['com_id']] = (int)$cat['com_est_calcule'];
endforeach;

// Formats d'objet
$formats = $db->query('SELECT fom_id, fom_nom FROM dd_format_objet_magique ORDER BY fom_id')
  ->fetchAll();

// Ressources actives
$sources = [];
if (!empty($res_ids)):
  $ph   = resIdsPlaceholders($res_ids);
  $stmt = $db->prepare("SELECT res_id, res_nom FROM dd_ressources WHERE res_id IN ($ph) ORDER BY res_nom");
  $stmt->execute($res_ids);
  $sources = $stmt->fetchAll();
endif;

// Pré-remplissage du label de sort (en modification avec sort lié)
$so_label_initial = '';
if (!empty($om['om_so_id'])):
  $stmt_so = $db->prepare('
    SELECT so.so_nom, res.res_nom,
      CASE WHEN so.so_ruleset_var_id = 1
        THEN (SELECT MIN(sc_niveau) FROM dd_sortclasse WHERE sc_so_id = so.so_id)
        ELSE so.so_niveau
      END AS niveau
    FROM   dd_sorts         so
    LEFT JOIN dd_ressources res ON res.res_id = so.so_res_id
    WHERE  so.so_id = ?
  ');
  $stmt_so->execute([(int)$om['om_so_id']]);
  $row_so = $stmt_so->fetch();
  if ($row_so):
    $niv             = $row_so['niveau'] !== null ? 'Niv. ' . (int)$row_so['niveau'] : '—';
    $so_label_initial = $row_so['so_nom'] . ' — ' . $niv . ' (' . $row_so['res_nom'] . ')';
  endif;
endif;

// Catégorie sélectionnée → calcule ?
$com_id_sel      = (int)($om['om_com_id'] ?? 0);
$cat_est_calcule = $cat_calcule_map[$com_id_sel] ?? 0;

$titre = $id > 0 ? 'Modifier ' . h($om['om_nom']) : 'Nouvel objet magique';
?>

<div class="modif-form">
  <h3 class="modif-form__title"><?= $titre ?></h3>

  <form id="form-objet" method="POST"
        action="<?= BASE_URL ?>/compendium/enregistrement.php?ajax=1">
    <?= csrfField() ?>
    <input type="hidden" name="entite"           value="objet">
    <input type="hidden" name="action"           value="sauvegarder">
    <input type="hidden" name="om_id"            value="<?= (int)$om['om_id'] ?>">
    <input type="hidden" name="om_ruleset_var_id" value="<?= $ruleset_id ?>">
    <!-- Contexte pour l'autocomplétion JS -->
    <input type="hidden" id="om_active_res_ids"  value="<?= h(implode(',', $res_ids)) ?>">

    <!-- ===== Section principale ===== -->
    <div class="modif-section">
      <div class="modif-grid">

        <!-- Nom -->
        <div class="form-group modif-grid__full">
          <label for="om_nom">Nom <span class="required">*</span></label>
          <input type="text" id="om_nom" name="om_nom"
                 value="<?= h($om['om_nom']) ?>" required maxlength="150">
        </div>

        <!-- Catégorie -->
        <div class="form-group">
          <label for="om_com_id">Catégorie <span class="required">*</span></label>
          <select id="om_com_id" name="om_com_id" required
                  onchange="omToggleSections('categorie')">
            <option value="">— Choisir —</option>
            <?php foreach ($categories as $cat): ?>
              <option value="<?= (int)$cat['com_id'] ?>"
                      data-calcule="<?= (int)$cat['com_est_calcule'] ?>"
                <?= (int)$om['om_com_id'] === (int)$cat['com_id'] ? 'selected' : '' ?>>
                <?= h($cat['com_nom']) ?>
              </option>
            <?php endforeach ?>
          </select>
        </div>

        <!-- Source -->
        <div class="form-group">
          <label for="om_res_id">Source <span class="required">*</span></label>
          <select id="om_res_id" name="om_res_id" required>
            <option value="">— Choisir —</option>
            <?php foreach ($sources as $src): ?>
              <option value="<?= (int)$src['res_id'] ?>"
                <?= (int)$om['om_res_id'] === (int)$src['res_id'] ? 'selected' : '' ?>>
                <?= h($src['res_nom']) ?>
              </option>
            <?php endforeach ?>
          </select>
        </div>

        <!-- Variantes -->
        <div class="form-group modif-grid__full">
          <label for="om_variantes">Variantes
            <span class="form-hint">(mineur, majeur, versions…)</span>
          </label>
          <input type="text" id="om_variantes" name="om_variantes"
                 value="<?= h($om['om_variantes'] ?? '') ?>" maxlength="255">
        </div>

        <!-- Visible (édition uniquement) -->
        <div class="form-group">
          <label class="form-label--checkbox">
            <input type="checkbox" name="om_visible" value="1"
              <?= $om['om_visible'] ? 'checked' : '' ?>>
            Visible par les joueurs
          </label>
        </div>

      </div><!-- .modif-grid -->
    </div><!-- .modif-section -->

    <?php if ($ruleset_rep === 'DD3.5'): ?>
    <!-- ===== Section DD3.5 uniquement : format + sort + modificateur ===== -->
    <div class="modif-section" id="section-dd35-auto">

      <div class="modif-section__header">
        <span class="modif-section__label">Paramètres DD3.5</span>
      </div>

      <div class="modif-grid">

        <!-- Format / Affichage -->
        <div class="form-group">
          <label for="om_fom_id">Affichage
            <span class="form-hint">(mis à jour selon la catégorie)</span>
          </label>
          <select id="om_fom_id" name="om_fom_id"
                  onchange="omToggleSections()">
            <?php foreach ($formats as $fom): ?>
              <option value="<?= (int)$fom['fom_id'] ?>"
                <?= (int)$om['om_fom_id'] === (int)$fom['fom_id'] ? 'selected' : '' ?>>
                <?= h($fom['fom_nom']) ?>
              </option>
            <?php endforeach ?>
          </select>
        </div>

        <!-- Modificateur -->
        <div class="form-group" id="grp-modificateurs">
          <label for="om_modificateurs">Bonus magique (+1 à +5)</label>
          <select id="om_modificateurs" name="om_modificateurs">
            <?php for ($i = 0; $i <= 5; $i++): ?>
              <option value="<?= $i ?>"
                <?= (int)$om['om_modificateurs'] === $i ? 'selected' : '' ?>>
                <?= $i === 0 ? '—' : '+' . $i ?>
              </option>
            <?php endfor ?>
          </select>
        </div>

        <!-- Sort lié (autocomplétion) -->
        <div class="form-group modif-grid__full" id="grp-sort-lie">
          <label for="om_so_search">Sort reproduit</label>
          <div class="autocomplete-wrap">
            <div class="autocomplete-input-row">
              <input type="text"
                     id="om_so_search"
                     class="autocomplete-input comp-filtre-input"
                     autocomplete="off"
                     placeholder="Taper au moins 2 caractères…"
                     value="<?= h($so_label_initial) ?>">
              <?php if (!empty($om['om_so_id'])): ?>
                <button type="button" class="autocomplete-clear"
                        id="om_so_clear" title="Effacer le sort lié">
                  <i class="fa fa-times"></i>
                </button>
              <?php else: ?>
                <button type="button" class="autocomplete-clear noDisplay"
                        id="om_so_clear" title="Effacer le sort lié">
                  <i class="fa fa-times"></i>
                </button>
              <?php endif ?>
            </div>
            <input type="hidden" id="om_so_id" name="om_so_id"
                   value="<?= (int)($om['om_so_id'] ?? 0) ?>">
            <ul class="autocomplete-list" id="om_so_list" hidden></ul>
          </div>
        </div>

        <!-- NLS override -->
        <div class="form-group" id="grp-nls">
          <label for="om_so_niveau">NLS spécifique
            <span class="form-hint">(0 = calculé auto)</span>
          </label>
          <input type="number" id="om_so_niveau" name="om_so_niveau"
                 value="<?= (int)$om['om_so_niveau'] ?>" min="0" max="20">
        </div>

      </div><!-- .modif-grid -->
    </div><!-- #section-dd35-auto -->
    <?php endif ?>

    <!-- ===== Description TinyMCE ===== -->
    <div class="modif-section" id="section-description">
      <div class="form-group">
        <label for="om_description">Description</label>
        <textarea id="om_description" name="om_description"
                  class="tinymce-basic"><?= $om['om_description'] ?? '' ?></textarea>
      </div>
    </div>

    <!-- Boutons -->
    <div class="modif-actions">
      <button type="button" class="btn btn-primary" onclick="soumettreObjet()">
        <i class="fa fa-save"></i> Enregistrer
      </button>
      <button type="button" class="btn btn-secondary" onclick="fermerModification()">
        <i class="fa fa-times"></i> Annuler
      </button>
    </div>

  </form>
</div>

<!-- TinyMCE via jsDelivr -->
<script src="https://cdn.jsdelivr.net/npm/tinymce@6/tinymce.min.js"></script>
<script>
(function initTMCE() {
  if (typeof tinymce === 'undefined') { setTimeout(initTMCE, 100); return; }
  var isLight = document.body.classList.contains('theme-light');
  tinymce.remove('#om_description');
  tinymce.init({
    selector:      '#om_description',
    language:      'fr_FR',
    menubar:       false,
    plugins:       'lists link table code',
    toolbar:       'styles | bold italic underline | bullist numlist | link unlink table | removeformat | code',
    height:        300,
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

// Données contextuelles pour omToggleSections() et initSortAutocomplete()
// var (pas const) : réexécuté à chaque ouverture — const provoquerait SyntaxError
var OM_CAT_CALCULE = <?= json_encode($cat_calcule_map) ?>;
var OM_RULESET_ID  = <?= $ruleset_id ?>;
var BASE_URL = <?= json_encode(BASE_URL) ?>;

// Initialisation des comportements au chargement du formulaire
omToggleSections();
initSortAutocomplete();
</script>
