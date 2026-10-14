<?php
// include/liste-parser.php — Listes dynamiques dans les textes (SP-PO1)
//
// Un texte (reg_texte, description du compendium…) peut afficher une liste d'équipements
// ou d'objets magiques TOUJOURS À JOUR en y posant un tag, sur le modèle de [[tab:slug]] :
//
//   [[liste:equipement]]
//   [[liste:equipement|famille=armes-de-guerre]]
//   [[liste:equipement|famille=armures-legeres,boucliers|source=DRS 3.5]]
//   [[liste:objet|famille=baguettes|tri=nom]]
//
// ENTITÉS     equipement  → dd_equipements       (familles : dd_categorie_equipement)
//             objet       → dd_objets_magiques   (familles : dd_categorie_objet_magique)
// PARAMÈTRES  (tous facultatifs, séparés par « | », valeurs multiples par « , »)
//   famille   slug(s) de catégorie. Pour l'équipement, la famille inclut ses descendants
//             (« armes » = courantes + de guerre + exotiques). Absent = toutes.
//   source    abréviation ou nom de ressource (« DRS 3.5 »). Absent = sources ACTIVES
//             de l'utilisateur, comme le compendium ; renseigné = ces sources-là, quelles
//             que soient les sources actives.
//   tri       ordre (défaut : ordre du livre puis nom) | nom | prix
//   titre     légende du tableau (défaut : nom de la famille ; « - » = aucune légende)
//
// Les références se font par SLUG, jamais par id : les ids diffèrent entre le local et OVH.
// Tag inconnu, famille inconnue ou entité inconnue → le tag s'affiche tel quel, échappé
// (même politique de dégradation que les tableaux).
//
// Visibilité : celle du compendium (global visible, supplément propre, supplément partagé),
// hors homebrew de campagne (xxx_camp_id NULL uniquement).
//
// Référence : doc/ARCHITECTURE_0_REFERENCE.md §9e

require_once __DIR__ . '/helpers.php';

define('LISTE_TAG_MOTIF', '\[\[liste:([a-z]+)((?:\|[^\[\]|]*)*)\]\]');
define('LISTE_MAX_LIGNES', 200);

// ============================================================
// 1. FORMATAGE PRIX / POIDS
// ============================================================

// Prix stocké en pièces de cuivre (1 po = 100 pc) → « 1 500 po », « 5 pa », « 4 pc ».
function formaterPrixPc(?int $pc, ?string $txt = null): string
{
  if ($txt !== null && $txt !== '') return $txt;
  if ($pc === null) return '—';
  if ($pc % 100 === 0) return number_format($pc / 100, 0, ',', "\u{00A0}") . "\u{00A0}po";
  if ($pc % 10 === 0)  return number_format($pc / 10, 0, ',', "\u{00A0}") . "\u{00A0}pa";
  return number_format($pc, 0, ',', "\u{00A0}") . "\u{00A0}pc";
}

// Poids stocké en grammes → « 500 g », « 2,5 kg ».
function formaterPoidsG(?int $g, ?string $txt = null): string
{
  if ($txt !== null && $txt !== '') return $txt;
  if ($g === null) return '—';
  if ($g < 1000) return $g . "\u{00A0}g";
  $kg = rtrim(rtrim(number_format($g / 1000, 3, ',', ''), '0'), ',');
  return $kg . "\u{00A0}kg";
}

// Saisie d'un formulaire → [valeur numérique|null, texte d'affichage|null].
//   « 5 po », « 1 500 po », « 12 pa », « 3 pc » → nombre ; tout autre texte
//   (« spécial », « +50 po », « Niveau × 5 po ») → texte tel quel ; vide → [null, null].
function parserPrixSaisie(string $saisie): array
{
  $t = trim(str_replace("\u{00A0}", ' ', $saisie));
  if ($t === '' || $t === '—') return [null, null];
  if (preg_match('/^(\d[\d ]*)\s*(po|pa|pc)$/u', $t, $m)):
    $n = (int)str_replace(' ', '', $m[1]);
    return [$n * ['po' => 100, 'pa' => 10, 'pc' => 1][$m[2]], null];
  endif;
  return [null, mb_substr($t, 0, 60)];
}

//   « 500 g », « 2,5 kg » → grammes ; tout autre texte → texte tel quel.
function parserPoidsSaisie(string $saisie): array
{
  $t = trim(str_replace("\u{00A0}", ' ', $saisie));
  if ($t === '' || $t === '—') return [null, null];
  if (preg_match('/^(\d+(?:[.,]\d+)?)\s*(kg|g)$/u', $t, $m)):
    $v = (float)str_replace(',', '.', $m[1]);
    return [(int)round($m[2] === 'kg' ? $v * 1000 : $v), null];
  endif;
  return [null, mb_substr($t, 0, 60)];
}

// ============================================================
// 2. CATÉGORIES D'ÉQUIPEMENT
// ============================================================
// Arbre chargé une fois par ruleset et par requête (table de quelques dizaines de lignes).
// Retourne :
//   'noeuds'  → [cae_id => ligne]
//   'slugs'   → [cae_slug => cae_id]
//   'enfants' → [parent_id (0 = racine) => [cae_id,…]] triés par ordre puis nom
//   'rang'    → [cae_id => position dans le parcours en profondeur]

function catEquipementArbre(PDO $db, int $ruleset_id): array
{
  static $cache = [];
  if (isset($cache[$ruleset_id])) return $cache[$ruleset_id];

  $stmt = $db->prepare('
    SELECT * FROM dd_categorie_equipement
    WHERE  cae_ruleset_var_id = ?
    ORDER  BY cae_ordre, cae_nom
  ');
  $stmt->execute([$ruleset_id]);

  $arbre = ['noeuds' => [], 'slugs' => [], 'enfants' => [], 'rang' => []];
  foreach ($stmt->fetchAll() as $c):
    $id = (int)$c['cae_id'];
    $arbre['noeuds'][$id]            = $c;
    $arbre['slugs'][$c['cae_slug']]  = $id;
    $arbre['enfants'][(int)$c['cae_cae_id']][] = $id;
  endforeach;

  $rang = 0;
  $visiter = function (int $pid) use (&$visiter, &$arbre, &$rang): void {
    foreach ($arbre['enfants'][$pid] ?? [] as $id):
      $arbre['rang'][$id] = $rang++;
      $visiter($id);
    endforeach;
  };
  $visiter(0);

  $cache[$ruleset_id] = $arbre;
  return $arbre;
}

// Ids d'une catégorie et de tous ses descendants.
function catEquipementDescendants(array $arbre, int $id): array
{
  $ids = [$id];
  foreach ($arbre['enfants'][$id] ?? [] as $enfant):
    $ids = array_merge($ids, catEquipementDescendants($arbre, $enfant));
  endforeach;
  return $ids;
}

// Chaîne d'ancêtres, de la racine à la catégorie incluse : [id,…].
function catEquipementChaine(array $arbre, int $id): array
{
  $chaine = [];
  $garde  = 0;
  while ($id && isset($arbre['noeuds'][$id]) && $garde++ < 10):
    array_unshift($chaine, $id);
    $id = (int)$arbre['noeuds'][$id]['cae_cae_id'];
  endwhile;
  return $chaine;
}

// Définition des colonnes : celle de la catégorie, sinon du plus proche ancêtre qui en a une.
// [{k, l, a?, liste?},…] — k = 'prix' | 'poids' (colonnes de dd_equipements) ou clé d'attribut.
function catEquipementColonnes(array $arbre, int $id): array
{
  foreach (array_reverse(catEquipementChaine($arbre, $id)) as $cid):
    $json = $arbre['noeuds'][$cid]['cae_colonnes'] ?? null;
    if ($json === null || $json === '') continue;
    $def = json_decode($json, true);
    if (is_array($def)) return $def;
  endforeach;
  return [['k' => 'prix', 'l' => 'Prix', 'a' => 'r'], ['k' => 'poids', 'l' => 'Poids', 'a' => 'r']];
}

// Valeur affichée d'une colonne pour un équipement.
function equipementValeurColonne(array $eqt, array $attrs, string $k): string
{
  if ($k === 'prix')  return formaterPrixPc(isset($eqt['eqt_prix_pc']) ? (int)$eqt['eqt_prix_pc'] : null, $eqt['eqt_prix_txt'] ?? null);
  if ($k === 'poids') return formaterPoidsG(isset($eqt['eqt_poids_g']) ? (int)$eqt['eqt_poids_g'] : null, $eqt['eqt_poids_txt'] ?? null);
  $v = trim((string)($attrs[$k] ?? ''));
  return $v === '' ? '—' : $v;
}

function equipementAttributs(array $eqt): array
{
  $a = json_decode((string)($eqt['eqt_attributs'] ?? ''), true);
  return is_array($a) ? $a : [];
}

// ============================================================
// 3. FILTRES COMMUNS (sources, visibilité)
// ============================================================

// Sources demandées par le paramètre source= → ids de ressources du ruleset.
// null = pas de filtre (aucun paramètre, et aucune source active connue).
function listeSourcesIds(PDO $db, array $noms, int $ruleset_id): ?array
{
  if (empty($noms)):
    $actifs = getActiveResIds($db, $ruleset_id);
    return empty($actifs) ? null : $actifs;   // jamais d'IN () vide
  endif;

  $ids = [];
  $stmt = $db->prepare('
    SELECT res_id FROM dd_ressources
    WHERE  res_ruleset_var_id = ?
      AND (LOWER(res_abreviation) = LOWER(?) OR LOWER(res_nom) = LOWER(?))
  ');
  foreach ($noms as $nom):
    $stmt->execute([$ruleset_id, $nom, $nom]);
    foreach ($stmt->fetchAll(PDO::FETCH_COLUMN) as $id) $ids[] = (int)$id;
  endforeach;
  return $ids;   // peut être vide : source inconnue → aucune ligne
}

// Même règle que compendium-liste.php (supplément utilisateur, SP-C2), sans « brouillons ».
// $owner = res.res_j_id, $pub / $vis = champs _public / _visible de l'entité.
function listeClauseVisibilite(string $owner, string $pub, string $vis, array &$params): string
{
  $uid     = (int)($_SESSION['j_id'] ?? 0);
  $editeur = function_exists('canEditCompendium') && canEditCompendium();
  $globaux = $editeur ? '1 = 1' : "$vis = 1";
  $params[] = $uid;
  return "(($owner IS NULL AND $globaux) OR ($owner = ? AND $vis = 1) OR ($pub = 1 AND $vis = 1))";
}

// ============================================================
// 4. PARAMÈTRES DU TAG
// ============================================================

function listeParametres(string $bruts): array
{
  $p = ['famille' => [], 'source' => [], 'tri' => '', 'titre' => ''];
  foreach (array_slice(explode('|', $bruts), 1) as $paire):
    $kv = explode('=', $paire, 2);
    if (count($kv) !== 2) continue;
    $cle = strtolower(trim($kv[0]));
    $val = trim($kv[1]);
    if ($val === '') continue;
    if ($cle === 'famille' || $cle === 'source'):
      $p[$cle] = array_values(array_filter(array_map('trim', explode(',', $val)), 'strlen'));
    elseif ($cle === 'tri' || $cle === 'titre'):
      $p[$cle] = $val;
    endif;
  endforeach;
  return $p;
}

// ============================================================
// 5. RENDU HTML
// ============================================================

function listeHtmlTable(string $caption, array $entetes, array $lignes, string $note = ''): string
{
  // $entetes : [[label, align],…] ; $lignes : [['section'=>label] | ['cellules'=>[html,…]],…]
  $nb   = count($entetes);
  $html = '<figure class="reg-tab reg-liste" data-detail-base="' . BASE_URL . '/include/ajax/detail-pp/">';
  if ($caption !== ''):
    $html .= '<figcaption class="reg-tab__titre">' . h($caption) . '</figcaption>';
  endif;
  $html .= '<div class="reg-tab__scroll"><table class="reg-tab__table"><thead><tr>';
  foreach ($entetes as [$label, $align]):
    $html .= '<th' . ($align !== 'left' ? ' class="reg-tab__c--' . $align . '"' : '') . '>' . h($label) . '</th>';
  endforeach;
  $html .= '</tr></thead><tbody>';
  foreach ($lignes as $ligne):
    if (isset($ligne['section'])):
      $html .= '<tr class="reg-tab__section"><td colspan="' . $nb . '">' . h($ligne['section']) . '</td></tr>';
      continue;
    endif;
    $html .= '<tr>';
    foreach ($ligne['cellules'] as $i => $cel):
      $align = $entetes[$i][1];
      $html .= '<td' . ($align !== 'left' ? ' class="reg-tab__c--' . $align . '"' : '') . '>' . $cel . '</td>';
    endforeach;
    $html .= '</tr>';
  endforeach;
  $html .= '</tbody></table></div>';
  if ($note !== '') $html .= '<p class="reg-tab__note">' . $note . '</p>';
  return $html . '</figure>';
}

function listeLien(string $type, int $id, string $nom): string
{
  return '<span class="mo-lien" data-type="' . h($type) . '" data-id="' . $id . '">' . h($nom) . '</span>';
}

function listeAlign(?string $a): string
{
  return ['l' => 'left', 'c' => 'center', 'r' => 'right'][$a ?? 'l'] ?? 'left';
}

// ------------------------------------------------------------
// 5a. Équipement
// ------------------------------------------------------------
function listeRendreEquipement(PDO $db, array $p, int $ruleset_id): ?string
{
  $arbre = catEquipementArbre($db, $ruleset_id);

  // Familles demandées → ensemble de bases ; absent = les racines
  $bases = [];
  foreach ($p['famille'] as $slug):
    if (!isset($arbre['slugs'][$slug])) return null;
    $bases[] = $arbre['slugs'][$slug];
  endforeach;
  if (empty($bases)) $bases = $arbre['enfants'][0] ?? [];

  $cae_ids = [];
  foreach ($bases as $b) $cae_ids = array_merge($cae_ids, catEquipementDescendants($arbre, $b));
  if (empty($cae_ids)) return '<p class="reg-liste__vide">Aucun élément.</p>';

  $params = [$ruleset_id];
  $where  = ['eqt.eqt_ruleset_var_id = ?', 'eqt.eqt_camp_id IS NULL'];

  $where[] = 'eqt.eqt_cae_id IN (' . resIdsPlaceholders($cae_ids) . ')';
  $params  = array_merge($params, $cae_ids);

  $res_ids = listeSourcesIds($db, $p['source'], $ruleset_id);
  if ($res_ids !== null):
    if (empty($res_ids)) return '<p class="reg-liste__vide">Aucun élément.</p>';
    $where[] = 'eqt.eqt_res_id IN (' . resIdsPlaceholders($res_ids) . ')';
    $params  = array_merge($params, $res_ids);
  endif;

  $where[] = listeClauseVisibilite('res.res_j_id', 'eqt.eqt_public', 'eqt.eqt_visible', $params);

  $stmt = $db->prepare('
    SELECT eqt.*, res.res_abreviation
    FROM   dd_equipements eqt
    LEFT JOIN dd_ressources res ON res.res_id = eqt.eqt_res_id
    WHERE  ' . implode(' AND ', $where) . '
    LIMIT  2000
  ');
  $stmt->execute($params);
  $rows = $stmt->fetchAll();
  if (empty($rows)) return '<p class="reg-liste__vide">Aucun élément.</p>';

  // Ordre : parcours de l'arbre, puis ordre du livre, puis nom (ou tri demandé)
  $tri = $p['tri'];
  usort($rows, function ($a, $b) use ($arbre, $tri) {
    $ra = $arbre['rang'][(int)$a['eqt_cae_id']] ?? 0;
    $rb = $arbre['rang'][(int)$b['eqt_cae_id']] ?? 0;
    if ($ra !== $rb) return $ra <=> $rb;
    if ($tri === 'nom') return strcasecmp($a['eqt_nom'], $b['eqt_nom']);

    // Prix : sans prix chiffré en dernier ; sinon l'ordre du livre
    $ka = $tri === 'prix' ? ($a['eqt_prix_pc'] === null ? PHP_INT_MAX : (int)$a['eqt_prix_pc']) : (int)$a['eqt_ordre'];
    $kb = $tri === 'prix' ? ($b['eqt_prix_pc'] === null ? PHP_INT_MAX : (int)$b['eqt_prix_pc']) : (int)$b['eqt_ordre'];
    if ($ka !== $kb) return $ka <=> $kb;
    return strcasecmp($a['eqt_nom'], $b['eqt_nom']);
  });

  $total = count($rows);
  $rows  = array_slice($rows, 0, LISTE_MAX_LIGNES);

  $sources = array_unique(array_column($rows, 'res_abreviation'));
  $avec_source = count($sources) > 1;

  // Regroupement : un tableau par jeu de colonnes, des sections par catégorie
  $tableaux = [];
  foreach ($rows as $r):
    $cid  = (int)$r['eqt_cae_id'];
    $cols = catEquipementColonnes($arbre, $cid);
    $sig  = md5(json_encode($cols));
    $base = $bases[0];
    foreach (array_reverse(catEquipementChaine($arbre, $cid)) as $anc):
      if (in_array($anc, $bases, true)) { $base = $anc; break; }
    endforeach;
    $tableaux[$sig]['cols']  ??= $cols;
    $tableaux[$sig]['bases'][$base] = true;
    $tableaux[$sig]['rows'][] = [$r, $cid, $base];
  endforeach;

  $html  = '';
  $multi = count($tableaux) > 1;
  foreach ($tableaux as $t):
    $cols = array_values(array_filter($t['cols'], fn($c) => ($c['liste'] ?? true) !== false));
    $entetes = [['Nom', 'left']];
    foreach ($cols as $c) $entetes[] = [(string)$c['l'], listeAlign($c['a'] ?? null)];
    if ($avec_source) $entetes[] = ['Source', 'left'];

    // Sections : chemin sous la base ; avec une seule base on l'omet
    $une_base = count($bases) === 1;
    $lignes   = [];
    $section_prec = null;
    foreach ($t['rows'] as [$r, $cid, $base]):
      $chaine = catEquipementChaine($arbre, $cid);
      $pos    = array_search($base, $chaine, true);
      $noms   = [];
      foreach (array_slice($chaine, $une_base ? $pos + 1 : $pos) as $anc) $noms[] = $arbre['noeuds'][$anc]['cae_nom'];
      $label = implode(' › ', $noms);
      if ($label !== '' && $label !== $section_prec):
        $lignes[] = ['section' => $label];
      endif;
      $section_prec = $label;

      $attrs = equipementAttributs($r);
      $cel   = [listeLien('equipement', (int)$r['eqt_id'], $r['eqt_nom'])];
      foreach ($cols as $c) $cel[] = h(equipementValeurColonne($r, $attrs, (string)$c['k']));
      if ($avec_source) $cel[] = h((string)$r['res_abreviation']);
      $lignes[] = ['cellules' => $cel];
    endforeach;

    $caption = $p['titre'];
    if ($caption === '' && ($multi || count($bases) === 1)):
      $b = array_key_first($t['bases']);
      $caption = (string)$arbre['noeuds'][$b]['cae_nom'];
    endif;
    $html .= listeHtmlTable($p['titre'] === '-' ? '' : $caption, $entetes, $lignes, '');
  endforeach;

  if ($total > LISTE_MAX_LIGNES):
    $html .= '<p class="reg-liste__plus">' . ($total - LISTE_MAX_LIGNES) . ' autre(s) ligne(s) — '
           . '<a href="' . BASE_URL . '/compendium/equipements.php">voir tout dans le compendium</a>.</p>';
  endif;
  return $html;
}

// ------------------------------------------------------------
// 5b. Objets magiques
// ------------------------------------------------------------
function listeRendreObjet(PDO $db, array $p, int $ruleset_id): ?string
{
  $params = [$ruleset_id];
  $where  = ['om.om_ruleset_var_id = ?', 'om.om_camp_id IS NULL'];

  if (!empty($p['famille'])):
    $stmt = $db->prepare('SELECT com_id FROM dd_categorie_objet_magique WHERE com_slug = ? AND com_ruleset_var_id = ?');
    $com_ids = [];
    foreach ($p['famille'] as $slug):
      $stmt->execute([$slug, $ruleset_id]);
      $id = $stmt->fetchColumn();
      if ($id === false) return null;
      $com_ids[] = (int)$id;
    endforeach;
    $where[] = 'om.om_com_id IN (' . resIdsPlaceholders($com_ids) . ')';
    $params  = array_merge($params, $com_ids);
  else:
    // Comme le compendium : les « propriétés spéciales » (DD3.5) ne sont pas des objets
    $where[] = '(com.com_est_propriete = 0 OR com.com_est_propriete IS NULL)';
  endif;

  $res_ids = listeSourcesIds($db, $p['source'], $ruleset_id);
  if ($res_ids !== null):
    if (empty($res_ids)) return '<p class="reg-liste__vide">Aucun élément.</p>';
    $where[] = 'om.om_res_id IN (' . resIdsPlaceholders($res_ids) . ')';
    $params  = array_merge($params, $res_ids);
  endif;

  $where[] = listeClauseVisibilite('res.res_j_id', 'om.om_public', 'om.om_visible', $params);

  $ordre = $p['tri'] === 'prix' ? 'om.om_prix IS NULL, om.om_prix, om.om_nom' : 'com.com_nom, om.om_nom';
  $stmt = $db->prepare('
    SELECT om.om_id, om.om_nom, om.om_prix, om.om_harmonisation, om.om_com_id,
           com.com_nom, omr.omr_nom, res.res_abreviation
    FROM   dd_objets_magiques om
    LEFT JOIN dd_categorie_objet_magique com ON com.com_id = om.om_com_id
    LEFT JOIN dd_objets_magiques_rarete  omr ON omr.omr_id = om.om_rarete
    LEFT JOIN dd_ressources              res ON res.res_id = om.om_res_id
    WHERE  ' . implode(' AND ', $where) . '
    ORDER  BY ' . $ordre . '
    LIMIT  2000
  ');
  $stmt->execute($params);
  $rows = $stmt->fetchAll();
  if (empty($rows)) return '<p class="reg-liste__vide">Aucun élément.</p>';

  $total = count($rows);
  $rows  = array_slice($rows, 0, LISTE_MAX_LIGNES);

  $categories  = array_unique(array_column($rows, 'com_nom'));
  $par_section = count($categories) > 1 && $p['tri'] !== 'prix';
  $avec_source = count(array_unique(array_column($rows, 'res_abreviation'))) > 1;
  $dd2024      = $ruleset_id !== 1;

  $entetes = [['Nom', 'left']];
  if ($dd2024):
    $entetes[] = ['Rareté', 'left'];
    $entetes[] = ['Harmonisation', 'center'];
  else:
    $entetes[] = ['Prix', 'right'];
  endif;
  if ($avec_source) $entetes[] = ['Source', 'left'];

  $lignes = [];
  $prec   = null;
  foreach ($rows as $r):
    if ($par_section && $r['com_nom'] !== $prec):
      $lignes[] = ['section' => (string)$r['com_nom']];
    endif;
    $prec = $r['com_nom'];

    $cel = [listeLien('objet', (int)$r['om_id'], $r['om_nom'])];
    if ($dd2024):
      $cel[] = h((string)($r['omr_nom'] ?? '—'));
      $cel[] = (int)$r['om_harmonisation'] === 1 ? 'Oui' : '—';
    else:
      $cel[] = !empty($r['om_prix']) ? h(number_format((int)$r['om_prix'], 0, ',', "\u{00A0}") . "\u{00A0}po") : '—';
    endif;
    if ($avec_source) $cel[] = h((string)$r['res_abreviation']);
    $lignes[] = ['cellules' => $cel];
  endforeach;

  $caption = $p['titre'];
  if ($caption === '' && count($categories) === 1) $caption = (string)reset($categories);

  $html = listeHtmlTable($p['titre'] === '-' ? '' : $caption, $entetes, $lignes);
  if ($total > LISTE_MAX_LIGNES):
    $html .= '<p class="reg-liste__plus">' . ($total - LISTE_MAX_LIGNES) . ' autre(s) ligne(s) — '
           . '<a href="' . BASE_URL . '/compendium/objets.php">voir tout dans le compendium</a>.</p>';
  endif;
  return $html;
}

// ============================================================
// 6. RÉSOLUTION DU TAG [[liste:…]]
// ============================================================
// Mêmes deux passes que resoudreTagsTableaux() : un <figure> n'a pas sa place dans un
// <p>, donc le tag seul dans un paragraphe remplace le paragraphe entier.

function resoudreTagsListes(PDO $db, ?string $html, int $ruleset_id): string
{
  $html = (string)$html;
  if ($html === '' || stripos($html, '[[liste:') === false) return $html;

  $rendre = function (string $entite, string $bruts) use ($db, $ruleset_id): ?string {
    $p = listeParametres($bruts);
    return match ($entite) {
      'equipement' => listeRendreEquipement($db, $p, $ruleset_id),
      'objet'      => listeRendreObjet($db, $p, $ruleset_id),
      default      => null,
    };
  };

  $html = preg_replace_callback(
    '/<p\b[^>]*>\s*(?:<strong>\s*)?' . LISTE_TAG_MOTIF . '(?:\s*<\/strong>)?\s*<\/p>/i',
    function ($m) use ($rendre) {
      $out = $rendre($m[1], $m[2]);
      // Crochets en entités : la passe 2 ne doit pas re-matcher le tag déjà signalé
      return $out ?? '<p class="reg-tab__manquant">'
        . str_replace('[', '&#91;', h('[[liste:' . $m[1] . $m[2] . ']]')) . '</p>';
    },
    $html
  );

  return preg_replace_callback(
    '/' . LISTE_TAG_MOTIF . '/i',
    function ($m) use ($rendre) {
      $out = $rendre($m[1], $m[2]);
      return $out ?? '<span class="reg-tab__manquant">' . h($m[0]) . '</span>';
    },
    $html
  );
}
