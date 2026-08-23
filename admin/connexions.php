<?php
// admin/connexions.php — Relevés d'affichage des utilisateurs (SP-RS5)
// Écran de lecture seule : synthèse par palier responsive + journal daté des
// connexions, alimentés par le beacon include/ajax/releve-device.php.
// Objectif : arbitrer les paliers du projet (991 / 768 / 479) sur des mesures
// réelles plutôt que sur des hypothèses.
require_once '../include/db.php';
require_once '../include/auth.php';
require_once '../include/helpers.php';

requireAdmin();

$page_title = 'Relevés d\'affichage';
$css_module = 'admin';

// Expression de rang des paliers — réutilisée pour le regroupement et le tri.
// Bornes alignées sur les media queries réellement déclarées dans les CSS.
const PALIER_SQL = "
  CASE
    WHEN co_vp_w <= 479 THEN 1
    WHEN co_vp_w <= 767 THEN 2
    WHEN co_vp_w <= 991 THEN 3
    ELSE 4
  END
";

$paliers_libelles = [
  1 => '≤ 479 px — smartphone étroit',
  2 => '480 – 767 px — smartphone',
  3 => '768 – 991 px — tablette',
  4 => '≥ 992 px — desktop',
];

// --- Synthèse par palier ----------------------------------------------------
$synthese = $db->query('
  SELECT ' . PALIER_SQL . ' AS palier,
         COUNT(*)                  AS nb_connexions,
         COUNT(DISTINCT co_j_id)   AS nb_joueurs,
         MIN(co_vp_w)              AS vp_min,
         MAX(co_vp_w)              AS vp_max
  FROM   dd_connexions
  WHERE  co_vp_w IS NOT NULL
  GROUP  BY palier
  ORDER  BY palier
')->fetchAll();

$total_releves = 0;
foreach ($synthese as $s):
  $total_releves += (int)$s['nb_connexions'];
endforeach;

// --- Largeurs les plus fréquentes -------------------------------------------
$largeurs = $db->query('
  SELECT co_vp_w, COUNT(*) AS nb, COUNT(DISTINCT co_j_id) AS nb_joueurs
  FROM   dd_connexions
  WHERE  co_vp_w IS NOT NULL
  GROUP  BY co_vp_w
  ORDER  BY nb DESC, co_vp_w ASC
  LIMIT  15
')->fetchAll();

// --- Journal ----------------------------------------------------------------
$journal = $db->query('
  SELECT co.co_id, co.co_date, co.co_vp_w, co.co_vp_h, co.co_dpr,
         co.co_screen_w, co.co_screen_h, co.co_orientation, co.co_touch,
         co.co_plateforme, co.co_langue, co.co_ua,
         j.j_pseudo
  FROM   dd_connexions co
  LEFT   JOIN dd_joueurs j ON j.j_id = co.co_j_id
  ORDER  BY co.co_date DESC
  LIMIT  200
')->fetchAll();

require_once '../include/header.php';
?>

<div class="flex-between mb-md">
  <h1>Relevés d'affichage</h1>
</div>

<p class="text-muted mb-md">
  Un relevé par session authentifiée. Les largeurs sont exprimées en <strong>pixels CSS</strong> —
  ce sont elles qui décident du palier appliqué, pas la définition physique de l'écran.
</p>

<?php if ($total_releves === 0): ?>

  <p class="text-muted">
    Aucun relevé pour le moment. La collecte démarre à la prochaine connexion de chaque
    utilisateur.
  </p>

<?php else: ?>

  <h2 class="mt-md mb-md">Répartition par palier — <?= $total_releves ?> relevé<?= $total_releves > 1 ? 's' : '' ?></h2>

  <div class="comp-liste-wrapper mb-md">
    <table class="comp-liste">
      <thead>
        <tr>
          <th>Palier</th>
          <th>Connexions</th>
          <th>Part</th>
          <th>Utilisateurs</th>
          <th>Largeurs observées</th>
        </tr>
      </thead>
      <tbody>
        <?php foreach ($synthese as $s): ?>
          <?php $part = round(100 * (int)$s['nb_connexions'] / $total_releves) ?>
          <tr>
            <td><?= h($paliers_libelles[(int)$s['palier']] ?? '—') ?></td>
            <td><?= (int)$s['nb_connexions'] ?></td>
            <td><?= $part ?> %</td>
            <td><?= (int)$s['nb_joueurs'] ?></td>
            <td><?= (int)$s['vp_min'] ?> – <?= (int)$s['vp_max'] ?> px</td>
          </tr>
        <?php endforeach ?>
      </tbody>
    </table>
  </div>

  <h2 class="mt-md mb-md">Largeurs les plus fréquentes</h2>

  <div class="comp-liste-wrapper mb-md">
    <table class="comp-liste">
      <thead>
        <tr>
          <th>Largeur</th>
          <th>Connexions</th>
          <th>Utilisateurs</th>
        </tr>
      </thead>
      <tbody>
        <?php foreach ($largeurs as $l): ?>
          <tr>
            <td><?= (int)$l['co_vp_w'] ?> px</td>
            <td><?= (int)$l['nb'] ?></td>
            <td><?= (int)$l['nb_joueurs'] ?></td>
          </tr>
        <?php endforeach ?>
      </tbody>
    </table>
  </div>

  <h2 class="mt-md mb-md">Journal — 200 dernières connexions</h2>

  <div class="comp-liste-wrapper">
    <table class="comp-liste">
      <thead>
        <tr>
          <th>Date</th>
          <th>Utilisateur</th>
          <th>Viewport</th>
          <th>DPR</th>
          <th>Écran</th>
          <th>Orientation</th>
          <th>Tactile</th>
          <th>Plateforme</th>
          <th>Navigateur</th>
        </tr>
      </thead>
      <tbody>
        <?php foreach ($journal as $c): ?>
          <tr>
            <td><?= h(date('d/m/Y H:i', strtotime($c['co_date']))) ?></td>
            <td><?= h($c['j_pseudo'] ?? '—') ?></td>
            <td><?= (int)$c['co_vp_w'] ?> × <?= (int)$c['co_vp_h'] ?></td>
            <td><?= $c['co_dpr'] !== null ? h(rtrim(rtrim(number_format((float)$c['co_dpr'], 2, ',', ''), '0'), ',')) : '—' ?></td>
            <td>
              <?= $c['co_screen_w'] ? (int)$c['co_screen_w'] . ' × ' . (int)$c['co_screen_h'] : '—' ?>
            </td>
            <td><?= $c['co_orientation'] === 'landscape' ? 'paysage' : ($c['co_orientation'] === 'portrait' ? 'portrait' : '—') ?></td>
            <td><?= (int)$c['co_touch'] > 0 ? 'oui' : 'non' ?></td>
            <td><?= h($c['co_plateforme'] ?? '—') ?></td>
            <td title="<?= h($c['co_ua'] ?? '') ?>">
              <?= h(mb_substr((string)($c['co_ua'] ?? '—'), 0, 40)) ?><?= mb_strlen((string)$c['co_ua']) > 40 ? '…' : '' ?>
            </td>
          </tr>
        <?php endforeach ?>
      </tbody>
    </table>
  </div>

<?php endif ?>

<?php
require_once '../include/footer.php';
?>
