<?php
// admin/import-notes-v1.php — Import des notes de la v1 dans une campagne (SP-NO7, D-NO14).
// Règles d'import : include/notes-import-v1.php. Données : tables de transit dd_v1_*.
// GET  camp_id : campagne cible (recharge les catégories et compétences de son ruleset)
// POST action=importer : camp_id, type_tyno[t], type_comp[t][], tag_nom[t] (CSRF)
require_once '../include/db.php';
require_once '../include/auth.php';
require_once '../include/helpers.php';
require_once '../include/notes-import-v1.php';

requireAdmin();

$url_page = BASE_URL . '/admin/import-notes-v1.php';

// Tables de transit absentes : migration SP-NO7 non jouée
try {
  $nb_total    = (int)$db->query('SELECT COUNT(*) FROM dd_v1_notes')->fetchColumn();
  $nb_importes = (int)$db->query('SELECT COUNT(*) FROM dd_v1_notes WHERE no_importe_no_id IS NOT NULL')->fetchColumn();
} catch (PDOException $e) {
  $nb_total = null;
}

$campagnes = $db->query("
  SELECT camp.camp_id, camp.camp_nom, camp.camp_ruleset_var_id, camp.camp_j_id, j.j_pseudo, var.var_valeur AS ruleset_label
    FROM dd_campagnes camp
    JOIN dd_variables var ON var.var_id = camp.camp_ruleset_var_id
    LEFT JOIN dd_joueurs j ON j.j_id = camp.camp_j_id
   WHERE camp.camp_supprime = 0
ORDER BY camp.camp_nom
")->fetchAll();
$camps_par_id = array_column($campagnes, null, 'camp_id');

/** Catégories et compétences du ruleset d'une campagne */
function referentielsImportV1(PDO $db, int $ruleset_id): array {
  $stmt = $db->prepare('SELECT tyno_id, tyno_nom FROM dd_types_notes WHERE tyno_ruleset_var_id = ? ORDER BY tyno_ordre, tyno_nom');
  $stmt->execute([$ruleset_id]);
  $categories = $stmt->fetchAll(PDO::FETCH_KEY_PAIR);
  $stmt = $db->prepare('SELECT comp_id, comp_nom FROM dd_competences WHERE comp_ruleset_var_id = ? ORDER BY comp_nom');
  $stmt->execute([$ruleset_id]);
  $competences = $stmt->fetchAll(PDO::FETCH_KEY_PAIR);
  return [$categories, $competences];
}

// ============================================================
// IMPORT (POST)
// ============================================================

if ($_SERVER['REQUEST_METHOD'] === 'POST' && ($_POST['action'] ?? '') === 'importer' && $nb_total !== null):
  verifyCsrf();
  $camp_id = intParam($_POST['camp_id'] ?? 0);
  $retour  = $url_page . '?camp_id=' . $camp_id;
  $erreur  = null;
  $camp    = $camps_par_id[$camp_id] ?? null;

  if (!$camp):
    $erreur = 'Campagne introuvable.';
  else:
    [$categories, $competences] = referentielsImportV1($db, (int)$camp['camp_ruleset_var_id']);
    $choix = [];
    foreach (array_keys(typesNotesV1($db)) as $t):
      $tyno_id  = intParam($_POST['type_tyno'][$t] ?? 0);
      $comp_ids = array_values(array_unique(array_filter(array_map('intval', (array)($_POST['type_comp'][$t] ?? [])))));
      if (!isset($categories[$tyno_id])):
        $erreur = 'Type v1 n° ' . $t . ' : catégorie absente du ruleset de la campagne.';
        break;
      endif;
      if (empty($comp_ids) || array_diff($comp_ids, array_keys($competences))):
        $erreur = 'Type v1 n° ' . $t . ' : au moins une compétence du ruleset de la campagne est requise.';
        break;
      endif;
      $choix[$t] = ['tyno_id' => $tyno_id, 'comp_ids' => $comp_ids];
    endforeach;
  endif;

  if ($erreur === null):
    $noms_tags = [];
    foreach (array_keys(tagsNotesV1($db)) as $t) $noms_tags[$t] = strParam($_POST['tag_nom'][$t] ?? '');
    try {
      $db->beginTransaction();
      $bilan = importerNotesV1($db, $camp_id, (int)$camp['camp_j_id'], $choix, $noms_tags);
      $db->commit();
      $_SESSION['flash_message'] = ['type' => 'success', 'text' => sprintf(
        '%d note(s) importée(s) dans « %s » : %d section(s) conditionnée(s), %d lien(s) de mots-clés, %d bloc(s) vide(s) écarté(s). Aucun destinataire : à diffuser depuis la liste des notes.',
        $bilan['notes'], $camp['camp_nom'], $bilan['sections'], $bilan['liens_tags'], $bilan['blocs_vides'])];
    } catch (Exception $e) {
      $db->rollBack();
      error_log('importerNotesV1 : ' . $e->getMessage());
      $erreur = 'Erreur pendant l\'import, rien n\'a été enregistré.';
    }
  endif;

  if ($erreur !== null) $_SESSION['flash_message'] = ['type' => 'error', 'text' => $erreur];
  header('Location: ' . $retour);
  exit;
endif;

// ============================================================
// AFFICHAGE
// ============================================================

$camp_id = intParam($_GET['camp_id'] ?? 0);
$camp    = $camps_par_id[$camp_id] ?? null;
$types   = $tags = $props = $categories = $competences = [];
if ($nb_total !== null && $camp):
  $rep = (int)$camp['camp_ruleset_var_id'] === 2 ? 'DD2024' : 'DD3.5';
  [$categories, $competences] = referentielsImportV1($db, (int)$camp['camp_ruleset_var_id']);
  $types = typesNotesV1($db);
  $tags  = tagsNotesV1($db);
  $props = propositionsImportV1($types, $categories, $competences, $rep);
endif;

$page_title = 'Import des notes v1';
$css_module = 'admin';
require_once '../include/header.php';
?>

<div class="flex-between mb-md">
  <h1>Import des notes v1</h1>
  <a href="<?= BASE_URL ?>/admin/index.php" class="btn btn-secondary btn-sm">
    <i class="fa fa-arrow-left"></i> Admin
  </a>
</div>

<?php if ($nb_total === null): ?>
  <p class="text-muted">Les tables de transit sont absentes : jouer d'abord la migration
    <code>sql/2026-11-01_sp-no7_notes_v1_transit.sql</code> (écran Migrations SQL).</p>
<?php else: ?>

  <p class="text-muted text-sm">
    <?= $nb_total ?> notes v1 en transit, dont <strong><?= $nb_importes ?></strong> déjà importée<?= $nb_importes > 1 ? 's' : '' ?>.
    Un import ne reprend que les notes non encore importées. Les blocs DD 10 forment le texte commun ; chaque bloc
    de DD supérieur devient une section conditionnée au même DD par les compétences du type. Images retirées ;
    aucun destinataire n'est affecté.
  </p>

  <form method="GET" action="" class="import-v1__campagne">
    <label for="camp_id"><strong>Campagne cible</strong></label>
    <select id="camp_id" name="camp_id" onchange="this.form.submit()">
      <option value="">— Choisir —</option>
      <?php foreach ($campagnes as $c): ?>
        <option value="<?= (int)$c['camp_id'] ?>" <?= (int)$c['camp_id'] === $camp_id ? 'selected' : '' ?>>
          <?= h($c['camp_nom']) ?> (<?= h($c['ruleset_label']) ?>, MJ <?= h($c['j_pseudo'] ?? '?') ?>)
        </option>
      <?php endforeach ?>
    </select>
  </form>

  <?php if ($camp && $nb_importes < $nb_total): ?>
    <form method="POST" action="">
      <?= csrfField() ?>
      <input type="hidden" name="action" value="importer">
      <input type="hidden" name="camp_id" value="<?= $camp_id ?>">

      <h2>Types v1 → catégorie et compétences</h2>
      <table class="table-dd import-v1__table">
        <thead>
          <tr><th>Type v1</th><th>Catégorie</th><th>Compétence</th><th>ou</th></tr>
        </thead>
        <tbody>
          <?php foreach ($types as $t => $info): ?>
            <tr>
              <td>
                <details>
                  <summary>n° <?= $t ?> — <?= count($info['titres']) ?> note<?= count($info['titres']) > 1 ? 's' : '' ?></summary>
                  <small class="text-muted"><?= h(implode(' · ', $info['titres'])) ?></small>
                </details>
              </td>
              <td>
                <select name="type_tyno[<?= $t ?>]">
                  <?php foreach ($categories as $id => $nom): ?>
                    <option value="<?= (int)$id ?>" <?= (int)$id === $props[$t]['tyno_id'] ? 'selected' : '' ?>><?= h($nom) ?></option>
                  <?php endforeach ?>
                </select>
              </td>
              <?php for ($k = 0; $k < 2; $k++): ?>
                <td>
                  <select name="type_comp[<?= $t ?>][]">
                    <option value=""><?= $k === 0 ? '— Choisir —' : '—' ?></option>
                    <?php foreach ($competences as $id => $nom): ?>
                      <option value="<?= (int)$id ?>" <?= (int)$id === ($props[$t]['comp_ids'][$k] ?? 0) ? 'selected' : '' ?>><?= h(trim($nom)) ?></option>
                    <?php endforeach ?>
                  </select>
                </td>
              <?php endfor ?>
            </tr>
          <?php endforeach ?>
        </tbody>
      </table>

      <h2>Mots-clés v1</h2>
      <p class="text-muted text-sm">Leurs libellés ne figurent pas dans l'export : nommer chacun d'après ses notes.
        Un mot-clé laissé vide n'est pas importé.</p>
      <table class="table-dd import-v1__table">
        <thead>
          <tr><th>Mot-clé v1</th><th>Notes</th><th>Libellé</th></tr>
        </thead>
        <tbody>
          <?php foreach ($tags as $t => $titres): ?>
            <tr>
              <td>n° <?= $t ?></td>
              <td><small><?= h(implode(' · ', $titres)) ?></small></td>
              <td><input type="text" name="tag_nom[<?= $t ?>]" maxlength="80" placeholder="Libellé"></td>
            </tr>
          <?php endforeach ?>
        </tbody>
      </table>

      <div class="modif-actions">
        <button type="submit" class="btn btn-primary">
          <i class="fa fa-file-import"></i> Importer <?= $nb_total - $nb_importes ?> note<?= $nb_total - $nb_importes > 1 ? 's' : '' ?> dans « <?= h($camp['camp_nom']) ?> »
        </button>
      </div>
    </form>
  <?php elseif ($camp): ?>
    <p>Toutes les notes v1 sont déjà importées.</p>
  <?php endif ?>

<?php endif ?>

<?php require_once '../include/footer.php'; ?>
