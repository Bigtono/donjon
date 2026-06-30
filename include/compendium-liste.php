<?php
// include/compendium-liste.php — Moteur de liste commun du compendium
//
// Prérequis dans le contrôleur appelant :
//   - require db.php, auth.php, helpers.php
//   - requireAuth() appelé
//   - $listConfig défini (voir ARCHITECTURE_REFERENCE.md §5)
//   - header.php déjà inclus
//
// $listConfig attendu :
//   entite        string   — identifiant court ('sort', 'classe'...)
//   from          string   — fragment SQL FROM + JOINs
//   champ_id      string   — champ clé primaire avec alias table ('so.so_id')
//   champ_res     string   — champ ressource avec alias table ('so.so_res_id')
//   champ_ruleset string   — champ ruleset avec alias table (optionnel)
//   colonnes      array    — [{sql, champ, label, mobile, tri}]
//   filtres       array    — critères métier intermédiaires [{type, name, champ, label, ...}]
//   url_detail    string   — URL endpoint AJAX detail-pp
//   url_modifier  string   — URL endpoint AJAX modifier ('' = pas de modification)
//   url_enreg     string   — URL enregistrement.php
//   bulk_actions  array    — [{valeur, label}]
//   row_actions   array    — (optionnel) actions supplémentaires par ligne dans le menu ⋮ :
//                            [{label, icon (fa-class), href (avec {id}), download (bool), require_edit (bool)}]
//                            require_edit=false → item visible pour tous dans le menu ⋮
//                                                 (le menu ⋮ s'affiche même pour les non-éditeurs)
//                            require_edit=true  → item réservé aux éditeurs dans le menu ⋮
//
//   --- Supplément utilisateur (SP-C2) — les 3 clés suivantes sont optionnelles,
//       et doivent être déclarées ENSEMBLE pour activer le mécanisme :
//   champ_public     string — champ _public avec alias table ('mo.mo_public')
//   champ_visible    string — champ _visible avec alias table ('mo.mo_visible')
//   champ_res_owner  string — champ res_j_id de la ressource liée ('res.res_j_id'),
//                             nécessite que 'from' joigne déjà dd_ressources sous cet alias.
//   Si absentes : comportement strictement inchangé (rétro-compatible).

// ============================================================
// 1. PARAMÈTRES GET — tri, filtres, page
// ============================================================

$entite    = $listConfig['entite'];
$per_page  = (int)($_SESSION['j_items_par_page'] ?? 20);
$page_courante = max(1, intParam($_GET['page'] ?? 1));

// Tri — validation par whitelist
$cols_triables = [];
foreach ($listConfig['colonnes'] as $col):
  if (!empty($col['tri'])) $cols_triables[$col['champ']] = $col['sql'];
endforeach;

$sort_col = strParam($_GET['sort_col'] ?? '');
$sort_dir = strtolower(strParam($_GET['sort_dir'] ?? 'asc')) === 'desc' ? 'DESC' : 'ASC';
if (!isset($cols_triables[$sort_col])):
  // Tri par défaut : première colonne triable
  reset($cols_triables);
  $sort_col = key($cols_triables);
endif;
$sort_sql = $cols_triables[$sort_col] . ' ' . $sort_dir;

// Filtre texte libre
$q = strParam($_GET['q'] ?? '');

// Filtres sources : intersection sélection active ∩ sélection GET
$res_actifs = getActiveResIds($db);
$res_get    = [];
if (!empty($_GET['f_res']) && is_array($_GET['f_res'])):
  foreach ($_GET['f_res'] as $r):
    $r = (int)$r;
    if (in_array($r, $res_actifs)) $res_get[] = $r;
  endforeach;
endif;
$res_ids = !empty($res_get) ? $res_get : $res_actifs;

// ============================================================
// 1bis. SUPPLÉMENT UTILISATEUR — détection + toggle "brouillons" (SP-C2)
// ============================================================

$gere_supplement = !empty($listConfig['champ_public'])
                 && !empty($listConfig['champ_visible'])
                 && !empty($listConfig['champ_res_owner']);

$uid_courant          = (int)($_SESSION['j_id'] ?? 0);
$mes_brouillons_dispo = false;
$afficher_brouillons  = false;

if ($gere_supplement && $uid_courant):
  // Le toggle n'est proposé que si l'utilisateur a au moins une entrée
  // brouillon (_visible=0) dans son propre supplément pour cette entité.
  $stmt_brouillons = $db->prepare("
    SELECT 1 FROM {$listConfig['from']}
    WHERE {$listConfig['champ_res_owner']} = ?
      AND {$listConfig['champ_visible']} = 0
    LIMIT 1
  ");
  $stmt_brouillons->execute([$uid_courant]);
  $mes_brouillons_dispo = (bool)$stmt_brouillons->fetchColumn();
  $afficher_brouillons  = $mes_brouillons_dispo && isset($_GET['f_brouillons']);
endif;

// ============================================================
// 2. CONSTRUCTION SQL
// ============================================================

$where_parts = [];
$params      = [];

// Filtre ruleset (si déclaré dans le config)
if (!empty($listConfig['champ_ruleset'])):
  $where_parts[] = $listConfig['champ_ruleset'] . ' = ?';
  $params[]      = (int)($_SESSION['ruleset_var_id'] ?? 1);
endif;

// Filtre homebrew : compendium global uniquement (camp_id IS NULL)
// Trois comportements selon champ_camp :
//   non déclaré → auto-inférer depuis champ_id (convention <prefix>_camp_id)
//   string      → utiliser cette colonne directement
//   false       → pas de filtre camp (entité sans champ camp, ex : dd_competences)
if (!array_key_exists('champ_camp', $listConfig)):
  // Auto-inférence : so_camp_id, cla_camp_id, do_camp_id...
  preg_match('/(\w+)\.(\w+)_id/', $listConfig['champ_id'], $m);
  if (!empty($m[2])):
    $prefix_table = $m[1];
    $where_parts[] = $prefix_table . '.' . $m[2] . '_camp_id IS NULL';
  endif;
elseif ($listConfig['champ_camp'] !== false):
  $where_parts[] = $listConfig['champ_camp'] . ' IS NULL';
endif;
// champ_camp === false → filtre omis

// Filtre sources
if (!empty($res_ids)):
  $placeholders  = resIdsPlaceholders($res_ids);
  $where_parts[] = $listConfig['champ_res'] . ' IN (' . $placeholders . ')';
  foreach ($res_ids as $rid) $params[] = (int)$rid;
else:
  // Aucune source active → aucun résultat
  $where_parts[] = '1=0';
endif;

// Filtre visibilité supplément (SP-C2) — vient EN PLUS du filtre sources
// ci-dessus (une source de supplément peut être active sans que toutes ses
// entrées soient visibles à tous) :
//   - entrée officielle (res_owner IS NULL)            → toujours
//   - entrée du supplément du propriétaire courant      → toujours, sauf
//     brouillon (_visible=0) qui nécessite le toggle "Afficher mes brouillons"
//   - entrée d'un supplément tiers                      → seulement si
//     _public=1 ET _visible=1
if ($gere_supplement):
  $owner = $listConfig['champ_res_owner'];
  $pub   = $listConfig['champ_public'];
  $vis   = $listConfig['champ_visible'];
  if ($afficher_brouillons):
    $where_parts[] = "($owner IS NULL OR $owner = ? OR ($pub = 1 AND $vis = 1))";
  else:
    $where_parts[] = "($owner IS NULL OR ($owner = ? AND $vis = 1) OR ($pub = 1 AND $vis = 1))";
  endif;
  $params[] = $uid_courant;
endif;

// Filtre texte libre sur la première colonne
if ($q !== ''):
  $where_parts[] = $listConfig['colonnes'][0]['sql'] . ' LIKE ?';
  $params[]      = '%' . $q . '%';
endif;

// Filtres métier intermédiaires
foreach ($listConfig['filtres'] as $f):
  // Les filtres checkbox n'alimentent pas le WHERE SQL —
  // leur effet est géré par extra_where dans la page contrôleur
  if ($f['type'] === 'checkbox') continue;
  $val = strParam($_GET[$f['name']] ?? '');
  if ($val === '' || $val === '0') continue;
  if ($f['type'] === 'exists' || $f['type'] === 'exists_range'):
    // Filtre via sous-requête EXISTS — évite les doublons liés aux JOINs
    $where_parts[] = $f['sql'];
    $params[]      = $val;
  else:
    $where_parts[] = $f['champ'] . ' = ?';
    $params[]      = $val;
  endif;
endforeach;

$where_sql = $where_parts ? 'WHERE ' . implode(' AND ', $where_parts) : '';

// extra_where : clause SQL brute optionnelle injectée par la page contrôleur
// (ex : om.om_visible = 1 pour masquer les objets invisibles aux non-éditeurs)
if (!empty($listConfig['extra_where'])):
  $where_sql = $where_sql
    ? $where_sql . ' AND ' . $listConfig['extra_where']
    : 'WHERE ' . $listConfig['extra_where'];
endif;

// SELECT des colonnes
$select_parts = [$listConfig['champ_id'] . ' AS _id'];
foreach ($listConfig['colonnes'] as $col):
  $select_parts[] = $col['sql'] . ' AS ' . $col['champ'];
endforeach;
// Supplément (SP-C2) : propriétaire de la ressource, pour le badge homebrew
// et le gating per-entry du menu ⋮ (canEditCompendiumEntry()).
if ($gere_supplement):
  $select_parts[] = $listConfig['champ_res_owner'] . ' AS _res_j_id';
endif;
// Colonnes supplémentaires déclarées (ex: nom ressource)
if (!empty($listConfig['select_extra'])):
  foreach ($listConfig['select_extra'] as $extra):
    $select_parts[] = $extra;
  endforeach;
endif;
$select_sql = implode(', ', $select_parts);

$from_sql = $listConfig['from'];

// ============================================================
// 3. EXÉCUTION — COUNT + SELECT paginé
// ============================================================

$sql_count = "SELECT COUNT(*) FROM $from_sql $where_sql";
$stmt_count = $db->prepare($sql_count);
$stmt_count->execute($params);
$total = (int)$stmt_count->fetchColumn();

$pag    = getPagination($total, $per_page, $page_courante);
$offset = $pag['offset'];

$sql_data = "SELECT $select_sql FROM $from_sql $where_sql ORDER BY $sort_sql LIMIT ? OFFSET ?";
$params_data   = array_merge($params, [$per_page, $offset]);
$stmt_data     = $db->prepare($sql_data);
$stmt_data->execute($params_data);
$lignes        = $stmt_data->fetchAll();

// ============================================================
// 4. SOURCES DISPONIBLES pour le SELECT filtre
// ============================================================

$sources_dispo = [];
if (!empty($res_actifs)):
  $ph   = resIdsPlaceholders($res_actifs);
  $stmt = $db->prepare("SELECT res_id, res_nom, res_abreviation FROM dd_ressources WHERE res_id IN ($ph) ORDER BY res_nom");
  $stmt->execute($res_actifs);
  $sources_dispo = $stmt->fetchAll();
endif;

// ============================================================
// 5. CONSTRUCTION URL DE BASE (sans page, pour pagination et tri)
// ============================================================

function compListeUrlBase(array $config): string
{
  $params = $_GET;
  unset($params['page']);
  return '?' . http_build_query($params);
}

function compListeUrlTri(string $champ, string $dir_actuelle, string $col_actuelle): string
{
  $params = $_GET;
  $params['sort_col'] = $champ;
  $params['sort_dir'] = ($col_actuelle === $champ && $dir_actuelle === 'ASC') ? 'desc' : 'asc';
  unset($params['page']);
  return '?' . http_build_query($params);
}

// ============================================================
// 6. RENDU HTML
// ============================================================
?>

<div class="comp-liste-container" id="comp-liste-<?= h($entite) ?>">

  <?php // ---- VARIABLES JS injectées ---- 
  ?>
  <script>
    var compUrlDetail = <?= json_encode($listConfig['url_detail']) ?>;
    var compUrlModifier = <?= json_encode($listConfig['url_modifier'] ?? '') ?>;
    var compUrlEnreg = <?= json_encode($listConfig['url_enreg']) ?>;
    var compEntite = <?= json_encode($entite) ?>;
  </script>

  <?php // ---- ZONE FILTRE ---- 
  ?>
  <?php
  // Compte les filtres actifs (hors texte libre) pour badge mobile
  $filtres_actifs = 0;
  if ($q !== '') $filtres_actifs++;
  foreach ($listConfig['filtres'] as $f):
    if ($f['type'] === 'checkbox') {
      if (!empty($f['checked'])) $filtres_actifs++;
      continue;
    }
    $v = strParam($_GET[$f['name']] ?? '');
    if ($v !== '' && $v !== '0') $filtres_actifs++;
  endforeach;
  $sources_actives = count($res_get);
  if ($sources_actives > 0) $filtres_actifs++;
  if ($gere_supplement && $afficher_brouillons) $filtres_actifs++;
  ?>

  <div class="comp-filtre-bar">

    <?php // Bouton toggle mobile — masqué en desktop 
    ?>
    <button type="button" class="comp-filtre-toggle"
      onclick="toggleFiltresMobile()"
      aria-expanded="false" id="filtre-toggle-btn">
      <i class="fa fa-filter"></i>
      Filtres
      <?php if ($filtres_actifs > 0): ?>
        <span class="comp-filtre-badge"><?= $filtres_actifs ?></span>
      <?php endif ?>
      <i class="fa fa-chevron-down comp-filtre-chevron"></i>
    </button>

    <div class="comp-filtre-content" id="comp-filtre-content">
      <form class="comp-filtre-form" method="GET" action="" id="form-filtre-<?= h($entite) ?>">

        <?php // ── Texte libre (toujours premier, largeur réduite) 
        ?>
        <div class="comp-filtre-item comp-filtre-item--text">
          <input type="text" name="q" value="<?= h($q) ?>"
            placeholder="Rechercher…" class="comp-filtre-input"
            autocomplete="off">
        </div>

        <?php // ── Critères métier (depuis $listConfig['filtres']) 
        ?>
        <?php foreach ($listConfig['filtres'] as $f): ?>
          <div class="comp-filtre-item">

            <?php if ($f['type'] === 'select' || $f['type'] === 'exists'): ?>
              <?php
              $val_actuelle = strParam($_GET[$f['name']] ?? '');
              $opts_stmt    = $db->prepare($f['query']);
              $opts_stmt->execute($f['query_params'] ?? []);
              $opts = $opts_stmt->fetchAll();
              ?>
              <select name="<?= h($f['name']) ?>" class="comp-filtre-select"
                title="<?= h($f['label']) ?>">
                <option value="">— <?= h($f['label']) ?> —</option>
                <?php foreach ($opts as $opt): ?>
                  <option value="<?= h($opt['val']) ?>"
                    <?= $opt['val'] == $val_actuelle ? 'selected' : '' ?>>
                    <?= h($opt['lab']) ?>
                  </option>
                <?php endforeach ?>
              </select>

            <?php elseif ($f['type'] === 'select_range' || $f['type'] === 'exists_range'): ?>
              <?php $val_actuelle = strParam($_GET[$f['name']] ?? '') ?>
              <select name="<?= h($f['name']) ?>" class="comp-filtre-select"
                title="<?= h($f['label']) ?>">
                <option value="">— <?= h($f['label']) ?> —</option>
                <?php foreach ($f['valeurs'] as $v): ?>
                  <option value="<?= h($v) ?>"
                    <?= (string)$v === (string)$val_actuelle ? 'selected' : '' ?>>
                    <?= h($v) ?>
                  </option>
                <?php endforeach ?>
              </select>

            <?php elseif ($f['type'] === 'checkbox'): ?>
              <label class="comp-filtre-checkbox-label">
                <input type="checkbox"
                       name="<?= h($f['name']) ?>"
                       value="1"
                       <?= !empty($f['checked']) ? 'checked' : '' ?>
                       onchange="document.getElementById('form-filtre-<?= h($entite) ?>').submit()">
                <?= h($f['label']) ?>
              </label>

            <?php endif ?>
          </div>
        <?php endforeach ?>

        <?php // ── Supplément (SP-C2) : toggle "Afficher mes brouillons"
        // Visible uniquement si l'utilisateur a ≥1 entrée _visible=0 dans
        // son propre supplément pour cette entité.
        ?>
        <?php if ($gere_supplement && $mes_brouillons_dispo): ?>
          <div class="comp-filtre-item">
            <label class="comp-filtre-checkbox-label">
              <input type="checkbox"
                     name="f_brouillons"
                     value="1"
                     <?= $afficher_brouillons ? 'checked' : '' ?>
                     onchange="document.getElementById('form-filtre-<?= h($entite) ?>').submit()">
              Afficher mes brouillons
            </label>
          </div>
        <?php endif ?>

        <?php // ── Sources : bouton + menu déroulant avec checkboxes 
        ?>
        <?php if (!empty($sources_dispo)): ?>
          <div class="comp-filtre-item comp-filtre-item--sources">
            <button type="button"
              class="comp-filtre-sources-btn"
              onclick="toggleSources('<?= h($entite) ?>')"
              id="sources-btn-<?= h($entite) ?>">
              <i class="fa fa-books"></i>
              Sources
              <?php if ($sources_actives > 0): ?>
                <span class="comp-filtre-badge" id="sources-badge-<?= h($entite) ?>">
                  <?= $sources_actives ?>
                </span>
              <?php else: ?>
                <span class="comp-filtre-badge comp-filtre-badge--empty"
                  id="sources-badge-<?= h($entite) ?>"
                  style="display:none;">0</span>
              <?php endif ?>
              <i class="fa fa-chevron-down comp-filtre-chevron" id="sources-chevron-<?= h($entite) ?>"></i>
            </button>

            <div class="comp-filtre-sources-menu noDisplay"
              id="sources-menu-<?= h($entite) ?>">
              <?php foreach ($sources_dispo as $src): ?>
                <?php $chk = in_array((int)$src['res_id'], $res_get) ? 'checked' : '' ?>
                <label class="comp-filtre-source-item">
                  <input type="checkbox" name="f_res[]"
                    value="<?= (int)$src['res_id'] ?>"
                    <?= $chk ?>
                    onchange="majSourcesBadge('<?= h($entite) ?>')">
                  <span><?= h($src['res_nom']) ?></span>
                </label>
              <?php endforeach ?>
            </div>
          </div>
        <?php endif ?>

        <?php // ── Actions 
        ?>
        <div class="comp-filtre-item comp-filtre-item--actions">
          <button type="submit" class="btn btn-primary btn-sm">
            <i class="fa fa-search"></i>
            <span class="comp-filtre-label-desktop">Filtrer</span>
          </button>
          <a href="?" class="btn btn-secondary btn-sm" title="Réinitialiser">
            <i class="fa fa-times"></i>
          </a>
          <?php if (canEditCompendium()): ?>
            <button type="button" class="btn btn-primary btn-sm"
              onclick="ouvrirModifier(compUrlModifier, 0)"
              title="Ajouter">
              <i class="fa fa-plus"></i>
            </button>
          <?php endif ?>
        </div>

      </form>
    </div><!-- .comp-filtre-content -->
  </div><!-- .comp-filtre-bar -->

  <?php // ---- COMPTEUR ---- 
  ?>
  <div class="comp-liste-info">
    <?php if ($total === 0): ?>
      <span class="text-muted">Aucun résultat.</span>
    <?php else: ?>
      <span class="text-muted">
        <?= $total ?> résultat<?= $total > 1 ? 's' : '' ?> —
        page <?= $pag['current_page'] ?>/<?= $pag['total_pages'] ?>
      </span>
    <?php endif ?>
  </div>

  <?php // ---- TABLEAU ---- 
  ?>
  <div class="comp-liste-wrapper">
    <table class="table-std comp-liste" id="table-<?= h($entite) ?>">
      <thead>
        <tr>
          <?php // Checkbox select-all — masqué sur mobile 
          ?>
          <th class="bulk-check">
            <input type="checkbox" id="comp-select-all" title="Tout sélectionner">
          </th>

          <?php // Menu ligne — masqué sur mobile 
          ?>
          <th class="col-action"></th>

          <?php // Colonnes 
          ?>
          <?php foreach ($listConfig['colonnes'] as $col): ?>
            <?php
            $cls     = $col['mobile'] ? 'col-primary' : 'col-secondary';
            $url_tri = compListeUrlTri($col['champ'], $sort_dir, $sort_col);
            $icone   = '';
            if ($sort_col === $col['champ']):
              $icone = $sort_dir === 'ASC'
                ? ' <i class="fa fa-sort-up"></i>'
                : ' <i class="fa fa-sort-down"></i>';
            else:
              $icone = ' <i class="fa fa-sort text-muted"></i>';
            endif;
            ?>
            <th class="<?= $cls ?><?= $col['tri'] ? ' sortable' : '' ?>">
              <?php if ($col['tri']): ?>
                <a href="<?= h($url_tri) ?>" class="comp-sort-link">
                  <?= h($col['label']) ?><?= $icone ?>
                </a>
              <?php else: ?>
                <?= h($col['label']) ?>
              <?php endif ?>
            </th>
          <?php endforeach ?>
        </tr>
      </thead>

      <tbody>
        <?php if (empty($lignes)): ?>
          <tr>
            <td colspan="<?= 2 + count($listConfig['colonnes']) ?>"
              class="text-muted" style="text-align:center; padding: 2rem;">
              Aucune donnée à afficher.
            </td>
          </tr>

        <?php else: ?>
          <?php foreach ($lignes as $ligne): ?>
            <?php
            $id = (int)$ligne['_id'];
            // Supplément (SP-C2) : propriété de l'entrée + droit de modif per-entry.
            $res_j_id_ligne = null;
            $est_homebrew   = false;
            if ($gere_supplement && array_key_exists('_res_j_id', $ligne) && $ligne['_res_j_id'] !== null):
              $res_j_id_ligne = (int)$ligne['_res_j_id'];
              $est_homebrew   = true;
            endif;
            $peut_modifier_ligne = $gere_supplement
              ? canEditCompendiumEntry($db, $res_j_id_ligne)
              : canEditCompendium();
            ?>
            <tr id="row-<?= $id ?>" class="comp-ligne<?= $est_homebrew ? ' comp-ligne--homebrew' : '' ?>">

              <?php // Checkbox — masquée si l'utilisateur ne peut pas agir sur cette ligne
              ?>
              <td class="bulk-check">
                <?php if ($peut_modifier_ligne): ?>
                  <input type="checkbox" class="comp-check" data-id="<?= $id ?>">
                <?php endif ?>
              </td>

              <?php // Menu ligne (⋮) 
              ?>
              <?php
              // Le menu ⋮ s'affiche si l'utilisateur peut modifier la ligne
              // OU s'il y a des row_actions visibles pour tous (require_edit=false).
              $_row_actions    = $listConfig['row_actions'] ?? [];
              $_has_open_actions = !empty(array_filter($_row_actions, fn($a) => empty($a['require_edit'])));
              $_afficher_menu  = $peut_modifier_ligne || $_has_open_actions;
              ?>
              <td class="col-action">
                <?php if ($_afficher_menu): ?>
                  <div class="comp-menu-ligne">
                    <button class="btn btn-icon btn-sm comp-menu-btn"
                      onclick="compToggleMenu(<?= $id ?>)"
                      title="Actions">⋮</button>
                    <div id="comp-menu-<?= $id ?>" class="comp-menu-dropdown noDisplay">
                      <?php if ($peut_modifier_ligne): ?>
                        <button class="comp-menu-item"
                          onclick="compToggleMenu(<?= $id ?>); ouvrirModifier(compUrlModifier, <?= $id ?>)">
                          <i class="fa fa-edit"></i> Modifier
                        </button>
                      <?php endif ?>
                      <?php // Toutes les row_actions visibles selon les droits ?>
                      <?php foreach ($_row_actions as $_ra): ?>
                        <?php if (empty($_ra['require_edit']) || $peut_modifier_ligne): ?>
                          <?php $_ra_href = str_replace('{id}', (string)$id, (string)$_ra['href']) ?>
                          <a href="<?= h($_ra_href) ?>"
                             <?php if (!empty($_ra['download'])): ?>download<?php endif ?>
                             class="comp-menu-item"
                             onclick="compToggleMenu(<?= $id ?>)">
                            <i class="fa <?= h($_ra['icon']) ?>"></i> <?= h($_ra['label']) ?>
                          </a>
                        <?php endif ?>
                      <?php endforeach ?>
                      <?php if ($peut_modifier_ligne): ?>
                        <button class="comp-menu-item comp-menu-item--danger"
                          onclick="compToggleMenu(<?= $id ?>); compDemanderSuppression(<?= $id ?>)">
                          <i class="fa fa-trash"></i> Supprimer
                        </button>
                      <?php endif ?>
                    </div>
                  </div>
                <?php endif ?>

                <?php // Confirmation suppression inline 
                ?>
                <div id="comp-confirm-<?= $id ?>" class="comp-confirm-suppr noDisplay">
                  <span>Supprimer ?</span>
                  <button class="btn btn-danger btn-sm"
                    onclick="compConfirmerSuppression(<?= $id ?>)">Oui</button>
                  <button class="btn btn-secondary btn-sm"
                    onclick="compAnnulerSuppression(<?= $id ?>)">Non</button>
                </div>
              </td>

              <?php
              // Colonnes — col-primary contient aussi la sous-ligne mobile
              $cols_secondary = array_filter(
                $listConfig['colonnes'],
                fn($c) => !$c['mobile']
              );
              $first = true;
              ?>
              <?php foreach ($listConfig['colonnes'] as $col): ?>
                <?php
                $cls_col = $col['mobile'] ? 'col-primary' : 'col-secondary';
                $val     = $ligne[$col['champ']] ?? '';
                ?>
                <td class="<?= $cls_col ?>"
                  onclick="actualiserPage(compUrlDetail, {id: <?= $id ?>}, 'liste')">
                  <?php if ($col['mobile'] && $est_homebrew): ?>
                    <i class="fa fa-flask comp-homebrew-icon" title="Entrée de supplément"></i>
                  <?php endif ?>
                  <?= h((string)$val) ?>

                  <?php // Sous-ligne mobile : injectée dans col-primary uniquement 
                  ?>
                  <?php if ($col['mobile'] && !empty($cols_secondary)): ?>
                    <div class="comp-subrow">                      <?php
                      $parts = [];
                      foreach ($cols_secondary as $sc):
                        $sv = $ligne[$sc['champ']] ?? '';
                        if ($sv !== '' && $sv !== null)
                          $parts[] = h((string)$sv);
                      endforeach;
                      echo implode(' · ', $parts);
                      ?>
                    </div>
                  <?php endif ?>
                </td>
              <?php endforeach ?>

            </tr>
          <?php endforeach ?>
        <?php endif ?>
      </tbody>
    </table>
  </div>

  <?php // ---- PAGINATION ---- 
  ?>
  <?php if ($pag['total_pages'] > 1): ?>
    <nav class="comp-pagination">
      <?php
      $base_url = compListeUrlBase($listConfig);
      $params_pag = $_GET;
      unset($params_pag['page']);
      ?>

      <?php // Précédent 
      ?>
      <?php if ($pag['current_page'] > 1): ?>
        <?php $params_pag['page'] = $pag['current_page'] - 1 ?>
        <a href="?<?= http_build_query($params_pag) ?>" class="comp-pag-btn">
          <i class="fa fa-chevron-left"></i>
        </a>
      <?php else: ?>
        <span class="comp-pag-btn comp-pag-btn--disabled">
          <i class="fa fa-chevron-left"></i>
        </span>
      <?php endif ?>

      <?php // Pages 
      ?>
      <?php
      $debut = max(1, $pag['current_page'] - 2);
      $fin   = min($pag['total_pages'], $pag['current_page'] + 2);
      ?>
      <?php if ($debut > 1): ?>
        <?php $params_pag['page'] = 1 ?>
        <a href="?<?= http_build_query($params_pag) ?>" class="comp-pag-btn">1</a>
        <?php if ($debut > 2): ?>
          <span class="comp-pag-ellipsis">…</span>
        <?php endif ?>
      <?php endif ?>

      <?php for ($p = $debut; $p <= $fin; $p++): ?>
        <?php $params_pag['page'] = $p ?>
        <?php if ($p === $pag['current_page']): ?>
          <span class="comp-pag-btn comp-pag-btn--active"><?= $p ?></span>
        <?php else: ?>
          <a href="?<?= http_build_query($params_pag) ?>" class="comp-pag-btn"><?= $p ?></a>
        <?php endif ?>
      <?php endfor ?>

      <?php if ($fin < $pag['total_pages']): ?>
        <?php if ($fin < $pag['total_pages'] - 1): ?>
          <span class="comp-pag-ellipsis">…</span>
        <?php endif ?>
        <?php $params_pag['page'] = $pag['total_pages'] ?>
        <a href="?<?= http_build_query($params_pag) ?>" class="comp-pag-btn">
          <?= $pag['total_pages'] ?>
        </a>
      <?php endif ?>

      <?php // Suivant 
      ?>
      <?php if ($pag['current_page'] < $pag['total_pages']): ?>
        <?php $params_pag['page'] = $pag['current_page'] + 1 ?>
        <a href="?<?= http_build_query($params_pag) ?>" class="comp-pag-btn">
          <i class="fa fa-chevron-right"></i>
        </a>
      <?php else: ?>
        <span class="comp-pag-btn comp-pag-btn--disabled">
          <i class="fa fa-chevron-right"></i>
        </span>
      <?php endif ?>
    </nav>
  <?php endif ?>

  <?php // ---- BARRE BULK ---- 
  ?>
  <?php if (canEditCompendium() && !empty($listConfig['bulk_actions'])): ?>
    <div class="comp-bulk-bar" id="comp-bulk-bar" style="display:none;">
      <span class="comp-bulk-info">
        <span id="comp-bulk-count">0</span> sélectionné(s)
      </span>
      <select id="comp-bulk-action" class="comp-bulk-select">
        <option value="">— Action groupée —</option>
        <?php foreach ($listConfig['bulk_actions'] as $action): ?>
          <option value="<?= h($action['valeur']) ?>"><?= h($action['label']) ?></option>
        <?php endforeach ?>
      </select>
      <button class="btn btn-primary btn-sm" onclick="compSoumettreAction()">
        Appliquer
      </button>
      <button class="btn btn-secondary btn-sm" onclick="compDeselectionnerTout()">
        Annuler
      </button>
    </div>

    <?php // Formulaire caché pour le submit bulk 
    ?>
    <form id="comp-bulk-form" method="POST" action="<?= h($listConfig['url_enreg']) ?>">
      <?= csrfField() ?>
      <input type="hidden" name="entite" value="<?= h($entite) ?>">
      <input type="hidden" name="action" id="comp-bulk-action-hidden">
      <div id="comp-bulk-ids"></div>
    </form>
  <?php endif ?>

</div>