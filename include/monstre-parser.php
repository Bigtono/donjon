<?php
// include/monstre-parser.php
// ============================================================
// Moteur d'analyse et de rendu du bloc de stats d'un monstre.
//
// Entrée  : mo_stats en TEXTE BRUT (saisi tel quel, sans TinyMCE).
// Sortie  : HTML formaté + entités du jeu rendues cliquables.
//
// Appelé à l'AFFICHAGE par include/ajax/detail-pp/monstre.php :
//
//   require_once __DIR__ . '/../../monstre-parser.php';
//   $rendu = rendreStatsMonstre($db, $mo['mo_stats'], $ruleset_id, $res_ids);
//   echo $rendu['html'];           // $rendu['rapport'] = compteur de liens posés
//
// Les liens produits sont des spans NEUTRES, sans onclick ni URL :
//   <span class="mo-lien" data-type="don" data-id="42">Alerte</span>
// La résolution data-type -> endpoint detail-pp -> actualiserPageSub() est
// faite côté client (js/compendium.js). Le HTML stocké en base reste le texte
// brut : c'est ce rendu qui est recalculé à chaque affichage.
// ============================================================

require_once __DIR__ . '/helpers.php'; // h()

// ------------------------------------------------------------
// 1. CONFIGURATION
// ------------------------------------------------------------

// Registre déclaratif des types liables.
//   ruleset / res / camp : nom de colonne de scoping, ou null si non applicable.
//   actif : true  -> détecté partout dans le texte libre.
//           false -> relié uniquement via une ligne étiquetée dédiée
//                    (évite les faux positifs sur des noms courts et courants).
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
      'actif' => false, // « Nain », « Elfe »… trop courants -> ligne étiquetée requise
    ],
    'classe' => [
      'table' => 'dd_classes', 'id' => 'cla_id', 'nom' => 'cla_nom',
      'ruleset' => 'cla_ruleset_var_id', 'res' => 'cla_res_id', 'camp' => 'cla_camp_id',
      'actif' => false, // « Guerrier », « Mage »… idem
    ],
  ];
}

// Étiquettes reconnues en tête de ligne (« Label : valeur »).
// Le label est mis en gras. « Dons » et « Compétences » déclenchent en plus une
// liaison ciblée sur leur type respectif. Liste librement extensible.
function labelsStatsMonstre(): array
{
  return [
    "Classe d'armure", 'Dés de vie', 'Initiative', 'Vitesse de déplacement',
    'Attaque de base/lutte', 'Attaque à outrance', 'Attaque',
    'Espace occupé/allonge', 'Attaques spéciales', 'Particularités',
    'Jets de sauvegarde', 'Caractéristiques', 'Compétences', 'Dons',
    'Environnement', 'Organisation sociale', 'Facteur de puissance', 'Trésor',
    'Alignement', 'Évolution possible', 'Ajustement de niveau', 'Type',
  ];
}

// Longueur minimale (en caractères, après normalisation) d'un nom détectable
// dans le texte libre — bride les faux positifs sur les mots très courts.
const MO_LONGUEUR_MIN = 3;

// ------------------------------------------------------------
// 2. NORMALISATION
// ------------------------------------------------------------

// Minuscule + apostrophes unifiées + accents retirés + espaces compactés.
// Sert des deux côtés (dictionnaire et texte) pour un matching insensible
// à la casse et aux accents.
function normaliserNomMonstre(string $s): string
{
  $s = mb_strtolower(trim($s), 'UTF-8');
  $s = str_replace(['’', '‘', '`', '´'], "'", $s);
  $accents = [
    'à' => 'a', 'á' => 'a', 'â' => 'a', 'ã' => 'a', 'ä' => 'a', 'å' => 'a',
    'è' => 'e', 'é' => 'e', 'ê' => 'e', 'ë' => 'e',
    'ì' => 'i', 'í' => 'i', 'î' => 'i', 'ï' => 'i',
    'ò' => 'o', 'ó' => 'o', 'ô' => 'o', 'õ' => 'o', 'ö' => 'o',
    'ù' => 'u', 'ú' => 'u', 'û' => 'u', 'ü' => 'u',
    'ç' => 'c', 'ñ' => 'n', 'œ' => 'oe', 'æ' => 'ae', 'ý' => 'y', 'ÿ' => 'y',
  ];
  $s = strtr($s, $accents);
  $s = preg_replace('/\s+/', ' ', $s);
  return trim($s);
}

// Nombre maximal de mots parmi un jeu de clés normalisées (pour le fenêtrage).
function maxMotsIndex(array $clesNormalisees): int
{
  $max = 1;
  foreach ($clesNormalisees as $cle):
    $n = substr_count($cle, ' ') + 1;
    if ($n > $max) $max = $n;
  endforeach;
  return $max;
}

// ------------------------------------------------------------
// 3. CHARGEMENT DU DICTIONNAIRE (requêtes groupées : 1 par type)
// ------------------------------------------------------------

// Retourne : [ type => ['actif' => bool, 'noms' => [ nomNorm => ['id','nom'] ]] ]
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
      $where[] = $cfg['camp'] . ' IS NULL'; // compendium global uniquement
    endif;

    // Type scopé par source mais aucune source active -> rien à proposer.
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

// Index fusionné des types actifs, pour la détection en texte libre.
// En cas d'homonymie entre types, la priorité suit l'ordre du registre.
function construireIndexLibre(array $indexParType): array
{
  $libre = []; // nomNorm => ['type','id','nom']
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

// ------------------------------------------------------------
// 4. MOTEUR DE LIAISON (fenêtrage par mots, plus longue correspondance)
// ------------------------------------------------------------

// Parcourt le texte mot à mot. Pour chaque position, teste les fenêtres de
// $maxWords mots décroissant jusqu'à 1 ; la première reconnue par $resolve est
// transformée en span. Le texte non lié est conservé tel quel (échappé HTML).
//
// $resolve : fn(string $nomNorm) => ['type','id','nom'] | null
function lierAvecIndex(string $txt, int $maxWords, callable $resolve, array &$rapport): string
{
  if ($maxWords < 1 || $txt === '') return h($txt);

  // Mots = suites de lettres/chiffres/apostrophes, avec offset OCTET (PCRE).
  if (!preg_match_all('/[\p{L}\p{N}\']+/u', $txt, $mm, PREG_OFFSET_CAPTURE)):
    return h($txt);
  endif;

  $mots = $mm[0];
  $n    = count($mots);
  $out  = '';
  $curseur = 0;
  $i = 0;

  while ($i < $n):
    $trouve = null;
    $kmax   = min($maxWords, $n - $i);

    for ($k = $kmax; $k >= 1; $k--):
      $debut  = $mots[$i][1];
      $dernier = $mots[$i + $k - 1];
      $fin    = $dernier[1] + strlen($dernier[0]);
      $brut   = substr($txt, $debut, $fin - $debut);
      $cle    = normaliserNomMonstre($brut);

      if (mb_strlen($cle) < MO_LONGUEUR_MIN) continue;
      if (!preg_match('/\p{L}/u', $cle)) continue; // ignore les candidats purement numériques

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

    // Littéral précédant le match.
    if ($trouve['debut'] > $curseur):
      $out .= h(substr($txt, $curseur, $trouve['debut'] - $curseur));
    endif;

    $c = $trouve['cible'];
    $out .= '<span class="mo-lien" data-type="' . h($c['type']) . '" data-id="' . (int)$c['id'] . '">'
          . h($trouve['brut'])
          . '</span>';
    $curseur = $trouve['fin'];

    $rapport['liens']++;
    $rapport['par_type'][$c['type']] = ($rapport['par_type'][$c['type']] ?? 0) + 1;
  endwhile;

  if ($curseur < strlen($txt)):
    $out .= h(substr($txt, $curseur));
  endif;

  return $out;
}

// Liaison sur l'index fusionné (texte libre).
function lierTexteLibre(string $txt, array $indexLibre, array &$rapport): string
{
  $maxW    = maxMotsIndex(array_keys($indexLibre));
  $resolve = function (string $cle) use ($indexLibre) {
    return $indexLibre[$cle] ?? null;
  };
  return lierAvecIndex($txt, $maxW, $resolve, $rapport);
}

// Liaison restreinte à un seul type (lignes « Dons : » / « Compétences : »).
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

// ------------------------------------------------------------
// 5. FORMATAGE D'UNE LIGNE
// ------------------------------------------------------------

function formaterLigneMonstre(
  string $ligne, array $labelSet, array $indexParType, array $indexLibre, array &$rapport
): string {
  // Ligne « Label : valeur » ?
  $pos = mb_strpos($ligne, ':');
  if ($pos !== false):
    $gauche = trim(mb_substr($ligne, 0, $pos));
    $droite = trim(mb_substr($ligne, $pos + 1));
    $gNorm  = normaliserNomMonstre($gauche);

    if ($gauche !== '' && isset($labelSet[$gNorm])):
      $labelHtml = '<strong class="mo-stat-label">' . h($gauche) . '</strong>';
      if ($droite === ''):
        return $labelHtml . ' :';
      endif;

      if ($gNorm === 'dons' && isset($indexParType['don'])):
        $valeur = lierTexteType($droite, $indexParType['don'], 'don', $rapport);
      elseif ($gNorm === 'competences' && isset($indexParType['competence'])):
        $valeur = lierTexteType($droite, $indexParType['competence'], 'competence', $rapport);
      else:
        $valeur = lierTexteLibre($droite, $indexLibre, $rapport);
      endif;

      return $labelHtml . ' : ' . $valeur;
    endif;
  endif;

  // Ligne ordinaire -> liaison en texte libre.
  return lierTexteLibre($ligne, $indexLibre, $rapport);
}

// ------------------------------------------------------------
// 6. POINT D'ENTRÉE PUBLIC
// ------------------------------------------------------------

function rendreStatsMonstre(PDO $db, ?string $texte, int $ruleset_id, array $res_ids): array
{
  $texte   = (string)$texte;
  $rapport = ['liens' => 0, 'par_type' => []];

  if (trim($texte) === ''):
    return ['html' => '', 'rapport' => $rapport];
  endif;

  $indexParType = chargerIndexMonstre($db, $ruleset_id, $res_ids);
  $indexLibre   = construireIndexLibre($indexParType);

  // Jeu d'étiquettes : clé normalisée => libellé d'origine (non utilisé ici,
  // le libellé affiché reste celui saisi par l'éditeur).
  $labelSet = [];
  foreach (labelsStatsMonstre() as $lab):
    $labelSet[normaliserNomMonstre($lab)] = $lab;
  endforeach;

  $lignes = preg_split('/\r\n|\r|\n/', $texte);
  $out    = [];

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
           . formaterLigneMonstre($ligne, $labelSet, $indexParType, $indexLibre, $rapport)
           . '</div>';
  endforeach;

  return ['html' => implode("\n", $out), 'rapport' => $rapport];
}
