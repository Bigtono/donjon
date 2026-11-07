<?php
// include/ajax/ecran-mj.php — Écran du MJ d'une campagne (SP-TB8).
//
// Paramètres GET :
//   camp_id (int)    — campagne (MJ ou admin seulement)
//   vue     (string) — absente   : HTML de la surcouche, disposition enregistrée
//                      elements : JSON {ok, html} — tableaux désignés par ids
//                      proposee : JSON {ok, html} — sélection tab_ecran_mj = 1
//                      camp     : JSON {ok, html, colonnes} — écran de la campagne from
//   ids     (string) — vue=elements : ids séparés par des virgules
//   from    (int)    — vue=camp : campagne source (même ruleset, même MJ sauf admin)
//
// Les vues JSON ne font que préremplir le client : rien n'est écrit avant
// l'action enregistrerEcranMJ de campagnes/enregistrement.php.
//
// Référence : doc/ARCHITECTURE_0_REFERENCE.md §9c (Écran du MJ)

require_once __DIR__ . '/../db.php';
require_once __DIR__ . '/../auth.php';
require_once __DIR__ . '/../helpers.php';
require_once __DIR__ . '/../ecran-mj.php';

requireAuth();

$camp_id = intParam($_GET['camp_id'] ?? 0);
$vue     = strParam($_GET['vue'] ?? '');
$camp    = $camp_id ? chargerCampagneEcran($db, $camp_id) : null;

function ecranMJJson(array $data): void
{
  header('Content-Type: application/json');
  echo json_encode($data);
  exit;
}

if (!$camp || !isMJ($db, $camp_id)):
  http_response_code(403);
  if ($vue !== '') ecranMJJson(['ok' => false, 'erreur' => 'Accès refusé.']);
  echo '<p class="erreur">Campagne introuvable ou accès refusé.</p>';
  exit;
endif;

$ruleset_id  = (int)$camp['camp_ruleset_var_id'];
$nb_colonnes = ecranMJBornerColonnes((int)$camp['camp_ecran_colonnes']);

// ── Vues JSON (préremplissage) ─────────────────────────────────────────────
if ($vue === 'elements'):
  $ids = explode(',', (string)($_GET['ids'] ?? ''));
  $tab = chargerTableauxEcran($db, $ids, $ruleset_id);
  ecranMJJson(['ok' => true, 'html' => rendreElementsEcranMJ($db, $tab, $camp_id, $ruleset_id)]);
endif;

if ($vue === 'proposee'):
  $nb  = ecranMJBornerColonnes(intParam($_GET['colonnes'] ?? $nb_colonnes));
  $tab = chargerSelectionProposee($db, $ruleset_id, $nb);
  ecranMJJson(['ok' => true, 'html' => rendreElementsEcranMJ($db, $tab, $camp_id, $ruleset_id)]);
endif;

if ($vue === 'camp'):
  $from     = intParam($_GET['from'] ?? 0);
  $source   = $from ? chargerCampagneEcran($db, $from) : null;
  // Même ruleset obligatoire : les tableaux sont propres à un ruleset.
  if (!$source || $from === $camp_id || !isMJ($db, $from)
      || (int)$source['camp_ruleset_var_id'] !== $ruleset_id):
    ecranMJJson(['ok' => false, 'erreur' => 'Campagne source introuvable ou incompatible.']);
  endif;
  $tab = chargerEcranMJ($db, $from, $ruleset_id);
  ecranMJJson([
    'ok'       => true,
    'html'     => rendreElementsEcranMJ($db, $tab, $camp_id, $ruleset_id),
    'colonnes' => ecranMJBornerColonnes((int)$source['camp_ecran_colonnes']),
  ]);
endif;

if ($vue !== ''):
  ecranMJJson(['ok' => false, 'erreur' => 'Vue inconnue.']);
endif;

// ── Surcouche complète ─────────────────────────────────────────────────────
$tableaux = chargerEcranMJ($db, $camp_id, $ruleset_id);
$stmt = $db->prepare('
  SELECT COUNT(*) FROM dd_tableaux
  WHERE  tab_ruleset_var_id = ? AND tab_ecran_mj = 1 AND tab_visible = 1
');
$stmt->execute([$ruleset_id]);
$nb_proposes = (int)$stmt->fetchColumn();
?>
<div class="ecran-mj__barre">
  <h2 class="ecran-mj__titre">
    <i class="fa fa-chalkboard" aria-hidden="true"></i>
    Écran du MJ
    <span class="ecran-mj__campagne"><?= h($camp['camp_nom']) ?></span>
  </h2>

  <div class="ecran-mj__actions ecran-mj__actions--consult">
    <button type="button" class="btn btn-secondary btn-sm" data-ecran-action="organiser">
      <i class="fa fa-th-large" aria-hidden="true"></i> Organiser
    </button>
  </div>

  <div class="ecran-mj__actions ecran-mj__actions--orga">
    <label class="ecran-mj__colonnes">
      Colonnes
      <select class="form-control" data-ecran-champ="colonnes">
        <?php for ($n = ECRAN_MJ_COLONNES_MIN; $n <= ECRAN_MJ_COLONNES_MAX; $n++): ?>
          <option value="<?= $n ?>"<?= $n === $nb_colonnes ? ' selected' : '' ?>><?= $n ?></option>
        <?php endfor ?>
      </select>
    </label>
    <button type="button" class="btn btn-secondary btn-sm" data-ecran-action="ajouter">
      <i class="fa fa-plus" aria-hidden="true"></i> Ajouter des tableaux
    </button>
    <button type="button" class="btn btn-secondary btn-sm" data-ecran-action="dupliquer">
      <i class="fa fa-copy" aria-hidden="true"></i> Dupliquer depuis une campagne…
    </button>
    <button type="button" class="btn btn-secondary btn-sm" data-ecran-action="annuler">
      <i class="fa fa-undo" aria-hidden="true"></i> Annuler
    </button>
    <button type="button" class="btn btn-primary btn-sm" data-ecran-action="enregistrer">
      <i class="fa fa-save" aria-hidden="true"></i> Enregistrer
    </button>
  </div>

  <button type="button" class="ecran-mj__fermer" data-ecran-action="fermer" title="Fermer (Échap)">
    <i class="fa fa-times" aria-hidden="true"></i>
  </button>
</div>

<div class="ecran-mj__corps">

  <div class="ecran-mj__vide">
    <p>Aucun tableau sur l'écran de cette campagne.</p>
    <div class="ecran-mj__vide-actions">
      <?php if ($nb_proposes > 0): ?>
        <button type="button" class="btn btn-secondary btn-sm" data-ecran-action="proposee">
          <i class="fa fa-star" aria-hidden="true"></i>
          Reprendre la sélection proposée (<?= $nb_proposes ?>)
        </button>
      <?php endif ?>
      <button type="button" class="btn btn-secondary btn-sm" data-ecran-action="ajouter">
        <i class="fa fa-plus" aria-hidden="true"></i> Ajouter des tableaux
      </button>
      <button type="button" class="btn btn-secondary btn-sm" data-ecran-action="dupliquer">
        <i class="fa fa-copy" aria-hidden="true"></i> Dupliquer depuis une campagne…
      </button>
    </div>
  </div>

  <div class="ecran-mj__grille"><?= rendreElementsEcranMJ($db, $tableaux, $camp_id, $ruleset_id) ?></div>

</div>
<script type="application/json" class="ecran-mj__config"><?= json_encode([
  'campId'   => $camp_id,
  'colonnes' => $nb_colonnes,
], JSON_HEX_TAG) ?></script>
