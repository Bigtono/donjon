<?php
// include/ajax/detail-pp/classe.php
// Retourne le HTML de détail d'une classe pour #detail-pp
// Appelé via actualiserPage() — pas de layout header/footer
//
// Paramètres GET :
//   id (int) — cla_id de la classe à afficher

require_once __DIR__ . '/../../db.php';
require_once __DIR__ . '/../../auth.php';
require_once __DIR__ . '/../../helpers.php';

requireAuth();

$id      = intParam($_GET['id'] ?? $_POST['id'] ?? 0);
$ruleset = $_SESSION['rulesetRep'] ?? 'DD3.5';

if (!$id):
  http_response_code(400);
  echo '<p class="erreur">Identifiant manquant.</p>';
  exit;
endif;

// ============================================================
// Données principales de la classe
// ============================================================

$stmt = $db->prepare('
  SELECT cla.*,
         clt.clt_nom,
         mag.mag_nom,   mag.mag_abreviation,
         car.car_nom    AS car_ls_nom,
         res.res_nom,
         camp.camp_nom,
         var.var_valeur AS ruleset_label
  FROM   dd_classes cla
  LEFT JOIN dd_classe_type   clt  ON clt.clt_id   = cla.cla_clt_id
  LEFT JOIN dd_typemagie     mag  ON mag.mag_id    = cla.cla_mag_id
  LEFT JOIN dd_caracteristiques car ON car.car_id  = cla.cla_car_id
  LEFT JOIN dd_ressources    res  ON res.res_id    = cla.cla_res_id
  LEFT JOIN dd_campagnes     camp ON camp.camp_id  = cla.cla_camp_id
  LEFT JOIN dd_variables     var  ON var.var_id    = cla.cla_ruleset_var_id
  WHERE  cla.cla_id = ?
');
$stmt->execute([$id]);
$cla = $stmt->fetch();

if (!$cla):
  http_response_code(404);
  echo '<p class="erreur">Classe introuvable.</p>';
  exit;
endif;

$niveauMax      = (int)$cla['cla_niveauMax'];
$isLanceurSorts = (int)$cla['cla_mag_id'] > 0;

// Pouvoirs actifs (intitulé non nul)
$activePouvoirs = [];
for ($p = 1; $p <= 5; $p++):
  if (!empty(trim((string)$cla['cla_pouvoir' . $p]))):
    $activePouvoirs[] = $p;
  endif;
endfor;

// ============================================================
// Compétences de classe (dd_classe_competence → dd_competences)
// ============================================================

$stmt_comp = $db->prepare('
  SELECT comp.comp_id, comp.comp_nom, cc.ccomp_precision
  FROM   dd_classe_competence cc
  JOIN   dd_competences comp ON comp.comp_id = cc.ccomp_comp_id
  WHERE  cc.ccomp_cla_id = ?
  ORDER  BY comp.comp_nom
');
$stmt_comp->execute([$id]);
$competences = $stmt_comp->fetchAll();

// ============================================================
// Table de progression par niveau (dd_classe_niveau)
// ============================================================

$cols_select = ['cn.*'];
$stmt_niv = $db->prepare('
  SELECT cn.*,
    GROUP_CONCAT(
      CONCAT(cap.cap_id, \'|\', cap.cap_nom)
      ORDER BY cap.cap_nom
      SEPARATOR \'||\'
    ) AS capacites_raw
  FROM   dd_classe_niveau cn
  LEFT JOIN dd_classe_capacite cc  ON cc.cc_cla_id = cn.cn_cla_id
                                   AND cc.cc_niveau = cn.cn_niveau
  LEFT JOIN dd_capacites_speciales cap ON cap.cap_id = cc.cc_cap_id
  WHERE  cn.cn_cla_id = ?
  GROUP  BY cn.cn_id
  ORDER  BY cn.cn_niveau
');
$stmt_niv->execute([$id]);
$niveaux = $stmt_niv->fetchAll();

// ============================================================
// Capacités spéciales complètes (pour la section descriptions)
// ============================================================

$stmt_cap = $db->prepare('
  SELECT DISTINCT cap.cap_id, cap.cap_nom, cap.cap_description, cap.cap_type
  FROM   dd_classe_capacite cc
  JOIN   dd_capacites_speciales cap ON cap.cap_id = cc.cc_cap_id
  WHERE  cc.cc_cla_id = ?
  ORDER  BY cap.cap_nom
');
$stmt_cap->execute([$id]);
$capacites = $stmt_cap->fetchAll();

// URL de base pour les sous-panels
$url_sub_cap  = BASE_URL . '/include/ajax/detail-pp/capacite.php';
$url_sub_comp = BASE_URL . '/include/ajax/detail-pp/competence.php';
?>

<div class="sort-detail classe-detail">

  <?php // ---- En-tête + bouton Modifier ?>
  <div class="sort-detail__header">
    <h2 class="sort-detail__nom">
      <?= h($cla['cla_nom']) ?>
      <?php if ($cla['cla_abreviation']): ?>
        <span class="sort-detail__college">(<?= h($cla['cla_abreviation']) ?>)</span>
      <?php endif ?>
      <?php if (canEditCompendium()): ?>
        <button class="sort-detail__edit-btn"
                onclick="ouvrirModifier('<?= BASE_URL ?>/include/ajax/modifier/classe.php', <?= $id ?>)"
                title="Modifier cette classe">
          <i class="fa fa-edit"></i>
        </button>
      <?php endif ?>
    </h2>
    <?php if ($cla['clt_nom']): ?>
      <p class="sort-detail__college"><?= h($cla['clt_nom']) ?></p>
    <?php endif ?>
  </div>

  <?php // ---- Données de base ?>
  <div class="sort-detail__body">

    <div class="sort-detail__row">
      <span class="sort-detail__label">Dé de vie</span>
      <span class="sort-detail__value">d<?= (int)$cla['cla_dV'] ?></span>
    </div>

    <div class="sort-detail__row">
      <span class="sort-detail__label">Niveaux</span>
      <span class="sort-detail__value"><?= $niveauMax ?></span>
    </div>

    <?php if ($cla['mag_nom']): ?>
      <div class="sort-detail__row">
        <span class="sort-detail__label">Magie</span>
        <span class="sort-detail__value"><?= h($cla['mag_nom']) ?></span>
      </div>
    <?php endif ?>

    <?php if ($cla['cla_car_id'] && $cla['car_ls_nom']): ?>
      <div class="sort-detail__row">
        <span class="sort-detail__label">Caractéristique LS</span>
        <span class="sort-detail__value"><?= h($cla['car_ls_nom']) ?></span>
      </div>
    <?php endif ?>

    <?php if ($ruleset === 'DD3.5'): ?>

      <?php if ($cla['cla_pointsCompetences']): ?>
        <div class="sort-detail__row">
          <span class="sort-detail__label">Points de compétences</span>
          <span class="sort-detail__value"><?= (int)$cla['cla_pointsCompetences'] ?> + mod. Int</span>
        </div>
      <?php endif ?>

      <?php if ($cla['cla_alignement']): ?>
        <div class="sort-detail__row">
          <span class="sort-detail__label">Alignement</span>
          <span class="sort-detail__value"><?= h($cla['cla_alignement']) ?></span>
        </div>
      <?php endif ?>

      <?php if ((int)$cla['cla_clt_id'] === 2 && $cla['cla_conditions']): ?>
        <div class="sort-detail__row sort-detail__row--full">
          <span class="sort-detail__label">Conditions d'accès</span>
          <div class="sort-detail__value"><?= $cla['cla_conditions'] ?></div>
        </div>
      <?php endif ?>

    <?php elseif ($ruleset === 'DD2024'): ?>

      <?php if ($cla['cla_sauvegardes']): ?>
        <div class="sort-detail__row">
          <span class="sort-detail__label">Jets de sauvegarde</span>
          <span class="sort-detail__value"><?= h($cla['cla_sauvegardes']) ?></span>
        </div>
      <?php endif ?>

    <?php endif ?>

  </div>

  <?php // ---- Compétences de classe ?>
  <?php if (!empty($competences)): ?>
    <div class="classe-detail__section" style="margin-top:.75rem;">
      <div class="sort-detail__label" style="margin-bottom:.3rem;">
        <?= $ruleset === 'DD2024' ? 'Compétences maîtrisées' : 'Compétences de classe' ?>
      </div>
      <div class="classe-detail__competences">
        <?php foreach ($competences as $i => $comp): ?>
          <?php if ($i > 0) echo ', ' ?>
          <span class="lien-sub"
                onclick="actualiserPageSub('<?= $url_sub_comp ?>',{id:<?= (int)$comp['comp_id'] ?>})"
                title="Voir la compétence">
            <?= h($comp['comp_nom']) ?>
            <?php if ($comp['ccomp_precision']): ?>
              (<?= h($comp['ccomp_precision']) ?>)
            <?php endif ?>
          </span>
        <?php endforeach ?>
      </div>
    </div>
  <?php endif ?>

  <?php // ---- Armes (et armures en DD3.5) ?>
  <?php if ($cla['cla_armes']): ?>
    <div class="classe-detail__section" style="margin-top:.5rem;">
      <span class="sort-detail__label">
        <?= $ruleset === 'DD3.5' ? 'Armes &amp; armures' : 'Maîtrise d\'armes' ?>
      </span>
      <div><?= $cla['cla_armes'] ?></div>
    </div>
  <?php endif ?>

  <?php // ---- Armures DD2024 ?>
  <?php if ($ruleset === 'DD2024' && $cla['cla_armures']): ?>
    <div class="classe-detail__section" style="margin-top:.5rem;">
      <span class="sort-detail__label">Formation aux armures</span>
      <div><?= $cla['cla_armures'] ?></div>
    </div>
  <?php endif ?>

  <?php // ---- Description ?>
  <?php if ($cla['cla_description']): ?>
    <div class="sort-detail__description" style="margin:.75rem 0;">
      <?= $cla['cla_description'] ?>
    </div>
  <?php endif ?>

  <?php // ---- Tableau de progression par niveau ?>
  <?php if (!empty($niveaux)): ?>
    <?php
    // Nombre de colonnes sorts actives (pour le colspan "Nombre de sorts par jour")
    $nbColsSorts = $isLanceurSorts ? 10 : 0; // niv 0-9
    if ($ruleset === 'DD2024' && $cla['cla_sort_prepare']) $nbColsSorts = 1; // remplace les 10 par 1
    // Nombre de colonnes stats
    $nbColsStats  = ($ruleset === 'DD3.5') ? 4 : 1; // BBA+Réf+Vig+Vol ou B.maîtrise seul
    $nbColsPouvoirs = count($activePouvoirs);
    // Colspan total de l'en-tête sur la rangée 1 avant les sorts
    $colsBefore = 1 + $nbColsStats + 1 + $nbColsPouvoirs; // Niv + stats + Aptitudes + pouvoirs
    ?>
    <div class="classe-detail__niveaux" style="margin-top:1rem; overflow-x:auto;">
      <p class="classe-detail__table-titre">
        <strong>Table de progression : <?= h($cla['cla_nom']) ?></strong>
      </p>

      <table class="table-classe-niv" id="classe-niv-table">
        <thead>
          <?php if ($isLanceurSorts): ?>
          <tr class="thead-groupes">
            <th colspan="<?= $colsBefore ?>"></th>
            <th colspan="<?= $nbColsSorts ?>" class="th-groupe-sorts">Nombre de sorts par jour</th>
          </tr>
          <?php endif ?>
          <tr>
            <th class="col-niv">Niv.</th>
            <?php if ($ruleset === 'DD3.5'): ?>
              <th class="col-stat">BBA</th>
              <th class="col-stat">Réf.</th>
              <th class="col-stat">Vig.</th>
              <th class="col-stat">Vol.</th>
            <?php else: ?>
              <th class="col-stat">B. maîtrise</th>
            <?php endif ?>
            <th class="col-aptitudes">Aptitudes</th>
            <?php foreach ($activePouvoirs as $p): ?>
              <th class="col-pouvoir"><?= h((string)($cla['cla_pouvoir' . $p] ?? '')) ?></th>
            <?php endforeach ?>
            <?php if ($isLanceurSorts): ?>
              <?php if ($ruleset === 'DD2024' && $cla['cla_sort_prepare']): ?>
                <th class="col-sort">Prép.</th>
              <?php else: ?>
                <?php for ($s = 0; $s <= 9; $s++): ?>
                  <th class="col-sort"><?= $s ?></th>
                <?php endfor ?>
              <?php endif ?>
            <?php endif ?>
          </tr>
        </thead>
        <tbody>
          <?php foreach ($niveaux as $niv): ?>
            <?php
            $caps_html = '—';
            if (!empty($niv['capacites_raw'])):
              $caps_parts = [];
              foreach (explode('||', $niv['capacites_raw']) as $raw):
                [$cap_id, $cap_nom] = explode('|', $raw, 2);
                $caps_parts[] = '<span class="lien-sub" '
                  . 'onclick="actualiserPageSub(\'' . $url_sub_cap . '\',{id:' . (int)$cap_id . '})" '
                  . 'title="Voir la capacité">'
                  . h($cap_nom)
                  . '</span>';
              endforeach;
              $caps_html = implode(', ', $caps_parts);
            endif;
            ?>
            <tr>
              <td class="col-niv"><strong><?= (int)$niv['cn_niveau'] ?></strong></td>
              <?php if ($ruleset === 'DD3.5'): ?>
                <td class="col-stat"><?= h($niv['cn_bba'] ?? '') ?></td>
                <td class="col-stat">+<?= (int)($niv['cn_reflexes'] ?? 0) ?></td>
                <td class="col-stat">+<?= (int)($niv['cn_vigueur']  ?? 0) ?></td>
                <td class="col-stat">+<?= (int)($niv['cn_volonte']  ?? 0) ?></td>
              <?php else: ?>
                <td class="col-stat"><?= h($niv['cn_bba'] ?? '') ?></td>
              <?php endif ?>
              <td class="col-aptitudes"><?= $caps_html ?></td>
              <?php foreach ($activePouvoirs as $p): ?>
                <td class="col-pouvoir"><?= h((string)($niv['cn_pouvoir' . $p] ?? '—')) ?></td>
              <?php endforeach ?>
              <?php if ($isLanceurSorts): ?>
                <?php if ($ruleset === 'DD2024' && $cla['cla_sort_prepare']): ?>
                  <td class="col-sort"><?= $niv['cn_sortPrepare'] !== null && $niv['cn_sortPrepare'] !== '' ? (int)$niv['cn_sortPrepare'] : '—' ?></td>
                <?php else: ?>
                  <?php for ($s = 0; $s <= 9; $s++): ?>
                    <td class="col-sort"><?= $niv['cn_sort_n' . $s] !== null && $niv['cn_sort_n' . $s] !== '' ? (int)$niv['cn_sort_n' . $s] : '—' ?></td>
                  <?php endfor ?>
                <?php endif ?>
              <?php endif ?>
            </tr>
          <?php endforeach ?>
        </tbody>
      </table>
    </div>

    <?php // ---- Table Sorts connus (DD3.5 uniquement, dans une table séparée) ?>
    <?php
    // Vérifier qu'au moins une ligne contient une valeur avant d'afficher la table
    $hasSortsConnus = false;
    if ($ruleset === 'DD3.5' && $cla['cla_sort_connu'] && !empty($niveaux)):
      foreach ($niveaux as $niv):
        for ($s = 0; $s <= 9; $s++):
          if (isset($niv['cn_sortConnu_n' . $s]) && $niv['cn_sortConnu_n' . $s] !== '' && $niv['cn_sortConnu_n' . $s] !== null):
            $hasSortsConnus = true;
            break 2;
          endif;
        endfor;
      endforeach;
    endif;
    ?>
    <?php if ($hasSortsConnus): ?>
    <div class="classe-detail__niveaux" style="margin-top:.75rem; overflow-x:auto;">
      <p class="classe-detail__table-titre">
        <strong>Sorts connus : <?= h($cla['cla_nom']) ?></strong>
      </p>
      <table class="table-classe-niv">
        <thead>
          <tr class="thead-groupes">
            <th></th>
            <th colspan="10" class="th-groupe-sorts">Nombre de sorts connus</th>
          </tr>
          <tr>
            <th class="col-niv">Niv.</th>
            <?php for ($s = 0; $s <= 9; $s++): ?>
              <th class="col-sort"><?= $s ?></th>
            <?php endfor ?>
          </tr>
        </thead>
        <tbody>
          <?php foreach ($niveaux as $niv): ?>
            <?php
            // N'afficher que les lignes qui ont au moins une valeur non vide
            $hasData = false;
            for ($s = 0; $s <= 9; $s++):
              if (isset($niv['cn_sortConnu_n' . $s]) && $niv['cn_sortConnu_n' . $s] !== '' && $niv['cn_sortConnu_n' . $s] !== null):
                $hasData = true;
                break;
              endif;
            endfor;
            if (!$hasData) continue;
            ?>
            <tr>
              <td class="col-niv"><strong><?= (int)$niv['cn_niveau'] ?></strong></td>
              <?php for ($s = 0; $s <= 9; $s++): ?>
                <td class="col-sort"><?= $niv['cn_sortConnu_n' . $s] !== null && $niv['cn_sortConnu_n' . $s] !== '' ? (int)$niv['cn_sortConnu_n' . $s] : '—' ?></td>
              <?php endfor ?>
            </tr>
          <?php endforeach ?>
        </tbody>
      </table>
    </div>
    <?php endif ?>

  <?php endif ?>

  <?php // ---- Sorts (description DD3.5) ?>
  <?php if ($ruleset === 'DD3.5' && $cla['cla_sorts']): ?>
    <div class="classe-detail__section" style="margin-top:.75rem;">
      <div class="sort-detail__label">Sorts</div>
      <div><?= $cla['cla_sorts'] ?></div>
    </div>
  <?php endif ?>

  <?php // ---- Descriptions des capacités spéciales ?>
  <?php if (!empty($capacites)): ?>
    <div class="classe-detail__capacites" style="margin-top:1rem;">
      <div class="sort-detail__label" style="margin-bottom:.5rem;">Capacités spéciales</div>
      <?php foreach ($capacites as $cap): ?>
        <div class="classe-detail__capacite" id="capacite-<?= (int)$cap['cap_id'] ?>"
             style="margin-bottom:.75rem;">
          <div class="classe-detail__capacite-nom">
            <strong><?= h($cap['cap_nom']) ?></strong>
            <?php if ($cap['cap_type']): ?>
              <span class="cap-type">(<?= h($cap['cap_type']) ?>)</span>
            <?php endif ?>
          </div>
          <?php if ($cap['cap_description']): ?>
            <div class="classe-detail__capacite-desc">
              <?= $cap['cap_description'] ?>
            </div>
          <?php endif ?>
        </div>
      <?php endforeach ?>
    </div>
  <?php endif ?>

  <?php // ---- Pied de fiche ?>
  <div class="sort-detail__footer" style="margin-top:1rem;">
    <span class="sort-detail__source">
      <i class="fa fa-book"></i> <?= h($cla['res_nom']) ?>
    </span>
    <?php if ($cla['cla_camp_id'] && $cla['camp_nom']): ?>
      <span class="sort-detail__homebrew">
        <i class="fa fa-flask"></i> <?= h($cla['camp_nom']) ?>
      </span>
    <?php endif ?>
    <span class="sort-detail__ruleset">
      <?= h($cla['ruleset_label']) ?>
    </span>
  </div>

</div>

<style>
/* ============================================================
   Styles locaux au panel classe — injectés avec le HTML
   ============================================================ */

/* Titre de table */
.classe-detail__table-titre {
  margin: 0 0 .3rem;
  font-size: .9rem;
}

/* Table pleine largeur */
.table-classe-niv {
  border-collapse: collapse;
  font-size: .82rem;
  width: 100%;
  table-layout: auto;
}

.table-classe-niv th,
.table-classe-niv td {
  border: 1px solid var(--clr-border);
  padding: 3px 5px;
  text-align: center;
  vertical-align: middle;
  white-space: nowrap;
}

/* En-tête de groupe (ligne 1 : "Nombre de sorts par jour") */
.table-classe-niv .thead-groupes th {
  background: var(--clr-surface-alt, #2a2a2a);
  font-size: .78rem;
  border-bottom: none;
  padding: 2px 4px;
}
.table-classe-niv .th-groupe-sorts {
  border-left: 2px solid var(--clr-accent, #8b6914);
}

/* En-tête ligne 2 (labels de colonnes) */
.table-classe-niv thead tr:last-child th {
  background: var(--clr-surface-alt, #1e1e1e);
  font-size: .8rem;
  font-weight: 600;
}

/* Colonne niveau */
.table-classe-niv .col-niv {
  width: 28px;
  min-width: 28px;
  font-weight: 700;
}

/* Colonnes stats — taille fixe compacte */
.table-classe-niv .col-stat {
  width: 44px;
  min-width: 36px;
}

/* Colonnes sorts — compactes */
.table-classe-niv .col-sort {
  width: 24px;
  min-width: 20px;
  border-left-color: var(--clr-border-muted, var(--clr-border));
}
/* Séparation visuelle avant le groupe sorts */
.table-classe-niv td.col-sort:first-of-type,
.table-classe-niv th.col-sort:first-of-type {
  border-left: 2px solid var(--clr-accent, #8b6914);
}

/* Colonnes pouvoirs — taille adaptée */
.table-classe-niv .col-pouvoir {
  min-width: 48px;
  max-width: 80px;
  white-space: normal;
  word-break: break-word;
}

/* Colonne aptitudes — flexible, prend le reste de la largeur */
.table-classe-niv .col-aptitudes {
  text-align: left;
  white-space: normal;
  min-width: 25%;   /* garantit au moins 25% de la largeur totale */
  width: 100%;      /* avec table-layout:auto, s'étire pour combler le reste */
  word-break: break-word;
}

/* Liens cliquables vers le sous-panel */
.lien-sub {
  cursor: pointer;
  color: var(--clr-accent, #c8a84b);
  text-decoration: underline dotted;
}
.lien-sub:hover {
  text-decoration: underline;
}
</style>


