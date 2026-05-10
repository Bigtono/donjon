<?php
// include/admin-liste.php — Moteur de liste commun de la zone d'administration
//
// Prérequis dans le contrôleur appelant :
//   - require db.php, auth.php, helpers.php
//   - requireAdmin() appelé
//   - $adminListConfig défini (voir ARCHITECTURE_REFERENCE.md §6)
//   - header.php déjà inclus
//
// $adminListConfig attendu :
//   entite              string   — identifiant court ('utilisateur', 'ressource')
//   from                string   — fragment SQL FROM + JOINs
//   champ_id            string   — champ clé primaire avec alias table ('j.j_id')
//   colonnes            array    — [{sql, champ, label, mobile, tri, render?}]
//   select_extra        array    — (opt) champs SQL supplémentaires dans le SELECT
//   filtres             array    — critères métier [{type:'select_static', name, label, champ_where, valeurs}]
//   where_extra         array    — (opt) fragments WHERE supplémentaires (chaînes SQL)
//   params_extra        array    — (opt) valeurs pour where_extra
//   url_detail          string   — URL endpoint AJAX detail-pp
//   url_modifier        string   — URL endpoint AJAX modifier ('' = pas de modification)
//   url_enreg           string   — URL enregistrement.php
//   bulk_actions        array    — [{valeur, label}] — vide = pas de barre bulk
//   action_supprimer    string   — (opt) action envoyée au formulaire (défaut: 'supprimer')
//   label_supprimer     string   — (opt) libellé du bouton supprimer (défaut: 'Supprimer')
//   confirm_callback    string   — (opt) fonction PHP($ligne):string pour le texte de confirmation
//   menu_extra_callback string   — (opt) fonction PHP($ligne, $id):string pour items de menu supplémentaires
//   row_class_callback  string   — (opt) fonction PHP($ligne):string pour classe CSS sur <tr>
//   avec_modifier       bool     — (opt) affiche le bouton Modifier (défaut: true)
//   avec_supprimer      bool     — (opt) affiche le bouton Supprimer (défaut: true)

// ============================================================
// 1. PARAMÈTRES GET — tri, filtres, page
// ============================================================

$admin_entite    = $adminListConfig['entite'];
$per_page        = (int)($_SESSION['j_items_par_page'] ?? 20);
$page_courante   = max(1, intParam($_GET['page'] ?? 1));

// Tri — validation par whitelist
$admin_cols_triables = [];
foreach ($adminListConfig['colonnes'] as $col):
  if (!empty($col['tri'])) $admin_cols_triables[$col['champ']] = $col['sql'];
endforeach;

$sort_col = strParam($_GET['sort_col'] ?? '');
$sort_dir = strtolower(strParam($_GET['sort_dir'] ?? 'asc')) === 'desc' ? 'DESC' : 'ASC';
if (!isset($admin_cols_triables[$sort_col])):
  reset($admin_cols_triables);
  $sort_col = key($admin_cols_triables);
endif;
$sort_sql = !empty($sort_col) ? ($admin_cols_triables[$sort_col] . ' ' . $sort_dir) : '1';

// Filtre texte libre
$q = strParam($_GET['q'] ?? '');

// ============================================================
// 2. CONSTRUCTION SQL
// ============================================================

$where_parts = [];
$params      = [];

// WHERE extra (conditions fixes déclarées dans le contrôleur)
if (!empty($adminListConfig['where_extra'])):
  foreach ($adminListConfig['where_extra'] as $we):
    $where_parts[] = $we;
  endforeach;
  foreach (($adminListConfig['params_extra'] ?? []) as $pe):
    $params[] = $pe;
  endforeach;
endif;

// Filtres métier (select_static)
foreach ($adminListConfig['filtres'] as $f):
  $val = strParam($_GET[$f['name']] ?? '');
  if ($val === '') continue;
  if ($f['type'] === 'select_static' && !empty($f['champ_where'])):
    $where_parts[] = $f['champ_where'] . ' = ?';
    $params[]      = $val;
  endif;
endforeach;

// Filtre texte libre sur la première colonne triable
if ($q !== '' && !empty($adminListConfig['colonnes'][0]['sql'])):
  $where_parts[] = $adminListConfig['colonnes'][0]['sql'] . ' LIKE ?';
  $params[]      = '%' . $q . '%';
endif;

$where_sql = $where_parts ? 'WHERE ' . implode(' AND ', $where_parts) : '';

// SELECT des colonnes
$select_parts = [$adminListConfig['champ_id'] . ' AS _id'];
foreach ($adminListConfig['colonnes'] as $col):
  $select_parts[] = $col['sql'] . ' AS ' . $col['champ'];
endforeach;
if (!empty($adminListConfig['select_extra'])):
  foreach ($adminListConfig['select_extra'] as $extra):
    $select_parts[] = $extra;
  endforeach;
endif;
$select_sql = implode(', ', $select_parts);
$from_sql   = $adminListConfig['from'];

// ============================================================
// 3. EXÉCUTION — COUNT + SELECT paginé
// ============================================================

$sql_count  = "SELECT COUNT(*) FROM $from_sql $where_sql";
$stmt_count = $db->prepare($sql_count);
$stmt_count->execute($params);
$total = (int)$stmt_count->fetchColumn();

$pag    = getPagination($total, $per_page, $page_courante);
$offset = $pag['offset'];

$sql_data    = "SELECT $select_sql FROM $from_sql $where_sql ORDER BY $sort_sql LIMIT ? OFFSET ?";
$params_data = array_merge($params, [$per_page, $offset]);
$stmt_data   = $db->prepare($sql_data);
$stmt_data->execute($params_data);
$lignes = $stmt_data->fetchAll();

// ============================================================
// 4. FONCTIONS URL
// ============================================================

function adminListeUrlTri(string $champ, string $dir_actuelle, string $col_actuelle): string
{
  $p = $_GET;
  $p['sort_col'] = $champ;
  $p['sort_dir'] = ($col_actuelle === $champ && $dir_actuelle === 'ASC') ? 'desc' : 'asc';
  unset($p['page']);
  return '?' . http_build_query($p);
}

// Options de config avec valeurs par défaut
$avec_modifier    = $adminListConfig['avec_modifier']    ?? true;
$avec_supprimer   = $adminListConfig['avec_supprimer']   ?? true;
$label_supprimer  = $adminListConfig['label_supprimer']  ?? 'Supprimer';
$action_supprimer = $adminListConfig['action_supprimer'] ?? 'supprimer';
$confirm_cb       = $adminListConfig['confirm_callback']    ?? '';
$menu_extra_cb    = $adminListConfig['menu_extra_callback'] ?? '';
$row_class_cb     = $adminListConfig['row_class_callback']  ?? '';

// ============================================================
// 5. RENDU HTML
// ============================================================
?>

<div class="comp-liste-container" id="comp-liste-<?= h($admin_entite) ?>">

  <script>
    var compUrlDetail   = <?= json_encode($adminListConfig['url_detail']) ?>;
    var compUrlModifier = <?= json_encode($adminListConfig['url_modifier'] ?? '') ?>;
    var compUrlEnreg    = <?= json_encode($adminListConfig['url_enreg']) ?>;
    var compEntite      = <?= json_encode($admin_entite) ?>;
    var compSupprimerAction = <?= json_encode($action_supprimer) ?>;
  </script>

  <?php // ---- ZONE FILTRE ---- ?>
  <form class="comp-filtre-form" method="GET" action="">
    <div class="comp-filtre-row">

      <div class="comp-filtre-group comp-filtre-group--text">
        <input type="text" name="q" value="<?= h($q) ?>"
               placeholder="Rechercher..." class="comp-filtre-input"
               autocomplete="off">
      </div>

      <?php foreach ($adminListConfig['filtres'] as $f): ?>
        <?php if ($f['type'] === 'select_static'): ?>
          <?php $val_actuelle = strParam($_GET[$f['name']] ?? '') ?>
          <div class="comp-filtre-group">
            <select name="<?= h($f['name']) ?>" class="comp-filtre-select">
              <?php foreach ($f['valeurs'] as $opt): ?>
                <option value="<?= h($opt['val']) ?>"
                  <?= $opt['val'] === $val_actuelle ? 'selected' : '' ?>>
                  <?= h($opt['lab']) ?>
                </option>
              <?php endforeach ?>
            </select>
          </div>
        <?php endif ?>
      <?php endforeach ?>

      <div class="comp-filtre-group comp-filtre-group--actions">
        <button type="submit" class="btn btn-primary btn-sm">
          <i class="fa fa-search"></i> Filtrer
        </button>
        <a href="?" class="btn btn-secondary btn-sm" title="Réinitialiser">
          <i class="fa fa-times"></i>
        </a>
      </div>

      <div class="comp-filtre-group comp-filtre-group--add">
        <?php if ($avec_modifier && !empty($adminListConfig['url_modifier'])): ?>
          <button type="button" class="btn btn-primary btn-sm"
                  onclick="ouvrirModifier(compUrlModifier, 0)">
            <i class="fa fa-plus"></i> Ajouter
          </button>
        <?php endif ?>
      </div>

    </div>
  </form>

  <?php // ---- COMPTEUR ---- ?>
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

  <?php // ---- TABLEAU ---- ?>
  <div class="comp-liste-wrapper">
    <table class="table-std comp-liste" id="table-<?= h($admin_entite) ?>">
      <thead>
        <tr>
          <?php if (!empty($adminListConfig['bulk_actions'])): ?>
            <th class="bulk-check">
              <input type="checkbox" id="comp-select-all" title="Tout sélectionner">
            </th>
          <?php else: ?>
            <th class="bulk-check" style="width:0;padding:0;"></th>
          <?php endif ?>

          <th class="col-action"></th>

          <?php foreach ($adminListConfig['colonnes'] as $col): ?>
            <?php
              $cls     = $col['mobile'] ? 'col-primary' : 'col-secondary';
              $url_tri = adminListeUrlTri($col['champ'], $sort_dir, $sort_col);
              $icone   = '';
              if (!empty($col['tri'])):
                if ($sort_col === $col['champ']):
                  $icone = $sort_dir === 'ASC'
                    ? ' <i class="fa fa-sort-up"></i>'
                    : ' <i class="fa fa-sort-down"></i>';
                else:
                  $icone = ' <i class="fa fa-sort text-muted"></i>';
                endif;
              endif;
            ?>
            <th class="<?= $cls ?><?= !empty($col['tri']) ? ' sortable' : '' ?>">
              <?php if (!empty($col['tri'])): ?>
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
            <td colspan="<?= 2 + count($adminListConfig['colonnes']) ?>"
                class="text-muted" style="text-align:center; padding: 2rem;">
              Aucune donnée à afficher.
            </td>
          </tr>

        <?php else: ?>
          <?php foreach ($lignes as $ligne): ?>
            <?php
              $id        = (int)$ligne['_id'];
              $row_class = '';
              if ($row_class_cb && function_exists($row_class_cb)):
                $row_class = call_user_func($row_class_cb, $ligne);
              endif;
              $cols_secondary = array_filter($adminListConfig['colonnes'], fn($c) => !$c['mobile']);
            ?>
            <tr id="row-<?= $id ?>" class="comp-ligne <?= h($row_class) ?>">

              <?php // Checkbox ?>
              <td class="bulk-check" style="<?= empty($adminListConfig['bulk_actions']) ? 'width:0;padding:0;' : '' ?>">
                <?php if (!empty($adminListConfig['bulk_actions'])): ?>
                  <input type="checkbox" class="comp-check" data-id="<?= $id ?>">
                <?php endif ?>
              </td>

              <?php // Menu ligne ?>
              <td class="col-action">
                <?php if ($avec_modifier || $avec_supprimer || $menu_extra_cb): ?>
                  <div class="comp-menu-ligne">
                    <button class="btn btn-icon btn-sm comp-menu-btn"
                            onclick="compToggleMenu(<?= $id ?>)"
                            title="Actions">⋮</button>
                    <div id="comp-menu-<?= $id ?>" class="comp-menu-dropdown noDisplay">

                      <?php if ($avec_modifier && !empty($adminListConfig['url_modifier'])): ?>
                        <button class="comp-menu-item"
                                onclick="compToggleMenu(<?= $id ?>); ouvrirModifier(compUrlModifier, <?= $id ?>)">
                          <i class="fa fa-edit"></i> Modifier
                        </button>
                      <?php endif ?>

                      <?php if ($menu_extra_cb && function_exists($menu_extra_cb)): ?>
                        <?= call_user_func($menu_extra_cb, $ligne, $id) ?>
                      <?php endif ?>

                      <?php if ($avec_supprimer): ?>
                        <button class="comp-menu-item comp-menu-item--danger"
                                onclick="compToggleMenu(<?= $id ?>); compDemanderSuppression(<?= $id ?>)">
                          <i class="fa fa-trash"></i> <?= h($label_supprimer) ?>
                        </button>
                      <?php endif ?>

                    </div>
                  </div>

                  <?php
                    // Confirmation inline
                    $confirm_text = 'Confirmer ?';
                    if ($confirm_cb && function_exists($confirm_cb)):
                      $confirm_text = call_user_func($confirm_cb, $ligne);
                    endif;
                  ?>
                  <div id="comp-confirm-<?= $id ?>" class="comp-confirm-suppr noDisplay">
                    <span><?= $confirm_text ?></span>
                    <button class="btn btn-danger btn-sm"
                            onclick="compConfirmerSuppression(<?= $id ?>)">Oui</button>
                    <button class="btn btn-secondary btn-sm"
                            onclick="compAnnulerSuppression(<?= $id ?>)">Non</button>
                  </div>
                <?php endif ?>
              </td>

              <?php foreach ($adminListConfig['colonnes'] as $col): ?>
                <?php
                  $cls_col = $col['mobile'] ? 'col-primary' : 'col-secondary';
                  $val     = $ligne[$col['champ']] ?? '';
                ?>
                <td class="<?= $cls_col ?>"
                    onclick="actualiserPage(compUrlDetail, {id: <?= $id ?>}, 'liste')">

                  <?php if (!empty($col['render']) && function_exists($col['render'])): ?>
                    <?= call_user_func($col['render'], $ligne) ?>
                  <?php else: ?>
                    <?= h((string)$val) ?>
                  <?php endif ?>

                  <?php // Sous-ligne mobile dans col-primary ?>
                  <?php if ($col['mobile'] && !empty($cols_secondary)): ?>
                    <div class="comp-subrow">
                      <?php
                        $parts = [];
                        foreach ($cols_secondary as $sc):
                          if (!empty($sc['render']) && function_exists($sc['render'])):
                            $parts[] = strip_tags(call_user_func($sc['render'], $ligne));
                          else:
                            $sv = $ligne[$sc['champ']] ?? '';
                            if ($sv !== '' && $sv !== null)
                              $parts[] = h((string)$sv);
                          endif;
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

  <?php // ---- PAGINATION ---- ?>
  <?php if ($pag['total_pages'] > 1): ?>
    <nav class="comp-pagination">
      <?php
        $params_pag = $_GET;
        unset($params_pag['page']);
        $debut = max(1, $pag['current_page'] - 2);
        $fin   = min($pag['total_pages'], $pag['current_page'] + 2);
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

  <?php // ---- BARRE BULK ---- ?>
  <?php if (!empty($adminListConfig['bulk_actions'])): ?>
    <div class="comp-bulk-bar" id="comp-bulk-bar" style="display:none;">
      <span class="comp-bulk-info">
        <span id="comp-bulk-count">0</span> sélectionné(s)
      </span>
      <select id="comp-bulk-action" class="comp-bulk-select">
        <option value="">— Action groupée —</option>
        <?php foreach ($adminListConfig['bulk_actions'] as $action): ?>
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

    <form id="comp-bulk-form" method="POST" action="<?= h($adminListConfig['url_enreg']) ?>">
      <?= csrfField() ?>
      <input type="hidden" name="entite" value="<?= h($admin_entite) ?>">
      <input type="hidden" name="action" id="comp-bulk-action-hidden">
      <div id="comp-bulk-ids"></div>
    </form>
  <?php else: ?>
    <?php // Formulaire caché minimal pour la suppression individuelle ?>
    <form id="comp-bulk-form" method="POST" action="<?= h($adminListConfig['url_enreg']) ?>">
      <?= csrfField() ?>
      <input type="hidden" name="entite" value="<?= h($admin_entite) ?>">
      <input type="hidden" name="action" id="comp-bulk-action-hidden">
      <div id="comp-bulk-ids"></div>
    </form>
  <?php endif ?>

</div>
