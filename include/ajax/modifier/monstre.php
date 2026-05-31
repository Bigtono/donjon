<?php
// include/ajax/modifier/monstre.php
// Formulaire de création / modification d'un monstre
// Paramètres GET : id (int, 0 = création)
//
// mo_stats : saisi en TEXTE BRUT dans un <textarea> (pas de TinyMCE).
// La mise en forme et les liens cliquables sont calculés à l'affichage.

require_once __DIR__ . '/../../db.php';
require_once __DIR__ . '/../../auth.php';
require_once __DIR__ . '/../../helpers.php';

requireAuth();
if (!canEditCompendium()):
  http_response_code(403);
  echo '<p class="erreur">Accès refusé.</p>';
  exit;
endif;

$id          = intParam($_GET['id'] ?? 0);
$ruleset_id  = (int)($_SESSION['ruleset_var_id'] ?? 1);
$ruleset_rep = $_SESSION['rulesetRep'] ?? 'DD3.5';
$est_dd2024  = $ruleset_id !== 1;
$uid         = (int)($_SESSION['j_id'] ?? 0);
$res_ids     = getActiveResIds($db);

// Valeurs par défaut (création)
$mo = [
  'mo_id'       => 0,
  'mo_nom'      => '',
  'mo_mocat_id' => '',
  'mo_mogr_id'  => '',
  'mo_stats'    => '',
  'mo_fp_id'    => '',
  'mo_j_id'     => null,
  'mo_res_id'   => '',
  'mo_camp_id'  => null,
];

if ($id > 0):
  $stmt = $db->prepare('SELECT * FROM dd_monstres WHERE mo_id = ?');
  $stmt->execute([$id]);
  $row = $stmt->fetch();
  if ($row) $mo = $row;
endif;

// Catégories (filtrées par ruleset)
$stmt = $db->prepare('
  SELECT mocat_id, mocat_nom
  FROM   dd_monstres_categories
  WHERE  mocat_ruleset_var_id = ?
  ORDER  BY mocat_nom
');
$stmt->execute([$ruleset_id]);
$categories = $stmt->fetchAll();

// Groupes (DD2024 uniquement)
$groupes = [];
if ($est_dd2024):
  $stmt = $db->prepare('
    SELECT mogr_id, mogr_nom
    FROM   dd_monstres_groupes
    WHERE  mogr_ruleset_var_id = ?
    ORDER  BY mogr_nom
  ');
  $stmt->execute([$ruleset_id]);
  $groupes = $stmt->fetchAll();
endif;

// Facteurs de puissance — référentiel dd_fp, ordonné par valeur.
// On stocke le libellé (fp_nom) dans mo_fp_id (varchar).
$fps = $db->query('SELECT fp_nom, fp_valeur FROM dd_fp ORDER BY fp_valeur')->fetchAll();

// Ressources actives
$sources = [];
if (!empty($res_ids)):
  $ph   = resIdsPlaceholders($res_ids);
  $stmt = $db->prepare("SELECT res_id, res_nom FROM dd_ressources WHERE res_id IN ($ph) ORDER BY res_nom");
  $stmt->execute($res_ids);
  $sources = $stmt->fetchAll();
endif;

$titre = $id > 0 ? 'Modifier ' . h($mo['mo_nom']) : 'Nouveau monstre';
?>

<div class="modif-form">
  <h3 class="modif-form__title"><?= $titre ?></h3>

  <form id="form-monstre" method="POST"
        action="<?= BASE_URL ?>/compendium/enregistrement.php?ajax=1">
    <?= csrfField() ?>
    <input type="hidden" name="entite"            value="monstre">
    <input type="hidden" name="action"            value="sauvegarder">
    <input type="hidden" name="mo_id"             value="<?= (int)$mo['mo_id'] ?>">
    <input type="hidden" name="mo_ruleset_var_id" value="<?= $ruleset_id ?>">

    <!-- ===== Section principale ===== -->
    <div class="modif-section">
      <div class="modif-grid">

        <!-- Nom -->
        <div class="form-group modif-grid__full">
          <label for="mo_nom">Nom <span class="required">*</span></label>
          <input type="text" id="mo_nom" name="mo_nom"
                 value="<?= h($mo['mo_nom']) ?>" required maxlength="150">
        </div>

        <!-- Catégorie -->
        <div class="form-group">
          <label for="mo_mocat_id">Catégorie <span class="required">*</span></label>
          <select id="mo_mocat_id" name="mo_mocat_id" required>
            <option value="">— Choisir —</option>
            <?php foreach ($categories as $cat): ?>
              <option value="<?= (int)$cat['mocat_id'] ?>"
                <?= (int)$mo['mo_mocat_id'] === (int)$cat['mocat_id'] ? 'selected' : '' ?>>
                <?= h($cat['mocat_nom']) ?>
              </option>
            <?php endforeach ?>
          </select>
        </div>

        <?php if ($est_dd2024): ?>
        <!-- Groupe (DD2024) -->
        <div class="form-group">
          <label for="mo_mogr_id">Groupe <span class="required">*</span></label>
          <select id="mo_mogr_id" name="mo_mogr_id" required>
            <option value="">— Choisir —</option>
            <?php foreach ($groupes as $gr): ?>
              <option value="<?= (int)$gr['mogr_id'] ?>"
                <?= (int)$mo['mo_mogr_id'] === (int)$gr['mogr_id'] ? 'selected' : '' ?>>
                <?= h($gr['mogr_nom']) ?>
              </option>
            <?php endforeach ?>
          </select>
        </div>
        <?php else: ?>
          <!-- DD3.5 : pas de groupe. On transmet la valeur existante pour ne pas l'écraser. -->
          <input type="hidden" name="mo_mogr_id" value="<?= (int)($mo['mo_mogr_id'] ?: 0) ?>">
        <?php endif ?>

        <!-- Facteur de puissance -->
        <div class="form-group">
          <label for="mo_fp_id">Facteur de puissance</label>
          <select id="mo_fp_id" name="mo_fp_id">
            <option value="">—</option>
            <?php foreach ($fps as $fp): ?>
              <option value="<?= h($fp['fp_nom']) ?>"
                <?= (string)$mo['mo_fp_id'] === (string)$fp['fp_nom'] ? 'selected' : '' ?>>
                <?= h($fp['fp_nom']) ?>
              </option>
            <?php endforeach ?>
          </select>
        </div>

        <!-- Source -->
        <div class="form-group">
          <label for="mo_res_id">Source <span class="required">*</span></label>
          <select id="mo_res_id" name="mo_res_id" required>
            <option value="">— Choisir —</option>
            <?php foreach ($sources as $src): ?>
              <option value="<?= (int)$src['res_id'] ?>"
                <?= (int)$mo['mo_res_id'] === (int)$src['res_id'] ? 'selected' : '' ?>>
                <?= h($src['res_nom']) ?>
              </option>
            <?php endforeach ?>
          </select>
        </div>

        <!-- Visibilité : privé = visible du seul créateur -->
        <div class="form-group">
          <label class="form-label--checkbox">
            <input type="checkbox" id="mo_prive" name="mo_prive" value="1"
              <?= $mo['mo_j_id'] !== null ? 'checked' : '' ?>>
            Monstre privé (visible de moi seul)
          </label>
        </div>

      </div><!-- .modif-grid -->
    </div><!-- .modif-section -->

    <!-- ===== Bloc de statistiques (texte brut) ===== -->
    <div class="modif-section">
      <div class="modif-section__header">
        <span class="modif-section__label">Statistiques</span>
      </div>
      <div class="form-group">
        <label for="mo_stats">Description complète
          <span class="form-hint">
            (texte brut — les sorts et termes du glossaire sont liés automatiquement.
            Utilisez #Nom# pour un don, $Nom$ pour un sort, @id@ pour une règle, %id% pour le glossaire.)
          </span>
        </label>
        <textarea id="mo_stats" name="mo_stats"
                  class="mo-stats-input" rows="18"
                  placeholder="CA 13  Initiative +3 (13)&#10;Pv 67 (9d8 + 27)&#10;Vitesse 1,50 m&#10;&#10;Traits&#10;Nom du pouvoir. Description...&#10;&#10;Tags : #Nom don# $Nom sort$ @id règle@ %id glossaire%&#10;Séparateur : ligne ***"><?= h($mo['mo_stats'] ?? '') ?></textarea>
      </div>
    </div>

    <!-- Boutons -->
    <div class="modif-actions">
      <button type="button" class="btn btn-primary" onclick="soumettreMonstre()">
        <i class="fa fa-save"></i> Enregistrer
      </button>
      <button type="button" class="btn btn-secondary" onclick="fermerModification()">
        <i class="fa fa-times"></i> Annuler
      </button>
    </div>

  </form>

<div id="mo-tag-popup" class="mo-tag-popup" hidden>
  <div class="mo-tag-popup__header">
    <span class="mo-tag-popup__titre" id="mo-tag-popup-titre">Règle</span>
    <button type="button" class="mo-tag-popup__close" id="mo-tag-popup-close">&times;</button>
  </div>
  <input type="text" id="mo-tag-popup-input" class="mo-tag-popup__input"
         placeholder="Rechercher…" autocomplete="off">
  <ul id="mo-tag-popup-list" class="mo-tag-popup__list"></ul>
</div>

<script>
(function () {
  var textarea    = document.getElementById('mo_stats');
  var popup       = document.getElementById('mo-tag-popup');
  var popupTitre  = document.getElementById('mo-tag-popup-titre');
  var popupInput  = document.getElementById('mo-tag-popup-input');
  var popupList   = document.getElementById('mo-tag-popup-list');
  var popupClose  = document.getElementById('mo-tag-popup-close');

  if (!textarea || !popup) return;

  var BASE_URL    = <?= json_encode(BASE_URL) ?>;
  var RULESET_ID  = <?= (int)$ruleset_id ?>;
  var tagType     = null;   // 'regle' ou 'glossaire'
  var tagStart    = -1;     // position du @ ou % ouvrant dans le textarea
  var debounce    = null;

  // ---- Détection de la frappe ----
  textarea.addEventListener('keyup', function (e) {
    var pos = textarea.selectionStart;
    var val = textarea.value;

    // Remonter depuis le curseur pour trouver un @ ou % non fermé
    var found = null;
    for (var i = pos - 1; i >= Math.max(0, pos - 60); i--) {
      var c = val[i];
      if (c === '@') { found = { type: 'regle',    pos: i }; break; }
      if (c === '%') { found = { type: 'glossaire', pos: i }; break; }
      // Si on trouve le caractère fermant avant d'ouvrir -> on est hors tag
      if (c === '
') break;
    }

    if (!found) { fermerPopup(); return; }

    // Extraire le terme partiel entre le @ et le curseur
    var terme = val.substring(found.pos + 1, pos);
    // Si le terme contient déjà le fermant -> tag complet, fermer
    if (terme.indexOf(found.type === 'regle' ? '@' : '%') !== -1) {
      fermerPopup(); return;
    }

    tagType  = found.type;
    tagStart = found.pos;

    if (terme.length < 2) { fermerPopup(); return; }

    clearTimeout(debounce);
    debounce = setTimeout(function () { fetchSuggestions(terme); }, 220);
  });

  // Fermeture sur Échap
  textarea.addEventListener('keydown', function (e) {
    if (e.key === 'Escape') fermerPopup();
  });
  popupClose.addEventListener('click', fermerPopup);

  // ---- Fetch ----
  function fetchSuggestions(q) {
    var url = BASE_URL + '/include/ajax/autocomplete-tags-monstre.php'
            + '?type=' + encodeURIComponent(tagType)
            + '&q='    + encodeURIComponent(q)
            + '&ruleset=' + RULESET_ID;
    fetch(url)
      .then(function (r) { return r.json(); })
      .then(function (data) { afficherPopup(data, q); })
      .catch(function () { fermerPopup(); });
  }

  // ---- Affichage ----
  function afficherPopup(items, q) {
    popupList.innerHTML = '';
    if (items.length === 0) {
      var li = document.createElement('li');
      li.className = 'mo-tag-popup__vide';
      li.textContent = 'Aucun résultat';
      popupList.appendChild(li);
    } else {
      items.forEach(function (item) {
        var li = document.createElement('li');
        li.className = 'mo-tag-popup__item';

        var nomEl = document.createElement('span');
        nomEl.className = 'mo-tag-popup__nom';
        nomEl.textContent = item.label;

        li.appendChild(nomEl);

        if (item.contexte) {
          var ctxEl = document.createElement('span');
          ctxEl.className = 'mo-tag-popup__ctx';
          ctxEl.textContent = item.contexte;
          li.appendChild(ctxEl);
        }

        li.addEventListener('mousedown', function (e) {
          e.preventDefault();
          insererTag(item.id);
        });
        popupList.appendChild(li);
      });
    }

    popupTitre.textContent = tagType === 'glossaire' ? 'Glossaire' : 'Règle';

    // Positionner le popup sous le textarea (simple : toujours en bas)
    var rect = textarea.getBoundingClientRect();
    popup.style.top  = (textarea.offsetTop + textarea.offsetHeight + 4) + 'px';
    popup.style.left = textarea.offsetLeft + 'px';
    popup.style.width = Math.min(360, textarea.offsetWidth) + 'px';
    popup.hidden = false;
  }

  function fermerPopup() {
    popup.hidden = true;
    popupList.innerHTML = '';
    tagType = null;
    tagStart = -1;
  }

  // ---- Insertion ----
  function insererTag(id) {
    if (tagStart < 0) return;
    var val    = textarea.value;
    var ferm   = tagType === 'regle' ? '@' : '%';
    var ouv    = ferm;
    var cur    = textarea.selectionStart;
    // Remplacer depuis tagStart jusqu'au curseur par @id@ ou %id%
    var avant  = val.substring(0, tagStart);
    var apres  = val.substring(cur);
    textarea.value = avant + ouv + id + ferm + apres;
    // Repositionner le curseur après le tag
    var newPos = tagStart + 1 + String(id).length + 1;
    textarea.setSelectionRange(newPos, newPos);
    textarea.focus();
    fermerPopup();
  }
}());
</script>

</div>
