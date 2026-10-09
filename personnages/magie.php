<?php
// personnages/magie.php — Vue dédiée Magie du personnage (SP-PE7b).
//
// Une section par CLASSE LANCEUSE : c'est le regroupement de premier rang, pas
// le niveau de sort (objectif produit, METIER_7_SORTS.md §10.1). Un personnage
// monoclasse ne paie donc pas le prix visuel du multiclassage.
//
// Tout le calcul vit dans getMagieContexte() (SP-PE7a, personnage_helpers.php) :
// cette page ne fait que rendre. Les quatre pièges connus y sont déjà traités —
// Occultiste en cn_pouvoir1..3, sorts toujours préparés cumulatifs, helpers
// DD3.5 branchés sur le ruleset, cadence de renouvellement.
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
$est35       = ($ruleset_id === 1);
$classes     = getPersonnageClasses($db, (int)$perso['pe_id']);
$magie       = getMagieContexte($db, $perso, $classes);

// Sorts du personnage, indexés par classe (dd_personnages_classes.pc_id)
$sortsParClasse = [];
// Le NIVEAU D'UN SORT dépend du ruleset : absolu en DD2024 (so_niveau), mais
// RELATIF À LA CLASSE en DD3.5, où il vit dans dd_sortclasse.sc_niveau. Sans
// cette jointure, la pastille de niveau resterait vide sur tout le DD3.5.
$stmt = $db->prepare('
  SELECT pes.pes_pc_id, pes.pes_compris, so.so_id, so.so_nom,
         ' . ($est35 ? 'sc.sc_niveau' : 'so.so_niveau') . ' AS niveau_sort
    FROM dd_personnages_sorts pes
    JOIN dd_personnages_classes pc ON pc.pc_id = pes.pes_pc_id
    JOIN dd_sorts so ON so.so_id = pes.pes_so_id
    LEFT JOIN dd_sortclasse sc ON sc.sc_so_id = so.so_id AND sc.sc_cla_id = pc.pc_cla_id
   WHERE pc.pc_pe_id = ?
   ORDER BY niveau_sort, so.so_nom
');
$stmt->execute([(int)$perso['pe_id']]);
foreach ($stmt->fetchAll() as $r) $sortsParClasse[(int)$r['pes_pc_id']][] = $r;

// Sorts préparés, indexés par classe (dd_personnages_sorts_prepares.pesp_cla_id)
$preparesParClasse = [];
$stmt = $db->prepare('
  SELECT pesp.pesp_cla_id, pesp.pesp_nb, pesp.pesp_niveau, pesp.pesp_origine,
         so.so_id, so.so_nom,
         ' . ($est35 ? 'sc.sc_niveau' : 'so.so_niveau') . ' AS niveau_sort
    FROM dd_personnages_sorts_prepares pesp
    JOIN dd_sorts so ON so.so_id = pesp.pesp_so_id
    LEFT JOIN dd_sortclasse sc ON sc.sc_so_id = so.so_id AND sc.sc_cla_id = pesp.pesp_cla_id
   WHERE pesp.pesp_pe_id = ?
   ORDER BY niveau_sort, so.so_nom
');
$stmt->execute([(int)$perso['pe_id']]);
foreach ($stmt->fetchAll() as $r) $preparesParClasse[(int)$r['pesp_cla_id']][] = $r;

$page_title = 'Magie — ' . $perso['pe_nom'];
$js_module  = 'personnage';
$css_module = 'personnages';

require_once '../include/header.php';

$urlSort = BASE_URL . '/include/ajax/detail-pp/sort.php';
?>

<script>
  // Globals du module personnage (js/personnage.js) — mêmes noms que la fiche.
  var perPeId           = <?= (int)$perso['pe_id'] ?>;
  var perUrlEnreg       = <?= json_encode(BASE_URL . '/personnages/enregistrement.php?ajax=1') ?>;
  var perUrlSortsPicker = <?= json_encode(BASE_URL . '/include/ajax/detail-pp/sorts-picker.php') ?>;
  var perUrlSortDetail  = <?= json_encode(BASE_URL . '/include/ajax/detail-pp/sort.php') ?>;
</script>

<div class="per-fiche">

  <div class="per-fiche__header">
    <h1 class="per-fiche__nom"><?= h($perso['pe_nom']) ?></h1>
  </div>

  <?php $nav_courante = 'magie'; $nav_lanceur = true; ?>
  <?php require __DIR__ . '/../include/personnage-nav.php'; ?>

  <?php if (!$magie): ?>
    <div class="alert alert-info">
      <?= h($perso['pe_nom']) ?> n'a aucune classe lanceuse de sorts.
    </div>
  <?php endif ?>

  <?php foreach ($magie as $m): ?>
    <?php
      $bodyId  = 'bloc-magie-' . $m['pc_id'];
      $connus  = $sortsParClasse[$m['pc_id']] ?? [];
      $grimoire = array_values(array_filter($connus, fn($s) => (int)$s['pes_compris'] === 1));
      $aRecopier = array_values(array_filter($connus, fn($s) => (int)$s['pes_compris'] !== 1));
      $prepares = $preparesParClasse[$m['cla_id']] ?? [];
      // Le compteur ne totalise QUE les sorts préparés normalement : les sorts
      // toujours préparés — accordés par la classe ou choisis — ne pèsent pas
      // sur le plafond (METIER_7_SORTS.md §11 Q7).
      $nbPrepares = 0;
      foreach ($prepares as $p) if ((int)$p['pesp_origine'] === 0) $nbPrepares += max(1, (int)$p['pesp_nb']);
    ?>
    <section class="per-fiche__bloc">
      <header class="per-fiche__bloc-header per-fiche__bloc-header--flex">
        <h2 class="per-fiche__bloc-titre">
          <i class="fa fa-hat-wizard"></i>
          <?= h($m['cla_nom']) ?>
          <span class="per-fiche__niveau-global">niv. <?= (int)$m['niveau'] ?></span>
          <?php if ($m['profil_lib']): ?>
            <span class="text-muted text-sm">— <?= h($m['profil_lib']) ?></span>
          <?php endif ?>
        </h2>
        <button type="button" class="btn btn-link btn-sm per-fiche__replier"
                aria-controls="<?= $bodyId ?>" aria-expanded="true"
                onclick="perReplierBloc('<?= $bodyId ?>', this)"
                title="Afficher ou masquer le bloc">
          <i class="fa fa-chevron-up"></i>
        </button>
      </header>

      <div class="per-fiche__bloc-body" id="<?= $bodyId ?>">

        <?php foreach ($m['avertissements'] as $a): ?>
          <p class="alert alert-warning text-sm"><i class="fa fa-triangle-exclamation"></i> <?= h($a) ?></p>
        <?php endforeach ?>

        <?php // ---- Quatre cases de synthèse ----------------------------
              // « Attaque des sorts » était accolée au DD de sauvegarde : deux
              // chiffres différents sur une même ligne, qu'on confond au premier
              // coup d'œil. Chacun a désormais sa case. ?>
        <div class="per-magie__cases">
          <div class="per-magie__case">
            <span class="per-magie__case-lbl">Caractéristique</span>
            <span class="per-magie__case-val">
              <?php if ($m['car_valeur']): ?>
                <?= (int)$m['car_valeur'] ?> <small><?= formatMod((int)$m['car_mod']) ?></small>
              <?php else: ?>—<?php endif ?>
            </span>
            <span class="per-magie__case-note"><?= h($m['car_nom'] ?: '') ?></span>
          </div>

          <div class="per-magie__case">
            <span class="per-magie__case-lbl">NLS effectif</span>
            <span class="per-magie__case-val"><?= (int)$m['nls'] ?></span>
            <span class="per-magie__case-note">
              <?php if ((int)$m['nls_detail']['prestige'] !== 0): ?>
                <?= (int)$m['nls_detail']['base'] ?> de classe
                <?= $m['nls_detail']['origine'] === 'prestige' ? '+ prestige' : '· multiclasse' ?>
              <?php else: ?>niveau de lanceur<?php endif ?>
            </span>
          </div>

          <div class="per-magie__case">
            <span class="per-magie__case-lbl">DD de sauvegarde</span>
            <span class="per-magie__case-val">
              <?php if ($m['dd_par_niveau']): ?>
                <?= (int)$m['dd_base'] ?><small>+niv<?= formatMod((int)$m['car_mod']) ?></small>
              <?php else: ?><?= (int)$m['dd_base'] ?><?php endif ?>
            </span>
            <span class="per-magie__case-note">
              <?= $m['dd_par_niveau'] ? 'varie selon le niveau du sort' : 'toutes classes de sorts' ?>
            </span>
          </div>

          <div class="per-magie__case">
            <span class="per-magie__case-lbl">Attaque des sorts</span>
            <span class="per-magie__case-val">
              <?= $m['attaque'] !== null ? formatMod((int)$m['attaque']) : '—' ?>
            </span>
            <span class="per-magie__case-note">
              <?= $m['attaque'] !== null ? 'jets d\'attaque de sort' : 'sans objet en DD3.5' ?>
            </span>
          </div>
        </div>

        <?php // ---- Actions : un sélecteur par liste, toujours porté par la classe ?>
        <div class="per-magie__actions">
          <?php if ((int)$m['profil'] === PROFINC_GRIMOIRE || (int)$m['profil'] === PROFINC_REPERTOIRE): ?>
            <button type="button" class="btn btn-secondary btn-sm"
                    onclick="sortsPicker.ouvrir(<?= (int)$m['pc_id'] ?>, 'repertoire')">
              <i class="fa fa-book"></i>
              <?= (int)$m['profil'] === PROFINC_GRIMOIRE ? 'Grimoire et sorts connus' : 'Répertoire' ?>
            </button>
          <?php endif ?>
          <?php if ((int)$m['profil'] !== PROFINC_REPERTOIRE): ?>
            <button type="button" class="btn btn-secondary btn-sm"
                    onclick="sortsPicker.ouvrir(<?= (int)$m['pc_id'] ?>, 'prepare')">
              <i class="fa fa-wand-sparkles"></i> Préparer des sorts
            </button>
            <?php if ($nbPrepares > 0): ?>
              <button type="button" class="btn btn-link btn-sm"
                      onclick="sortsPicker.reinitialiser(<?= (int)$m['cla_id'] ?>, <?= h(json_encode($m['cla_nom'])) ?>)"
                      title="Vider la liste préparée ; les sorts toujours préparés sont conservés">
                <i class="fa fa-rotate-left"></i> Réinitialiser
              </button>
            <?php endif ?>
          <?php endif ?>
        </div>

        <?php // ---- Synthèse : emplacements à gauche, ressources à droite ---
              // Le tableau reprend l'habillage de « Nombre de sorts par jour »
              // du descriptif de classe (.table-dd / .col-sort) : c'est la même
              // information, elle doit se lire pareil. Les 9 niveaux sont
              // TOUJOURS affichés, même inaccessibles — une table dont le nombre
              // de colonnes varie d'une classe à l'autre se compare mal. Un
              // niveau hors de portée porte « — ».
              //
              // SP-PE10b : le panneau « Ressources de sorts » rassemble à droite
              // ce qui se dispersait en fin de bloc — plafonds, taille des listes,
              // cadence de renouvellement, domaines. ?>
        <?php
          // Une ligne par ressource RÉELLEMENT portée par le profil : un clerc
          // n'a ni grimoire ni répertoire, et « Sorts connus : 0 » lui ferait
          // croire à une donnée manquante.
          $ressources = [];
          if ($m['sorts_mineurs'] !== null):
            $ressources[] = ['Sorts mineurs connus', (string)(int)$m['sorts_mineurs']];
          endif;
          if ((int)$m['profil'] !== PROFINC_REPERTOIRE):
            // Le plafond de préparation n'existe qu'en DD2024 (cn_sortPrepare) :
            // en DD3.5, c'est le nombre d'emplacements de chaque niveau qui borne
            // la préparation, et le tableau ci-contre le dit déjà.
            $ressources[] = ['Sorts préparés', $m['sorts_prepares'] !== null
              ? $nbPrepares . ' / ' . (int)$m['sorts_prepares']
              : (string)$nbPrepares];
          endif;
          if ((int)$m['profil'] === PROFINC_GRIMOIRE):
            $ressources[] = ['Sorts en grimoire', (string)count($grimoire)];
            $ressources[] = ['Sorts connus',      (string)count($connus)];
          elseif ((int)$m['profil'] === PROFINC_REPERTOIRE):
            $ressources[] = ['Sorts au répertoire', (string)count($connus)];
          endif;
          if ($m['cadence_lib']):
            $ressources[] = ['Renouvellement', $m['cadence_lib']];
          endif;
          if ($m['domaines']):
            $ressources[] = ['Domaines', implode(', ', $m['domaines'])];
          endif;
        ?>
        <div class="per-magie__synthese">

          <div class="per-magie__colonne-empl">
            <?php if ($m['pacte']): ?>
              <p class="per-magie__pacte">
                <strong>Magie de pacte</strong> —
                <?= (int)$m['pacte']['nb'] ?> emplacement<?= $m['pacte']['nb'] > 1 ? 's' : '' ?>
                de niveau <?= (int)$m['pacte']['niveau'] ?>,
                restauré<?= $m['pacte']['nb'] > 1 ? 's' : '' ?> à chaque <strong>repos court</strong>.
              </p>
            <?php endif ?>
            <div class="table-dd-wrap">
              <table class="table-dd per-magie__table">
                <thead>
                  <tr class="thead-groupes">
                    <th></th>
                    <th colspan="<?= $est35 ? 10 : 9 ?>" class="th-groupe-sorts">Niveaux de sort</th>
                  </tr>
                  <tr>
                    <th></th>
                    <?php for ($n = $est35 ? 0 : 1; $n <= 9; $n++): ?>
                      <th class="col-sort"><?= $n ?></th>
                    <?php endfor ?>
                  </tr>
                </thead>
                <tbody>
                  <tr>
                    <th scope="row" class="per-magie__ligne-lbl">
                      Par jour <?= aideIcone('magie-emplacements') ?>
                    </th>
                    <?php for ($n = $est35 ? 0 : 1; $n <= 9; $n++): ?>
                      <?php
                        $d   = $m['empl_detail'][$n] ?? null;
                        $acc = $d && !empty($d['accessible']);
                        $tt  = $acc
                          ? 'table ' . (int)$d['table']
                            . ($d['bonus']   ? ' + ' . (int)$d['bonus'] . ' de caractéristique' : '')
                            . ($d['domaine'] ? ' + 1 de domaine' : '')
                          : 'Niveau inaccessible à ce niveau de classe';
                      ?>
                      <td class="col-sort" title="<?= h($tt) ?>">
                        <?= $acc ? (int)$m['emplacements'][$n] : '—' ?>
                      </td>
                    <?php endfor ?>
                  </tr>
                  <?php if ($m['sorts_connus']): ?>
                    <tr>
                      <th scope="row" class="per-magie__ligne-lbl">Sorts connus</th>
                      <?php for ($n = $est35 ? 0 : 1; $n <= 9; $n++): ?>
                        <?php $c = (int)($m['sorts_connus'][$n] ?? 0); ?>
                        <td class="col-sort"><?= $c ?: '—' ?></td>
                      <?php endfor ?>
                    </tr>
                  <?php endif ?>
                  <tr class="per-magie__stock">
                    <th scope="row" class="per-magie__ligne-lbl">
                      En stock
                      <button type="button" class="btn btn-link btn-sm per-magie__stock-reset"
                              title="Restaurer tous les emplacements de la journée"
                              onclick="notifier('Suivi des emplacements consommés : table dédiée prévue en SP-PE8 (Mode jeu).')">
                        <i class="fa fa-rotate-left"></i>
                      </button>
                    </th>
                    <?php for ($n = $est35 ? 0 : 1; $n <= 9; $n++): ?>
                      <?php
                        $d   = $m['empl_detail'][$n] ?? null;
                        $acc = $d && !empty($d['accessible']);
                      ?>
                      <td class="col-sort"><?= $acc ? (int)$m['emplacements'][$n] : '—' ?></td>
                    <?php endfor ?>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>

          <?php if ($ressources): ?>
            <div class="per-magie__ressources">
              <h3 class="per-magie__ressources-titre">Ressources de sorts</h3>
              <dl class="per-magie__ressources-liste">
                <?php foreach ($ressources as [$res_lbl, $res_val]): ?>
                  <div class="per-magie__ressource">
                    <dt><?= h($res_lbl) ?></dt>
                    <dd><?= h($res_val) ?></dd>
                  </div>
                <?php endforeach ?>
              </dl>
            </div>
          <?php endif ?>

        </div>

        <?php // ---- Sorts toujours préparés ?>
        <?php if ($m['toujours']): ?>
          <?php
            // Groupés par variante : le Cercle de la Terre du Druide en propose
            // quatre, entre lesquelles le joueur choisit à chaque repos long.
            $parVariante = [];
            foreach ($m['toujours'] as $t) $parVariante[$t['cs_variante']][] = $t;
          ?>
          <div class="per-magie__toujours">
            <h3 class="per-fiche__sous-titre">
              Toujours préparés
              <span class="text-muted text-sm">— ne comptent pas dans le plafond</span>
            </h3>
            <?php foreach ($parVariante as $variante => $liste): ?>
              <?php if ($variante !== ''): ?>
                <p class="per-magie__variante"><strong>Terres <?= h($variante) ?>s</strong></p>
              <?php endif ?>
              <ul class="per-magie__sorts">
                <?php foreach ($liste as $t): ?>
                  <li>
                    <span class="mo-lien"
                          onclick="actualiserPage('<?= $urlSort ?>', {id: <?= (int)$t['so_id'] ?>}, 'externe')">
                      <?= h($t['so_nom']) ?>
                    </span>
                    <span class="text-muted text-sm">
                      (niv. <?= (int)$t['cs_niveau'] ?><?php if ($t['cs_usages']): ?>,
                      <?= (int)$t['cs_usages'] ?>×/repos <?= h($t['cs_recharge']) ?><?php endif ?>)
                    </span>
                  </li>
                <?php endforeach ?>
              </ul>
            <?php endforeach ?>
            <?php if (count($parVariante) > 1): ?>
              <p class="text-muted text-sm">
                Un seul de ces groupes s'applique par jour : celui du terrain choisi au dernier repos long.
              </p>
            <?php endif ?>
          </div>
        <?php endif ?>

        <?php // ---- Listes du personnage ------------------------------------
              // Ordre DESCENDANT, du plus immédiat au plus lointain :
              //   Préparés  → ce que je peux lancer aujourd'hui
              //   Grimoire  → ce que je peux préparer demain
              //   Connus    → ce que je pourrai recopier un jour
              // Les explications passent en bulle d'aide : on ne les lit qu'une
              // fois, elles n'ont pas à encombrer la page à chaque visite. ?>
        <?php
          $blocs = [];
          if ((int)$m['profil'] !== PROFINC_REPERTOIRE):
            $blocs[] = ['Sorts préparés', $prepares, 'magie-prepares', 'prepare'];
          endif;
          if ((int)$m['profil'] === PROFINC_GRIMOIRE):
            $blocs[] = ['Grimoire',            $grimoire,  'magie-grimoire', null];
            $blocs[] = ['Connus, à recopier',  $aRecopier, 'magie-connus',   null];
          elseif ((int)$m['profil'] === PROFINC_REPERTOIRE):
            $blocs[] = ['Répertoire', $connus, null, null];
          endif;
        ?>
        <?php foreach ($blocs as [$titre, $liste, $cleAide, $mode]): ?>
          <div class="per-magie__liste">
            <h3 class="per-fiche__sous-titre">
              <?= h($titre) ?>
              <?php if ($cleAide): ?><?= aideIcone($cleAide) ?><?php endif ?>
            </h3>
            <?php if ($liste): ?>
              <ul class="per-magie__sorts">
                <?php foreach ($liste as $s2): ?>
                  <?php
                    // niveau_sort est résolu à la requête, selon le ruleset
                    // (so_niveau en DD2024, sc_niveau en DD3.5). Il peut rester
                    // NULL si le sort ne figure plus dans la liste de la classe —
                    // on omet alors la pastille plutôt que d'afficher un faux.
                    $niv = ($s2['niveau_sort'] === null || $s2['niveau_sort'] === '') ? null : (int)$s2['niveau_sort'];
                  ?>
                  <li>
                    <?php if ($niv !== null): ?>
                      <span class="per-magie__pastille" title="Niveau du sort"><?= $niv ?></span>
                    <?php endif ?>
                    <span class="mo-lien"
                          onclick="actualiserPage('<?= $urlSort ?>', {id: <?= (int)$s2['so_id'] ?>}, 'externe')"><?= h($s2['so_nom']) ?></span>
                    <?php if (isset($s2['pesp_nb']) && (int)$s2['pesp_nb'] > 1): ?>
                      <span class="text-muted text-sm">×<?= (int)$s2['pesp_nb'] ?></span>
                    <?php endif ?>
                    <?php if (isset($s2['pesp_origine']) && (int)$s2['pesp_origine'] !== 0): ?>
                      <span class="per-magie__badge">toujours préparé</span>
                    <?php endif ?>
                  </li>
                <?php endforeach ?>
              </ul>
            <?php else: ?>
              <p class="text-muted text-sm">Aucun sort.</p>
            <?php endif ?>
          </div>
        <?php endforeach ?>
      </div>
    </section>
  <?php endforeach ?>

</div>

<?php require_once '../include/footer.php'; ?>
