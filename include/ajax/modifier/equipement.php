<?php
// include/ajax/modifier/equipement.php
// Formulaire de création/modification d'un équipement
// Paramètres GET : id (int, 0 = création)

require_once __DIR__ . '/../../db.php';
require_once __DIR__ . '/../../auth.php';
require_once __DIR__ . '/../../helpers.php';
require_once __DIR__ . '/../../liste-parser.php';

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
$equipement = [
  'eqt_id'          => 0,
  'eqt_nom'         => '',
  'eqt_cae_id'      => '',
  'eqt_prix_pc'     => null,
  'eqt_prix_txt'    => null,
  'eqt_poids_g'     => null,
  'eqt_poids_txt'   => null,
  'eqt_attributs'   => null,
  'eqt_ordre'       => 0,
  'eqt_description' => '',
  'eqt_visible'     => 1,
  'eqt_public'      => 0,
  'eqt_res_id'      => '',
  'eqt_camp_id'     => '',
];

if ($id > 0):
  $stmt = $db->prepare('SELECT * FROM dd_equipements WHERE eqt_id = ?');
  $stmt->execute([$id]);
  $row = $stmt->fetch();
  if ($row) $equipement = $row;
endif;

// Familles : libellé hiérarchique + colonnes (héritées) pour fabriquer les champs d'attributs
$arbre     = catEquipementArbre($db, $ruleset_id);
$familles  = [];
$cols_par_famille = [];
foreach ($arbre['rang'] as $cae_id => $rang):
  $noms = [];
  foreach (catEquipementChaine($arbre, $cae_id) as $anc) $noms[] = $arbre['noeuds'][$anc]['cae_nom'];
  $familles[$rang] = ['id' => $cae_id, 'label' => implode(' › ', $noms)];
  // Seuls les champs d'attribut : prix et poids ont leurs propres champs
  $cols_par_famille[$cae_id] = array_values(array_filter(
    catEquipementColonnes($arbre, $cae_id),
    fn($c) => !in_array($c['k'], ['prix', 'poids'], true)
  ));
endforeach;
ksort($familles);

$attributs = equipementAttributs($equipement);

// Prix / poids tels que saisis : le texte d'affichage prime sur la valeur chiffrée
$prix_saisi = $equipement['eqt_prix_txt']
  ?: ($equipement['eqt_prix_pc'] !== null ? formaterPrixPc((int)$equipement['eqt_prix_pc']) : '');
$poids_saisi = $equipement['eqt_poids_txt']
  ?: ($equipement['eqt_poids_g'] !== null ? formaterPoidsG((int)$equipement['eqt_poids_g']) : '');
$prix_saisi  = str_replace("\u{00A0}", ' ', $prix_saisi);
$poids_saisi = str_replace("\u{00A0}", ' ', $poids_saisi);

// Sources — officielles vs supplément personnel (même mécanisme que objet.php)
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

$supp_res_id = getUserSupplementResId($db, $uid, $ruleset_id);
$supp_nom    = '';
if ($supp_res_id !== null):
  $stmt = $db->prepare('SELECT res_nom FROM dd_ressources WHERE res_id = ?');
  $stmt->execute([$supp_res_id]);
  $supp_nom = (string)$stmt->fetchColumn();
else:
  $stmt = $db->prepare('SELECT j_pseudo FROM dd_joueurs WHERE j_id = ?');
  $stmt->execute([$uid]);
  $pseudo   = $stmt->fetchColumn();
  $supp_nom = 'Supplément de ' . ($pseudo !== false ? $pseudo : 'utilisateur');
endif;

$res_select = (string)$equipement['eqt_res_id'];
if ($supp_res_id !== null && (int)$equipement['eqt_res_id'] === $supp_res_id):
  $res_select = 'supplement';
endif;

// Campagnes de l'utilisateur
$campagnes = [];
if (!empty($_SESSION['j_mode_campagne'])):
  [$owWhere, $owParams] = ownerFilter('camp');
  $stmt = $db->prepare("SELECT camp_id, camp_nom FROM dd_campagnes WHERE $owWhere ORDER BY camp_nom");
  $stmt->execute($owParams);
  $campagnes = $stmt->fetchAll();
endif;

$titre = $id > 0 ? 'Modifier ' . h($equipement['eqt_nom']) : 'Nouvel équipement';
?>

<div class="modif-form">
  <h3 class="modif-form__title"><?= $titre ?></h3>

  <form id="form-equipement" method="POST"
        action="<?= BASE_URL ?>/compendium/enregistrement.php?ajax=1">
    <?= csrfField() ?>
    <input type="hidden" name="entite"            value="equipement">
    <input type="hidden" name="action"            value="sauvegarder">
    <input type="hidden" name="eqt_id"            value="<?= (int)$equipement['eqt_id'] ?>">

    <div class="modif-section">
      <div class="modif-grid">

        <!-- Nom -->
        <div class="form-group modif-grid__full">
          <label for="eqt_nom">Nom <span class="required">*</span></label>
          <input type="text" id="eqt_nom" name="eqt_nom"
                 value="<?= h($equipement['eqt_nom']) ?>" required maxlength="150">
        </div>

        <!-- Famille -->
        <div class="form-group modif-grid__full">
          <label for="eqt_cae_id">Famille<?php if (!empty($familles)): ?> <span class="required">*</span><?php endif ?></label>
          <?php // Aucune famille saisie pour ce ruleset (DD2024 avant SP-E6) : le champ reste facultatif ?>
          <select id="eqt_cae_id" name="eqt_cae_id" <?= !empty($familles) ? 'required' : '' ?>>
            <option value=""><?= !empty($familles) ? '— Choisir —' : '— Aucune famille définie pour ce ruleset —' ?></option>
            <?php foreach ($familles as $fam): ?>
              <option value="<?= (int)$fam['id'] ?>"
                <?= (int)$equipement['eqt_cae_id'] === (int)$fam['id'] ? 'selected' : '' ?>>
                <?= h($fam['label']) ?>
              </option>
            <?php endforeach ?>
          </select>
        </div>

        <!-- Prix -->
        <div class="form-group">
          <label for="eqt_prix">Prix
            <span class="form-hint">(5 po, 12 pa, 3 pc — ou un texte : « spécial »)</span>
          </label>
          <input type="text" id="eqt_prix" name="eqt_prix"
                 value="<?= h($prix_saisi) ?>" maxlength="60">
        </div>

        <!-- Poids -->
        <div class="form-group">
          <label for="eqt_poids">Poids
            <span class="form-hint">(500 g, 2,5 kg — ou un texte)</span>
          </label>
          <input type="text" id="eqt_poids" name="eqt_poids"
                 value="<?= h($poids_saisi) ?>" maxlength="60">
        </div>

        <!-- Attributs propres à la famille (générés par JS d'après les colonnes) -->
        <div class="modif-grid__full" id="eqt-attributs"></div>

        <!-- Ordre -->
        <div class="form-group">
          <label for="eqt_ordre">Ordre d'affichage
            <span class="form-hint">(dans sa famille ; 0 = alphabétique)</span>
          </label>
          <input type="number" id="eqt_ordre" name="eqt_ordre" min="0" max="65000"
                 value="<?= (int)$equipement['eqt_ordre'] ?>">
        </div>

        <!-- Source -->
        <div class="form-group">
          <label for="eqt_res_id">Source <span class="required">*</span></label>
          <select id="eqt_res_id" name="eqt_res_id" required>
            <option value="">— Choisir —</option>
            <optgroup label="Sources officielles">
              <?php foreach ($sources_officielles as $src): ?>
                <option value="<?= (int)$src['res_id'] ?>" data-supplement="0"
                  <?= $res_select === (string)$src['res_id'] ? 'selected' : '' ?>>
                  <?= h($src['res_nom']) ?>
                </option>
              <?php endforeach ?>
            </optgroup>
            <optgroup label="Mon supplément">
              <option value="supplement" data-supplement="1"
                <?= $res_select === 'supplement' ? 'selected' : '' ?>>
                <?= h($supp_nom) ?>
              </option>
            </optgroup>
          </select>
        </div>

        <!-- Campagne homebrew -->
        <?php if (!empty($campagnes)): ?>
          <div class="form-group">
            <label for="eqt_camp_id">Campagne (homebrew)</label>
            <select id="eqt_camp_id" name="eqt_camp_id">
              <option value="">— Compendium global —</option>
              <?php foreach ($campagnes as $camp): ?>
                <option value="<?= (int)$camp['camp_id'] ?>"
                  <?= (int)$equipement['eqt_camp_id'] === (int)$camp['camp_id'] ? 'selected' : '' ?>>
                  <?= h($camp['camp_nom']) ?>
                </option>
              <?php endforeach ?>
            </select>
          </div>
        <?php endif ?>

        <!-- Visibilité -->
        <div class="form-group">
          <label class="form-label--checkbox">
            <input type="checkbox" id="eqt_visible" name="eqt_visible" value="1"
              <?= (int)$equipement['eqt_visible'] === 1 ? 'checked' : '' ?>>
            Visible par les joueurs
          </label>
        </div>

        <!-- Partagé (supplément uniquement) -->
        <div class="form-group" id="eqt-supplement-visibilite" hidden>
          <label class="form-label--checkbox">
            <input type="checkbox" id="eqt_public" name="eqt_public" value="1"
              <?= (int)$equipement['eqt_public'] === 1 ? 'checked' : '' ?>>
            Partagé (visible des autres utilisateurs ayant ce supplément comme source)
          </label>
          <span class="form-hint">Une entrée partagée est forcément visible.</span>
        </div>

      </div><!-- .modif-grid -->
    </div><!-- .modif-section -->

    <!-- Description TinyMCE -->
    <div class="modif-section">
      <div class="form-group">
        <label for="eqt_description">Description<?= aideIcone('texte-parsers') ?></label>
        <textarea id="eqt_description" name="eqt_description"
                  class="tinymce-basic"><?= $equipement['eqt_description'] ?? '' ?></textarea>
      </div>
    </div>

    <!-- Boutons -->
    <div class="modif-actions">
      <button type="button" class="btn btn-primary" onclick="soumettreEquipement()">
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
  tinymce.remove('#eqt_description');
  tinymce.init({
    selector:      '#eqt_description',
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

<script>
(function () {
  // var (pas const) : le formulaire est réinjecté à chaque ouverture
  var colsParFamille = <?= json_encode($cols_par_famille, JSON_UNESCAPED_UNICODE) ?>;
  var valeurs        = <?= json_encode($attributs, JSON_UNESCAPED_UNICODE | JSON_FORCE_OBJECT) ?>;
  var selectFam      = document.getElementById('eqt_cae_id');
  var zone           = document.getElementById('eqt-attributs');

  // Mémorise ce qui est saisi avant de reconstruire (changement de famille)
  function relever() {
    zone.querySelectorAll('input[data-attr]').forEach(function (inp) {
      valeurs[inp.getAttribute('data-attr')] = inp.value;
    });
  }

  function construire() {
    relever();
    zone.innerHTML = '';
    var cols = colsParFamille[selectFam.value] || [];
    if (!cols.length) return;
    var grille = document.createElement('div');
    grille.className = 'modif-grid';
    cols.forEach(function (c) {
      var groupe = document.createElement('div');
      groupe.className = 'form-group';
      var lab = document.createElement('label');
      lab.textContent = c.l;
      var inp = document.createElement('input');
      inp.type = 'text';
      inp.name = 'eqt_attr[' + c.k + ']';
      inp.setAttribute('data-attr', c.k);
      inp.maxLength = 120;
      inp.value = valeurs[c.k] || '';
      groupe.appendChild(lab);
      groupe.appendChild(inp);
      grille.appendChild(groupe);
    });
    zone.appendChild(grille);
  }

  selectFam.addEventListener('change', construire);
  construire();

  // Supplément : « Partagé » n'a de sens que sur la source de l'utilisateur ;
  // une entrée partagée est forcément visible
  var selectRes  = document.getElementById('eqt_res_id');
  var blocPublic = document.getElementById('eqt-supplement-visibilite');
  var chkPublic  = document.getElementById('eqt_public');
  var chkVisible = document.getElementById('eqt_visible');

  function appliquerContrainte() {
    if (chkPublic.checked) { chkVisible.checked = true; chkVisible.disabled = true; }
    else { chkVisible.disabled = false; }
  }
  function actualiserAffichage() {
    var option = selectRes.options[selectRes.selectedIndex];
    var estSupplement = option && option.getAttribute('data-supplement') === '1';
    blocPublic.hidden = !estSupplement;
    if (estSupplement) appliquerContrainte();
    else chkVisible.disabled = false;
  }
  selectRes.addEventListener('change', actualiserAffichage);
  chkPublic.addEventListener('change', appliquerContrainte);
  actualiserAffichage();
}());
</script>
