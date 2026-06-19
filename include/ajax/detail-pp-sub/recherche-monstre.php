<?php
// include/ajax/detail-pp-sub/recherche-monstre.php
// Sous-panneau de recherche de monstre pour le sélecteur d'opposition.
// Affiché au-dessus de #modification (formulaire opposition déjà ouvert).
// Paramètres GET : camp_id (int, requis)

require_once __DIR__ . '/../../db.php';
require_once __DIR__ . '/../../auth.php';
require_once __DIR__ . '/../../helpers.php';

requireAuth();

$camp_id = intParam($_GET['camp_id'] ?? 0);
if (!$camp_id || !isMJ($db, $camp_id)):
  http_response_code(403);
  echo '<p class="erreur">Accès refusé.</p>';
  exit;
endif;

$stmt = $db->prepare('SELECT camp_ruleset_var_id FROM dd_campagnes WHERE camp_id = ? AND camp_supprime = 0');
$stmt->execute([$camp_id]);
$ruleset_var_id = (int)$stmt->fetchColumn();

// Catégories du ruleset, pour le filtre déroulant
$stmt_cat = $db->prepare('
  SELECT mocat_id, mocat_nom FROM dd_monstres_categories
  WHERE  mocat_ruleset_var_id = ? ORDER BY mocat_nom ASC
');
$stmt_cat->execute([$ruleset_var_id]);
$categories = $stmt_cat->fetchAll();

$url_recherche = BASE_URL . '/include/ajax/recherche-monstre.php';
?>

<div class="rech-mo" data-camp-id="<?= $camp_id ?>">

  <h3 class="modif-form__title">Choisir un monstre</h3>

  <div class="rech-mo__filtres">
    <input type="text" id="rech-mo-q" class="rech-mo__input"
           placeholder="Rechercher par nom…" autocomplete="off">

    <select id="rech-mo-cat" class="rech-mo__select">
      <option value="0">Toutes catégories</option>
      <?php foreach ($categories as $cat): ?>
        <option value="<?= (int)$cat['mocat_id'] ?>"><?= h($cat['mocat_nom']) ?></option>
      <?php endforeach ?>
    </select>
  </div>

  <div id="rech-mo-resultats" class="rech-mo__resultats">
    <p class="text-muted">Tapez un nom ou choisissez une catégorie pour lancer la recherche.</p>
  </div>

</div>

<script>
(function() {
  'use strict';

  const CAMP_ID   = <?= $camp_id ?>;
  const URL_RECH  = <?= json_encode($url_recherche) ?>;
  let debounceTimer = null;

  const qEl   = document.getElementById('rech-mo-q');
  const catEl = document.getElementById('rech-mo-cat');
  const resEl = document.getElementById('rech-mo-resultats');

  function lancerRecherche() {
    const q       = qEl.value.trim();
    const mocatId = catEl.value;

    if (!q && mocatId === '0') {
      resEl.innerHTML = '<p class="text-muted">Tapez un nom ou choisissez une catégorie pour lancer la recherche.</p>';
      return;
    }

    resEl.innerHTML = '<p class="text-muted"><i class="fa fa-spinner fa-spin"></i> Recherche…</p>';

    const params = new URLSearchParams({ camp_id: CAMP_ID, q: q, mocat_id: mocatId });

    fetch(URL_RECH + '?' + params.toString())
      .then(r => r.json())
      .then(data => {
        if (!data.resultats || data.resultats.length === 0) {
          resEl.innerHTML = '<p class="text-muted">Aucun monstre trouvé.</p>';
          return;
        }
        resEl.innerHTML = data.resultats.map(mo => `
          <div class="rech-mo__ligne" data-mo-id="${mo.mo_id}"
               onclick="rechMoSelectionner(${mo.mo_id}, ${JSON.stringify(mo.mo_nom)})">
            <span class="rech-mo__nom">${escHtml(mo.mo_nom)}</span>
            <span class="rech-mo__meta">
              ${mo.mocat_nom ? escHtml(mo.mocat_nom) : ''}
              ${mo.mo_fp_id ? ' · FP ' + escHtml(mo.mo_fp_id) : ''}
            </span>
          </div>
        `).join('');
      })
      .catch(() => {
        resEl.innerHTML = '<p class="erreur">Erreur lors de la recherche.</p>';
      });
  }

  function escHtml(s) {
    const d = document.createElement('div');
    d.textContent = s;
    return d.innerHTML;
  }

  qEl.addEventListener('input', () => {
    clearTimeout(debounceTimer);
    debounceTimer = setTimeout(lancerRecherche, 300);
  });
  catEl.addEventListener('change', lancerRecherche);

  qEl.focus();

})();

// Appelée au clic sur un résultat — remplit le formulaire opposition ouvert
// dans #modification (sous-jacent) puis ferme le sous-panneau.
function rechMoSelectionner(moId, moNom) {
  const moIdField  = document.getElementById('opp_mo_id');
  const moNomField = document.getElementById('opp_mo_nom_affiche');
  if (moIdField)  moIdField.value = moId;
  if (moNomField) moNomField.textContent = moNom;
  if (typeof oppositionForm !== 'undefined' && oppositionForm.chargerDepuisMonstre) {
    oppositionForm.chargerDepuisMonstre(moId);
  }
  fermerSubPanel();
}
</script>
