<?php
// include/ajax/modifier/personnage.php
// Formulaire de création / modification d'un personnage — identité.
// Appelé via ouvrirModifier() — pas de layout header/footer.
//
// Paramètres GET :
//   id (int) — pe_id à modifier (0 = création)
//
// Sous-phase 3.1 : identité complète (nom, sexe, race, archétype DD3.5,
// historique DD2024, alignement, caractéristiques, combat, background),
// + première classe + niveau obligatoires à la création (option 1).
// Les éditeurs Classes/NLS/Compétences/Dons/Sorts arrivent en 3.2 à 3.6.

require_once __DIR__ . '/../../db.php';
require_once __DIR__ . '/../../auth.php';
require_once __DIR__ . '/../../helpers.php';
require_once __DIR__ . '/../../personnage_helpers.php';

requireAuth();

$id   = intParam($_GET['id'] ?? 0);
$j_id = (int)$_SESSION['j_id'];

// ============================================================
// Chargement du personnage ou valeurs par défaut (création)
// ============================================================

$perso = [
  'pe_id'             => 0,
  'pe_nom'            => '',
  'pe_sexe'           => '',
  'pe_ra_id'          => 0,
  'pe_arc_id'         => 0,
  'pe_hi_id'          => 0,   // DD2024 — colonne ajoutée ci-dessous si absente
  'pe_al_id'          => 0,
  'pe_for'            => 10,
  'pe_con'            => 10,
  'pe_dex'            => 10,
  'pe_int'            => 10,
  'pe_sag'            => 10,
  'pe_cha'            => 10,
  'pe_ca'             => 10,
  'pe_pv'             => 0,
  'pe_background'     => '',
  'pe_ruleset_var_id' => (int)($_SESSION['ruleset_var_id'] ?? 1),
];

if ($id > 0):
  $row = getPersonnageContext($db, $id);
  if (!$row):
    http_response_code(404);
    echo '<p class="erreur">Personnage introuvable ou accès refusé.</p>';
    exit;
  endif;
  // Conserve les valeurs par défaut pour les colonnes éventuellement nulles
  foreach ($perso as $k => $v):
    if (array_key_exists($k, $row) && $row[$k] !== null):
      $perso[$k] = $row[$k];
    endif;
  endforeach;
endif;

$ruleset_id  = (int)$perso['pe_ruleset_var_id'];
$ruleset_rep = ($ruleset_id === 2) ? 'DD2024' : 'DD3.5';
$mode        = $id > 0 ? 'edition' : 'creation';

// ============================================================
// Listes de référence pour les selects
// ============================================================
//
// Pattern identique à compendium-liste.php :
//   - Si getActiveResIds() renvoie des ids → filtre sur ra_res_id IN (...)
//   - Si tableau vide → pas de filtre source (afficher tout le compendium global)
// Le compendium global = camp_id IS NULL.

$res_ids      = getActiveResIds($db);
$filtre_res   = !empty($res_ids);
$placeholders = $filtre_res ? resIdsPlaceholders($res_ids) : '';

// Races jouables (toutes sauf les archétypes DD3.5 ra_rat_id = 2).
// ra_rat_id = 1 → races de base DD3.5
// ra_rat_id = 2 → archétypes DD3.5 (exclus ici, listés séparément ci-dessous)
// ra_rat_id = 3 → races de base DD2024
// On filtre par ruleset_var_id ; les archétypes sont toujours ra_rat_id = 2.
$sql_races = "
  SELECT ra.ra_id, ra.ra_nom
    FROM dd_races ra
   WHERE ra.ra_ruleset_var_id = ?
     AND ra.ra_rat_id != 2
     AND ra.ra_camp_id IS NULL"
  . ($filtre_res ? " AND ra.ra_res_id IN ($placeholders)" : '') . "
   ORDER BY ra.ra_nom";
$stmt = $db->prepare($sql_races);
$stmt->execute($filtre_res ? array_merge([$ruleset_id], $res_ids) : [$ruleset_id]);
$races_base = $stmt->fetchAll();

// Archétypes (DD3.5 uniquement — ra_rat_id = 2)
$archetypes = [];
if ($ruleset_rep === 'DD3.5'):
  $sql_arc = "
    SELECT ra.ra_id, ra.ra_nom
      FROM dd_races ra
     WHERE ra.ra_ruleset_var_id = ?
       AND ra.ra_rat_id = 2
       AND ra.ra_camp_id IS NULL"
    . ($filtre_res ? " AND ra.ra_res_id IN ($placeholders)" : '') . "
     ORDER BY ra.ra_nom";
  $stmt = $db->prepare($sql_arc);
  $stmt->execute($filtre_res ? array_merge([$ruleset_id], $res_ids) : [$ruleset_id]);
  $archetypes = $stmt->fetchAll();
endif;

// Historiques (DD2024 uniquement)
$historiques = [];
if ($ruleset_rep === 'DD2024'):
  $sql_hi = "
    SELECT hi.hi_id, hi.hi_nom
      FROM dd_historiques hi
     WHERE hi.hi_ruleset_var_id = ?
       AND hi.hi_camp_id IS NULL"
    . ($filtre_res ? " AND hi.hi_res_id IN ($placeholders)" : '') . "
     ORDER BY hi.hi_nom";
  $stmt = $db->prepare($sql_hi);
  $stmt->execute($filtre_res ? array_merge([$ruleset_id], $res_ids) : [$ruleset_id]);
  $historiques = $stmt->fetchAll();
endif;

// Alignements (référentiel commun, 9 valeurs)
$alignements = getAlignements($db);

// Classes du ruleset (toutes confondues : base + prestige) pour le select "première classe"
$stmt = $db->prepare('
  SELECT cla.cla_id, cla.cla_nom
    FROM dd_classes cla
   WHERE cla.cla_ruleset_var_id = ?
   ORDER BY cla.cla_nom
');
$stmt->execute([$ruleset_id]);
$classes = $stmt->fetchAll();

// Pour le mode édition : première classe déjà existante (affichage informatif)
$classe_existante = null;
if ($mode === 'edition'):
  $stmt = $db->prepare('
    SELECT pc.pc_cla_id, pc.pc_niveau, cla.cla_nom
      FROM dd_personnages_classes pc
      JOIN dd_classes cla ON cla.cla_id = pc.pc_cla_id
     WHERE pc.pc_pe_id = ?
     ORDER BY pc.pc_id ASC
     LIMIT 1
  ');
  $stmt->execute([$id]);
  $classe_existante = $stmt->fetch() ?: null;
endif;

$titre = $mode === 'creation' ? 'Nouveau personnage' : 'Modifier ' . h($perso['pe_nom']);
?>

<div class="modif-form">
  <h3 class="modif-form__title"><?= $titre ?></h3>

  <form id="form-personnage" method="POST"
        action="<?= BASE_URL ?>/personnages/enregistrement.php?ajax=1">
    <?= csrfField() ?>
    <input type="hidden" name="action" value="enregistrerPersonnage">
    <input type="hidden" name="pe_id"  value="<?= (int)$perso['pe_id'] ?>">

    <!-- ====================================================
         SECTION 1 — Identité
         ==================================================== -->
    <div class="modif-section">
      <div class="modif-section__header">
        <span class="modif-section__label">Section 1 — Identité</span>
      </div>

      <div class="modif-grid">

        <div class="form-group modif-grid__full">
          <label for="pe_nom">Nom <span class="required">*</span></label>
          <input type="text" id="pe_nom" name="pe_nom"
                 value="<?= h($perso['pe_nom']) ?>" required maxlength="100">
        </div>

        <div class="form-group">
          <label for="pe_ruleset_var_id">Ruleset <span class="required">*</span></label>
          <?php if ($mode === 'edition'): ?>
            <input type="text" value="<?= libVar($db, $ruleset_id) ?>" disabled>
            <input type="hidden" name="pe_ruleset_var_id" value="<?= $ruleset_id ?>">
            <p class="form-hint">Le ruleset ne peut pas être modifié.</p>
          <?php else: ?>
            <?= optionListVar($db, 'ruleset', 'pe_ruleset_var_id', $ruleset_id) ?>
            <p class="form-hint">
              Le ruleset est fixé à la création (modifie races, historique et classes disponibles).
            </p>
          <?php endif ?>
        </div>

        <div class="form-group">
          <label for="pe_sexe">Sexe</label>
          <input type="text" id="pe_sexe" name="pe_sexe"
                 value="<?= h($perso['pe_sexe']) ?>" maxlength="20"
                 placeholder="Ex : féminin, masculin…">
        </div>

        <div class="form-group">
          <label for="pe_al_id">Alignement</label>
          <select id="pe_al_id" name="pe_al_id">
            <option value="0">— Non renseigné —</option>
            <?php foreach ($alignements as $al): ?>
              <option value="<?= (int)$al['al_id'] ?>"
                <?= (int)$perso['pe_al_id'] === (int)$al['al_id'] ? 'selected' : '' ?>>
                <?= h($al['al_nom']) ?> (<?= h($al['al_abreviation']) ?>)
              </option>
            <?php endforeach ?>
          </select>
        </div>

        <div class="form-group">
          <label for="pe_ra_id">Race <span class="required">*</span></label>
          <select id="pe_ra_id" name="pe_ra_id" required>
            <option value="0">— Choisir une race —</option>
            <?php foreach ($races_base as $ra): ?>
              <option value="<?= (int)$ra['ra_id'] ?>"
                <?= (int)$perso['pe_ra_id'] === (int)$ra['ra_id'] ? 'selected' : '' ?>>
                <?= h($ra['ra_nom']) ?>
              </option>
            <?php endforeach ?>
          </select>
        </div>

        <?php if ($ruleset_rep === 'DD3.5'): ?>
          <div class="form-group">
            <label for="pe_arc_id">Archétype</label>
            <select id="pe_arc_id" name="pe_arc_id">
              <option value="0">— Aucun —</option>
              <?php foreach ($archetypes as $arc): ?>
                <option value="<?= (int)$arc['ra_id'] ?>"
                  <?= (int)$perso['pe_arc_id'] === (int)$arc['ra_id'] ? 'selected' : '' ?>>
                  <?= h($arc['ra_nom']) ?>
                </option>
              <?php endforeach ?>
            </select>
          </div>
        <?php else: ?>
          <input type="hidden" name="pe_arc_id" value="0">
        <?php endif ?>

        <?php if ($ruleset_rep === 'DD2024'): ?>
          <div class="form-group">
            <label for="pe_hi_id">Historique</label>
            <select id="pe_hi_id" name="pe_hi_id">
              <option value="0">— Aucun —</option>
              <?php foreach ($historiques as $hi): ?>
                <option value="<?= (int)$hi['hi_id'] ?>"
                  <?= (int)$perso['pe_hi_id'] === (int)$hi['hi_id'] ? 'selected' : '' ?>>
                  <?= h($hi['hi_nom']) ?>
                </option>
              <?php endforeach ?>
            </select>
          </div>
        <?php else: ?>
          <input type="hidden" name="pe_hi_id" value="0">
        <?php endif ?>

      </div><!-- .modif-grid -->
    </div><!-- .modif-section -->

    <!-- ====================================================
         SECTION 2 — Caractéristiques
         Saisie déclarative : aucune validation des règles
         de point-buy ou de génération.
         ==================================================== -->
    <div class="modif-section">
      <div class="modif-section__header">
        <span class="modif-section__label">Section 2 — Caractéristiques</span>
      </div>
      <div class="modif-grid modif-grid--carac">

        <?php
          $caracs = [
            'pe_for' => ['lbl' => 'Force',        'abr' => 'FOR'],
            'pe_con' => ['lbl' => 'Constitution', 'abr' => 'CON'],
            'pe_dex' => ['lbl' => 'Dextérité',    'abr' => 'DEX'],
            'pe_int' => ['lbl' => 'Intelligence', 'abr' => 'INT'],
            'pe_sag' => ['lbl' => 'Sagesse',      'abr' => 'SAG'],
            'pe_cha' => ['lbl' => 'Charisme',     'abr' => 'CHA'],
          ];
        ?>
        <?php foreach ($caracs as $champ => $meta): ?>
          <div class="form-group form-group--carac">
            <label for="<?= $champ ?>" title="<?= h($meta['lbl']) ?>"><?= $meta['abr'] ?></label>
            <input type="number" id="<?= $champ ?>" name="<?= $champ ?>"
                   value="<?= (int)$perso[$champ] ?>" min="0" max="99" required
                   inputmode="numeric">
          </div>
        <?php endforeach ?>

      </div>
    </div>

    <!-- ====================================================
         SECTION 3 — Combat
         ==================================================== -->
    <div class="modif-section">
      <div class="modif-section__header">
        <span class="modif-section__label">Section 3 — Combat</span>
      </div>
      <div class="modif-grid">

        <div class="form-group">
          <label for="pe_ca">Classe d'armure (CA)</label>
          <input type="number" id="pe_ca" name="pe_ca"
                 value="<?= (int)$perso['pe_ca'] ?>" min="0" max="99" required
                 inputmode="numeric">
        </div>

        <div class="form-group">
          <label for="pe_pv">Points de vie (PV)</label>
          <input type="number" id="pe_pv" name="pe_pv"
                 value="<?= (int)$perso['pe_pv'] ?>" min="0" max="9999" required
                 inputmode="numeric">
        </div>

      </div>
    </div>

    <!-- ====================================================
         SECTION 4 — Première classe (création UNIQUEMENT)
         Règle métier : ≥ 1 classe à la création (cf. archi §7.2).
         L'éditeur complet multi-classes arrive en 3.2 ; en 3.1,
         on impose seulement la première ligne.
         En édition, on affiche pour information la classe la plus
         ancienne (modification gérée par l'éditeur 3.2).
         ==================================================== -->
    <?php if ($mode === 'creation'): ?>
      <div class="modif-section">
        <div class="modif-section__header">
          <span class="modif-section__label">Section 4 — Première classe</span>
        </div>
        <div class="modif-grid">

          <div class="form-group">
            <label for="pe_cla_id">Classe <span class="required">*</span></label>
            <select id="pe_cla_id" name="pe_cla_id" required>
              <option value="0">— Choisir une classe —</option>
              <?php foreach ($classes as $cla): ?>
                <option value="<?= (int)$cla['cla_id'] ?>">
                  <?= h($cla['cla_nom']) ?>
                </option>
              <?php endforeach ?>
            </select>
          </div>

          <div class="form-group">
            <label for="pe_cla_niveau">Niveau <span class="required">*</span></label>
            <input type="number" id="pe_cla_niveau" name="pe_cla_niveau"
                   value="1" min="1" max="40" required inputmode="numeric">
          </div>

        </div>
        <p class="form-hint">
          À la création, un personnage doit avoir au moins une classe. Les classes
          supplémentaires et la modification des niveaux se gèrent ensuite depuis
          la fiche (sous-phase 3.2).
        </p>
      </div>
    <?php elseif ($classe_existante): ?>
      <div class="modif-section">
        <div class="modif-section__header">
          <span class="modif-section__label">Section 4 — Classes</span>
        </div>
        <p class="form-hint">
          Première classe : <strong><?= h($classe_existante['cla_nom']) ?></strong>
          (niveau <?= (int)$classe_existante['pc_niveau'] ?>). La gestion des
          classes et des niveaux se fait depuis la fiche (sous-phase 3.2).
        </p>
      </div>
    <?php endif ?>

    <!-- ====================================================
         SECTION 5 — Background (texte riche)
         ==================================================== -->
    <div class="modif-section">
      <div class="modif-section__header">
        <span class="modif-section__label">Section 5 — Background</span>
      </div>
      <div class="form-group">
        <label for="pe_background">Historique du personnage</label>
        <textarea id="pe_background" name="pe_background"
                  class="tinymce-full"><?= $perso['pe_background'] ?? '' ?></textarea>
      </div>
    </div>

    <!-- ====================================================
         BOUTONS
         ==================================================== -->
    <div class="modif-actions">
      <button type="button" class="btn btn-primary" onclick="personnageForm.soumettre()">
        <i class="fa fa-save"></i> Enregistrer
      </button>
      <button type="button" class="btn btn-secondary" onclick="fermerModification()">
        <i class="fa fa-times"></i> Annuler
      </button>
    </div>

  </form>
</div>

<!-- TinyMCE -->
<script src="https://cdn.jsdelivr.net/npm/tinymce@6/tinymce.min.js"></script>
<script>
// ============================================================
// IIFE — isolation du scope (formulaire injecté via innerHTML).
// L'objet personnageForm est exposé sur window pour les onclick="".
// ============================================================
(function() {
  'use strict';

  // ---- TinyMCE : configuration complète (images autorisées) ----
  (function initTMCE() {
    if (typeof tinymce === 'undefined') { setTimeout(initTMCE, 100); return; }
    var isLight = document.body.classList.contains('theme-light');
    tinymce.remove('#pe_background');
    tinymce.init({
      selector:    '#pe_background',
      language:    'fr_FR',
      menubar:     false,
      plugins:     'lists link image table',
      toolbar:     'bold italic underline | bullist numlist | h2 h3 | link image table | removeformat',
      height:      360,
      skin:        isLight ? 'oxide' : 'oxide-dark',
      content_css: isLight ? 'default' : 'dark',
      promotion:   false,
      branding:    false,
      base_url:    'https://cdn.jsdelivr.net/npm/tinymce@6',
      suffix:      '.min',
      images_upload_url: '<?= BASE_URL ?>/include/ajax/upload-image.php',
      images_upload_credentials: true,
      automatic_uploads: true,
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
    const form = document.getElementById('form-personnage');
    if (!form) return;

    // Validations basiques côté client
    const nom = document.getElementById('pe_nom').value.trim();
    if (!nom) { alert('Le nom du personnage est obligatoire.'); return; }

    const raId = parseInt(document.getElementById('pe_ra_id').value || '0', 10);
    if (raId <= 0) { alert('La race est obligatoire.'); return; }

    // À la création, première classe + niveau obligatoires
    const claSelect = document.getElementById('pe_cla_id');
    if (claSelect) {
      const claId = parseInt(claSelect.value || '0', 10);
      if (claId <= 0) { alert('La première classe est obligatoire.'); return; }
      const niv = parseInt(document.getElementById('pe_cla_niveau').value || '0', 10);
      if (niv < 1) { alert('Le niveau de la première classe doit être au moins 1.'); return; }
    }

    // Synchroniser TinyMCE avant l'envoi
    const bgEl = document.getElementById('pe_background');
    if (bgEl) bgEl.value = tmceGet('pe_background');

    fetch(form.getAttribute('action'), {
      method: 'POST',
      body:   new FormData(form),
    })
    .then(r => r.json())
    .then(data => {
      if (data.ok) {
        fermerModification();
        // Si on est sur la liste : déclenche un rafraîchissement
        if (typeof _pendingListRefresh !== 'undefined') {
          _pendingListRefresh = true;
        }
        // Si la page d'origine est la liste, on rafraîchit ; sinon on va sur la fiche
        if (data.url_fiche) {
          window.location = data.url_fiche;
        } else if (typeof rafraichirListe === 'function') {
          rafraichirListe();
        }
      } else {
        alert(data.erreur || "Erreur lors de l'enregistrement.");
      }
    })
    .catch(err => alert('Erreur : ' + err));
  }

  window.personnageForm = { soumettre: soumettre };

})(); // fin IIFE
</script>
