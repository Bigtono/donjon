<?php
// include/ajax/detail-pp-sub/ecran-mj-picker.php — Ajout de tableaux à l'écran du MJ (SP-TB8e).
//
// S'affiche dans #detail-pp-sub (300), au-dessus de la surcouche #ecran-mj (190).
// Distinct de tableaux-picker.php : celui-ci est réservé aux éditeurs du
// compendium et insère un tag dans TinyMCE, alors qu'ici tout MJ coche des
// tableaux à poser sur son écran.
//
// Le filtrage (texte, catégorie) se fait côté client : recharger le panneau
// ferait perdre les cases déjà cochées.
//
// Paramètres GET :
//   camp_id (int)    — campagne (MJ ou admin seulement)
//   exclus  (string) — ids déjà présents sur l'écran (état client, non enregistré)

require_once __DIR__ . '/../../db.php';
require_once __DIR__ . '/../../auth.php';
require_once __DIR__ . '/../../helpers.php';
require_once __DIR__ . '/../../ecran-mj.php';

requireAuth();

$camp_id = intParam($_GET['camp_id'] ?? 0);
$camp    = $camp_id ? chargerCampagneEcran($db, $camp_id) : null;
if (!$camp || !isMJ($db, $camp_id)):
  http_response_code(403);
  echo '<p class="erreur">Accès refusé.</p>';
  exit;
endif;

$exclus = array_flip(array_filter(
  array_map('intval', explode(',', (string)($_GET['exclus'] ?? ''))),
  fn($v) => $v > 0
));

$categories = chargerCategoriesTableaux($db);
$stmt = $db->prepare('
  SELECT tab_id, tab_nom, tab_slug, tab_tabc_id, tab_ecran_mj
  FROM   dd_tableaux
  WHERE  tab_ruleset_var_id = ? AND tab_visible = 1
  ORDER  BY tab_nom
');
$stmt->execute([(int)$camp['camp_ruleset_var_id']]);
$tableaux = array_values(array_filter(
  $stmt->fetchAll(),
  fn($t) => !isset($exclus[(int)$t['tab_id']])
));
?>
<div class="ecran-mj-picker">

  <h3 class="overlay-titre">Ajouter des tableaux à l'écran</h3>

  <?php if (empty($tableaux)): ?>
    <p class="text-muted">Tous les tableaux disponibles sont déjà sur l'écran.</p>
  <?php else: ?>
    <div class="ecran-mj-picker__filtres">
      <input type="text" class="form-control" data-picker-champ="q"
             placeholder="Filtrer par nom…" autocomplete="off">
      <select class="form-control" data-picker-champ="tabc" aria-label="Catégorie">
        <option value="0">Toutes catégories</option>
        <?php foreach ($categories as $tabc_id => $tabc_nom): ?>
          <option value="<?= (int)$tabc_id ?>"><?= h($tabc_nom) ?></option>
        <?php endforeach ?>
      </select>
    </div>

    <ul class="ecran-mj-picker__liste">
      <?php foreach ($tableaux as $t): ?>
        <li class="ecran-mj-picker__item"
            data-nom="<?= h(mb_strtolower((string)$t['tab_nom'])) ?>"
            data-tabc="<?= (int)$t['tab_tabc_id'] ?>">
          <label>
            <input type="checkbox" value="<?= (int)$t['tab_id'] ?>">
            <span class="ecran-mj-picker__nom"><?= h($t['tab_nom']) ?></span>
            <?php if ($t['tab_ecran_mj']): ?>
              <i class="fa fa-star ecran-mj-picker__propose" title="Proposé pour l'écran du MJ"></i>
            <?php endif ?>
            <?php if (isset($categories[(int)$t['tab_tabc_id']])): ?>
              <span class="ecran-mj-picker__meta"><?= h($categories[(int)$t['tab_tabc_id']]) ?></span>
            <?php endif ?>
          </label>
        </li>
      <?php endforeach ?>
    </ul>

    <div class="ecran-mj-picker__pied">
      <span class="ecran-mj-picker__compte">0 sélectionné</span>
      <button type="button" class="btn btn-secondary btn-sm" onclick="fermerSubPanel()">Fermer</button>
      <button type="button" class="btn btn-primary btn-sm" data-picker-action="ajouter" disabled>
        <i class="fa fa-plus" aria-hidden="true"></i> Ajouter
      </button>
    </div>
  <?php endif ?>

</div>

<script>
  (function () {
    var racine = document.querySelector('.ecran-mj-picker');
    if (!racine) return;
    var champ  = racine.querySelector('[data-picker-champ="q"]');
    var tabc   = racine.querySelector('[data-picker-champ="tabc"]');
    var bouton = racine.querySelector('[data-picker-action="ajouter"]');
    var compte = racine.querySelector('.ecran-mj-picker__compte');
    if (!bouton) return;

    function cochees() {
      return Array.from(racine.querySelectorAll('input[type="checkbox"]:checked'))
        .map(function (c) { return c.value; });
    }

    function filtrer() {
      var q = (champ.value || '').trim().toLowerCase();
      var c = tabc.value;
      racine.querySelectorAll('.ecran-mj-picker__item').forEach(function (li) {
        var ok = (q === '' || li.getAttribute('data-nom').indexOf(q) !== -1)
              && (c === '0' || li.getAttribute('data-tabc') === c);
        li.hidden = !ok;
      });
    }

    champ.addEventListener('input', filtrer);
    tabc.addEventListener('change', filtrer);
    champ.focus();

    racine.addEventListener('change', function (e) {
      if (e.target.type !== 'checkbox') return;
      var n = cochees().length;
      compte.textContent = n + (n > 1 ? ' sélectionnés' : ' sélectionné');
      bouton.disabled = n === 0;
    });

    bouton.addEventListener('click', function () {
      var ids = cochees();
      if (!ids.length || typeof ecranMJAjouter !== 'function') return;
      fermerSubPanel();
      ecranMJAjouter(ids);
    });
  })();
</script>
