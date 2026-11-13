<?php
// include/liens-compendium-parser.php — Liens vers sorts, dons et objets magiques (SP-GL5)
// ============================================================
// Transforme, dans un texte HTML issu de TinyMCE (om_description), les renvois à
// d'autres entrées du compendium en liens cliquables :
//
//   <span class="mo-lien" data-type="sort" data-id="123">Boule de feu</span>
//
// C'est le même lien que celui du bloc de stats des monstres (monstre-parser.php) :
// le handler de clic est dans js/main.js (délégué, .mo-lien), il ouvre la fiche dans
// #detail-pp-sub. Il lit la base d'URL sur un ancêtre [data-detail-base] : le conteneur
// qui reçoit ce HTML doit le porter.
//
// POURQUOI UNE SYNTAXE À PART — les tags du monstre-parser (#don#, $sort$, &objet&,
// @id@, %id%) supposent un texte brut. Dans du HTML, « & » ouvre une entité, « # » en
// fait partie (&#039;) et « $ » / « % » servent aux prix et aux pourcentages.
//
// TAGS EXPLICITES (toujours résolus, insensibles à la casse et aux accents) :
//   [[sort:Boule de feu]]               [[don:Création d'anneaux magiques]]
//   [[objet:Anneau de protection]]      [[sort:Boule de feu|boules de feu]]  (libellé affiché)
//   Nom inconnu -> le tag est restitué tel quel, dans un <span class="reg-tab__manquant">.
//
// LIAISON AUTOMATIQUE PAR NOM (objets, sorts, dons — dans cet ordre de priorité) :
//   1. PREMIÈRE OCCURRENCE seulement, par cible. Un tag explicite compte comme première
//      occurrence : aucun doublon n'est ajouté devant lui.
//   2. CASSE EXACTE du nom en base (« Boule de feu » dans une liste de pouvoirs), comme
//      le glossaire : les noms de sorts sont des mots courants (Lumière, Charme, Sommeil).
//   3. EXCEPTION — un paragraphe qui commence par « Création » (« Création. Conditions :
//      Création d'anneaux magiques, boule de feu… ») ne liste que des dons et des sorts :
//      la casse n'y est plus exigée.
//   4. Longueur minimale MO_LONGUEUR_MIN (monstre-parser.php).
//
// ZONES EXCLUES : celles du glossaire (<a>, <code>, <pre>, <table>, <h1>–<h6>…) et les
// tags [[tab:…]] / [[liste:…]]. Le glossaire n'entre pas dans l'index : il a son propre
// parser (glossaire-parser.php), appelé AVANT celui-ci par rendreTexteEnrichi().
//
// Référence : doc/ARCHITECTURE_0_REFERENCE.md §9d — DECISIONS_LOG [2026-11-10] SP-GL5

require_once __DIR__ . '/helpers.php';
require_once __DIR__ . '/glossaire-parser.php';
require_once __DIR__ . '/monstre-parser.php';

// Tag explicite : 1 = type, 2 = nom, 3 = libellé (optionnel).
define('LC_TAG_MOTIF', '\[\[(sort|don|objet):([^\[\]|]{1,160})(?:\|([^\[\]]{1,160}))?\]\]');

// ============================================================
// 1. INDEX DES CIBLES
// ============================================================
// chargerIndexMonstre() : sorts, dons, objets du ruleset, limités aux sources actives
// et hors contenu de campagne. Un cache par requête évite de relire des milliers de
// noms si plusieurs textes sont rendus.

function lcChargerIndex(PDO $db, int $ruleset_id): array
{
  static $cache = [];
  $res_ids = getActiveResIds($db, $ruleset_id);
  $cle     = $ruleset_id . '|' . implode(',', $res_ids);
  if (!isset($cache[$cle])):
    $cache[$cle] = chargerIndexMonstre($db, $ruleset_id, $res_ids);
  endif;
  return $cache[$cle];
}

// Index de la liaison automatique : nom normalisé -> cible. Priorité objet > sort > don
// pour deux entrées de même nom. Les cibles à exclure restent dans l'index, marquées
// « bloque » : un homonyme de moindre priorité ne prend pas leur place.
function lcConstruireIndexAuto(array $index, array $exclus): array
{
  $auto = [];
  foreach (['objet', 'sort', 'don'] as $type):
    foreach (($index[$type] ?? []) as $cle => $info):
      if (isset($auto[$cle])) continue;
      $auto[$cle] = [
        'type'   => $type,
        'id'     => (int)$info['id'],
        'nom'    => $info['nom'],
        'bloque' => isset($exclus[$type . ':' . (int)$info['id']]),
      ];
    endforeach;
  endforeach;
  return $auto;
}

// ============================================================
// 2. POINT D'ENTRÉE PUBLIC
// ============================================================
// $exclure : cibles que la liaison AUTOMATIQUE ne doit pas produire, ex. ['objet' => 42]
// pour qu'un objet ne se lie pas à lui-même. Un tag explicite reste toujours résolu.

function lierMotsClesCompendium(
  PDO $db, ?string $html, int $ruleset_id, array $exclure = []
): string {
  $html = (string)$html;
  if (trim($html) === '') return $html;

  $index = lcChargerIndex($db, $ruleset_id);
  $exclus = [];
  foreach ($exclure as $type => $id):
    $exclus[$type . ':' . (int)$id] = true;
  endforeach;

  $auto = lcConstruireIndexAuto($index, $exclus);
  if (empty($auto)) return $html;
  $max_mots = maxMotsIndex(array_keys($auto));

  // Cibles déjà liées. Les tags explicites sont déclarés d'avance : sans cela, une
  // mention automatique placée AVANT le tag produirait deux liens pour la même cible.
  $fait = [];
  if (preg_match_all('/' . LC_TAG_MOTIF . '/iu', $html, $mm, PREG_SET_ORDER)):
    foreach ($mm as $m):
      $type = strtolower($m[1]);
      $nom  = normaliserNomMonstre(html_entity_decode($m[2], ENT_QUOTES | ENT_HTML5, 'UTF-8'));
      if (isset($index[$type][$nom])):
        $fait[$type . ':' . (int)$index[$type][$nom]['id']] = true;
      endif;
    endforeach;
  endif;

  $rapport  = ['liens' => 0, 'par_type' => []];
  $creation = false;   // vrai dans un paragraphe « Création… » : la casse n'est plus exigée

  // Résolveur de lierSegmentBrut() : reçoit le nom normalisé et le texte brut (casse d'origine).
  // Casse exacte mais accents indifférents : la base stocke « Eclair », le texte écrit « Éclair ».
  $resolve = function (string $cle, string $brut = '') use ($auto, &$fait) {
    $info = $auto[$cle] ?? null;
    if ($info === null || $info['bloque']) return null;
    $k = $info['type'] . ':' . $info['id'];
    if (isset($fait[$k])) return null;
    if (!lcMemeNom($brut, $info['nom'])) return null;
    $fait[$k] = true;
    return $info;
  };

  $tokens     = preg_split('/(<[^>]*>)/s', $html, -1, PREG_SPLIT_DELIM_CAPTURE);
  $profondeur = 0;
  $out        = '';

  foreach ($tokens as $i => $token):
    if ($token === '') continue;

    if ($token[0] === '<'):
      $out .= $token;
      $profondeur = _glMajProfondeur($token, $profondeur);
      if (preg_match('/^<\s*p\b/i', $token)):
        $creation = lcParagrapheCreation($tokens, $i);
      elseif (preg_match('/^<\s*\/\s*p\s*>/i', $token)):
        $creation = false;
      endif;
      continue;
    endif;

    $out .= $profondeur > 0
      ? $token
      : lcLierTexte($token, $index, $auto, $max_mots, $creation, $resolve, $fait, $rapport);
  endforeach;

  return $out;
}

// Vrai si le paragraphe ouvert au jeton $i commence par « Création » (éventuellement en
// gras) : on regarde les deux jetons non vides qui suivent le <p>.
function lcParagrapheCreation(array $tokens, int $i): bool
{
  $suite = [];
  for ($j = $i + 1; $j < count($tokens) && count($suite) < 3; $j++):
    if ($tokens[$j] !== '') $suite[] = $tokens[$j];
  endfor;

  foreach ($suite as $jeton):
    if ($jeton[0] === '<'):
      if (!preg_match('/^<\s*(strong|b|em|i)\b/i', $jeton)) return false;
      continue;
    endif;
    $texte = html_entity_decode($jeton, ENT_QUOTES | ENT_HTML5, 'UTF-8');
    return (bool)preg_match('/^\s*Cr[ée]ation\b/ui', $texte);
  endforeach;
  return false;
}

// ============================================================
// 3. ANALYSE D'UN SEGMENT DE TEXTE
// ============================================================
// Les tags [[tab:…]] et [[liste:…]] passent intacts (résolus plus tard). Les tags
// [[sort|don|objet:…]] sont résolus. Le reste passe par la liaison automatique, après
// décodage des entités (reg_texte / om_description stockent les accents en entités),
// puis ré-échappement par h() dans lierSegmentBrut().

function lcLierTexte(
  string $seg, array $index, array $auto, int $max_mots, bool $creation,
  callable $resolve, array &$fait, array &$rapport
): string {
  $parts = preg_split('/(' . GL_TAB_MOTIF . ')/iu', $seg, -1, PREG_SPLIT_DELIM_CAPTURE);
  $out   = '';

  foreach ($parts as $part):
    if ($part === '') continue;

    if (preg_match('/^' . LC_TAG_MOTIF . '$/iu', $part, $m)):
      $out .= lcRendreTag(strtolower($m[1]), $m[2], $m[3] ?? null, $index, $fait, $rapport);
    elseif (preg_match('/^' . GL_TAB_MOTIF . '$/iu', $part)):
      $out .= $part;
    else:
      $plain = html_entity_decode($part, ENT_QUOTES | ENT_HTML5, 'UTF-8');
      if ($creation || lcEstListe($plain, $auto, $max_mots)):
        // Bloc de noms (« Conditions : boule de feu, cône de froid, … ») : chaque élément
        // est lié, sans exiger la casse ; il ne dépend pas des liens posés plus haut.
        $fait_bloc = [];
        $out .= lcLierListe($plain, $auto, $max_mots, 'sort', $fait_bloc, $rapport);
      else:
        // Marge de 3 mots : lierSegmentBrut() compte « d’armes » (apostrophe typographique)
        // pour deux mots, alors que normaliserNomMonstre() n'en voit qu'un.
        $out .= lierSegmentBrut($plain, $max_mots + 3, $resolve, $rapport);
      endif;
    endif;
  endforeach;

  return $out;
}

// ============================================================
// 4. SORTS ET LISTES DE NOMS
// ============================================================
// Les noms de sorts apparaissent sous trois formes dans les objets magiques :
//   - « Boule de feu à intensité augmentée au 5e niveau (1 charge) » : le nom EN TÊTE
//     d'un élément, suivi d'un qualificatif ou d'une parenthèse ;
//   - « boule de feu, cône de froid, éclair » : liste de noms en minuscules, séparés
//     par , ; ou : (ligne « Conditions » des objets DD3.5, cellules de tableaux DD2024) ;
//   - dans une phrase, où seule la casse exacte distingue le sort du mot courant.
// Les deux premières formes sont traitées ici : on cherche le plus long nom connu au
// DÉBUT de chaque élément (après un éventuel « et » / « ou »), sans exiger la casse, et
// on ne lie que ce nom — le qualificatif reste en texte.

// Retire les accents en conservant la casse (normaliserNomMonstre() passe en minuscules).
function lcSansAccents(string $s): string
{
  static $carte = null;
  if ($carte === null):
    $carte = [];
    foreach ([
      'a' => 'àáâäã', 'e' => 'èéêë', 'i' => 'ìíîï', 'o' => 'òóôöõ', 'u' => 'ùúûü',
      'c' => 'ç', 'n' => 'ñ', 'y' => 'ýÿ',
    ] as $base => $lettres):
      foreach (preg_split('//u', $lettres, -1, PREG_SPLIT_NO_EMPTY) as $l):
        $carte[$l] = $base;
        $carte[mb_strtoupper($l)] = strtoupper($base);
      endforeach;
    endforeach;
    $carte['œ'] = 'oe'; $carte['Œ'] = 'Oe'; $carte['æ'] = 'ae'; $carte['Æ'] = 'Ae';
  endif;
  return strtr($s, $carte);
}

// Même nom, casse exacte, accents et typographie (apostrophe, espaces) indifférents.
function lcMemeNom(string $brut, string $nom): bool
{
  return lcSansAccents(glossaireNormaliser($brut)) === lcSansAccents(glossaireNormaliser($nom));
}

// Plus long nom de $map au début de $item. Retourne ['debut','fin','brut','info'] ou null.
function lcPrefixeNom(string $item, array $map, int $max_mots): ?array
{
  if (!preg_match_all('/[\p{L}\p{N}\']+/u', $item, $mm, PREG_OFFSET_CAPTURE)) return null;
  $mots = $mm[0];
  $n    = count($mots);

  $i = 0;
  while ($i < $n && in_array(mb_strtolower($mots[$i][0]), ['et', 'ou'], true)) $i++;
  if ($i >= $n) return null;

  for ($k = min($max_mots + 3, $n - $i); $k >= 1; $k--):
    $debut   = $mots[$i][1];
    $dernier = $mots[$i + $k - 1];
    $fin     = $dernier[1] + strlen($dernier[0]);
    $brut    = substr($item, $debut, $fin - $debut);
    $cle     = normaliserNomMonstre($brut);
    if (mb_strlen($cle) < MO_LONGUEUR_MIN) continue;
    if (isset($map[$cle])) return ['debut' => $debut, 'fin' => $fin, 'brut' => $brut, 'info' => $map[$cle]];
  endfor;
  return null;
}

// Vrai si le texte est surtout une liste de noms : au moins 2 éléments (séparés par , ; :)
// commencent par un nom connu, et ils font au moins la moitié des éléments non vides.
function lcEstListe(string $plain, array $map, int $max_mots): bool
{
  $total = 0;
  $ok    = 0;
  foreach (preg_split('/[,;:]+/u', $plain) as $item):
    $item = trim($item, " \t\n\r\0\x0B\u{00A0}");
    if ($item === '') continue;
    $total++;
    if (lcPrefixeNom($item, $map, $max_mots) !== null) $ok++;
  endforeach;
  return $ok >= 2 && $ok * 2 >= $total;
}

// Lie le nom en tête de chaque élément. $fait_bloc : cibles déjà liées DANS ce bloc
// (une cible n'est liée qu'une fois par bloc). $type_defaut : type des entrées de $map
// qui ne portent pas de clé 'type' (index brut chargerIndexMonstre()['sort']).
function lcLierListe(
  string $plain, array $map, int $max_mots, string $type_defaut,
  array &$fait_bloc, array &$rapport
): string {
  $parts = preg_split('/([,;:]+)/u', $plain, -1, PREG_SPLIT_DELIM_CAPTURE);
  $out   = '';

  foreach ($parts as $idx => $part):
    if ($idx % 2 === 1 || $part === ''):
      $out .= h($part);
      continue;
    endif;

    $m = lcPrefixeNom($part, $map, $max_mots);
    if ($m === null):
      $out .= h($part);
      continue;
    endif;

    $info = $m['info'];
    $type = $info['type'] ?? $type_defaut;
    $k    = $type . ':' . (int)$info['id'];
    if (!empty($info['bloque']) || isset($fait_bloc[$k])):
      $out .= h($part);
      continue;
    endif;

    $fait_bloc[$k] = true;
    $rapport['liens']++;
    $rapport['par_type'][$type] = ($rapport['par_type'][$type] ?? 0) + 1;
    $out .= h(substr($part, 0, $m['debut']))
          . '<span class="mo-lien" data-type="' . h($type) . '" data-id="' . (int)$info['id'] . '">'
          . h($m['brut']) . '</span>'
          . h(substr($part, $m['fin']));
  endforeach;

  return $out;
}

// Cellule d'une colonne « Sorts » d'un tableau (texte brut, sans tag) : chaque nom de sort
// en tête d'un élément devient un lien. $index_sorts = chargerIndexMonstre()['sort'].
function lcLierCelluleSorts(string $texte, array $index_sorts): string
{
  if ($texte === '' || empty($index_sorts)) return h($texte);
  $rapport   = ['liens' => 0, 'par_type' => []];
  $fait_bloc = [];
  return lcLierListe($texte, $index_sorts, maxMotsIndex(array_keys($index_sorts)), 'sort', $fait_bloc, $rapport);
}

function lcRendreTag(
  string $type, string $nom, ?string $libelle, array $index, array &$fait, array &$rapport
): string {
  $nom  = trim(html_entity_decode($nom, ENT_QUOTES | ENT_HTML5, 'UTF-8'));
  $info = $index[$type][normaliserNomMonstre($nom)] ?? null;

  if ($info === null):
    $brut = '[[' . $type . ':' . $nom . ($libelle !== null ? '|' . $libelle : '') . ']]';
    return '<span class="reg-tab__manquant">' . h($brut) . '</span>';
  endif;

  $affiche = $libelle !== null ? trim(html_entity_decode($libelle, ENT_QUOTES | ENT_HTML5, 'UTF-8')) : '';
  if ($affiche === '') $affiche = $nom;

  $fait[$type . ':' . (int)$info['id']] = true;
  $rapport['liens']++;
  $rapport['par_type'][$type] = ($rapport['par_type'][$type] ?? 0) + 1;

  return '<span class="mo-lien" data-type="' . h($type) . '" data-id="' . (int)$info['id'] . '">'
       . h($affiche) . '</span>';
}
