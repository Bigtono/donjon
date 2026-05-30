<?php
// include/ajax/modifier/regle.php
// Formulaire overlay création / modification d'un nœud dd_regles.
// Appelé via actualiserPageModif() — pas de layout header/footer.
//
// Paramètres GET :
//   id         (int) — reg_id à modifier (0 = création)
//   parent_id  (int) — pré-sélectionne le parent (optionnel, utilisé via "Ajouter ici")
//
// Référence : doc/ARCHITECTURE_0_REFERENCE.md §9b

require_once __DIR__ . '/../../db.php';
require_once __DIR__ . '/../../auth.php';
require_once __DIR__ . '/../../helpers.php';
require_once __DIR__ . '/../../regles-arbre.php';

requireAuth();
if (!canEditCompendium()):
  http_response_code(403);
  echo '<p class="erreur">Accès refusé.</p>';
  exit;
endif;

$id         = intParam($_GET['id']        ?? 0);
$parent_pre = intParam($_GET['parent_id'] ?? 0);
$ruleset_id = (int)($_SESSION['ruleset_var_id'] ?? 1);

// ============================================================
// Chargement du nœud existant (modification) ou valeurs vides
// ============================================================
$reg = [
  'reg_id'           => 0,
  'reg_reg_id'       => $parent_pre ?: null,
  'reg_type'         => 'regle',
  'reg_nom'          => '',
  'reg_slug'         => '',
  'reg_texte'        => '',
  'reg_ordre'        => 0,
  'reg_visible'      => 1,
];

if ($id > 0):
  $stmt = $db->prepare('SELECT * FROM dd_regles WHERE reg_id = ? AND reg_ruleset_var_id = ?');
  $stmt->execute([$id, $ruleset_id]);
  $row = $stmt->fetch();
  if ($row) $reg = array_merge($reg, array_map(fn($v) => $v ?? '', $row));
endif;

// ============================================================
// Arbre pour le <select> parent (tous les nœuds du ruleset,
// excluant le nœud lui-même et ses descendants)
// ============================================================
$arbre = chargerArbreRegles($db, $ruleset_id, true);

// Construit la liste à plat avec indentation pour le <select>
function _optionsParent(array $ids, array $arbre, int $excludeId, int $depth = 0): string
{
  $html = '';
  foreach ($ids as $nid):
    if ($nid === $excludeId) continue;
    $label = str_repeat('— ', $depth) . $arbre['nodes'][$nid]['reg_nom'];
    $html .= '<option value="' . (int)$nid . '">'
           . htmlspecialchars($label, ENT_QUOTES, 'UTF-8')
           . '</option>';
    if (!empty($arbre['enfants'][$nid])):
      $html .= _optionsParent($arbre['enfants'][$nid], $arbre, $excludeId, $depth + 1);
    endif;
  endforeach;
  return $html;
}

$options_parent = _optionsParent($arbre['racines'], $arbre, $id);
$parent_courant = $reg['reg_reg_id'] ? (int)$reg['reg_reg_id'] : 0;

$est_creation = $id === 0;
$titre = $est_creation ? 'Nouveau nœud' : 'Modifier — ' . htmlspecialchars($reg['reg_nom'], ENT_QUOTES, 'UTF-8');

// ID unique pour TinyMCE (évite les conflits si plusieurs formulaires)
$tinymce_id = 'reg_texte_' . ($id ?: 'new');
?>

<div class="modifier-regle">

  <h2 class="overlay-titre"><?= $titre ?></h2>

  <div class="modifier-regle__form">

    <input type="hidden" id="reg_id"    name="reg_id"    value="<?= (int)$reg['reg_id'] ?>">
    <?= csrfField() ?>

    <?php // ---- Nom ---- ?>
    <div class="form-group">
      <label for="reg_nom">Nom <span class="form-required">*</span></label>
      <input type="text" id="reg_nom" name="reg_nom" class="form-control"
             value="<?= htmlspecialchars($reg['reg_nom'], ENT_QUOTES, 'UTF-8') ?>"
             required maxlength="200" autocomplete="off">
    </div>

    <?php // ---- Type ---- ?>
    <div class="form-group">
      <label for="reg_type">Type</label>
      <select id="reg_type" name="reg_type" class="form-control">
        <?php foreach (['chapitre' => 'Chapitre', 'regle' => 'Règle', 'glossaire' => 'Glossaire'] as $val => $lab): ?>
          <option value="<?= $val ?>"<?= $reg['reg_type'] === $val ? ' selected' : '' ?>>
            <?= $lab ?>
          </option>
        <?php endforeach ?>
      </select>
    </div>

    <?php // ---- Parent ---- ?>
    <div class="form-group">
      <label for="reg_reg_id">Parent</label>
      <select id="reg_reg_id" name="reg_reg_id" class="form-control">
        <option value="0"<?= $parent_courant === 0 ? ' selected' : '' ?>>— Aucun (racine) —</option>
        <?php
        // Reconstruction avec la bonne sélection
        $html_opts = _optionsParent($arbre['racines'], $arbre, $id);
        // On injecte selected sur la valeur courante
        if ($parent_courant > 0):
          $html_opts = str_replace(
            'value="' . $parent_courant . '">',
            'value="' . $parent_courant . '" selected>',
            $html_opts
          );
        endif;
        echo $html_opts;
        ?>
      </select>
    </div>

    <?php // ---- Slug ---- ?>
    <div class="form-group">
      <label for="reg_slug">
        Slug
        <small class="form-hint">(lien permanent — laissez vide pour générer automatiquement)</small>
      </label>
      <input type="text" id="reg_slug" name="reg_slug" class="form-control"
             value="<?= htmlspecialchars($reg['reg_slug'], ENT_QUOTES, 'UTF-8') ?>"
             maxlength="220" autocomplete="off"
             pattern="[a-z0-9\-]+" title="Minuscules, chiffres et tirets uniquement">
    </div>

    <?php // ---- Ordre ---- ?>
    <div class="form-group form-group--inline">
      <label for="reg_ordre">Ordre parmi les frères</label>
      <input type="number" id="reg_ordre" name="reg_ordre" class="form-control form-control--sm"
             value="<?= (int)$reg['reg_ordre'] ?>" min="0" max="9999">
    </div>

    <?php // ---- Visible ---- ?>
    <div class="form-group form-group--inline">
      <label class="form-check-label">
        <input type="checkbox" name="reg_visible" value="1"
               <?= $reg['reg_visible'] ? 'checked' : '' ?>>
        Visible (décocher = brouillon)
      </label>
    </div>

    <?php // ---- Texte (TinyMCE) ---- ?>
    <div class="form-group">
      <label for="<?= $tinymce_id ?>">Contenu</label>
      <textarea id="<?= $tinymce_id ?>" name="reg_texte"
                class="form-control tinymce-regle"
                rows="14"><?= htmlspecialchars($reg['reg_texte'], ENT_QUOTES, 'UTF-8') ?></textarea>
    </div>

    <?php // ---- Actions ---- ?>
    <div class="form-actions">
      <button type="button" class="btn btn--primary" onclick="reglesEnregistrer()">
        <i class="fa fa-save"></i> Enregistrer
      </button>
      <button type="button" class="btn btn--secondary" onclick="fermerModification()">
        Annuler
      </button>
    </div>

  </div><?php // .modifier-regle__form ?>
</div><?php // .modifier-regle ?>

<script>
(function () {
  var TINYMCE_ID   = <?= json_encode($tinymce_id) ?>;
  var URL_ENREG    = <?= json_encode(BASE_URL . '/regles/enregistrement.php?ajax=1') ?>;
  var CSRF_TOKEN   = <?= json_encode(csrfToken()) ?>;

  // ---- Initialisation TinyMCE ----
  if (typeof tinymce !== 'undefined') {
    tinymce.init({
      selector: '#' + TINYMCE_ID,
      language: 'fr_FR',
      height: 380,
      menubar: false,
      plugins: 'lists link table code',
      toolbar:
        'bold italic underline | bullist numlist | link table | '
        + 'removeformat | code',
      content_style:
        'body { font-family: inherit; font-size: 14px; } '
        + '.glossaire-lien { color: #9d7fd3; text-decoration: underline dotted; cursor: pointer; }',
      // Pas de conversion automatique des URLs (on gère les .glossaire-lien manuellement)
      convert_urls: false,
    });
  }

  // ---- Enregistrement AJAX ----
  window.reglesEnregistrer = function () {
    var nom  = document.getElementById('reg_nom').value.trim();
    if (!nom) { alert('Le nom est obligatoire.'); return; }

    // Récupère le contenu TinyMCE ou le textarea brut
    var texte = '';
    if (typeof tinymce !== 'undefined') {
      var ed = tinymce.get(TINYMCE_ID);
      texte = (ed && ed.initialized) ? ed.getContent() : document.getElementById(TINYMCE_ID).value;
    } else {
      texte = document.getElementById(TINYMCE_ID).value;
    }

    var data = new URLSearchParams({
      action:      'sauvegarder',
      csrf_token:  CSRF_TOKEN,
      reg_id:      document.getElementById('reg_id').value,
      reg_nom:     nom,
      reg_type:    document.getElementById('reg_type').value,
      reg_reg_id:  document.getElementById('reg_reg_id').value,
      reg_slug:    document.getElementById('reg_slug').value,
      reg_ordre:   document.getElementById('reg_ordre').value,
      reg_visible: document.querySelector('[name="reg_visible"]').checked ? '1' : '0',
      reg_texte:   texte,
    });

    fetch(URL_ENREG, {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: data.toString(),
    })
    .then(function (r) { return r.json(); })
    .then(function (res) {
      if (res.ok) {
        fermerModification();
        // Recharge la page pour refléter les changements
        window.location.href = (typeof BASE_URL !== 'undefined' ? BASE_URL : '')
          + '/regles/regle.php?id=' + res.id;
      } else {
        alert(res.erreur || 'Erreur lors de l\'enregistrement.');
      }
    })
    .catch(function (e) { alert('Erreur réseau : ' + e); });
  };
}());
</script>
