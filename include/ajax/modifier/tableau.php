<?php
// include/ajax/modifier/tableau.php
// Formulaire overlay création / modification d'un tableau dd_tableaux (SP-TB3).
// Appelé via actualiserPageModif() — pas de layout header/footer.
//
// Paramètres GET :
//   id (int) — tab_id à modifier (0 = création)
//
// Le contenu est saisi en clair (convention texte) : pas de TinyMCE ici, c'est
// précisément ce dont ce module affranchit l'utilisateur.
//
// Référence : doc/ARCHITECTURE_0_REFERENCE.md §9c

require_once __DIR__ . '/../../db.php';
require_once __DIR__ . '/../../auth.php';
require_once __DIR__ . '/../../helpers.php';
require_once __DIR__ . '/../../tableau-parser.php';

requireAuth();
if (!canEditCompendium()):
  http_response_code(403);
  echo '<p class="erreur">Accès refusé.</p>';
  exit;
endif;

$id         = intParam($_GET['id'] ?? 0);
$ruleset_id = (int)($_SESSION['ruleset_var_id'] ?? 1);

$tab = [
  'tab_id'          => 0,
  'tab_slug'        => '',
  'tab_nom'         => '',
  'tab_contenu'     => '',
  'tab_align'       => '',
  'tab_note'        => '',
  'tab_res_id'      => 0,
  'tab_ecran_mj'    => 0,
  'tab_ecran_ordre' => 0,
  'tab_visible'     => 1,
];

if ($id > 0):
  $row = chargerTableauParId($db, $id, $ruleset_id);
  if (!$row):
    http_response_code(404);
    echo '<p class="erreur">Tableau introuvable.</p>';
    exit;
  endif;
  $tab = array_merge($tab, array_map(fn($v) => $v ?? '', $row));
endif;

// Ressources du ruleset (attribution de la source)
$stmt = $db->prepare('
  SELECT res_id, res_nom FROM dd_ressources
  WHERE  res_ruleset_var_id = ?
  ORDER  BY res_nom
');
$stmt->execute([$ruleset_id]);
$ressources = $stmt->fetchAll();

$est_creation = $id === 0;
$titre = $est_creation ? 'Nouveau tableau' : 'Modifier — ' . h($tab['tab_nom']);
$uid   = 'tab_' . ($id ?: 'new');
?>

<div class="modifier-tableau">

  <h2 class="overlay-titre"><?= $titre ?></h2>

  <div class="modifier-tableau__form">

    <input type="hidden" id="<?= $uid ?>_id" value="<?= (int)$tab['tab_id'] ?>">
    <?= csrfField() ?>

    <div class="form-group">
      <label for="<?= $uid ?>_nom">Nom <span class="form-required">*</span></label>
      <input type="text" id="<?= $uid ?>_nom" class="form-control"
             value="<?= h($tab['tab_nom']) ?>" required maxlength="200" autocomplete="off">
    </div>

    <div class="form-group">
      <label for="<?= $uid ?>_slug">
        Slug
        <small class="form-hint">(clé du tag — laisser vide pour générer depuis le nom)</small>
      </label>
      <input type="text" id="<?= $uid ?>_slug" class="form-control"
             value="<?= h($tab['tab_slug']) ?>" maxlength="120" autocomplete="off"
             pattern="[a-z0-9\-]*" title="Minuscules, chiffres et tirets uniquement">
      <?php if (!$est_creation): ?>
        <p class="form-hint">
          Tag à insérer dans une règle :
          <code class="reg-tab-liste__tag">[[tab:<?= h($tab['tab_slug']) ?>]]</code>
          — renommer le slug met automatiquement à jour les règles et les monstres
          qui l'utilisent.
        </p>
      <?php endif ?>
    </div>

    <?php // ---- Contenu (convention texte) ---- ?>
    <div class="form-group">
      <label for="<?= $uid ?>_contenu">Contenu <span class="form-required">*</span></label>

      <details class="reg-tab-aide">
        <summary>Rappel de la convention de saisie</summary>
        <table class="reg-tab-aide__table">
          <tr><td><code>|</code></td><td>sépare les cellules</td></tr>
          <tr><td><code>!</code></td><td>ligne d'en-tête — plusieurs <code>!</code> consécutifs = en-tête à plusieurs niveaux</td></tr>
          <tr><td><code>#</code></td><td>ligne de section, fusionnée sur toute la largeur</td></tr>
          <tr><td><code>&gt;</code></td><td>note de bas de tableau</td></tr>
          <tr><td><em>vide</em></td><td>dans une ligne <code>!</code> : fusion avec la cellule de gauche</td></tr>
          <tr><td><code>^</code></td><td>dans une ligne <code>!</code> : fusion avec la cellule du dessus</td></tr>
        </table>
        <p class="form-hint">
          Liens cliquables dans les cellules :
          <code>#don#</code> · <code>$sort$</code> · <code>&amp;objet&amp;</code> ·
          <code>@id_règle@</code> · <code>%id_glossaire%</code>
        </p>
        <pre class="reg-tab-aide__exemple">! | Rythme | | | Effet
! Distance par… | Rapide | Normal | Lent | ^
Minute | 120 m | 90 m | 60 m | —</pre>
      </details>

      <textarea id="<?= $uid ?>_contenu" class="form-control reg-tab-saisie"
                rows="16" spellcheck="false"
                placeholder="! Colonne A | Colonne B&#10;valeur 1 | valeur 2"><?= h($tab['tab_contenu']) ?></textarea>
    </div>

    <div class="form-group form-group--inline">
      <label for="<?= $uid ?>_align">
        Alignement
        <small class="form-hint">(une lettre par colonne : l gauche, c centré, r droite — ex. <code>lrr</code>)</small>
      </label>
      <input type="text" id="<?= $uid ?>_align" class="form-control form-control--sm"
             value="<?= h($tab['tab_align']) ?>" maxlength="40" autocomplete="off"
             pattern="[lcrLCR,\s]*">
    </div>

    <div class="form-group">
      <label for="<?= $uid ?>_note">Note de bas de tableau</label>
      <input type="text" id="<?= $uid ?>_note" class="form-control"
             value="<?= h($tab['tab_note']) ?>" maxlength="500" autocomplete="off">
    </div>

    <div class="form-group">
      <label for="<?= $uid ?>_res">Source</label>
      <select id="<?= $uid ?>_res" class="form-control">
        <option value="0">— Aucune —</option>
        <?php foreach ($ressources as $r): ?>
          <option value="<?= (int)$r['res_id'] ?>"
            <?= (int)$tab['tab_res_id'] === (int)$r['res_id'] ? ' selected' : '' ?>>
            <?= h($r['res_nom']) ?>
          </option>
        <?php endforeach ?>
      </select>
    </div>

    <div class="form-group form-group--inline">
      <label class="form-check-label">
        <input type="checkbox" id="<?= $uid ?>_ecran" value="1"
          <?= $tab['tab_ecran_mj'] ? 'checked' : '' ?>>
        Retenir pour l'écran du MJ
      </label>
      <label for="<?= $uid ?>_ordre">Position</label>
      <input type="number" id="<?= $uid ?>_ordre" class="form-control form-control--sm"
             value="<?= (int)$tab['tab_ecran_ordre'] ?>" min="0" max="999">
    </div>

    <div class="form-group form-group--inline">
      <label class="form-check-label">
        <input type="checkbox" id="<?= $uid ?>_visible" value="1"
          <?= $tab['tab_visible'] ? 'checked' : '' ?>>
        Visible (décocher = brouillon)
      </label>
    </div>

    <?php // ---- Aperçu ---- ?>
    <div class="form-group">
      <button type="button" class="btn btn--sm btn--secondary" id="<?= $uid ?>_btn_apercu">
        <i class="fa fa-eye"></i> Aperçu
      </button>
      <div class="reg-tab-apercu" id="<?= $uid ?>_apercu"></div>
    </div>

    <div class="form-actions">
      <button type="button" class="btn btn--primary" id="<?= $uid ?>_btn_save">
        <i class="fa fa-save"></i> Enregistrer
      </button>
      <button type="button" class="btn btn--secondary" onclick="fermerModification()">
        Annuler
      </button>
    </div>

  </div>
</div>

<script>
  (function () {
    var UID        = <?= json_encode($uid) ?>;
    var URL_ENREG  = <?= json_encode(BASE_URL . '/regles/tableaux-enregistrement.php?ajax=1') ?>;
    var URL_APERCU = <?= json_encode(BASE_URL . '/include/ajax/tableau-apercu.php') ?>;
    var CSRF_TOKEN = <?= json_encode(csrfToken()) ?>;

    function val(suffixe) {
      var el = document.getElementById(UID + suffixe);
      if (!el) return '';
      return el.type === 'checkbox' ? (el.checked ? '1' : '0') : el.value;
    }

    function collecter() {
      return {
        tab_id:          val('_id'),
        tab_nom:         val('_nom').trim(),
        tab_slug:        val('_slug').trim(),
        tab_contenu:     val('_contenu'),
        tab_align:       val('_align'),
        tab_note:        val('_note'),
        tab_res_id:      val('_res'),
        tab_ecran_mj:    val('_ecran'),
        tab_ecran_ordre: val('_ordre'),
        tab_visible:     val('_visible')
      };
    }

    // ---- Aperçu ----
    document.getElementById(UID + '_btn_apercu').addEventListener('click', function () {
      var cible = document.getElementById(UID + '_apercu');
      cible.innerHTML = '<div class="loading"><i class="fa fa-spinner fa-spin"></i></div>';

      var data = new URLSearchParams({
        csrf_token:  CSRF_TOKEN,
        tab_nom:     val('_nom'),
        tab_contenu: val('_contenu'),
        tab_align:   val('_align'),
        tab_note:    val('_note')
      });

      fetch(URL_APERCU, {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: data.toString()
      })
      .then(function (r) { return r.text(); })
      .then(function (html) { cible.innerHTML = html; })
      .catch(function (e) { cible.innerHTML = '<p class="erreur">Erreur réseau : ' + e + '</p>'; });
    });

    // ---- Enregistrement ----
    document.getElementById(UID + '_btn_save').addEventListener('click', function () {
      var champs = collecter();
      if (!champs.tab_nom)     { alert('Le nom est obligatoire.'); return; }
      if (!champs.tab_contenu.trim()) { alert('Le contenu est obligatoire.'); return; }

      champs.action     = 'sauvegarder';
      champs.csrf_token = CSRF_TOKEN;

      fetch(URL_ENREG, {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: new URLSearchParams(champs).toString()
      })
      .then(function (r) { return r.json(); })
      .then(function (res) {
        if (!res.ok) { alert(res.erreur || 'Erreur lors de l\'enregistrement.'); return; }
        fermerModification();
        window.location.reload();
      })
      .catch(function (e) { alert('Erreur réseau : ' + e); });
    });
  }());
</script>
