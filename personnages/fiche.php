<?php
// personnages/fiche.php — Fiche personnage unique, responsive.
//
// SOUS-PHASE 3.1 : blocs Mode jeu (placeholder), Identité, Caracs, Combat.
// SOUS-PHASE 3.2 : bloc Classes — éditeur DOM inline (ajout / suppression /
//                  modification de niveau + domaines divins DD3.5).
//
// Blocs à venir : 6. NLS (3.5), 7. Compétences (3.3), 8. Dons (3.4), 9. Campagnes.
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

// Classes actuelles du personnage (avec domaines si DD3.5)
$classes = getPersonnageClasses($db, (int)$perso['pe_id']);

// Niveau global = somme des niveaux de toutes les classes
$niveau_global = array_sum(array_column($classes, 'pc_niveau'));

// Toutes les classes du ruleset pour le select de l'éditeur
$res_ids    = getActiveResIds($db);
$filtre_res = !empty($res_ids);
$ph         = $filtre_res ? resIdsPlaceholders($res_ids) : '';
$sql_cla    = "
  SELECT cla.cla_id, cla.cla_nom, cla.cla_clt_id, cla.cla_niveauMax,
         cla.cla_domaine_divin, cla.cla_mag_id
    FROM dd_classes cla
   WHERE cla.cla_ruleset_var_id = ?"
  . ($filtre_res ? " AND cla.cla_res_id IN ($ph)" : '') . "
   ORDER BY cla.cla_clt_id ASC, cla.cla_nom ASC";
$stmt_cla = $db->prepare($sql_cla);
$stmt_cla->execute($filtre_res ? array_merge([$ruleset_id], $res_ids) : [$ruleset_id]);
$toutes_classes = $stmt_cla->fetchAll();

// Domaines divins (DD3.5 uniquement)
$domaines = [];
if ($ruleset_rep === 'DD3.5'):
  $stmt_do = $db->query('SELECT do_id, do_nom FROM dd_domaines ORDER BY do_nom');
  $domaines = $stmt_do->fetchAll();
endif;

$page_title = $perso['pe_nom'];
$js_module  = 'personnage';
$css_module = 'personnages';

require_once '../include/header.php';
?>

<script>
  var perUrlDetail    = <?= json_encode(BASE_URL . '/include/ajax/detail-pp/personnage.php') ?>;
  var perUrlModifier  = <?= json_encode(BASE_URL . '/include/ajax/modifier/personnage.php') ?>;
  var perUrlEnreg     = <?= json_encode(BASE_URL . '/personnages/enregistrement.php?ajax=1') ?>;
  var perRuleset      = <?= json_encode($ruleset_rep) ?>;
  var perPeId         = <?= (int)$perso['pe_id'] ?>;

  // Données classes disponibles injectées en JS pour l'éditeur DOM
  var perClassesDisponibles = <?= json_encode(array_map(function($c) {
    return [
      'id'            => (int)$c['cla_id'],
      'nom'           => $c['cla_nom'],
      'clt_id'        => (int)$c['cla_clt_id'],
      'niveauMax'     => (int)$c['cla_niveauMax'],
      'domaineDivin'  => (bool)$c['cla_domaine_divin'],
    ];
  }, $toutes_classes), JSON_UNESCAPED_UNICODE) ?>;

  // Domaines disponibles (DD3.5)
  var perDomaines = <?= json_encode(array_map(function($d) {
    return ['id' => (int)$d['do_id'], 'nom' => $d['do_nom']];
  }, $domaines), JSON_UNESCAPED_UNICODE) ?>;

  // Classes actuelles du personnage (état initial de l'éditeur)
  var perClassesInitiales = <?= json_encode(array_map(function($c) {
    return [
      'pc_id'      => (int)$c['pc_id'],
      'cla_id'     => (int)$c['pc_cla_id'],
      'cla_nom'    => $c['cla_nom'],
      'clt_id'     => (int)$c['cla_clt_id'],
      'niveau'     => (int)$c['pc_niveau'],
      'niveauMax'  => (int)($c['cla_niveauMax'] ?? 20),
      'domaineDivin' => (bool)($c['cla_domaine_divin'] ?? false),
      'do_id_1'    => (int)($c['pc_do_id_1'] ?? 0),
      'do_id_2'    => (int)($c['pc_do_id_2'] ?? 0),
    ];
  }, $classes), JSON_UNESCAPED_UNICODE) ?>;
</script>

<div class="per-fiche">

  <!-- EN-TÊTE -->
  <div class="per-fiche__header">
    <div class="per-fiche__header-titre">
      <h1 class="per-fiche__nom"><?= h($perso['pe_nom']) ?></h1>
      <div class="per-fiche__meta">
        <span class="per-fiche__ruleset"><?= h($perso['ruleset_label']) ?></span>
        <?php if ($niveau_global > 0): ?>
          · <span class="per-fiche__niveau">Niveau <?= $niveau_global ?></span>
        <?php endif ?>
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

  <!-- BLOC 1 — MODE JEU (placeholder 3.7) -->
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

  <!-- BLOC 2 — IDENTITÉ -->
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
                   title="Disponible lors de la livraison du compendium Historiques">
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
          <dd><?= $perso['pe_sexe'] ? h($perso['pe_sexe']) : '<span class="text-muted">—</span>' ?></dd>
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
       BLOC 3 — CLASSES (éditeur DOM inline — 3.2)
       Remonté après Identité pour lecture rapide en partie.
       Deux modes : lecture (défaut) et édition (activé par bouton).
       ============================================================ -->
  <section class="per-fiche__bloc" id="bloc-classes">
    <header class="per-fiche__bloc-header per-fiche__bloc-header--flex">
      <h2 class="per-fiche__bloc-titre">
        <i class="fa fa-users"></i> Classes
        <?php if ($niveau_global > 0): ?>
          <span class="per-fiche__niveau-global">— niveau <?= $niveau_global ?></span>
        <?php endif ?>
      </h2>
      <button class="btn btn-link btn-sm" id="btn-editer-classes"
              onclick="classesEditor.basculerEdition()">
        <i class="fa fa-edit"></i> Modifier
      </button>
    </header>

    <!-- Mode lecture -->
    <div class="per-fiche__bloc-body" id="classes-lecture">
      <?php if (empty($classes)): ?>
        <p class="text-muted">Aucune classe définie.</p>
      <?php else: ?>
        <ul class="per-classes">
          <?php foreach ($classes as $c): ?>
            <li class="per-classes__item">
              <?php if ((int)$c['cla_clt_id'] === 2): ?>
                <span class="per-classes__badge-prestige" title="Classe de prestige">P</span>
              <?php endif ?>
              <a href="javascript:void(0)"
                 onclick="actualiserPage('<?= BASE_URL ?>/include/ajax/detail-pp/classe.php', {id: <?= (int)$c['pc_cla_id'] ?>}, 'externe')">
                <?= h($c['cla_nom']) ?>
              </a>
              <span class="per-classes__niveau">niv. <?= (int)$c['pc_niveau'] ?></span>
              <?php if ($ruleset_rep === 'DD3.5' && ($c['pc_do_id_1'] || $c['pc_do_id_2'])): ?>
                <span class="per-classes__domaines text-muted">
                  — domaines :
                  <?= h($c['domaine1_nom'] ?? '') ?>
                  <?php if ($c['pc_do_id_1'] && $c['pc_do_id_2']): ?>,<?php endif ?>
                  <?= h($c['domaine2_nom'] ?? '') ?>
                </span>
              <?php endif ?>
            </li>
          <?php endforeach ?>
        </ul>
      <?php endif ?>
    </div>

    <!-- Mode édition (caché par défaut, activé par JS) -->
    <div class="per-fiche__bloc-body noDisplay" id="classes-edition">
      <div id="classes-editor-lignes">
        <!-- Les lignes sont générées par classesEditor.init() en JS -->
      </div>
      <div class="per-classes-actions">
        <button class="btn btn-link btn-sm" onclick="classesEditor.ajouterLigne()">
          <i class="fa fa-plus"></i> Ajouter une classe
        </button>
      </div>
      <div class="per-classes-commit">
        <button class="btn btn-primary btn-sm" onclick="classesEditor.enregistrer()">
          <i class="fa fa-save"></i> Enregistrer
        </button>
        <button class="btn btn-secondary btn-sm" onclick="classesEditor.annuler()">
          Annuler
        </button>
        <span class="per-classes-commit__msg noDisplay" id="classes-msg"></span>
      </div>
    </div>

  </section>

  <!-- BLOC 4 — CARACTÉRISTIQUES -->
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

  <!-- BLOC 5 — COMBAT -->
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

  <!-- BLOC 6 — BACKGROUND -->
  <?php if (!empty($perso['pe_background'])): ?>
  <section class="per-fiche__bloc">
    <header class="per-fiche__bloc-header">
      <h2 class="per-fiche__bloc-titre">
        <i class="fa fa-book-open"></i> Background
      </h2>
    </header>
    <div class="per-fiche__bloc-body per-fiche__bloc-body--html">
      <?= $perso['pe_background'] ?>
    </div>
  </section>
  <?php endif ?>

  <!-- BLOCS À VENIR -->
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
