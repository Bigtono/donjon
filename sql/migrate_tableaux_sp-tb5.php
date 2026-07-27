<?php
// sql/migrate_tableaux_sp-tb5.php — Migration SP-TB5
//
// Extrait les tableaux HTML encore présents dans dd_regles.reg_texte, les crée
// dans dd_tableaux au format convention, et remplace le bloc HTML par le tag
// [[tab:slug]] dans le corps de la règle.
//
// Traite le motif nominal produit par l'import DD2024 :
//     <p class="table-titre"><strong>TITRE</strong></p>
//     <table …>…</table>
// ainsi qu'un <table> isolé (titre = nom de la règle).
//
// Deux tableaux au contenu ET au titre identiques ne sont créés qu'une fois et
// partagent le même tag — c'est le gain principal du refactor (« Bonus de
// maîtrise » est aujourd'hui dupliqué dans deux règles).
//
// USAGE — navigateur, connecté en admin (ruleset actif = celui de la session) :
//   /donjon/sql/migrate_tableaux_sp-tb5.php        → simulation (rien n'est écrit)
//   /donjon/sql/migrate_tableaux_sp-tb5.php?go=1   → application
//
// USAGE — CLI (le ruleset doit être passé explicitement, il n'y a pas de session) :
//   php sql/migrate_tableaux_sp-tb5.php --ruleset=2
//   php sql/migrate_tableaux_sp-tb5.php --ruleset=2 --go
//
// Idempotent : une seconde exécution ne trouve plus aucun <table> à migrer.
//
// Prérequis : 2026-07-27_tableaux_sp-tb0.sql appliqué.
// Référence : doc/ARCHITECTURE_0_REFERENCE.md §9c

require_once __DIR__ . '/../include/db.php';
require_once __DIR__ . '/../include/auth.php';
require_once __DIR__ . '/../include/helpers.php';
require_once __DIR__ . '/../include/tableau-parser.php';

$est_cli = PHP_SAPI === 'cli';

if ($est_cli):
  // En CLI, l'accès au système de fichiers vaut déjà accès admin — le garde
  // requireAdmin() n'aurait rien à protéger et ne ferait qu'empêcher l'exécution
  // (pas de session HTTP).
  $args       = getopt('', ['go', 'ruleset:']);
  $appliquer  = isset($args['go']);
  $ruleset_id = (int)($args['ruleset'] ?? 0);
  if (!$ruleset_id):
    fwrite(STDERR, "Usage : php migrate_tableaux_sp-tb5.php --ruleset=<id> [--go]\n");
    exit(1);
  endif;
else:
  requireAuth();
  requireAdmin();
  header('Content-Type: text/html; charset=utf-8');
  $appliquer  = isset($_GET['go']);
  $ruleset_id = (int)($_SESSION['ruleset_var_id'] ?? 1);
endif;

// En CLI, le HTML de mise en forme est du bruit : on ne garde que le texte.
function _mig_echo(string $html): void
{
  if (PHP_SAPI !== 'cli'):
    echo $html;
    return;
  endif;
  // Les balises de bloc portent le retour à la ligne : sans cela, une liste
  // <li> ressortirait en une seule ligne collée.
  $html = preg_replace('#</(p|li|h1|h2|ul|pre|div)>#i', "\n", $html);
  $txt  = html_entity_decode(strip_tags($html), ENT_QUOTES | ENT_HTML5, 'UTF-8');
  $txt  = rtrim($txt);
  if (trim($txt) !== '') echo $txt . "\n";
}

if (!$est_cli):
  echo '<!doctype html><meta charset="utf-8"><title>Migration SP-TB5</title>';
  echo '<style>body{font-family:system-ui,sans-serif;max-width:1100px;margin:2rem auto;padding:0 1rem}'
     . 'pre{background:#f4f1eb;padding:.5rem;overflow-x:auto;font-size:.8rem}'
     . 'h2{border-bottom:2px solid #8b2020;color:#8b2020;font-size:1.1rem;margin-top:2rem}'
     . '.ok{color:#2a7a3b}.warn{color:#a06010}.err{color:#c0392b}</style>';
endif;

_mig_echo('<h1>Migration SP-TB5 — tableaux HTML → dd_tableaux</h1>');
_mig_echo('<p>Ruleset : <strong>' . h((string)($_SESSION['rulesetRep'] ?? $ruleset_id)) . '</strong> — '
   . ($appliquer
      ? '<strong class="err">MODE APPLICATION</strong> (écriture en base)'
      : '<strong class="warn">SIMULATION</strong> — '
        . ($est_cli ? 'ajouter --go pour appliquer' : 'ajouter <code>?go=1</code> pour appliquer'))
   . '</p>');

// ============================================================
// Conversion d'un <table> HTML en contenu convention
// ============================================================
// Retourne ['contenu' => string, 'alertes' => [string,…]] ou null si le tableau
// utilise des fusions (colspan/rowspan) : elles ne sont pas devinables de façon
// fiable, on préfère alerter et laisser l'auteur reprendre le tableau à la main.

function _mig_convertirTable(string $html): ?array
{
  $alertes = [];

  if (preg_match('/\b(colspan|rowspan)\s*=/i', $html)):
    return null;
  endif;

  if (!preg_match_all('/<tr\b[^>]*>(.*?)<\/tr>/is', $html, $m_tr)):
    return null;
  endif;

  $lignes = [];
  foreach ($m_tr[1] as $tr):
    if (!preg_match_all('/<(th|td)\b[^>]*>(.*?)<\/\1>/is', $tr, $m_c, PREG_SET_ORDER)):
      continue;
    endif;

    $est_entete = true;
    $cellules   = [];
    foreach ($m_c as $c):
      if (strtolower($c[1]) !== 'th') $est_entete = false;

      $txt = html_entity_decode(strip_tags($c[2]), ENT_QUOTES | ENT_HTML5, 'UTF-8');
      $txt = trim(preg_replace('/\s+/u', ' ', $txt));

      // Le « | » est le séparateur de cellules : il ne peut pas rester dans
      // le contenu. Aucun cas dans les données actuelles ; on trace si besoin.
      if (str_contains($txt, '|')):
        $alertes[] = 'Caractère « | » remplacé par « / » dans : ' . mb_substr($txt, 0, 40);
        $txt = str_replace('|', '/', $txt);
      endif;

      $cellules[] = $txt;
    endforeach;

    if (empty($cellules)) continue;
    $lignes[] = ($est_entete ? '! ' : '') . implode(' | ', $cellules);
  endforeach;

  if (empty($lignes)) return null;
  return ['contenu' => implode("\n", $lignes), 'alertes' => $alertes];
}

// ============================================================
// Parcours des règles
// ============================================================

$stmt = $db->prepare('
  SELECT reg_id, reg_nom, reg_slug, reg_texte
  FROM   dd_regles
  WHERE  reg_ruleset_var_id = ? AND reg_texte LIKE ?
  ORDER  BY reg_id
');
$stmt->execute([$ruleset_id, '%<table%']);
$regles = $stmt->fetchAll();

if (empty($regles)):
  _mig_echo('<p class="ok">Aucun tableau HTML restant dans reg_texte — rien à migrer.</p>');
  exit;
endif;

// Motif : titre optionnel immédiatement suivi du tableau
$motif = '#(?:<p\b[^>]*class="table-titre"[^>]*>\s*(?:<strong>)?(.*?)(?:</strong>)?\s*</p>\s*)?'
       . '<table\b[^>]*>.*?</table>#is';

$deja_crees = [];   // clé nom|contenu → slug (dédoublonnage)
$nb_crees   = 0;
$nb_reuse   = 0;
$nb_ignores = 0;

if ($appliquer) $db->beginTransaction();

foreach ($regles as $reg):
  _mig_echo('<h2>' . h($reg['reg_nom']) . ' (reg_id ' . (int)$reg['reg_id'] . ')</h2>');

  $modifie = false;

  $nouveau_texte = preg_replace_callback(
    $motif,
    function ($m) use (
      $db, $reg, $ruleset_id, $appliquer,
      &$deja_crees, &$nb_crees, &$nb_reuse, &$nb_ignores, &$modifie
    ) {
      $bloc  = $m[0];
      $titre = isset($m[1]) ? trim(html_entity_decode(strip_tags($m[1]), ENT_QUOTES | ENT_HTML5, 'UTF-8')) : '';
      if ($titre === '') $titre = $reg['reg_nom'];

      $conv = _mig_convertirTable($bloc);
      if ($conv === null):
        $nb_ignores++;
        _mig_echo('<p class="err">  [IGNORE] « ' . h($titre) . ' » '
           . '(fusions colspan/rowspan ou structure non reconnue) — à reprendre à la main.</p>');
        return $bloc;   // bloc laissé tel quel
      endif;

      foreach ($conv['alertes'] as $a):
        _mig_echo('<p class="warn">  [ALERTE] ' . h($a) . '</p>');
      endforeach;

      $cle = $titre . '|' . $conv['contenu'];

      if (isset($deja_crees[$cle])):
        $slug = $deja_crees[$cle];
        $nb_reuse++;
        _mig_echo('<p class="ok">  [REUSE]  « ' . h($titre) . ' » — identique à un tableau déjà migré, '
           . 'réutilisation de [[tab:' . h($slug) . ']]</p>');
      else:
        $slug = $appliquer
          ? tableauGenererSlug($db, $titre, $ruleset_id)
          : _tabSlugify($titre);

        if ($appliquer):
          $ins = $db->prepare('
            INSERT INTO dd_tableaux
              (tab_slug, tab_nom, tab_contenu, tab_ruleset_var_id, tab_visible,
               tab_date_creation, tab_date_modif)
            VALUES (?,?,?,?,1,NOW(),NOW())
          ');
          $ins->execute([$slug, $titre, $conv['contenu'], $ruleset_id]);
        endif;

        $deja_crees[$cle] = $slug;
        $nb_crees++;
        _mig_echo('<p class="ok">  [CREE]   « ' . h($titre) .' » → [[tab:' . h($slug) . ']]</p>');
        _mig_echo('<pre>' . h($conv['contenu']) . '</pre>');
      endif;

      $modifie = true;
      return '<p>[[tab:' . $slug . ']]</p>';
    },
    (string)$reg['reg_texte']
  );

  if ($modifie && $appliquer):
    $upd = $db->prepare('
      UPDATE dd_regles SET reg_texte = ?, reg_date_modif = NOW()
      WHERE  reg_id = ? AND reg_ruleset_var_id = ?
    ');
    $upd->execute([$nouveau_texte, (int)$reg['reg_id'], $ruleset_id]);
  endif;

  if (!$modifie):
    _mig_echo('<p class="warn">  Aucun bloc migrable dans cette règle.</p>');
  endif;
endforeach;

if ($appliquer) $db->commit();

_mig_echo('<h2>Bilan</h2>');
_mig_echo('<ul>'
   . '<li>' . $nb_crees   . ' tableau(x) créé(s)</li>'
   . '<li>' . $nb_reuse   . ' réutilisation(s) d\'un tableau identique</li>'
   . '<li class="' . ($nb_ignores ? 'err' : 'ok') . '">' . $nb_ignores . ' ignoré(s)</li>'
   . '</ul>');

if (!$appliquer):
  _mig_echo($est_cli
    ? '<p>Relancer avec --go pour appliquer.</p>'
    : '<p><a href="?go=1"><strong>Appliquer la migration</strong></a></p>');
else:
  _mig_echo('<p class="ok"><strong>Migration appliquée.</strong></p>');
  if (!$est_cli):
    echo '<p><a href="' . BASE_URL . '/regles/tableaux.php">Voir les tableaux</a></p>';
  endif;
endif;
