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
            (texte brut — les dons, sorts, objets, capacités… cités seront
            rendus cliquables automatiquement à l'affichage)
          </span>
        </label>
        <textarea id="mo_stats" name="mo_stats"
                  class="mo-stats-input" rows="18"
                  placeholder="Classe d'armure : …&#10;Dés de vie : …&#10;Dons : …&#10;Compétences : …&#10;&#10;Utiliser une ligne *** pour insérer un séparateur."><?= h($mo['mo_stats'] ?? '') ?></textarea>
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
</div>
