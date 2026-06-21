<?php
// include/ajax/modifier/opposition.php
// Formulaire de création / modification d'une opposition.
// Paramètres GET : id (int) — opp_id (0 = création), re_id (requis si id=0)

require_once __DIR__ . '/../../db.php';
require_once __DIR__ . '/../../auth.php';
require_once __DIR__ . '/../../helpers.php';

requireAuth();

$id    = intParam($_GET['id']    ?? 0);
$re_id = intParam($_GET['re_id'] ?? 0);

$opp = [
  'opp_id'         => 0,
  'opp_nom'        => '',
  'opp_mocat_nom'  => '',
  'opp_stats'      => '',
  'opp_mo_id'      => 0,
  'opp_re_id'      => $re_id,
];
$mo_nom_origine = '';

// Remonte camp_id + ruleset depuis re_id (pour la recherche de monstre)
function getCampCtxFromRe(PDO $db, int $re_id): ?array {
  $stmt = $db->prepare('
    SELECT camp.camp_id, camp.camp_ruleset_var_id
    FROM   dd_rencontres re
    JOIN   dd_scenarios_chapitres scc ON scc.scc_id = re.re_scc_id
    JOIN   dd_scenarios sce  ON sce.sce_id  = scc.scc_sce_id
    JOIN   dd_campagnes camp ON camp.camp_id = sce.sce_camp_id
    WHERE  re.re_id = ? AND re.re_supprime = 0
      AND  scc.scc_supprime = 0 AND sce.sce_supprime = 0 AND camp.camp_supprime = 0
  ');
  $stmt->execute([$re_id]);
  $row = $stmt->fetch();
  return $row ?: null;
}

if ($id > 0):
  $stmt = $db->prepare('
    SELECT opp.*, mo.mo_nom AS mo_nom_origine
    FROM   dd_oppositions opp
    LEFT JOIN dd_monstres mo ON mo.mo_id = opp.opp_mo_id
    WHERE  opp.opp_id = ? AND opp.opp_supprime = 0
  ');
  $stmt->execute([$id]);
  $row = $stmt->fetch();
  if (!$row):
    http_response_code(404);
    echo '<p class="erreur">Opposition introuvable.</p>';
    exit;
  endif;
  $re_id  = (int)$row['opp_re_id'];
  $ctx    = getCampCtxFromRe($db, $re_id);
  if (!$ctx || !isMJ($db, (int)$ctx['camp_id'])):
    http_response_code(403);
    echo '<p class="erreur">Accès refusé.</p>';
    exit;
  endif;
  $opp            = $row;
  $mo_nom_origine = $row['mo_nom_origine'] ?? '(monstre supprimé du compendium)';
else:
  if (!$re_id):
    http_response_code(400);
    echo '<p class="erreur">re_id manquant.</p>';
    exit;
  endif;
  $ctx = getCampCtxFromRe($db, $re_id);
  if (!$ctx || !isMJ($db, (int)$ctx['camp_id'])):
    http_response_code(403);
    echo '<p class="erreur">Accès refusé.</p>';
    exit;
  endif;
endif;

$camp_id = (int)$ctx['camp_id'];
$titre   = $id > 0 ? 'Modifier ' . h($opp['opp_nom']) : 'Nouvelle opposition';

$url_sub_recherche = BASE_URL . '/include/ajax/detail-pp-sub/recherche-monstre.php';
$url_detail_mo     = BASE_URL . '/include/ajax/detail-monstre-json.php';
?>

<div class="modif-form">
  <h3 class="modif-form__title"><?= $titre ?></h3>

  <form id="form-opposition" method="POST"
        action="<?= BASE_URL ?>/campagnes/enregistrement.php?ajax=1">
    <?= csrfField() ?>
    <input type="hidden" name="action"   value="enregistrerOpposition">
    <input type="hidden" name="opp_id"   value="<?= (int)$opp['opp_id'] ?>">
    <input type="hidden" name="re_id"    value="<?= $re_id ?>">
    <input type="hidden" name="opp_mo_id" id="opp_mo_id" value="<?= (int)$opp['opp_mo_id'] ?>">

    <div class="modif-section">
      <div class="modif-section__header">
        <span class="modif-section__label">Monstre d'origine <span class="form-hint">(facultatif)</span></span>
      </div>

      <div class="opp-mo-origine">
        <span id="opp_mo_nom_affiche">
          <?= $opp['opp_mo_id'] ? h($mo_nom_origine) : '— aucun, saisie manuelle —' ?>
        </span>
        <?php if ($id === 0 || !$opp['opp_mo_id']): ?>
          <button type="button" class="btn btn-secondary btn-sm"
                  onclick="actualiserPageSub('<?= $url_sub_recherche ?>', {camp_id:<?= $camp_id ?>})">
            <i class="fa fa-search"></i> Choisir un monstre
          </button>
          <span class="form-hint">Optionnel — laissez vide pour une opposition saisie entièrement à la main.</span>
        <?php else: ?>
          <span class="form-hint">Le monstre d'origine ne peut pas être changé après création.</span>
        <?php endif ?>
      </div>
    </div>

    <div class="modif-section">
      <div class="modif-section__header">
        <span class="modif-section__label">Données de l'opposition</span>
      </div>

      <div class="modif-grid">

        <div class="form-group modif-grid__full">
          <label for="opp_nom">Nom <span class="required">*</span></label>
          <input type="text" id="opp_nom" name="opp_nom"
                 value="<?= h($opp['opp_nom']) ?>" required maxlength="150">
        </div>

        <div class="form-group modif-grid__full">
          <label for="opp_mocat_nom">Catégorie <span class="form-hint">(texte libre)</span></label>
          <input type="text" id="opp_mocat_nom" name="opp_mocat_nom"
                 value="<?= h($opp['opp_mocat_nom'] ?? '') ?>" maxlength="150">
        </div>

        <div class="form-group modif-grid__full">
          <label for="opp_stats">Statistiques</label>
          <textarea id="opp_stats" name="opp_stats" rows="14"
                    style="font-family: monospace;"><?= h($opp['opp_stats'] ?? '') ?></textarea>
        </div>

      </div>
    </div>

    <div class="modif-actions">
      <button type="button" class="btn btn-primary" onclick="oppositionForm.soumettre()">
        <i class="fa fa-save"></i> Enregistrer
      </button>
      <button type="button" class="btn btn-secondary" onclick="fermerModification()">
        <i class="fa fa-times"></i> Annuler
      </button>
    </div>

  </form>
</div>

<script>
(function() {
  'use strict';

  const OPP_ID         = <?= (int)$opp['opp_id'] ?>;
  const RE_ID          = <?= $re_id ?>;
  const CAMP_ID         = <?= $camp_id ?>;
  const URL_OPP_DETAIL  = <?= json_encode(BASE_URL . '/include/ajax/detail-pp-sub/opposition.php') ?>;
  const URL_RE_DETAIL   = <?= json_encode(BASE_URL . '/include/ajax/detail-pp/rencontre.php') ?>;
  const URL_DETAIL_MO   = <?= json_encode($url_detail_mo) ?>;

  // Appelée par detail-pp-sub/recherche-monstre.php après sélection d'un résultat.
  function chargerDepuisMonstre(moId) {
    const params = new URLSearchParams({ id: moId, camp_id: CAMP_ID });
    fetch(URL_DETAIL_MO + '?' + params.toString())
      .then(r => r.json())
      .then(data => {
        if (!data.ok) { alert(data.erreur || 'Erreur de chargement.'); return; }
        document.getElementById('opp_nom').value        = data.monstre.mo_nom        || '';
        document.getElementById('opp_mocat_nom').value   = data.monstre.mocat_nom     || '';
        document.getElementById('opp_stats').value       = data.monstre.mo_stats      || '';
      })
      .catch(err => alert('Erreur : ' + err));
  }

  function soumettre() {
    const form = document.getElementById('form-opposition');
    if (!form) return;

    const nom = document.getElementById('opp_nom').value.trim();
    if (!nom) { alert('Le nom est obligatoire.'); return; }

    // Monstre d'origine optionnel — une opposition peut être saisie entièrement
    // à la main (opp_mo_id reste vide, opp_mo_id POST = '0' = NULL côté serveur).

    fetch(form.getAttribute('action'), { method: 'POST', body: new FormData(form) })
      .then(r => r.json())
      .then(data => {
        if (data.ok) {
          fermerModification();
          if (OPP_ID > 0) {
            actualiserPageSub(URL_OPP_DETAIL, { id: OPP_ID });
          } else {
            naviguerDetailPP(URL_RE_DETAIL, { id: RE_ID });
          }
        } else {
          alert(data.erreur || "Erreur lors de l'enregistrement.");
        }
      })
      .catch(err => alert('Erreur : ' + err));
  }

  window.oppositionForm = { soumettre: soumettre, chargerDepuisMonstre: chargerDepuisMonstre };

})();
</script>
