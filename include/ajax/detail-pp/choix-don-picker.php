<?php
// include/ajax/detail-pp/choix-don-picker.php
// Sélecteur d'un don pour un emplacement de capacité de classe (SP-CH) —
// s'affiche dans #detail-pp.
//
// Un seul clic choisit le don et ferme le panneau : l'écriture passe par l'action
// enregistrerChoixCapacite de personnages/enregistrement.php. Le nom d'un don ouvre
// sa fiche dans #detail-pp-sub pour aider au choix.
//
// Paramètres GET : pe_id (int), dado_id (int, 0 = toutes les catégories), guerrier (1 = dons de guerrier,
// avec dado_id : dons de guerrier OU de cette catégorie), do_id (don actuel, 0 = aucun)

require_once __DIR__ . '/../../db.php';
require_once __DIR__ . '/../../auth.php';
require_once __DIR__ . '/../../helpers.php';
require_once __DIR__ . '/../../personnage_helpers.php';

requireAuth();

$pe_id   = intParam($_GET['pe_id'] ?? 0);
$dado_id = intParam($_GET['dado_id'] ?? 0);
$do_cour = intParam($_GET['do_id'] ?? 0);
$guerrier = intParam($_GET['guerrier'] ?? 0) === 1;
$perso   = getPersonnageContext($db, $pe_id); // contrôle de propriété inclus

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

// Même périmètre que le sélecteur de dons : sources actives, hors suppléments de
// campagne ; le don déjà choisi reste listé même si sa source a été désactivée.
[$sql_restriction, $params_restriction] = conditionDonsChoix($dado_id, $guerrier);

$sql = '
  SELECT do.do_id, do.do_nom, dad.dado_nom
    FROM dd_dons do
    LEFT JOIN dd_data_don dad ON dad.dado_id = do.do_dado_id
   WHERE do.do_ruleset_var_id = ?
     AND do.do_camp_id IS NULL'
  . $sql_restriction
  . ($filtre_res ? " AND (do.do_res_id IN ($ph) OR do.do_id = ?)" : '') . '
   ORDER BY do.do_nom';

$params = array_merge([$ruleset_id], $params_restriction);
if ($filtre_res):
  $params = array_merge($params, $res_ids, [$do_cour]);
endif;

$stmt = $db->prepare($sql);
$stmt->execute($params);
$dons = $stmt->fetchAll();
?>

<div class="choix-don-picker" id="choix-don-picker">
  <header class="dons-picker__header">
    <h2 class="dons-picker__titre">Choisir un don</h2>
  </header>

  <div class="dons-picker__filtres">
    <input type="search" id="choix-don-q" class="dons-picker__recherche"
           placeholder="Rechercher un don…" autocomplete="off"
           oninput="perChoix.filtrerDons()">
  </div>

  <?php // Précision facultative, envoyée avec le don choisi (Spécialisation martiale : l'arme…) ?>
  <div class="dons-picker__filtres">
    <input type="text" id="choix-don-precision" class="dons-picker__recherche"
           placeholder="Précision du don (arme, école, compétence…), facultative"
           maxlength="100" autocomplete="off">
  </div>

  <?php if (empty($dons)): ?>
    <p class="text-muted">
      Aucun don disponible avec les sources actives.
      <a href="<?= BASE_URL ?>/profil/">Configurer mes sources</a>
    </p>
  <?php else: ?>
    <ul class="choix-don-picker__liste">
      <?php foreach ($dons as $d): ?>
        <li class="choix-don-picker__item<?= (int)$d['do_id'] === $do_cour ? ' is-courant' : '' ?>"
            data-nom="<?= h(mb_strtolower($d['do_nom'])) ?>">
          <a href="javascript:void(0)" class="choix-don-picker__nom"
             onclick="actualiserPageSub('<?= BASE_URL ?>/include/ajax/detail-pp/don.php', {id: <?= (int)$d['do_id'] ?>})">
            <?= h($d['do_nom']) ?>
          </a>
          <span class="choix-don-picker__cat"><?= h($d['dado_nom'] ?? '—') ?></span>
          <button type="button" class="btn btn-sm"
                  onclick="perChoix.choisirDon(<?= (int)$d['do_id'] ?>)">
            <i class="fa fa-check"></i> Choisir
          </button>
        </li>
      <?php endforeach ?>
    </ul>
  <?php endif ?>
</div>
