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

setLastPersonnage((int)$perso['pe_id'], (int)$perso['pe_ruleset_var_id']);

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
      // sur le plafond (METIER_7_SORTS.md §11 Q7). En DD2024, les sorts mineurs
      // non plus : ils sont connus, pas préparés, et cn_sort_n0 les compte à
      // part (SP-PE10s). En DD3.5, le niveau 0 occupe de vrais emplacements.
      $nbPrepares = 0;
      foreach ($prepares as $p):
        if ((int)$p['pesp_origine'] !== 0) continue;
        if (!$est35 && $p['niveau_sort'] !== null && (int)$p['niveau_sort'] === 0) continue;
        $nbPrepares += max(1, (int)$p['pesp_nb']);
      endforeach;
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

        <?php // ---- Synthèse de la classe (SP-PE10p) ---------------------
              // Les quatre cases deviennent des paires libellé / valeur, sur le
              // modèle de la ligne d'identité de la fiche : libellé en gras,
              // valeur en graisse normale, même taille. Le nom de la
              // caractéristique sert lui-même de libellé, et les notes qui
              // répétaient le libellé (« jets d'attaque de sort »…) sont tombées.
              // Le panneau « Ressources de sorts » a disparu : ses compteurs de
              // listes sont passés dans les onglets, le reste (sorts mineurs,
              // renouvellement, domaines) suit ici les quatre valeurs.
              $stats = [];
              $stats[] = [
                $m['car_nom'] ?: 'Caractéristique',
                $m['car_valeur'] ? (int)$m['car_valeur'] . ' (' . formatMod((int)$m['car_mod']) . ')' : '—',
                '',
              ];
              $stats[] = [
                'NLS',
                (string)(int)$m['nls'],
                (int)$m['nls_detail']['prestige'] !== 0
                  ? '(' . (int)$m['nls_detail']['base'] . ($m['nls_detail']['origine'] === 'prestige' ? ' + prestige)' : ' · multiclasse)')
                  : '',
              ];
              // DD3.5 : le DD dépend du niveau du sort, il reste une formule.
              $stats[] = [
                'DD',
                $m['dd_par_niveau']
                  ? (int)$m['dd_base'] . ' + niv. ' . formatMod((int)$m['car_mod'])
                  : (string)(int)$m['dd_base'],
                '',
              ];
              // Sans objet en DD3.5 : le champ n'est pas produit, plutôt qu'un tiret.
              if ($m['attaque'] !== null):
                $stats[] = ['Attaque', formatMod((int)$m['attaque']), ''];
              endif;
              if ($m['sorts_mineurs'] !== null):
                $stats[] = ['Sorts mineurs', (string)(int)$m['sorts_mineurs'], ''];
              endif;
              if ($m['cadence_lib']):
                $stats[] = ['Renouvellement', $m['cadence_lib'], ''];
              endif;
              if ($m['domaines']):
                $stats[] = ['Domaines', implode(', ', $m['domaines']), ''];
              endif;
        ?>
        <div class="per-magie__entete">

          <dl class="per-magie__stats">
            <?php foreach ($stats as [$st_lbl, $st_val, $st_appoint]): ?>
              <div class="per-magie__stat">
                <dt><?= h($st_lbl) ?></dt>
                <dd>
                  <?= h($st_val) ?>
                  <?php if ($st_appoint !== ''): ?>
                    <span class="per-identite__appoint"><?= h($st_appoint) ?></span>
                  <?php endif ?>
                </dd>
              </div>
            <?php endforeach ?>
          </dl>

          <?php // ---- Tableau des emplacements (SP-PE10q) ----------------
                // Une seule rangée d'en-tête : la ligne de groupe « Niveaux de
                // sort » est tombée, la case d'angle porte « Niv. ». Les 9
                // niveaux sont TOUJOURS affichés, même inaccessibles — une table
                // dont le nombre de colonnes varie d'une classe à l'autre se
                // compare mal. Un niveau hors de portée porte « — ». ?>
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
                  <tr>
                    <th class="per-magie__ligne-lbl" scope="col">Niv.</th>
                    <?php for ($n = $est35 ? 0 : 1; $n <= 9; $n++): ?>
                      <th class="col-sort" scope="col"><?= $n ?></th>
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
                      Restant
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

        </div>

        <?php // ---- Listes du personnage, en onglets (SP-PE10r) ------------
              // Ordre DESCENDANT, du plus immédiat au plus lointain :
              //   Préparés    → ce que je peux lancer aujourd'hui (onglet par défaut)
              //   Grimoire    → ce que je peux préparer demain
              //   À recopier  → ce que je pourrai recopier un jour
              // Chaque onglet porte son compteur et ses actions : la barre
              // d'actions et le panneau « Ressources de sorts » ont disparu.
              // Un profil à liste unique (clerc, ensorceleur) garde la barre,
              // réduite à un onglet : elle lui sert de titre et porte ses actions.
              // Les outils sont des icônes seules, leur `title` dit l'action.
              // « Réinitialiser » vit dans le sélecteur de préparation (SP-PE10s).
              $pcId   = (int)$m['pc_id'];
              $onglets = [];
              if ((int)$m['profil'] !== PROFINC_REPERTOIRE):
                $outils = '<button type="button" class="btn btn-secondary btn-sm"'
                  . ' onclick="sortsPicker.ouvrir(' . $pcId . ', \'prepare\')"'
                  . ' title="Préparer des sorts" aria-label="Préparer des sorts">'
                  . '<i class="fa fa-wand-sparkles"></i></button>';
                $onglets[] = [
                  'cle'    => 'prepares',
                  'titre'  => 'Préparés',
                  // Le plafond de préparation n'existe qu'en DD2024 (cn_sortPrepare) :
                  // en DD3.5, c'est le tableau des emplacements qui borne.
                  'compte' => $m['sorts_prepares'] !== null ? $nbPrepares . '/' . (int)$m['sorts_prepares'] : (string)$nbPrepares,
                  'liste'  => $prepares,
                  'aide'   => 'magie-prepares',
                  'outils' => $outils,
                ];
              endif;
              $outilsRep = '<button type="button" class="btn btn-secondary btn-sm"'
                . ' onclick="sortsPicker.ouvrir(' . $pcId . ', \'repertoire\')"'
                . ' title="Gérer les sorts connus" aria-label="Gérer les sorts connus">'
                . '<i class="fa fa-book"></i></button>';
              if ((int)$m['profil'] === PROFINC_GRIMOIRE):
                $onglets[] = ['cle' => 'grimoire', 'titre' => 'Grimoire', 'compte' => (string)count($grimoire),
                              'liste' => $grimoire, 'aide' => 'magie-grimoire', 'outils' => $outilsRep];
                $onglets[] = ['cle' => 'recopier', 'titre' => 'À recopier', 'compte' => (string)count($aRecopier),
                              'liste' => $aRecopier, 'aide' => 'magie-connus', 'outils' => $outilsRep];
              elseif ((int)$m['profil'] === PROFINC_REPERTOIRE):
                $onglets[] = ['cle' => 'repertoire', 'titre' => 'Répertoire', 'compte' => (string)count($connus),
                              'liste' => $connus, 'aide' => null, 'outils' => $outilsRep];
              endif;
        ?>
        <?php if ($onglets): ?>
          <div class="per-magie__onglets" data-onglets="<?= $pcId ?>">

            <div class="per-magie__onglets-barre">
              <div class="per-magie__onglets-liste" role="tablist">
                <?php foreach ($onglets as $i => $o): ?>
                  <button type="button" role="tab"
                          class="per-magie__onglet<?= $i === 0 ? ' est-actif' : '' ?>"
                          id="onglet-<?= $pcId ?>-<?= h($o['cle']) ?>"
                          aria-controls="panneau-<?= $pcId ?>-<?= h($o['cle']) ?>"
                          aria-selected="<?= $i === 0 ? 'true' : 'false' ?>"
                          tabindex="<?= $i === 0 ? '0' : '-1' ?>"
                          data-onglet="<?= h($o['cle']) ?>">
                    <?= h($o['titre']) ?>
                    <span class="per-magie__onglet-compte"><?= h($o['compte']) ?></span>
                  </button>
                <?php endforeach ?>
              </div>
              <?php // Les outils de l'onglet actif seulement : les autres sont masqués. ?>
              <?php foreach ($onglets as $i => $o): ?>
                <div class="per-magie__outils" data-onglet="<?= h($o['cle']) ?>"<?= $i === 0 ? '' : ' hidden' ?>>
                  <?php if ($o['aide']): ?><?= aideIcone($o['aide']) ?><?php endif ?>
                  <?= $o['outils'] /* HTML construit ci-dessus, valeurs échappées */ ?>
                </div>
              <?php endforeach ?>
            </div>

            <?php foreach ($onglets as $i => $o): ?>
              <div class="per-magie__panneau" role="tabpanel"
                   id="panneau-<?= $pcId ?>-<?= h($o['cle']) ?>"
                   aria-labelledby="onglet-<?= $pcId ?>-<?= h($o['cle']) ?>"
                   data-onglet="<?= h($o['cle']) ?>"<?= $i === 0 ? '' : ' hidden' ?>>

                <?php
                  // Une ligne par niveau de sort, la pastille une seule fois en
                  // tête de ligne. niveau_sort est résolu à la requête selon le
                  // ruleset (so_niveau en DD2024, sc_niveau en DD3.5) ; il peut
                  // rester NULL si le sort ne figure plus dans la liste de la
                  // classe — ces sorts ferment la liste, sans pastille.
                  $parNiveau = [];
                  foreach ($o['liste'] as $s2):
                    $niv = ($s2['niveau_sort'] === null || $s2['niveau_sort'] === '') ? '' : (string)(int)$s2['niveau_sort'];
                    $parNiveau[$niv][] = $s2;
                  endforeach;
                  if (isset($parNiveau[''])):
                    $sansNiveau = $parNiveau[''];
                    unset($parNiveau['']);
                    $parNiveau[''] = $sansNiveau;
                  endif;
                ?>
                <?php if ($parNiveau): ?>
                  <div class="per-magie__niveaux">
                    <?php foreach ($parNiveau as $niv => $sorts): ?>
                      <div class="per-magie__niveau">
                        <span class="per-magie__pastille"<?= $niv === '' ? ' title="Niveau inconnu pour cette classe"' : ' title="Niveau du sort"' ?>><?= $niv === '' ? '?' : h($niv) ?></span>
                        <ul class="per-magie__sorts">
                          <?php foreach ($sorts as $s2): ?>
                            <li>
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
                      </div>
                    <?php endforeach ?>
                  </div>
                <?php else: ?>
                  <p class="text-muted text-sm per-magie__vide">Aucun sort.</p>
                <?php endif ?>

                <?php // ---- Sorts toujours préparés : dans le premier onglet,
                      // celui de ce qui se lance aujourd'hui. ?>
                <?php if ($i === 0 && $m['toujours']): ?>
                  <?php
                    // Groupés par variante : le Cercle de la Terre du Druide en
                    // propose quatre, entre lesquelles le joueur choisit à chaque
                    // repos long. Dans chaque variante, une ligne par niveau.
                    $parVariante = [];
                    foreach ($m['toujours'] as $t) $parVariante[$t['cs_variante']][(int)$t['cs_niveau']][] = $t;
                  ?>
                  <div class="per-magie__toujours">
                    <h3 class="per-fiche__sous-titre">
                      Toujours préparés
                      <span class="text-muted text-sm">— ne comptent pas dans le plafond</span>
                    </h3>
                    <?php foreach ($parVariante as $variante => $niveaux): ?>
                      <?php ksort($niveaux); ?>
                      <?php if ($variante !== ''): ?>
                        <p class="per-magie__variante"><strong>Terres <?= h($variante) ?>s</strong></p>
                      <?php endif ?>
                      <div class="per-magie__niveaux">
                        <?php foreach ($niveaux as $niv => $liste): ?>
                          <div class="per-magie__niveau">
                            <span class="per-magie__pastille" title="Niveau du sort"><?= (int)$niv ?></span>
                            <ul class="per-magie__sorts">
                              <?php foreach ($liste as $t): ?>
                                <li>
                                  <span class="mo-lien"
                                        onclick="actualiserPage('<?= $urlSort ?>', {id: <?= (int)$t['so_id'] ?>}, 'externe')"><?= h($t['so_nom']) ?></span>
                                  <?php if ($t['cs_usages']): ?>
                                    <span class="text-muted text-sm">(<?= (int)$t['cs_usages'] ?>×/repos <?= h($t['cs_recharge']) ?>)</span>
                                  <?php endif ?>
                                </li>
                              <?php endforeach ?>
                            </ul>
                          </div>
                        <?php endforeach ?>
                      </div>
                    <?php endforeach ?>
                    <?php if (count($parVariante) > 1): ?>
                      <p class="text-muted text-sm">
                        Un seul de ces groupes s'applique par jour : celui du terrain choisi au dernier repos long.
                      </p>
                    <?php endif ?>
                  </div>
                <?php endif ?>

              </div>
            <?php endforeach ?>

          </div>
        <?php endif ?>
      </div>
    </section>
  <?php endforeach ?>

</div>

<?php require_once '../include/footer.php'; ?>
