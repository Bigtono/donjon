<?php
// include/ajax/detail-pp/tableau.php
// Fiche détail d'un tableau dd_tableaux pour #detail-pp (SP-TB3).
//
// Paramètres GET :
//   id (int) — tab_id
//
// Référence : doc/ARCHITECTURE_0_REFERENCE.md §9c

require_once __DIR__ . '/../../db.php';
require_once __DIR__ . '/../../auth.php';
require_once __DIR__ . '/../../helpers.php';
require_once __DIR__ . '/../../tableau-parser.php';

requireAuth();

$id          = intParam($_GET['id'] ?? 0);
$ruleset_id  = (int)($_SESSION['ruleset_var_id'] ?? 1);
$peut_editer = canEditCompendium();

if (!$id):
  http_response_code(400);
  echo '<p class="erreur">Identifiant manquant.</p>';
  exit;
endif;

$tab = chargerTableauParId($db, $id, $ruleset_id);

if (!$tab || (!$tab['tab_visible'] && !$peut_editer)):
  http_response_code(404);
  echo '<p class="erreur">Tableau introuvable.</p>';
  exit;
endif;

// Règles qui insèrent ce tableau
$stmt = $db->prepare('
  SELECT reg_id, reg_nom FROM dd_regles
  WHERE  reg_ruleset_var_id = ? AND reg_texte LIKE ?
  ORDER  BY reg_nom
  LIMIT  20
');
$stmt->execute([$ruleset_id, '%[[tab:' . $tab['tab_slug'] . ']]%']);
$regles = $stmt->fetchAll();

// Source
$res_nom = '';
if (!empty($tab['tab_res_id'])):
  $stmt = $db->prepare('SELECT res_nom FROM dd_ressources WHERE res_id = ?');
  $stmt->execute([(int)$tab['tab_res_id']]);
  $res_nom = (string)$stmt->fetchColumn();
endif;

$index = preg_match('/[@%#$&]/', (string)$tab['tab_contenu'])
  ? chargerIndexMonstre($db, $ruleset_id, getActiveResIds($db))
  : [];
?>

<div class="tableau-detail">

  <div class="regle-detail__header">
    <h2 class="regle-detail__titre">
      <?= h($tab['tab_nom']) ?>
      <?php if ($tab['tab_ecran_mj']): ?>
        <span class="regles-badge regles-badge--ecran" title="Retenu pour l'écran du MJ">
          <i class="fa fa-star"></i> Écran MJ
        </span>
      <?php endif ?>
      <?php if (!$tab['tab_visible']): ?>
        <span class="regles-badge regles-badge--brouillon">Brouillon</span>
      <?php endif ?>
    </h2>

    <?php if ($peut_editer): ?>
      <button class="regle-detail__edit-btn"
              onclick="ouvrirModifier('<?= BASE_URL ?>/include/ajax/modifier/tableau.php', <?= $id ?>)"
              title="Modifier">
        <i class="fa fa-edit"></i>
      </button>
    <?php endif ?>
  </div>

  <?= rendreTableau($tab, $index, $ruleset_id, $db) ?>

  <p class="form-hint">
    Tag à insérer dans une règle :
    <code class="reg-tab-liste__tag" onclick="reglesCopierTag(this)" title="Cliquer pour copier">[[tab:<?= h($tab['tab_slug']) ?>]]</code>
  </p>

  <?php if (!empty($regles)): ?>
    <div class="regle-detail__enfants">
      <h4>Utilisé par</h4>
      <ul class="regle-detail__enfants-liste">
        <?php foreach ($regles as $r): ?>
          <li>
            <a href="<?= BASE_URL ?>/regles/regle.php?id=<?= (int)$r['reg_id'] ?>"
               onclick="fermerDetailPP()">
              <?= h($r['reg_nom']) ?>
            </a>
          </li>
        <?php endforeach ?>
      </ul>
    </div>
  <?php else: ?>
    <p class="text-muted">Ce tableau n'est référencé par aucune règle.</p>
  <?php endif ?>

  <?php if ($res_nom !== ''): ?>
    <div class="regle-detail__footer">
      <span class="regle-detail__source">
        <i class="fa fa-book"></i> <?= h($res_nom) ?>
      </span>
    </div>
  <?php endif ?>

</div>
