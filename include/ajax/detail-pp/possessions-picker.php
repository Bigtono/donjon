<?php
// include/ajax/detail-pp/possessions-picker.php
// Sélecteur d'équipements et d'objets magiques simples du personnage (SP-PO9),
// affiché dans #detail-pp depuis personnages/possessions.php. Clone du sélecteur de dons (§7.5b).
//
// Une seule liste, choisie par le bouton « Ajouter » du bloc d'origine (type=equipement | objet,
// D-PO31 : plus d'onglets), en deux volets : à gauche la liste filtrable (nom, famille ou
// catégorie), à droite la fiche du compendium de l'article cliqué.
// « Ajouter » écrit immédiatement (action ajouterPossession, une unité ; une ligne identique
// voit sa quantité augmentée). La page est rechargée à la fermeture si quelque chose a bougé.
//
// Périmètre : ruleset du PERSONNAGE ; sources actives de l'utilisateur ; visibilité des listes du
// compendium (listeClauseVisibilite) ; hors homebrew de campagne. Exclus : les propriétés spéciales
// et, en DD3.5, les catégories calculées (potions, baguettes, parchemins) — ils se composent.
//
// Paramètres GET : pe_id (int), type (equipement par défaut | objet)
//
// Référence : doc/ARCHITECTURE_0_REFERENCE.md §7.9b

require_once __DIR__ . '/../../db.php';
require_once __DIR__ . '/../../auth.php';
require_once __DIR__ . '/../../helpers.php';
require_once __DIR__ . '/../../personnage_helpers.php';
require_once __DIR__ . '/../../liste-parser.php';

requireAuth();

$pe_id = intParam($_GET['pe_id'] ?? 0);
$perso = getPersonnageContext($db, $pe_id); // droit peutGererPersonnage inclus

if (!$perso):
  http_response_code(403);
  echo '<p class="erreur">Personnage introuvable ou accès refusé.</p>';
  exit;
endif;

$ruleset_id = (int)$perso['pe_ruleset_var_id'];
$res_ids    = getActiveResIds($db, $ruleset_id, ['pe_id' => $pe_id]);
$filtre_res = !empty($res_ids);   // jamais d'IN () vide
$type       = ($_GET['type'] ?? '') === 'objet' ? 'objet' : 'equipement';
$equipements = $objets = $options_familles = $categories = [];

// Quantités déjà possédées, par article (toutes lignes confondues)
$possede = ['equipement' => [], 'objet' => []];
foreach (getPersonnagePossessions($db, $pe_id) as $p):
  if ($p['pp_type'] === 'equipement') $possede['equipement'][(int)$p['pp_eqt_id']] = ($possede['equipement'][(int)$p['pp_eqt_id']] ?? 0) + (int)$p['pp_quantite'];
  if ($p['pp_type'] === 'objet')      $possede['objet'][(int)$p['pp_om_id']]       = ($possede['objet'][(int)$p['pp_om_id']] ?? 0) + (int)$p['pp_quantite'];
endforeach;

// ---- Équipement ----------------------------------------------------
if ($type === 'equipement'):
  $params = [$ruleset_id];
  $vis = listeClauseVisibilite('res.res_j_id', 'eqt.eqt_public', 'eqt.eqt_visible', $params);
  $sql = "
    SELECT eqt.eqt_id, eqt.eqt_nom, eqt.eqt_cae_id, eqt.eqt_prix_pc, eqt.eqt_prix_txt, eqt.eqt_ordre
      FROM dd_equipements eqt
      LEFT JOIN dd_ressources res ON res.res_id = eqt.eqt_res_id
     WHERE eqt.eqt_ruleset_var_id = ? AND eqt.eqt_camp_id IS NULL AND $vis";
  if ($filtre_res):
    $sql .= ' AND eqt.eqt_res_id IN (' . resIdsPlaceholders($res_ids) . ')';
    $params = array_merge($params, $res_ids);
  endif;
  $stmt = $db->prepare($sql);
  $stmt->execute($params);
  $equipements = $stmt->fetchAll();

  // Ordre de l'arbre des familles, puis du livre, puis du nom (comme les listes du compendium)
  $arbre = catEquipementArbre($db, $ruleset_id);
  usort($equipements, function ($a, $b) use ($arbre) {
    $ra = $arbre['rang'][(int)$a['eqt_cae_id']] ?? PHP_INT_MAX;
    $rb = $arbre['rang'][(int)$b['eqt_cae_id']] ?? PHP_INT_MAX;
    return [$ra, (int)$a['eqt_ordre'], mb_strtolower($a['eqt_nom'])] <=> [$rb, (int)$b['eqt_ordre'], mb_strtolower($b['eqt_nom'])];
  });

  // Familles présentes (et leurs ancêtres), pour le filtre : un parent filtre ses descendants
  $familles_utiles = [];
  foreach ($equipements as $e):
    foreach (catEquipementChaine($arbre, (int)$e['eqt_cae_id']) as $anc) $familles_utiles[$anc] = true;
  endforeach;
  $options_familles = [];
  foreach ($arbre['rang'] as $cae_id => $rang):
    if (!isset($familles_utiles[$cae_id])) continue;
    $options_familles[$rang] = ['id' => $cae_id, 'nom' => $arbre['noeuds'][$cae_id]['cae_nom'],
                                'profondeur' => count(catEquipementChaine($arbre, $cae_id)) - 1];
  endforeach;
  ksort($options_familles);
endif;

// ---- Objets magiques -----------------------------------------------
if ($type === 'objet'):
  $params = [$ruleset_id];
  $vis = listeClauseVisibilite('res.res_j_id', 'om.om_public', 'om.om_visible', $params);
  $sql = "
    SELECT om.om_id, om.om_nom, om.om_com_id, om.om_prix, com.com_nom, omr.omr_nom AS rarete, omr.omr_prix
      FROM dd_objets_magiques om
      JOIN dd_categorie_objet_magique com ON com.com_id = om.om_com_id
      LEFT JOIN dd_objets_magiques_rarete omr ON omr.omr_id = om.om_rarete
      LEFT JOIN dd_ressources res ON res.res_id = om.om_res_id
     WHERE om.om_ruleset_var_id = ? AND om.om_camp_id IS NULL AND $vis
       AND com.com_est_propriete = 0" . ($ruleset_id === 1 ? ' AND com.com_est_calcule = 0' : '');
  if ($filtre_res):
    $sql .= ' AND om.om_res_id IN (' . resIdsPlaceholders($res_ids) . ')';
    $params = array_merge($params, $res_ids);
  endif;
  $sql .= ' ORDER BY com.com_nom, om.om_nom';
  $stmt = $db->prepare($sql);
  $stmt->execute($params);
  $objets = $stmt->fetchAll();

  foreach ($objets as $o) $categories[(int)$o['om_com_id']] = $o['com_nom'];
  asort($categories, SORT_NATURAL | SORT_FLAG_CASE);
endif;

$url_eqt = BASE_URL . '/include/ajax/detail-pp/equipement.php';
$url_om  = BASE_URL . '/include/ajax/detail-pp/objet.php';
?>

<div class="dons-picker poss-picker" id="poss-picker" data-pe-id="<?= (int)$pe_id ?>">

  <header class="dons-picker__header">
    <h2 class="dons-picker__titre">
      <i class="fa <?= $type === 'objet' ? 'fa-wand-sparkles' : 'fa-toolbox' ?>"></i>
      <?= $type === 'objet' ? 'Objets magiques' : 'Équipement' ?> — <?= h($perso['pe_nom']) ?>
    </h2>
  </header>

  <div class="dons-picker__filtres">
    <input type="search" id="poss-picker-q" class="dons-picker__recherche"
           placeholder="Rechercher…" autocomplete="off" oninput="possPicker.filtrer()">
    <?php if ($type === 'equipement'): ?>
      <select id="poss-picker-fam" class="dons-picker__select" onchange="possPicker.filtrer()" title="Famille d'équipement">
        <option value="0">Toutes les familles</option>
        <?php foreach ($options_familles as $f): ?>
          <option value="<?= (int)$f['id'] ?>"><?= str_repeat("\u{00A0}\u{00A0}", $f['profondeur']) . h($f['nom']) ?></option>
        <?php endforeach ?>
      </select>
    <?php else: ?>
      <select id="poss-picker-cat" class="dons-picker__select" onchange="possPicker.filtrer()" title="Catégorie d'objet magique">
        <option value="0">Toutes les catégories</option>
        <?php foreach ($categories as $com_id => $com_nom): ?>
          <option value="<?= (int)$com_id ?>"><?= h($com_nom) ?></option>
        <?php endforeach ?>
      </select>
    <?php endif ?>
    <span class="dons-picker__decompte text-muted text-sm" id="poss-picker-decompte"></span>
  </div>

  <?php if ($ruleset_id === 1 && $type === 'objet'): ?>
    <p class="poss-picker__aide text-muted text-sm">
      <i class="fa fa-circle-info"></i>
      Armes, armures et boucliers magiques, potions, huiles, baguettes et parchemins se
      <strong>composent</strong> (bonus et propriétés, ou sort et NLS) : ils n'apparaissent pas ici.
      Seuls les objets à prix figé du compendium y figurent.
    </p>
  <?php endif ?>

  <div class="dons-picker__corps">

    <div class="dons-picker__liste" id="poss-picker-liste">
      <?php if ($type === 'equipement'): ?>
      <ul class="dons-picker__ul" data-liste="equipement">
        <?php if (empty($equipements)): ?>
          <li class="dons-picker__item text-muted">Aucun équipement avec les sources actives.</li>
        <?php endif ?>
        <?php foreach ($equipements as $e): ?>
          <?php
            $eid  = (int)$e['eqt_id'];
            $qte  = $possede['equipement'][$eid] ?? 0;
            $prix = formaterPrixPc($e['eqt_prix_pc'] !== null ? (int)$e['eqt_prix_pc'] : null, $e['eqt_prix_txt']);
          ?>
          <li class="dons-picker__item<?= $qte ? ' is-possede' : '' ?>"
              data-type="equipement" data-id="<?= $eid ?>"
              data-nom="<?= h(mb_strtolower($e['eqt_nom'])) ?>"
              data-fam="<?= h(implode(' ', catEquipementChaine($arbre, (int)$e['eqt_cae_id']))) ?>">
            <button type="button" class="dons-picker__btn" title="Ajouter un exemplaire"
                    onclick="possPicker.ajouter('equipement', <?= $eid ?>)">
              <i class="fa fa-plus"></i><span class="dons-picker__btn-lbl">Ajouter</span>
            </button>
            <a href="javascript:void(0)" class="dons-picker__nom"
               onclick="possPicker.voir('equipement', <?= $eid ?>)"><?= h($e['eqt_nom']) ?></a>
            <span class="poss-picker__possede" data-qte="<?= $qte ?>"<?= $qte ? '' : ' hidden' ?>>× <?= $qte ?></span>
            <span class="dons-picker__cat"><?= h($prix) ?></span>
          </li>
        <?php endforeach ?>
      </ul>
      <?php else: ?>

      <ul class="dons-picker__ul" data-liste="objet">
        <?php if (empty($objets)): ?>
          <li class="dons-picker__item text-muted">Aucun objet magique avec les sources actives.</li>
        <?php endif ?>
        <?php foreach ($objets as $o): ?>
          <?php
            $oid  = (int)$o['om_id'];
            $qte  = $possede['objet'][$oid] ?? 0;
            $prix = $o['om_prix'] !== null ? formaterPrixPo((int)$o['om_prix'] * 100) : ($o['rarete'] ?? '—');
          ?>
          <li class="dons-picker__item<?= $qte ? ' is-possede' : '' ?>"
              data-type="objet" data-id="<?= $oid ?>"
              data-nom="<?= h(mb_strtolower($o['om_nom'])) ?>"
              data-cat="<?= (int)$o['om_com_id'] ?>">
            <button type="button" class="dons-picker__btn" title="Ajouter un exemplaire"
                    onclick="possPicker.ajouter('objet', <?= $oid ?>)">
              <i class="fa fa-plus"></i><span class="dons-picker__btn-lbl">Ajouter</span>
            </button>
            <a href="javascript:void(0)" class="dons-picker__nom"
               onclick="possPicker.voir('objet', <?= $oid ?>)"><?= h($o['om_nom']) ?></a>
            <span class="poss-picker__possede" data-qte="<?= $qte ?>"<?= $qte ? '' : ' hidden' ?>>× <?= $qte ?></span>
            <span class="dons-picker__cat" title="<?= h($o['com_nom']) ?>"><?= h($prix) ?></span>
          </li>
        <?php endforeach ?>
      </ul>
      <?php endif ?>
    </div>

    <div class="dons-picker__detail" id="poss-picker-detail"
         data-url-equipement="<?= h($url_eqt) ?>" data-url-objet="<?= h($url_om) ?>">
      <p class="dons-picker__vide text-muted">
        <i class="fa fa-hand-pointer"></i><br>
        Cliquez sur un nom pour lire sa fiche ici, sans quitter la liste.
      </p>
    </div>

  </div>
</div>
