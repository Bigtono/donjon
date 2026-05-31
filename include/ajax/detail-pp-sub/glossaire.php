<?php
// include/ajax/detail-pp-sub/glossaire.php
// Retourne le HTML de la définition d'un terme de glossaire pour #detail-pp-sub.
// Appelé via actualiserPageSub() — lecture seule, pas de layout header/footer.
//
// Paramètres GET :
//   slug (string) — reg_slug du terme (unique par ruleset)
//   id   (int)    — reg_id alternatif (priorité si fourni)
//
// Note : le bouton de fermeture et le backdrop sont injectés par actualiserPageSub() dans main.js.
// Cet endpoint ne rend que le contenu.
//
// Référence : doc/ARCHITECTURE_0_REFERENCE.md §9b et §12 (pattern #detail-pp-sub)

require_once __DIR__ . '/../../db.php';
require_once __DIR__ . '/../../auth.php';
require_once __DIR__ . '/../../helpers.php';

requireAuth();

$slug       = strParam($_GET['slug'] ?? '');
$id         = intParam($_GET['id']   ?? 0);
$ruleset_id = (int)($_SESSION['ruleset_var_id'] ?? 1);

if (!$slug && !$id):
  http_response_code(400);
  echo '<p class="erreur">Paramètre manquant.</p>';
  exit;
endif;

// ============================================================
// Récupération du terme
// ============================================================
if ($id > 0):
  $stmt = $db->prepare('
    SELECT reg_id, reg_nom, reg_texte, reg_slug, reg_type
    FROM   dd_regles
    WHERE  reg_id = ?
      AND  reg_ruleset_var_id = ?
      AND  reg_type = \'glossaire\'
      AND  reg_visible = 1
  ');
  $stmt->execute([$id, $ruleset_id]);
else:
  $stmt = $db->prepare('
    SELECT reg_id, reg_nom, reg_texte, reg_slug, reg_type
    FROM   dd_regles
    WHERE  reg_slug = ?
      AND  reg_ruleset_var_id = ?
      AND  reg_type = \'glossaire\'
      AND  reg_visible = 1
    LIMIT 1
  ');
  $stmt->execute([$slug, $ruleset_id]);
endif;

$terme = $stmt->fetch();

if (!$terme):
  http_response_code(404);
  echo '<p class="erreur">Terme de glossaire introuvable.</p>';
  exit;
endif;
?>

<div class="glossaire-sub">

  <header class="glossaire-sub__header">
    <!-- Ligne 1 : badge (le bouton Fermer, injecte par actualiserPageSub,
         flotte en absolute en haut a droite sur cette meme ligne) -->
    <div class="glossaire-sub__ligne-badge">
      <span class="regles-badge regles-badge--glossaire">Glossaire</span>
    </div>

    <!-- Ligne 2 : titre + lien "voir la page complete", l'un derriere l'autre -->
    <div class="glossaire-sub__ligne-titre">
      <h3 class="glossaire-sub__titre">
        <span class="glossaire-sub__nom"><?= h($terme['reg_nom']) ?></span>
      </h3>
      <a href="<?= BASE_URL ?>/regles/regle.php?id=<?= (int)$terme['reg_id'] ?>"
        class="glossaire-sub__lien-complet" title="Voir la page complète">
        <i class="fa fa-external-link-alt"></i>
        <!---<span class="glossaire-sub__lien-texte">Voir la page complète</span>---->
      </a>
    </div>
  </header>

  <div class="glossaire-sub__texte">
    <?php if ($terme['reg_texte']): ?>
      <?= $terme['reg_texte'] ?>
    <?php else: ?>
      <p class="regles-vide"><em>Aucune définition disponible.</em></p>
    <?php endif ?>
  </div>

</div>