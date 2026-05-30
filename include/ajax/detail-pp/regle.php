<?php
// include/ajax/detail-pp/regle.php
// Retourne le HTML d'un nœud de règle pour #detail-pp.
// Appelé via actualiserPage() depuis une liste ou depuis le module Campagnes.
//
// Paramètres GET :
//   id (int) — reg_id du nœud
//
// Référence : doc/ARCHITECTURE_0_REFERENCE.md §9b

require_once __DIR__ . '/../../db.php';
require_once __DIR__ . '/../../auth.php';
require_once __DIR__ . '/../../helpers.php';
require_once __DIR__ . '/../../regles-arbre.php';

requireAuth();

$id         = intParam($_GET['id'] ?? 0);
$ruleset_id = (int)($_SESSION['ruleset_var_id'] ?? 1);
$peut_editer = canEditCompendium();

if (!$id):
  http_response_code(400);
  echo '<p class="erreur">Identifiant manquant.</p>';
  exit;
endif;

// Charge uniquement le nœud (requête légère — pas l'arbre entier)
$stmt = $db->prepare('
  SELECT r.reg_id, r.reg_nom, r.reg_texte, r.reg_type, r.reg_visible,
         r.reg_reg_id, r.reg_slug,
         res.res_nom AS res_nom
  FROM   dd_regles r
  LEFT JOIN dd_ressources res ON res.res_id = r.reg_res_id
  WHERE  r.reg_id = ?
    AND  r.reg_ruleset_var_id = ?
');
$stmt->execute([$id, $ruleset_id]);
$noeud = $stmt->fetch();

if (!$noeud || (!$noeud['reg_visible'] && !$peut_editer)):
  http_response_code(404);
  echo '<p class="erreur">Règle introuvable.</p>';
  exit;
endif;

// Enfants directs (pour résumé des sous-sections)
$stmt_enfants = $db->prepare('
  SELECT reg_id, reg_nom, reg_type
  FROM   dd_regles
  WHERE  reg_reg_id = ? AND reg_ruleset_var_id = ?
    AND  reg_visible = 1
  ORDER  BY reg_ordre ASC, reg_nom ASC
  LIMIT  20
');
$stmt_enfants->execute([$id, $ruleset_id]);
$enfants = $stmt_enfants->fetchAll();
?>

<div class="regle-detail">

  <div class="regle-detail__header">
    <h2 class="regle-detail__titre">
      <?= h($noeud['reg_nom']) ?>
      <?php if ($noeud['reg_type'] === 'glossaire'): ?>
        <span class="regles-badge regles-badge--glossaire">Glossaire</span>
      <?php endif ?>
      <?php if (!$noeud['reg_visible']): ?>
        <span class="regles-badge regles-badge--brouillon">Brouillon</span>
      <?php endif ?>
    </h2>

    <?php if ($peut_editer): ?>
      <button class="regle-detail__edit-btn"
              onclick="ouvrirModifier('<?= BASE_URL ?>/include/ajax/modifier/regle.php', <?= $id ?>)"
              title="Modifier">
        <i class="fa fa-edit"></i>
      </button>
    <?php endif ?>
  </div>

  <?php if ($noeud['reg_texte']): ?>
    <div class="regle-detail__texte">
      <?= $noeud['reg_texte'] ?>
    </div>
  <?php endif ?>

  <?php if (!empty($enfants)): ?>
    <div class="regle-detail__enfants">
      <h4>Sections</h4>
      <ul class="regle-detail__enfants-liste">
        <?php foreach ($enfants as $enf): ?>
          <li>
            <a href="<?= BASE_URL ?>/regles/regle.php?id=<?= (int)$enf['reg_id'] ?>"
               onclick="fermerDetailPP()">
              <?= h($enf['reg_nom']) ?>
            </a>
          </li>
        <?php endforeach ?>
      </ul>
    </div>
  <?php endif ?>

  <div class="regle-detail__footer">
    <a href="<?= BASE_URL ?>/regles/regle.php?id=<?= $id ?>"
       class="btn btn--sm btn--secondary"
       onclick="fermerDetailPP()">
      <i class="fa fa-book-open"></i> Voir la page complète
    </a>
    <?php if ($noeud['res_nom']): ?>
      <span class="regle-detail__source">
        <i class="fa fa-book"></i> <?= h($noeud['res_nom']) ?>
      </span>
    <?php endif ?>
  </div>

</div>
