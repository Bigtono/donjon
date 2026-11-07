<?php
// include/ajax/detail-pp-sub/ecran-mj-dupliquer.php — Dupliquer l'écran du MJ
// d'une autre campagne (SP-TB8f).
//
// Liste les autres campagnes du même ruleset dont l'utilisateur est MJ (toutes
// pour l'admin) et qui ont un écran non vide. Le choix ne fait que préremplir
// l'écran courant : rien n'est écrit avant « Enregistrer ».
//
// Paramètre GET : camp_id (int) — campagne de destination

require_once __DIR__ . '/../../db.php';
require_once __DIR__ . '/../../auth.php';
require_once __DIR__ . '/../../helpers.php';
require_once __DIR__ . '/../../ecran-mj.php';

requireAuth();

$camp_id = intParam($_GET['camp_id'] ?? 0);
$camp    = $camp_id ? chargerCampagneEcran($db, $camp_id) : null;
if (!$camp || !isMJ($db, $camp_id)):
  http_response_code(403);
  echo '<p class="erreur">Accès refusé.</p>';
  exit;
endif;

$campagnes = listerCampagnesDuplicables($db, $camp);
?>
<div class="ecran-mj-dupliquer">

  <h3 class="overlay-titre">Dupliquer l'écran d'une autre campagne</h3>

  <?php if (empty($campagnes)): ?>
    <p class="text-muted">Aucune autre de vos campagnes du même jeu de règles n'a d'écran du MJ.</p>
  <?php else: ?>
    <p class="text-muted">
      L'écran choisi remplace la disposition en cours. Rien n'est enregistré avant
      « Enregistrer ».
    </p>
    <ul class="ecran-mj-dupliquer__liste">
      <?php foreach ($campagnes as $c): ?>
        <li>
          <button type="button" class="ecran-mj-dupliquer__btn"
                  data-from="<?= (int)$c['camp_id'] ?>">
            <span class="ecran-mj-dupliquer__nom"><?= h($c['camp_nom']) ?></span>
            <span class="ecran-mj-dupliquer__meta">
              <?= (int)$c['nb_tableaux'] ?> tableau<?= (int)$c['nb_tableaux'] > 1 ? 'x' : '' ?>
              · <?= (int)$c['camp_ecran_colonnes'] ?> colonnes
            </span>
          </button>
        </li>
      <?php endforeach ?>
    </ul>
  <?php endif ?>

</div>

<script>
  (function () {
    var racine = document.querySelector('.ecran-mj-dupliquer');
    if (!racine) return;
    racine.addEventListener('click', function (e) {
      var btn = e.target.closest('.ecran-mj-dupliquer__btn');
      if (!btn || typeof ecranMJCharger !== 'function') return;
      fermerSubPanel();
      ecranMJCharger('camp', btn.getAttribute('data-from'));
    });
  })();
</script>
