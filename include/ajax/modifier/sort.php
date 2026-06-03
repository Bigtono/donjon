<?php
// include/ajax/modifier/sort.php
// Retourne le HTML du formulaire de création/modification d'un sort
// Appelé via actualiserPageModif() — pas de layout header/footer
//
// Paramètres GET :
//   id (int) — so_id du sort à modifier (0 = création)

require_once __DIR__ . '/../../db.php';
require_once __DIR__ . '/../../auth.php';
require_once __DIR__ . '/../../helpers.php';

requireAuth();
if (!canEditCompendium()):
  http_response_code(403);
  echo '<p class="erreur">Accès refusé.</p>';
  exit;
endif;

$id      = intParam($_GET['id'] ?? 0);
$ruleset = $_SESSION['rulesetRep'] ?? 'DD3.5';
$res_ids = getActiveResIds($db);

// ============================================================
// Chargement du sort existant (modification) ou valeurs vides (création)
// ============================================================
$so = [
  'so_id'                => 0,
  'so_nom'               => '',
  'so_co_id'             => '',
  'so_branche'           => '',
  'so_vocal'             => 0,
  'so_gestuel'           => 0,
  'so_materiel'          => 0,
  'so_focalisateur'      => 0,
  'so_focalisateur_divin'=> 0,
  'so_composante'        => '',
  'so_portee'            => '',
  'so_cible'             => '',
  'so_zone_effet'        => '',
  'so_duree_incantation' => '',
  'so_duree_sort'        => '',
  'so_jet_sauvegarde'    => '',
  'so_resistance'        => '',
  'so_niveau'            => '',
  'so_resume'            => '',
  'so_description'       => '',
  'so_res_id'            => '',
  'so_camp_id'           => '',
];

if ($id > 0):
  $stmt = $db->prepare('SELECT * FROM dd_sorts WHERE so_id = ?');
  $stmt->execute([$id]);
  $row = $stmt->fetch();
  if ($row) $so = $row;
endif;

// Niveaux existants par classe
$niveaux_classes = [];
if ($id > 0):
  $stmt = $db->prepare('SELECT sc_cla_id, sc_niveau FROM dd_sortclasse WHERE sc_so_id = ?');
  $stmt->execute([$id]);
  foreach ($stmt->fetchAll() as $r):
    $niveaux_classes[(int)$r['sc_cla_id']] = (int)$r['sc_niveau'];
  endforeach;
endif;

// Niveaux existants par domaine [DD3.5]
$niveaux_domaines = [];
if ($id > 0 && $ruleset === 'DD3.5'):
  $stmt = $db->prepare('SELECT sd_do_id, sd_niveau FROM dd_sortdomaine WHERE sd_so_id = ?');
  $stmt->execute([$id]);
  foreach ($stmt->fetchAll() as $r):
    $niveaux_domaines[(int)$r['sd_do_id']] = (int)$r['sd_niveau'];
  endforeach;
endif;

// ============================================================
// Listes de référence
// ============================================================

// Collèges
$colleges = $db->query('SELECT co_id, co_nom FROM dd_colleges ORDER BY co_nom')->fetchAll();

// Classes lanceurs de sort du ruleset
$ruleset_id = (int)($_SESSION['ruleset_var_id'] ?? 1);
$stmt = $db->prepare('
  SELECT cla_id, cla_nom, cla_clt_id
  FROM   dd_classes
  WHERE  cla_mag_id > 0
    AND  cla_ruleset_var_id = ?
  ORDER  BY cla_clt_id ASC, cla_nom ASC
');
$stmt->execute([$ruleset_id]);
$classes = $stmt->fetchAll();

// Domaines [DD3.5]
$domaines = [];
if ($ruleset === 'DD3.5'):
  $domaines = $db->query('SELECT do_id, do_nom FROM dd_domaines ORDER BY do_nom')->fetchAll();
endif;

// Ressources actives
$sources = [];
if (!empty($res_ids)):
  $ph   = resIdsPlaceholders($res_ids);
  $stmt = $db->prepare("SELECT res_id, res_nom FROM dd_ressources WHERE res_id IN ($ph) ORDER BY res_nom");
  $stmt->execute($res_ids);
  $sources = $stmt->fetchAll();
endif;

// Campagnes de l'utilisateur (pour homebrew)
$campagnes = [];
if (!empty($_SESSION['j_mode_campagne'])):
  [$owWhere, $owParams] = ownerFilter('camp');
  $stmt = $db->prepare("SELECT camp_id, camp_nom FROM dd_campagnes WHERE $owWhere ORDER BY camp_nom");
  $stmt->execute($owParams);
  $campagnes = $stmt->fetchAll();
endif;

$titre = $id > 0 ? 'Modifier ' . h($so['so_nom']) : 'Nouveau sort';

// Niveaux disponibles
$niveaux_dd35   = range(0, 9);
$niveaux_dd2024 = range(0, 20);
?>

<div class="modif-form">
  <h3 class="modif-form__title"><?= $titre ?></h3>

  <form id="form-sort" method="POST" action="<?= BASE_URL ?>/compendium/enregistrement.php?ajax=1">
    <?= csrfField() ?>
    <input type="hidden" name="entite"  value="sort">
    <input type="hidden" name="action"  value="sauvegarder">
    <input type="hidden" name="so_id"   value="<?= (int)$so['so_id'] ?>">
    <input type="hidden" name="so_ruleset_var_id" value="<?= $ruleset_id ?>">

    <!-- ====================================================
         DONNÉES PRINCIPALES
         ==================================================== -->
    <div class="modif-section">

      <div class="modif-grid">

        <div class="form-group modif-grid__full">
          <label for="so_nom">Nom <span class="required">*</span></label>
          <input type="text" id="so_nom" name="so_nom"
                 value="<?= h($so['so_nom']) ?>" required maxlength="150">
        </div>

        <div class="form-group">
          <label for="so_co_id">Collège de magie</label>
          <select id="so_co_id" name="so_co_id">
            <option value="">— Aucun —</option>
            <?php foreach ($colleges as $co): ?>
              <option value="<?= (int)$co['co_id'] ?>"
                <?= (int)$so['so_co_id'] === (int)$co['co_id'] ? 'selected' : '' ?>>
                <?= h($co['co_nom']) ?>
              </option>
            <?php endforeach ?>
          </select>
        </div>

        <?php if ($ruleset === 'DD3.5'): ?>
          <div class="form-group">
            <label for="so_branche">Branche</label>
            <input type="text" id="so_branche" name="so_branche"
                   value="<?= h($so['so_branche'] ?? '') ?>" maxlength="40">
          </div>
        <?php endif ?>

        <?php if ($ruleset === 'DD2024'): ?>
          <div class="form-group">
            <label for="so_niveau">Niveau du sort</label>
            <select id="so_niveau" name="so_niveau">
              <?php foreach (range(0, 9) as $n): ?>
                <option value="<?= $n ?>" <?= (string)$so['so_niveau'] === (string)$n ? 'selected' : '' ?>>
                  <?= $n ?>
                </option>
              <?php endforeach ?>
            </select>
          </div>
        <?php endif ?>

        <div class="form-group">
          <label for="so_duree_incantation">Temps d'incantation <span class="required">*</span></label>
          <input type="text" id="so_duree_incantation" name="so_duree_incantation"
                 value="<?= h($so['so_duree_incantation']) ?>" required maxlength="100">
        </div>

        <div class="form-group">
          <label for="so_portee">Portée <span class="required">*</span></label>
          <input type="text" id="so_portee" name="so_portee"
                 value="<?= h($so['so_portee']) ?>" required maxlength="100">
        </div>

        <?php if ($ruleset === 'DD3.5'): ?>
          <div class="form-group">
            <label for="so_cible">Cible</label>
            <input type="text" id="so_cible" name="so_cible"
                   value="<?= h($so['so_cible'] ?? '') ?>" maxlength="150">
          </div>

          <div class="form-group">
            <label for="so_zone_effet">Zone d'effet</label>
            <input type="text" id="so_zone_effet" name="so_zone_effet"
                   value="<?= h($so['so_zone_effet'] ?? '') ?>" maxlength="100">
          </div>
        <?php endif ?>

        <div class="form-group">
          <label for="so_duree_sort">Durée</label>
          <input type="text" id="so_duree_sort" name="so_duree_sort"
                 value="<?= h($so['so_duree_sort'] ?? '') ?>" maxlength="100">
        </div>

        <?php if ($ruleset === 'DD3.5'): ?>
          <div class="form-group">
            <label for="so_jet_sauvegarde">Jet de sauvegarde</label>
            <input type="text" id="so_jet_sauvegarde" name="so_jet_sauvegarde"
                   value="<?= h($so['so_jet_sauvegarde'] ?? '') ?>" maxlength="100">
          </div>

          <div class="form-group">
            <label for="so_resistance">Résistance à la magie</label>
            <input type="text" id="so_resistance" name="so_resistance"
                   value="<?= h($so['so_resistance'] ?? '') ?>" maxlength="100">
          </div>
        <?php endif ?>

        <div class="form-group">
          <label for="so_res_id">Source <span class="required">*</span></label>
          <select id="so_res_id" name="so_res_id" required>
            <option value="">— Choisir —</option>
            <?php foreach ($sources as $src): ?>
              <option value="<?= (int)$src['res_id'] ?>"
                <?= (int)$so['so_res_id'] === (int)$src['res_id'] ? 'selected' : '' ?>>
                <?= h($src['res_nom']) ?>
              </option>
            <?php endforeach ?>
          </select>
        </div>

        <?php if (!empty($campagnes)): ?>
          <div class="form-group">
            <label for="so_camp_id">Campagne (homebrew)</label>
            <select id="so_camp_id" name="so_camp_id">
              <option value="">— Compendium global —</option>
              <?php foreach ($campagnes as $camp): ?>
                <option value="<?= (int)$camp['camp_id'] ?>"
                  <?= (int)$so['so_camp_id'] === (int)$camp['camp_id'] ? 'selected' : '' ?>>
                  <?= h($camp['camp_nom']) ?>
                </option>
              <?php endforeach ?>
            </select>
          </div>
        <?php endif ?>

      </div><!-- .modif-grid -->

      <!-- Composantes -->
      <div class="form-group">
        <label>Composantes</label>
        <div class="modif-checks">
          <label class="modif-check">
            <input type="checkbox" name="so_vocal" value="1"
                   <?= $so['so_vocal'] ? 'checked' : '' ?>>
            V — Verbale
          </label>
          <label class="modif-check">
            <input type="checkbox" name="so_gestuel" value="1"
                   <?= $so['so_gestuel'] ? 'checked' : '' ?>>
            <?= $ruleset === 'DD2024' ? 'S — Somatique' : 'G — Gestuelle' ?>
          </label>
          <label class="modif-check">
            <input type="checkbox" name="so_materiel" value="1"
                   <?= $so['so_materiel'] ? 'checked' : '' ?>>
            M — Matérielle
          </label>
          <?php if ($ruleset === 'DD3.5'): ?>
            <label class="modif-check">
              <input type="checkbox" name="so_focalisateur" value="1"
                     <?= $so['so_focalisateur'] ? 'checked' : '' ?>>
              F — Focalisateur
            </label>
            <label class="modif-check">
              <input type="checkbox" name="so_focalisateur_divin" value="1"
                     <?= $so['so_focalisateur_divin'] ? 'checked' : '' ?>>
              FD — Focalisateur divin
            </label>
          <?php endif ?>
        </div>
      </div>

      <div class="form-group">
        <label for="so_composante">Détail des composantes matérielles</label>
        <input type="text" id="so_composante" name="so_composante"
               value="<?= h($so['so_composante'] ?? '') ?>" maxlength="255"
               placeholder="Ex: une plume de hibou, 100 po de poudre de diamant…">
      </div>

    </div><!-- .modif-section -->

    <!-- ====================================================
         CLASSES — bloc repliable
         ==================================================== -->
    <div class="modif-section">
      <div class="modif-section__header">
        <span class="modif-section__label">Classes</span>
        <button type="button" class="accordion-trigger" onclick="togglePlusExclusif('bloc-classes', '#form-sort')">
          <i class="fa fa-bars"></i>
        </button>
      </div>
      <div id="bloc-classes" class="accordion-content noDisplay">
        <div class="box-data">
          <div class="modif-niveau-grid">
            <?php foreach ($classes as $cla): ?>
              <?php
                $cla_id  = (int)$cla['cla_id'];
                $niveau  = $niveaux_classes[$cla_id] ?? 0;
                $is_prestige = (int)$cla['cla_clt_id'] === 2;
              ?>
              <div class="modif-niveau-row<?= $is_prestige ? ' modif-niveau-row--prestige' : '' ?>">
                <span class="modif-niveau-nom"><?= h($cla['cla_nom']) ?></span>
                <select name="niveaux_classes[<?= $cla_id ?>]" class="modif-niveau-select">
                  <option value="0"></option>
                  <?php foreach ($ruleset === 'DD3.5' ? $niveaux_dd35 : $niveaux_dd2024 as $n): ?>
                    <?php if ($n === 0) continue ?>
                    <option value="<?= $n ?>" <?= $niveau === $n ? 'selected' : '' ?>><?= $n ?></option>
                  <?php endforeach ?>
                </select>
              </div>
            <?php endforeach ?>
          </div>
        </div>
      </div>
    </div>

    <!-- ====================================================
         DOMAINES [DD3.5] — bloc repliable
         ==================================================== -->
    <?php if ($ruleset === 'DD3.5' && !empty($domaines)): ?>
    <div class="modif-section">
      <div class="modif-section__header">
        <span class="modif-section__label">Domaines</span>
        <button type="button" class="accordion-trigger" onclick="togglePlusExclusif('bloc-domaines', '#form-sort')">
          <i class="fa fa-bars"></i>
        </button>
      </div>
      <div id="bloc-domaines" class="accordion-content noDisplay">
        <div class="box-data">
          <div class="modif-niveau-grid">
            <?php foreach ($domaines as $dom): ?>
              <?php
                $dom_id = (int)$dom['do_id'];
                $niveau = $niveaux_domaines[$dom_id] ?? 0;
              ?>
              <div class="modif-niveau-row">
                <span class="modif-niveau-nom"><?= h($dom['do_nom']) ?></span>
                <select name="niveaux_domaines[<?= $dom_id ?>]" class="modif-niveau-select">
                  <option value="0"></option>
                  <?php foreach ($niveaux_dd35 as $n): ?>
                    <?php if ($n === 0) continue ?>
                    <option value="<?= $n ?>" <?= $niveau === $n ? 'selected' : '' ?>><?= $n ?></option>
                  <?php endforeach ?>
                </select>
              </div>
            <?php endforeach ?>
          </div>
        </div>
      </div>
    </div>
    <?php endif ?>

    <!-- ====================================================
         DESCRIPTION — TinyMCE
         ==================================================== -->
    <div class="modif-section">
      <div class="form-group">
        <label for="so_description">Description</label>
        <textarea id="so_description" name="so_description"
                  class="tinymce-basic"><?= $so['so_description'] ?? '' ?></textarea>
      </div>
    </div>

    <!-- ====================================================
         RÉSUMÉ [DD3.5]
         ==================================================== -->
    <?php if ($ruleset === 'DD3.5'): ?>
    <div class="modif-section">
      <div class="form-group">
        <label for="so_resume">Résumé <span class="form-hint" style="font-weight:normal;">(non affiché dans la fiche — usage futur dans les listes)</span></label>
        <textarea id="so_resume" name="so_resume" rows="3"><?= h($so['so_resume'] ?? '') ?></textarea>
      </div>
    </div>
    <?php endif ?>

    <!-- ====================================================
         BOUTONS
         ==================================================== -->
    <div class="modif-actions">
      <button type="button" class="btn btn-primary" onclick="soumettreSort()">
        <i class="fa fa-save"></i> Enregistrer
      </button>
      <button type="button" class="btn btn-secondary" onclick="fermerModification()">
        <i class="fa fa-times"></i> Annuler
      </button>
    </div>

  </form>
</div>

<!-- TinyMCE via jsDelivr (sans clé API requise) -->
<script src="https://cdn.jsdelivr.net/npm/tinymce@6/tinymce.min.js"></script>
<script>
(function initTMCE() {
  if (typeof tinymce === 'undefined') { setTimeout(initTMCE, 100); return; }
  tinymce.remove('#so_description');
  tinymce.init({
    selector:    '#so_description',
    language:    'fr_FR',
    menubar:     false,
    plugins:     'lists link table',
    toolbar:     'bold italic underline | bullist numlist | h2 h3 | link table | removeformat',
    height:      400,
    skin:        'oxide-dark',
    content_css: 'dark',
    promotion:   false,
    branding:    false,
    base_url:    'https://cdn.jsdelivr.net/npm/tinymce@6',
    suffix:      '.min',
  });
})();
</script>
