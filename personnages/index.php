<?php
// personnages/index.php — Liste des personnages du joueur courant, filtrés par ruleset actif.
// Liste dédiée (pas le moteur compendium-liste) : scope strict par propriétaire.
// Filtres : campagne, classe, recherche libre sur le nom.
require_once '../include/db.php';
require_once '../include/auth.php';
require_once '../include/helpers.php';

requireAuth();

$page_title = 'Personnages';
$js_module  = 'personnage';
$css_module = 'personnages';

$j_id        = (int)$_SESSION['j_id'];
$ruleset_id  = (int)($_SESSION['ruleset_var_id'] ?? 1);
$ruleset_rep = $_SESSION['rulesetRep'] ?? 'DD3.5';

// ============================================================
// LECTURE DES FILTRES (GET)
// ============================================================
$f_camp_id = intParam($_GET['f_camp_id'] ?? 0);
$f_cla_id  = intParam($_GET['f_cla_id']  ?? 0);
$q         = trim(strParam($_GET['q']    ?? ''));

// ============================================================
// CONSTRUCTION DE LA REQUÊTE
// ============================================================
$where  = ['pe.pe_j_id = ?', 'pe.pe_ruleset_var_id = ?'];
$params = [$j_id, $ruleset_id];

if ($f_camp_id > 0):
  $where[]  = 'pe.pe_camp_id = ?';
  $params[] = $f_camp_id;
endif;

if ($f_cla_id > 0):
  $where[]  = 'EXISTS (SELECT 1 FROM dd_personnages_classes pc
                       WHERE  pc.pc_pe_id  = pe.pe_id
                         AND  pc.pc_cla_id = ?)';
  $params[] = $f_cla_id;
endif;

if ($q !== ''):
  $where[]  = 'pe.pe_nom LIKE ?';
  $params[] = '%' . $q . '%';
endif;

$sql = '
  SELECT pe.pe_id,
         pe.pe_nom,
         pe.pe_camp_id,
         ra_base.ra_nom    AS race_nom,
         ra_arc.ra_nom     AS archetype_nom,
         al.al_abreviation AS alignement,
         camp.camp_nom     AS campagne_nom,
         (SELECT GROUP_CONCAT(CONCAT(cla.cla_nom, " ", pc.pc_niveau) ORDER BY cla.cla_nom SEPARATOR " / ")
            FROM dd_personnages_classes pc
            JOIN dd_classes cla ON cla.cla_id = pc.pc_cla_id
           WHERE pc.pc_pe_id = pe.pe_id) AS classes_libelle
  FROM   dd_personnages pe
  LEFT JOIN dd_races       ra_base ON ra_base.ra_id = pe.pe_ra_id
  LEFT JOIN dd_races       ra_arc  ON ra_arc.ra_id  = pe.pe_arc_id AND pe.pe_arc_id > 0
  LEFT JOIN dd_alignements al      ON al.al_id      = pe.pe_al_id
  LEFT JOIN dd_campagnes   camp    ON camp.camp_id  = pe.pe_camp_id
  WHERE  ' . implode(' AND ', $where) . '
  ORDER  BY pe.pe_nom ASC
';
$stmt = $db->prepare($sql);
$stmt->execute($params);
$personnages = $stmt->fetchAll();

// ============================================================
// DONNÉES POUR LES SELECTS DE FILTRES
// ============================================================
// Campagnes du joueur (un perso n'évolue que dans les campagnes de son joueur)
$stmt = $db->prepare('
  SELECT camp.camp_id, camp.camp_nom
    FROM dd_campagnes camp
   WHERE camp.camp_j_id = ?
     AND camp.camp_ruleset_var_id = ?
     AND camp.camp_supprime = 0
   ORDER BY camp.camp_nom
');
$stmt->execute([$j_id, $ruleset_id]);
$campagnes_filtre = $stmt->fetchAll();

// Classes du ruleset (toutes confondues : base + prestige)
$stmt = $db->prepare('
  SELECT cla.cla_id, cla.cla_nom
    FROM dd_classes cla
   WHERE cla.cla_ruleset_var_id = ?
   ORDER BY cla.cla_nom
');
$stmt->execute([$ruleset_id]);
$classes_filtre = $stmt->fetchAll();

// Compte des filtres actifs (pour badge mobile éventuel)
$filtres_actifs = 0;
if ($f_camp_id > 0) $filtres_actifs++;
if ($f_cla_id  > 0) $filtres_actifs++;
if ($q !== '')      $filtres_actifs++;

require_once '../include/header.php';
?>

<script>
  var perUrlDetail   = <?= json_encode(BASE_URL . '/include/ajax/detail-pp/personnage.php') ?>;
  var perUrlModifier = <?= json_encode(BASE_URL . '/include/ajax/modifier/personnage.php') ?>;
  var perUrlEnreg    = <?= json_encode(BASE_URL . '/personnages/enregistrement.php?ajax=1') ?>;
  var perUrlFiche    = <?= json_encode(BASE_URL . '/personnages/fiche.php') ?>;
</script>

<div class="flex-between mb-md">
  <h1>Personnages <span class="text-muted text-sm">(<?= h($ruleset_rep) ?>)</span></h1>
  <button class="btn btn-primary btn-sm" onclick="ouvrirModifier(perUrlModifier, 0)">
    <i class="fa fa-plus"></i> Nouveau personnage
  </button>
</div>

<!-- ============================================================
     BARRE DE FILTRES
     ============================================================ -->
<form method="get" class="per-filtres" id="perFiltresForm">
  <div class="per-filtres__bloc">
    <label for="f_camp_id" class="per-filtres__label">Campagne</label>
    <select id="f_camp_id" name="f_camp_id" onchange="document.getElementById('perFiltresForm').submit()">
      <option value="0">— Toutes —</option>
      <?php foreach ($campagnes_filtre as $c): ?>
        <option value="<?= (int)$c['camp_id'] ?>" <?= $f_camp_id === (int)$c['camp_id'] ? 'selected' : '' ?>>
          <?= h($c['camp_nom']) ?>
        </option>
      <?php endforeach ?>
    </select>
  </div>

  <div class="per-filtres__bloc">
    <label for="f_cla_id" class="per-filtres__label">Classe</label>
    <select id="f_cla_id" name="f_cla_id" onchange="document.getElementById('perFiltresForm').submit()">
      <option value="0">— Toutes —</option>
      <?php foreach ($classes_filtre as $c): ?>
        <option value="<?= (int)$c['cla_id'] ?>" <?= $f_cla_id === (int)$c['cla_id'] ? 'selected' : '' ?>>
          <?= h($c['cla_nom']) ?>
        </option>
      <?php endforeach ?>
    </select>
  </div>

  <div class="per-filtres__bloc per-filtres__bloc--recherche">
    <label for="q" class="per-filtres__label">Recherche</label>
    <input type="text" id="q" name="q" value="<?= h($q) ?>" placeholder="Nom du personnage…">
  </div>

  <div class="per-filtres__bloc per-filtres__bloc--actions">
    <button type="submit" class="btn btn-secondary btn-sm">
      <i class="fa fa-filter"></i> Filtrer
    </button>
    <?php if ($filtres_actifs > 0): ?>
      <a href="<?= BASE_URL ?>/personnages/" class="btn btn-link btn-sm">Réinitialiser</a>
    <?php endif ?>
  </div>
</form>

<!-- ============================================================
     LISTE DES PERSONNAGES
     ============================================================ -->
<?php if (empty($personnages)): ?>

  <p class="text-muted">
    <?php if ($filtres_actifs > 0): ?>
      Aucun personnage ne correspond aux filtres en cours.
    <?php else: ?>
      Aucun personnage pour le moment. Créez-en un pour commencer.
    <?php endif ?>
  </p>

<?php else: ?>

  <div class="table-scroll">
    <table class="per-liste">
      <thead>
        <tr>
          <th class="col-action"></th>
          <th>Nom</th>
          <th class="per-liste__col-sec">Race</th>
          <th class="per-liste__col-sec">Classes</th>
          <th class="per-liste__col-sec per-liste__col-align">Alignement</th>
          <th class="per-liste__col-sec">Campagne en cours</th>
        </tr>
      </thead>
      <tbody>

        <?php foreach ($personnages as $perso): ?>
          <?php
            $pid       = (int)$perso['pe_id'];
            $race_aff  = h($perso['race_nom'] ?? '—');
            if (!empty($perso['archetype_nom'])):
              $race_aff .= ' / ' . h($perso['archetype_nom']);
            endif;
            $classes_aff = $perso['classes_libelle']
              ? h($perso['classes_libelle'])
              : '<span class="text-muted">—</span>';
            $align_aff = $perso['alignement']
              ? h($perso['alignement'])
              : '<span class="text-muted">—</span>';
            $camp_aff  = $perso['campagne_nom']
              ? h($perso['campagne_nom'])
              : '<span class="text-muted">—</span>';
          ?>

          <tr id="per-row-<?= $pid ?>">

            <!-- Menu contextuel -->
            <td class="col-action">
              <div class="comp-menu-ligne">
                <button class="btn btn-icon btn-sm comp-menu-btn"
                        onclick="perToggleMenu(<?= $pid ?>)"
                        title="Actions">⋮</button>
                <div id="comp-menu-<?= $pid ?>" class="comp-menu-dropdown noDisplay">
                  <button class="comp-menu-item"
                          onclick="perToggleMenu(<?= $pid ?>); ouvrirModifier(perUrlModifier, <?= $pid ?>)">
                    <i class="fa fa-edit"></i> Modifier
                  </button>
                  <button class="comp-menu-item comp-menu-item--danger"
                          onclick="perToggleMenu(<?= $pid ?>); perDemanderSuppression(<?= $pid ?>)">
                    <i class="fa fa-trash"></i> Supprimer
                  </button>
                </div>
              </div>
              <!-- Template de confirmation inline -->
              <div id="per-confirm-<?= $pid ?>" class="comp-confirm-suppr noDisplay">
                <span>Supprimer « <?= h($perso['pe_nom']) ?> » et ses données associées ?</span>
                <button class="btn btn-danger btn-sm"
                        onclick="perConfirmerSuppression(<?= $pid ?>)">Oui</button>
                <button class="btn btn-secondary btn-sm"
                        onclick="perAnnulerSuppression(<?= $pid ?>)">Non</button>
              </div>
            </td>

            <!-- Cellules données — clic → fiche personnage -->
            <td class="per-liste__nom"
                onclick="window.location='<?= BASE_URL ?>/personnages/fiche.php?id=<?= $pid ?>'"
                style="cursor:pointer">
              <span class="per-liste__nom-libelle"><?= h($perso['pe_nom']) ?></span>
              <!-- Résumé mobile : race · classes · alignement · campagne sous le nom -->
              <span class="per-liste__resume-mobile">
                <?= $race_aff ?>
                <?php if ($perso['classes_libelle']): ?> · <?= h($perso['classes_libelle']) ?><?php endif ?>
                <?php if ($perso['alignement']):       ?> · <?= h($perso['alignement']) ?><?php endif ?>
                <?php if ($perso['campagne_nom']):     ?> · <?= h($perso['campagne_nom']) ?><?php endif ?>
              </span>
            </td>
            <td class="per-liste__col-sec"
                onclick="window.location='<?= BASE_URL ?>/personnages/fiche.php?id=<?= $pid ?>'"
                style="cursor:pointer">
              <?= $race_aff ?>
            </td>
            <td class="per-liste__col-sec"
                onclick="window.location='<?= BASE_URL ?>/personnages/fiche.php?id=<?= $pid ?>'"
                style="cursor:pointer">
              <?= $classes_aff ?>
            </td>
            <td class="per-liste__col-sec per-liste__col-align"
                onclick="window.location='<?= BASE_URL ?>/personnages/fiche.php?id=<?= $pid ?>'"
                style="cursor:pointer">
              <?= $align_aff ?>
            </td>
            <td class="per-liste__col-sec"
                onclick="window.location='<?= BASE_URL ?>/personnages/fiche.php?id=<?= $pid ?>'"
                style="cursor:pointer">
              <?= $camp_aff ?>
            </td>

          </tr>
        <?php endforeach ?>

      </tbody>
    </table>
  </div>

<?php endif ?>

<?php require_once '../include/footer.php'; ?>
