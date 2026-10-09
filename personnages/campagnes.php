<?php
// personnages/campagnes.php — Campagnes du personnage (sous-page).
//
// Extrait de fiche.php lors du passage au sous-menu (retour 2026-09-01).
// Le rattachement reste à ÉCRITURE IMMÉDIATE, sans bouton « Enregistrer »
// (SP-PE5, archi §7.5c) : le déplacement en sous-page ne change rien à ça.
require_once '../include/db.php';
require_once '../include/auth.php';
require_once '../include/helpers.php';
require_once '../include/personnage_helpers.php';

requireAuth();

$pe_id = intParam($_GET['id'] ?? 0);
$perso = getPersonnageContext($db, $pe_id);

if (!$perso):
  header('Location: ' . BASE_URL . '/personnages/');
  exit;
endif;

setLastPersonnage((int)$perso['pe_id']);

$ruleset_id  = (int)$perso['pe_ruleset_var_id'];
$ruleset_rep = ($ruleset_id === 2) ? 'DD2024' : 'DD3.5';
$classes     = getPersonnageClasses($db, (int)$perso['pe_id']);

// L'onglet Magie n'est proposé qu'aux lanceurs — cla_mag_id > 0 les identifie
// dans les deux rulesets, seule la plage de valeurs diffère (D-MAG2).
$nav_lanceur = false;
foreach ($classes as $c):
  if ((int)$c['cla_mag_id'] > 0) { $nav_lanceur = true; break; }
endforeach;

$pe_camp_id      = (int)($perso['pe_camp_id'] ?? 0);
$campagnes_perso = getCampagnesPersonnage($db, (int)$perso['pe_id'], $pe_camp_id);

// Liste de l'éditeur = campagnes rattachables ∪ campagnes déjà liées.
// L'union protège les liaisons qui ne satisfont plus les critères de
// rattachement (campagne d'un autre ruleset héritée d'un import) : elles
// restent affichées et détachables au lieu de devenir invisibles.
$campagnes_liees = [];
foreach ($campagnes_perso as $c):
  $campagnes_liees[(int)$c['camp_id']] = $c;
endforeach;

$campagnes_editeur = [];
foreach (getCampagnesRattachables($db, (int)$perso['pe_j_id'], $ruleset_id) as $c):
  $cid = (int)$c['camp_id'];
  $campagnes_editeur[$cid] = [
    'id'       => $cid,
    'nom'      => $c['camp_nom'],
    'resume'   => $c['camp_resume'] ?? '',
    'univers'  => $c['univers_nom'] ?? '',
    'rattache' => isset($campagnes_liees[$cid]) && (int)$campagnes_liees[$cid]['est_liee'] === 1,
    'actif'    => !isset($campagnes_liees[$cid]) || (int)$campagnes_liees[$cid]['cp_actif'] === 1,
    'courante' => ($cid === $pe_camp_id),
  ];
endforeach;

$page_title   = 'Campagnes — ' . $perso['pe_nom'];
$js_module    = 'personnage';
$css_module   = 'personnages';
$nav_courante = 'campagnes';

require_once '../include/header.php';
?>

<script>
  var perPeId     = <?= (int)$perso['pe_id'] ?>;
  var perUrlEnreg = <?= json_encode(BASE_URL . '/personnages/enregistrement.php?ajax=1') ?>;
  // Campagnes (SP-PE5) — état initial de l'éditeur de rattachement
  var perCampCourante     = <?= $pe_camp_id ?>;
  var perCampagnesEditeur = <?= json_encode(array_values($campagnes_editeur), JSON_UNESCAPED_UNICODE) ?>;
</script>

<div class="per-fiche">

  <div class="per-fiche__header">
    <h1 class="per-fiche__nom"><?= h($perso['pe_nom']) ?></h1>
  </div>

  <?php require __DIR__ . '/../include/personnage-nav.php'; ?>

  <!-- ============================================================
       BLOC 9 — CAMPAGNES (SP-PE5)
       Lecture : campagne en cours en tête, puis historique traversé.
       Édition : rattachement à écriture immédiate (aucun bouton
       « Enregistrer » — cf. archi §7.5c).
       ============================================================ -->
  <section class="per-fiche__bloc" id="bloc-campagnes">
    <header class="per-fiche__bloc-header per-fiche__bloc-header--flex">
      <h2 class="per-fiche__bloc-titre">
        <i class="fa fa-map"></i> Campagnes
        <?php if (!empty($campagnes_perso)): ?>
          <span class="per-fiche__niveau-global">— <?= count($campagnes_perso) ?></span>
        <?php endif ?>
      </h2>
      <button class="btn btn-link btn-sm" id="btn-editer-campagnes"
              title="Modifier les campagnes"
              onclick="campagnesEditor.basculerEdition()">
        <i class="fa fa-edit"></i>
      </button>
    </header>

    <!-- Mode lecture -->
    <div class="per-fiche__bloc-body" id="campagnes-lecture">
      <?php if (empty($campagnes_perso)): ?>
        <p class="text-muted">
          Ce personnage n'est rattaché à aucune campagne. Utilisez « Modifier » pour l'y inscrire.
        </p>
      <?php else: ?>
        <ul class="per-camp">
          <?php foreach ($campagnes_perso as $c): ?>
            <?php $est_courante = (int)$c['est_courante'] === 1 ?>
            <li class="per-camp__item<?= $est_courante ? ' is-courante' : '' ?>">
              <div class="per-camp__ligne">
                <?php // SP-CP : la campagne est une page, plus un panneau detail-pp. ?>
                <a href="<?= BASE_URL ?>/campagnes/campagne.php?id=<?= (int)$c['camp_id'] ?>">
                  <?= h($c['camp_nom']) ?>
                </a>
                <?php if ($est_courante): ?>
                  <span class="per-camp__badge per-camp__badge--courante">En cours</span>
                <?php elseif ((int)$c['cp_actif'] !== 1): ?>
                  <span class="per-camp__badge">Participation terminée</span>
                <?php endif ?>
                <?php if (!empty($c['univers_nom'])): ?>
                  <span class="per-camp__univers text-muted">
                    <i class="fa fa-globe"></i> <?= h($c['univers_nom']) ?>
                  </span>
                <?php endif ?>
              </div>
              <?php if (!empty($c['camp_resume'])): ?>
                <p class="per-camp__resume text-muted text-sm"><?= h($c['camp_resume']) ?></p>
              <?php endif ?>
            </li>
          <?php endforeach ?>
        </ul>
      <?php endif ?>
    </div>

    <!-- Mode édition (caché par défaut, activé par JS) -->
    <div class="per-fiche__bloc-body noDisplay" id="campagnes-edition">
      <?php if (empty($campagnes_editeur)): ?>
        <p class="text-muted">
          Aucune campagne en <?= h($ruleset_rep) ?> sur ce compte.
          <a href="<?= BASE_URL ?>/campagnes/">Créer une campagne</a> pour pouvoir y rattacher ce personnage.
        </p>
      <?php else: ?>
        <p class="text-muted text-sm">
          Chaque clic est enregistré immédiatement. Seules vos campagnes en
          <?= h($ruleset_rep) ?> sont proposées.
        </p>
        <div id="campagnes-editor-lignes">
          <!-- Les lignes sont générées par campagnesEditor.init() en JS -->
        </div>
      <?php endif ?>
      <div class="per-classes-commit">
        <button class="btn btn-secondary btn-sm" onclick="campagnesEditor.fermer()">
          Fermer
        </button>
        <span class="per-classes-commit__msg noDisplay" id="campagnes-msg"></span>
      </div>
    </div>
  </section>

</div>

<?php require_once '../include/footer.php'; ?>
