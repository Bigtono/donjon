<?php
// include/ajax/detail-pp/objet.php
// Retourne le HTML de détail d'un objet magique pour #detail-pp
// Paramètres GET : id (int)

require_once __DIR__ . '/../../db.php';
require_once __DIR__ . '/../../auth.php';
require_once __DIR__ . '/../../helpers.php';

requireAuth();

$id = intParam($_GET['id'] ?? $_POST['id'] ?? 0);

if (!$id):
  http_response_code(400);
  echo '<p class="erreur">Identifiant manquant.</p>';
  exit;
endif;

$stmt = $db->prepare('
  SELECT
    om.*,
    com.com_nom,
    com.com_est_calcule,
    res.res_nom,
    var.var_valeur AS ruleset_label
  FROM   dd_objets_magiques            om
  LEFT JOIN dd_categorie_objet_magique com ON com.com_id = om.om_com_id
  LEFT JOIN dd_ressources              res ON res.res_id = om.om_res_id
  LEFT JOIN dd_variables               var ON var.var_id = om.om_ruleset_var_id
  WHERE  om.om_id = ?
');
$stmt->execute([$id]);
$om = $stmt->fetch();

if (!$om):
  http_response_code(404);
  echo '<p class="erreur">Objet magique introuvable.</p>';
  exit;
endif;

// Masquage aux non-éditeurs si invisible
if (!canEditCompendium() && !(int)$om['om_visible']):
  http_response_code(403);
  echo '<p class="erreur">Accès refusé.</p>';
  exit;
endif;

$ruleset_rep = $_SESSION['rulesetRep'] ?? 'DD3.5';

// Le calcul auto NLS/prix est DD3.5 uniquement, pour les catégories marquées
// com_est_calcule=1 et avec le format "auto" (om_fom_id=1)
$calcule = $ruleset_rep === 'DD3.5'
  && (int)$om['com_est_calcule'] === 1
  && (int)$om['om_fom_id'] === 1;

// Préparation du contenu de description
$contenu_description = '';

if ($calcule && $om['om_so_id']):
  // ---- Objets à sort lié : baguettes, parchemins, potions ----
  $stmt_so = $db->prepare('
    SELECT so.so_id, so.so_nom, co.co_nom AS college
    FROM   dd_sorts   so
    LEFT JOIN dd_colleges co ON co.co_id = so.so_co_id
    WHERE  so.so_id = ?
  ');
  $stmt_so->execute([(int)$om['om_so_id']]);
  $so = $stmt_so->fetch();

  if ($so):
    // Calcul NLS : MIN niveau mage (cla_id=6) ou prêtre (cla_id=9)
    $stmt_sc = $db->prepare('
      SELECT sc_cla_id, sc_niveau
      FROM   dd_sortclasse
      WHERE  sc_so_id = ?
        AND  sc_cla_id IN (6, 9)
    ');
    $stmt_sc->execute([(int)$om['om_so_id']]);
    $niveaux = $stmt_sc->fetchAll();

    $niv_mage = $niv_pretre = null;
    foreach ($niveaux as $sc):
      if ((int)$sc['sc_cla_id'] === 6) $niv_mage   = (int)$sc['sc_niveau'];
      if ((int)$sc['sc_cla_id'] === 9) $niv_pretre = (int)$sc['sc_niveau'];
    endforeach;

    $niveau_base = $niv_mage ?? $niv_pretre ?? 0;
    $nls_auto    = $niveau_base > 0 ? (2 * $niveau_base) - 1 : 0;
    $nls         = (int)$om['om_so_niveau'] > $nls_auto
      ? (int)$om['om_so_niveau']
      : $nls_auto;
    $nls = max($nls, 1);

    $college  = h($so['college'] ?? '');
    $so_nom   = h($so['so_nom'] ?? '');
    $so_id    = (int)$so['so_id'];
    $lien_sort = '<span class="om-lien-sort"'
      . ' onclick="actualiserPage(\''
      . BASE_URL . '/include/ajax/detail-pp/sort.php\', {id:' . $so_id . '})">'
      . $so_nom . '</span>';

    $com_id = (int)$om['om_com_id'];

    ob_start();
    if ($com_id === 15):
      // Potion / Huile
      $prix = 50 * $niveau_base * $nls;
      $cout = (int)round($prix / 2);
      $xp   = (int)round($prix / 25);
      echo '<p>Cette potion ou huile reproduit les effets du sort ' . $lien_sort . '.</p>';
      echo '<p>' . ($college ? $college . ' ; ' : '');
      echo 'NLS ' . $nls . ' ; Préparation de potions, ' . $so_nom . ' ; ';
      echo 'Prix ' . number_format($prix, 0, ',', ' ') . ' po ; ';
      echo 'Coût ' . number_format($cout, 0, ',', ' ') . ' po, ' . $xp . ' PX.</p>';
    elseif ($com_id === 4):
      // Baguette
      $prix = 750 * $niveau_base * $nls;
      $cout = (int)round($prix / 2);
      $xp   = (int)round($prix / 25);
      echo '<p>Cette baguette possède 50 charges du sort ' . $lien_sort
        . ', lancé au niveau ' . $nls . ' de lanceur de sorts.</p>';
      echo '<p>' . ($college ? $college . ' ; ' : '');
      echo 'NLS ' . $nls . ' ; Création de baguettes magiques, ' . $so_nom . ' ; ';
      echo 'Prix ' . number_format($prix, 0, ',', ' ') . ' po ; ';
      echo 'Coût ' . number_format($cout, 0, ',', ' ') . ' po, ' . $xp . ' PX.</p>';
    elseif ($com_id === 14):
      // Parchemin
      $prix = 25 * $niveau_base * $nls;
      $cout = (int)round($prix / 2);
      $xp   = (int)round($prix / 25);
      echo '<p>Ce parchemin permet de lancer le sort ' . $lien_sort
        . ' au niveau ' . $nls . ' de lanceur de sorts.</p>';
      echo '<p>' . ($college ? $college . ' ; ' : '');
      echo 'NLS ' . $nls . ' ; Écriture de parchemins, ' . $so_nom . ' ; ';
      echo 'Prix ' . number_format($prix, 0, ',', ' ') . ' po ; ';
      echo 'Coût ' . number_format($cout, 0, ',', ' ') . ' po, ' . $xp . ' PX.</p>';
    else:
      // Autre catégorie est_calcule=1 avec sort → description libre
      if ($om['om_description']) echo $om['om_description'];
    endif;
    $contenu_description = ob_get_clean();

  else:
    // Sort introuvable → repli sur description libre
    $contenu_description = $om['om_description'] ?? '';
  endif;

elseif ($calcule && !$om['om_so_id'] && in_array((int)$om['om_com_id'], [2, 3])):
  // ---- Armes et armures : calcul via modificateur ----
  $mod = (int)$om['om_modificateurs'];
  $nls = 3 * max($mod, 1);

  ob_start();
  if ((int)$om['om_com_id'] === 2):
    // Arme
    $prix = match ($mod) {
      2 => 8000, 3 => 18000, 4 => 32000, 5 => 50000, default => 2000,
    };
    $cout = (int)round($prix / 2);
    $xp   = (int)round($prix / 25);
    echo '<p>Cette arme possède un modificateur au toucher et aux dégâts de +' . $mod . '.</p>';
    echo '<p>NLS ' . $nls . ' ; Création d\'armes et armures magiques ; ';
    echo 'Prix ' . number_format($prix, 0, ',', ' ') . ' po ; ';
    echo 'Coût ' . number_format($cout, 0, ',', ' ') . ' po, ' . $xp . ' PX.</p>';
  else:
    // Armure / Bouclier
    $prix = 1000 * $mod * $mod;
    $cout = (int)round($prix / 2);
    $xp   = (int)round($prix / 25);
    echo '<p>Cette armure ou ce bouclier possède un bonus magique de +' . $mod . '.</p>';
    echo '<p>NLS ' . $nls . ' ; Création d\'armes et armures magiques ; ';
    echo 'Prix ' . number_format($prix, 0, ',', ' ') . ' po ; ';
    echo 'Coût ' . number_format($cout, 0, ',', ' ') . ' po, ' . $xp . ' PX.</p>';
  endif;
  $contenu_description = ob_get_clean();

else:
  // ---- Format libre (tous rulesets, toutes catégories non calculées) ----
  $contenu_description = $om['om_description'] ?? '';
endif;
?>

<div class="sort-detail">

  <!-- En-tête : nom + bouton modifier -->
  <div class="sort-detail__header">
    <h2 class="sort-detail__nom">
      <?= h($om['om_nom']) ?>
      <?php if (!$om['om_visible']): ?>
        <span class="badge-invisible" title="Masqué aux joueurs">
          <i class="fa fa-eye-slash"></i>
        </span>
      <?php endif ?>
      <?php if (canEditCompendium()): ?>
        <button class="sort-detail__edit-btn"
                onclick="ouvrirModifier('<?= BASE_URL ?>/include/ajax/modifier/objet.php', <?= $id ?>)"
                title="Modifier cet objet magique">
          <i class="fa fa-edit"></i>
        </button>
      <?php endif ?>
    </h2>

    <!-- Sous-titre : catégorie + variantes + modificateur -->
    <?php
    $meta = [];
    if ($om['com_nom'])          $meta[] = h($om['com_nom']);
    if ($om['om_variantes'])     $meta[] = h($om['om_variantes']);
    if ($om['om_modificateurs'] > 0) $meta[] = '+' . (int)$om['om_modificateurs'];
    ?>
    <?php if (!empty($meta)): ?>
      <p class="sort-detail__college">
        <?= implode(' · ', $meta) ?>
      </p>
    <?php endif ?>
  </div>

  <!-- Description -->
  <?php if ($contenu_description): ?>
    <div class="sort-detail__description">
      <?= $contenu_description ?>
    </div>
  <?php endif ?>

  <!-- Pied de fiche -->
  <div class="sort-detail__footer">
    <span class="sort-detail__source">
      <i class="fa fa-book"></i> <?= h($om['res_nom']) ?>
    </span>
    <span class="sort-detail__ruleset"><?= h($om['ruleset_label']) ?></span>
  </div>

</div>
