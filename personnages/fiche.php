<?php
// personnages/fiche.php — Fiche personnage unique, responsive.
//
// SOUS-PHASE 3.1 : blocs livrés
//   1. Mode jeu       (placeholder)
//   2. Identité       (nom, race+archétype, historique, sexe, alignement)
//   3. Caractéristiques (6 caracs + modificateurs)
//   4. Combat         (CA, PV)
//
// Blocs à venir : 5. Classes (3.2), 6. NLS (3.5), 7. Compétences (3.3),
//                 8. Dons (3.4), 9. Campagnes.
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

// Mémoriser ce perso comme "dernier consulté"
setLastPersonnage((int)$perso['pe_id']);

$ruleset_rep = ((int)$perso['pe_ruleset_var_id'] === 2) ? 'DD2024' : 'DD3.5';

// Classes (pour le bloc 5 — affichage simple en 3.1, éditeur réel en 3.2)
$classes = getPersonnageClasses($db, (int)$perso['pe_id']);

$page_title = $perso['pe_nom'];
$js_module  = 'personnage';
$css_module = 'personnages';

require_once '../include/header.php';
?>

<script>
  var perUrlDetail   = <?= json_encode(BASE_URL . '/include/ajax/detail-pp/personnage.php') ?>;
  var perUrlModifier = <?= json_encode(BASE_URL . '/include/ajax/modifier/personnage.php') ?>;
  var perUrlEnreg    = <?= json_encode(BASE_URL . '/personnages/enregistrement.php?ajax=1') ?>;
</script>

<div class="per-fiche">

  <!-- ============================================================
       EN-TÊTE
       ============================================================ -->
  <div class="per-fiche__header">
    <div class="per-fiche__header-titre">
      <h1 class="per-fiche__nom"><?= h($perso['pe_nom']) ?></h1>
      <div class="per-fiche__meta">
        <span class="per-fiche__ruleset"><?= h($perso['ruleset_label']) ?></span>
        <?php if ($perso['campagne_courante_nom']): ?>
          · <span class="per-fiche__campagne">
              <i class="fa fa-map"></i> <?= h($perso['campagne_courante_nom']) ?>
            </span>
        <?php endif ?>
      </div>
    </div>
    <div class="per-fiche__header-actions">
      <a href="<?= BASE_URL ?>/personnages/" class="btn btn-link btn-sm">
        <i class="fa fa-arrow-left"></i> Liste
      </a>
      <button class="btn btn-secondary btn-sm"
              onclick="ouvrirModifier(perUrlModifier, <?= (int)$perso['pe_id'] ?>)">
        <i class="fa fa-edit"></i> Modifier
      </button>
    </div>
  </div>

  <!-- ============================================================
       BLOC 1 — MODE JEU (placeholder)
       Position prioritaire en haut pour accès rapide en partie.
       Contenu réel : 3.7 — variables de jeu suivies (PV courants,
       conditions, emplacements de sorts utilisés, etc.).
       ============================================================ -->
  <section class="per-fiche__bloc per-fiche__bloc--mode-jeu">
    <header class="per-fiche__bloc-header">
      <h2 class="per-fiche__bloc-titre">
        <i class="fa fa-dice-d20"></i> Mode jeu
      </h2>
    </header>
    <div class="per-fiche__bloc-body">
      <p class="text-muted text-sm">
        Emplacement réservé. Le suivi des PV, conditions et autres variables de
        partie sera ajouté en sous-phase 3.7.
      </p>
    </div>
  </section>

  <!-- ============================================================
       BLOC 2 — IDENTITÉ
       ============================================================ -->
  <section class="per-fiche__bloc">
    <header class="per-fiche__bloc-header">
      <h2 class="per-fiche__bloc-titre">
        <i class="fa fa-id-card"></i> Identité
      </h2>
    </header>
    <div class="per-fiche__bloc-body">
      <dl class="per-identite">

        <div class="per-identite__row">
          <dt>Race</dt>
          <dd>
            <?php if (!empty($perso['pe_ra_id'])): ?>
              <a href="javascript:void(0)"
                 onclick="actualiserPage('<?= BASE_URL ?>/include/ajax/detail-pp/race.php', {id: <?= (int)$perso['pe_ra_id'] ?>}, 'externe')">
                <?= h($perso['race_nom'] ?? '—') ?>
              </a>
              <?php if ($ruleset_rep === 'DD3.5' && !empty($perso['pe_arc_id'])): ?>
                /
                <a href="javascript:void(0)"
                   onclick="actualiserPage('<?= BASE_URL ?>/include/ajax/detail-pp/race.php', {id: <?= (int)$perso['pe_arc_id'] ?>}, 'externe')">
                  <?= h($perso['archetype_nom'] ?? '—') ?>
                </a>
              <?php endif ?>
            <?php else: ?>
              <span class="text-muted">—</span>
            <?php endif ?>
          </dd>
        </div>

        <?php if ($ruleset_rep === 'DD2024'): ?>
          <div class="per-identite__row">
            <dt>Historique</dt>
            <dd>
              <?php if (!empty($perso['pe_hi_id'])): ?>
                <a href="javascript:void(0)"
                   onclick="actualiserPage('<?= BASE_URL ?>/include/ajax/detail-pp/historique.php', {id: <?= (int)$perso['pe_hi_id'] ?>}, 'externe')"
                   title="Le détail des historiques sera disponible lors de la livraison du compendium Historiques">
                  <?= h($perso['historique_nom'] ?? '—') ?>
                </a>
              <?php else: ?>
                <span class="text-muted">—</span>
              <?php endif ?>
            </dd>
          </div>
        <?php endif ?>

        <div class="per-identite__row">
          <dt>Sexe</dt>
          <dd>
            <?= $perso['pe_sexe'] ? h($perso['pe_sexe']) : '<span class="text-muted">—</span>' ?>
          </dd>
        </div>

        <div class="per-identite__row">
          <dt>Alignement</dt>
          <dd>
            <?php if (!empty($perso['pe_al_id'])): ?>
              <?= h($perso['alignement_nom']) ?>
              <span class="text-muted">(<?= h($perso['alignement_abr']) ?>)</span>
            <?php else: ?>
              <span class="text-muted">—</span>
            <?php endif ?>
          </dd>
        </div>

      </dl>
    </div>
  </section>

  <!-- ============================================================
       BLOC 3 — CARACTÉRISTIQUES (grille fluide)
       Valeurs brutes + modificateurs calculés (affichage uniquement).
       ============================================================ -->
  <section class="per-fiche__bloc">
    <header class="per-fiche__bloc-header">
      <h2 class="per-fiche__bloc-titre">
        <i class="fa fa-chart-bar"></i> Caractéristiques
      </h2>
    </header>
    <div class="per-fiche__bloc-body">
      <div class="per-caracs">
        <?php
          $caracs_def = [
            ['abr' => 'FOR', 'lbl' => 'Force',        'val' => (int)$perso['pe_for']],
            ['abr' => 'CON', 'lbl' => 'Constitution', 'val' => (int)$perso['pe_con']],
            ['abr' => 'DEX', 'lbl' => 'Dextérité',    'val' => (int)$perso['pe_dex']],
            ['abr' => 'INT', 'lbl' => 'Intelligence', 'val' => (int)$perso['pe_int']],
            ['abr' => 'SAG', 'lbl' => 'Sagesse',      'val' => (int)$perso['pe_sag']],
            ['abr' => 'CHA', 'lbl' => 'Charisme',     'val' => (int)$perso['pe_cha']],
          ];
        ?>
        <?php foreach ($caracs_def as $c): ?>
          <div class="per-carac">
            <div class="per-carac__abr" title="<?= h($c['lbl']) ?>"><?= $c['abr'] ?></div>
            <div class="per-carac__val"><?= $c['val'] ?></div>
            <div class="per-carac__mod"><?= formatMod(modCarac($c['val'])) ?></div>
          </div>
        <?php endforeach ?>
      </div>
    </div>
  </section>

  <!-- ============================================================
       BLOC 4 — COMBAT
       ============================================================ -->
  <section class="per-fiche__bloc">
    <header class="per-fiche__bloc-header">
      <h2 class="per-fiche__bloc-titre">
        <i class="fa fa-shield-alt"></i> Combat
      </h2>
    </header>
    <div class="per-fiche__bloc-body">
      <div class="per-combat">
        <div class="per-combat__stat">
          <div class="per-combat__lbl">CA</div>
          <div class="per-combat__val"><?= (int)$perso['pe_ca'] ?></div>
          <div class="per-combat__hint">Classe d'armure</div>
        </div>
        <div class="per-combat__stat">
          <div class="per-combat__lbl">PV</div>
          <div class="per-combat__val"><?= (int)$perso['pe_pv'] ?></div>
          <div class="per-combat__hint">Points de vie totaux</div>
        </div>
      </div>
    </div>
  </section>

  <!-- ============================================================
       BLOC 5 — CLASSES (affichage simple — éditeur en 3.2)
       ============================================================ -->
  <section class="per-fiche__bloc">
    <header class="per-fiche__bloc-header">
      <h2 class="per-fiche__bloc-titre">
        <i class="fa fa-users"></i> Classes
      </h2>
    </header>
    <div class="per-fiche__bloc-body">
      <?php if (empty($classes)): ?>
        <p class="text-muted">Aucune classe.</p>
      <?php else: ?>
        <ul class="per-classes">
          <?php foreach ($classes as $c): ?>
            <li class="per-classes__item">
              <a href="javascript:void(0)"
                 onclick="actualiserPage('<?= BASE_URL ?>/include/ajax/detail-pp/classe.php', {id: <?= (int)$c['pc_cla_id'] ?>}, 'externe')">
                <?= h($c['cla_nom']) ?>
              </a>
              <span class="per-classes__niveau">niveau <?= (int)$c['pc_niveau'] ?></span>
            </li>
          <?php endforeach ?>
        </ul>
      <?php endif ?>
      <p class="text-muted text-sm">
        L'éditeur multi-classes complet (ajout / suppression / modification de niveau) arrive en sous-phase 3.2.
      </p>
    </div>
  </section>

  <!-- ============================================================
       BLOCS 6–9 — À VENIR
       ============================================================ -->
  <section class="per-fiche__bloc per-fiche__bloc--avenir">
    <header class="per-fiche__bloc-header">
      <h2 class="per-fiche__bloc-titre">
        <i class="fa fa-hourglass-half"></i> À venir
      </h2>
    </header>
    <div class="per-fiche__bloc-body">
      <ul class="per-avenir-liste">
        <?php if ($ruleset_rep === 'DD3.5'): ?>
          <li>NLS prestige (sous-phase 3.5)</li>
        <?php endif ?>
        <li>Compétences (sous-phase 3.3)</li>
        <li>Dons (sous-phase 3.4)</li>
        <li>Campagnes du personnage</li>
        <li>
          Vue Magie dédiée —
          <a href="<?= BASE_URL ?>/personnages/magie.php?id=<?= (int)$perso['pe_id'] ?>">accéder</a>
        </li>
      </ul>
    </div>
  </section>

</div><!-- .per-fiche -->

<?php require_once '../include/footer.php'; ?>
