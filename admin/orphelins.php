<?php
// admin/orphelins.php — Rapport des données orphelines (SP-AD6d), lecture seule
// Chaque relation de ressourceRelations() (include/ressource-suppression.php) est
// contrôlée : lignes qui référencent un id inexistant, contenu dont la ressource n'existe
// plus, capacités spéciales rattachées à rien. Aucun nettoyage ici : il passe par une
// migration dédiée, validée à part (SP-AD6e).
require_once '../include/db.php';
require_once '../include/auth.php';
require_once '../include/helpers.php';
require_once '../include/ressource-suppression.php';

requireAdmin();

$page_title = 'Données orphelines';
$js_module  = 'admin';
$css_module = 'admin';

$lignes = ressourceRapportOrphelins($db);
usort($lignes, fn($a, $b) => $b['nb'] <=> $a['nb']);
$total = array_sum(array_column($lignes, 'nb'));

require_once '../include/header.php';
?>

<div class="flex-between mb-md">
  <h1>Données orphelines</h1>
  <a href="<?= h(BASE_URL) ?>/admin/index.php" class="btn btn-secondary btn-sm">
    <i class="fa fa-arrow-left"></i> Admin
  </a>
</div>

<p class="text-muted">
  Lignes de la base qui pointent vers une entrée qui n'existe plus. Ce rapport ne modifie rien ;
  le nettoyage se fait par une migration dédiée.
</p>

<?php if ($total === 0): ?>
  <p><i class="fa fa-check-circle"></i> Aucune donnée orpheline.</p>
<?php else: ?>
  <p><strong><?= $total ?></strong> ligne(s) orpheline(s) au total.</p>
<?php endif ?>

<div class="comp-liste-wrapper">
  <table class="table-std">
    <thead>
      <tr>
        <th>Relation</th>
        <th class="col-secondary">Colonne</th>
        <th class="col-secondary">Cible</th>
        <th>Orphelins</th>
      </tr>
    </thead>
    <tbody>
      <?php foreach ($lignes as $l): ?>
        <tr<?= $l['nb'] === 0 ? ' class="text-muted"' : '' ?>>
          <td><?= h($l['libelle']) ?></td>
          <td class="col-secondary"><code><?= h($l['relation']) ?></code></td>
          <td class="col-secondary"><code><?= h($l['cible']) ?></code></td>
          <td>
            <?php if ($l['nb'] > 0): ?>
              <span class="badge badge--count"><?= (int)$l['nb'] ?></span>
            <?php else: ?>
              0
            <?php endif ?>
          </td>
        </tr>
      <?php endforeach ?>
    </tbody>
  </table>
</div>

<?php require_once '../include/footer.php'; ?>
