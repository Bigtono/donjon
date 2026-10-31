<?php
// personnages/notes.php — Notes reçues par le personnage (SP-NO4).
//
// Sous-page du personnage, comme Magie et Possessions. Ne montre que ce que le
// personnage peut lire : le moteur d'accès (getNotesPersonnage, SP-NO1) écarte
// côté serveur les sections dont aucune condition n'est remplie — elles
// n'atteignent jamais le navigateur, et la recherche ne les parcourt pas.
//
// Portée (pe_notes_scope) : 0 = campagne en cours, 1 = toutes les campagnes.
// Sans campagne en cours, toutes les campagnes sont montrées.
// Paramètres GET : id (pe_id), f_campagne, f_sce, f_tyno, f_tag, q, tri (asc|desc)
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

$ruleset_id = (int)$perso['pe_ruleset_var_id'];
$classes    = getPersonnageClasses($db, (int)$perso['pe_id']);

// L'onglet Magie n'est proposé qu'aux lanceurs (D-MAG2).
$nav_lanceur = false;
foreach ($classes as $c):
  if ((int)$c['cla_mag_id'] > 0) { $nav_lanceur = true; break; }
endforeach;

$pe_camp_id   = (int)($perso['pe_camp_id'] ?? 0);
$scope_toutes = (int)$perso['pe_notes_scope'] === 1 || $pe_camp_id === 0;

// Filtres de la portée seule : sert aux listes de choix (scénarios, catégories,
// mots-clés des seules notes reçues).
$filtres_portee = $scope_toutes ? [] : ['camp_id' => $pe_camp_id];
$toutes         = getNotesPersonnage($db, $perso, $filtres_portee);

$f_campagne = $scope_toutes ? intParam($_GET['f_campagne'] ?? 0) : $pe_camp_id;
$f_sce      = intParam($_GET['f_sce'] ?? 0);
$f_tyno     = intParam($_GET['f_tyno'] ?? 0);
$f_tag      = intParam($_GET['f_tag'] ?? 0);
$q          = strParam($_GET['q'] ?? '');
$tri        = ($_GET['tri'] ?? 'desc') === 'asc' ? 'asc' : 'desc';

$opt_camps = $opt_sces = $opt_tynos = $opt_tags = [];
foreach ($toutes as $n):
  $opt_camps[(int)$n['no_camp_id']] = $n['camp_nom'];
  if ($n['sce_nom'] !== null && ($f_campagne === 0 || (int)$n['no_camp_id'] === $f_campagne)):
    $opt_sces[(int)$n['no_sce_id']] = $n['sce_nom'];
  endif;
  if ($n['tyno_nom'] !== null) $opt_tynos[(int)$n['no_tyno_id']] = $n['tyno_nom'];
  foreach ($n['tags'] as $t) $opt_tags[$t['tag_id']] = $t['tag_nom'];
endforeach;
foreach ([&$opt_camps, &$opt_sces, &$opt_tynos, &$opt_tags] as &$opts) asort($opts, SORT_NATURAL | SORT_FLAG_CASE);
unset($opts);

$filtres_actifs = count(array_filter([$scope_toutes ? $f_campagne : 0, $f_sce, $f_tyno, $f_tag, $q !== '' ? 1 : 0]));
$notes = ($filtres_actifs === 0 && $tri === 'desc')
  ? $toutes
  : getNotesPersonnage($db, $perso, [
      'camp_id' => $f_campagne, 'sce_id' => $f_sce, 'tyno_id' => $f_tyno,
      'tag_id'  => $f_tag, 'q' => $q, 'tri' => $tri,
    ]);

$nb_non_lues = count(array_filter($toutes, fn($n) => $n['pno_lu_date'] === null));

// Extrait d'une carte : début du texte commun, sinon de la première section lisible.
function extraitNote(array $n): string {
  $html = !texteRicheVide($n['no_texte']) ? $n['no_texte'] : ($n['sections'][0]['noc_texte'] ?? '');
  $txt  = trim(preg_replace('/\s+/u', ' ', html_entity_decode(strip_tags((string)$html), ENT_QUOTES | ENT_HTML5, 'UTF-8')));
  return mb_strlen($txt) > 160 ? rtrim(mb_substr($txt, 0, 160)) . '…' : $txt;
}

$page_title   = 'Notes — ' . $perso['pe_nom'];
$js_module    = 'personnage';
$css_module   = 'personnages';
$nav_courante = 'notes';

require_once '../include/header.php';
?>

<script>
  var perPeId     = <?= (int)$perso['pe_id'] ?>;
  var perUrlEnreg = <?= json_encode(BASE_URL . '/personnages/enregistrement.php?ajax=1') ?>;
</script>

<div class="per-fiche">

  <div class="per-fiche__header">
    <h1 class="per-fiche__nom"><?= h($perso['pe_nom']) ?></h1>
  </div>

  <?php require __DIR__ . '/../include/personnage-nav.php'; ?>

  <section class="per-fiche__bloc">
    <header class="per-fiche__bloc-header per-notes__entete">
      <h2 class="per-fiche__bloc-titre">
        <i class="fa fa-sticky-note"></i> Notes
        <?php if ($nb_non_lues > 0): ?>
          <span class="per-notes__compte" title="Notes non lues"><?= $nb_non_lues ?> nouvelle<?= $nb_non_lues > 1 ? 's' : '' ?></span>
        <?php endif ?>
      </h2>
      <?php if ($pe_camp_id > 0): ?>
        <div class="per-notes__portee" role="group" aria-label="Campagnes affichées">
          <button type="button" class="per-notes__portee-btn<?= !$scope_toutes ? ' est-actif' : '' ?>"
                  onclick="perDefinirPorteeNotes(0)" <?= !$scope_toutes ? 'aria-pressed="true"' : 'aria-pressed="false"' ?>
                  title="<?= h($perso['campagne_courante_nom'] ?? '') ?>">
            Campagne en cours
          </button>
          <button type="button" class="per-notes__portee-btn<?= $scope_toutes ? ' est-actif' : '' ?>"
                  onclick="perDefinirPorteeNotes(1)" <?= $scope_toutes ? 'aria-pressed="true"' : 'aria-pressed="false"' ?>>
            Toutes
          </button>
        </div>
      <?php endif ?>
    </header>

    <div class="per-fiche__bloc-body">

      <?php if (empty($toutes)): ?>
        <p class="text-muted text-sm">
          <?php if (!$scope_toutes): ?>
            Aucune note reçue dans la campagne « <?= h($perso['campagne_courante_nom'] ?? '') ?> ».
          <?php else: ?>
            Aucune note reçue pour le moment. Le MJ les diffuse depuis la campagne.
          <?php endif ?>
        </p>
      <?php else: ?>

        <div class="comp-filtre-bar">
          <button type="button" class="comp-filtre-toggle" onclick="toggleFiltresMobile()"
                  aria-expanded="false" id="filtre-toggle-btn">
            <i class="fa fa-filter"></i>
            Filtres
            <?php if ($filtres_actifs > 0): ?>
              <span class="comp-filtre-badge"><?= $filtres_actifs ?></span>
            <?php endif ?>
            <i class="fa fa-chevron-down comp-filtre-chevron"></i>
          </button>

          <div class="comp-filtre-content" id="comp-filtre-content">
            <form class="comp-filtre-form" method="GET" action="" id="form-filtre-notes">
              <input type="hidden" name="id" value="<?= (int)$perso['pe_id'] ?>">

              <div class="comp-filtre-item comp-filtre-item--text">
                <input type="search" name="q" value="<?= h($q) ?>" placeholder="Rechercher…"
                       class="comp-filtre-input" autocomplete="off">
              </div>

              <?php if ($scope_toutes && count($opt_camps) > 1): ?>
                <div class="comp-filtre-item">
                  <select name="f_campagne" class="comp-filtre-select" title="Campagne" onchange="this.form.submit()">
                    <option value="">— Campagne —</option>
                    <?php foreach ($opt_camps as $val => $lib): ?>
                      <option value="<?= $val ?>" <?= $val === $f_campagne ? 'selected' : '' ?>><?= h($lib) ?></option>
                    <?php endforeach ?>
                  </select>
                </div>
              <?php endif ?>

              <?php foreach ([['f_sce', 'Scénario', $opt_sces, $f_sce], ['f_tyno', 'Catégorie', $opt_tynos, $f_tyno], ['f_tag', 'Mot-clé', $opt_tags, $f_tag]] as [$nom, $lib_f, $opts, $val_f]): ?>
                <?php if (!empty($opts)): ?>
                  <div class="comp-filtre-item">
                    <select name="<?= $nom ?>" class="comp-filtre-select" title="<?= h($lib_f) ?>" onchange="this.form.submit()">
                      <option value="">— <?= h($lib_f) ?> —</option>
                      <?php foreach ($opts as $val => $lib): ?>
                        <option value="<?= $val ?>" <?= $val === $val_f ? 'selected' : '' ?>><?= h($lib) ?></option>
                      <?php endforeach ?>
                    </select>
                  </div>
                <?php endif ?>
              <?php endforeach ?>

              <div class="comp-filtre-item">
                <select name="tri" class="comp-filtre-select" title="Tri par date" onchange="this.form.submit()">
                  <option value="desc" <?= $tri === 'desc' ? 'selected' : '' ?>>Plus récentes</option>
                  <option value="asc" <?= $tri === 'asc' ? 'selected' : '' ?>>Plus anciennes</option>
                </select>
              </div>

              <div class="comp-filtre-item comp-filtre-item--actions">
                <button type="submit" class="btn btn-primary btn-sm">
                  <i class="fa fa-search"></i>
                  <span class="comp-filtre-label-desktop">Filtrer</span>
                </button>
                <a href="?id=<?= (int)$perso['pe_id'] ?>" class="btn btn-secondary btn-sm" title="Réinitialiser">
                  <i class="fa fa-times"></i>
                </a>
              </div>
            </form>
          </div>
        </div>

        <?php if (empty($notes)): ?>
          <p class="text-muted text-sm">Aucune note ne correspond à ces filtres.</p>
        <?php else: ?>
          <ul class="per-notes__liste">
            <?php foreach ($notes as $n): ?>
              <?php $nouveau = $n['pno_lu_date'] === null; ?>
              <li>
                <button type="button" class="per-notes__carte<?= $nouveau ? ' est-nouveau' : '' ?>"
                        onclick="perOuvrirNote(this, <?= (int)$n['no_id'] ?>)">
                  <span class="per-notes__tete">
                    <span class="per-notes__titre"><?= h($n['no_nom']) ?></span>
                    <?php if ($nouveau): ?>
                      <span class="per-notes__nouveau">Nouveau</span>
                    <?php endif ?>
                  </span>
                  <span class="per-notes__meta">
                    <?= h($n['tyno_nom'] ?? '') ?>
                    · <?= h(date('d/m/Y', strtotime($n['no_date']))) ?>
                    <?php if ($scope_toutes): ?>· <?= h($n['camp_nom']) ?><?php endif ?>
                    <?php if ($n['sce_nom'] !== null): ?>› <?= h($n['sce_nom']) ?><?php endif ?>
                  </span>
                  <?php $extrait = extraitNote($n); ?>
                  <?php if ($extrait !== ''): ?>
                    <span class="per-notes__extrait"><?= h($extrait) ?></span>
                  <?php endif ?>
                  <?php if ($n['tags']): ?>
                    <span class="per-notes__tags">
                      <?php foreach ($n['tags'] as $t): ?>
                        <span class="per-notes__tag"><?= h($t['tag_nom']) ?></span>
                      <?php endforeach ?>
                    </span>
                  <?php endif ?>
                </button>
              </li>
            <?php endforeach ?>
          </ul>
        <?php endif ?>

      <?php endif ?>
    </div>
  </section>

</div>

<?php require_once '../include/footer.php'; ?>
