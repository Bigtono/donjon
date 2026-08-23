<?php
// include/ajax/detail-pp/dons-picker.php
// Sélecteur de dons du personnage (SP-PE4) — s'affiche dans #detail-pp.
//
// Deux volets : à gauche la liste filtrable des dons du ruleset (ascenseur
// propre), à droite la fiche du don cliqué, qui aide au choix. Le bouton
// d'ajout / retrait est présent des deux côtés.
//
// Le panneau reste ouvert : on enchaîne les choix, chacun écrit immédiatement
// en base (actions ajouterDon / supprimerDon de personnages/enregistrement.php).
// Fermeture par le seul bouton ✕ — le backdrop de #detail-pp ne ferme pas au
// clic, contrairement à celui de #detail-pp-sub.
//
// Paramètres GET : pe_id (int)
//
// Référence : doc/ARCHITECTURE_0_REFERENCE.md §7.5b

require_once __DIR__ . '/../../db.php';
require_once __DIR__ . '/../../auth.php';
require_once __DIR__ . '/../../helpers.php';
require_once __DIR__ . '/../../personnage_helpers.php';

requireAuth();

$pe_id = intParam($_GET['pe_id'] ?? 0);
$perso = getPersonnageContext($db, $pe_id); // contrôle de propriété inclus

if (!$perso):
  http_response_code(403);
  echo '<p class="erreur">Personnage introuvable ou accès refusé.</p>';
  exit;
endif;

// Ruleset du PERSONNAGE (figé à la création), jamais celui de la session
$ruleset_id = (int)$perso['pe_ruleset_var_id'];
$res_ids    = getActiveResIds($db, $ruleset_id);
$filtre_res = !empty($res_ids);
$ph         = $filtre_res ? resIdsPlaceholders($res_ids) : '';

// Dons du ruleset bornés par les sources actives. Un don déjà choisi reste
// listé même si sa source a été désactivée depuis (même principe que les
// compétences en SP-PE3) : sinon il deviendrait invisible et non retirable.
$sql = '
  SELECT do.do_id,
         do.do_nom,
         do.do_dado_id,
         dad.dado_nom,
         (ped.ped_id IS NOT NULL) AS possede
    FROM dd_dons do
    LEFT JOIN dd_data_don dad ON dad.dado_id = do.do_dado_id
    LEFT JOIN dd_personnages_dons ped
           ON ped.ped_do_id = do.do_id
          AND ped.ped_pe_id = ?
   WHERE do.do_ruleset_var_id = ?
     AND do.do_camp_id IS NULL'
  . ($filtre_res ? " AND (do.do_res_id IN ($ph) OR ped.ped_id IS NOT NULL)" : '') . '
   ORDER BY do.do_nom';

$params = $filtre_res
  ? array_merge([$pe_id, $ruleset_id], $res_ids)
  : [$pe_id, $ruleset_id];

$stmt = $db->prepare($sql);
$stmt->execute($params);
$dons = $stmt->fetchAll();

// Compteur : total des dons du personnage, indépendamment de la session de choix
$total = 0;
foreach ($dons as $d):
  if ($d['possede']):
    $total++;
  endif;
endforeach;

// Catégories réellement présentes dans la liste (alimente le select de filtre)
$categories = [];
foreach ($dons as $d):
  $cat_id = (int)$d['do_dado_id'];
  if ($cat_id > 0 && !isset($categories[$cat_id])):
    $categories[$cat_id] = $d['dado_nom'];
  endif;
endforeach;
asort($categories);
?>

<div class="dons-picker" id="dons-picker" data-pe-id="<?= (int)$pe_id ?>">

  <header class="dons-picker__header">
    <h2 class="dons-picker__titre">
      Dons de <?= h($perso['pe_nom']) ?>
    </h2>
    <p class="dons-picker__compteur">
      <strong id="dons-picker-compteur"><?= $total ?></strong>
      <span id="dons-picker-compteur-lbl"><?= $total > 1 ? 'dons choisis' : 'don choisi' ?></span>
    </p>
  </header>

  <div class="dons-picker__filtres">
    <input type="search" id="dons-picker-q" class="dons-picker__recherche"
           placeholder="Rechercher un don…" autocomplete="off"
           oninput="donsPicker.filtrer()">
    <select id="dons-picker-cat" class="dons-picker__select" onchange="donsPicker.filtrer()">
      <option value="0">Toutes les catégories</option>
      <?php foreach ($categories as $cat_id => $cat_nom): ?>
        <option value="<?= (int)$cat_id ?>"><?= h($cat_nom) ?></option>
      <?php endforeach ?>
    </select>
    <span class="dons-picker__decompte text-muted text-sm" id="dons-picker-decompte"></span>
  </div>

  <div class="dons-picker__corps">

    <!-- Volet gauche : liste filtrable, ascenseur propre -->
    <div class="dons-picker__liste" id="dons-picker-liste">
      <?php if (empty($dons)): ?>
        <p class="text-muted">
          Aucun don disponible pour ce ruleset avec les sources actives.
          <a href="<?= BASE_URL ?>/profil/">Configurer mes sources</a>
        </p>
      <?php else: ?>
        <ul class="dons-picker__ul">
          <?php foreach ($dons as $d): ?>
            <?php $possede = (bool)$d['possede']; ?>
            <li class="dons-picker__item<?= $possede ? ' is-possede' : '' ?>"
                data-do-id="<?= (int)$d['do_id'] ?>"
                data-nom="<?= h(mb_strtolower($d['do_nom'])) ?>"
                data-cat="<?= (int)$d['do_dado_id'] ?>">
              <button type="button"
                      class="dons-picker__btn<?= $possede ? ' dons-picker__btn--retirer' : '' ?>"
                      onclick="donsPicker.basculer(<?= (int)$d['do_id'] ?>)"
                      title="<?= $possede ? 'Retirer ce don' : 'Ajouter ce don' ?>">
                <i class="fa <?= $possede ? 'fa-trash' : 'fa-plus' ?>"></i>
                <span class="dons-picker__btn-lbl"><?= $possede ? 'Supprimer' : 'Ajouter' ?></span>
              </button>
              <a href="javascript:void(0)" class="dons-picker__nom"
                 onclick="donsPicker.voir(<?= (int)$d['do_id'] ?>)">
                <?= h($d['do_nom']) ?>
              </a>
              <span class="dons-picker__cat"><?= h($d['dado_nom'] ?? '—') ?></span>
            </li>
          <?php endforeach ?>
        </ul>
      <?php endif ?>
    </div>

    <!-- Volet droit : fiche du don cliqué -->
    <div class="dons-picker__detail" id="dons-picker-detail">
      <p class="dons-picker__vide text-muted">
        <i class="fa fa-hand-pointer"></i><br>
        Cliquez sur le nom d'un don pour lire sa description ici,
        sans quitter la liste.
      </p>
    </div>

  </div>
</div>
