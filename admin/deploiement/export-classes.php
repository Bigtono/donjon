<?php
// admin/deploiement/export-classes.php — Export de classes vers la production (SP-XC2)
//
// Choix des classes à recopier en production. « Générer » écrit une migration
// dans sql/ (export-classes-lib.php) : le prochain déploiement l'envoie et la
// fait jouer par le serveur. « Aperçu » montre le script sans rien écrire.
// Module local : protégé par garde.php, jamais transféré.
require_once __DIR__ . '/garde.php';
require_once __DIR__ . '/export-classes-lib.php';

$ruleset = intParam($_GET['ruleset'] ?? ($_SESSION['ruleset_var_id'] ?? 2));
if (!isset(XC_RULESETS[$ruleset])):
  $ruleset = 2;
endif;

$export     = null;
$fichier    = null;
$erreur     = null;
$coches     = [];
$listeSorts = true;

if ($_SERVER['REQUEST_METHOD'] === 'POST'):
  verifyCsrf();
  $coches     = array_map('intval', (array)($_POST['cla'] ?? []));
  $listeSorts = !empty($_POST['liste_sorts']);
  $action     = strParam($_POST['action'] ?? '');

  try {
    $export = xcGenerer($db, $coches, $listeSorts);
    if ($action === 'generer'):
      $fichier = xcEcrireMigration($db, $export);
      $coches  = [];
    endif;
  } catch (Throwable $e) {
    $erreur = $e->getMessage();
  }
endif;

$classes = xcClassesExportables($db, $ruleset);

$page_title = 'Export de classes';
$css_module = 'admin';

require_once __DIR__ . '/../../include/header.php';
?>

<div class="flex-between mb-md">
  <h1>Export de classes</h1>
  <a href="<?= BASE_URL ?>/admin/deploiement/index.php" class="btn btn-secondary">
    <i class="fa fa-arrow-left"></i> Déploiement
  </a>
</div>

<p class="text-muted mb-md">
  Recopie en production les classes cochées avec toutes leurs données : fiche, table de progression,
  capacités spéciales, compétences, sorts toujours préparés et liste de sorts. Le fichier est écrit
  dans <code>sql/</code> comme une migration : le prochain déploiement l'envoie et la fait jouer par le
  serveur. Chaque classe est retrouvée en production par son nom, puis écrasée ; sa ressource, sa classe
  parente, ses sorts et ses compétences doivent déjà y exister, sinon rien n'est écrit.
</p>

<?php if ($erreur !== null): ?>
  <div class="flash-message flash-message--error"><?= h($erreur) ?></div>
<?php endif ?>

<?php if ($fichier !== null): ?>
  <div class="flash-message flash-message--success">
    Migration <code><?= h($fichier) ?></code> écrite et marquée comme appliquée en local.
    Elle partira au prochain déploiement.
  </div>
<?php endif ?>

<div class="deploiement-sections">

  <?php if ($export !== null): ?>
    <section class="deploiement-section">
      <h2><?= $fichier !== null ? 'Contenu exporté' : 'Aperçu' ?></h2>
      <div class="comp-liste-wrapper">
        <table class="comp-liste">
          <thead>
            <tr>
              <th>Classe</th>
              <th>Niveaux</th>
              <th>Capacités</th>
              <th>Compétences</th>
              <th>Sorts préparés</th>
              <th>Liste de sorts</th>
            </tr>
          </thead>
          <tbody>
            <?php foreach ($export['resume'] as $ligne): ?>
              <tr>
                <td><?= h($ligne['nom']) ?></td>
                <td><?= (int)$ligne['niveaux'] ?></td>
                <td><?= (int)$ligne['capacites'] ?></td>
                <td><?= (int)$ligne['competences'] ?></td>
                <td><?= (int)$ligne['prepares'] ?></td>
                <td><?= $ligne['liste'] === null ? '<span class="text-muted">non incluse</span>' : (int)$ligne['liste'] ?></td>
              </tr>
            <?php endforeach ?>
          </tbody>
        </table>
      </div>
      <details class="deploiement__liste">
        <summary>Script SQL (<?= number_format(strlen($export['sql']) / 1024, 1, ',', ' ') ?> Ko)</summary>
        <pre class="xc-script"><?= h($export['sql']) ?></pre>
      </details>
    </section>
  <?php endif ?>

  <section class="deploiement-section">
    <h2>Classes</h2>

    <form method="GET" action="<?= BASE_URL ?>/admin/deploiement/export-classes.php" class="mb-md">
      <label for="xc_ruleset">Ruleset</label>
      <select id="xc_ruleset" name="ruleset" onchange="this.form.submit()">
        <?php foreach (XC_RULESETS as $id => $libelle): ?>
          <option value="<?= (int)$id ?>"<?= $id === $ruleset ? ' selected' : '' ?>><?= h($libelle) ?></option>
        <?php endforeach ?>
      </select>
    </form>

    <form method="POST" action="<?= BASE_URL ?>/admin/deploiement/export-classes.php?ruleset=<?= (int)$ruleset ?>">
      <?= csrfField() ?>

      <?php if (!$classes): ?>
        <p class="text-muted">Aucune classe dans ce ruleset.</p>
      <?php else: ?>
        <div class="comp-liste-wrapper">
          <table class="comp-liste">
            <thead>
              <tr>
                <th></th>
                <th>Classe</th>
                <th>Type</th>
                <th>Source</th>
                <th>Niveaux</th>
                <th>Capacités</th>
                <th>Sorts</th>
              </tr>
            </thead>
            <tbody>
              <?php foreach ($classes as $classe): ?>
                <?php $id = (int)$classe['cla_id'] ?>
                <tr>
                  <td>
                    <input type="checkbox" id="xc_cla_<?= $id ?>" name="cla[]" value="<?= $id ?>"
                           <?= in_array($id, $coches, true) ? 'checked' : '' ?>>
                  </td>
                  <td>
                    <label for="xc_cla_<?= $id ?>">
                      <?php if ($classe['cla_cla_id']): ?>
                        <span class="text-muted">↳ <?= h((string)$classe['parent_nom']) ?> —</span>
                      <?php endif ?>
                      <?= h($classe['cla_nom']) ?>
                    </label>
                  </td>
                  <td><?= h((string)$classe['clt_nom']) ?></td>
                  <td><?= h($classe['res_nom']) ?></td>
                  <td><?= (int)$classe['nb_niveaux'] ?></td>
                  <td><?= (int)$classe['nb_capacites'] ?></td>
                  <td><?= (int)$classe['nb_sorts'] ?></td>
                </tr>
              <?php endforeach ?>
            </tbody>
          </table>
        </div>

        <p class="mt-md">
          <label>
            <input type="checkbox" name="liste_sorts" value="1"<?= $listeSorts ? ' checked' : '' ?>>
            Inclure la liste de sorts (<code>dd_sortclasse</code>) — décochée, celle de la production reste intacte
          </label>
        </p>
        <p class="form-hint">
          Une sous-classe n'est exportée que si elle est cochée ; sa classe de base doit alors être cochée
          aussi, ou déjà exister en production.
        </p>

        <div class="form-actions">
          <button type="submit" name="action" value="apercu" class="btn btn-secondary">
            <i class="fa fa-eye"></i> Aperçu
          </button>
          <button type="submit" name="action" value="generer" class="btn btn-primary">
            <i class="fa fa-file-export"></i> Générer la migration
          </button>
        </div>
      <?php endif ?>
    </form>
  </section>

</div>

<?php
require_once __DIR__ . '/../../include/footer.php';
?>
