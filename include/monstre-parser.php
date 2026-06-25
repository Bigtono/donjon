<?php
// include/monstre-parser.php  v3
// ============================================================
// Moteur d'analyse et de rendu du bloc de stats d'un monstre.
// Entree  : mo_stats TEXTE BRUT. Sortie : HTML formate + liens cliquables.
//
// TAGS EXPLICITES (resolus en pre-passe) :
//   #Nom don#       -> lien vers le don par nom
//   $Nom sort$      -> lien vers le sort par nom
//   &Nom objet&     -> lien vers l'objet magique par nom
//   @id@            -> lien vers la regle (dd_regles, tout type)
//   %id%            -> lien vers le glossaire (dd_regles, type=glossaire)
//
// PARSING AUTOMATIQUE DD2024 (description des pouvoirs + labels) :
//   - Priorite : objets magiques / équipement > sorts > glossaire (liaison par nom)
//   - Le nom du pouvoir lui-meme n'est jamais parse automatiquement.
//
// DD3.5 : labels avec ":" ; parsing automatique a completer ulterieurement.
// ============================================================

require_once __DIR__ . '/helpers.php';

// ============================================================
// 1. TYPES LIABLES (index base)
// ============================================================

function typesLiablesMonstre(): array
{
  return [
    'don' => [
      'table' => 'dd_dons', 'id' => 'do_id', 'nom' => 'do_nom',
      'ruleset' => 'do_ruleset_var_id', 'res' => 'do_res_id', 'camp' => 'do_camp_id',
    ],
    'sort' => [
      'table' => 'dd_sorts', 'id' => 'so_id', 'nom' => 'so_nom',
      'ruleset' => 'so_ruleset_var_id', 'res' => 'so_res_id', 'camp' => 'so_camp_id',
    ],
    // Équipement / objets magiques — liaison auto dans la ligne "Equipement"
    // (label_gras DD2024) et dans les blocs Actions (texte des pouvoirs),
    // au même titre que les sorts et le glossaire (cf. construireIndexAuto()).
    'objet' => [
      'table' => 'dd_objets_magiques', 'id' => 'om_id', 'nom' => 'om_nom',
      'ruleset' => 'om_ruleset_var_id', 'res' => 'om_res_id', 'camp' => 'om_camp_id',
    ],
  ];
}

// ============================================================
// 2. LABELS PAR RULESET
// ============================================================

function labelsDD35(): array
{
  return [
    "Classe d'armure", 'Des de vie', 'Initiative', 'Vitesse de deplacement',
    'Attaque de base/lutte', 'Attaque a outrance', 'Attaque',
    'Espace occupe/allonge', 'Attaques speciales', 'Particularites',
    'Jets de sauvegarde', 'Caracteristiques', 'Competences', 'Dons',
    'Environnement', 'Organisation sociale', 'Facteur de puissance', 'Tresor',
    'Alignement', 'Evolution possible', 'Ajustement de niveau', 'Type',
  ];
}

function labelsInlineDD2024(): array
{
  return ['CA', 'Pv', 'Vitesse', 'Initiative'];
}

function labelsGrasDD2024(): array
{
  return [
    'Sauvegardes', 'Resistances', 'Immunites', 'Vulnerabilites', 'Sens', 'Langues', 'FP',
    'Competences', 'Dons', 'Maitrises', 'Bonus de maitrise', 'Equipement',
  ];
}

// Labels pour lesquels la liaison automatique (glossaire/regles/sorts) est exclue.
// Ces labels contiennent des valeurs structurees (abreviations, nombres) qui
// produiraient de faux positifs s'ils etaient passes a resoudreTagsExplicites/lierAuto.
function labelsGrasSansLiaisonDD2024(): array
{
  return ['Sauvegardes'];
}

function sectionsTitresDD2024(): array
{
  return [
    'Traits', 'Actions', 'Actions legendaires', 'Actions bonus',
    'Reactions', 'Repaire', 'Actions de repaire', 'Actions regionales',
    'Pouvoirs',
  ];
}

define('CARAC_DD2024', ['For', 'Dex', 'Con', 'Int', 'Sag', 'Cha']);

// ============================================================
// 3. NORMALISATION
// ============================================================

function normaliserNomMonstre(string $s): string
{
  $s = mb_strtolower(trim($s), 'UTF-8');
  $s = preg_replace("/[\x{2018}\x{2019}\x{201A}\x{201B}`\x{00B4}]/u", "'", $s);
  $acc = [
    "\xc3\xa0"=>'a',"\xc3\xa1"=>'a',"\xc3\xa2"=>'a',"\xc3\xa4"=>'a',
    "\xc3\xa8"=>'e',"\xc3\xa9"=>'e',"\xc3\xaa"=>'e',"\xc3\xab"=>'e',
    "\xc3\xac"=>'i',"\xc3\xad"=>'i',"\xc3\xae"=>'i',"\xc3\xaf"=>'i',
    "\xc3\xb2"=>'o',"\xc3\xb3"=>'o',"\xc3\xb4"=>'o',"\xc3\xb6"=>'o',
    "\xc3\xb9"=>'u',"\xc3\xba"=>'u',"\xc3\xbb"=>'u',"\xc3\xbc"=>'u',
    "\xc3\xa7"=>'c',"\xc3\xb1"=>'n',
    "\xc5\x93"=>'oe',"\xc3\xa6"=>'ae',"\xc3\xbd"=>'y',"\xc3\xbf"=>'y',
  ];
  $s = str_replace(array_keys($acc), array_values($acc), $s);
  $s = preg_replace('/\s+/', ' ', $s);
  return trim($s);
}

function maxMotsIndex(array $cles): int
{
  $max = 1;
  foreach ($cles as $cle):
    $n = substr_count($cle, ' ') + 1;
    if ($n > $max) $max = $n;
  endforeach;
  return $max;
}

// ============================================================
// 4. CHARGEMENT DU DICTIONNAIRE
// ============================================================

// Charge sorts + dons via typesLiablesMonstre().
// Charge glossaire separement (dd_regles, reg_type='glossaire').
// Retourne ['sort'=>[...], 'don'=>[...], 'glossaire'=>[...]]
function chargerIndexMonstre(PDO $db, int $ruleset_id, array $res_ids): array
{
  $res_ids = array_values(array_filter(array_map('intval', $res_ids)));
  $index   = [];

  foreach (typesLiablesMonstre() as $type => $cfg):
    $where  = [$cfg['ruleset'] . ' = ?'];
    $params = [$ruleset_id];

    if ($cfg['camp'] !== null):
      $where[] = $cfg['camp'] . ' IS NULL';
    endif;

    if (!empty($res_ids)):
      $ph      = implode(',', array_fill(0, count($res_ids), '?'));
      $where[] = $cfg['res'] . ' IN (' . $ph . ')';
      foreach ($res_ids as $r) $params[] = $r;
    elseif ($cfg['res'] !== null):
      // Aucune source active -> dictionnaire vide pour ce type
      $index[$type] = [];
      continue;
    endif;

    $sql  = 'SELECT ' . $cfg['id'] . ' AS id, ' . $cfg['nom'] . ' AS nom FROM ' . $cfg['table'];
    $sql .= ' WHERE ' . implode(' AND ', $where);
    $stmt = $db->prepare($sql);
    $stmt->execute($params);

    $noms = [];
    foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $row):
      $cle = normaliserNomMonstre((string)$row['nom']);
      if ($cle !== '' && !isset($noms[$cle])):
        $noms[$cle] = ['id' => (int)$row['id'], 'nom' => (string)$row['nom']];
      endif;
    endforeach;
    $index[$type] = $noms;
  endforeach;

  // Glossaire : reg_type='glossaire', scope ruleset, visible, global (camp IS NULL)
  $stmt = $db->prepare("
    SELECT reg_id AS id, reg_nom AS nom
    FROM   dd_regles
    WHERE  reg_ruleset_var_id = ?
      AND  reg_type = 'glossaire'
      AND  reg_visible = 1
      AND  (reg_camp_id IS NULL)
    ORDER  BY reg_nom
  ");
  $stmt->execute([$ruleset_id]);
  $glos = [];
  foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $row):
    $cle = normaliserNomMonstre((string)$row['nom']);
    if ($cle !== '' && !isset($glos[$cle])):
      $glos[$cle] = ['id' => (int)$row['id'], 'nom' => (string)$row['nom']];
    endif;
  endforeach;
  $index['glossaire'] = $glos;

  return $index;
}

// Index fusionne sorts + objets + glossaire pour la detection automatique en texte libre.
function construireIndexAuto(array $index): array
{
  $auto = [];
  // Priorite : objet > sort > glossaire
  foreach (['objet', 'sort', 'glossaire'] as $type):
    foreach (($index[$type] ?? []) as $cle => $info):
      if (!isset($auto[$cle])):
        $auto[$cle] = ['type' => $type, 'id' => $info['id'], 'nom' => $info['nom']];
      endif;
    endforeach;
  endforeach;
  return $auto;
}

// ============================================================
// 5. PRE-PASSE : RESOLUTION DES TAGS EXPLICITES
// ============================================================
// Remplace les tags avant toute autre analyse :
//   #Nom#   -> don par nom
//   $Nom$   -> sort par nom
//   @id@    -> regle par id (tout type)
//   %id%    -> glossaire par id

function resoudreTagsExplicites(
  string $txt, PDO $db, array $index, int $ruleset_id, array &$rapport
): string {
  // @id@ et %id% : resolution directe par id en base
  $txt = preg_replace_callback('/@(\d+)@/', function ($m) use ($db, &$rapport) {
    $id   = (int)$m[1];
    $stmt = $db->prepare('SELECT reg_nom FROM dd_regles WHERE reg_id = ? AND reg_visible = 1');
    $stmt->execute([$id]);
    $nom = $stmt->fetchColumn();
    if (!$nom) return h($m[0]); // tag invalide : afficher tel quel
    $rapport['liens']++;
    $rapport['par_type']['regle'] = ($rapport['par_type']['regle'] ?? 0) + 1;
    return '<span class="mo-lien" data-type="regle" data-id="' . $id . '">'
         . h((string)$nom) . '</span>';
  }, $txt);

  $txt = preg_replace_callback('/%(\d+)%/', function ($m) use ($db, &$rapport) {
    $id   = (int)$m[1];
    $stmt = $db->prepare(
      "SELECT reg_nom FROM dd_regles WHERE reg_id = ? AND reg_type = 'glossaire' AND reg_visible = 1"
    );
    $stmt->execute([$id]);
    $nom = $stmt->fetchColumn();
    if (!$nom) return h($m[0]);
    $rapport['liens']++;
    $rapport['par_type']['glossaire'] = ($rapport['par_type']['glossaire'] ?? 0) + 1;
    return '<span class="mo-lien" data-type="glossaire" data-id="' . $id . '">'
         . h((string)$nom) . '</span>';
  }, $txt);

  // #Nom# : don par nom (insensible casse/accents)
  $txt = preg_replace_callback('/#([^#\n]+)#/', function ($m) use ($index, &$rapport) {
    $cle  = normaliserNomMonstre($m[1]);
    $info = $index['don'][$cle] ?? null;
    if (!$info) return h($m[1]); // non trouve : afficher le nom sans tag
    $rapport['liens']++;
    $rapport['par_type']['don'] = ($rapport['par_type']['don'] ?? 0) + 1;
    return '<span class="mo-lien" data-type="don" data-id="' . $info['id'] . '">'
         . h($m[1]) . '</span>';
  }, $txt);

  // $Nom$ : sort par nom
  $txt = preg_replace_callback('/\$([^\$\n]+)\$/', function ($m) use ($index, &$rapport) {
    $cle  = normaliserNomMonstre($m[1]);
    $info = $index['sort'][$cle] ?? null;
    if (!$info) return h($m[1]);
    $rapport['liens']++;
    $rapport['par_type']['sort'] = ($rapport['par_type']['sort'] ?? 0) + 1;
    return '<span class="mo-lien" data-type="sort" data-id="' . $info['id'] . '">'
         . h($m[1]) . '</span>';
  }, $txt);

  // &Nom& : objet magique par nom
  $txt = preg_replace_callback('/&([^&\n]+)&/', function ($m) use ($index, &$rapport) {
    $cle  = normaliserNomMonstre($m[1]);
    $info = $index['objet'][$cle] ?? null;
    if (!$info) return h($m[1]);
    $rapport['liens']++;
    $rapport['par_type']['objet'] = ($rapport['par_type']['objet'] ?? 0) + 1;
    return '<span class="mo-lien" data-type="objet" data-id="' . $info['id'] . '">'
         . h($m[1]) . '</span>';
  }, $txt);

  return $txt;
}

// ============================================================
// 6. MOTEUR DE LIAISON AUTOMATIQUE (sorts + glossaire)
// ============================================================

define('MO_LONGUEUR_MIN', 4);

// $txt peut déjà contenir des <span class="mo-lien">...</span> insérés par
// resoudreTagsExplicites() (chaînage systématique resoudreTagsExplicites()
// puis lierAuto()/lierSorts()/lierDons() dans formaterBlocDD2024()). Ces
// blocs sont déjà du HTML sûr (construit via h() au moment de leur
// création) : ils ne doivent ni être re-tokenisés (les mots de l'attribut
// data-type/data-id pourraient matcher l'index par accident) ni être
// re-échappés (h() transformerait leurs chevrons en entités, faisant
// apparaître le tag littéralement à l'écran). On les protège donc en les
// faisant transiter tels quels, et on n'applique le tokenizer qu'aux
// segments de texte brut situés entre eux.
function lierAvecIndex(string $txt, int $maxWords, callable $resolve, array &$rapport): string
{
  if (!preg_match('/<span\b[^>]*\bclass="mo-lien"[^>]*>.*?<\/span>/su', $txt)):
    return lierSegmentBrut($txt, $maxWords, $resolve, $rapport);
  endif;
  return lierAvecSegmentsProteges($txt, $maxWords, $resolve, $rapport);
}

function lierAvecSegmentsProteges(string $txt, int $maxWords, callable $resolve, array &$rapport): string
{
  $segments = preg_split(
    '/(<span\b[^>]*\bclass="mo-lien"[^>]*>.*?<\/span>)/su',
    $txt, -1, PREG_SPLIT_DELIM_CAPTURE
  );
  $out = '';
  foreach ($segments as $seg):
    $out .= str_starts_with($seg, '<span')
      ? $seg
      : lierSegmentBrut($seg, $maxWords, $resolve, $rapport);
  endforeach;
  return $out;
}

function lierSegmentBrut(string $txt, int $maxWords, callable $resolve, array &$rapport): string
{
  if ($maxWords < 1 || $txt === '') return h($txt);
  if (!preg_match_all('/[\p{L}\p{N}\']+/u', $txt, $mm, PREG_OFFSET_CAPTURE)):
    return h($txt);
  endif;

  $mots = $mm[0]; $n = count($mots);
  $out = ''; $curseur = 0; $i = 0;

  while ($i < $n):
    $trouve = null;
    $kmax   = min($maxWords, $n - $i);
    for ($k = $kmax; $k >= 1; $k--):
      $debut   = $mots[$i][1];
      $dernier = $mots[$i + $k - 1];
      $fin     = $dernier[1] + strlen($dernier[0]);
      $brut    = substr($txt, $debut, $fin - $debut);
      $cle     = normaliserNomMonstre($brut);
      if (mb_strlen($cle) < MO_LONGUEUR_MIN) continue;
      if (!preg_match('/\p{L}/u', $cle)) continue;
      $cible = $resolve($cle);
      if ($cible !== null):
        $trouve = ['debut'=>$debut,'fin'=>$fin,'brut'=>$brut,'cible'=>$cible];
        $i += $k;
        break;
      endif;
    endfor;
    if ($trouve === null): $i++; continue; endif;
    if ($trouve['debut'] > $curseur):
      $out .= h(substr($txt, $curseur, $trouve['debut'] - $curseur));
    endif;
    $c    = $trouve['cible'];
    $out .= '<span class="mo-lien" data-type="' . h($c['type'])
          . '" data-id="' . (int)$c['id'] . '">' . h($trouve['brut']) . '</span>';
    $curseur = $trouve['fin'];
    $rapport['liens']++;
    $rapport['par_type'][$c['type']] = ($rapport['par_type'][$c['type']] ?? 0) + 1;
  endwhile;

  if ($curseur < strlen($txt)):
    $out .= h(substr($txt, $curseur));
  endif;
  return $out;
}

// Liaison auto (sorts + glossaire)
function lierAuto(string $txt, array $indexAuto, array &$rapport): string
{
  $maxW    = maxMotsIndex(array_keys($indexAuto));
  $resolve = fn(string $cle) => $indexAuto[$cle] ?? null;
  return lierAvecIndex($txt, $maxW, $resolve, $rapport);
}

// Liaison sort uniquement (sous-liste "A volonte :", "2/jour :")
function lierSorts(string $txt, array $index, array &$rapport): string
{
  $noms    = $index['sort'] ?? [];
  $maxW    = maxMotsIndex(array_keys($noms));
  $resolve = function (string $cle) use ($noms) {
    if (!isset($noms[$cle])) return null;
    return ['type'=>'sort','id'=>$noms[$cle]['id'],'nom'=>$noms[$cle]['nom']];
  };
  return lierAvecIndex($txt, $maxW, $resolve, $rapport);
}

// Liaison don uniquement (ligne "Dons :" DD3.5)
function lierDons(string $txt, array $index, array &$rapport): string
{
  $noms    = $index['don'] ?? [];
  $maxW    = maxMotsIndex(array_keys($noms));
  $resolve = function (string $cle) use ($noms) {
    if (!isset($noms[$cle])) return null;
    return ['type'=>'don','id'=>$noms[$cle]['id'],'nom'=>$noms[$cle]['nom']];
  };
  return lierAvecIndex($txt, $maxW, $resolve, $rapport);
}

// ============================================================
// 7. TABLEAU DES CARACTERISTIQUES DD2024
// ============================================================

function parserLigneCarac(string $ligne): array
{
  $ligne  = preg_replace('/[\x{2010}-\x{2015}\x{2212}]/u', '-', $ligne);
  $noms   = implode('|', CARAC_DD2024);
  if (!preg_match_all(
    '/(' . $noms . ')\s+(\d+)\s+([+-]\s*\d+)\s+([+-]\s*\d+)/u',
    $ligne, $mm, PREG_SET_ORDER
  )): return []; endif;
  $result = [];
  foreach ($mm as $m):
    $result[] = [
      'abbr' => $m[1],
      'val'  => $m[2],
      'mod'  => preg_replace('/\s+/', '', $m[3]),
      'js'   => preg_replace('/\s+/', '', $m[4]),
    ];
  endforeach;
  return $result;
}

// Rend une ou deux lignes de carac en grille flex (3 col x 2 rangees)
// correspondant visuellement au SRD 2024 :
//   ligne 1 : For Dex Con
//   ligne 2 : Int Sag Cha
// avec entete MOD/JS et valeur empilee dans chaque colonne.
function rendreTableauCarac(array $lignes): string
{
  $caracs = [];
  foreach ($lignes as $l):
    foreach (parserLigneCarac($l) as $c):
      $caracs[] = $c;
    endforeach;
  endforeach;

  if (empty($caracs)):
    return implode('<br>', array_map('h', $lignes));
  endif;

  // Tableau 12 colonnes fixes (4 par carac x 3 groupes).
  // <colgroup> impose les largeurs indépendamment du contenu des cellules.
  // Chaque groupe : abbr(12%) val(10%) mod(9%) js(9%) -> 40% x 3 = 120%
  // table-layout:fixed + width:100% -> les % sont relatifs à 100%, ok.
  $colgroup = '<colgroup>';
  for ($g = 0; $g < 3; $g++):
    $colgroup .= '<col class="mo-col-abbr">'
               . '<col class="mo-col-val">'
               . '<col class="mo-col-mod">'
               . '<col class="mo-col-js">';
  endfor;
  $colgroup .= '</colgroup>';

  // En-tête : 3 groupes, MOD et JS centrés sur les bonnes colonnes
  $thead = '<thead><tr>';
  for ($g = 0; $g < 3; $g++):
    $sep = ($g < 2) ? ' mo-ct-sep' : '';
    $thead .= '<th></th>'
            . '<th></th>'
            . '<th class="mo-ct-label">MOD</th>'
            . '<th class="mo-ct-label' . $sep . '">JS</th>';
  endfor;
  $thead .= '</tr></thead>';

  // Corps : une ligne par groupe de 3 caracs
  $tbody = '<tbody>';
  foreach (array_chunk($caracs, 3) as $rang):
    $tbody .= '<tr>';
    foreach ($rang as $i => $c):
      $sep = ($i < 2) ? ' mo-ct-sep' : '';
      $tbody .= '<td class="mo-ct-abbr">'           . h($c['abbr']) . '</td>'
              . '<td class="mo-ct-val">'             . h($c['val'])  . '</td>'
              . '<td class="mo-ct-mod">'             . h($c['mod'])  . '</td>'
              . '<td class="mo-ct-js' . $sep . '">'  . h($c['js'])   . '</td>';
    endforeach;
    $tbody .= '</tr>';
  endforeach;
  $tbody .= '</tbody>';

  return '<div class="mo-carac-wrap"><table class="mo-carac-table">'
       . $colgroup . $thead . $tbody . '</table></div>';
}


function classerLigneDD2024(string $ligne): array
{
  $trim = trim($ligne);

  // Entete tableau carac
  if (preg_match('/^MOD\s+JS\s+MOD\s+JS/i', $trim)):
    return ['type' => 'carac_header'];
  endif;

  // Ligne de caracteristiques
  if (preg_match('/^(For|Dex|Con|Int|Sag|Cha)\s/u', $trim)):
    return ['type' => 'carac_row', 'texte' => $trim];
  endif;

  // Titre de section
  $titresNorm = array_map('normaliserNomMonstre', sectionsTitresDD2024());
  if (in_array(normaliserNomMonstre($trim), $titresNorm, true)):
    return ['type' => 'section_titre', 'texte' => $trim];
  endif;

  // Label inline (CA, Pv, Vitesse, Initiative)
  foreach (labelsInlineDD2024() as $lab):
    if (str_starts_with($trim, $lab . ' ')):
      return ['type' => 'label_inline', 'label' => $lab,
              'valeur' => trim(substr($trim, strlen($lab)))];
    endif;
  endforeach;

  // Label en gras (Resistances, Immunites, FP, Equipement...)
  foreach (labelsGrasDD2024() as $lab):
    $labNorm  = normaliserNomMonstre($lab);
    $lineNorm = normaliserNomMonstre($trim);
    if ($lineNorm === $labNorm || str_starts_with($lineNorm, $labNorm . ' ')):
      $apres = mb_strlen($trim) > mb_strlen($lab) ? trim(mb_substr($trim, mb_strlen($lab))) : '';
      return ['type' => 'label_gras', 'label' => $lab, 'valeur' => $apres];
    endif;
  endforeach;

  // Sous-liste de sorts : "A volonte :", "2/jour chacun :", "1/jour chacun :"
  if (preg_match('/^([\p{L}\p{N}\s\/]+?)\s*:\s*(.*)$/u', $trim, $m)):
    $prefNorm = normaliserNomMonstre($m[1]);
    // Prefixes caracteristiques des sous-listes de sorts
    if (preg_match('/^(a volonte|\d+\/jour)/u', $prefNorm)):
      return ['type' => 'sous_liste', 'label' => trim($m[1]), 'valeur' => trim($m[2])];
    endif;
  endif;

  // Pouvoir : "Nom. Description..."
  // Le nom peut contenir des virgules, parentheses, chiffres (ex: "Resistance legendaire (3/jour)")
  if (preg_match('/^(.{2,100}?)\.\s+(.{5,})/su', $trim, $m)):
    // Verification anti-faux-positif : ne pas confondre une phrase normale
    // dont la 1ere partie fait plus de 100 car avec un pouvoir
    $nom = trim($m[1]);
    // Exclure si le "nom" contient deja un point (ex: phrase avec abreviation)
    if (substr_count($nom, '.') === 0):
      return ['type' => 'pouvoir', 'nom' => $nom, 'description' => $m[2]];
    endif;
  endif;

  return ['type' => 'ligne', 'texte' => $trim];
}

function formaterBlocDD2024(
  array $lignes, PDO $db, array $index, array $indexAuto, array &$rapport
): string {
  $out       = [];
  $i         = 0;
  $n         = count($lignes);
  $carac_buf = [];

  $flushCarac = function () use (&$carac_buf, &$out) {
    if (empty($carac_buf)) return;
    $out[]     = '<div class="mo-carac-wrap">' . rendreTableauCarac($carac_buf) . '</div>';
    $carac_buf = [];
  };

  while ($i < $n):
    $ligne = rtrim($lignes[$i]);

    if (trim($ligne) === ''):
      $flushCarac();
      $out[] = '<div class="mo-stat-vide"></div>';
      $i++; continue;
    endif;

    if (trim($ligne) === '***'):
      $flushCarac();
      $out[] = '<hr class="mo-stat-hr">';
      $i++; continue;
    endif;

    $cl = classerLigneDD2024($ligne);

    switch ($cl['type']):

      case 'carac_header':
        $i++; break;

      case 'carac_row':
        $carac_buf[] = $cl['texte'];
        $i++; break;

      case 'section_titre':
        $flushCarac();
        $out[] = '<div class="mo-section-titre">' . h($cl['texte']) . '</div>';
        $i++; break;

      case 'label_inline':
        $flushCarac();
        // Pré-passe tags + liaison auto sur la valeur
        $val = resoudreTagsExplicites($cl['valeur'], $db, $index, 0, $rapport);
        $val = lierAuto($val, $indexAuto, $rapport);
        $out[] = '<div class="mo-stat-ligne">'
               . '<strong class="mo-stat-label">' . h($cl['label']) . '</strong> '
               . $val . '</div>';
        $i++; break;

      case 'label_gras':
        $flushCarac();
        $gNorm        = normaliserNomMonstre($cl['label']);
        $sansLiaison  = array_map('normaliserNomMonstre', labelsGrasSansLiaisonDD2024());
        if (in_array($gNorm, $sansLiaison, true)):
          // Sauvegardes : pas de liaison glossaire/regles/sorts (valeur structuree,
          // abreviations de caracteristiques, risque de faux positifs)
          $val = h($cl['valeur']);
        else:
          $val = resoudreTagsExplicites($cl['valeur'], $db, $index, 0, $rapport);
          // Competences : pas de liaison auto (les noms de competences peuvent etre des mots communs)
          // Dons : liaisons via tags # uniquement
          // Sorts dans FP : pas de liaison
          // Pour Resistances/Immunites etc. : liaison auto (peut contenir des termes de glossaire)
          $val = lierAuto($val, $indexAuto, $rapport);
        endif;
        $out[] = '<div class="mo-stat-ligne">'
               . '<strong class="mo-stat-label">' . h($cl['label']) . '</strong>'
               . ($cl['valeur'] !== '' ? ' ' . $val : '')
               . '</div>';
        $i++; break;

      case 'sous_liste':
        // Sous-liste de sorts : uniquement liaison sorts (contexte 100% sorts)
        $flushCarac();
        $val = resoudreTagsExplicites($cl['valeur'], $db, $index, 0, $rapport);
        $val = lierSorts($val, $index, $rapport);
        $out[] = '<div class="mo-sous-liste">'
               . '<span class="mo-sous-liste-label">' . h($cl['label']) . ' :</span> '
               . $val . '</div>';
        $i++; break;

      case 'pouvoir':
        $flushCarac();
        // NOM : affiche tel quel, jamais parse automatiquement
        $nomHtml = h($cl['nom']);
        // DESCRIPTION : pré-passe tags + liaison auto (sorts + glossaire)
        $desc = resoudreTagsExplicites($cl['description'], $db, $index, 0, $rapport);
        $desc = lierAuto($desc, $indexAuto, $rapport);
        $out[] = '<div class="mo-pouvoir">'
               . '<span class="mo-pouvoir-nom">' . $nomHtml . '.</span> '
               . $desc . '</div>';
        $i++; break;

      default:
        $flushCarac();
        $txt = resoudreTagsExplicites(trim($ligne), $db, $index, 0, $rapport);
        $txt = lierAuto($txt, $indexAuto, $rapport);
        $out[] = '<div class="mo-stat-ligne">' . $txt . '</div>';
        $i++; break;

    endswitch;
  endwhile;

  $flushCarac();
  return implode("\n", $out);
}

// ============================================================
// 9. RENDU DD3.5
// ============================================================

function formaterLigneDD35(
  string $ligne, array $labelSet, array $index, array $indexAuto,
  PDO $db, array &$rapport
): string {
  $pos = mb_strpos($ligne, ':');
  if ($pos !== false):
    $gauche = trim(mb_substr($ligne, 0, $pos));
    $droite = trim(mb_substr($ligne, $pos + 1));
    $gNorm  = normaliserNomMonstre($gauche);
    if ($gauche !== '' && isset($labelSet[$gNorm])):
      $labelHtml = '<strong class="mo-stat-label">' . h($gauche) . '</strong>';
      if ($droite === '') return $labelHtml . ' :';
      // Dons : liaison par tags # + liaison auto dons
      // Sorts : liaison par tags $ + liaison auto sorts
      // Autres : tags explicites + liaison auto (sorts + glossaire)
      $droite = resoudreTagsExplicites($droite, $db, $index, 0, $rapport);
      if ($gNorm === 'dons'):
        $valeur = lierDons($droite, $index, $rapport);
      else:
        $valeur = lierAuto($droite, $indexAuto, $rapport);
      endif;
      return $labelHtml . ' : ' . $valeur;
    endif;
  endif;
  $ligne = resoudreTagsExplicites($ligne, $db, $index, 0, $rapport);
  return lierAuto($ligne, $indexAuto, $rapport);
}

// ============================================================
// 10. POINT D'ENTREE PUBLIC
// ============================================================

function rendreStatsMonstre(PDO $db, ?string $texte, int $ruleset_id, array $res_ids): array
{
  $texte   = (string)$texte;
  $rapport = ['liens' => 0, 'par_type' => []];

  if (trim($texte) === ''):
    return ['html' => '', 'rapport' => $rapport];
  endif;

  $index     = chargerIndexMonstre($db, $ruleset_id, $res_ids);
  $indexAuto = construireIndexAuto($index);
  $est_dd2024 = $ruleset_id !== 1;
  $lignes    = preg_split('/\r\n|\r|\n/', $texte);

  if ($est_dd2024):
    $html = formaterBlocDD2024($lignes, $db, $index, $indexAuto, $rapport);
  else:
    $labelSet = [];
    foreach (labelsDD35() as $lab):
      $labelSet[normaliserNomMonstre($lab)] = $lab;
    endforeach;
    $out = [];
    foreach ($lignes as $ligne):
      $ligne = rtrim($ligne);
      if (trim($ligne) === ''):
        $out[] = '<div class="mo-stat-vide"></div>';
        continue;
      endif;
      if (trim($ligne) === '***'):
        $out[] = '<hr class="mo-stat-hr">';
        continue;
      endif;
      $out[] = '<div class="mo-stat-ligne">'
             . formaterLigneDD35($ligne, $labelSet, $index, $indexAuto, $db, $rapport)
             . '</div>';
    endforeach;
    $html = implode("\n", $out);
  endif;

  return ['html' => $html, 'rapport' => $rapport];
}
