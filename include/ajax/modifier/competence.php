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

// Compétences à domaines (SP-CD — DD3.5). Un domaine est une compétence fille :
// on n'y saisit que la partie entre parenthèses, le reste vient de la mère.
// Mères possibles : les compétences sans mère du ruleset. Une compétence qui a
// déjà des domaines ne peut pas devenir elle-même un domaine.
$comp_parent_id = (int)($comp['comp_parent_id'] ?? 0);
$meres          = [];
$a_domaines     = false;
if ($ruleset_id === 1):
  if ($id > 0):
    $stmt = $db->prepare('SELECT COUNT(*) FROM dd_competences WHERE comp_parent_id = ?');
    $stmt->execute([$id]);
    $a_domaines = (int)$stmt->fetchColumn() > 0;
  endif;
  if (!$a_domaines):
    $stmt = $db->prepare('
      SELECT comp_id, comp_nom
        FROM dd_competences
       WHERE comp_ruleset_var_id = ? AND comp_parent_id IS NULL AND comp_id <> ?
       ORDER BY comp_nom
    ');
    $stmt->execute([$ruleset_id, $id]);
    $meres = $stmt->fetchAll();
  endif;
endif;

// Nom saisi : pour un domaine, la partie entre parenthèses seulement
$comp_nom_saisi = (string)$comp['comp_nom'];
if ($comp_parent_id > 0 && preg_match('/\((.*)\)\s*$/u', $comp_nom_saisi, $m)):
  $comp_nom_saisi = $m[1];
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

// Synergies accordées par cette compétence (SP-PE21 — DD3.5) : cible, seuil,
// bonus, condition facultative. Cibles possibles : les compétences du ruleset
// (sauf elle-même), sans filtre de sources — comme les conditions de notes.
$synergies    = [];
$cibles_synergie = [];
if ($ruleset_id === 1):
  if ($id > 0):
    $stmt = $db->prepare('
      SELECT syn_comp_cible_id, syn_seuil, syn_bonus, syn_condition
        FROM dd_competences_synergies
       WHERE syn_comp_source_id = ?
    ORDER BY syn_id
    ');
    $stmt->execute([$id]);
    $synergies = $stmt->fetchAll();
  endif;
  $stmt = $db->prepare('
    SELECT comp_id, comp_nom
      FROM dd_competences
     WHERE comp_ruleset_var_id = ? AND comp_id <> ?
     ORDER BY comp_nom
  ');
  $stmt->execute([$ruleset_id, $id]);
  $cibles_synergie = $stmt->fetchAll();
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

    <div class="modif-section">
      <div class="modif-grid">

        <?php if (!empty($meres)): ?>
          <!-- Domaine d'une compétence mère (SP-CD) -->
          <div class="form-group modif-grid__full">
            <label for="comp_parent_id">Domaine de</label>
            <select id="comp_parent_id" name="comp_parent_id">
              <option value="0">— Aucune (compétence à part entière) —</option>
              <?php foreach ($meres as $mere): ?>
                <option value="<?= (int)$mere['comp_id'] ?>"
                  <?= $comp_parent_id === (int)$mere['comp_id'] ? 'selected' : '' ?>>
                  <?= h($mere['comp_nom']) ?>
                </option>
              <?php endforeach ?>
            </select>
            <span class="form-hint">Pour un domaine (ex. Connaissances → « histoire »), la caractéristique,
              la formation et le malus d'armure sont ceux de la compétence mère.</span>
          </div>
        <?php endif ?>

        <!-- Nom -->
        <div class="form-group modif-grid__full">
          <label for="comp_nom"><span id="comp-nom-libelle"><?= $comp_parent_id > 0 ? 'Domaine' : 'Nom' ?></span> <span class="required">*</span></label>
          <input type="text" id="comp_nom" name="comp_nom"
                 value="<?= h($comp_nom_saisi) ?>" required maxlength="100">
        </div>

        <!-- Caractéristique associée -->
        <div class="form-group comp-champ-herite">
          <label for="comp_car_id">Caractéristique <span class="required">*</span></label>
          <select id="comp_car_id" name="comp_car_id">
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
        <div class="form-group comp-champ-herite">
          <label class="form-label--checkbox">
            <input type="checkbox" name="comp_formation" value="1"
              <?= $comp['comp_formation'] ? 'checked' : '' ?>>
            Formation requise
          </label>
        </div>

        <!-- Malus d'armure -->
        <div class="form-group comp-champ-herite">
          <label for="comp_malusArmure">Malus d'armure</label>
          <input type="number" id="comp_malusArmure" name="comp_malusArmure"
                 value="<?= (int)$comp['comp_malusArmure'] ?>" min="0" max="99">
        </div>

      </div><!-- .modif-grid -->
    </div><!-- .modif-section -->

    <?php if ($ruleset_id === 1): ?>
      <!-- Synergies accordées (SP-PE21 — DD3.5) -->
      <div class="modif-section">
        <div class="form-group">
          <?php // Présent même sans ligne : une liste vide efface les synergies ?>
          <input type="hidden" name="synergies_envoyees" value="1">
          <label>Synergies accordées</label>
          <span class="form-hint">Rangs minimum dans cette compétence pour donner le bonus à la compétence cible.
            Une condition (« parchemins ») réserve le bonus à certains tests : il est alors affiché sur la fiche,
            mais pas compté dans le total.</span>
          <table class="table-dd comp-synergies">
            <thead>
              <tr>
                <th class="comp-synergies__cible">Compétence cible</th>
                <th class="col-stat">Rangs</th>
                <th class="col-stat">Bonus</th>
                <th class="comp-synergies__condition">Condition (facultative)</th>
                <th class="col-stat"></th>
              </tr>
            </thead>
            <tbody id="comp-synergies-lignes">
              <?php foreach ($synergies as $i => $s): ?>
                <tr class="comp-synergies__ligne">
                  <td class="comp-synergies__cible">
                    <select name="synergies[<?= $i ?>][cible]">
                      <option value="0">— Choisir —</option>
                      <?php foreach ($cibles_synergie as $cb): ?>
                        <option value="<?= (int)$cb['comp_id'] ?>"
                          <?= (int)$s['syn_comp_cible_id'] === (int)$cb['comp_id'] ? 'selected' : '' ?>>
                          <?= h($cb['comp_nom']) ?>
                        </option>
                      <?php endforeach ?>
                    </select>
                  </td>
                  <td><input type="number" name="synergies[<?= $i ?>][seuil]" value="<?= (int)$s['syn_seuil'] ?>" min="1" max="99"></td>
                  <td><input type="number" name="synergies[<?= $i ?>][bonus]" value="<?= (int)$s['syn_bonus'] ?>" min="-20" max="20"></td>
                  <td class="comp-synergies__condition">
                    <input type="text" name="synergies[<?= $i ?>][condition]" value="<?= h($s['syn_condition'] ?? '') ?>" maxlength="200">
                  </td>
                  <td>
                    <button type="button" class="btn btn-link btn-sm comp-synergies__retirer" title="Retirer cette synergie">
                      <i class="fa fa-times"></i>
                    </button>
                  </td>
                </tr>
              <?php endforeach ?>
            </tbody>
          </table>
          <button type="button" class="btn btn-secondary btn-sm" id="comp-synergies-ajouter">
            <i class="fa fa-plus"></i> Ajouter une synergie
          </button>
          <template id="comp-synergies-modele">
            <tr class="comp-synergies__ligne">
              <td class="comp-synergies__cible">
                <select name="synergies[__i__][cible]">
                  <option value="0">— Choisir —</option>
                  <?php foreach ($cibles_synergie as $cb): ?>
                    <option value="<?= (int)$cb['comp_id'] ?>"><?= h($cb['comp_nom']) ?></option>
                  <?php endforeach ?>
                </select>
              </td>
              <td><input type="number" name="synergies[__i__][seuil]" value="5" min="1" max="99"></td>
              <td><input type="number" name="synergies[__i__][bonus]" value="2" min="-20" max="20"></td>
              <td class="comp-synergies__condition">
                <input type="text" name="synergies[__i__][condition]" value="" maxlength="200">
              </td>
              <td>
                <button type="button" class="btn btn-link btn-sm comp-synergies__retirer" title="Retirer cette synergie">
                  <i class="fa fa-times"></i>
                </button>
              </td>
            </tr>
          </template>
        </div>
      </div>
    <?php endif ?>

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

  // Domaine (SP-CD) : champs hérités de la mère masqués
  var selectMere = document.getElementById('comp_parent_id');
  var libelleNom = document.getElementById('comp-nom-libelle');
  function actualiserDomaine() {
    var estDomaine = selectMere && selectMere.value !== '0';
    document.querySelectorAll('#form-competence .comp-champ-herite').forEach(function (el) {
      el.style.display = estDomaine ? 'none' : '';
    });
    libelleNom.textContent = estDomaine ? 'Domaine' : 'Nom';
  }
  if (selectMere) selectMere.addEventListener('change', actualiserDomaine);
  actualiserDomaine();

  // Synergies accordées (SP-PE21) : ajout depuis le modèle, retrait par ligne.
  // L'indice ne sert qu'à grouper les champs d'une ligne : il croît sans se
  // réutiliser, les trous laissés par un retrait sont sans effet.
  var corpsSyn  = document.getElementById('comp-synergies-lignes');
  var modeleSyn = document.getElementById('comp-synergies-modele');
  var btnSyn    = document.getElementById('comp-synergies-ajouter');
  if (corpsSyn && modeleSyn && btnSyn) {
    var indiceSyn = corpsSyn.querySelectorAll('.comp-synergies__ligne').length;
    btnSyn.addEventListener('click', function () {
      var html = modeleSyn.innerHTML.replace(/__i__/g, String(indiceSyn++));
      corpsSyn.insertAdjacentHTML('beforeend', html);
    });
    corpsSyn.addEventListener('click', function (e) {
      var btn = e.target.closest('.comp-synergies__retirer');
      if (btn) btn.closest('tr').remove();
    });
  }
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
    toolbar:       'styles | bold italic underline | bullist numlist | link unlink table | tableau liste | removeformat | code',
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
