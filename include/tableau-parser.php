<?php
// include/tableau-parser.php — Moteur des tableaux de données (SP-TB1)
//
// Les tableaux de règles ne sont plus saisis en HTML dans reg_texte : ils vivent
// dans dd_tableaux, saisis selon une convention texte, et sont insérés dans le
// corps d'une règle par le tag [[tab:slug]]. Le HTML est produit ici, le design
// reste entièrement géré en CSS.
//
// CONVENTION DE SAISIE (tab_contenu) — une ligne = une ligne de tableau,
// « | » sépare les cellules :
//
//   ! Nom | Prix | Poids      → ligne d'en-tête (<th>). Plusieurs lignes « ! »
//                               consécutives = en-tête sur plusieurs niveaux.
//   # ARMES COURANTES         → ligne de section, fusionnée sur toute la largeur
//   bâton | 2 pa | 2 kg       → ligne de données (<td>)
//   > Les prix sont indicatifs → note de bas de tableau
//   (ligne vide)              → ignorée
//
// FUSIONS — uniquement dans les lignes d'en-tête « ! » :
//   cellule vide  → fusion horizontale avec la cellule de gauche (colspan)
//   cellule « ^ » → fusion verticale avec la cellule du dessus (rowspan)
//
//   Exemple d'en-tête sur deux niveaux :
//     ! | Rythme | | | Effet
//     ! Distance parcourue par… | Rapide | Normal | Lent | ^
//
// Les lignes de données ne connaissent aucune fusion : une cellule vide reste
// une cellule vide (indispensable aux grilles irrégulières, ex. « Compétences »).
//
// ALIGNEMENT — hors contenu, dans tab_align : une lettre par colonne (l/c/r),
// séparateurs optionnels. Ex. « lrr » ou « l,r,r ». Colonnes non couvertes = l.
//
// LIAISON DES CELLULES — le contenu des cellules passe par
// resoudreTagsExplicites() (tags #don#, $sort$, &objet&, @id@ règle, %id% glossaire).
// Tout le reste est échappé. Aucune liaison automatique (lierAuto) n'est
// appliquée : trop coûteux et trop bruyant dans une grille dense.
//
// Référence : doc/ARCHITECTURE_0_REFERENCE.md §9c

require_once __DIR__ . '/monstre-parser.php';
// Requis par rendreTexteEnrichi() (SP-GL3). glossaire-parser.php ne dépend que
// de helpers.php : la dépendance reste à sens unique.
require_once __DIR__ . '/glossaire-parser.php';

// ============================================================
// 1. PARSING — convention texte → structure
// ============================================================
// Retourne :
//   'entetes' → [[cellule,…],…]   lignes de <thead>
//   'lignes'  → [['type'=>'donnees'|'section', 'cellules'=>[…]],…]
//   'notes'   → [string,…]
//   'nb_cols' → int
//
// Une cellule = ['texte'=>string, 'colspan'=>int, 'rowspan'=>int, 'col'=>int]

function tableauParser(string $contenu): array
{
  $entetes = [];
  $lignes  = [];
  $notes   = [];

  // Découpage brut, en conservant l'ordre. Les lignes d'en-tête ne sont
  // reconnues que tant qu'aucune ligne de données n'a encore été lue :
  // un « ! » plus bas dans le tableau serait un en-tête intermédiaire,
  // que la convention ne gère pas (et que le HTML rendrait mal).
  $brut_entetes = [];
  $brut_corps   = [];

  foreach (preg_split('/\r\n|\r|\n/', $contenu) as $ligne):
    $ligne = trim($ligne);
    if ($ligne === '') continue;

    $prefixe = mb_substr($ligne, 0, 1);
    $reste   = trim(mb_substr($ligne, 1));

    if ($prefixe === '>'):
      $notes[] = $reste;
    elseif ($prefixe === '!' && empty($brut_corps)):
      $brut_entetes[] = _tabDecouper($reste);
    elseif ($prefixe === '#'):
      $brut_corps[] = ['type' => 'section', 'cellules' => [$reste]];
    else:
      $brut_corps[] = ['type' => 'donnees', 'cellules' => _tabDecouper($ligne)];
    endif;
  endforeach;

  // Nombre de colonnes = plus large ligne rencontrée (en-tête ou données)
  $nb_cols = 0;
  foreach ($brut_entetes as $r):
    $nb_cols = max($nb_cols, count($r));
  endforeach;
  foreach ($brut_corps as $r):
    if ($r['type'] === 'donnees') $nb_cols = max($nb_cols, count($r['cellules']));
  endforeach;
  $nb_cols = max(1, $nb_cols);

  // ---- En-têtes : résolution des fusions ----
  foreach ($brut_entetes as $num_ligne => $raws):
    $cellules = [];
    $dernier  = null;   // index de la dernière cellule émise sur cette ligne
    $col      = 0;

    foreach ($raws as $raw):
      // Cellule vide → fusion horizontale avec la cellule de gauche
      if ($raw === '' && $dernier !== null):
        $cellules[$dernier]['colspan']++;
        $col++;
        continue;
      endif;

      // « ^ » → fusion verticale avec la cellule du dessus (même colonne)
      if ($raw === '^' && $num_ligne > 0):
        $cible = _tabCelluleAuDessus($entetes, $num_ligne, $col);
        if ($cible !== null):
          $entetes[$cible[0]][$cible[1]]['rowspan']++;
          $col++;
          continue;
        endif;
        // Aucune cellule au-dessus : on dégrade en cellule vide
        $raw = '';
      endif;

      $cellules[] = [
        'texte'   => $raw,
        'colspan' => 1,
        'rowspan' => 1,
        'col'     => $col,
      ];
      $dernier = count($cellules) - 1;
      $col++;
    endforeach;

    $entetes[$num_ligne] = $cellules;
  endforeach;

  // ---- Corps ----
  foreach ($brut_corps as $r):
    if ($r['type'] === 'section'):
      $lignes[] = [
        'type'     => 'section',
        'cellules' => [[
          'texte'   => $r['cellules'][0],
          'colspan' => $nb_cols,
          'rowspan' => 1,
          'col'     => 0,
        ]],
      ];
      continue;
    endif;

    $cellules = [];
    for ($i = 0; $i < $nb_cols; $i++):
      $cellules[] = [
        'texte'   => $r['cellules'][$i] ?? '',
        'colspan' => 1,
        'rowspan' => 1,
        'col'     => $i,
      ];
    endfor;
    $lignes[] = ['type' => 'donnees', 'cellules' => $cellules];
  endforeach;

  return [
    'entetes' => $entetes,
    'lignes'  => $lignes,
    'notes'   => $notes,
    'nb_cols' => $nb_cols,
  ];
}

// Découpe une ligne sur « | » et nettoie chaque cellule.
function _tabDecouper(string $ligne): array
{
  $cellules = array_map('trim', explode('|', $ligne));
  // Une ligne peut se terminer par « | » pour la lisibilité : on retire
  // uniquement la dernière cellule si elle est vide ET qu'il y en a d'autres.
  $n = count($cellules);
  if ($n > 1 && $cellules[$n - 1] === '') array_pop($cellules);
  return $cellules;
}

// Cherche, dans les lignes d'en-tête déjà résolues, la cellule qui démarre
// à la colonne $col — en remontant depuis la ligne précédente.
// Retourne [num_ligne, index_cellule] ou null.
function _tabCelluleAuDessus(array $entetes, int $num_ligne, int $col): ?array
{
  for ($l = $num_ligne - 1; $l >= 0; $l--):
    if (!isset($entetes[$l])) continue;
    foreach ($entetes[$l] as $idx => $cel):
      if ($cel['col'] === $col) return [$l, $idx];
    endforeach;
  endfor;
  return null;
}

// ============================================================
// 2. ALIGNEMENTS
// ============================================================
// « lrr », « l,r,r », « l r r » → ['left','right','right']
// Colonnes non couvertes → 'left'.

function tableauAlignements(?string $align, int $nb_cols): array
{
  $map = ['l' => 'left', 'c' => 'center', 'r' => 'right'];
  $lettres = preg_replace('/[^lcr]/i', '', strtolower((string)$align));

  $out = [];
  for ($i = 0; $i < $nb_cols; $i++):
    $lettre = $lettres[$i] ?? 'l';
    $out[]  = $map[$lettre] ?? 'left';
  endfor;
  return $out;
}

// ============================================================
// 3. RENDU HTML
// ============================================================
// $tab : ligne dd_tableaux (tab_nom, tab_contenu, tab_align, tab_note, tab_slug)
// $index : index de liaison (chargerIndexMonstre()) — [] = pas de liaison
//
// Le conteneur porte data-detail-base : le handler .mo-lien de js/main.js en
// dérive l'URL des endpoints detail-pp. Sans cet attribut, les liens produits
// dans les cellules seraient inertes.

function rendreTableau(array $tab, array $index = [], int $ruleset_id = 0, ?PDO $db = null): string
{
  $struct = tableauParser((string)($tab['tab_contenu'] ?? ''));
  $aligns = tableauAlignements($tab['tab_align'] ?? null, $struct['nb_cols']);
  $slug   = (string)($tab['tab_slug'] ?? '');

  $rapport = ['liens' => 0, 'par_type' => []];
  $cel = function (array $c, string $balise) use ($aligns, $index, $ruleset_id, $db, &$rapport): string {
    $attrs = '';
    if ($c['colspan'] > 1) $attrs .= ' colspan="' . (int)$c['colspan'] . '"';
    if ($c['rowspan'] > 1) $attrs .= ' rowspan="' . (int)$c['rowspan'] . '"';
    // L'alignement est une propriété de colonne : une cellule fusionnée
    // horizontalement (section, en-tête groupé) n'en hérite pas.
    $align = $c['colspan'] > 1 ? 'left' : ($aligns[$c['col']] ?? 'left');
    if ($align !== 'left') $attrs .= ' class="reg-tab__c--' . $align . '"';
    return '<' . $balise . $attrs . '>'
      . tableauCellule((string)$c['texte'], $index, $ruleset_id, $db, $rapport)
      . '</' . $balise . '>';
  };

  $html  = '<figure class="reg-tab"' . ($slug !== '' ? ' id="tab-' . h($slug) . '"' : '')
         . ' data-detail-base="' . BASE_URL . '/include/ajax/detail-pp/">';

  if (!empty($tab['tab_nom'])):
    $html .= '<figcaption class="reg-tab__titre">' . h((string)$tab['tab_nom']) . '</figcaption>';
  endif;

  $html .= '<div class="reg-tab__scroll"><table class="reg-tab__table">';

  if (!empty($struct['entetes'])):
    $html .= '<thead>';
    foreach ($struct['entetes'] as $ligne):
      $html .= '<tr>';
      foreach ($ligne as $c) $html .= $cel($c, 'th');
      $html .= '</tr>';
    endforeach;
    $html .= '</thead>';
  endif;

  $html .= '<tbody>';
  foreach ($struct['lignes'] as $ligne):
    $cls = $ligne['type'] === 'section' ? ' class="reg-tab__section"' : '';
    $html .= '<tr' . $cls . '>';
    foreach ($ligne['cellules'] as $c) $html .= $cel($c, 'td');
    $html .= '</tr>';
  endforeach;
  $html .= '</tbody></table></div>';

  // Notes : lignes « > » du contenu, puis tab_note
  $notes = $struct['notes'];
  if (!empty($tab['tab_note'])) $notes[] = (string)$tab['tab_note'];
  foreach ($notes as $note):
    $html .= '<p class="reg-tab__note">'
      . tableauCellule($note, $index, $ruleset_id, $db, $rapport) . '</p>';
  endforeach;

  $html .= '</figure>';
  return $html;
}

// Rend le contenu d'une cellule : tags explicites résolus, tout le reste échappé.
//
// resoudreTagsExplicites() ne protège que ses propres remplacements — le texte
// brut alentour en ressort non échappé. On repasse donc par
// lierAvecSegmentsProteges() avec maxWords = 0 : les <span class="mo-lien">
// déjà produits transitent tels quels, tout le reste est h()-échappé, et aucune
// liaison automatique n'est tentée (cf. lierSegmentBrut(), retour immédiat).
function tableauCellule(
  string $texte, array $index, int $ruleset_id, ?PDO $db, array &$rapport
): string {
  if ($texte === '') return '';

  // Pas de tag → échappement simple, aucun coût
  if ($db === null || !preg_match('/[@%#$&]/', $texte)):
    return h($texte);
  endif;

  $txt = resoudreTagsExplicites($texte, $db, $index, $ruleset_id, $rapport);
  return lierAvecSegmentsProteges($txt, 0, fn() => null, $rapport);
}

// ============================================================
// 4. RÉSOLUTION DU TAG [[tab:slug]]
// ============================================================
// Remplace les tags dans un texte hôte (reg_texte, mo_stats, et à terme tout
// champ description du compendium — cf. SP-TB7).
//
// Deux passes :
//   1. tag seul dans un <p> (cas TinyMCE nominal) → le <p> entier est remplacé.
//      Indispensable : un <table> à l'intérieur d'un <p> est du HTML invalide,
//      le navigateur ferme le <p> et la mise en page casse.
//   2. tag nu restant → remplacement sur place.
//
// Slug inconnu ou tableau masqué → le tag s'affiche tel quel, échappé
// (même politique de dégradation que resoudreTagsExplicites()).

define('TAB_TAG_MOTIF', '\[\[tab:([a-z0-9\-]{1,120})\]\]');

function resoudreTagsTableaux(
  PDO $db, ?string $html, int $ruleset_id, bool $inclureMasques = false
): string {
  $html = (string)$html;
  if ($html === '' || stripos($html, '[[tab:') === false) return $html;

  $index_charge = false;
  $index        = [];

  $rendre = function (string $slug) use (
    $db, $ruleset_id, $inclureMasques, &$index_charge, &$index
  ): ?string {
    $tab = chargerTableauParSlug($db, $slug, $ruleset_id, $inclureMasques);
    if (!$tab) return null;

    // Index de liaison chargé une seule fois, et seulement si au moins un
    // tableau de la page contient un tag explicite dans ses cellules.
    if (!$index_charge && preg_match('/[@%#$&]/', (string)$tab['tab_contenu'])):
      $index        = chargerIndexMonstre($db, $ruleset_id, getActiveResIds($db));
      $index_charge = true;
    endif;

    return rendreTableau($tab, $index, $ruleset_id, $db);
  };

  // Passe 1 — <p>[[tab:slug]]</p> (le <strong> éventuel vient de TinyMCE)
  $html = preg_replace_callback(
    '/<p\b[^>]*>\s*(?:<strong>\s*)?' . TAB_TAG_MOTIF . '(?:\s*<\/strong>)?\s*<\/p>/i',
    function ($m) use ($rendre) {
      $out = $rendre($m[1]);
      return $out ?? '<p class="reg-tab__manquant">' . h('[[tab:' . $m[1] . ']]') . '</p>';
    },
    $html
  );

  // Passe 2 — tag nu résiduel
  $html = preg_replace_callback(
    '/' . TAB_TAG_MOTIF . '/i',
    function ($m) use ($rendre) {
      $out = $rendre($m[1]);
      return $out ?? '<span class="reg-tab__manquant">' . h('[[tab:' . $m[1] . ']]') . '</span>';
    },
    $html
  );

  return $html;
}

// Point d'entrée unique des champs texte du compendium (SP-TB7 + SP-GL3).
// Applique, dans l'ordre imposé, les deux parsers de rendu :
//   1. lierGlossaireAuto()    — mentions de termes de glossaire -> ancres
//   2. resoudreTagsTableaux() — tags [[tab:slug]] -> tableaux dd_tableaux
//
// L'ORDRE EST IMPÉRATIF (cf. §9d). Glossaire d'abord : le HTML des tableaux est
// alors injecté après coup et ne traverse jamais le parser glossaire, ce qui met
// l'intérieur des tableaux rendus hors de portée sans code dédié.
//
// Le ruleset est lu dans la session plutôt que reçu en paramètre — les endpoints
// detail-pp du compendium ne définissent pas tous une variable $ruleset_id
// locale, et un appel qui en dépendrait produirait un scoping silencieusement
// faux là où elle est absente. Un appelant qui connaît son ruleset peut toujours
// le passer.
//
// NE PAS UTILISER sur mo_stats : monstre-parser.php a sa propre liaison
// glossaire (lierAuto() + tag %id%), l'ajout produirait des liens en double.
//
// À n'utiliser que sur un champ déjà rendu SANS h() : appliqué à une sortie
// échappée, le tag resterait littéral ; appliqué pour contourner un
// échappement, il ouvrirait une injection HTML.
function rendreTexteEnrichi(PDO $db, ?string $html, ?int $ruleset_id = null): string
{
  $rs = $ruleset_id ?? (int)($_SESSION['ruleset_var_id'] ?? 1);
  return resoudreTagsTableaux($db, lierGlossaireAuto($db, $html, $rs), $rs);
}

// ============================================================
// 5. CHARGEMENT
// ============================================================
// Cache statique par requête : une règle peut appeler plusieurs fois le même
// tableau (« Bonus de maîtrise » est référencé par deux règles distinctes).

function chargerTableauParSlug(
  PDO $db, string $slug, int $ruleset_id, bool $inclureMasques = false
): ?array {
  static $cache = [];
  $cle = $slug . '|' . $ruleset_id . '|' . ($inclureMasques ? '1' : '0');
  if (array_key_exists($cle, $cache)) return $cache[$cle];

  $cond = $inclureMasques ? '' : 'AND tab_visible = 1';
  $stmt = $db->prepare("
    SELECT * FROM dd_tableaux
    WHERE  tab_slug = ? AND tab_ruleset_var_id = ?
      $cond
    LIMIT  1
  ");
  $stmt->execute([$slug, $ruleset_id]);
  $row = $stmt->fetch();

  $cache[$cle] = $row ?: null;
  return $cache[$cle];
}

function chargerTableauParId(PDO $db, int $id, int $ruleset_id): ?array
{
  $stmt = $db->prepare('
    SELECT * FROM dd_tableaux
    WHERE  tab_id = ? AND tab_ruleset_var_id = ?
    LIMIT  1
  ');
  $stmt->execute([$id, $ruleset_id]);
  $row = $stmt->fetch();
  return $row ?: null;
}

// Génère un slug URL-safe unique pour le ruleset donné.
function tableauGenererSlug(PDO $db, string $nom, int $ruleset_id, int $excludeId = 0): string
{
  $base = _tabSlugify($nom);
  $slug = $base;
  $i    = 2;
  while (true):
    $stmt = $db->prepare('
      SELECT COUNT(*) FROM dd_tableaux
      WHERE  tab_slug = ? AND tab_ruleset_var_id = ? AND tab_id != ?
    ');
    $stmt->execute([$slug, $ruleset_id, $excludeId]);
    if ((int)$stmt->fetchColumn() === 0) return $slug;
    $slug = $base . '-' . $i++;
  endwhile;
}

// Translittération défensive : l'extension intl n'est pas garantie (elle est
// désactivée par défaut dans php.ini sous XAMPP), et son absence provoquerait
// une erreur fatale au premier enregistrement. Trois niveaux de repli.
function _tabSlugify(string $s): string
{
  $s = mb_strtolower($s, 'UTF-8');

  if (function_exists('transliterator_transliterate')):
    $s = transliterator_transliterate('Any-Latin; Latin-ASCII', $s) ?: $s;
  else:
    $s = strtr($s, [
      'à'=>'a','â'=>'a','ä'=>'a','á'=>'a','ã'=>'a','å'=>'a',
      'ç'=>'c','é'=>'e','è'=>'e','ê'=>'e','ë'=>'e',
      'î'=>'i','ï'=>'i','í'=>'i','ì'=>'i',
      'ô'=>'o','ö'=>'o','ó'=>'o','ò'=>'o','õ'=>'o',
      'ù'=>'u','û'=>'u','ü'=>'u','ú'=>'u',
      'ÿ'=>'y','ñ'=>'n','œ'=>'oe','æ'=>'ae',
    ]);
  endif;

  $s = preg_replace('/[^a-z0-9]+/', '-', $s);
  return substr(trim($s, '-') ?: 'tableau', 0, 120);
}
