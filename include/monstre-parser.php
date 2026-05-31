<?php
// include/monstre-parser.php
// ============================================================
// Moteur d'analyse et de rendu du bloc de stats d'un monstre.
// Entree  : mo_stats TEXTE BRUT. Sortie : HTML formate + liens cliquables.
// DD2024  : labels sans ":", sections titres, tableau carac, pouvoirs gras.
// DD3.5   : labels avec ":".
// ============================================================

require_once __DIR__ . '/helpers.php';

// ============================================================
// 1. CONFIGURATION — types liables
// ============================================================

function typesLiablesMonstre(): array
{
  return [
    'don' => [
      'table' => 'dd_dons', 'id' => 'do_id', 'nom' => 'do_nom',
      'ruleset' => 'do_ruleset_var_id', 'res' => 'do_res_id', 'camp' => 'do_camp_id',
      'actif' => true,
    ],
    'competence' => [
      'table' => 'dd_competences', 'id' => 'comp_id', 'nom' => 'comp_nom',
      'ruleset' => 'comp_ruleset_var_id', 'res' => 'comp_res_id', 'camp' => null,
      'actif' => true,
    ],
    'sort' => [
      'table' => 'dd_sorts', 'id' => 'so_id', 'nom' => 'so_nom',
      'ruleset' => 'so_ruleset_var_id', 'res' => 'so_res_id', 'camp' => 'so_camp_id',
      'actif' => true,
    ],
    'objet' => [
      'table' => 'dd_objets_magiques', 'id' => 'om_id', 'nom' => 'om_nom',
      'ruleset' => 'om_ruleset_var_id', 'res' => 'om_res_id', 'camp' => 'om_camp_id',
      'actif' => true,
    ],
    'capacite' => [
      'table' => 'dd_capacites_speciales', 'id' => 'cap_id', 'nom' => 'cap_nom',
      'ruleset' => null, 'res' => null, 'camp' => null,
      'actif' => true,
    ],
    'race' => [
      'table' => 'dd_races', 'id' => 'ra_id', 'nom' => 'ra_nom',
      'ruleset' => 'ra_ruleset_var_id', 'res' => 'ra_res_id', 'camp' => 'ra_camp_id',
      'actif' => false,
    ],
    'classe' => [
      'table' => 'dd_classes', 'id' => 'cla_id', 'nom' => 'cla_nom',
      'ruleset' => 'cla_ruleset_var_id', 'res' => 'cla_res_id', 'camp' => 'cla_camp_id',
      'actif' => false,
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
    // formes accentuees reconnues via normalisation
  ];
}

function labelsInlineDD2024(): array
{
  return ['CA', 'Pv', 'Vitesse', 'Initiative'];
}

function labelsGrasDD2024(): array
{
  return [
    'Resistances', 'Immunites', 'Vulnerabilites', 'Sens', 'Langues', 'FP',
    'Competences', 'Dons', 'Maitrises', 'Bonus de maitrise',
  ];
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
  // apostrophes variantes -> apostrophe droite
  $s = preg_replace("/[\x{2018}\x{2019}\x{201A}\x{201B}`\x{00B4}]/u", "'", $s);
  $accents = [
    "\xc3\xa0" => 'a', "\xc3\xa1" => 'a', "\xc3\xa2" => 'a', "\xc3\xa4" => 'a',
    "\xc3\xa8" => 'e', "\xc3\xa9" => 'e', "\xc3\xaa" => 'e', "\xc3\xab" => 'e',
    "\xc3\xac" => 'i', "\xc3\xad" => 'i', "\xc3\xae" => 'i', "\xc3\xaf" => 'i',
    "\xc3\xb2" => 'o', "\xc3\xb3" => 'o', "\xc3\xb4" => 'o', "\xc3\xb6" => 'o',
    "\xc3\xb9" => 'u', "\xc3\xba" => 'u', "\xc3\xbb" => 'u', "\xc3\xbc" => 'u',
    "\xc3\xa7" => 'c', "\xc3\xb1" => 'n',
    "\xc5\x93" => 'oe', "\xc3\xa6" => 'ae', "\xc3\xbd" => 'y', "\xc3\xbf" => 'y',
  ];
  $s = str_replace(array_keys($accents), array_values($accents), $s);
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

function chargerIndexMonstre(PDO $db, int $ruleset_id, array $res_ids): array
{
  $res_ids = array_values(array_filter(array_map('intval', $res_ids)));
  $index   = [];

  foreach (typesLiablesMonstre() as $type => $cfg):
    $where  = [];
    $params = [];

    if ($cfg['ruleset'] !== null):
      $where[]  = $cfg['ruleset'] . ' = ?';
      $params[] = $ruleset_id;
    endif;

    if ($cfg['camp'] !== null):
      $where[] = $cfg['camp'] . ' IS NULL';
    endif;

    if ($cfg['res'] !== null && empty($res_ids)):
      $index[$type] = ['actif' => (bool)$cfg['actif'], 'noms' => []];
      continue;
    endif;

    if ($cfg['res'] !== null):
      $ph      = implode(',', array_fill(0, count($res_ids), '?'));
      $where[] = $cfg['res'] . ' IN (' . $ph . ')';
      foreach ($res_ids as $r) $params[] = $r;
    endif;

    $sql = 'SELECT ' . $cfg['id'] . ' AS id, ' . $cfg['nom'] . ' AS nom FROM ' . $cfg['table'];
    if ($where) $sql .= ' WHERE ' . implode(' AND ', $where);

    $stmt = $db->prepare($sql);
    $stmt->execute($params);

    $noms = [];
    foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $row):
      $cle = normaliserNomMonstre((string)$row['nom']);
      if ($cle === '' || isset($noms[$cle])) continue;
      $noms[$cle] = ['id' => (int)$row['id'], 'nom' => (string)$row['nom']];
    endforeach;

    $index[$type] = ['actif' => (bool)$cfg['actif'], 'noms' => $noms];
  endforeach;

  return $index;
}

function construireIndexLibre(array $indexParType): array
{
  $libre = [];
  foreach ($indexParType as $type => $bloc):
    if (empty($bloc['actif'])) continue;
    foreach ($bloc['noms'] as $cle => $info):
      if (!isset($libre[$cle])):
        $libre[$cle] = ['type' => $type, 'id' => $info['id'], 'nom' => $info['nom']];
      endif;
    endforeach;
  endforeach;
  return $libre;
}

// ============================================================
// 5. MOTEUR DE LIAISON
// ============================================================

define('MO_LONGUEUR_MIN', 3);

function lierAvecIndex(string $txt, int $maxWords, callable $resolve, array &$rapport): string
{
  if ($maxWords < 1 || $txt === '') return h($txt);

  if (!preg_match_all('/[\p{L}\p{N}\']+/u', $txt, $mm, PREG_OFFSET_CAPTURE)):
    return h($txt);
  endif;

  $mots    = $mm[0];
  $n       = count($mots);
  $out     = '';
  $curseur = 0;
  $i       = 0;

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
        $trouve = ['debut' => $debut, 'fin' => $fin, 'brut' => $brut, 'cible' => $cible];
        $i += $k;
        break;
      endif;
    endfor;

    if ($trouve === null):
      $i++;
      continue;
    endif;

    if ($trouve['debut'] > $curseur):
      $out .= h(substr($txt, $curseur, $trouve['debut'] - $curseur));
    endif;

    $c    = $trouve['cible'];
    $out .= '<span class="mo-lien" data-type="' . h($c['type']) . '" data-id="' . (int)$c['id'] . '">'
          . h($trouve['brut']) . '</span>';
    $curseur = $trouve['fin'];

    $rapport['liens']++;
    $rapport['par_type'][$c['type']] = ($rapport['par_type'][$c['type']] ?? 0) + 1;
  endwhile;

  if ($curseur < strlen($txt)):
    $out .= h(substr($txt, $curseur));
  endif;

  return $out;
}

function lierTexteLibre(string $txt, array $indexLibre, array &$rapport): string
{
  $maxW    = maxMotsIndex(array_keys($indexLibre));
  $resolve = fn(string $cle) => $indexLibre[$cle] ?? null;
  return lierAvecIndex($txt, $maxW, $resolve, $rapport);
}

function lierTexteType(string $txt, array $blocType, string $type, array &$rapport): string
{
  $noms    = $blocType['noms'] ?? [];
  $maxW    = maxMotsIndex(array_keys($noms));
  $resolve = function (string $cle) use ($noms, $type) {
    if (!isset($noms[$cle])) return null;
    return ['type' => $type, 'id' => $noms[$cle]['id'], 'nom' => $noms[$cle]['nom']];
  };
  return lierAvecIndex($txt, $maxW, $resolve, $rapport);
}

// ============================================================
// 6. RENDU DD3.5
// ============================================================

function formaterLigneDD35(
  string $ligne, array $labelSet, array $indexParType, array $indexLibre, array &$rapport
): string {
  $pos = mb_strpos($ligne, ':');
  if ($pos !== false):
    $gauche = trim(mb_substr($ligne, 0, $pos));
    $droite = trim(mb_substr($ligne, $pos + 1));
    $gNorm  = normaliserNomMonstre($gauche);

    if ($gauche !== '' && isset($labelSet[$gNorm])):
      $labelHtml = '<strong class="mo-stat-label">' . h($gauche) . '</strong>';
      if ($droite === '') return $labelHtml . ' :';

      $gNorm2 = normaliserNomMonstre($gauche);
      if ($gNorm2 === 'dons' && isset($indexParType['don'])):
        $valeur = lierTexteType($droite, $indexParType['don'], 'don', $rapport);
      elseif ($gNorm2 === 'competences' && isset($indexParType['competence'])):
        $valeur = lierTexteType($droite, $indexParType['competence'], 'competence', $rapport);
      else:
        $valeur = lierTexteLibre($droite, $indexLibre, $rapport);
      endif;

      return $labelHtml . ' : ' . $valeur;
    endif;
  endif;

  return lierTexteLibre($ligne, $indexLibre, $rapport);
}

// ============================================================
// 7. RENDU DD2024
// ============================================================

function classerLigneDD2024(string $ligne): array
{
  $trim = trim($ligne);

  // Entete tableau carac (a ignorer)
  if (preg_match('/^MOD\s+JS\s+MOD\s+JS/i', $trim)):
    return ['type' => 'carac_header'];
  endif;

  // Ligne de caracteristiques
  if (preg_match('/^(For|Dex|Con|Int|Sag|Cha)\s/u', $trim)):
    return ['type' => 'carac_row', 'texte' => $trim];
  endif;

  // Titre de section seul
  $titresNorm = array_map('normaliserNomMonstre', sectionsTitresDD2024());
  if (in_array(normaliserNomMonstre($trim), $titresNorm, true)):
    return ['type' => 'section_titre', 'texte' => $trim];
  endif;

  // Label inline (CA, Pv, Vitesse, Initiative)
  foreach (labelsInlineDD2024() as $lab):
    if (str_starts_with($trim, $lab . ' ')):
      $valeur = trim(substr($trim, strlen($lab)));
      return ['type' => 'label_inline', 'label' => $lab, 'valeur' => $valeur];
    endif;
  endforeach;

  // Label en gras (Resistances, Immunites, FP…)
  foreach (labelsGrasDD2024() as $lab):
    $labNorm  = normaliserNomMonstre($lab);
    $lineNorm = normaliserNomMonstre($trim);
    if ($lineNorm === $labNorm || str_starts_with($lineNorm, $labNorm . ' ')):
      $apres = mb_strlen($trim) > mb_strlen($lab) ? trim(mb_substr($trim, mb_strlen($lab))) : '';
      return ['type' => 'label_gras', 'label' => $lab, 'valeur' => $apres];
    endif;
  endforeach;

  // Pouvoir : "Nom du pouvoir. Description..."
  if (preg_match('/^([\p{Lu}][\p{L}\p{N}\s\'\x{2019}\-\(\)\/]{0,80}?)\.\s+(.+)/su', $trim, $m)):
    return ['type' => 'pouvoir', 'nom' => $m[1], 'description' => $m[2]];
  endif;

  return ['type' => 'ligne', 'texte' => $trim];
}

function parserLigneCarac(string $ligne): array
{
  // Normalise les tirets unicode (moins, tiret long, signe moins mathematique) -> tiret ASCII
  $ligne = preg_replace('/[\x{2010}-\x{2015}\x{2212}]/u', '-', $ligne);
  $noms  = implode('|', CARAC_DD2024);
  if (!preg_match_all('/(' . $noms . ')\s+(\d+)\s+([+-]\s*\d+)\s+([+-]\s*\d+)/u', $ligne, $mm, PREG_SET_ORDER)):
    return [];
  endif;
  $result = [];
  foreach ($mm as $m):
    $result[] = ['abbr' => $m[1], 'val' => $m[2], 'mod' => $m[3], 'js' => $m[4]];
  endforeach;
  return $result;
}

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

  $th = $td_val = $td_mod = '';
  foreach ($caracs as $c):
    $th     .= '<th>' . h($c['abbr']) . '</th>';
    $td_val .= '<td>' . h($c['val'])  . '</td>';
    $td_mod .= '<td>' . h($c['mod'])  . ' / ' . h($c['js']) . '</td>';
  endforeach;

  return '<table class="mo-carac-table">'
       . '<thead><tr><th></th>' . $th . '</tr></thead>'
       . '<tbody>'
       . '<tr><td class="mo-carac-label">Val.</td>'    . $td_val . '</tr>'
       . '<tr><td class="mo-carac-label">Mod / JS</td>' . $td_mod . '</tr>'
       . '</tbody></table>';
}

function formaterBlocDD2024(
  array $lignes, array $indexParType, array $indexLibre, array &$rapport
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
      $i++;
      continue;
    endif;

    if (trim($ligne) === '***'):
      $flushCarac();
      $out[] = '<hr class="mo-stat-hr">';
      $i++;
      continue;
    endif;

    $cl = classerLigneDD2024($ligne);

    switch ($cl['type']):

      case 'carac_header':
        $i++;
        break;

      case 'carac_row':
        $carac_buf[] = $cl['texte'];
        $i++;
        break;

      case 'section_titre':
        $flushCarac();
        $out[] = '<div class="mo-section-titre">' . h($cl['texte']) . '</div>';
        $i++;
        break;

      case 'label_inline':
        $flushCarac();
        $valeur = lierTexteLibre($cl['valeur'], $indexLibre, $rapport);
        $out[] = '<div class="mo-stat-ligne">'
               . '<strong class="mo-stat-label">' . h($cl['label']) . '</strong> '
               . $valeur . '</div>';
        $i++;
        break;

      case 'label_gras':
        $flushCarac();
        $gNorm = normaliserNomMonstre($cl['label']);
        if ($gNorm === 'dons' && isset($indexParType['don'])):
          $valeurHtml = lierTexteType($cl['valeur'], $indexParType['don'], 'don', $rapport);
        elseif ($gNorm === 'competences' && isset($indexParType['competence'])):
          $valeurHtml = lierTexteType($cl['valeur'], $indexParType['competence'], 'competence', $rapport);
        else:
          $valeurHtml = lierTexteLibre($cl['valeur'], $indexLibre, $rapport);
        endif;
        $out[] = '<div class="mo-stat-ligne">'
               . '<strong class="mo-stat-label">' . h($cl['label']) . '</strong>'
               . ($cl['valeur'] !== '' ? ' ' . $valeurHtml : '')
               . '</div>';
        $i++;
        break;

      case 'pouvoir':
        $flushCarac();
        $nomLie  = lierTexteLibre($cl['nom'], $indexLibre, $rapport);
        $descLie = lierTexteLibre($cl['description'], $indexLibre, $rapport);
        $out[] = '<div class="mo-pouvoir">'
               . '<span class="mo-pouvoir-nom">' . $nomLie . '.</span> '
               . $descLie . '</div>';
        $i++;
        break;

      default:
        $flushCarac();
        $out[] = '<div class="mo-stat-ligne">'
               . lierTexteLibre(trim($ligne), $indexLibre, $rapport)
               . '</div>';
        $i++;
        break;

    endswitch;
  endwhile;

  $flushCarac();
  return implode("\n", $out);
}

// ============================================================
// 8. POINT D'ENTREE PUBLIC
// ============================================================

function rendreStatsMonstre(PDO $db, ?string $texte, int $ruleset_id, array $res_ids): array
{
  $texte   = (string)$texte;
  $rapport = ['liens' => 0, 'par_type' => []];

  if (trim($texte) === ''):
    return ['html' => '', 'rapport' => $rapport];
  endif;

  $indexParType = chargerIndexMonstre($db, $ruleset_id, $res_ids);
  $indexLibre   = construireIndexLibre($indexParType);
  $est_dd2024   = $ruleset_id !== 1;

  $lignes = preg_split('/\r\n|\r|\n/', $texte);

  if ($est_dd2024):
    $html = formaterBlocDD2024($lignes, $indexParType, $indexLibre, $rapport);
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
             . formaterLigneDD35($ligne, $labelSet, $indexParType, $indexLibre, $rapport)
             . '</div>';
    endforeach;
    $html = implode("\n", $out);
  endif;

  return ['html' => $html, 'rapport' => $rapport];
}
