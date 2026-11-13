<?php
// include/ajax/modifier/objet-compose.php
// Compositeur d'objets magiques DD3.5 (SP-PO10) dans #modification, depuis personnages/possessions.php.
//
// Armes, armures, boucliers : objet de base, bonus d'altération (par tête pour une arme double),
// propriétés spéciales (paramètre libre), nom. L'aperçu (prix, coût, PX, NLS, erreurs) est calculé
// en direct par include/ajax/possession-calcul.php, donc par le moteur ; l'enregistrement
// (enregistrerCompose) recalcule et refuse une composition qui enfreint une règle (D-PO19, D-PO20).
// Les propriétés incompatibles avec l'objet de base sont grisées ici, mais c'est le moteur qui tranche.
//
// Potions, huiles, baguettes, parchemins (SP-PO11) : un sort (1 à 6 pour un parchemin) cherché par
// include/ajax/autocomplete-sorts.php, la liste de classe qui fixe son niveau (listes du sort renvoyées
// par possession-calcul.php, option listes=), le NLS (minimum de cette liste si vide), les composantes
// coûteuses en po et en PX.
//
// Paramètres GET : pe_id, cat (arme | armure | bouclier | potion | huile | baguette | parchemin,
//                  défaut arme), id (pp_id : recomposer)
// Droit : peutGererPersonnage (getPersonnageContext).
//
// Référence : doc/ARCHITECTURE_0_REFERENCE.md §7.9b

require_once __DIR__ . '/../../db.php';
require_once __DIR__ . '/../../auth.php';
require_once __DIR__ . '/../../helpers.php';
require_once __DIR__ . '/../../personnage_helpers.php';
require_once __DIR__ . '/../../objet-compose.php';

requireAuth();

$pe_id = intParam($_GET['pe_id'] ?? 0);
$perso = getPersonnageContext($db, $pe_id);
if (!$perso || (int)$perso['pe_ruleset_var_id'] !== OC_RULESET):
  http_response_code(403);
  echo '<p class="erreur">Personnage introuvable, accès refusé, ou personnage hors DD3.5.</p>';
  exit;
endif;

// ---- Objet existant (recomposer) ------------------------------------
$pp_id = intParam($_GET['id'] ?? 0);
$pp = null;
$elements = [];
if ($pp_id > 0):
  $stmt = $db->prepare('SELECT * FROM dd_personnages_possessions WHERE pp_id = ? AND pp_pe_id = ? AND pp_type = \'compose\'');
  $stmt->execute([$pp_id, $pe_id]);
  $pp = $stmt->fetch();
  if (!$pp):
    http_response_code(404);
    echo '<p class="erreur">Objet composé introuvable.</p>';
    exit;
  endif;
  $stmt = $db->prepare('SELECT * FROM dd_personnages_possessions_elements WHERE ppe_pp_id = ? ORDER BY ppe_tete, ppe_ordre');
  $stmt->execute([$pp_id]);
  $elements = $stmt->fetchAll();
endif;

$cats   = composeCategories();
$consos = composeConsommables();
$cat = $pp ? $pp['pp_compose_cat'] : strParam($_GET['cat'] ?? 'arme');
if (!isset($cats[$cat])):
  echo '<p class="erreur">Type d\'objet inconnu.</p>';
  exit;
endif;
$est_conso = isset($consos[$cat]);
$res_ids   = getActiveResIds($db, OC_RULESET, ['pe_id' => $pe_id]);
$bases = $proprietes = $sorts = [];

if (!$est_conso):
// ---- Objets de base : équipement DD3.5 du bon rôle -------------------
$params  = [OC_RULESET];
$vis     = listeClauseVisibilite('res.res_j_id', 'eqt.eqt_public', 'eqt.eqt_visible', $params);
$sql = "
  SELECT eqt.*, cae.cae_slug, cae.cae_nom
    FROM dd_equipements eqt
    JOIN dd_categorie_equipement cae ON cae.cae_id = eqt.eqt_cae_id
    LEFT JOIN dd_ressources res ON res.res_id = eqt.eqt_res_id
   WHERE eqt.eqt_ruleset_var_id = ? AND eqt.eqt_camp_id IS NULL AND $vis";
if (!empty($res_ids)):
  // L'objet de base d'un composé existant reste proposé même si sa source a été désactivée
  $sql .= ' AND (eqt.eqt_res_id IN (' . resIdsPlaceholders($res_ids) . ') OR eqt.eqt_id = ?)';
  $params = array_merge($params, $res_ids, [(int)($pp['pp_eqt_id'] ?? 0)]);
endif;
$stmt = $db->prepare($sql);
$stmt->execute($params);
$arbre = catEquipementArbre($db, OC_RULESET);
$bases = [];
foreach ($stmt->fetchAll() as $eqt):
  $b = composeObjetBaseDepuisLigne($db, $eqt);
  if ($b['role'] !== $cat) continue;
  $b['famille'] = $eqt['cae_nom'];
  $b['rang']    = $arbre['rang'][(int)$eqt['eqt_cae_id']] ?? PHP_INT_MAX;
  $bases[] = $b;
endforeach;
usort($bases, fn($a, $b) => [$a['rang'], (int)$a['eqt']['eqt_ordre'], $a['nom']] <=> [$b['rang'], (int)$b['eqt']['eqt_ordre'], $b['nom']]);

// ---- Propriétés spéciales de la catégorie ---------------------------
$params = [OC_RULESET, $cat === 'arme' ? OC_CAT_PROP_ARME : OC_CAT_PROP_ARMURE];
$vis    = listeClauseVisibilite('res.res_j_id', 'om.om_public', 'om.om_visible', $params);
$stmt = $db->prepare("
  SELECT om.om_id, om.om_nom, om.om_bonus_equiv, om.om_prix, om.om_nls, om.om_restriction
    FROM dd_objets_magiques om
    JOIN dd_categorie_objet_magique com ON com.com_id = om.om_com_id
    LEFT JOIN dd_ressources res ON res.res_id = om.om_res_id
   WHERE om.om_ruleset_var_id = ? AND com.com_slug = ? AND com.com_est_propriete = 1
     AND om.om_camp_id IS NULL AND $vis
   ORDER BY om.om_nom
");
$stmt->execute($params);
$proprietes = $stmt->fetchAll();
endif;

// ---- Sorts d'un consommable existant (recomposer) --------------------
// Chaque ligne porte ses listes de classe, pour pré-remplir le choix de la liste
if ($est_conso):
  $stmt = $db->prepare('SELECT so_nom FROM dd_sorts WHERE so_id = ?');
  foreach ($elements as $e):
    if ($e['ppe_type'] !== 'sort' || !$e['ppe_so_id']) continue;
    $stmt->execute([(int)$e['ppe_so_id']]);
    $sorts[] = [
      'so_id'  => (int)$e['ppe_so_id'],
      'nom'    => (string)$stmt->fetchColumn(),
      'cla_id' => (int)$e['ppe_cla_id'],
      'nls'    => $e['ppe_nls'] !== null ? (int)$e['ppe_nls'] : '',
      'po'     => (int)$e['ppe_suppl_pc'] > 0 ? str_replace('.', ',', rtrim(rtrim(sprintf('%.2f', (int)$e['ppe_suppl_pc'] / 100), '0'), '.')) : '',
      'px'     => (int)$e['ppe_suppl_px'] > 0 ? (int)$e['ppe_suppl_px'] : '',
      'listes' => sortListesClasses($db, (int)$e['ppe_so_id']),
    ];
  endforeach;
  if (empty($sorts)) $sorts[] = ['so_id' => 0, 'nom' => '', 'cla_id' => 0, 'nls' => '', 'po' => '', 'px' => '', 'listes' => []];
endif;

// Éléments existants : [tete][om_id] => paramètre
$coches = [1 => [], 2 => []];
foreach ($elements as $e):
  if ($e['ppe_type'] === 'propriete') $coches[(int)$e['ppe_tete'] === 2 ? 2 : 1][(int)$e['ppe_om_id']] = (string)$e['ppe_parametre'];
endforeach;

$bonus  = $pp ? (int)$pp['pp_bonus'] : 1;
$bonus2 = $pp && $pp['pp_bonus_tete2'] !== null ? (int)$pp['pp_bonus_tete2'] : 0;
$jetons = proprieteRestrictionsJetons();
$url_calcul = BASE_URL . '/include/ajax/possession-calcul.php';
$url_form   = BASE_URL . '/include/ajax/modifier/objet-compose.php';
?>

<div class="modif-form oc-form" id="oc-form">
  <h3 class="modif-form__title">
    <?= $pp ? 'Recomposer' : 'Composer' ?> un objet magique — <?= h($perso['pe_nom']) ?>
  </h3>

  <div class="oc-form__types" role="radiogroup" aria-label="Type d'objet">
    <?php foreach ($cats as $c => $lib): ?>
      <button type="button" class="poss-picker__onglet<?= $c === $cat ? ' est-actif' : '' ?>"
              <?= $pp ? 'disabled' : '' ?>
              onclick="actualiserPageModif(<?= h(json_encode($url_form)) ?>, {pe_id: <?= (int)$pe_id ?>, cat: '<?= $c ?>'})">
        <?= h($lib) ?>
      </button>
    <?php endforeach ?>
  </div>

  <form id="oc-form-champs" onsubmit="return false">
    <input type="hidden" name="pe_id" value="<?= (int)$pe_id ?>">
    <input type="hidden" name="pp_id" value="<?= (int)$pp_id ?>">
    <input type="hidden" name="cat" value="<?= h($cat) ?>">

    <?php if (!$est_conso): ?>
    <div class="oc-form__grille">
      <div class="form-group">
        <label for="oc-eqt">Objet de base <span class="required">*</span></label>
        <select id="oc-eqt" name="eqt_id" onchange="ocForm.changerBase()">
          <option value="">— Choisir —</option>
          <?php $famille = null; ?>
          <?php foreach ($bases as $b): ?>
            <?php if ($b['famille'] !== $famille): ?>
              <?php if ($famille !== null): ?></optgroup><?php endif ?>
              <optgroup label="<?= h($b['famille']) ?>">
              <?php $famille = $b['famille']; ?>
            <?php endif ?>
            <option value="<?= (int)$b['eqt']['eqt_id'] ?>"
                    data-emploi="<?= h(implode(' ', $b['emploi'])) ?>"
                    data-degats="<?= h(implode(' ', $b['degats'])) ?>"
                    data-double="<?= $b['double'] ? 1 : 0 ?>"
                    <?= $pp && (int)$pp['pp_eqt_id'] === (int)$b['eqt']['eqt_id'] ? 'selected' : '' ?>>
              <?= h($b['nom']) ?><?= $b['munition'] ? ' (lot de ' . OC_MUNITIONS_LOT . ')' : '' ?>
            </option>
          <?php endforeach ?>
          <?php if ($famille !== null): ?></optgroup><?php endif ?>
        </select>
      </div>

      <div class="form-group">
        <label for="oc-bonus">Bonus d'altération<span class="oc-tete2"> — tête 1</span></label>
        <select id="oc-bonus" name="bonus" onchange="ocForm.calculer()">
          <?php for ($i = 0; $i <= OC_BONUS_MAX; $i++): ?>
            <option value="<?= $i ?>" <?= $i === $bonus ? 'selected' : '' ?>><?= $i === 0 ? '+0 (de maître)' : '+' . $i ?></option>
          <?php endfor ?>
        </select>
      </div>

      <div class="form-group oc-tete2">
        <label for="oc-bonus2">Bonus d'altération — tête 2</label>
        <select id="oc-bonus2" name="bonus_tete2" onchange="ocForm.calculer()">
          <?php for ($i = 0; $i <= OC_BONUS_MAX; $i++): ?>
            <option value="<?= $i ?>" <?= $i === $bonus2 ? 'selected' : '' ?>><?= $i === 0 ? '+0 (de maître)' : '+' . $i ?></option>
          <?php endfor ?>
        </select>
      </div>
    </div>

    <fieldset class="oc-form__proprietes">
      <legend>Propriétés spéciales</legend>
      <input type="search" class="dons-picker__recherche oc-form__filtre" placeholder="Filtrer les propriétés…"
             oninput="ocForm.filtrerProprietes(this.value)">
      <ul class="oc-proprietes" id="oc-proprietes">
        <?php foreach ($proprietes as $p): ?>
          <?php
            $om_id = (int)$p['om_id'];
            $valeur = $p['om_bonus_equiv'] !== null ? '+' . (int)$p['om_bonus_equiv'] : ($p['om_prix'] !== null ? formaterPrixPo((int)$p['om_prix'] * 100) : '?');
            $restr = preg_split('/\s+/', (string)$p['om_restriction'], -1, PREG_SPLIT_NO_EMPTY);
            $restr_lib = [];
            foreach ($restr as $j) $restr_lib[] = mb_strtolower($jetons['emploi'][$j] ?? $jetons['degats'][$j] ?? $j);
            $param = $coches[1][$om_id] ?? $coches[2][$om_id] ?? '';
          ?>
          <li class="oc-propriete" data-om="<?= $om_id ?>" data-nom="<?= h(mb_strtolower($p['om_nom'])) ?>"
              data-restriction="<?= h((string)$p['om_restriction']) ?>">
            <label class="oc-propriete__case">
              <input type="checkbox" data-tete="1" onchange="ocForm.calculer()" <?= isset($coches[1][$om_id]) ? 'checked' : '' ?>>
              <span class="oc-tete2">T1</span>
            </label>
            <label class="oc-propriete__case oc-tete2">
              <input type="checkbox" data-tete="2" onchange="ocForm.calculer()" <?= isset($coches[2][$om_id]) ? 'checked' : '' ?>>
              <span>T2</span>
            </label>
            <a href="javascript:void(0)" class="oc-propriete__nom"
               onclick="actualiserPageSub(<?= h(json_encode(BASE_URL . '/include/ajax/detail-pp/objet.php')) ?>, {id: <?= $om_id ?>})"><?= h($p['om_nom']) ?></a>
            <span class="oc-propriete__valeur"><?= h($valeur) ?> · NLS <?= (int)$p['om_nls'] ?></span>
            <?php if ($restr_lib): ?>
              <span class="oc-propriete__restriction"><?= h(implode(', ', $restr_lib)) ?></span>
            <?php endif ?>
            <input type="text" class="oc-propriete__param" maxlength="150" value="<?= h($param) ?>"
                   placeholder="Précision (créature, sort, énergie…)" onchange="ocForm.calculer()">
          </li>
        <?php endforeach ?>
      </ul>
    </fieldset>
    <?php else: ?>
    <?php
      $regl = $consos[$cat];
      // Une ligne de sort ; $s vide = modèle cloné par le JS
      $ligneSort = function (array $s) use ($regl): void { ?>
        <li class="oc-sort" data-so="<?= (int)$s['so_id'] ?>">
          <div class="form-group oc-sort__recherche">
            <label>Sort</label>
            <div class="autocomplete-wrap">
              <input type="text" class="autocomplete-input oc-sort__nom" autocomplete="off"
                     placeholder="Taper au moins 2 caractères…" value="<?= h($s['nom']) ?>"
                     oninput="ocForm.chercherSort(this)" onblur="ocForm.fermerRecherche(this)">
              <ul class="autocomplete-list" hidden></ul>
            </div>
          </div>
          <div class="form-group oc-sort__liste-grp">
            <label>Liste de classe</label>
            <select class="oc-sort__liste" onchange="ocForm.changerListe(this)">
              <?php if (empty($s['listes'])): ?>
                <option value="0">— Choisir un sort —</option>
              <?php endif ?>
              <?php foreach ($s['listes'] as $l): ?>
                <option value="<?= (int)$l['cla_id'] ?>" data-nls-min="<?= (int)$l['nls_min'] ?>"
                        <?= (int)$l['cla_id'] === $s['cla_id'] ? 'selected' : '' ?>>
                  <?= h($l['cla_nom']) ?> — niveau <?= (int)$l['niveau'] ?><?= $l['niveau'] > $regl['niv_max'] ? ' (trop haut)' : '' ?>
                </option>
              <?php endforeach ?>
            </select>
          </div>
          <div class="form-group oc-sort__court">
            <label>NLS</label>
            <input type="number" class="oc-sort__nls" min="1" max="20" value="<?= h((string)$s['nls']) ?>"
                   onchange="ocForm.calculer()">
          </div>
          <div class="form-group oc-sort__court">
            <label title="Composantes matérielles ou focaliseur coûteux, en po">Compos. (po)</label>
            <input type="text" class="oc-sort__po" inputmode="decimal" value="<?= h((string)$s['po']) ?>"
                   onchange="ocForm.calculer()">
          </div>
          <div class="form-group oc-sort__court">
            <label title="Coût en PX du sort, s'il en a un">PX</label>
            <input type="number" class="oc-sort__px" min="0" value="<?= h((string)$s['px']) ?>"
                   onchange="ocForm.calculer()">
          </div>
          <?php if ($regl['nb_max'] > 1): ?>
            <button type="button" class="btn-icon btn-sm oc-sort__retirer" title="Retirer ce sort"
                    onclick="ocForm.retirerSort(this)"><i class="fa fa-trash"></i></button>
          <?php endif ?>
        </li>
      <?php };
    ?>
    <fieldset class="oc-form__proprietes">
      <legend>Sort<?= $regl['nb_max'] > 1 ? 's (' . $regl['nb_min'] . ' à ' . $regl['nb_max'] . ')' : '' ?></legend>
      <p class="text-muted text-sm oc-form__aide">
        Niveau de sort <?= (int)$regl['niv_max'] ?> au plus<?= $cat === 'parchemin' ? ', sorts tous profanes ou tous divins' : '' ?>.
        NLS vide = minimum de la liste choisie. Les composantes coûteuses comptent
        <?= $regl['comp'] > 1 ? '× ' . (int)$regl['comp'] . ' (une par charge)' : 'une fois' ?>.
      </p>
      <ul class="oc-sorts" id="oc-sorts">
        <?php foreach ($sorts as $s) $ligneSort($s); ?>
      </ul>
      <template id="oc-sort-modele">
        <?php $ligneSort(['so_id' => 0, 'nom' => '', 'cla_id' => 0, 'nls' => '', 'po' => '', 'px' => '', 'listes' => []]); ?>
      </template>
      <?php if ($regl['nb_max'] > 1): ?>
        <button type="button" class="btn btn-secondary btn-sm" id="oc-sort-ajouter" onclick="ocForm.ajouterSort()">
          <i class="fa fa-plus"></i> Ajouter un sort
        </button>
      <?php endif ?>
    </fieldset>
    <?php endif ?>

    <div class="form-group">
      <label for="oc-nom">Nom</label>
      <input type="text" id="oc-nom" name="nom" maxlength="200" value="<?= h((string)($pp['pp_nom'] ?? '')) ?>"
             oninput="ocForm.nomSaisi()">
    </div>
  </form>

  <section class="oc-apercu" id="oc-apercu" aria-live="polite">
    <p class="text-muted text-sm"><?= $est_conso ? 'Choisissez un sort pour voir le prix.' : 'Choisissez l\'objet de base pour voir le prix.' ?></p>
  </section>

  <div class="modif-actions">
    <button type="button" class="btn btn-primary" id="oc-enregistrer" onclick="ocForm.enregistrer()" disabled>
      <i class="fa fa-check"></i> <?= $pp ? 'Recomposer' : 'Ajouter à l\'inventaire' ?>
    </button>
    <button type="button" class="btn btn-secondary" onclick="fermerModification()">
      <i class="fa fa-times"></i> Annuler
    </button>
  </div>
</div>

<script>
(function() {
  var urlCalcul = <?= json_encode($url_calcul) ?>;
  var urlEnreg  = <?= json_encode(BASE_URL . '/personnages/enregistrement.php?ajax=1') ?>;
  var urlSorts  = <?= json_encode(BASE_URL . '/include/ajax/autocomplete-sorts.php') ?>;
  var resIds    = <?= json_encode(implode(',', $res_ids)) ?>;
  var estConso  = <?= $est_conso ? 'true' : 'false' ?>;
  var nbMax     = <?= $est_conso ? (int)$consos[$cat]['nb_max'] : 0 ?>;
  var nomGenere = null;
  var nomManuel = <?= $pp ? 'null' : 'false' ?>;   // null : à décider au premier aperçu (recomposer)
  var demande   = 0;
  var dernier   = null;
  var minuterie = null;

  function form()  { return document.getElementById('oc-form-champs'); }
  function base()  { var s = document.getElementById('oc-eqt'); return s ? s.options[s.selectedIndex] : null; }
  function estDouble() { var o = base(); return !!(o && o.value && o.dataset.double === '1'); }

  // Propriétés incompatibles avec l'objet de base : grisées et décochées (le moteur tranche quand même)
  function majCompatibilite() {
    if (estConso) return;
    var o = base();
    var emploi = o && o.value ? o.dataset.emploi.split(' ') : [];
    var degats = o && o.value ? o.dataset.degats.split(' ') : [];
    var empJ = ['cac', 'distance', 'jet', 'armure', 'bouclier', 'ecu'];
    document.querySelectorAll('#oc-proprietes .oc-propriete').forEach(function(li) {
      var r = li.dataset.restriction ? li.dataset.restriction.split(' ') : [];
      var rEmp = r.filter(function(j) { return empJ.indexOf(j) !== -1; });
      var rDeg = r.filter(function(j) { return empJ.indexOf(j) === -1; });
      var ok = !o || !o.value
        || ((!rEmp.length || rEmp.some(function(j) { return emploi.indexOf(j) !== -1; }))
         && (!rDeg.length || rDeg.some(function(j) { return degats.indexOf(j) !== -1; })));
      li.classList.toggle('est-incompatible', !ok);
      li.querySelectorAll('input[type="checkbox"]').forEach(function(c) {
        c.disabled = !ok;
        if (!ok) c.checked = false;
      });
    });
    document.getElementById('oc-form').classList.toggle('est-double', estDouble());
  }

  function lignesSorts() { return Array.prototype.slice.call(document.querySelectorAll('#oc-sorts .oc-sort')); }

  function donnees() {
    var f = form();
    var d = new URLSearchParams();
    d.append('csrf_token', getCsrfToken());
    ['pe_id', 'pp_id', 'cat'].forEach(function(k) { d.append(k, f.elements[k].value); });
    if (estConso) {
      lignesSorts().forEach(function(li) {
        if (!parseInt(li.dataset.so, 10)) return;
        d.append('sort_so[]', li.dataset.so);
        d.append('sort_cla[]', li.querySelector('.oc-sort__liste').value);
        d.append('sort_nls[]', li.querySelector('.oc-sort__nls').value);
        d.append('sort_suppl_po[]', li.querySelector('.oc-sort__po').value);
        d.append('sort_suppl_px[]', li.querySelector('.oc-sort__px').value);
      });
      return d;
    }
    ['eqt_id', 'bonus'].forEach(function(k) { d.append(k, f.elements[k].value); });
    if (estDouble()) d.append('bonus_tete2', f.elements['bonus_tete2'].value);
    document.querySelectorAll('#oc-proprietes .oc-propriete').forEach(function(li) {
      li.querySelectorAll('input[type="checkbox"]').forEach(function(c) {
        var tete = parseInt(c.dataset.tete, 10);
        if (!c.checked || (tete === 2 && !estDouble())) return;
        d.append('prop_om[]', li.dataset.om);
        d.append('prop_tete[]', tete);
        d.append('prop_param[]', li.querySelector('.oc-propriete__param').value);
      });
      var coche = Array.prototype.some.call(li.querySelectorAll('input[type="checkbox"]'), function(c) { return c.checked; });
      li.classList.toggle('est-coche', coche);
    });
    return d;
  }

  function echapper(t) {
    var s = document.createElement('span');
    s.textContent = t == null ? '' : String(t);
    return s.innerHTML;
  }

  function afficher(r) {
    var z = document.getElementById('oc-apercu');
    var h = '<h4 class="oc-apercu__nom">' + echapper(r.nom || '—') + '</h4>'
      + '<p class="oc-apercu__chiffres"><strong>' + echapper(r.prix) + '</strong>'
      + (r.quantite > 1 ? ' pour ' + r.quantite : '')
      + ' · coût de création ' + echapper(r.cout) + ', ' + r.cout_px + ' PX'
      + (r.nls ? ' · NLS ' + r.nls : '')
      // Recomposer garde les charges restantes : n'afficher les 50 charges que pour une création
      + (r.charges && !<?= $pp ? 'true' : 'false' ?> ? ' · ' + r.charges + ' charges' : '') + '</p>';
    if (r.details && r.details.length) {
      h += '<ul class="oc-apercu__details">';
      r.details.forEach(function(x) { h += '<li><span>' + echapper(x.libelle) + '</span><span>' + echapper(x.prix) + '</span></li>'; });
      h += '</ul>';
    }
    (r.avertissements || []).forEach(function(a) { h += '<p class="oc-apercu__avert"><i class="fa fa-circle-info"></i> ' + echapper(a) + '</p>'; });
    (r.erreurs || []).forEach(function(e) { h += '<p class="oc-apercu__erreur"><i class="fa fa-triangle-exclamation"></i> ' + echapper(e) + '</p>'; });
    z.innerHTML = h;

    var nom = document.getElementById('oc-nom');
    if (nomManuel === null) nomManuel = nom.value !== '' && nom.value !== r.nom;
    if (!nomManuel) nom.value = r.nom || '';
    nomGenere = r.nom;
    document.getElementById('oc-enregistrer').disabled = !r.ok;
  }

  function pret() {
    if (estConso) return lignesSorts().some(function(li) { return parseInt(li.dataset.so, 10) > 0; });
    return !!form().elements['eqt_id'].value;
  }

  function calculer() {
    if (!pret()) {
      document.getElementById('oc-enregistrer').disabled = true;
      return;
    }
    var n = ++demande;
    fetch(urlCalcul, { method: 'POST', body: donnees() })
      .then(function(r) { if (!r.ok) throw new Error('Erreur ' + r.status); return r.json(); })
      .then(function(r) { if (n !== demande) return; dernier = r; afficher(r); })
      .catch(function(e) { document.getElementById('oc-apercu').innerHTML = '<p class="erreur">' + echapper(e) + '</p>'; });
  }

  function changerBase() { majCompatibilite(); calculer(); }

  function nomSaisi() {
    var v = document.getElementById('oc-nom').value;
    nomManuel = v !== '' && v !== nomGenere;
  }

  function filtrerProprietes(q) {
    q = q.trim().toLowerCase();
    document.querySelectorAll('#oc-proprietes .oc-propriete').forEach(function(li) {
      li.classList.toggle('noDisplay', q !== '' && li.dataset.nom.indexOf(q) === -1);
    });
  }

  // ---- Sorts (consommables) ------------------------------------------

  function chercherSort(input) {
    var li = input.closest('.oc-sort');
    var liste = li.querySelector('.autocomplete-list');
    // Le texte ne correspond plus au sort choisi : la ligne redevient vide
    if (parseInt(li.dataset.so, 10)) { li.dataset.so = '0'; viderListes(li); calculer(); }
    clearTimeout(minuterie);
    var q = input.value.trim();
    if (q.length < 2) { liste.hidden = true; return; }
    minuterie = setTimeout(function() {
      var p = new URLSearchParams({ q: q, ruleset: 1, res_ids: resIds, limite: 12 });
      fetch(urlSorts + '?' + p.toString())
        .then(function(r) { return r.json(); })
        .then(function(items) {
          liste.innerHTML = '';
          if (!items.length) {
            liste.innerHTML = '<li class="autocomplete-empty">Aucun sort trouvé</li>';
          }
          items.forEach(function(it) {
            var e = document.createElement('li');
            e.className = 'autocomplete-item';
            e.textContent = it.label;
            e.addEventListener('mousedown', function(ev) { ev.preventDefault(); choisirSort(li, it); });
            liste.appendChild(e);
          });
          liste.hidden = false;
        })
        .catch(function() { liste.hidden = true; });
    }, 250);
  }

  function fermerRecherche(input) {
    setTimeout(function() { input.closest('.oc-sort').querySelector('.autocomplete-list').hidden = true; }, 150);
  }

  function viderListes(li) {
    li.querySelector('.oc-sort__liste').innerHTML = '<option value="0">— Choisir un sort —</option>';
    li.querySelector('.oc-sort__nls').placeholder = '';
  }

  // Sort choisi : ses listes de classe viennent du moteur (option listes= de possession-calcul.php)
  function choisirSort(li, it) {
    li.dataset.so = it.id;
    li.querySelector('.oc-sort__nom').value = it.label.replace(/ — .*$/, '');
    li.querySelector('.autocomplete-list').hidden = true;
    var d = new URLSearchParams();
    d.append('csrf_token', getCsrfToken());
    d.append('cat', form().elements['cat'].value);
    d.append('listes', it.id);
    fetch(urlCalcul, { method: 'POST', body: d })
      .then(function(r) { return r.json(); })
      .then(function(r) {
        var sel = li.querySelector('.oc-sort__liste');
        sel.innerHTML = '';
        var nivMax = <?= $est_conso ? (int)$consos[$cat]['niv_max'] : 0 ?>;
        var choisi = null;
        (r.listes || []).forEach(function(l) {
          var o = document.createElement('option');
          o.value = l.cla_id;
          o.dataset.nlsMin = l.nls_min;
          o.textContent = l.cla_nom + ' — niveau ' + l.niveau + (l.niveau > nivMax ? ' (trop haut)' : '');
          sel.appendChild(o);
          if (choisi === null && l.niveau <= nivMax) choisi = String(l.cla_id);
        });
        if (!sel.options.length) sel.innerHTML = '<option value="0">Aucune liste de classe</option>';
        if (choisi !== null) sel.value = choisi;
        changerListe(sel);
      });
  }

  function changerListe(sel) {
    var o = sel.options[sel.selectedIndex];
    var nls = sel.closest('.oc-sort').querySelector('.oc-sort__nls');
    nls.placeholder = o && o.dataset.nlsMin ? 'min. ' + o.dataset.nlsMin : '';
    nls.min = o && o.dataset.nlsMin ? o.dataset.nlsMin : 1;
    calculer();
  }

  function majBoutonAjout() {
    var b = document.getElementById('oc-sort-ajouter');
    if (b) b.disabled = lignesSorts().length >= nbMax;
  }

  function ajouterSort() {
    if (lignesSorts().length >= nbMax) return;
    var modele = document.getElementById('oc-sort-modele');
    document.getElementById('oc-sorts').appendChild(modele.content.cloneNode(true));
    majBoutonAjout();
    var l = lignesSorts();
    l[l.length - 1].querySelector('.oc-sort__nom').focus();
  }

  function retirerSort(btn) {
    var li = btn.closest('.oc-sort');
    if (lignesSorts().length <= 1) {
      li.dataset.so = '0';
      li.querySelector('.oc-sort__nom').value = '';
      viderListes(li);
    } else {
      li.remove();
    }
    majBoutonAjout();
    calculer();
  }

  function enregistrer() {
    if (!dernier || !dernier.ok) return;
    var d = donnees();
    d.append('action', 'enregistrerCompose');
    d.append('nom', nomManuel ? document.getElementById('oc-nom').value : '');
    var btn = document.getElementById('oc-enregistrer');
    btn.disabled = true;
    fetch(urlEnreg, { method: 'POST', body: d })
      .then(function(r) { return r.json(); })
      .then(function(r) {
        if (!r.ok) { notifier(r.erreur || 'Échec', 'erreur'); btn.disabled = false; return; }
        fermerModification();
        window.location.reload();
      })
      .catch(function(e) { notifier('Erreur réseau', 'erreur'); btn.disabled = false; });
  }

  window.ocForm = { calculer: calculer, changerBase: changerBase, nomSaisi: nomSaisi,
                    filtrerProprietes: filtrerProprietes, enregistrer: enregistrer,
                    chercherSort: chercherSort, fermerRecherche: fermerRecherche, changerListe: changerListe,
                    ajouterSort: ajouterSort, retirerSort: retirerSort };
  majCompatibilite();
  majBoutonAjout();
  lignesSorts().forEach(function(li) {
    var sel = li.querySelector('.oc-sort__liste');
    var o = sel.options[sel.selectedIndex];
    if (o && o.dataset.nlsMin) li.querySelector('.oc-sort__nls').placeholder = 'min. ' + o.dataset.nlsMin;
  });
  calculer();
})();
</script>
