<?php
// include/ajax/export/monstre-roll20.php
// ============================================================
// Génère et télécharge un JSON Roll20 NPC (fiche DD5e 2014 VF)
// à partir d'un monstre du compendium Codex DD.
//
// Point d'entrée : GET ?id={mo_id}
// Sortie         : application/json avec Content-Disposition: attachment
//
// Contraintes Roll20 ciblées :
//   - Fiche "D&D 5e (2014)" en VF, mode charactersheet_type = "npc"
//   - Sorts NPC : spelloutput = "SPELLCARD" uniquement (V2 prévoira ATTACK)
//   - Initiative : DEX_mod + DEX_score/100 (convention tie-breaker 2014)
//   - Bonus de maîtrise : extrait de la ligne "FP" dans mo_stats
//   - IDs repeating : pseudo-Firebase 20 chars générés en PHP
// ============================================================

require_once __DIR__ . '/../../db.php';
require_once __DIR__ . '/../../auth.php';
require_once __DIR__ . '/../../helpers.php';

requireAuth();

$mo_id = intParam($_GET['id'] ?? 0);
if (!$mo_id):
  http_response_code(400);
  header('Content-Type: application/json');
  echo json_encode(['erreur' => 'Identifiant manquant']);
  exit;
endif;

$stmt = $db->prepare('
  SELECT mo.*, res.res_nom
  FROM   dd_monstres mo
  LEFT JOIN dd_ressources res ON res.res_id = mo.mo_res_id
  WHERE  mo.mo_id = ?
');
$stmt->execute([$mo_id]);
$mo = $stmt->fetch(PDO::FETCH_ASSOC);

if (!$mo):
  http_response_code(404);
  header('Content-Type: application/json');
  echo json_encode(['erreur' => 'Monstre introuvable']);
  exit;
endif;

$parsed = parseMonstreStats((string)($mo['mo_stats'] ?? ''));
$sorts  = [];
if (!empty($parsed['incantation']['noms_sorts'])):
  $sorts = fetchSortsByName($db, $parsed['incantation']['noms_sorts'], (int)$mo['mo_ruleset_var_id']);
endif;

$json_data = buildRoll20NpcJson($mo, $parsed, $sorts);

// Normaliser les accents avant de construire le nom de fichier :
// preg_replace sans flag /u traite chaque octet séparément — 'é' (2 octets) → '__'
$_nom_brut = strtr((string)$mo['mo_nom'], [
  'à'=>'a','á'=>'a','â'=>'a','ä'=>'a','ã'=>'a',
  'è'=>'e','é'=>'e','ê'=>'e','ë'=>'e',
  'ì'=>'i','í'=>'i','î'=>'i','ï'=>'i',
  'ò'=>'o','ó'=>'o','ô'=>'o','ö'=>'o','õ'=>'o',
  'ù'=>'u','ú'=>'u','û'=>'u','ü'=>'u',
  'ç'=>'c','ñ'=>'n','œ'=>'oe','æ'=>'ae',
  'À'=>'A','Á'=>'A','Â'=>'A','Ä'=>'A','Ã'=>'A',
  'È'=>'E','É'=>'E','Ê'=>'E','Ë'=>'E',
  'Ì'=>'I','Í'=>'I','Î'=>'I','Ï'=>'I',
  'Ò'=>'O','Ó'=>'O','Ô'=>'O','Ö'=>'O','Õ'=>'O',
  'Ù'=>'U','Ú'=>'U','Û'=>'U','Ü'=>'U',
  'Ç'=>'C','Ñ'=>'N','Œ'=>'Oe','Æ'=>'Ae',
]);
$filename = 'roll20_' . preg_replace('/[^a-z0-9_-]/i', '_', $_nom_brut) . '.json';
header('Content-Type: application/json; charset=utf-8');
header('Content-Disposition: attachment; filename="' . addslashes($filename) . '"');
echo json_encode($json_data, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
exit;


// ════════════════════════════════════════════════════════
// UTILITAIRES GÉNÉRAUX
// ════════════════════════════════════════════════════════

/**
 * Génère un ID pseudo-Firebase 20 chars unique dans l'export courant.
 * Format Roll20 : commence par '-', puis 19 chars alphanumériques ou '_'.
 */
function firebaseId(): string
{
  static $used = [];
  $chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  // ⚠ Pas de '_' : Roll20 utilise '_' comme séparateur dans les noms d'attributs.
  // Un ID contenant '_' tronque l'ID lors du parsing et génère une ligne fantôme.
  do {
    $id = '-';
    for ($i = 0; $i < 19; $i++):
      $id .= $chars[random_int(0, 61)];
    endfor;
  } while (isset($used[$id]));
  $used[$id] = true;
  return $id;
}

/** Ajoute un attribut Roll20 au tableau $attrs. */
function attr(array &$attrs, string $name, $current, string $max = ''): void
{
  $attrs[] = ['name' => $name, 'current' => $current, 'max' => $max];
}

/** Normalise une chaîne pour comparaison floue (sans accents, minuscules, espaces normalisés). */
function normaliserRoll20(string $s): string
{
  $s   = mb_strtolower(trim($s), 'UTF-8');
  $acc = [
    'à'=>'a','á'=>'a','â'=>'a','ä'=>'a','è'=>'e','é'=>'e','ê'=>'e','ë'=>'e',
    'ì'=>'i','í'=>'i','î'=>'i','ï'=>'i','ò'=>'o','ó'=>'o','ô'=>'o','ö'=>'o',
    'ù'=>'u','ú'=>'u','û'=>'u','ü'=>'u','ç'=>'c','ñ'=>'n','œ'=>'oe','æ'=>'ae',
  ];
  $s = str_replace(array_keys($acc), array_values($acc), $s);
  return trim(preg_replace('/\s+/', ' ', $s));
}

/** Normalise les tirets Unicode (−, –, …) en tiret ASCII. */
/**
 * Vérifie qu'une ligne est une sous-liste de sorts dans un bloc Incantation.
 * Supporte deux formats de séparateur :
 *   "Prefix : noms"   → "À volonté : lumière", "2/jour chacun : boule de feu"
 *   "Prefix - noms"   → "Tour de magie - assistance", "Niveau 1 (3/J) - blessure"
 *
 * Préfixes reconnus (normalisés) :
 *   a volonte, \d+/jour, tours? de magie, niveau \d, cantrip
 */
function estPrefixeSousListeSorts(string $ligne): bool
{
  // Séparateur ":" — max 40 chars non-":" avant
  if (preg_match('/^([^:]{1,40}):\s*.+$/u', $ligne, $m)):
    if (preg_match('/^(a volonte|\d+\/jour|tours? de magie|niveau\s*\d|cantrip)/u', normaliserRoll20(trim($m[1])))):
      return true;
    endif;
  endif;
  // Séparateur " - " — max 60 chars avant (permet "(3/J)" dans le préfixe)
  if (preg_match('/^(.{1,60}?)\s+-\s+.+$/u', $ligne, $m)):
    if (preg_match('/^(a volonte|\d+\/jour|tours? de magie|niveau\s*\d|cantrip)/u', normaliserRoll20(trim($m[1])))):
      return true;
    endif;
  endif;
  return false;
}

function normaliserMinus(string $s): string
{
  return preg_replace('/[\x{2010}-\x{2015}\x{2212}]/u', '-', $s);
}

/** Retourne une chaîne signée : "+5", "-1", "+0". */
function avecSigne(int $n): string
{
  return ($n >= 0 ? '+' : '') . $n;
}

// ── Tables de correspondance ──────────────────────────────

/** Abréviation FR (mo_stats) → clé Roll20 (strength/dexterity/…). */
function carAbbr2Roll20(): array
{
  return [
    'For' => 'strength',    'Dex' => 'dexterity',    'Con' => 'constitution',
    'Int' => 'intelligence','Sag' => 'wisdom',         'Cha' => 'charisma',
  ];
}

/** Nom de caractéristique FR normalisé → clé Roll20 spell_ability. */
function carac2SpellAbility(string $carac): string
{
  $map = [
    'force'        => '@{strength_mod}+',
    'dexterite'    => '@{dexterity_mod}+',
    'constitution' => '@{constitution_mod}+',
    'intelligence' => '@{intelligence_mod}+',
    'sagesse'      => '@{wisdom_mod}+',
    'charisme'     => '@{charisma_mod}+',
  ];
  return $map[normaliserRoll20($carac)] ?? '@{intelligence_mod}+';
}

/** Compétence FR normalisée → champ Roll20. */
function compFr2Roll20(): array
{
  return [
    'acrobaties'   => 'acrobatics',   'dressage'      => 'animal_handling',
    'arcanes'      => 'arcana',        'athletisme'    => 'athletics',
    'tromperie'    => 'deception',     'histoire'      => 'history',
    'perspicacite' => 'insight',       'intimidation'  => 'intimidation',
    'investigation'=> 'investigation', 'medecine'      => 'medicine',
    'nature'       => 'nature',        'perception'    => 'perception',
    'representation'=>'performance',   'persuasion'    => 'persuasion',
    'religion'     => 'religion',      'escamotage'    => 'sleight_of_hand',
    'discretion'   => 'stealth',       'survie'        => 'survival',
  ];
}

/** Compétence Roll20 → caractéristique associée. */
function compCar(): array
{
  return [
    'acrobatics'    =>'dexterity',  'animal_handling'=>'wisdom',
    'arcana'        =>'intelligence','athletics'    =>'strength',
    'deception'     =>'charisma',   'history'       =>'intelligence',
    'insight'       =>'wisdom',     'intimidation'  =>'charisma',
    'investigation' =>'intelligence','medicine'     =>'wisdom',
    'nature'        =>'intelligence','perception'   =>'wisdom',
    'performance'   =>'charisma',   'persuasion'    =>'charisma',
    'religion'      =>'intelligence','sleight_of_hand'=>'dexterity',
    'stealth'       =>'dexterity',  'survival'      =>'wisdom',
  ];
}

/** Collège FR normalisé → spellschool Roll20. */
function college2Roll20(string $col): string
{
  $map = [
    'abjuration'    => 'abjuration',  'invocation'  => 'conjuration',
    'conjuration'   => 'conjuration', 'divination'  => 'divination',
    'enchantement'  => 'enchantment', 'evocation'   => 'evocation',
    'illusion'      => 'illusion',    'necromancie' => 'necromancy',
    'transmutation' => 'transmutation',
  ];
  $norm = normaliserRoll20($col);
  return $map[$norm] ?? $norm;
}

/** Abbréviation car (str/dex/…) à partir du nom Roll20 complet. */
function carNom2Abbr(string $car): string
{
  return [
    'strength'=>'str','dexterity'=>'dex','constitution'=>'con',
    'intelligence'=>'int','wisdom'=>'wis','charisma'=>'cha',
  ][$car] ?? substr($car, 0, 3);
}


// ════════════════════════════════════════════════════════
// PARSING mo_stats
// ════════════════════════════════════════════════════════

/**
 * Parse le champ mo_stats (format DD2024) en tableau structuré.
 */
function parseMonstreStats(string $texte): array
{
  $result = [
    'npc_type'              => '',
    'ac'                    => 0,
    'hp_max'                => 0,
    'hp_formula'            => '',
    'speed'                 => '',
    'cr'                    => '',
    'xp'                    => 0,
    'pb'                    => 2,
    'stats'                 => [],  // [car => [score, mod, save]]
    'skills'                => [],  // [comp_roll20 => bonus]
    'resistances'           => '',
    'immunities'            => '',
    'condition_immunities'  => '',
    'vulnerabilities'       => '',
    'senses'                => '',
    'languages'             => '',
    'traits'                => [],
    'equipment_text'        => '',    // ligne Équipement → sera injectée en tête des traits
    'actions'               => [],
    'legendary_actions_count'=> 0,
    'legendary_actions_desc' => '',
    'legendary_actions'     => [],
    'bonus_actions'         => [],
    'reactions'             => [],
    'incantation'           => null,
  ];

  if (trim($texte) === '') return $result;

  $lignes = preg_split('/\r\n|\r|\n/', normaliserMinus($texte));
  $n      = count($lignes);

  // ── Détecter les numéros de ligne des titres de section ──
  $sections_norm = [
    'traits'    => ['traits', 'caracteristiques', 'traits et aptitudes'],
    'actions'   => ['actions'],
    'legendary' => ['actions legendaires'],
    'bonus'     => ['actions bonus'],
    'reactions' => ['reactions'],
    'equipment' => ['equipement'],
  ];

  $bloc = [];
  foreach ($lignes as $i => $ligne):
    $norm = normaliserRoll20(trim($ligne));
    foreach ($sections_norm as $type => $candidats):
      if (!isset($bloc[$type]) && in_array($norm, $candidats, true)):
        $bloc[$type] = $i;
      endif;
    endforeach;
  endforeach;

  // ── Header (lignes avant Traits) ─────────────────────
  $fin_header = $bloc['traits'] ?? $n;
  parseHeader($lignes, 0, $fin_header, $result);

  // Chaque section est bornée par la prochaine section qui la suit dans
  // le texte, quelle que soit l'ordre des sections dans mo_stats.
  // sentinelleBloc() cherche la première section positionnée APRÈS $apres,
  // ce qui couvre les formats non-standards (ex: Traits après Actions).

  // ── Header (lignes avant la première section détectée) ──────
  // $fin_header est déjà calculé plus haut.

  // ── Traits ────────────────────────────────────────────
  if (isset($bloc['traits'])):
    $debut = $bloc['traits'] + 1;
    $fin   = sentinelleBloc($bloc, $bloc['traits'], $n);
    $result['traits'] = parseActionBlock(array_slice($lignes, $debut, $fin - $debut), $result);
  endif;

  // ── Actions ───────────────────────────────────────────
  if (isset($bloc['actions'])):
    $debut = $bloc['actions'] + 1;
    $fin   = sentinelleBloc($bloc, $bloc['actions'], $n);
    $result['actions'] = parseActionBlock(array_slice($lignes, $debut, $fin - $debut), $result);
  endif;

  // ── Actions Légendaires ───────────────────────────────
  if (isset($bloc['legendary'])):
    $debut = $bloc['legendary'] + 1;
    $fin   = sentinelleBloc($bloc, $bloc['legendary'], $n);
    parseLegendaryBlock(array_slice($lignes, $debut, $fin - $debut), $result);
  endif;

  // ── Actions Bonus ─────────────────────────────────────
  if (isset($bloc['bonus'])):
    $debut = $bloc['bonus'] + 1;
    $fin   = sentinelleBloc($bloc, $bloc['bonus'], $n);
    $result['bonus_actions'] = parseActionBlock(array_slice($lignes, $debut, $fin - $debut), $result);
  endif;

  // ── Réactions ─────────────────────────────────────────
  if (isset($bloc['reactions'])):
    $debut = $bloc['reactions'] + 1;
    $fin   = sentinelleBloc($bloc, $bloc['reactions'], $n);
    $result['reactions'] = parseActionBlock(array_slice($lignes, $debut, $fin - $debut), $result);
  endif;

  // ── Équipement (section dédiée : "Équipement" seul sur sa ligne, suivi
  // d'un ou plusieurs paragraphes — distinct de la ligne d'en-tête
  // "Équipement : ..." gérée par parseOptionalLine). Le texte collecté
  // est stocké dans 'equipment_text', même champ que la forme ligne
  // d'en-tête, pour réutiliser sans changement la synthèse en trait
  // "Équipement" dans buildRoll20NpcJson(). Voir DECISIONS_LOG D-R24.
  if (isset($bloc['equipment'])):
    $debut     = $bloc['equipment'] + 1;
    $fin       = sentinelleBloc($bloc, $bloc['equipment'], $n);
    $eq_lignes = [];
    foreach (array_slice($lignes, $debut, $fin - $debut) as $eq_ligne):
      $eq_ligne = trim($eq_ligne);
      if ($eq_ligne !== '') $eq_lignes[] = $eq_ligne;
    endforeach;
    if (!empty($eq_lignes)):
      $result['equipment_text'] = implode("\n", $eq_lignes);
    endif;
  endif;

  return $result;
}

/**
 * Retourne la position de la prochaine section qui vient APRÈS $apres
 * dans le texte, en cherchant parmi toutes les sections détectées.
 * Rend le parsing indépendant de l'ordre des sections dans mo_stats
 * (ex: Traits après Actions, ou tout ordre non-standard).
 */
function sentinelleBloc(array $bloc, int $apres, int $defaut): int
{
  $min = $defaut;
  foreach ($bloc as $pos):
    if ($pos > $apres && $pos < $min):
      $min = $pos;
    endif;
  endforeach;
  return $min;
}

/**
 * Parse le header : type, CA, PV, Vitesse, FP, stats, lignes optionnelles.
 */
function parseHeader(array $lignes, int $debut, int $fin, array &$result): void
{
  $carac_lignes = [];
  $vu_ca        = false;

  for ($i = $debut; $i < $fin; $i++):
    $ligne = trim($lignes[$i]);
    if ($ligne === '') continue;

    // Ligne 0 : npc_type si elle ne commence pas par "CA "
    if ($i === $debut && !preg_match('/^CA\s+\d+/i', $ligne)):
      $result['npc_type'] = $ligne;
      continue;
    endif;

    // CA {n} Initiative {mod} ({score})
    if (preg_match('/^CA\s+(\d+)/i', $ligne, $m)):
      $result['ac'] = (int)$m[1];
      $vu_ca = true;
      continue;
    endif;

    // Pv {n} ({formule})
    if (preg_match('/^Pv\s+(\d+)\s+\(([^)]+)\)/i', $ligne, $m)):
      $result['hp_max']     = (int)$m[1];
      $result['hp_formula'] = trim($m[2]);
      continue;
    endif;

    // Vitesse {texte}
    if (preg_match('/^Vitesse\s+(.+)$/i', $ligne, $m)):
      $result['speed'] = trim($m[1]);
      continue;
    endif;

    // FP {X} (PX {Y} ; BM +{Z})  — format principal observé en base
    // FP {X} ({Y} PX; BM {Z})    — format alternatif
    if (preg_match('/^FP\s+(\S+)\s+\(PX\s+([\d\s\x{202F}]+?)\s*;\s*BM\s*[+\-]?(\d+)/iu', $ligne, $m)):
      $result['cr'] = trim($m[1]);
      $result['xp'] = (int)preg_replace('/[\s\x{202F}]/u', '', $m[2]);
      $result['pb'] = (int)$m[3];
      continue;
    elseif (preg_match('/^FP\s+(\S+)\s+\(([\d\s\x{202F}]+)PX\s*;\s*BM\s*[+\-]?(\d+)/iu', $ligne, $m)):
      $result['cr'] = trim($m[1]);
      $result['xp'] = (int)preg_replace('/[\s\x{202F}]/u', '', $m[2]);
      $result['pb'] = (int)$m[3];
      continue;
    endif;

    // Ligne de caractéristiques (For/Dex/Con ou Int/Sag/Cha)
    if (preg_match('/^(For|Dex|Con|Int|Sag|Cha)\s+\d+/u', $ligne)):
      parseCaracLine($ligne, $result);
      continue;
    endif;

    // Lignes optionnelles
    parseOptionalLine($ligne, $result);
  endfor;
}

/** Parse une ligne de caractéristiques : "For 21 +5 +5 Dex 9 -1 +3 Con 15 +2 +6". */
function parseCaracLine(string $ligne, array &$result): void
{
  $map = carAbbr2Roll20();
  if (!preg_match_all(
    '/(For|Dex|Con|Int|Sag|Cha)\s+(\d+)\s+([+-]\d+)\s+([+-]\d+)/u',
    $ligne, $mm, PREG_SET_ORDER
  )) return;

  foreach ($mm as $m):
    $key = $map[$m[1]] ?? null;
    if (!$key) continue;
    $result['stats'][$key] = [
      'score' => (int)$m[2],
      'mod'   => (int)$m[3],
      'save'  => (int)$m[4],
    ];
  endforeach;
}

/** Parse les lignes optionnelles du header (Compétences, Équipement, Résistances, Sens, Langues…).
 * Le deux-points séparateur est optionnel (les deux formats existent en base). */
function parseOptionalLine(string $ligne, array &$result): void
{
  $compMap = compFr2Roll20();

  // Compétences — avec ou sans ":"
  if (preg_match('/^Comp[eé]tences?\s*:?\s*(.+)$/iu', $ligne, $m)):
    foreach (preg_split('/,\s*/u', trim($m[1])) as $part):
      if (preg_match('/^(.+?)\s+([+-]\d+)$/u', trim($part), $mm)):
        $key = $compMap[normaliserRoll20($mm[1])] ?? null;
        if ($key) $result['skills'][$key] = (int)$mm[2];
      endif;
    endforeach;
    return;
  endif;

  // Équipement → stocké pour être converti en trait "Équipement"
  if (preg_match('/^[EÉ]quipement\s*:?\s*(.+)$/iu', $ligne, $m)):
    $result['equipment_text'] = trim($m[1]);
    return;
  endif;

  // Résistances / Immunités aux dégâts / Immunités aux états / Vulnérabilités — avec ou sans ":"
  if (preg_match('/^R[eé]sistances?\s+aux\s+d[eé]g[aâ]ts?\s*:?\s*(.+)$/iu', $ligne, $m)):
    $result['resistances'] = trim($m[1]); return;
  endif;
  if (preg_match('/^Immunit[eé]s?\s+aux\s+d[eé]g[aâ]ts?\s*:?\s*(.+)$/iu', $ligne, $m)):
    $result['immunities'] = trim($m[1]); return;
  endif;
  if (preg_match('/^Immunit[eé]s?\s+aux\s+[eé]tats?\s*:?\s*(.+)$/iu', $ligne, $m)):
    $result['condition_immunities'] = trim($m[1]); return;
  endif;
  if (preg_match('/^Vuln[eé]rabilit[eé]s?\s*:?\s*(.+)$/iu', $ligne, $m)):
    $result['vulnerabilities'] = trim($m[1]); return;
  endif;
  // Sens — avec ou sans ":"
  if (preg_match('/^Sens\s*:?\s*(.+)$/iu', $ligne, $m)):
    $result['senses'] = trim($m[1]); return;
  endif;
  // Langues — avec ou sans ":"
  if (preg_match('/^Langues?\s*:?\s*(.+)$/iu', $ligne, $m)):
    $result['languages'] = trim($m[1]); return;
  endif;
}

/**
 * Parse un bloc d'actions/traits (chaque action sur une ligne).
 * Gère le cas spécial du bloc "Incantation" (multi-lignes de sorts).
 */
/**
 * Extrait les noms de sorts mentionnés dans une ligne libre (action, bonus, réaction).
 * Supporte deux formats :
 *   Format liste : "lance les sorts suivants... : sort1, sort2 ou sort3"
 *   Format unique : "lance le sort arme spirituelle avec..."
 *
 * Les notes entre parenthèses sont supprimées avant retour.
 * Retourne [] si aucun sort détecté.
 */
function extraireNomsSortsLigneLibre(string $texte): array
{
  $noms = [];

  // Format liste : colon suivi de noms séparés par "," ou " ou "
  if (preg_match('/lance\s+(?:l.?un\s+des\s+|le[s]?\s+)sort[s]?[^:]{0,140}:\s*(.+)$/iu', $texte, $m)):
    $liste = rtrim(trim($m[1]), '.');
    foreach (preg_split('/,\s*|\s+ou\s+/iu', $liste) as $part):
      $nom = rtrim(trim(preg_replace('/\s*\([^)]*\)/', '', trim($part))), '.');
      if ($nom !== '') $noms[] = $nom;
    endforeach;
    return $noms;
  endif;

  // Format sort unique : "lance le sort {nom} avec|en|.|,"
  if (preg_match('/lance le sort\s+([\p{L}\s\-]+?)(?:\s+avec|\s+en\s|[.,]|$)/iu', $texte, $m)):
    $nom = rtrim(trim($m[1]), '.');
    if ($nom !== '') $noms[] = $nom;
  endif;

  return $noms;
}

function parseActionBlock(array $lignes, array &$result): array
{
  $actions = [];
  $i       = 0;
  $n       = count($lignes);

  while ($i < $n):
    $ligne = trim($lignes[$i]);
    if ($ligne === '' || $ligne === '***') { $i++; continue; }

    // Pattern : "Nom. Description..."
    if (!preg_match('/^(.{2,120}?)\.\s+(.{2,})/su', $ligne, $m)):
      $i++; continue;
    endif;

    $nom  = trim($m[1]);
    $desc = trim($m[2]);

    // Cas spécial : bloc Incantation (sous-listes sur les lignes suivantes)
    if (normaliserRoll20($nom) === 'incantation'):
      $inc_lines = [$ligne];
      $i++;
      while ($i < $n):
        $next = trim($lignes[$i]);
        // Sous-liste de sorts : deux séparateurs supportés
        //   Format ":"  : "À volonté : lumière, thaumaturgie"
        //   Format " - ": "Tour de magie - assistance, lumière"
        //                 "Niveau 1 (3/J) - blessure, injonction"
        if (estPrefixeSousListeSorts($next)):
          $inc_lines[] = $next;
          $i++;
          continue;
        endif;
        break;  // fin du bloc Incantation
      endwhile;

      $full_text = implode("\n", $inc_lines);
      parseIncantation($full_text, $result);
      $actions[] = [
        'name'           => $nom,
        'description'    => $full_text,
        'has_attack'     => false,
        'is_incantation' => true,
      ];
      continue;
    endif;

    $action = parseAction($nom, $desc);

    // Chercher des sorts dans toute action/bonus/réaction (ex: "lance les sorts
    // suivants ... : sort1, sort2"). Permet de récupérer les sorts déclarés
    // hors du bloc principal "Incantation." (Actions Bonus, Réactions, etc.).
    $noms_inline = extraireNomsSortsLigneLibre($desc);
    if (!empty($noms_inline)):
      if ($result['incantation'] === null):
        // Pas de bloc Incantation principal : créer une structure minimale
        $result['incantation'] = [
          'full_text'  => $nom . '. ' . $desc,
          'carac'      => 'wisdom',
          'save_dc'    => 0,
          'noms_sorts' => [],
        ];
      endif;
      foreach ($noms_inline as $_ns):
        if (!in_array($_ns, $result['incantation']['noms_sorts'], true)):
          $result['incantation']['noms_sorts'][] = $_ns;
        endif;
      endforeach;
    endif;

    $actions[] = $action;
    $i++;
  endwhile;

  return $actions;
}

/**
 * Parse une action individuelle. Retourne la structure Roll20 correspondante.
 * TYPE A : attaque au corps à corps ou à distance.
 * TYPE B : description pure (sort, multiattaque, JS…).
 */
function parseAction(string $nom, string $desc): array
{
  $action = [
    'name'         => $nom,
    'description'  => $desc,
    'has_attack'   => false,
    'attack_type'  => '',
    'tohit'        => 0,
    'range'        => '',
    'target'       => 'one target',
    'damage'       => '',
    'damage_type'  => '',
    'damage2'      => '',
    'damage_type2' => '',
    'crit'         => '',
    'crit2'        => '',
    'onhit'        => '',
  ];

  $is_melee  = (bool)preg_match('/Corps\s+à\s+corps/iu', $desc);
  $is_ranged = (bool)preg_match('/[AÀ]\s+distance/iu', $desc);
  if (!$is_melee && !$is_ranged) return $action;

  $action['has_attack']  = true;
  $action['attack_type'] = $is_melee ? 'Melee' : 'Ranged';

  // Bonus toucher : "+N," après le premier ":"
  if (preg_match('/:\s*\+(\d+)\s*,/u', $desc, $m)):
    $action['tohit'] = (int)$m[1];
  endif;

  // Portée
  if ($is_melee && preg_match('/allonge\s+([\d,\.]+\s*m[^,.]*)/iu', $desc, $m)):
    $action['range'] = trim($m[1]);
  elseif (!$is_melee && preg_match('/port[eé]e\s+([\d,\.\/\s]+m[^,.]*)/iu', $desc, $m)):
    $action['range'] = trim($m[1]);
  endif;

  // Dégâts principaux
  // Formats supportés :
  //   "Touché : 6 (1d6 + 3) dégâts contondants"
  //   "En cas de coup réussi : 16 (2d10 + 5) points de dégâts psychiques"
  if (preg_match(
    '/(Touch[eé]|En cas de coup r[eé]ussi)\s*:\s*(\d+)\s*\(([^)]+)\)\s+(?:points de\s+)?d[eé]g[aâ]ts?\s+([\p{L}]+)/iu',
    $desc, $m
  )):
    $formula               = trim($m[3]);
    $type                  = trim($m[4]);
    $action['damage']      = $formula;
    $action['damage_type'] = $type;
    $action['onhit']       = $m[2] . ' (' . $formula . ') dégâts ' . $type;
    // Dés de critique = dés de la formule sans le modificateur fixe
    $action['crit'] = trim(preg_replace('/\s*[+-]\s*\d+\s*$/', '', $formula));
  endif;

  // Dégâts secondaires : "plus {avg} ({formule2}) dégâts {type2}"
  if (preg_match('/plus\s+\d+\s*\(([^)]+)\)\s+d[eé]g[aâ]ts?\s+([\p{L}]+)/iu', $desc, $m)):
    $formula2              = trim($m[1]);
    $action['damage2']     = $formula2;
    $action['damage_type2']= trim($m[2]);
    $action['crit2']       = trim(preg_replace('/\s*[+-]\s*\d+\s*$/', '', $formula2));
  endif;

  return $action;
}

/**
 * Parse le bloc "Incantation." et remplit $result['incantation'].
 * Extrait la caractéristique d'incantation, le DD et la liste des noms de sorts.
 */
function parseIncantation(string $texte, array &$result): void
{
  $inc = [
    'full_text'  => $texte,
    'carac'      => 'intelligence',
    'save_dc'    => 0,
    'noms_sorts' => [],
  ];

  // Caractéristique d'incantation
  foreach (['Force','Dextérité','Constitution','Intelligence','Sagesse','Charisme'] as $car):
    if (mb_stripos($texte, $car . ' étant') !== false
     || mb_stripos($texte, 'la ' . mb_strtolower($car)) !== false):
      $inc['carac'] = normaliserRoll20($car);
      break;
    endif;
  endforeach;

  // DD de sauvegarde
  // \D{0,30}? plutôt que \s+ : tolère du texte entre "sauvegarde" et le chiffre
  // (ex : "DD de sauvegarde des sorts 14", "DD de sauvegarde de sorts 14"),
  // formulation standard des blocs stat officiels traduits — pas seulement
  // "DD de sauvegarde 14". Borné à 30 caractères pour éviter d'accrocher un
  // chiffre sans rapport plus loin dans le texte si "sauvegarde" apparaît
  // sans DD à proximité (comportement de repli identique : save_dc reste 0).
  if (preg_match('/DD\s+de\s+sauvegarde\D{0,30}?(\d+)/iu', $texte, $m)):
    $inc['save_dc'] = (int)$m[1];
  endif;

  // Sous-listes : deux séparateurs supportés (voir estPrefixeSousListeSorts)
  //   Format ":"  : "À volonté : lumière"   "1/jour : boule de feu"
  //   Format " - ": "Tour de magie - lumière" "Niveau 1 (3/J) - blessure"
  foreach (preg_split('/\r?\n/', $texte) as $sl):
    $sl = trim($sl);
    if (!estPrefixeSousListeSorts($sl)) continue;
    // Extraire la partie "noms" après le séparateur
    if (preg_match('/^.+?[:\-]\s*(.+)$/u', $sl, $m)):
      foreach (preg_split('/,\s*/u', trim($m[1])) as $nom):
        // Supprimer les notes entre parenthèses : "(compris dans la CA)", "(au 4e niveau)"…
        $nom = trim(preg_replace('/\s*\([^)]*\)/', '', trim($nom)));
        if ($nom !== '') $inc['noms_sorts'][] = $nom;
      endforeach;
    endif;
  endforeach;

  $result['incantation'] = $inc;
}

/**
 * Parse le bloc "Actions Légendaires".
 * Sépare le texte d'introduction des actions individuelles.
 */
function parseLegendaryBlock(array $lignes, array &$result): void
{
  $intro   = [];
  $actions = [];

  foreach ($lignes as $ligne):
    $ligne = trim($ligne);
    if ($ligne === '') continue;

    // Tenter de reconnaître "Nom. Description..." comme action légendaire
    // Heuristique : nom court (< 60 chars), sans point intermédiaire dans le nom
    if (preg_match('/^([^.]{2,60})\.\s+(.{5,})/su', $ligne, $m)):
      $nom  = trim($m[1]);
      $desc = trim($m[2]);
      // Si aucun intro encore : cette ligne fait partie de l'intro
      // Si c'est déjà défini ou si la ligne ressemble à une action légendaire
      // (nom court sans verbe d'intro), on l'ajoute comme action
      if (!empty($intro) || !preg_match('/^Utilisations/iu', $ligne)):
        // La première ligne contenant "Utilisations" = intro
        if (preg_match('/^Utilisations/iu', $ligne)):
          // Extraire le nb d'actions légendaires
          if (preg_match('/:\s*(\d+)/u', $ligne, $cnt)):
            $result['legendary_actions_count'] = (int)$cnt[1];
          endif;
          $intro[] = $ligne;
        else:
          $actions[] = parseAction($nom, $desc);
        endif;
        continue;
      endif;
    endif;

    // Ligne d'intro
    if (preg_match('/^Utilisations/iu', $ligne)):
      if (preg_match('/:\s*(\d+)/u', $ligne, $cnt)):
        $result['legendary_actions_count'] = (int)$cnt[1];
      endif;
    endif;
    $intro[] = $ligne;
  endforeach;

  $result['legendary_actions_desc'] = implode(' ', $intro);
  $result['legendary_actions']      = $actions;
}


// ════════════════════════════════════════════════════════
// FETCH SORTS DEPUIS dd_sorts
// ════════════════════════════════════════════════════════

/**
 * Récupère les données complètes des sorts pour un sous-ensemble de noms.
 * Passe 1 : index léger name→id (tous sorts du ruleset).
 * Passe 2 : données complètes (TEXT inclus) pour les IDs trouvés.
 */
function fetchSortsByName(PDO $db, array $noms, int $ruleset_id): array
{
  if (empty($noms)) return [];

  // Normaliser les noms recherchés
  $noms_norm = [];
  foreach ($noms as $nom):
    $noms_norm[normaliserRoll20($nom)] = $nom;
  endforeach;

  // Passe 1 : index léger
  $stmt = $db->prepare('
    SELECT so_id, so_nom
    FROM   dd_sorts
    WHERE  so_ruleset_var_id = ?
      AND  so_camp_id IS NULL
  ');
  $stmt->execute([$ruleset_id]);

  $ids = [];
  foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $row):
    $cle = normaliserRoll20((string)$row['so_nom']);
    if (isset($noms_norm[$cle])):
      $ids[$cle] = (int)$row['so_id'];
    endif;
  endforeach;

  if (empty($ids)) return [];

  // Passe 2 : données complètes
  $ph   = implode(',', array_fill(0, count($ids), '?'));
  $stmt = $db->prepare("
    SELECT so.so_id, so.so_nom, so.so_niveau, so.so_description,
           so.so_duree_incantation, so.so_duree_sort, so.so_portee,
           so.so_concentration, so.so_rituel,
           so.so_vocal, so.so_gestuel, so.so_materiel, so.so_composante,
           co.co_nom AS college_nom
    FROM   dd_sorts so
    LEFT JOIN dd_colleges co ON co.co_id = so.so_co_id
    WHERE  so.so_id IN ($ph)
  ");
  $stmt->execute(array_values($ids));

  $sorts = [];
  foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $row):
    $cle = normaliserRoll20((string)$row['so_nom']);
    $sorts[$cle] = $row;
  endforeach;
  return $sorts;
}


// ════════════════════════════════════════════════════════
// BUILD JSON ROLL20
// ════════════════════════════════════════════════════════

/**
 * Construit le tableau JSON complet au format Roll20 NPC.
 */
function buildRoll20NpcJson(array $mo, array $parsed, array $sorts): array
{
  $attrs  = [];
  $mo_nom = (string)$mo['mo_nom'];

  // ── Identité ────────────────────────────────────────
  attr($attrs, 'charactersheet_type', 'npc');
  attr($attrs, 'npc',                  '1');
  attr($attrs, 'npc_name',             $mo_nom);
  attr($attrs, 'npc_name_flag',        '{{name=@{npc_name}}}');
  attr($attrs, 'npc_options-flag',     'on');
  attr($attrs, 'charname_output',      '{{charname=@{npc_name}}}');
  attr($attrs, 'npc_type',             $parsed['npc_type']);
  attr($attrs, 'rtype',                '@{advantagetoggle}');
  // wtype = "Chuchoter les jets au MJ" : valeur littérale '/w gm '
  // (et non une référence @{whispertoggle}, qui correspondrait au mode "Bascule").
  // C'est la même valeur que produit la commande API !setattr --wtype|/w gm
  attr($attrs, 'wtype',                '/w gm ');

  // ── CA ──────────────────────────────────────────────
  $ac = $parsed['ac'] ?: 10;
  attr($attrs, 'ac',                   $ac);
  attr($attrs, 'npc_ac',               (string)$ac);
  attr($attrs, 'npc_actype',           '');
  attr($attrs, 'armorwarningflag',     'hide');
  attr($attrs, 'customacwarningflag',  'hide');

  // ── HP ──────────────────────────────────────────────
  attr($attrs, 'hp',           '', (string)$parsed['hp_max']);
  attr($attrs, 'npc_hpformula', $parsed['hp_formula']);

  // ── Initiative ────────────────────────────────────
  // Fiche 2014 : initiative = DEX_mod + DEX_score/100 (tie-breaker)
  $dex_s   = $parsed['stats']['dexterity']['score'] ?? 10;
  $dex_mod = $parsed['stats']['dexterity']['mod']   ?? (int)floor(($dex_s - 10) / 2);
  $init    = round($dex_mod + $dex_s / 100, 2);
  attr($attrs, 'initiative_bonus', $init);
  attr($attrs, 'init_tiebreaker',  '@{dexterity}/100');

  // ── Vitesse ──────────────────────────────────────
  attr($attrs, 'npc_speed', $parsed['speed']);

  // ── FP / XP / BM ─────────────────────────────────
  $cr = $parsed['cr'] ?: (string)($mo['mo_fp_id'] ?? '');
  $pb = max(2, (int)$parsed['pb']);
  attr($attrs, 'npc_challenge', $cr);
  attr($attrs, 'npc_xp',        $parsed['xp']);
  attr($attrs, 'npc_pb',        (string)$pb);
  attr($attrs, 'pb',            $pb);
  attr($attrs, 'pb_type',       'custom');
  attr($attrs, 'pb_custom',     $pb);
  attr($attrs, 'pbd_safe',      '');

  // ── Caractéristiques ─────────────────────────────
  addAbilityScores($attrs, $parsed['stats']);

  // ── Sauvegardes NPC ──────────────────────────────
  addNpcSaves($attrs, $parsed['stats']);

  // ── Compétences NPC ──────────────────────────────
  addNpcSkills($attrs, $parsed['stats'], $parsed['skills'], $pb);

  // ── Immunités / Résistances ──────────────────────
  attr($attrs, 'npc_resistances',          $parsed['resistances']);
  attr($attrs, 'npc_immunities',           $parsed['immunities']);
  attr($attrs, 'npc_condition_immunities', $parsed['condition_immunities']);
  attr($attrs, 'npc_vulnerabilities',      $parsed['vulnerabilities']);
  attr($attrs, 'npc_senses',               $parsed['senses']);
  attr($attrs, 'npc_languages',            $parsed['languages']);

  // ── Actions légendaires ──────────────────────────
  attr($attrs, 'npc_legendary_actions',      $parsed['legendary_actions_count']);
  attr($attrs, 'npc_legendary_actions_desc', $parsed['legendary_actions_desc']);
  attr($attrs, 'npc_mythic_actions',         0);
  attr($attrs, 'npc_mythic_actions_desc',    '');

  // ── Flags de sections ────────────────────────────
  attr($attrs, 'npcspellcastingflag', $parsed['incantation'] !== null ? '1' : '0');
  attr($attrs, 'npcbonusactionsflag', !empty($parsed['bonus_actions']) ? '1' : '0');
  attr($attrs, 'npcreactionsflag',    !empty($parsed['reactions'])     ? '1' : '0');

  // ── Sorts : DC et bonus d'attaque ────────────────
  if ($parsed['incantation'] !== null):
    $inc     = $parsed['incantation'];
    $ability = carac2SpellAbility($inc['carac']);
    attr($attrs, 'spellcasting_ability', $ability);
    attr($attrs, 'spell_save_dc',        $inc['save_dc'] ?: 0);
    attr($attrs, 'spell_attack_bonus',   max(0, ($inc['save_dc'] ?: 8) - 8));
  else:
    attr($attrs, 'spellcasting_ability', '@{intelligence_mod}+');
    attr($attrs, 'spell_save_dc',        0);
    attr($attrs, 'spell_attack_bonus',   0);
  endif;
  attr($attrs, 'spell_attack_mod', 0);
  attr($attrs, 'spell_dc_mod',     0);
  attr($attrs, 'caster_level',     0);

  // ── Divers constants ─────────────────────────────
  attr($attrs, 'version',              4.21);
  attr($attrs, 'sheet_version',        1);
  attr($attrs, 'dtype',                'full');
  attr($attrs, 'death_save_bonus',     0);
  attr($attrs, 'global_attack_mod',    '');
  attr($attrs, 'global_attack_mod_flag','1');
  attr($attrs, 'global_damage_mod_flag','1');
  attr($attrs, 'global_damage_mod_roll','');
  attr($attrs, 'global_damage_mod_type','');
  attr($attrs, 'global_save_mod_flag', '1');
  attr($attrs, 'global_skill_mod_flag','1');
  attr($attrs, 'token_size',           '1');
  attr($attrs, 'ammotracking',         'off');
  attr($attrs, 'encumberance_setting', 'on');

  // ── Sections répétées ────────────────────────────

  // Traits (+ trait "Équipement" synthétisé depuis le header si présent)
  $traits_a_rendre = $parsed['traits'];
  if (!empty($parsed['equipment_text'])):
    array_unshift($traits_a_rendre, [
      'name'        => 'Équipement',
      'description' => $parsed['equipment_text'],
      'has_attack'  => false,
    ]);
  endif;

  $repord_traits = [];
  foreach ($traits_a_rendre as $t):
    $tid = firebaseId();
    $repord_traits[] = $tid;
    $pref = "repeating_npctrait_{$tid}_";
    attr($attrs, $pref . 'name',             $t['name']);
    attr($attrs, $pref . 'description',      $t['description']);
    attr($attrs, $pref . 'npc_options-flag', 0);
  endforeach;
  if (!empty($repord_traits)):
    attr($attrs, '_reporder_repeating_npctrait', implode(',', $repord_traits));
  endif;

  // Actions
  $repord_actions = [];
  $action_names   = [];
  foreach ($parsed['actions'] as $a):
    $aid = firebaseId();
    $repord_actions[] = $aid;
    $action_names[]   = $a['name'];
    addNpcActionAttrs($attrs, $aid, 'repeating_npcaction', $a);
  endforeach;
  if (!empty($repord_actions)):
    attr($attrs, '_reporder_repeating_npcaction', implode(',', $repord_actions));
  endif;
  attr($attrs, 'npcactionlist', implode('|', $action_names));

  // Actions Légendaires
  if (!empty($parsed['legendary_actions'])):
    $repord_leg = [];
    foreach ($parsed['legendary_actions'] as $a):
      $lid = firebaseId();
      $repord_leg[] = $lid;
      addNpcActionAttrs($attrs, $lid, 'repeating_npcaction-l', $a);
    endforeach;
    if (!empty($repord_leg)):
      attr($attrs, '_reporder_repeating_npcaction-l', implode(',', $repord_leg));
    endif;
  endif;

  // Actions Bonus
  if (!empty($parsed['bonus_actions'])):
    $repord_bonus = [];
    foreach ($parsed['bonus_actions'] as $a):
      $bid = firebaseId();
      $repord_bonus[] = $bid;
      addNpcActionAttrs($attrs, $bid, 'repeating_npcbonusaction', $a);
    endforeach;
    if (!empty($repord_bonus)):
      attr($attrs, '_reporder_repeating_npcbonusaction', implode(',', $repord_bonus));
    endif;
  endif;

  // Réactions
  if (!empty($parsed['reactions'])):
    $repord_react = [];
    foreach ($parsed['reactions'] as $a):
      $rid = firebaseId();
      $repord_react[] = $rid;
      addNpcActionAttrs($attrs, $rid, 'repeating_npcreaction', $a);
    endforeach;
    if (!empty($repord_react)):
      attr($attrs, '_reporder_repeating_npcreaction', implode(',', $repord_react));
    endif;
  endif;

  // Sorts (si lanceur de sorts)
  if ($parsed['incantation'] !== null && !empty($sorts)):
    addSpellAttrs($attrs, $sorts, $parsed['incantation']);
  endif;

  return [
    'character'  => ['id' => firebaseId(), 'name' => $mo_nom, 'avatar' => ''],
    'attributes' => $attrs,
  ];
}


// ════════════════════════════════════════════════════════
// HELPERS BUILD — CARACTÉRISTIQUES ET COMPÉTENCES
// ════════════════════════════════════════════════════════

/** Ajoute les 6 caractéristiques et leurs modificateurs. */
function addAbilityScores(array &$attrs, array $stats): void
{
  $caracs = ['strength','dexterity','constitution','intelligence','wisdom','charisma'];
  foreach ($caracs as $car):
    $s   = $stats[$car]['score'] ?? 10;
    $mod = $stats[$car]['mod']   ?? (int)floor(($s - 10) / 2);
    attr($attrs, $car,                   $s);
    attr($attrs, $car . '_base',         (string)$s);
    attr($attrs, $car . '_mod',          $mod);
    attr($attrs, $car . '_flag',         0);
    // Marqueur négatif (utilisé par les macros Roll20)
    $abbr = carNom2Abbr($car);
    attr($attrs, 'npc_' . $abbr . '_negative', $mod < 0 ? 1 : 0);
  endforeach;
}

/** Ajoute les sauvegardes NPC (triple champ par caractéristique + roll). */
function addNpcSaves(array &$attrs, array $stats): void
{
  $caracs_save = [
    'strength'    => 'str', 'dexterity'    => 'dex',
    'constitution'=> 'con', 'intelligence' => 'int',
    'wisdom'      => 'wis', 'charisma'     => 'cha',
  ];

  $shown = 0;
  foreach ($caracs_save as $car => $abbr):
    $mod  = $stats[$car]['mod']  ?? 0;
    $save = $stats[$car]['save'] ?? $mod;
    $flag = ($save !== $mod) ? 1 : 0;
    if ($flag) $shown++;

    attr($attrs, 'npc_' . $abbr . '_save',       $save);
    attr($attrs, 'npc_' . $abbr . '_save_base',  avecSigne($save));
    attr($attrs, 'npc_' . $abbr . '_save_flag',  $flag);
    attr($attrs, $car . '_save_bonus',            $save);
    attr($attrs, $car . '_save_roll',             buildSaveRoll($car, $save));
  endforeach;
  attr($attrs, 'npc_saving_flag', $shown);
  attr($attrs, 'death_save_bonus', 0);
}

/** Construit la macro roll pour une sauvegarde NPC. */
function buildSaveRoll(string $car, int $bonus): string
{
  return "@{wtype}&{template:simple} {{rname=^{{$car}-save-u}}} {{mod=@{{$car}_save_bonus}}}"
       . " {{r1=[[@{d20}+@{{$car}_save_bonus}@{pbd_safe}]]}} @{advantagetoggle}"
       . "+@{{$car}_save_bonus}@{pbd_safe}]]}} {{global=@{global_save_mod}}} @{charname_output}";
}

/** Ajoute les compétences NPC (npc_{comp}, _base, _flag + roll). */
function addNpcSkills(array &$attrs, array $stats, array $skills, int $pb): void
{
  $compCar = compCar();
  $shown   = 0;

  foreach ($compCar as $comp => $car):
    $car_mod = $stats[$car]['mod'] ?? 0;

    if (isset($skills[$comp])):
      $val = $skills[$comp];
      // Détecter expertise vs maîtrise
      $exp_prof = $car_mod + $pb;
      $exp_exp  = $car_mod + 2 * $pb;
      $flag = ($val === $exp_exp) ? 2 : 1;
      $shown++;
    else:
      $val  = $car_mod;
      $flag = 0;
    endif;

    attr($attrs, 'npc_' . $comp,           $flag > 0 ? $val : '');
    attr($attrs, 'npc_' . $comp . '_base', $flag > 0 ? avecSigne($val) : '');
    attr($attrs, 'npc_' . $comp . '_flag', $flag);
    attr($attrs, $comp . '_bonus',         $val);
    attr($attrs, $comp . '_roll',          buildSkillRoll($comp, $car, $val));
  endforeach;

  attr($attrs, 'npc_skills_flag', $shown);

  // Perception passive
  $wis_mod = $stats['wisdom']['mod'] ?? 0;
  $perc    = $skills['perception'] ?? $wis_mod;
  attr($attrs, 'passive_wisdom', 10 + $perc);
}

/** Construit la macro roll pour une compétence NPC. */
function buildSkillRoll(string $comp, string $car, int $bonus): string
{
  $b = avecSigne($bonus);
  return "@{wtype}&{template:simple} {{rname=^{{$comp}-u}}} {{mod=@{{$comp}_bonus}}}"
       . " {{r1=[[@{d20}{$b}[{$car}]@{pbd_safe}]]}} @{advantagetoggle}{$b}[{$car}]@{pbd_safe}]]}}"
       . " {{global=@{global_skill_mod}}} @{charname_output}";
}


// ════════════════════════════════════════════════════════
// HELPERS BUILD — ACTIONS NPC
// ════════════════════════════════════════════════════════

/** Ajoute tous les attributs Roll20 d'une action NPC dans $attrs. */
function addNpcActionAttrs(array &$attrs, string $id, string $section, array $action): void
{
  $pref = "{$section}_{$id}_";

  attr($attrs, $pref . 'name',             $action['name']);
  attr($attrs, $pref . 'description',      $action['description']);
  attr($attrs, $pref . 'npc_options-flag', 0);

  if (!empty($action['has_attack'])):
    $tohit = (int)$action['tohit'];
    $type  = $action['attack_type'];  // "Melee" / "Ranged"
    $range = $action['range'];
    $dir   = ($type === 'Melee') ? 'allonge' : 'portée';

    attr($attrs, $pref . 'attack_flag',         'on');
    attr($attrs, $pref . 'attack_type',         $type);
    attr($attrs, $pref . 'attack_tohit',        $tohit);
    attr($attrs, $pref . 'attack_tohitrange',   '+' . $tohit . ', ' . $dir . ' ' . $range . ', one target');
    attr($attrs, $pref . 'attack_range',        $range);
    attr($attrs, $pref . 'attack_target',       $action['target']);
    attr($attrs, $pref . 'attack_damage',       $action['damage']);
    attr($attrs, $pref . 'attack_damagetype',   $action['damage_type']);
    attr($attrs, $pref . 'attack_damage2',      $action['damage2']);
    attr($attrs, $pref . 'attack_damagetype2',  $action['damage_type2']);
    attr($attrs, $pref . 'attack_crit',         $action['crit']);
    attr($attrs, $pref . 'attack_crit2',        $action['crit2']);
    attr($attrs, $pref . 'attack_onhit',        $action['onhit']);
    attr($attrs, $pref . 'attack_display_flag', '{{attack=1}}');
    attr($attrs, $pref . 'attack_options',      '{{attack=1}}');

    $dmg_flag = '{{damage=1}} {{dmg1flag=1}} ';
    if (!empty($action['damage2'])) $dmg_flag .= '{{dmg2flag=1}} ';
    attr($attrs, $pref . 'damage_flag', $dmg_flag);

    // rollbase template ② (attaque)
    attr($attrs, $pref . 'rollbase',
      '@{wtype}&{template:npcfullatk} {{attack=1}} @{damage_flag} @{npc_name_flag}'
      . ' {{rname=@{name}}} {{r1=[[@{d20}+(@{attack_tohit}+0)]]}}'
      . ' @{rtype}+(@{attack_tohit}+0)]]}} {{dmg1=[[@{attack_damage}+0]]}}'
      . ' {{dmg1type=@{attack_damagetype}}} {{dmg2=[[@{attack_damage2}+0]]}}'
      . ' {{dmg2type=@{attack_damagetype2}}} {{crit1=[[@{attack_crit}+0]]}}'
      . ' {{crit2=[[@{attack_crit2}+0]]}} {{description=@{show_desc}}} @{charname_output}'
    );
  else:
    // rollbase template ① (description uniquement)
    attr($attrs, $pref . 'attack_tohitrange', '+0');
    attr($attrs, $pref . 'damage_flag',       '');
    attr($attrs, $pref . 'attack_onhit',      '');
    attr($attrs, $pref . 'rollbase',
      '@{wtype}&{template:npcaction} @{npc_name_flag}'
      . ' {{rname=@{name}}} {{description=@{show_desc}}} @{charname_output}'
    );
  endif;
}


// ════════════════════════════════════════════════════════
// HELPERS BUILD — SORTS NPC
// ════════════════════════════════════════════════════════

/** Ajoute les entrées repeating_spell-N pour les sorts d'un PNJ lanceur. */
function addSpellAttrs(array &$attrs, array $sorts, array $incantation): void
{
  $ability = carac2SpellAbility($incantation['carac']);
  $dc      = $incantation['save_dc'] ?? 0;
  $repords = [];

  foreach ($sorts as $nom_norm => $sort):
    $niveau    = (int)($sort['so_niveau'] ?? 0);
    $level_key = ($niveau === 0) ? 'cantrip' : (string)$niveau;
    $sid       = firebaseId();
    $pref      = "repeating_spell-{$level_key}_{$sid}_";
    $school    = college2Roll20((string)($sort['college_nom'] ?? ''));

    attr($attrs, $pref . 'spellname',         $sort['so_nom']);
    attr($attrs, $pref . 'spellschool',        $school);
    attr($attrs, $pref . 'spellcastingtime',   $sort['so_duree_incantation'] ?? '');
    attr($attrs, $pref . 'spellduration',      $sort['so_duree_sort'] ?? '');
    attr($attrs, $pref . 'spellrange',         $sort['so_portee'] ?? '');
    attr($attrs, $pref . 'spelldescription',   $sort['so_description'] ?? '');
    attr($attrs, $pref . 'spell_ability',      $ability);
    attr($attrs, $pref . 'spelloutput',        'SPELLCARD');
    attr($attrs, $pref . 'spellprepared',      '1');
    attr($attrs, $pref . 'details-flag',       '0');
    attr($attrs, $pref . 'options-flag',       '0');
    attr($attrs, $pref . 'roll_output_dc',     $dc);

    if (!empty($sort['so_concentration'])):
      attr($attrs, $pref . 'spellconcentration', '{{concentration=1}}');
    endif;
    if (!empty($sort['so_rituel'])):
      attr($attrs, $pref . 'spellritual', '{{ritual=1}}');
    endif;
    if (!empty($sort['so_composante'])):
      attr($attrs, $pref . 'spellcomp_materials', $sort['so_composante']);
    endif;

    $repords[$level_key][] = $sid;
  endforeach;

  foreach ($repords as $level_key => $ids):
    attr($attrs, '_reporder_repeating_spell-' . $level_key, implode(',', $ids));
  endforeach;
}
