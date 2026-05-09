<?php
// include/ajax/detail-pp/sort.php
// Retourne le HTML de détail d'un sort pour #detail-pp
// Appelé via actualiserPage() — pas de layout header/footer
//
// Paramètres GET :
//   id (int) — so_id du sort à afficher

require_once __DIR__ . '/../../db.php';
require_once __DIR__ . '/../../auth.php';
require_once __DIR__ . '/../../helpers.php';

requireAuth();

$id         = intParam($_GET['id'] ?? 0);
$ruleset    = $_SESSION['rulesetRep'] ?? 'DD3.5';

if (!$id):
  http_response_code(400);
  echo '<p class="erreur">Identifiant manquant.</p>';
  exit;
endif;

// ============================================================
// Données principales du sort
// ============================================================
$stmt = $db->prepare('
  SELECT so.*, co.co_nom, res.res_nom,
         camp.camp_nom,
         var.var_valeur AS ruleset_label
  FROM   dd_sorts so
  LEFT JOIN dd_colleges   co   ON co.co_id     = so.so_co_id
  LEFT JOIN dd_ressources res  ON res.res_id    = so.so_res_id
  LEFT JOIN dd_campagnes  camp ON camp.camp_id  = so.so_camp_id
  LEFT JOIN dd_variables  var  ON var.var_id    = so.so_ruleset_var_id
  WHERE  so.so_id = ?
');
$stmt->execute([$id]);
$so = $stmt->fetch();

if (!$so):
  http_response_code(404);
  echo '<p class="erreur">Sort introuvable.</p>';
  exit;
endif;

// ============================================================
// Classes du sort (dd_sortclasse)
// ============================================================
$stmt_classes = $db->prepare('
  SELECT cla.cla_nom, cla.cla_clt_id, sc.sc_niveau
  FROM   dd_sortclasse sc
  JOIN   dd_classes cla ON cla.cla_id = sc.sc_cla_id
  WHERE  sc.sc_so_id = ?
  ORDER  BY cla.cla_clt_id ASC, cla.cla_nom ASC
');
$stmt_classes->execute([$id]);
$classes = $stmt_classes->fetchAll();

// ============================================================
// Domaines du sort [DD3.5 uniquement] (dd_sortdomaine)
// ============================================================
$domaines = [];
if ($ruleset === 'DD3.5'):
  $stmt_dom = $db->prepare('
    SELECT dom.do_nom, sd.sd_niveau
    FROM   dd_sortdomaine sd
    JOIN   dd_domaines    dom ON dom.do_id = sd.sd_do_id
    WHERE  sd.sd_so_id = ?
    ORDER  BY dom.do_nom ASC
  ');
  $stmt_dom->execute([$id]);
  $domaines = $stmt_dom->fetchAll();
endif;

// ============================================================
// Construction des champs composés
// ============================================================

// {liste des composantes}
function buildComposantes(array $so, string $ruleset): string {
  $parts = [];
  if ($so['so_vocal'])    $parts[] = 'V';
  if ($so['so_gestuel'])  $parts[] = ($ruleset === 'DD2024') ? 'S' : 'G';
  if ($so['so_materiel']) $parts[] = 'M';
  if ($ruleset === 'DD3.5'):
    if ($so['so_focalisateur'])       $parts[] = 'F';
    if ($so['so_focalisateur_divin']) $parts[] = 'FD';
  endif;
  return implode(', ', $parts);
}

// {liste des classes} pour DD3.5 : "Nom niv / Nom niv"
// {liste des classes} pour DD2024 : "Nom / Nom" (pas de niveau)
function buildClassesList(array $classes, string $ruleset): string {
  if (empty($classes)) return '<em class="text-muted">—</em>';
  $parts = [];
  foreach ($classes as $c):
    $parts[] = $ruleset === 'DD3.5'
      ? h($c['cla_nom']) . ' ' . (int)$c['sc_niveau']
      : h($c['cla_nom']);
  endforeach;
  return implode(' / ', $parts);
}

// {liste des domaines} pour DD3.5 : "Nom niv / Nom niv"
function buildDomainesList(array $domaines): string {
  if (empty($domaines)) return '';
  $parts = [];
  foreach ($domaines as $d):
    $parts[] = h($d['do_nom']) . ' ' . (int)$d['sd_niveau'];
  endforeach;
  return implode(' / ', $parts);
}

$composantes_str = buildComposantes($so, $ruleset);
$classes_str     = buildClassesList($classes, $ruleset);
$domaines_str    = buildDomainesList($domaines);

// Ligne "Niveau" DD3.5 : classes + domaines séparés
$niveau_str = $classes_str;
if ($ruleset === 'DD3.5' && !empty($domaines_str)):
  $niveau_str .= ' ; ' . $domaines_str;
endif;
?>

<div class="sort-detail">

  <?php // ---- En-tête + bouton Modifier ---- ?>
  <div class="sort-detail__header flex-between">
    <div>
      <h2 class="sort-detail__nom"><?= h($so['so_nom']) ?></h2>

      <?php // Collège + branche ?>
      <?php if ($so['co_nom']): ?>
        <p class="sort-detail__college">
          <?= h($so['co_nom']) ?>
          <?php if ($ruleset === 'DD3.5' && $so['so_branche']): ?>
            (<?= h($so['so_branche']) ?>)
          <?php endif ?>
        </p>
      <?php endif ?>
    </div>

    <?php if (canEditCompendium()): ?>
      <button class="btn btn-secondary btn-sm"
              onclick="ouvrirModifier('<?= BASE_URL ?>/include/ajax/modifier/sort.php', <?= $id ?>)">
        <i class="fa fa-edit"></i> Modifier
      </button>
    <?php endif ?>
  </div>

  <?php // ---- Corps de la fiche ---- ?>
  <dl class="sort-detail__body">

    <?php // ---- Niveau (classes + domaines DD3.5) ---- ?>
    <div class="sort-detail__row">
      <dt>Niveau</dt>
      <dd><?= $niveau_str ?></dd>
    </div>

    <?php // ---- DD2024 : niveau du sort ---- ?>
    <?php if ($ruleset === 'DD2024' && $so['so_niveau'] !== null): ?>
      <div class="sort-detail__row">
        <dt>Niveau du sort</dt>
        <dd><?= (int)$so['so_niveau'] ?></dd>
      </div>
    <?php endif ?>

    <?php // ---- Composantes ---- ?>
    <?php if ($composantes_str): ?>
      <div class="sort-detail__row">
        <dt>Composantes</dt>
        <dd>
          <?= $composantes_str ?>
          <?php if ($so['so_composante']): ?>
            (<?= h($so['so_composante']) ?>)
          <?php endif ?>
        </dd>
      </div>
    <?php endif ?>

    <?php // ---- Temps d'incantation ---- ?>
    <?php if ($so['so_duree_incantation']): ?>
      <div class="sort-detail__row">
        <dt>Temps d'incantation</dt>
        <dd><?= h($so['so_duree_incantation']) ?></dd>
      </div>
    <?php endif ?>

    <?php // ---- Portée ---- ?>
    <?php if ($so['so_portee']): ?>
      <div class="sort-detail__row">
        <dt>Portée</dt>
        <dd><?= h($so['so_portee']) ?></dd>
      </div>
    <?php endif ?>

    <?php // ---- Cible [DD3.5] ---- ?>
    <?php if ($ruleset === 'DD3.5' && $so['so_cible']): ?>
      <div class="sort-detail__row">
        <dt>Cible</dt>
        <dd><?= h($so['so_cible']) ?></dd>
      </div>
    <?php endif ?>

    <?php // ---- Zone d'effet [DD3.5] ---- ?>
    <?php if ($ruleset === 'DD3.5' && $so['so_zone_effet']): ?>
      <div class="sort-detail__row">
        <dt>Zone d'effet</dt>
        <dd><?= h($so['so_zone_effet']) ?></dd>
      </div>
    <?php endif ?>

    <?php // ---- Durée ---- ?>
    <?php if ($so['so_duree_sort']): ?>
      <div class="sort-detail__row">
        <dt>Durée</dt>
        <dd><?= h($so['so_duree_sort']) ?></dd>
      </div>
    <?php endif ?>

    <?php // ---- Jet de sauvegarde [DD3.5] ---- ?>
    <?php if ($ruleset === 'DD3.5' && $so['so_jet_sauvegarde']): ?>
      <div class="sort-detail__row">
        <dt>Jet de sauvegarde</dt>
        <dd><?= h($so['so_jet_sauvegarde']) ?></dd>
      </div>
    <?php endif ?>

    <?php // ---- Résistance à la magie [DD3.5] ---- ?>
    <?php if ($ruleset === 'DD3.5' && $so['so_resistance']): ?>
      <div class="sort-detail__row">
        <dt>Résistance à la magie</dt>
        <dd><?= h($so['so_resistance']) ?></dd>
      </div>
    <?php endif ?>

  </dl>

  <?php // ---- Description ---- ?>
  <?php if ($so['so_description']): ?>
    <div class="sort-detail__description">
      <?= $so['so_description'] ?>
    </div>
  <?php endif ?>

  <?php // ---- Pied de fiche : source, campagne, ruleset ---- ?>
  <div class="sort-detail__footer">
    <span class="sort-detail__source">
      <i class="fa fa-book"></i> <?= h($so['res_nom']) ?>
    </span>
    <?php if ($so['so_camp_id'] && $so['camp_nom']): ?>
      <span class="sort-detail__homebrew">
        <i class="fa fa-flask"></i> <?= h($so['camp_nom']) ?>
      </span>
    <?php endif ?>
    <span class="sort-detail__ruleset">
      <?= h($so['ruleset_label']) ?>
    </span>
  </div>

</div>
