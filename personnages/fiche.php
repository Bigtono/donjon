<?php
// personnages/fiche.php — Fiche personnage unique, responsive.
//
// SP-PE1 : blocs Mode jeu (placeholder), Identité, Caracs, Combat.
// SP-PE2 : bloc Classes — éditeur DOM inline (ajout / suppression /
//          modification de niveau + domaines divins DD3.5).
// SP-PE3 : bloc Compétences — lecture (maîtrisées seules) + éditeur DOM
//          inline sur le tableau complet du ruleset, filtrable.
// SP-PE4 : bloc Dons — lecture seule ; le choix passe par le sélecteur
//          deux volets ouvert dans #detail-pp (detail-pp/dons-picker.php).
// SP-PE5 : bloc Campagnes — lecture (campagne en cours + historique) et
//          éditeur inline de rattachement à écriture immédiate.
// SP-PE6 : bloc NLS prestige (DD3.5) — un tableau par classe de prestige
//          influant sur le NLS, affectation vers les classes de base
//          lanceuses via l'éditeur DOM inline (commit global du bloc).
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

// Toutes les classes du ruleset pour le select de l'éditeur.
// Le ruleset passé est celui du PERSONNAGE, pas celui de la session : les deux
// peuvent diverger (personnage DD3.5 consulté depuis une session DD2024) et le
// croisement produirait des listes vides.
$res_ids    = getActiveResIds($db, $ruleset_id);
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

// ------------------------------------------------------------
// COMPÉTENCES (SP-PE3)
// Le tableau complet du ruleset sert à la fois au mode lecture
// (filtré sur pec_maitrise > 0, cf. archi §7.3) et à l'éditeur inline.
// ------------------------------------------------------------
$competences = getPersonnageCompetences($db, (int)$perso['pe_id'], $ruleset_id, $res_ids);

// Bonus de maîtrise DD2024 au niveau global (toujours 0 en DD3.5)
$bonus_maitrise = ($ruleset_rep === 'DD2024')
  ? getBonusMaitrise($db, $ruleset_id, $niveau_global)
  : 0;

// Modificateur de la caractéristique associée, indexé par comp_car_id.
// car_diminutif ('for', 'dex', …) correspond au suffixe des champs pe_*.
// Certaines compétences n'ont pas de caractéristique (comp_car_id = 0,
// ex. « Langue » en DD3.5) : modificateur 0, aucun champ pe_* à lire.
$mod_par_carac = [];
foreach ($competences as $c):
  $cid = (int)$c['comp_car_id'];
  if (!isset($mod_par_carac[$cid])):
    $dim = $c['car_diminutif'] ?? '';
    $mod_par_carac[$cid] = ($dim !== '' && isset($perso['pe_' . $dim]))
      ? modCarac((int)$perso['pe_' . $dim])
      : 0;
  endif;
endforeach;

// Mode lecture : compétences maîtrisées uniquement
$competences_maitrisees = array_values(array_filter($competences, function($c) {
  return (int)$c['pec_maitrise'] > 0;
}));

// ------------------------------------------------------------
// NLS PRESTIGE (SP-PE6 — DD3.5 uniquement)
// $nls est null si le bloc n'a pas lieu d'être : pas de classe de base
// lanceuse, ou aucune classe de prestige dont un niveau détenu fait
// progresser le NLS (archi §7.5d). Le bloc est alors omis de la fiche.
// ------------------------------------------------------------
$nls = ($ruleset_rep === 'DD3.5')
  ? getPersonnageNls($db, $classes, (int)$perso['pe_id'])
  : null;

// ------------------------------------------------------------
// DONS (SP-PE4)
// Le bloc de la fiche n'affiche que les dons choisis ; le catalogue
// complet vit dans le sélecteur (detail-pp/dons-picker.php).
// ------------------------------------------------------------
$stmt_dons = $db->prepare('
  SELECT ped.ped_do_id,
         ped.ped_niveau,
         do.do_nom,
         dad.dado_nom
    FROM dd_personnages_dons ped
    JOIN dd_dons do        ON do.do_id     = ped.ped_do_id
    LEFT JOIN dd_data_don dad ON dad.dado_id = do.do_dado_id
   WHERE ped.ped_pe_id = ?
   ORDER BY do.do_nom
');
$stmt_dons->execute([(int)$perso['pe_id']]);
$dons_perso = $stmt_dons->fetchAll();

// ------------------------------------------------------------
// CAMPAGNES (SP-PE5)
// Le mode lecture affiche la campagne en cours puis l'historique traversé ;
// l'éditeur propose les campagnes rattachables du propriétaire.
// ------------------------------------------------------------
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

foreach ($campagnes_perso as $c):
  $cid = (int)$c['camp_id'];
  if (!isset($campagnes_editeur[$cid])):
    $campagnes_editeur[$cid] = [
      'id'       => $cid,
      'nom'      => $c['camp_nom'],
      'resume'   => $c['camp_resume'] ?? '',
      'univers'  => $c['univers_nom'] ?? '',
      'rattache' => (int)$c['est_liee'] === 1,
      'actif'    => (int)$c['cp_actif'] === 1,
      'courante' => ($cid === $pe_camp_id),
    ];
  endif;
endforeach;

// Tri alphabétique stable (les liaisons ajoutées en fin de tableau ci-dessus
// ne doivent pas se retrouver reléguées après les campagnes rattachables)
uasort($campagnes_editeur, function($a, $b) {
  return strcasecmp($a['nom'], $b['nom']);
});

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

  // Tableau complet des compétences du ruleset (état initial de l'éditeur SP-PE3)
  var perCompetencesInitiales = <?= json_encode(array_map(function($c) use ($mod_par_carac) {
    return [
      'comp_id'      => (int)$c['comp_id'],
      'nom'          => $c['comp_nom'],
      'carac'        => strtoupper($c['car_diminutif'] ?? ''),
      'mod'          => (int)($mod_par_carac[(int)$c['comp_car_id']] ?? 0),
      'formation'    => (bool)$c['comp_formation'],
      'malusArmure'  => (bool)$c['comp_malusArmure'],
      'maitrise'     => (int)$c['pec_maitrise'],
    ];
  }, $competences), JSON_UNESCAPED_UNICODE) ?>;

  // Bonus de maîtrise DD2024 au niveau global (0 en DD3.5) — calcul du total live
  var perBonusMaitrise = <?= (int)$bonus_maitrise ?>;

  // Sélecteur de dons (SP-PE4)
  var perUrlDonsPicker = <?= json_encode(BASE_URL . '/include/ajax/detail-pp/dons-picker.php') ?>;
  var perUrlDonDetail  = <?= json_encode(BASE_URL . '/include/ajax/detail-pp/don.php') ?>;

  // Campagnes (SP-PE5) — état initial de l'éditeur de rattachement
  var perCampagnesEditeur = <?= json_encode(array_values($campagnes_editeur), JSON_UNESCAPED_UNICODE) ?>;
  var perCampCourante     = <?= $pe_camp_id ?>;

  // NLS prestige (SP-PE6) — état initial de l'éditeur. null si le bloc est omis.
  var perNlsBases = <?= json_encode($nls ? $nls['bases'] : [], JSON_UNESCAPED_UNICODE) ?>;
  var perNlsPrestiges = <?= json_encode($nls ? array_map(function($p) {
    return [
      'pc_id'   => $p['pc_id'],
      'nom'     => $p['nom'],
      'niveau'  => $p['niveau'],
      'niveaux' => $p['niveaux'],
    ];
  }, $nls['prestiges']) : [], JSON_UNESCAPED_UNICODE) ?>;
</script>

<div class="per-fiche">

  <?php
  // EN-TÊTE (SP-RS6d)
  // Structure à plat pilotée par une grille nommée : sous 992px le retour se
  // pose au bout de la ligne du nom et Modifier au bout de la ligne meta ;
  // au-dessus, les deux boutons restent groupés en haut à droite comme avant.
  // La mention du ruleset est retirée : le header du site l'affiche déjà.
  ?>
  <div class="per-fiche__header">
    <h1 class="per-fiche__nom"><?= h($perso['pe_nom']) ?></h1>

    <div class="per-fiche__meta">
      <?php if ($niveau_global > 0): ?>
        <span class="per-fiche__niveau">Niveau <?= $niveau_global ?></span>
      <?php endif ?>
      <?php if ($perso['campagne_courante_nom']): ?>
        <?php if ($niveau_global > 0): ?> · <?php endif ?>
        <span class="per-fiche__campagne">
          <i class="fa fa-map"></i> <?= h($perso['campagne_courante_nom']) ?>
        </span>
      <?php endif ?>
    </div>

    <a href="<?= BASE_URL ?>/personnages/" class="btn btn-link btn-sm per-fiche__retour"
       title="Retour à la liste">
      <i class="fa fa-arrow-left"></i>
      <span class="per-btn-label">Liste</span>
    </a>

    <button class="btn btn-secondary btn-sm per-fiche__modifier"
            onclick="ouvrirModifier(perUrlModifier, <?= (int)$perso['pe_id'] ?>)"
            title="Modifier le personnage">
      <i class="fa fa-edit"></i>
      <span class="per-btn-label">Modifier</span>
    </button>
  </div>

  <?php // BLOC 1 — MODE JEU (placeholder SP-PE8), repliable et replié par défaut ?>
  <section class="per-fiche__bloc per-fiche__bloc--mode-jeu">
    <header class="per-fiche__bloc-header per-fiche__bloc-header--flex">
      <h2 class="per-fiche__bloc-titre">
        <i class="fa fa-dice-d20"></i> Mode jeu
      </h2>
      <button type="button" class="btn btn-link btn-sm per-fiche__replier"
              id="btn-replier-mode-jeu"
              aria-controls="bloc-mode-jeu-body" aria-expanded="false"
              onclick="perReplierBloc('bloc-mode-jeu-body', this)"
              title="Afficher ou masquer le bloc">
        <i class="fa fa-chevron-down"></i>
      </button>
    </header>
    <div class="per-fiche__bloc-body noDisplay" id="bloc-mode-jeu-body">
      <p class="text-muted text-sm">
        Emplacement réservé. Le suivi des PV, conditions et autres variables de
        partie sera ajouté ultérieurement.
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

        <?php
        // CLASSES (éditeur DOM inline — SP-PE2)
        // Déplacé ici depuis son bloc propre (SP-RS6d) : lecture immédiate après
        // la race. Les identifiants #bloc-classes, #classes-lecture,
        // #classes-edition, #btn-editer-classes et #classes-msg sont conservés —
        // classesEditor (js/personnage.js) s'appuie dessus.
        ?>
        <div class="per-identite__row per-identite__row--large" id="bloc-classes">
          <dt>Classes<?php if ($niveau_global > 0): ?>
            <span class="per-fiche__niveau-global">niv. <?= $niveau_global ?></span>
          <?php endif ?></dt>
          <dd>
            <div class="per-identite__valeur-actions">

              <div class="per-identite__valeur" id="classes-lecture">
                <?php if (empty($classes)): ?>
                  <span class="text-muted">Aucune classe définie.</span>
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

              <button class="btn btn-link btn-sm per-fiche__editer" id="btn-editer-classes"
                      onclick="classesEditor.basculerEdition()"
                      title="Modifier les classes">
                <i class="fa fa-edit"></i><span class="per-btn-label">Modifier</span>
              </button>
            </div>

            <?php // Mode édition (caché par défaut, activé par JS) ?>
            <div class="noDisplay" id="classes-edition">
              <div id="classes-editor-lignes">
                <?php // Les lignes sont générées par classesEditor.init() en JS ?>
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

  <!-- ============================================================
       BLOC 6 — COMPÉTENCES (éditeur DOM inline — SP-PE3)
       Lecture : compétences maîtrisées uniquement (archi §7.3).
       Édition : tableau complet du ruleset, filtrable.
       ============================================================ -->
  <section class="per-fiche__bloc" id="bloc-competences">
    <header class="per-fiche__bloc-header per-fiche__bloc-header--flex">
      <h2 class="per-fiche__bloc-titre">
        <i class="fa fa-list-check"></i> Compétences
      </h2>
      <button class="btn btn-link btn-sm" id="btn-editer-competences"
              onclick="competencesEditor.basculerEdition()">
        <i class="fa fa-edit"></i> Modifier
      </button>
    </header>

    <!-- Mode lecture -->
    <div class="per-fiche__bloc-body" id="competences-lecture">
      <?php if (empty($competences)): ?>
        <p class="text-muted">
          Aucune compétence disponible pour ce ruleset avec les sources actives.
          <a href="<?= BASE_URL ?>/profil/">Configurer mes sources</a>
        </p>
      <?php elseif (empty($competences_maitrisees)): ?>
        <p class="text-muted">Aucune compétence maîtrisée. Utilisez « Modifier » pour les saisir.</p>
      <?php else: ?>
        <?php
        // Rendu aligné sur le bloc Dons (SP-RS6e) : liste flex, nom à gauche,
        // valeurs calées à droite et alignées en haut si le nom passe à la
        // ligne. Seule différence avec les dons : une ligne d'en-tête, en gras.
        ?>
        <ul class="per-comp">
          <li class="per-comp__item per-comp__item--entete">
            <span class="per-comp__nom">Compétence</span>
            <span class="per-comp__val">Carac</span>
            <span class="per-comp__val"><?= $ruleset_rep === 'DD2024' ? 'Maîtrise' : 'Rangs' ?></span>
            <span class="per-comp__val">Total</span>
          </li>

          <?php foreach ($competences_maitrisees as $c): ?>
            <?php
              $maitrise = (int)$c['pec_maitrise'];
              $mod      = (int)($mod_par_carac[(int)$c['comp_car_id']] ?? 0);
              $total    = bonusCompetence($maitrise, $mod, $ruleset_rep, $bonus_maitrise);
            ?>
            <li class="per-comp__item">
              <span class="per-comp__nom">
                <a href="javascript:void(0)"
                   onclick="actualiserPage('<?= BASE_URL ?>/include/ajax/detail-pp/competence.php', {id: <?= (int)$c['comp_id'] ?>}, 'externe')">
                  <?= h($c['comp_nom']) ?>
                </a>
                <?php if ((int)$c['comp_formation'] === 1): ?>
                  <span class="per-comp__flag" title="Formation requise">F</span>
                <?php endif ?>
                <?php if ((int)$c['comp_malusArmure'] === 1): ?>
                  <span class="per-comp__flag" title="Soumise au malus d'armure">A</span>
                <?php endif ?>
              </span>
              <span class="per-comp__val">
                <?php if (!empty($c['car_diminutif'])): ?>
                  <?= h(strtoupper($c['car_diminutif'])) ?>
                  <span class="text-muted"><?= formatMod($mod) ?></span>
                <?php else: ?>
                  <span class="text-muted" title="Aucune caractéristique associée">—</span>
                <?php endif ?>
              </span>
              <span class="per-comp__val">
                <?php if ($ruleset_rep === 'DD2024'): ?>
                  <?= $maitrise >= 2 ? 'Expertise' : 'Maîtrise' ?>
                <?php else: ?>
                  <?= $maitrise ?>
                <?php endif ?>
              </span>
              <span class="per-comp__val per-comp__val--total"><?= formatMod($total) ?></span>
            </li>
          <?php endforeach ?>
        </ul>
      <?php endif ?>
    </div>

    <!-- Mode édition (caché par défaut, activé par JS) -->
    <div class="per-fiche__bloc-body noDisplay" id="competences-edition">
      <div class="per-comp-editor__filtre">
        <input type="search" id="competences-filtre" class="per-comp-editor__recherche"
               placeholder="Filtrer les compétences…" autocomplete="off"
               oninput="competencesEditor.filtrer(this.value)">
        <span class="text-muted text-sm">
          <?= $ruleset_rep === 'DD2024'
            ? 'Aucune / Maîtrise / Expertise'
            : 'Nombre de rangs (0 = non maîtrisée)' ?>
        </span>
      </div>
      <div id="competences-editor-lignes">
        <!-- Le tableau est généré par competencesEditor.init() en JS -->
      </div>
      <div class="per-classes-commit">
        <button class="btn btn-primary btn-sm" onclick="competencesEditor.enregistrer()">
          <i class="fa fa-save"></i> Enregistrer
        </button>
        <button class="btn btn-secondary btn-sm" onclick="competencesEditor.annuler()">
          Annuler
        </button>
        <span class="per-classes-commit__msg noDisplay" id="competences-msg"></span>
      </div>
    </div>

  </section>

  <?php if ($nls): ?>
  <!-- ============================================================
       BLOC 7 — NLS PRESTIGE (SP-PE6 — DD3.5 uniquement)
       Affiché seulement si le personnage a au moins une classe de base
       lanceuse ET une classe de prestige dont un niveau détenu fait
       progresser le NLS (archi §7.5d).
       Lecture : un tableau par classe de prestige, un niveau par ligne.
       Édition : select des classes de base compatibles par niveau,
       commit global du bloc (action enregistrerNls).
       ============================================================ -->
  <section class="per-fiche__bloc" id="bloc-nls">
    <header class="per-fiche__bloc-header per-fiche__bloc-header--flex">
      <h2 class="per-fiche__bloc-titre">
        <i class="fa fa-hat-wizard"></i> NLS prestige
      </h2>
      <button class="btn btn-link btn-sm" id="btn-editer-nls"
              onclick="nlsEditor.basculerEdition()">
        <i class="fa fa-edit"></i> Modifier
      </button>
    </header>

    <!-- Mode lecture -->
    <div class="per-fiche__bloc-body" id="nls-lecture">
      <p class="text-muted text-sm">
        Affectation des niveaux de classe de prestige aux classes de base
        lanceuses de sorts. Le niveau de lanceur de sorts effectif est calculé
        dans la vue Magie.
      </p>
      <?php foreach ($nls['prestiges'] as $p): ?>
        <div class="per-nls__classe">
          <h3 class="per-nls__titre">
            <?= h($p['nom']) ?>
            <span class="per-classes__niveau">niv. <?= (int)$p['niveau'] ?></span>
          </h3>
          <div class="table-dd-wrap">
            <table class="table-dd per-nls-table">
              <thead>
                <tr>
                  <th class="col-stat">Niveau</th>
                  <th class="per-nls-table__prog">Progression</th>
                  <th class="per-nls-table__classe">Classe de base affectée</th>
                </tr>
              </thead>
              <tbody>
                <?php foreach ($p['niveaux'] as $n => $niv): ?>
                  <?php
                    $progresse = $niv['arcane'] || $niv['divin'] || $niv['effectif'];
                    $base_nom  = '';
                    foreach ($nls['bases'] as $b):
                      if ($b['pc_id'] === $niv['base_pc_id']):
                        $base_nom = $b['nom'];
                        break;
                      endif;
                    endforeach;
                  ?>
                  <tr>
                    <td><?= (int)$n ?></td>
                    <td class="per-nls-table__prog">
                      <?php if ($progresse): ?>
                        <?= h(libelleProgressionNls($niv)) ?>
                      <?php else: ?>
                        <span class="text-muted">—</span>
                      <?php endif ?>
                    </td>
                    <td class="per-nls-table__classe">
                      <?php if (!$progresse): ?>
                        <span class="text-muted">Sans progression de NLS</span>
                      <?php elseif ($base_nom !== ''): ?>
                        <?= h($base_nom) ?>
                      <?php else: ?>
                        <span class="per-nls__a-affecter">À affecter</span>
                      <?php endif ?>
                    </td>
                  </tr>
                <?php endforeach ?>
              </tbody>
            </table>
          </div>
        </div>
      <?php endforeach ?>
    </div>

    <!-- Mode édition (caché par défaut, activé par JS) -->
    <div class="per-fiche__bloc-body noDisplay" id="nls-edition">
      <p class="text-muted text-sm">
        Affectez chaque niveau à l'une des classes de base lanceuses du
        personnage. Seules les classes compatibles avec le type de magie du
        niveau sont proposées. Un niveau peut rester « À affecter ».
      </p>
      <div id="nls-editor-lignes">
        <!-- Les tableaux sont générés par nlsEditor en JS -->
      </div>
      <div class="per-classes-commit">
        <button class="btn btn-primary btn-sm" onclick="nlsEditor.enregistrer()">
          <i class="fa fa-save"></i> Enregistrer
        </button>
        <button class="btn btn-secondary btn-sm" onclick="nlsEditor.annuler()">
          Annuler
        </button>
        <span class="per-classes-commit__msg noDisplay" id="nls-msg"></span>
      </div>
    </div>
  </section>
  <?php endif ?>

  <!-- ============================================================
       BLOC 8 — DONS (SP-PE4)
       Lecture seule ici ; l'ajout et le retrait passent par le
       sélecteur deux volets ouvert dans #detail-pp.
       ============================================================ -->
  <section class="per-fiche__bloc" id="bloc-dons">
    <header class="per-fiche__bloc-header per-fiche__bloc-header--flex">
      <h2 class="per-fiche__bloc-titre">
        <i class="fa fa-star"></i> Dons
        <?php if (!empty($dons_perso)): ?>
          <span class="per-fiche__niveau-global">— <?= count($dons_perso) ?></span>
        <?php endif ?>
      </h2>
      <button class="btn btn-link btn-sm" onclick="donsPicker.ouvrir()">
        <i class="fa fa-plus"></i> Choisir des dons
      </button>
    </header>
    <div class="per-fiche__bloc-body">
      <?php if (empty($dons_perso)): ?>
        <p class="text-muted">Aucun don choisi. Utilisez « Choisir des dons » pour les saisir.</p>
      <?php else: ?>
        <ul class="per-dons">
          <?php foreach ($dons_perso as $d): ?>
            <li class="per-dons__item">
              <span class="per-dons__nom">
                <a href="javascript:void(0)"
                   onclick="actualiserPage('<?= BASE_URL ?>/include/ajax/detail-pp/don.php', {id: <?= (int)$d['ped_do_id'] ?>}, 'externe')">
                  <?= h($d['do_nom']) ?>
                </a>
              </span>
              <span class="per-dons__cat text-muted"><?= h($d['dado_nom'] ?? '—') ?></span>
            </li>
          <?php endforeach ?>
        </ul>
      <?php endif ?>
    </div>
  </section>

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
              onclick="campagnesEditor.basculerEdition()">
        <i class="fa fa-edit"></i> Modifier
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

  <!-- BLOC 10 — BACKGROUND -->
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
        <li>
          Vue Magie dédiée —
          <a href="<?= BASE_URL ?>/personnages/magie.php?id=<?= (int)$perso['pe_id'] ?>">accéder</a>
        </li>
      </ul>
    </div>
  </section>

</div><!-- .per-fiche -->

<?php require_once '../include/footer.php'; ?>
