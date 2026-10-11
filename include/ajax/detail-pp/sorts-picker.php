<?php
// include/ajax/detail-pp/sorts-picker.php
// Sélecteur de sorts du personnage (SP-PE7b) — s'affiche dans #detail-pp.
//
// Deux volets : à gauche la liste filtrable du réservoir, à droite la fiche du
// sort cliqué. Écriture immédiate au clic (Q8, D-MAG13), le panneau reste ouvert.
//
// TOUJOURS PORTÉ PAR CLASSE : un multiclassé a un sélecteur par classe lanceuse,
// et une écriture ne touche jamais la liste d'une autre classe.
//
// LE RÉSERVOIR DÉPEND DU PROFIL ET DU MODE :
//   mode = repertoire  → la liste de sorts de la classe (dd_sortclasse), bornée
//                        par les sources actives. Alimente dd_personnages_sorts.
//   mode = prepare     → ce que le personnage peut préparer :
//                          profil Grimoire  → ses sorts COMPRIS (pes_compris=1),
//                                             car préparable ⟺ compris (D-MAG6) ;
//                          autres profils   → la liste de classe entière.
//                        Alimente dd_personnages_sorts_prepares.
//
// LA LISTE EST BORNÉE AUX NIVEAUX ACCESSIBLES : proposer à un magicien de
// niveau 5 des sorts de niveau 9 n'aide pas, ça noie le choix utile. Le
// critère est l'accessibilité calculée par getMagieContexte(), pas le niveau
// de classe — un « 0 » du SRD reste un niveau accessible.
//
// Paramètres GET : pe_id (int), pc_id (int), mode (repertoire|prepare)
//
// Référence : ARCHITECTURE_0_REFERENCE.md §7.5b (motif) et METIER_7_SORTS.md §9
require_once __DIR__ . '/../../db.php';
require_once __DIR__ . '/../../auth.php';
require_once __DIR__ . '/../../helpers.php';
require_once __DIR__ . '/../../personnage_helpers.php';

requireAuth();

$pe_id = intParam($_GET['pe_id'] ?? 0);
$pc_id = intParam($_GET['pc_id'] ?? 0);
$mode  = strParam($_GET['mode'] ?? 'repertoire');
if (!in_array($mode, ['repertoire', 'prepare'], true)) $mode = 'repertoire';

$perso = getPersonnageContext($db, $pe_id);
if (!$perso):
  http_response_code(404);
  echo '<p class="erreur">Personnage introuvable.</p>';
  exit;
endif;

$classes = getPersonnageClasses($db, $pe_id);
$classe  = null;
foreach ($classes as $c) if ((int)$c['pc_id'] === $pc_id) $classe = $c;
if (!$classe):
  http_response_code(400);
  echo '<p class="erreur">Cette classe n\'est pas celle du personnage.</p>';
  exit;
endif;

// Contexte de calcul : emplacements, plafonds, accessibilité par niveau.
$ctx = null;
foreach (getMagieContexte($db, $perso, $classes) as $e) if ((int)$e['pc_id'] === $pc_id) $ctx = $e;
if (!$ctx):
  http_response_code(400);
  echo '<p class="erreur">Cette classe ne lance pas de sorts.</p>';
  exit;
endif;

$ruleset_id = (int)$perso['pe_ruleset_var_id'];
$est35      = ($ruleset_id === 1);
$profil     = (int)$ctx['profil'];
$cla_id     = (int)$classe['pc_cla_id'];

// Niveaux de sort réellement accessibles au personnage.
$accessibles = [];
foreach ($ctx['empl_detail'] as $n => $d) if (!empty($d['accessible'])) $accessibles[] = (int)$n;
if (!$accessibles) $accessibles = [0];

// Ruleset du PERSONNAGE (figé à la création), jamais celui de la session.
$res_ids = getActiveResIds($db, $ruleset_id);

// ------------------------------------------------------------
// Réservoir
// ------------------------------------------------------------
// En DD3.5 le niveau d'un sort est RELATIF À LA CLASSE (dd_sortclasse.sc_niveau) ;
// en DD2024 il est absolu (so_niveau). D'où deux expressions plutôt qu'un
// COALESCE qui masquerait la différence.
$colNiveau = $est35 ? 'sc.sc_niveau' : 'so.so_niveau';
$phNiv     = implode(',', array_fill(0, count($accessibles), '?'));

$sorts = [];
if ($mode === 'prepare' && $profil === PROFINC_GRIMOIRE):
  // Réservoir = le grimoire. Un sort connu mais non recopié n'est pas préparable.
  $stmt = $db->prepare("
    SELECT so.so_id, so.so_nom, $colNiveau AS niveau
      FROM dd_personnages_sorts pes
      JOIN dd_sorts so ON so.so_id = pes.pes_so_id
 LEFT JOIN dd_sortclasse sc ON sc.sc_so_id = so.so_id AND sc.sc_cla_id = ?
     WHERE pes.pes_pc_id = ? AND pes.pes_compris = 1 AND $colNiveau IN ($phNiv)
  ORDER BY niveau, so.so_nom");
  $stmt->execute(array_merge([$cla_id, $pc_id], $accessibles));
  $sorts = $stmt->fetchAll();
elseif (!empty($res_ids)):
  $ph = resIdsPlaceholders($res_ids);
  $stmt = $db->prepare("
    SELECT so.so_id, so.so_nom, $colNiveau AS niveau
      FROM dd_sortclasse sc
      JOIN dd_sorts so ON so.so_id = sc.sc_so_id
     WHERE sc.sc_cla_id = ? AND so.so_ruleset_var_id = ?
       AND so.so_res_id IN ($ph) AND $colNiveau IN ($phNiv)
  ORDER BY niveau, so.so_nom");
  $stmt->execute(array_merge([$cla_id, $ruleset_id], $res_ids, $accessibles));
  $sorts = $stmt->fetchAll();
endif;

// ------------------------------------------------------------
// Ce que le personnage possède déjà
// ------------------------------------------------------------
// so_id => pes_compris (mode répertoire) | NOMBRE D'EXEMPLAIRES préparés (mode
// préparation). En DD3.5 un sort se prépare plusieurs fois, chaque exemplaire
// occupant son emplacement (SP-PE10e) ; en DD2024 la valeur vaut toujours 1.
$possedes = [];
// niveau => nombre d'EXEMPLAIRES déjà retenus, pour les compteurs DD3.5
$parNiveau = [];

if ($mode === 'repertoire'):
  $stmt = $db->prepare('SELECT pes_so_id, pes_compris FROM dd_personnages_sorts WHERE pes_pc_id = ?');
  $stmt->execute([$pc_id]);
  foreach ($stmt->fetchAll() as $r) $possedes[(int)$r['pes_so_id']] = (int)$r['pes_compris'];
else:
  // GREATEST(pesp_nb, 1) : la colonne vaut 0 par défaut alors qu'un exemplaire
  // préparé compte pour 1 — même lecture que le total de `enregistrement.php`.
  $stmt = $db->prepare("
    SELECT pesp.pesp_so_id, GREATEST(pesp.pesp_nb, 1) AS nb, $colNiveau AS niveau
      FROM dd_personnages_sorts_prepares pesp
      JOIN dd_sorts so ON so.so_id = pesp.pesp_so_id
 LEFT JOIN dd_sortclasse sc ON sc.sc_so_id = so.so_id AND sc.sc_cla_id = ?
     WHERE pesp.pesp_pe_id = ? AND pesp.pesp_cla_id = ? AND pesp.pesp_origine = 0");
  $stmt->execute([$cla_id, $pe_id, $cla_id]);
  foreach ($stmt->fetchAll() as $r):
    $nb = max(1, (int)$r['nb']);
    // Plusieurs lignes pour un même sort (versions métamagiques) : on cumule.
    $possedes[(int)$r['pesp_so_id']] = ($possedes[(int)$r['pesp_so_id']] ?? 0) + $nb;
    $n = ($r['niveau'] === null) ? 0 : (int)$r['niveau'];
    $parNiveau[$n] = ($parNiveau[$n] ?? 0) + $nb;
  endforeach;
endif;

// ------------------------------------------------------------
// Compteurs
// ------------------------------------------------------------
// DD2024 : un plafond global de sorts préparés (cn_sortPrepare).
// DD3.5  : pas de plafond global — c'est le nombre d'EMPLACEMENTS de chaque
//          niveau qui borne la préparation. D'où un compteur par niveau.
// DD2024 : plafond de sorts DISTINCTS — count($possedes) reste la bonne mesure,
// la quantité par sort étant une règle DD3.5.
$plafondGlobal = (!$est35 && $mode === 'prepare') ? $ctx['sorts_prepares'] : null;
// Les sorts mineurs ne pèsent pas sur ce plafond : en DD2024 ils sont connus,
// pas préparés, et cn_sort_n0 les compte à part (SP-PE10s).
$nbPlafonnes = count($possedes) - (int)($parNiveau[0] ?? 0);
$plafondsNiveau = [];
if ($est35 && $mode === 'prepare'):
  foreach ($accessibles as $n) $plafondsNiveau[$n] = (int)($ctx['emplacements'][$n] ?? 0);
endif;

$niveauxPresents = array_values(array_unique(array_map(fn($s) => (int)$s['niveau'], $sorts)));
sort($niveauxPresents);

$titre = $mode === 'prepare'
  ? 'Préparer des sorts — ' . $classe['cla_nom']
  : (($profil === PROFINC_GRIMOIRE) ? 'Grimoire et sorts connus — ' . $classe['cla_nom']
                                    : 'Répertoire — ' . $classe['cla_nom']);
?>

<div class="dons-picker sorts-picker"
     data-pe="<?= (int)$pe_id ?>" data-pc="<?= (int)$pc_id ?>"
     data-cla="<?= $cla_id ?>" data-mode="<?= h($mode) ?>"
     data-grimoire="<?= ($profil === PROFINC_GRIMOIRE) ? 1 : 0 ?>"
     data-plafond="<?= $plafondGlobal !== null ? (int)$plafondGlobal : '' ?>"
     data-plafonds-niveau="<?= h(json_encode($plafondsNiveau)) ?>">

  <h2 class="sort-detail__nom"><?= h($titre) ?></h2>

  <?php // ---- Compteurs, mis à jour en direct par sortsPicker ?>
  <?php if ($mode === 'prepare'): ?>
  <div class="sorts-picker__barre-prep">
    <?php if ($plafondGlobal !== null): ?>
      <?php $resteGlobal = max(0, (int)$plafondGlobal - $nbPlafonnes); ?>
      <p class="sorts-picker__compteur" id="sorts-picker-compteur">
        <strong><span data-restant-global><?= $resteGlobal ?></span></strong>
        sort<?= $resteGlobal > 1 ? 's' : '' ?>
        encore préparable<?= $resteGlobal > 1 ? 's' : '' ?>
        sur <?= (int)$plafondGlobal ?>
      </p>
    <?php elseif ($plafondsNiveau): ?>
      <div class="sorts-picker__compteurs" id="sorts-picker-compteur">
        <?php foreach ($plafondsNiveau as $n => $max): ?>
          <span class="sorts-picker__jeton" data-niveau="<?= $n ?>"
                title="Emplacements de niveau <?= $n ?> encore libres">
            N<?= $n ?>
            <strong data-restant="<?= $n ?>"><?= max(0, $max - (int)($parNiveau[$n] ?? 0)) ?></strong>
            / <?= $max ?>
          </span>
        <?php endforeach ?>
      </div>
    <?php endif ?>
    <?php // Vide la liste préparée de la classe ; recharge la page (sortsPicker.reinitialiser). ?>
    <button type="button" class="btn btn-link btn-sm"
            onclick="sortsPicker.reinitialiser(<?= $cla_id ?>, <?= h(json_encode($classe['cla_nom'])) ?>)"
            title="Vider la liste préparée ; les sorts toujours préparés sont conservés">
      <i class="fa fa-rotate-left"></i> Réinitialiser
    </button>
  </div>
  <?php endif ?>

  <?php if ($mode === 'prepare' && $profil === PROFINC_GRIMOIRE): ?>
    <p class="text-muted text-sm">
      Seuls les sorts <strong>recopiés dans le grimoire</strong> sont préparables.
    </p>
  <?php endif ?>

  <div class="dons-picker__filtres">
    <input type="search" id="sorts-picker-q" class="comp-filtre-input"
           placeholder="Rechercher un sort…" oninput="sortsPicker.filtrer()">
    <select id="sorts-picker-niv" class="comp-filtre-select" onchange="sortsPicker.filtrer()">
      <option value="">— Niveau —</option>
      <?php foreach ($niveauxPresents as $n): ?>
        <option value="<?= $n ?>">Niveau <?= $n ?></option>
      <?php endforeach ?>
    </select>
    <label class="comp-filtre-checkbox-label"
           title="<?= $mode === 'prepare'
                      ? 'Ne montrer que les sorts déjà préparés'
                      : 'Masquer les sorts que le personnage n\'a pas' ?>">
      <input type="checkbox" id="sorts-picker-miens" onchange="sortsPicker.filtrer()">
      <?= $mode === 'prepare' ? 'Les préparés seulement' : 'Les siens seulement' ?>
    </label>
    <span class="dons-picker__decompte" id="sorts-picker-decompte"></span>
  </div>

  <?php
    // En DD3.5, préparer n'est pas un oui/non : un magicien mémorise plusieurs
    // fois le même sort, chaque exemplaire occupant un emplacement de son
    // niveau (SP-PE10e). La ligne porte alors un compteur — [−] N [+] — au
    // lieu du bouton bascule. Partout ailleurs, la bascule suffit.
    $compteurParSort = ($est35 && $mode === 'prepare');
  ?>
  <div class="dons-picker__corps">

    <div class="dons-picker__liste">
      <?php if (!$sorts): ?>
        <p class="text-muted text-sm">
          <?= $mode === 'prepare' && $profil === PROFINC_GRIMOIRE
              ? 'Le grimoire est vide : recopiez d\'abord des sorts.'
              : 'Aucun sort disponible pour cette classe dans les sources actives.' ?>
        </p>
      <?php endif ?>
      <?php // Les sorts arrivent triés par niveau puis par nom : un en-tête à
            // chaque rupture suffit, et remplace la pastille que chaque ligne
            // portait (SP-PE10f). Une ligne de moins à lire, et la place gagnée
            // revient au nom du sort — précieuse sur un téléphone. ?>
      <ul class="dons-picker__items">
        <?php $niveauCourant = null; ?>
        <?php foreach ($sorts as $s): ?>
          <?php if ((int)$s['niveau'] !== $niveauCourant): ?>
            <?php $niveauCourant = (int)$s['niveau']; ?>
            <li class="sorts-picker__entete" data-entete="<?= $niveauCourant ?>">
              Niveau <?= $niveauCourant ?>
            </li>
          <?php endif ?>
          <?php
            $a  = isset($possedes[(int)$s['so_id']]);
            $nb = $compteurParSort ? (int)($possedes[(int)$s['so_id']] ?? 0) : ($a ? 1 : 0);
          ?>
          <li class="dons-picker__item sorts-picker__item<?= $a ? ' est-choisi' : '' ?>"
              data-id="<?= (int)$s['so_id'] ?>"
              data-nom="<?= h(mb_strtolower($s['so_nom'], 'UTF-8')) ?>"
              data-niv="<?= (int)$s['niveau'] ?>"
              data-nb="<?= $nb ?>">
            <?php if ($compteurParSort): ?>
              <?php // Les trois éléments sont TOUJOURS là : la ligne ne bouge pas
                    // quand la quantité change, et le pouce garde sa cible. ?>
              <span class="sorts-picker__stepper">
                <button type="button" class="btn btn-sm dons-picker__toggle sorts-picker__moins"
                        onclick="sortsPicker.retirerUn(<?= (int)$s['so_id'] ?>)"
                        title="Retirer un exemplaire préparé"
                        <?= $nb > 0 ? '' : 'disabled' ?>>
                  <i class="fa fa-minus"></i>
                </button>
                <span class="sorts-picker__nb" data-nb-lbl><?= $nb ?></span>
                <button type="button" class="btn btn-sm dons-picker__toggle sorts-picker__plus"
                        onclick="sortsPicker.ajouterUn(<?= (int)$s['so_id'] ?>)"
                        title="Préparer un exemplaire de plus">
                  <i class="fa fa-plus"></i>
                </button>
              </span>
            <?php else: ?>
              <button type="button" class="btn btn-sm dons-picker__toggle"
                      onclick="sortsPicker.basculer(<?= (int)$s['so_id'] ?>)"
                      title="<?= $a ? 'Retirer' : 'Ajouter' ?>">
                <i class="fa fa-<?= $a ? 'minus' : 'plus' ?>"></i>
              </button>
            <?php endif ?>
            <span class="dons-picker__nom" onclick="sortsPicker.voir(<?= (int)$s['so_id'] ?>)">
              <?= h($s['so_nom']) ?>
            </span>
            <?php // Le bouton n'a de sens que sur un sort RETENU : on ne recopie
                  // pas dans son grimoire un sort qu'on ne connaît pas. Il
                  // apparaît et disparaît donc au fil des clics — sortsPicker
                  // le pose et le retire lui-même (SP-PE10d). ?>
            <?php if ($mode === 'repertoire' && $profil === PROFINC_GRIMOIRE && $a): ?>
              <button type="button" class="btn btn-sm dons-picker__toggle dons-picker__grimoire"
                      onclick="sortsPicker.grimoire(<?= (int)$s['so_id'] ?>)"
                      title="<?= $possedes[(int)$s['so_id']] ? 'Retirer du grimoire' : 'Recopier dans le grimoire' ?>">
                <i class="fa fa-book<?= $possedes[(int)$s['so_id']] ? '' : '-open' ?>"></i>
              </button>
            <?php endif ?>
          </li>
        <?php endforeach ?>
      </ul>
    </div>

    <div class="dons-picker__detail" id="sorts-picker-detail">
      <p class="text-muted text-sm">Cliquez sur un sort pour afficher sa description.</p>
    </div>

  </div>
</div>
