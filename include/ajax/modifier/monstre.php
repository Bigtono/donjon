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
  'mo_res_id'   => '',
  'mo_camp_id'  => null,
  'mo_public'   => 0,
  'mo_visible'  => 1,
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

// Supplément de l'utilisateur courant : peut ne pas encore exister (aucune
// entrée de supplément créée pour ce ruleset). Dans ce cas, l'option du
// select porte la valeur sentinelle 'supplement' ; la ressource sera créée
// à la volée au save (getOrCreateUserSupplement(), cf. enregistrement.php).
$mon_supplement_res_id = getUserSupplementResId($db, $uid, $ruleset_id);
$mon_supplement_nom    = '';
if ($mon_supplement_res_id !== null):
  $stmt = $db->prepare('SELECT res_nom FROM dd_ressources WHERE res_id = ?');
  $stmt->execute([$mon_supplement_res_id]);
  $mon_supplement_nom = (string)$stmt->fetchColumn();
else:
  $stmt = $db->prepare('SELECT j_pseudo FROM dd_joueurs WHERE j_id = ?');
  $stmt->execute([$uid]);
  $pseudo = $stmt->fetchColumn();
  $mon_supplement_nom = 'Supplément de ' . ($pseudo !== false ? $pseudo : 'utilisateur');
endif;

// Valeur actuellement sélectionnée par le formulaire pour mo_res_id : si
// l'entrée éditée appartient déjà au supplément de l'utilisateur, on utilise
// la sentinelle pour pointer la bonne <option> même si le libellé diffère.
$mo_res_id_select = (string)$mo['mo_res_id'];
if ($mon_supplement_res_id !== null && (int)$mo['mo_res_id'] === $mon_supplement_res_id):
  $mo_res_id_select = 'supplement';
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
            <optgroup label="Sources officielles">
              <?php foreach ($sources_officielles as $src): ?>
                <option value="<?= (int)$src['res_id'] ?>" data-supplement="0"
                  <?= $mo_res_id_select === (string)$src['res_id'] ? 'selected' : '' ?>>
                  <?= h($src['res_nom']) ?>
                </option>
              <?php endforeach ?>
            </optgroup>
            <optgroup label="Mon supplément">
              <option value="supplement" data-supplement="1"
                <?= $mo_res_id_select === 'supplement' ? 'selected' : '' ?>>
                <?= h($mon_supplement_nom) ?>
              </option>
            </optgroup>
          </select>
        </div>

        <!-- Visibilité (supplément uniquement) -->
        <div class="form-group" id="mo-supplement-visibilite" hidden>
          <label class="form-label--checkbox">
            <input type="checkbox" id="mo_public" name="mo_public" value="1"
              <?= (int)$mo['mo_public'] === 1 ? 'checked' : '' ?>>
            Partagé (visible des autres utilisateurs ayant ce supplément comme source)
          </label>
          <label class="form-label--checkbox">
            <input type="checkbox" id="mo_visible" name="mo_visible" value="1"
              <?= (int)$mo['mo_visible'] === 1 ? 'checked' : '' ?>>
            Visible (décoché = brouillon masqué, accessible via « Afficher mes brouillons »)
          </label>
          <span class="form-hint">Une entrée partagée est forcément visible.</span>
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

<script>
(function () {
  // Affiche/masque le bloc public/visible selon le groupe de la source
  // sélectionnée (officielle vs supplément personnel), et applique la
  // contrainte client _public=1 => _visible coché + désactivé.
  var selectRes = document.getElementById('mo_res_id');
  var blocVisib = document.getElementById('mo-supplement-visibilite');
  var chkPublic = document.getElementById('mo_public');
  var chkVisible = document.getElementById('mo_visible');

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

<div id="mo-tag-popup" class="mo-tag-popup" hidden>
  <div class="mo-tag-popup__header">
    <span class="mo-tag-popup__titre" id="mo-tag-popup-titre">Regle</span>
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

  // ---- Detection de la frappe ----
  textarea.addEventListener('keyup', function (e) {
    var pos = textarea.selectionStart;
    var val = textarea.value;

    // Remonter depuis le curseur pour trouver un @ ou % non ferme
    var found = null;
    for (var i = pos - 1; i >= Math.max(0, pos - 60); i--) {
      var c = val[i];
      if (c === '@') { found = { type: 'regle',    pos: i }; break; }
      if (c === '%') { found = { type: 'glossaire', pos: i }; break; }
      // Si on trouve le caractere fermant avant d'ouvrir -> on est hors tag
      if (c === '
') break;
    }

    if (!found) { fermerPopup(); return; }

    // Extraire le terme partiel entre le @ et le curseur
    var terme = val.substring(found.pos + 1, pos);
    // Si le terme contient deja le fermant -> tag complet, fermer
    if (terme.indexOf(found.type === 'regle' ? '@' : '%') !== -1) {
      fermerPopup(); return;
    }

    tagType  = found.type;
    tagStart = found.pos;

    if (terme.length < 2) { fermerPopup(); return; }

    clearTimeout(debounce);
    debounce = setTimeout(function () { fetchSuggestions(terme); }, 220);
  });

  // Fermeture sur Echap
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
      li.textContent = 'Aucun resultat';
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

    popupTitre.textContent = tagType === 'glossaire' ? 'Glossaire' : 'Regle';

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
    // Repositionner le curseur apres le tag
    var newPos = tagStart + 1 + String(id).length + 1;
    textarea.setSelectionRange(newPos, newPos);
    textarea.focus();
    fermerPopup();
  }
}());
</script>

</div>
