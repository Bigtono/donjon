<?php
// include/glossaire-parser.php — Liaison automatique des termes de glossaire (SP-GL)
// ============================================================
// Transforme les mentions d'un terme de glossaire, dans un texte HTML issu de
// TinyMCE (reg_texte), en ancres cliquables :
//
//   <a class="glossaire-lien" data-glossaire-slug="avantage">Avantage</a>
//
// Le handler de clic vit dans js/main.js (délégué, chargé sur toutes les pages)
// et ouvre la définition dans #detail-pp-sub.
//
// RÈGLES DE DÉTECTION (arbitrage SP-GL) :
//   1. Résolution AU RENDU — rien n'est écrit en base. Renommer un terme du
//      glossaire suffit à mettre à jour tous les renvois.
//   2. CASSE EXACTE du reg_nom. Le SRD 2024 capitalise ses termes de jeu en
//      milieu de phrase (« a le Désavantage », « un Repos court ») : c'est le
//      signal qui distingue le terme technique du mot courant. Sans cette
//      contrainte, le glossaire (Action, Arme, Cible, Créature, Objet, Sort,
//      Mort, Vol…) produirait ~1 000 liens sur les 31 nœuds de règles au lieu
//      de ~280, et le texte deviendrait illisible.
//   3. PREMIÈRE OCCURRENCE seulement, par terme et par nœud. Les ancres déjà
//      présentes dans le HTML (renvois manuels du seed) comptent comme la
//      première occurrence : aucun doublon n'est ajouté derrière elles.
//   4. PLURIEL SIMPLE : un « s » ou un « x » final est admis (Chutes → Chute).
//      Les pluriels internes ne le sont pas (« Terrains difficiles » n'est pas
//      reconnu, « Terrain difficile » l'est) — cas marginal, assumé.
//
// ZONES EXCLUES : <a>, <code>, <pre>, <h1>–<h6>, <table>, <script>, <style>,
// <textarea>, et les tags [[tab:slug]] non encore résolus. Un terme ne se lie
// jamais à lui-même sur sa propre page (paramètre $exclure_id).
//
// ORDRE D'APPEL — lierGlossaireAuto() AVANT resoudreTagsTableaux() : le HTML
// des tableaux est ainsi injecté après coup et ne traverse jamais ce parser.
// C'est ce qui met « l'intérieur des tableaux rendus » hors de portée.
//
// Référence : doc/ARCHITECTURE_0_REFERENCE.md §9d — DECISIONS_LOG [2026-07-27]

require_once __DIR__ . '/helpers.php';

// Balises dont le contenu n'est jamais parcouru.
define('GL_BALISES_EXCLUES', [
  'a', 'code', 'pre', 'script', 'style', 'textarea', 'table',
  'h1', 'h2', 'h3', 'h4', 'h5', 'h6',
]);

// Tag tableau non résolu — repris littéralement plutôt qu'importé de
// tableau-parser.php : ce fichier ne doit dépendre que de helpers.php.
define('GL_TAB_MOTIF', '\[\[tab:[a-z0-9\-]{1,120}\]\]');

// ============================================================
// 1. INDEX DES TERMES
// ============================================================
// Termes globaux du ruleset (reg_camp_id IS NULL) : un glossaire propre à une
// campagne ne doit pas fuir dans les pages de règles générales.
// Trié par longueur décroissante — l'alternation PCRE retient la première
// branche qui matche, il faut donc que « Jet de sauvegarde contre la mort »
// passe avant « Jet de sauvegarde ».

function chargerIndexGlossaire(PDO $db, int $ruleset_id): array
{
  static $cache = [];
  if (isset($cache[$ruleset_id])) return $cache[$ruleset_id];

  $stmt = $db->prepare("
    SELECT reg_id, reg_nom, reg_slug
    FROM   dd_regles
    WHERE  reg_ruleset_var_id = ?
      AND  reg_type    = 'glossaire'
      AND  reg_visible = 1
      AND  reg_camp_id IS NULL
      AND  reg_slug IS NOT NULL
  ");
  $stmt->execute([$ruleset_id]);

  $index = [];
  foreach ($stmt->fetchAll() as $row):
    $nom = trim((string)$row['reg_nom']);
    if ($nom === '') continue;
    $index[(int)$row['reg_id']] = [
      'id'   => (int)$row['reg_id'],
      'nom'  => $nom,
      'slug' => (string)$row['reg_slug'],
    ];
  endforeach;

  uasort($index, fn($a, $b) => mb_strlen($b['nom']) <=> mb_strlen($a['nom']));

  $cache[$ruleset_id] = $index;
  return $index;
}

// ============================================================
// 2. NORMALISATION ET MOTIF
// ============================================================
// La casse et les accents sont significatifs (règle 2). Seules sont neutralisées
// les variantes typographiques qui ne changent pas le mot : apostrophe droite /
// courbe, et espace insécable / multiple.

function glossaireNormaliser(string $s): string
{
  $s = preg_replace("/[\x{2018}\x{2019}\x{201B}\x{00B4}`]/u", "'", $s);
  $s = preg_replace("/[\\s\x{00A0}]+/u", ' ', $s);
  return trim($s);
}

// Fragment de motif tolérant aux mêmes variantes que glossaireNormaliser().
function glossaireMotifTerme(string $nom): string
{
  $motif = preg_quote($nom, '/');
  $motif = str_replace("'", "['\x{2019}\x{2018}\x{201B}\x{00B4}`]", $motif);
  return str_replace(' ', "[\\s\x{00A0}]+", $motif);
}

// Motif complet + table de correspondance « texte matché » → terme.
// Retourne [motif, parNom]. Motif vide si l'index est vide.
function glossaireCompilerMotif(array $index): array
{
  $branches = [];
  $parNom   = [];
  foreach ($index as $info):
    $branches[] = glossaireMotifTerme($info['nom']);
    $parNom[glossaireNormaliser($info['nom'])] = $info;
  endforeach;

  if (empty($branches)) return ['', []];

  // Frontière de mot. Le trait d'union en fait partie : sans lui, « Mort » se
  // lierait dans « Mort-vivant ». Un terme peut lui-même en contenir
  // (« Personnage non-joueur ») — sans incidence, la contrainte ne porte que
  // sur les extrémités du match.
  $bord = '[\p{L}\p{N}\x{2010}-\x{2015}\-]';

  // Groupe 1 = le terme ; le « s »/« x » du pluriel reste hors du groupe pour
  // que la correspondance avec $parNom se fasse sur la forme au singulier.
  $motif = '/(?<!' . $bord . ')(' . implode('|', $branches) . ')[sx]?(?!' . $bord . ')/u';
  return [$motif, $parNom];
}

// ============================================================
// 3. POINT D'ENTRÉE PUBLIC
// ============================================================
// $exclure_id : reg_id du nœud affiché — son propre terme n'est pas lié.

function lierGlossaireAuto(
  PDO $db, ?string $html, int $ruleset_id, int $exclure_id = 0
): string {
  $html = (string)$html;
  if (trim($html) === '') return $html;

  $index = chargerIndexGlossaire($db, $ruleset_id);
  if ($exclure_id > 0) unset($index[$exclure_id]);
  if (empty($index)) return $html;

  [$motif, $parNom] = glossaireCompilerMotif($index);
  if ($motif === '') return $html;

  // Renvois déjà écrits à la main dans le HTML : ils tiennent lieu de première
  // occurrence (règle 3), sinon le parser en ajouterait un doublon plus bas.
  $fait = [];
  if (preg_match_all('/data-glossaire-slug="([^"]*)"/i', $html, $mm)):
    foreach ($mm[1] as $slug) $fait[html_entity_decode($slug, ENT_QUOTES, 'UTF-8')] = true;
  endif;

  // Découpage balises / texte. Les balises transitent intactes ; seul le texte
  // situé hors des zones exclues est analysé.
  $tokens     = preg_split('/(<[^>]*>)/s', $html, -1, PREG_SPLIT_DELIM_CAPTURE);
  $profondeur = 0;
  $out        = '';

  foreach ($tokens as $token):
    if ($token === '') continue;

    if ($token[0] === '<'):
      $out .= $token;
      $profondeur = _glMajProfondeur($token, $profondeur);
      continue;
    endif;

    $out .= $profondeur > 0
      ? $token
      : _glLierTexte($token, $motif, $parNom, $fait);
  endforeach;

  return $out;
}

// ============================================================
// 4. SUIVI DE PROFONDEUR DES ZONES EXCLUES
// ============================================================
// Un compteur suffit : on n'a pas besoin de savoir quelle balise a ouvert la
// zone, seulement si l'on s'y trouve. Les balises auto-fermantes et les
// commentaires / doctypes sont ignorés.

function _glMajProfondeur(string $token, int $profondeur): int
{
  if (!preg_match('/^<\s*(\/?)\s*([a-z][a-z0-9]*)/i', $token, $m)) return $profondeur;

  $balise = strtolower($m[2]);
  if (!in_array($balise, GL_BALISES_EXCLUES, true)) return $profondeur;

  if ($m[1] === '/') return max(0, $profondeur - 1);
  if (str_ends_with(rtrim($token, '> '), '/')) return $profondeur;   // <br/> et cie
  return $profondeur + 1;
}

// ============================================================
// 5. ANALYSE D'UN SEGMENT DE TEXTE
// ============================================================

// Isole les tags [[tab:slug]] avant analyse : ils seront résolus en tableaux
// juste après, et ne doivent surtout pas se retrouver coupés par une ancre.
function _glLierTexte(string $seg, string $motif, array $parNom, array &$fait): string
{
  if (stripos($seg, '[[tab:') === false):
    return _glLierSegment($seg, $motif, $parNom, $fait);
  endif;

  $parts = preg_split('/(' . GL_TAB_MOTIF . ')/i', $seg, -1, PREG_SPLIT_DELIM_CAPTURE);
  $out   = '';
  foreach ($parts as $part):
    $out .= preg_match('/^' . GL_TAB_MOTIF . '$/i', $part)
      ? $part
      : _glLierSegment($part, $motif, $parNom, $fait);
  endforeach;
  return $out;
}

// Le segment est décodé avant analyse : reg_texte stocke les accents en
// entités (« D&eacute;shydratation »), sur lesquelles aucun motif ne matcherait.
// Tout ce qui n'est pas transformé est ré-échappé par h() ; la page étant en
// UTF-8 (et la base en utf8mb4), les accents ressortent en clair — HTML
// équivalent, simplement plus lisible à l'inspection.
function _glLierSegment(string $seg, string $motif, array $parNom, array &$fait): string
{
  if ($seg === '') return '';

  $plain   = html_entity_decode($seg, ENT_QUOTES | ENT_HTML5, 'UTF-8');
  $out     = '';
  $curseur = 0;

  while (preg_match($motif, $plain, $m, PREG_OFFSET_CAPTURE, $curseur)):
    $brut  = $m[0][0];
    $debut = $m[0][1];
    $info  = $parNom[glossaireNormaliser($m[1][0])] ?? null;

    $out .= h(substr($plain, $curseur, $debut - $curseur));

    if ($info === null || isset($fait[$info['slug']])):
      $out .= h($brut);
    else:
      $fait[$info['slug']] = true;
      $out .= '<a class="glossaire-lien" data-glossaire-slug="' . h($info['slug'])
            . '" title="' . h($info['nom']) . ' — voir le glossaire">'
            . h($brut) . '</a>';
    endif;

    $curseur = $debut + strlen($brut);
  endwhile;

  return $out . h(substr($plain, $curseur));
}
