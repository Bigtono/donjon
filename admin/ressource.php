<?php
// admin/ressource.php — Page d'une ressource : fiche, contenu rattaché par catégorie (SP-AD5)
// GET : id (res_id), onglet (clé de contenuRessourceTables()), q (recherche), page
// Remplace l'ancien panneau #detail-pp des ressources. La lecture d'une entrée
// passe, elle, par les fiches include/ajax/detail-pp/*.php existantes.
require_once '../include/db.php';
require_once '../include/auth.php';
require_once '../include/helpers.php';

requireAdmin();

$res_id = intParam($_GET['id'] ?? 0);

$stmt = $db->prepare('
  SELECT res.*,
         var.var_valeur AS ruleset_label,
         prop.j_pseudo  AS proprietaire_pseudo
  FROM   dd_ressources res
  JOIN   dd_variables  var  ON var.var_id = res.res_ruleset_var_id
  LEFT JOIN dd_joueurs prop ON prop.j_id  = res.res_j_id
  WHERE  res.res_id = ?
');
$stmt->execute([$res_id]);
$res = $res_id ? $stmt->fetch() : false;

if (!$res):
  http_response_code(404);
  $page_title = 'Ressource introuvable';
  require_once '../include/header.php';
  echo '<p class="erreur">Ressource introuvable.</p>'
     . '<a href="' . h(BASE_URL) . '/admin/ressources.php" class="btn btn-secondary btn-sm">'
     . '<i class="fa fa-arrow-left"></i> Ressources</a>';
  require_once '../include/footer.php';
  exit;
endif;

$page_title = $res['res_nom'];
$js_module  = 'admin';
$css_module = 'admin';

// ============================================================
// Onglets : un par catégorie de contenu (clés = contenuRessourceTables())
// ============================================================

$tables    = contenuRessourceTables();
$compteurs = compterContenuRessource($db, $res_id);
$total     = array_sum($compteurs);

// Demande de suppression (SP-AD6) : analyse complète, affichée avant toute confirmation
$suppr   = intParam($_GET['suppr'] ?? 0) === 1;
$analyse = null;
if ($suppr):
  require_once '../include/ressource-suppression.php';
  $analyse = ressourceSuppressionAnalyse($db, $res_id);
endif;

// Onglet demandé validé par liste blanche ; à défaut, le premier non vide
$onglet = strParam($_GET['onglet'] ?? '');
if (!isset($tables[$onglet])):
  $onglet = '';
  foreach ($compteurs as $cle => $nb):
    if ($nb > 0):
      $onglet = $cle;
      break;
    endif;
  endforeach;
endif;

// URL de la page pour un onglet donné (la recherche et la page repartent à zéro)
function urlOngletRessource(int $res_id, string $cle): string
{
  return BASE_URL . '/admin/ressource.php?' . http_build_query(['id' => $res_id, 'onglet' => $cle]);
}

// ============================================================
// Liste de l'onglet actif — table et champs viennent de la liste statique
// ============================================================

$q         = strParam($_GET['q'] ?? '');
$lignes    = [];
$pag       = null;
$nb_filtre = 0;

if ($onglet !== ''):
  $t        = $tables[$onglet];
  $where    = $t['champ'] . ' = ?';
  $params   = [$res_id];
  if ($q !== ''):
    $where   .= ' AND ' . $t['nom'] . ' LIKE ?';
    $params[] = '%' . $q . '%';
  endif;

  $stmt = $db->prepare('SELECT COUNT(*) FROM ' . $t['table'] . ' WHERE ' . $where);
  $stmt->execute($params);
  $nb_filtre = (int)$stmt->fetchColumn();

  $per_page = (int)($_SESSION['j_items_par_page'] ?? 20);
  $pag      = getPagination($nb_filtre, $per_page, max(1, intParam($_GET['page'] ?? 1)));

  $stmt = $db->prepare(
    'SELECT ' . $t['id'] . ' AS _id, ' . $t['nom'] . ' AS _nom
       FROM ' . $t['table'] . '
      WHERE ' . $where . '
      ORDER BY ' . $t['nom'] . '
      LIMIT ? OFFSET ?'
  );
  $stmt->execute(array_merge($params, [$pag['per_page'], $pag['offset']]));
  $lignes = $stmt->fetchAll();
endif;

require_once '../include/header.php';
?>

<div id="res-page">

  <div class="flex-between mb-md">
    <h1>
      <?= h($res['res_nom']) ?>
      <?php if ((int)$res['res_selection']): ?>
        <i class="fa fa-star res-etoile" title="Active"></i>
      <?php endif ?>
    </h1>
    <div>
      <button type="button" class="btn btn-primary btn-sm"
              onclick="ouvrirModifier('<?= h(BASE_URL) ?>/include/ajax/modifier/ressource.php', <?= $res_id ?>)">
        <i class="fa fa-edit"></i> Modifier
      </button>
      <?php if (!$suppr): ?>
        <a href="<?= h(BASE_URL) ?>/admin/ressource.php?id=<?= $res_id ?>&amp;suppr=1" class="btn btn-danger btn-sm">
          <i class="fa fa-trash"></i> Supprimer…
        </a>
      <?php endif ?>
      <a href="<?= h(BASE_URL) ?>/admin/ressources.php" class="btn btn-secondary btn-sm">
        <i class="fa fa-arrow-left"></i> Ressources
      </a>
    </div>
  </div>

  <?php // ---- Suppression en cascade (SP-AD6) ---- ?>
  <?php if ($analyse !== null): ?>
    <section class="res-suppr" id="res-suppr">
      <h2 class="res-suppr__titre"><i class="fa fa-exclamation-triangle"></i> Supprimer cette ressource</h2>

      <?php if ($analyse['bloquee']): ?>
        <p class="res-suppr__refus">
          <i class="fa fa-lock"></i>
          Suppression impossible : les éléments ci-dessous dépendent de cette ressource. Modifiez-les d'abord.
        </p>

        <?php if ($analyse['personnages']): ?>
          <h3 class="res-suppr__sous-titre">Personnages (<?= count($analyse['personnages']) ?>)</h3>
          <ul class="res-suppr__liste">
            <?php foreach ($analyse['personnages'] as $pe_id => $p): ?>
              <li>
                <a href="<?= h(BASE_URL) ?>/personnages/fiche.php?id=<?= (int)$pe_id ?>"><?= h($p['nom']) ?></a>
                — <?= h(implode(' ; ', $p['elements'])) ?>
              </li>
            <?php endforeach ?>
          </ul>
        <?php endif ?>

        <?php if ($analyse['campagne']): ?>
          <h3 class="res-suppr__sous-titre">Notes de campagne (<?= count($analyse['campagne']) ?>)</h3>
          <ul class="res-suppr__liste">
            <?php foreach ($analyse['campagne'] as $c): ?>
              <li><?= h($c['libelle']) ?> : <?= h($c['detail']) ?></li>
            <?php endforeach ?>
          </ul>
        <?php endif ?>

        <?php if ($analyse['dependants']): ?>
          <h3 class="res-suppr__sous-titre">Contenu d'autres ressources (<?= count($analyse['dependants']) ?>)</h3>
          <ul class="res-suppr__liste">
            <?php foreach ($analyse['dependants'] as $d): ?>
              <li><?= h($d['libelle']) ?> : <?= h($d['nom']) ?> <span class="text-muted">(<?= h($d['ressource']) ?>)</span></li>
            <?php endforeach ?>
          </ul>
        <?php endif ?>

      <?php else: ?>
        <p>La ressource et <strong>tout ce qui lui est rattaché</strong> seront supprimés définitivement :</p>

        <?php if ($analyse['contenu'] || $analyse['liaisons']): ?>
          <ul class="res-suppr__liste">
            <?php foreach ($analyse['contenu'] as $c): ?>
              <li><strong><?= (int)$c['nb'] ?></strong> <?= h(mb_strtolower($c['libelle'])) ?></li>
            <?php endforeach ?>
            <?php foreach ($analyse['liaisons'] as $libelle => $nb): ?>
              <li class="text-muted"><?= (int)$nb ?> ligne(s) : <?= h($libelle) ?></li>
            <?php endforeach ?>
          </ul>
        <?php else: ?>
          <p class="text-muted">Aucun contenu rattaché.</p>
        <?php endif ?>

        <?php if ($analyse['liens_coupes']): ?>
          <h3 class="res-suppr__sous-titre">Liens coupés (les éléments restent)</h3>
          <ul class="res-suppr__liste">
            <?php foreach ($analyse['liens_coupes'] as $libelle => $nb): ?>
              <li><?= (int)$nb ?> : <?= h($libelle) ?></li>
            <?php endforeach ?>
          </ul>
        <?php endif ?>

        <?php if ($analyse['avertissements']): ?>
          <h3 class="res-suppr__sous-titre">Renvois textuels qui ne se résoudront plus</h3>
          <ul class="res-suppr__liste">
            <?php foreach ($analyse['avertissements'] as $a): ?>
              <li><?= h($a) ?></li>
            <?php endforeach ?>
          </ul>
        <?php endif ?>

        <?php $mot = ressourceMotDeConfirmation($analyse['ressource']); ?>
        <form method="POST" action="<?= h(BASE_URL) ?>/admin/enregistrement.php" class="res-suppr__form">
          <?= csrfField() ?>
          <input type="hidden" name="entite" value="ressource">
          <input type="hidden" name="action" value="supprimer">
          <input type="hidden" name="id" value="<?= $res_id ?>">
          <label for="res-suppr-confirmation">
            Cette opération est irréversible. Pour confirmer, saisissez <strong><?= h($mot) ?></strong> :
          </label>
          <div class="res-suppr__actions">
            <input type="text" id="res-suppr-confirmation" name="confirmation" autocomplete="off" required
                   class="comp-filtre-input">
            <button type="submit" class="btn btn-danger btn-sm">
              <i class="fa fa-trash"></i> Supprimer définitivement
            </button>
          </div>
        </form>
      <?php endif ?>

      <p class="res-suppr__annuler">
        <a href="<?= h(BASE_URL) ?>/admin/ressource.php?id=<?= $res_id ?>">Annuler</a>
      </p>
    </section>
  <?php endif ?>

  <?php // ---- Fiche ---- ?>
  <div class="admin-detail__header">
    <p class="admin-detail__pseudo">
      <span class="badge badge--ruleset"><?= h($res['ruleset_label']) ?></span>
      <span class="badge badge--abrev"><?= h($res['res_abreviation']) ?></span>
      <?php if ((int)$res['res_selection']): ?>
        <span class="badge badge--actif">Active</span>
      <?php endif ?>
    </p>
  </div>

  <div class="admin-detail__body">
    <?php if ($res['proprietaire_pseudo']): ?>
      <div class="sort-detail__row">
        <span class="sort-detail__label">Propriétaire (homebrew)</span>
        <span class="sort-detail__value"><?= h($res['proprietaire_pseudo']) ?></span>
      </div>
    <?php endif ?>
    <?php if ($res['res_editeur']): ?>
      <div class="sort-detail__row">
        <span class="sort-detail__label">Éditeur</span>
        <span class="sort-detail__value"><?= h($res['res_editeur']) ?></span>
      </div>
    <?php endif ?>
  </div>

  <?php if ($res['res_description']): ?>
    <div class="admin-detail__description">
      <?= $res['res_description'] ?>
    </div>
  <?php endif ?>

  <?php // ---- Contenu rattaché ---- ?>
  <div class="admin-detail__deps">
    <h2 class="admin-detail__deps-titre">Contenu rattaché</h2>

    <nav class="res-onglets" aria-label="Catégories de contenu">
      <?php foreach ($tables as $cle => $t): ?>
        <?php $nb = $compteurs[$cle]; ?>
        <?php if ($nb > 0): ?>
          <a href="<?= h(urlOngletRessource($res_id, $cle)) ?>"
             class="res-onglet<?= $cle === $onglet ? ' res-onglet--actif' : '' ?>">
            <?= h($t['label']) ?> <span class="badge badge--count"><?= $nb ?></span>
          </a>
        <?php else: ?>
          <span class="res-onglet res-onglet--vide">
            <?= h($t['label']) ?> <span class="text-muted">0</span>
          </span>
        <?php endif ?>
      <?php endforeach ?>
    </nav>

    <?php if ($total === 0): ?>
      <p class="text-muted">Aucun contenu rattaché.</p>
    <?php else: ?>
      <form class="comp-filtre-form" method="GET" action="">
        <input type="hidden" name="id" value="<?= $res_id ?>">
        <input type="hidden" name="onglet" value="<?= h($onglet) ?>">
        <div class="comp-filtre-row">
          <div class="comp-filtre-group comp-filtre-group--text">
            <input type="text" name="q" value="<?= h($q) ?>"
                   placeholder="Rechercher dans <?= h(mb_strtolower($tables[$onglet]['label'])) ?>…"
                   class="comp-filtre-input" autocomplete="off">
          </div>
          <div class="comp-filtre-group comp-filtre-group--actions">
            <button type="submit" class="btn btn-primary btn-sm">
              <i class="fa fa-search"></i> Filtrer
            </button>
            <a href="<?= h(urlOngletRessource($res_id, $onglet)) ?>" class="btn btn-secondary btn-sm"
               title="Réinitialiser"><i class="fa fa-times"></i></a>
          </div>
        </div>
      </form>

      <div class="comp-liste-info">
        <?php if ($nb_filtre === 0): ?>
          <span class="text-muted">Aucun résultat.</span>
        <?php else: ?>
          <span class="text-muted">
            <?= $nb_filtre ?> résultat<?= $nb_filtre > 1 ? 's' : '' ?> —
            page <?= $pag['current_page'] ?>/<?= $pag['total_pages'] ?>
          </span>
        <?php endif ?>
      </div>

      <?php if (!empty($lignes)): ?>
        <?php
          // Certaines catégories (domaines) n'ont pas de fiche de lecture : lignes non cliquables
          $url_fiche = $tables[$onglet]['detail'] !== null
            ? BASE_URL . '/include/ajax/detail-pp/' . $tables[$onglet]['detail']
            : null;
        ?>
        <div class="comp-liste-wrapper">
          <table class="table-std comp-liste res-liste">
            <tbody>
              <?php foreach ($lignes as $ligne): ?>
                <?php if ($url_fiche !== null): ?>
                  <tr class="comp-ligne"
                      onclick="actualiserPage(<?= h(json_encode($url_fiche)) ?>, {id: <?= (int)$ligne['_id'] ?>}, 'liste')">
                    <td class="col-primary"><?= h((string)$ligne['_nom']) ?></td>
                  </tr>
                <?php else: ?>
                  <tr class="res-ligne--inerte">
                    <td class="col-primary"><?= h((string)$ligne['_nom']) ?></td>
                  </tr>
                <?php endif ?>
              <?php endforeach ?>
            </tbody>
          </table>
        </div>
      <?php endif ?>

      <?php if ($pag !== null && $pag['total_pages'] > 1): ?>
        <nav class="comp-pagination">
          <?php
            $params_pag = $_GET;
            $debut      = max(1, $pag['current_page'] - 2);
            $fin        = min($pag['total_pages'], $pag['current_page'] + 2);
          ?>
          <?php if ($pag['current_page'] > 1): ?>
            <?php $params_pag['page'] = 1 ?>
            <a href="?<?= h(http_build_query($params_pag)) ?>" class="comp-pag-btn" title="Première page">
              <i class="fa fa-angle-double-left"></i>
            </a>
          <?php endif ?>
          <?php for ($p = $debut; $p <= $fin; $p++): ?>
            <?php $params_pag['page'] = $p ?>
            <?php if ($p === $pag['current_page']): ?>
              <span class="comp-pag-btn comp-pag-btn--active"><?= $p ?></span>
            <?php else: ?>
              <a href="?<?= h(http_build_query($params_pag)) ?>" class="comp-pag-btn"><?= $p ?></a>
            <?php endif ?>
          <?php endfor ?>
          <?php if ($pag['current_page'] < $pag['total_pages']): ?>
            <?php $params_pag['page'] = $pag['total_pages'] ?>
            <a href="?<?= h(http_build_query($params_pag)) ?>" class="comp-pag-btn" title="Dernière page">
              <i class="fa fa-angle-double-right"></i>
            </a>
          <?php endif ?>
        </nav>
      <?php endif ?>
    <?php endif ?>
  </div>

</div>

<?php require_once '../include/footer.php'; ?>
