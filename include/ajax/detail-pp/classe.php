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
// Tag [[tab:slug]] dans les champs texte du compendium (SP-TB7)
require_once __DIR__ . '/../../tableau-parser.php';

requireAuth();

$id      = intParam($_GET['id'] ?? $_POST['id'] ?? 0);
$ruleset    = $_SESSION['rulesetRep']      ?? 'DD3.5';
$ruleset_id = (int)($_SESSION['ruleset_var_id'] ?? 1);

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
         res.res_j_id,
         camp.camp_nom,
         var.var_valeur AS ruleset_label,
         clapar.cla_nom AS cla_parente_nom
  FROM   dd_classes cla
  LEFT JOIN dd_classe_type   clt  ON clt.clt_id   = cla.cla_clt_id
  LEFT JOIN dd_typemagie     mag  ON mag.mag_id    = cla.cla_mag_id
  LEFT JOIN dd_caracteristiques car ON car.car_id  = cla.cla_car_id
  LEFT JOIN dd_ressources    res  ON res.res_id    = cla.cla_res_id
  LEFT JOIN dd_campagnes     camp ON camp.camp_id  = cla.cla_camp_id
  LEFT JOIN dd_variables     var  ON var.var_id    = cla.cla_ruleset_var_id
  LEFT JOIN dd_classes       clapar ON clapar.cla_id = cla.cla_cla_id
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
$isSousClasse   = ((int)$cla['cla_clt_id'] === 5); // clt_id=5 → 'Sous-classe' (DD2024)

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

// SP-MA6 — Prestige DD3.5 qui fait progresser le NLS d'une classe de base au lieu
// d'accorder ses propres sorts : la table remplace ses colonnes de sorts par une
// colonne « Sorts par jour » rédigée (« +1 niv. profane »…), en forme courte pour
// tenir sur un téléphone. Les deux cas sont exclusifs : un seul drapeau levé
// suffit à basculer.
$progressionNls = false;
if ($ruleset === 'DD3.5' && (int)$cla['cla_clt_id'] === 2):
  foreach ($niveaux as $nv):
    if ((int)($nv['cn_niveauSortArcane'] ?? 0) === 1
        || (int)($nv['cn_niveauSortDivin'] ?? 0) === 1
        || (int)($nv['cn_niveauSortEffectif'] ?? 0) === 1):
      $progressionNls = true;
      break;
    endif;
  endforeach;
endif;

// Libellé d'un niveau de progression du NLS. « Au choix » prime : il couvre
// n'importe quelle classe de base lanceuse.
$libelleProgressionNls = function (array $nv): string {
  $arc = (int)($nv['cn_niveauSortArcane']   ?? 0) === 1;
  $div = (int)($nv['cn_niveauSortDivin']    ?? 0) === 1;
  $eff = (int)($nv['cn_niveauSortEffectif'] ?? 0) === 1;
  if ($eff):         return '+1 niv. au choix';         endif;
  if ($arc && $div): return '+1 niv. profane et divin'; endif;
  if ($arc):         return '+1 niv. profane';          endif;
  if ($div):         return '+1 niv. divin';            endif;
  return '—';
};

// ============================================================
// Capacités spéciales complètes (pour la section descriptions)
// ============================================================

// Une capacité affectée à plusieurs niveaux (itérations) n'apparaît qu'une
// fois, titrée par son PREMIER niveau d'obtention — MIN(cc_niveau). Les
// itérations suivantes restent lisibles dans la table de progression pour une
// classe normale, et dans le texte de la capacité pour une sous-classe.
// Le GROUP BY porte sur toutes les colonnes non agrégées (compatible
// ONLY_FULL_GROUP_BY).
$stmt_cap = $db->prepare('
  SELECT cap.cap_id, cap.cap_nom, cap.cap_description, cap.cap_type,
         MIN(cc.cc_niveau) AS cap_niveau
  FROM   dd_classe_capacite cc
  JOIN   dd_capacites_speciales cap ON cap.cap_id = cc.cc_cap_id
  WHERE  cc.cc_cla_id = ?
  GROUP  BY cap.cap_id, cap.cap_nom, cap.cap_description, cap.cap_type
  ORDER  BY cap_niveau, cap.cap_nom
');
$stmt_cap->execute([$id]);
$capacites = $stmt_cap->fetchAll();

// ============================================================
// Sous-classes rattachées (classe de base uniquement)
// ============================================================
// Même modèle d'affichage que "Classe parente" côté sous-classe : une liste
// de renvois cliquables. Périmètre identique à la liste du compendium :
// sources actives, et pour les entrées de supplément la règle de visibilité
// (officielle | mienne et visible | publique et visible).

$sousClasses = [];
if (!$isSousClasse):
  $res_ids_sc = getActiveResIds($db, $ruleset_id);
  if (!empty($res_ids_sc)):
    $ph_sc   = resIdsPlaceholders($res_ids_sc);
    $uid_sc  = (int)($_SESSION['j_id'] ?? 0);
    $stmt_sc = $db->prepare("
      SELECT sc.cla_id, sc.cla_nom
      FROM   dd_classes sc
      LEFT JOIN dd_ressources res ON res.res_id = sc.cla_res_id
      WHERE  sc.cla_cla_id = ?
        AND  sc.cla_res_id IN ($ph_sc)
        AND  (res.res_j_id IS NULL
              OR (res.res_j_id = ? AND sc.cla_visible = 1)
              OR (sc.cla_public = 1 AND sc.cla_visible = 1))
      ORDER  BY sc.cla_nom
    ");
    $stmt_sc->execute(array_merge([$id], $res_ids_sc, [$uid_sc]));
    $sousClasses = $stmt_sc->fetchAll();
  endif;
endif;

// Bonus de maîtrise DD2024 — commun à toutes les classes, par niveau
// Table : dd_bonus_matrise (orthographe exacte en base, filtrée par ruleset)
$bonusMaitrise = [];
if ($ruleset === 'DD2024'):
  try {
    $stmt_bm = $db->prepare('
      SELECT bm_niveau, bm_bonus
      FROM   dd_bonus_maitrise
      WHERE  bm_ruleset_var_id = ?
      ORDER  BY bm_niveau
    ');
    $stmt_bm->execute([$ruleset_id]);
    foreach ($stmt_bm->fetchAll() as $bm):
      $bonusMaitrise[(int)$bm['bm_niveau']] = (int)$bm['bm_bonus'];
    endforeach;
  } catch (Exception $e) {
    // Table absente ou vide — bonus non affiché
  }
endif;

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
      <?php if (canEditCompendiumEntry($db, $cla['res_j_id'] !== null ? (int)$cla['res_j_id'] : null)): ?>
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

    <?php if ($isSousClasse): ?>
      <?php if ((int)$cla['cla_cla_id'] > 0): ?>
        <div class="sort-detail__row">
          <span class="sort-detail__label">Classe parente</span>
          <span class="sort-detail__value">
            <span class="lien-sub"
                  onclick="naviguerDetailPP('<?= BASE_URL ?>/include/ajax/detail-pp/classe.php', {id:<?= (int)$cla['cla_cla_id'] ?>})"
                  title="Voir la classe parente">
              <?= h($cla['cla_parente_nom'] ?? '') ?>
            </span>
          </span>
        </div>
      <?php endif ?>
    <?php else: ?>

    <?php // ---- Caractéristique principale — première ligne de l'encadré
          // « Traits de base » du SRD DD2024. À ne pas confondre avec
          // « Caractéristique LS » (cla_car_id), qui est celle d'incantation. ?>
    <?php if ($ruleset === 'DD2024' && $cla['cla_caracteristiques']): ?>
      <div class="sort-detail__row">
        <span class="sort-detail__label">Caractéristique principale</span>
        <span class="sort-detail__value"><?= h($cla['cla_caracteristiques']) ?></span>
      </div>
    <?php endif ?>

    <div class="sort-detail__row">
      <span class="sort-detail__label">Dé de vie</span>
      <span class="sort-detail__value">d<?= (int)$cla['cla_dV'] ?></span>
    </div>

    <?php // Nombre de niveaux : non pertinent en DD2024 (progression commune) ?>
    <?php if ($ruleset === 'DD3.5'): ?>
      <div class="sort-detail__row">
        <span class="sort-detail__label">Niveaux</span>
        <span class="sort-detail__value"><?= $niveauMax ?></span>
      </div>
    <?php endif ?>

    <?php endif ?>


    <?php // Le libellé dd_typemagie ne vaut qu'en DD3.5 : en DD2024 cla_mag_id
          // n'est plus qu'un drapeau 0/1 et pointerait sur « Magie profane »
          // pour un Clerc (D-MAG2). ?>
    <?php if ($ruleset === 'DD3.5' && $cla['mag_nom']): ?>
      <div class="sort-detail__row">
        <span class="sort-detail__label">Magie</span>
        <span class="sort-detail__value"><?= h($cla['mag_nom']) ?></span>
      </div>
    <?php endif ?>

    <?php if ($cla['cla_profil_incantation']): ?>
      <div class="sort-detail__row">
        <span class="sort-detail__label">Incantation</span>
        <span class="sort-detail__value"><?= libVar($db, (int)$cla['cla_profil_incantation']) ?></span>
      </div>
    <?php endif ?>

    <?php if ($cla['cla_renouvellement']): ?>
      <div class="sort-detail__row">
        <span class="sort-detail__label">Renouvellement</span>
        <span class="sort-detail__value"><?= libVar($db, (int)$cla['cla_renouvellement']) ?></span>
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
          <span class="sort-detail__label">Maîtrise des jets de sauvegarde</span>
          <span class="sort-detail__value"><?= h($cla['cla_sauvegardes']) ?></span>
        </div>
      <?php endif ?>

    <?php endif ?>

    <?php // ---- Compétences — dd_classe_competence n'a pas le même sens
          // d'un ruleset à l'autre :
          //   *[DD3.5]*  compétences DE CLASSE — un point investi y vaut 1 rang
          //              (1/2 ailleurs), le nombre de points par niveau étant
          //              cla_pointsCompetences.
          //   *[DD2024]* compétences ÉLIGIBLES — le personnage en choisit
          //              cla_pointsCompetences (SP-IM7).
          // Sans liste fermée (le Barde choisit parmi les 18), aucune ligne
          // n'est stockée et on retombe sur le texte libre cla_competences. ?>
    <?php $nbChoixComp = (int)$cla['cla_pointsCompetences']; ?>
    <?php if (!empty($competences)): ?>
      <div class="sort-detail__row">
        <span class="sort-detail__label"><?= $ruleset === 'DD2024' ? 'Maîtrises de compétence' : 'Compétences de classe' ?></span>
        <div class="sort-detail__value">
          <?php if ($ruleset === 'DD2024' && $nbChoixComp > 0): ?>
            <em><?= $nbChoixComp ?> au choix parmi :</em>
          <?php endif ?>
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
    <?php elseif ($ruleset === 'DD2024' && $cla['cla_competences']): ?>
      <div class="sort-detail__row">
        <span class="sort-detail__label">Maîtrises de compétence</span>
        <div class="sort-detail__value"><?= h($cla['cla_competences']) ?></div>
      </div>
    <?php endif ?>

    <?php // ---- Armes (et armures en DD3.5)
          // En DD3.5 cla_armes sort d'un éditeur TinyMCE : rendu brut.
          // En DD2024 les quatre champs de l'encadré « Traits de base » sortent
          // de textarea simples : ils passent par h() (règle projet), avec
          // nl2br() pour conserver les retours à la ligne saisis. ?>
    <?php if ($cla['cla_armes']): ?>
      <div class="sort-detail__row">
        <span class="sort-detail__label"><?= $ruleset === 'DD3.5' ? 'Armes &amp; armures' : 'Maîtrises d\'arme' ?></span>
        <div class="sort-detail__value sort-detail__value--html">
          <?= $ruleset === 'DD3.5' ? $cla['cla_armes'] : nl2br(h($cla['cla_armes'])) ?>
        </div>
      </div>
    <?php endif ?>

    <?php // ---- Outils DD2024 ?>
    <?php if ($ruleset === 'DD2024' && $cla['cla_outils']): ?>
      <div class="sort-detail__row">
        <span class="sort-detail__label">Maîtrises d'outils</span>
        <div class="sort-detail__value sort-detail__value--html"><?= nl2br(h($cla['cla_outils'])) ?></div>
      </div>
    <?php endif ?>

    <?php // ---- Armures DD2024 ?>
    <?php if ($ruleset === 'DD2024' && $cla['cla_armures']): ?>
      <div class="sort-detail__row">
        <span class="sort-detail__label">Formation aux armures</span>
        <div class="sort-detail__value sort-detail__value--html"><?= nl2br(h($cla['cla_armures'])) ?></div>
      </div>
    <?php endif ?>

    <?php // ---- Équipement de départ DD2024 — ligne pleine largeur, c'est le
          // champ le plus long de l'encadré (jusqu'à trois options A/B/C). ?>
    <?php if ($ruleset === 'DD2024' && $cla['cla_equipement']): ?>
      <div class="sort-detail__row sort-detail__row--full">
        <span class="sort-detail__label">Équipement de départ</span>
        <div class="sort-detail__value sort-detail__value--html"><?= nl2br(h($cla['cla_equipement'])) ?></div>
      </div>
    <?php endif ?>

    <?php // ---- Sous-classes rattachées (classe de base) ?>
    <?php if (!empty($sousClasses)): ?>
      <div class="sort-detail__row">
        <span class="sort-detail__label">Sous-classes</span>
        <div class="sort-detail__value">
          <?php foreach ($sousClasses as $i => $sc): ?>
            <?php if ($i > 0) echo ', ' ?>
            <span class="lien-sub"
                  onclick="naviguerDetailPP('<?= BASE_URL ?>/include/ajax/detail-pp/classe.php', {id:<?= (int)$sc['cla_id'] ?>})"
                  title="Voir la sous-classe">
              <?= h($sc['cla_nom']) ?>
            </span>
          <?php endforeach ?>
        </div>
      </div>
    <?php endif ?>

  </div>

  <?php // ---- Description ?>
  <?php if ($cla['cla_description']): ?>
    <div class="sort-detail__description" style="margin:.75rem 0;">
      <?= rendreTexteEnrichi($db, $cla['cla_description']) ?>
    </div>
  <?php endif ?>

  <?php // ---- Tableau de progression par niveau ?>
  <?php if (!empty($niveaux)): ?>
    <?php
    // DD2024 : colonnes sorts = Min. + Prép. + niv 1-9 = 11 cols si lanceur de sorts
    // DD3.5  : colonnes sorts = niv 0-9 = 10 cols
    $nbColsPouvoirs = count($activePouvoirs);
    if ($ruleset === 'DD2024'):
      $nbColsStats = 1; // Bonus maîtrise
      if ($isLanceurSorts):
        // Min. | Prép. | N1..N9
        $nbColsSorts  = 11;
        $lblGroupSort = 'Nombre de sorts par jour';
      else:
        $nbColsSorts  = 0;
        $lblGroupSort = '';
      endif;
    else:
      $nbColsStats = 4; // BBA + Réf + Vig + Vol
      $nbColsSorts = $isLanceurSorts ? 10 : 0;
      $lblGroupSort = 'Nombre de sorts par jour';
    endif;
    // Colonnes avant les sorts : Niv + stats + Aptitudes + Pouvoirs
    $colsBefore = 1 + $nbColsStats + 1 + $nbColsPouvoirs;
    ?>
    <div class="classe-detail__niveaux table-dd-wrap" style="margin-top:1rem;">
      <p class="classe-detail__table-titre">
        <strong>Table de progression : <?= h($cla['cla_nom']) ?></strong>
      </p>

      <?php // Sans colonnes de sorts, la table peut tenir dans un téléphone (SP-MA6). ?>
      <table class="table-dd<?= ($isLanceurSorts && !$progressionNls) ? '' : ' table-dd--etroite' ?>" id="classe-niv-table">
        <thead>
          <?php if ($isLanceurSorts && !$progressionNls): ?>
          <tr class="thead-groupes">
            <th colspan="<?= $colsBefore ?>"></th>
            <th colspan="<?= $nbColsSorts ?>" class="th-groupe-sorts"><?= $lblGroupSort ?></th>
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
            <?php if ($isLanceurSorts && !$progressionNls): ?>
              <?php if ($ruleset === 'DD2024'): ?>
                <th class="col-sort" title="Sorts mineurs (niveau 0)">Min.</th>
                <th class="col-sort" title="Sorts préparés">Prép.</th>
                <?php for ($s = 1; $s <= 9; $s++): ?>
                  <th class="col-sort">N<?= $s ?></th>
                <?php endfor ?>
              <?php else: ?>
                <?php for ($s = 0; $s <= 9; $s++): ?>
                  <th class="col-sort"><?= $s ?></th>
                <?php endfor ?>
              <?php endif ?>
            <?php elseif ($progressionNls): ?>
              <th class="col-nls" title="Niveau de lanceur de sorts gagné par une classe de base">Sorts par jour</th>
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
            $niveau = (int)$niv['cn_niveau'];
            ?>
            <tr>
              <td class="col-niv"><strong><?= $niveau ?></strong></td>
              <?php if ($ruleset === 'DD3.5'): ?>
                <td class="col-stat"><?= h($niv['cn_bba'] ?? '') ?></td>
                <td class="col-stat">+<?= (int)($niv['cn_reflexes'] ?? 0) ?></td>
                <td class="col-stat">+<?= (int)($niv['cn_vigueur']  ?? 0) ?></td>
                <td class="col-stat">+<?= (int)($niv['cn_volonte']  ?? 0) ?></td>
              <?php else: ?>
                <td class="col-stat">
                  <?= isset($bonusMaitrise[$niveau]) ? '+' . $bonusMaitrise[$niveau] : '—' ?>
                </td>
              <?php endif ?>
              <td class="col-aptitudes"><?= $caps_html ?></td>
              <?php foreach ($activePouvoirs as $p): ?>
                <td class="col-pouvoir"><?= h((string)($niv['cn_pouvoir' . $p] ?? '—')) ?></td>
              <?php endforeach ?>
              <?php if ($isLanceurSorts && !$progressionNls): ?>
                <?php if ($ruleset === 'DD2024'): ?>
                  <td class="col-sort"><?= $niv['cn_sort_n0'] !== null && $niv['cn_sort_n0'] !== '' ? (int)$niv['cn_sort_n0'] : '—' ?></td>
                  <td class="col-sort"><?= $niv['cn_sortPrepare'] !== null && $niv['cn_sortPrepare'] !== '' ? (int)$niv['cn_sortPrepare'] : '—' ?></td>
                  <?php for ($s = 1; $s <= 9; $s++): ?>
                    <td class="col-sort"><?= $niv['cn_sort_n' . $s] !== null && $niv['cn_sort_n' . $s] !== '' ? (int)$niv['cn_sort_n' . $s] : '—' ?></td>
                  <?php endfor ?>
                <?php else: ?>
                  <?php for ($s = 0; $s <= 9; $s++): ?>
                    <td class="col-sort"><?= $niv['cn_sort_n' . $s] !== null && $niv['cn_sort_n' . $s] !== '' ? (int)$niv['cn_sort_n' . $s] : '—' ?></td>
                  <?php endfor ?>
                <?php endif ?>
              <?php elseif ($progressionNls): ?>
                <td class="col-nls"><?= h($libelleProgressionNls($niv)) ?></td>
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
    if ($ruleset === 'DD3.5' && (int)$cla['cla_profil_incantation'] === PROFINC_REPERTOIRE && !empty($niveaux)):
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
      <table class="table-dd">
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
  <?php // Pas de libellé de section : chaque titre "Niveau X : Nom" se suffit
        // et sert de séparation visuelle. Mise en forme dans compendium-modules.css. ?>
  <?php if (!empty($capacites)): ?>
    <div class="classe-detail__capacites">
      <?php foreach ($capacites as $cap): ?>
        <div class="classe-detail__capacite" id="capacite-<?= (int)$cap['cap_id'] ?>">
          <div class="classe-detail__capacite-nom">
            <?php // cc_niveau = 0 existe en DD3.5 sur quelques affectations non
                  // renseignées : on affiche alors le nom seul plutôt qu'un
                  // "Niveau 0" qui n'existe pas dans les règles. ?>
            <?php if ((int)$cap['cap_niveau'] > 0): ?>Niveau <?= (int)$cap['cap_niveau'] ?> : <?php endif ?><?= h($cap['cap_nom']) ?>
            <?php if ($cap['cap_type']): ?>
              <span class="cap-type">(<?= h($cap['cap_type']) ?>)</span>
            <?php endif ?>
          </div>
          <?php if ($cap['cap_description']): ?>
            <div class="classe-detail__capacite-desc">
              <?= rendreTexteEnrichi($db, $cap['cap_description']) ?>
            </div>
          <?php endif ?>
        </div>
      <?php endforeach ?>
    </div>
  <?php endif ?>

  <?php // ---- Pied de fiche ?>
  <div class="sort-detail__footer" style="margin-top:1rem;">
    <?php // Le LEFT JOIN sur dd_ressources rend res_nom NULL quand cla_res_id ne
          // désigne aucune ressource — c'est le cas de l'Ensorceleur DD3.5
          // (cla_res_id = 0), dont la fiche plantait ici en PHP 8 (D-CL0).
          // Le défaut de DONNÉE reste à corriger ; le rendu, lui, ne doit pas
          // tomber pour autant. ?>
    <span class="sort-detail__source">
      <i class="fa fa-book"></i> <?= h($cla['res_nom'] ?? 'Source inconnue') ?>
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
   Styles locaux au panel classe
   Les colonnes de la table de progression (.col-niv, .col-stat,
   .col-sort, .col-pouvoir, .col-aptitudes) et les en-têtes
   (.thead-groupes, .th-groupe-sorts) sont gérés par .table-dd
   dans modules.css (chargé sur toutes les pages).
   ============================================================ */

/* Titre de table */
.classe-detail__table-titre {
  margin: 0 0 .3rem;
  font-size: .9rem;
}

/* Liens cliquables vers le sous-panel */
.lien-sub {
  cursor: pointer;
  color: var(--clr-accent);
  text-decoration: underline dotted;
}
.lien-sub:hover {
  text-decoration: underline;
}
</style>


