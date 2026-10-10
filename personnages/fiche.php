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

setLastPersonnage((int)$perso['pe_id'], (int)$perso['pe_ruleset_var_id']);

$ruleset_id  = (int)$perso['pe_ruleset_var_id'];
$ruleset_rep = ($ruleset_id === 2) ? 'DD2024' : 'DD3.5';

// Classes actuelles du personnage (avec domaines si DD3.5)
$classes = getPersonnageClasses($db, (int)$perso['pe_id']);

// La vue Magie n'est proposée que si le personnage a au moins une classe
// lanceuse — cla_mag_id > 0 identifie les lanceuses dans les deux rulesets
// (D-MAG2 : la plage de valeurs diffère, le test « > 0 » reste valable).
$aClasseLanceuse = false;
foreach ($classes as $c):
  if ((int)$c['cla_mag_id'] > 0) { $aClasseLanceuse = true; break; }
endforeach;

// Niveau global = somme des niveaux des classes, SOUS-CLASSES EXCLUES.
// Une sous-classe DD2024 (cla_clt_id = 5) est une ligne de
// dd_personnages_classes comme une autre, mais elle n'ajoute aucun niveau : le
// Domaine de la Vie d'Adon est une facette de son Clerc, pas une classe de
// plus. Les compter donnait 7 à un clerc 5 / guerrier 1 — et un bonus de
// maîtrise faux avec (SP-PE10h).
$niveau_global = 0;
foreach ($classes as $c):
  if ((int)$c['cla_clt_id'] !== CLT_SOUS_CLASSE) $niveau_global += (int)$c['pc_niveau'];
endforeach;

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

// ------------------------------------------------------------
// CAPACITÉS SPÉCIALES (SP-PE11)
// Déduites de la race et des classes — aucune saisie, aucun champ : les
// tables de liaison dd_race_capacite et dd_classe_capacite disent déjà tout.
// ------------------------------------------------------------

// Race, et archétype DD3.5 s'il y en a un : ses capacités s'ajoutent à
// celles de la race de base.
$ra_ids = array_values(array_filter([
  (int)($perso['pe_ra_id'] ?? 0),
  (int)($perso['pe_arc_id'] ?? 0),
]));
$capacites_race = [];
if ($ra_ids):
  $ph   = implode(',', array_fill(0, count($ra_ids), '?'));
  $stmt = $db->prepare("
    SELECT cap.cap_id, cap.cap_nom, cap.cap_type
      FROM dd_race_capacite cr
      JOIN dd_capacites_speciales cap ON cap.cap_id = cr.cr_cap_id
     WHERE cr.cr_ra_id IN ($ph)
  ORDER BY cr.cr_ordre, cap.cap_nom
  ");
  $stmt->execute($ra_ids);
  $capacites_race = $stmt->fetchAll();
endif;

// Classes : seulement les capacités dont le niveau d'obtention est ATTEINT.
// Une requête par classe — un personnage en a deux ou trois, et le niveau
// seuil diffère de l'une à l'autre.
$capacites_classes = [];
$stmt_cap_cla = $db->prepare('
  SELECT cap.cap_id, cap.cap_nom, cc.cc_niveau, cc.cc_precision
    FROM dd_classe_capacite cc
    JOIN dd_capacites_speciales cap ON cap.cap_id = cc.cc_cap_id
   WHERE cc.cc_cla_id = ? AND cc.cc_niveau <= ?
ORDER BY cc.cc_niveau, cap.cap_nom
');
foreach ($classes as $c):
  // Une sous-classe DD2024 n'a pas de niveau propre : elle suit celui de la
  // classe qui la porte, sans quoi ses capacités resteraient invisibles.
  $niveau_ref = (int)$c['pc_niveau'];
  if ((int)$c['cla_clt_id'] === CLT_SOUS_CLASSE):
    foreach ($classes as $parent):
      if ((int)$parent['pc_cla_id'] === (int)($c['cla_cla_id'] ?? 0)):
        $niveau_ref = (int)$parent['pc_niveau'];
        break;
      endif;
    endforeach;
  endif;

  $stmt_cap_cla->execute([(int)$c['pc_cla_id'], $niveau_ref]);
  $lignes = $stmt_cap_cla->fetchAll();
  if ($lignes):
    $capacites_classes[] = ['nom' => $c['cla_nom'], 'capacites' => $lignes];
  endif;
endforeach;

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
// Les campagnes du personnage ont leur propre sous-page (campagnes.php)
// depuis le passage au sous-menu : les charger ici serait deux requêtes et
// une sérialisation JSON pour un bloc qui n'y est plus.


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

    <?php // Le niveau global a quitté cette ligne : il ouvre désormais le bloc
          // Identité, où il se lit avec la race et les classes (SP-PE10h). ?>
    <div class="per-fiche__meta">
      <?php if ($perso['campagne_courante_nom']): ?>
        <span class="per-fiche__campagne">
          <i class="fa fa-map"></i> <?= h($perso['campagne_courante_nom']) ?>
        </span>
      <?php endif ?>
    </div>

    <a href="<?= BASE_URL ?>/personnages/" class="btn btn-link btn-sm per-fiche__retour"
       title="Retour à la liste">
      <i class="fa fa-arrow-left"></i>
    </a>

    <button class="btn btn-secondary btn-sm per-fiche__modifier"
            onclick="ouvrirModifier(perUrlModifier, <?= (int)$perso['pe_id'] ?>)"
            title="Modifier le personnage">
      <i class="fa fa-edit"></i>
    </button>
  </div>

  <?php // BLOC 1 — MODE JEU (placeholder SP-PE8), repliable et replié par défaut ?>
  <?php $nav_courante = 'fiche'; $nav_lanceur = $aClasseLanceuse; ?>
  <?php require __DIR__ . '/../include/personnage-nav.php'; ?>

  <?php // Masquable depuis le profil (SP-PE10l) : le bloc n'est encore qu'un
        // emplacement réservé — le suivi des PV et des variables de partie
        // relève de SP-PE8 — et coûtait une barre d'en-tête pour rien. ?>
  <?php if (!empty($_SESSION['j_affichage_mode_jeu'])): ?>
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
  <?php endif ?>

  <!-- BLOC 2 — IDENTITÉ (refondu SP-PE10h) -->
  <?php // Sans titre, comme les blocs de stats (SP-PE10k) : « Identité » ne dit
        // rien de plus que « Niveau 6 · Race Humain · Clerc 5 » juste en
        // dessous, et coûtait une barre d'en-tête entière. ?>
  <section class="per-fiche__bloc per-fiche__bloc--identite">
    <div class="per-fiche__bloc-body">

      <?php // ---- Une seule rangée : niveau, race, sexe, alignement --------
            // Chaque champ est un bloc insécable qui passe à la ligne entier
            // quand la largeur manque — ce sont des couples libellé/valeur,
            // les couper au milieu ne rendrait service à personne. ?>
      <dl class="per-identite">

        <?php if ($niveau_global > 0): ?>
          <div class="per-identite__champ">
            <dt>Niveau</dt>
            <?php // Le bonus de maîtrise suit le niveau : il s'en déduit, et se
                  // lit donc avec lui plutôt que dans une tuile à part (SP-PE11). ?>
            <dd>
              <?= $niveau_global ?><?php if ($ruleset_rep === 'DD2024'): ?>
                <span class="per-identite__appoint" title="Bonus de maîtrise">(BM <?= formatMod($bonus_maitrise) ?>)</span>
              <?php endif ?>
            </dd>
          </div>
        <?php endif ?>

        <div class="per-identite__champ">
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

        <div class="per-identite__champ">
          <dt>Sexe</dt>
          <dd><?= $perso['pe_sexe'] ? h($perso['pe_sexe']) : '<span class="text-muted">—</span>' ?></dd>
        </div>

        <div class="per-identite__champ">
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

        <?php if ($ruleset_rep === 'DD2024'): ?>
          <div class="per-identite__champ">
            <dt>Historique</dt>
            <dd>
              <?php if (!empty($perso['pe_hi_id'])): ?>
                <a href="javascript:void(0)"
                   onclick="actualiserPage('<?= BASE_URL ?>/include/ajax/detail-pp/historique.php', {id: <?= (int)$perso['pe_hi_id'] ?>}, 'externe')">
                  <?= h($perso['historique_nom'] ?? '—') ?>
                </a>
              <?php else: ?>
                <span class="text-muted">—</span>
              <?php endif ?>
            </dd>
          </div>
        <?php endif ?>

      </dl>

      <?php
        // ---- Classes : une par ligne, sans libellé ni « niv. » -----------
        // Les SOUS-CLASSES DD2024 ne sont pas des classes de plus : le Domaine
        // de la Vie est une facette du Clerc. Elles rejoignent donc leur classe
        // parente, entre parenthèses — « Clerc 5 (Domaine de la Vie) ».
        $lignes_classes = [];
        $index_par_cla  = [];
        foreach ($classes as $c):
          if ((int)$c['cla_clt_id'] === CLT_SOUS_CLASSE) continue;
          $index_par_cla[(int)$c['pc_cla_id']] = count($lignes_classes);
          $lignes_classes[] = ['c' => $c, 'sous' => []];
        endforeach;
        foreach ($classes as $c):
          if ((int)$c['cla_clt_id'] !== CLT_SOUS_CLASSE) continue;
          $parent = (int)($c['cla_cla_id'] ?? 0);
          if (isset($index_par_cla[$parent])):
            $lignes_classes[$index_par_cla[$parent]]['sous'][] = $c;
          else:
            // Sous-classe orpheline (classe parente retirée) : plutôt que de la
            // perdre en silence, elle tient sa propre ligne.
            $lignes_classes[] = ['c' => $c, 'sous' => []];
          endif;
        endforeach;
      ?>
      <div class="per-classes-bloc" id="bloc-classes">

        <div id="classes-lecture">
          <?php if (empty($lignes_classes)): ?>
            <p class="text-muted">Aucune classe définie.</p>
          <?php else: ?>
            <ul class="per-classes">
              <?php foreach ($lignes_classes as $l): ?>
                <?php $c = $l['c']; $prestige = ((int)$c['cla_clt_id'] === CLT_PRESTIGE); ?>
                <li class="per-classes__item">
                  <?php // L'italique remplace le badge « P » : il dit la même
                        // chose sans occuper de place. ?>
                  <a href="javascript:void(0)"
                     class="per-classes__nom<?= $prestige ? ' per-classes__nom--prestige' : '' ?>"
                     <?= $prestige ? 'title="Classe de prestige"' : '' ?>
                     onclick="actualiserPage('<?= BASE_URL ?>/include/ajax/detail-pp/classe.php', {id: <?= (int)$c['pc_cla_id'] ?>}, 'externe')">
                    <?= h($c['cla_nom']) ?>
                  </a>
                  <span class="per-classes__niveau"><?= (int)$c['pc_niveau'] ?></span>
                  <?php foreach ($l['sous'] as $sc): ?>
                    <span class="per-classes__sous">(<a href="javascript:void(0)"
                       onclick="actualiserPage('<?= BASE_URL ?>/include/ajax/detail-pp/classe.php', {id: <?= (int)$sc['pc_cla_id'] ?>}, 'externe')"><?= h($sc['cla_nom']) ?></a>)</span>
                  <?php endforeach ?>
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

        <?php // Posé en absolu au bout de la PREMIÈRE ligne : les noms de
              // classe lui réservent sa place (padding-right), ils passent donc
              // à la ligne avant de l'atteindre. ?>
        <button class="btn btn-link btn-sm per-fiche__editer" id="btn-editer-classes"
                onclick="classesEditor.basculerEdition()"
                title="Modifier les classes">
          <i class="fa fa-edit"></i>
        </button>

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
      </div>

    </div>
  </section>

  <?php // ---- BLOCS 3 à 5 : caractéristiques, CA, PV (refondus SP-PE10h) ---
        // Trois blocs de même nature — des chiffres qu'on relit sans arrêt en
        // séance — tenus sur une rangée sur un poste, et repliés en deux lignes
        // sur téléphone : les six caractéristiques d'abord, CA et PV ensuite.
        //
        // Les titres sont tombés : « Caractéristiques » au-dessus de FOR CON
        // DEX ne dit rien que la grille ne dise déjà, et « Combat » coiffait
        // deux tuiles qui se passent de chapeau. Le contour des blocs reste —
        // c'est lui qui les sépare. ?>
  <div class="per-fiche__rangee">

    <section class="per-fiche__bloc per-fiche__bloc--caracs">
      <div class="per-fiche__bloc-body">
        <?php
          $caracs_def = [
            ['abr' => 'FOR', 'lbl' => 'Force',        'val' => (int)$perso['pe_for'], 'save' => (int)$perso['pe_for_save']],
            ['abr' => 'CON', 'lbl' => 'Constitution', 'val' => (int)$perso['pe_con'], 'save' => (int)$perso['pe_con_save']],
            ['abr' => 'DEX', 'lbl' => 'Dextérité',    'val' => (int)$perso['pe_dex'], 'save' => (int)$perso['pe_dex_save']],
            ['abr' => 'INT', 'lbl' => 'Intelligence', 'val' => (int)$perso['pe_int'], 'save' => (int)$perso['pe_int_save']],
            ['abr' => 'SAG', 'lbl' => 'Sagesse',      'val' => (int)$perso['pe_sag'], 'save' => (int)$perso['pe_sag_save']],
            ['abr' => 'CHA', 'lbl' => 'Charisme',     'val' => (int)$perso['pe_cha'], 'save' => (int)$perso['pe_cha_save']],
          ];
          // DD2024 : les six sauvegardes se lisent à côté de leur modificateur,
          // comme dans le bloc de stats d'un monstre (SP-PE11). DD3.5 n'en a
          // que trois, et elles portent des noms de jets : elles ont leur
          // propre bloc, plus bas.
          $avec_saves = ($ruleset_rep === 'DD2024');
        ?>
        <div class="per-caracs<?= $avec_saves ? ' per-caracs--saves' : '' ?>">
          <?php if ($avec_saves): ?>
            <?php // Un en-tête PAR COLONNE de caractéristiques, en tête de
                  // grille (SP-PE13). Un en-tête unique ne coiffait que la
                  // première : les deux autres colonnes de MOD et de SAUV se
                  // lisaient sans libellé. Trois cellules ici ; sous 992px,
                  // la grille n'a que deux colonnes et la troisième est
                  // masquée, sans quoi elle tomberait sur la rangée suivante. ?>
            <?php for ($col = 0; $col < 3; $col++): ?>
              <div class="per-caracs__entete" aria-hidden="true">
                <span class="per-carac__abr"></span>
                <span class="per-carac__val"></span>
                <span class="per-carac__mod">MOD</span>
                <span class="per-carac__save">SAUV</span>
              </div>
            <?php endfor ?>
          <?php endif ?>
          <?php foreach ($caracs_def as $c): ?>
            <div class="per-carac">
              <div class="per-carac__abr" title="<?= h($c['lbl']) ?>"><?= $c['abr'] ?></div>
              <div class="per-carac__val"><?= $c['val'] ?></div>
              <div class="per-carac__mod"><?= formatMod(modCarac($c['val'])) ?></div>
              <?php if ($avec_saves): ?>
                <div class="per-carac__save" title="Sauvegarde de <?= h($c['lbl']) ?>"><?= formatMod($c['save']) ?></div>
              <?php endif ?>
            </div>
          <?php endforeach ?>
        </div>
      </div>
    </section>

    <?php // L'initiative remplace le bonus de maîtrise, parti rejoindre le
          // niveau global dans le bloc Identité (SP-PE11). Elle vaut pour les
          // deux rulesets. ?>
    <section class="per-fiche__bloc per-fiche__bloc--stat">
      <div class="per-fiche__bloc-body">
        <div class="per-stat" title="Initiative">
          <span class="per-stat__lbl">Init</span>
          <span class="per-stat__val"><?= formatMod((int)$perso['pe_init']) ?></span>
        </div>
      </div>
    </section>

    <section class="per-fiche__bloc per-fiche__bloc--stat">
      <div class="per-fiche__bloc-body">
        <div class="per-stat" title="Classe d'armure">
          <span class="per-stat__lbl">CA</span>
          <span class="per-stat__val"><?= (int)$perso['pe_ca'] ?></span>
        </div>
      </div>
    </section>

    <section class="per-fiche__bloc per-fiche__bloc--stat">
      <div class="per-fiche__bloc-body">
        <div class="per-stat" title="Points de vie totaux">
          <span class="per-stat__lbl">PV</span>
          <span class="per-stat__val"><?= (int)$perso['pe_pv'] ?></span>
        </div>
      </div>
    </section>

  </div>

  <?php // ---- Jets de sauvegarde (DD3.5) --------------------------------
        // Le ruleset n'en connaît que trois, et sous leurs propres noms :
        // Réflexes (DEX), Vigueur (CON), Volonté (SAG). Elles ne peuvent donc
        // pas se ranger à côté des six modificateurs comme en DD2024 — d'où un
        // bloc à elles, juste sous la rangée de stats (SP-PE11). ?>
  <?php if ($ruleset_rep === 'DD3.5'): ?>
    <?php
      $saves_35 = [
        ['lbl' => 'Réflexes', 'carac' => 'DEX', 'val' => (int)$perso['pe_dex_save']],
        ['lbl' => 'Vigueur',  'carac' => 'CON', 'val' => (int)$perso['pe_con_save']],
        ['lbl' => 'Volonté',  'carac' => 'SAG', 'val' => (int)$perso['pe_sag_save']],
      ];
    ?>
    <section class="per-fiche__bloc per-fiche__bloc--saves">
      <div class="per-fiche__bloc-body">
        <h2 class="per-saves__titre">Jets de sauvegarde</h2>
        <div class="per-saves">
          <?php foreach ($saves_35 as $sv): ?>
            <div class="per-save" title="Sauvegarde de <?= h($sv['carac']) ?>">
              <span class="per-save__lbl"><?= h($sv['lbl']) ?></span>
              <span class="per-save__val"><?= formatMod($sv['val']) ?></span>
            </div>
          <?php endforeach ?>
        </div>
      </div>
    </section>
  <?php endif ?>

  <?php // ---- Compétences et Dons côte à côte (SP-PE10m) ------------------
        // Deux listes de même nature, lues de la même façon, qui laissaient
        // chacune la moitié droite de l'écran vide sur un poste. Elles se
        // partagent la rangée au-dessus de 992px et s'empilent en dessous.
        // Le bloc NLS, lui, porte un tableau par classe de prestige : il
        // garde sa pleine largeur, sous la rangée. ?>
  <div class="per-fiche__rangee per-fiche__rangee--listes">

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
                title="Modifier les compétences"
                onclick="competencesEditor.basculerEdition()">
          <i class="fa fa-edit"></i>
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
              <span class="per-comp__val per-comp__val--carac">Carac</span>
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
                <span class="per-comp__val per-comp__val--carac">
                  <?php if (!empty($c['car_diminutif'])): ?>
                    <?= h(strtoupper($c['car_diminutif'])) ?>
                    <span class="text-muted"><?= formatMod($mod) ?></span>
                  <?php else: ?>
                    <span class="text-muted" title="Aucune caractéristique associée">—</span>
                  <?php endif ?>
                </span>
                <?php // Abrégé (SP-PE10j) : « Maîtrise » et « Expertise » en toutes
                      // lettres imposaient à la colonne une largeur que la ligne
                      // n'avait pas. Le title garde le mot. ?>
                <span class="per-comp__val">
                  <?php if ($ruleset_rep === 'DD2024'): ?>
                    <span title="<?= $maitrise >= 2 ? 'Expertise' : 'Maîtrise' ?>"><?= $maitrise >= 2 ? 'E' : 'M.' ?></span>
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
  </div>

  <?php // ---- Capacités spéciales (SP-PE11) -----------------------------
        // Deux blocs sur une rangée, comme Compétences et Dons : ce que la
        // race apporte d'un côté, ce que les classes apportent de l'autre.
        // Rien ne s'y saisit — tout vient des tables de liaison. Un bloc vide
        // n'est pas rendu : mieux vaut une rangée à un bloc qu'un cadre vide. ?>
  <?php if ($capacites_race || $capacites_classes): ?>
    <div class="per-fiche__rangee per-fiche__rangee--listes">

      <?php if ($capacites_race): ?>
        <section class="per-fiche__bloc" id="bloc-capacites-race">
          <header class="per-fiche__bloc-header per-fiche__bloc-header--flex">
            <h2 class="per-fiche__bloc-titre">
              <i class="fa fa-dna"></i> Capacités de race
              <span class="per-fiche__compte"><?= count($capacites_race) ?></span>
            </h2>
          </header>
          <div class="per-fiche__bloc-body">
            <ul class="per-caps">
              <?php foreach ($capacites_race as $cap): ?>
                <li class="per-caps__item">
                  <a href="javascript:void(0)" class="per-caps__nom"
                     onclick="actualiserPage('<?= BASE_URL ?>/include/ajax/detail-pp/capacite.php', {id: <?= (int)$cap['cap_id'] ?>}, 'externe')">
                    <?= h($cap['cap_nom']) ?>
                  </a>
                  <?php if (!empty($cap['cap_type'])): ?>
                    <span class="per-caps__meta"><?= h($cap['cap_type']) ?></span>
                  <?php endif ?>
                </li>
              <?php endforeach ?>
            </ul>
          </div>
        </section>
      <?php endif ?>

      <?php if ($capacites_classes): ?>
        <section class="per-fiche__bloc" id="bloc-capacites-classes">
          <header class="per-fiche__bloc-header per-fiche__bloc-header--flex">
            <h2 class="per-fiche__bloc-titre">
              <i class="fa fa-shield-halved"></i> Capacités de classe
              <span class="per-fiche__compte"><?= array_sum(array_map(fn($g) => count($g['capacites']), $capacites_classes)) ?></span>
            </h2>
          </header>
          <div class="per-fiche__bloc-body">
            <?php foreach ($capacites_classes as $groupe): ?>
              <?php // L'intertitre ne sert que s'il y a plusieurs classes. ?>
              <?php if (count($capacites_classes) > 1): ?>
                <h3 class="per-caps__groupe"><?= h($groupe['nom']) ?></h3>
              <?php endif ?>
              <ul class="per-caps">
                <?php foreach ($groupe['capacites'] as $cap): ?>
                  <li class="per-caps__item">
                    <a href="javascript:void(0)" class="per-caps__nom"
                       onclick="actualiserPage('<?= BASE_URL ?>/include/ajax/detail-pp/capacite.php', {id: <?= (int)$cap['cap_id'] ?>}, 'externe')">
                      <?= h($cap['cap_nom']) ?>
                    </a>
                    <?php if (!empty($cap['cc_precision'])): ?>
                      <span class="per-caps__precision"><?= h($cap['cc_precision']) ?></span>
                    <?php endif ?>
                    <span class="per-caps__meta" title="Niveau d'obtention">niv. <?= (int)$cap['cc_niveau'] ?></span>
                  </li>
                <?php endforeach ?>
              </ul>
            <?php endforeach ?>
          </div>
        </section>
      <?php endif ?>

    </div>
  <?php endif ?>


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
              title="Modifier les affectations de NLS"
              onclick="nlsEditor.basculerEdition()">
        <i class="fa fa-edit"></i>
      </button>
      <?php // Replié par défaut (SP-PE10n) : l'affectation des niveaux de
            // prestige se règle une fois pour toutes, à la montée de niveau.
            // Elle n'a pas à occuper la fiche entre deux. ?>
      <button type="button" class="btn btn-link btn-sm per-fiche__replier"
              id="btn-replier-nls"
              aria-controls="bloc-nls-body" aria-expanded="false"
              onclick="perReplierBloc('bloc-nls-body', this)"
              title="Afficher ou masquer le bloc">
        <i class="fa fa-chevron-down"></i>
      </button>
    </header>

    <div class="noDisplay" id="bloc-nls-body">

    <!-- Mode lecture -->
    <div class="per-fiche__bloc-body" id="nls-lecture">
      <?php // Masqué sous 992px (SP-PE10h) : une explication qu'on ne lit
            // qu'une fois ne vaut pas quatre lignes sur un téléphone. ?>
      <p class="text-muted text-sm per-nls__aide">
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
    </div><!-- #bloc-nls-body -->

  </section>
  <?php endif ?>

</div><!-- .per-fiche -->

<?php require_once '../include/footer.php'; ?>
