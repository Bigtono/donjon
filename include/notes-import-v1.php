<?php
// include/notes-import-v1.php — Import des notes de la v1 (SP-NO7, D-NO14).
//
// Source : tables de transit dd_v1_notes / dd_v1_notes_contenus / dd_v1_notes_tags
// (migration sql/2026-11-01_sp-no7_notes_v1_transit.sql). Règles arbitrées :
//   - campagne cible choisie à l'import ; rédacteur = MJ de la campagne ; date v1 conservée ;
//     aucun destinataire (le MJ diffuse ensuite) ; scénario vide (toute la campagne) ;
//   - blocs DD ≤ 10 → tronc commun ; blocs DD > 10 → une section chacun, conditionnée au même DD
//     par les compétences choisies pour le type v1 (OU) ;
//   - images retirées ; lien relatif de la v1 (href sans http) remplacé par son texte ;
//     entités HTML converties en caractères (la recherche LIKE trouve les accents), sauf &lt; &gt; &amp; &quot; ;
//   - colonnes no_texte_basique … expert ignorées (copies anciennes des blocs).
// Utilisé par admin/import-notes-v1.php.

require_once __DIR__ . '/personnage_helpers.php'; // texteRicheVide()
require_once __DIR__ . '/tableau-parser.php';     // _tabSlugify()

// Catégorie proposée par type v1 (libellés v1 absents de l'export : déduits des titres des notes)
const NOTES_V1_CATEGORIE = [
  1 => 'Indices et documents',
  2 => 'Culture et société',
  3 => 'Géographie et lieux',
  4 => 'Histoire',
  5 => 'Magie et arcanes',
  6 => 'Personnages',
  7 => 'Indices et documents',
  8 => 'Organisations et factions',
];

// Compétences proposées par catégorie, selon le ruleset (noms de dd_competences)
const NOTES_V1_COMPETENCES = [
  'DD2024' => [
    'Indices et documents'      => ['Investigation'],
    'Culture et société'        => ['Histoire'],
    'Géographie et lieux'       => ['Histoire'],
    'Histoire'                  => ['Histoire'],
    'Magie et arcanes'          => ['Arcanes'],
    'Personnages'               => ['Histoire', 'Intuition'],
    'Organisations et factions' => ['Histoire'],
    'Religions et divinités'    => ['Religion'],
    'Créatures'                 => ['Nature', 'Arcanes'],
    'Objets et artefacts'       => ['Arcanes'],
    'Divers'                    => ['Histoire'],
  ],
  // Spécialités de Connaissances (D-NO15) plutôt que la compétence générique
  'DD3.5' => [
    'Indices et documents'      => ['Connaissances (mystères)', 'Décryptage'],
    'Culture et société'        => ['Connaissances (folklore local)', 'Connaissances (histoire)'],
    'Géographie et lieux'       => ['Connaissances (géographie)', 'Connaissances (folklore local)'],
    'Histoire'                  => ['Connaissances (histoire)'],
    'Magie et arcanes'          => ['Connaissances (mystères)', 'Art de la magie'],
    'Personnages'               => ['Connaissances (folklore local)', 'Connaissances (noblesse et royauté)'],
    'Organisations et factions' => ['Connaissances (noblesse et royauté)', 'Connaissances (histoire)'],
    'Religions et divinités'    => ['Connaissances (religion)'],
    'Créatures'                 => ['Connaissances (nature)', 'Connaissances (mystères)'],
    'Objets et artefacts'       => ['Connaissances (mystères)', 'Art de la magie'],
    'Divers'                    => ['Connaissances (histoire)'],
  ],
];

/**
 * Nettoie le HTML d'un bloc v1 : images retirées, liens relatifs déballés,
 * entités converties, paragraphes vidés supprimés.
 */
function nettoyerHtmlV1(string $html): string {
  $html = preg_replace('/<img\b[^>]*>/i', '', $html);
  // Lien vers un fichier de la v1 (chemin relatif) : on garde le texte du lien
  $html = preg_replace('/<a\b(?![^>]*\bhref\s*=\s*["\']?(?:https?:|mailto:|#))[^>]*>(.*?)<\/a>/is', '$1', $html);
  $html = preg_replace_callback('/&(?!(?:lt|gt|amp|quot);)(?:[a-zA-Z][a-zA-Z0-9]*|#\d+|#x[0-9a-fA-F]+);/', function ($m) {
    $c = html_entity_decode($m[0], ENT_QUOTES | ENT_HTML5, 'UTF-8');
    return in_array($c, ['<', '>', '&', '"'], true) ? $m[0] : $c;
  }, $html);
  $html = preg_replace('/<p\b[^>]*>(?:\s|\x{00A0}|<br\s*\/?>)*<\/p>/iu', '', $html);
  return trim($html);
}

/** Types v1 présents : [tyno_id => [nb, titres[]]] */
function typesNotesV1(PDO $db): array {
  $types = [];
  foreach ($db->query('SELECT no_tyno_id, no_nom FROM dd_v1_notes ORDER BY no_tyno_id, no_nom') as $r):
    $t = (int)$r['no_tyno_id'];
    $types[$t]['titres'][] = $r['no_nom'];
  endforeach;
  return $types;
}

/** Mots-clés v1 : [tag_id => titres des notes][] */
function tagsNotesV1(PDO $db): array {
  $tags = [];
  foreach ($db->query('SELECT t.notag_tag_id, n.no_nom FROM dd_v1_notes_tags t JOIN dd_v1_notes n ON n.no_id = t.notag_no_id ORDER BY t.notag_tag_id, n.no_nom') as $r):
    $tags[(int)$r['notag_tag_id']][] = $r['no_nom'];
  endforeach;
  return $tags;
}

/**
 * Propositions par défaut pour une campagne : [type v1 => ['tyno_id' => int, 'comp_ids' => int[]]]
 * $categories : [tyno_id => tyno_nom] du ruleset ; $competences : [comp_id => comp_nom] du ruleset.
 */
function propositionsImportV1(array $types, array $categories, array $competences, string $ruleset_rep): array {
  $par_nom_cat  = array_flip($categories);
  $par_nom_comp = [];
  foreach ($competences as $id => $nom) $par_nom_comp[trim($nom)] = $id;
  $props = [];
  foreach (array_keys($types) as $t):
    $cat = NOTES_V1_CATEGORIE[$t] ?? 'Divers';
    $noms_comp = NOTES_V1_COMPETENCES[$ruleset_rep][$cat] ?? ($ruleset_rep === 'DD3.5' ? ['Connaissances (histoire)'] : ['Histoire']);
    $props[$t] = [
      'tyno_id'  => (int)($par_nom_cat[$cat] ?? (array_key_first($categories) ?? 0)),
      'comp_ids' => array_values(array_filter(array_map(fn($n) => $par_nom_comp[$n] ?? 0, $noms_comp))),
    ];
  endforeach;
  return $props;
}

/**
 * Importe les notes v1 non encore importées dans la campagne.
 * $choix_types : [type v1 => ['tyno_id' => int, 'comp_ids' => int[]]] (déjà validés)
 * $noms_tags   : [tag v1 => libellé] (libellé vide = mot-clé ignoré)
 * Renvoie ['notes' => n, 'sections' => n, 'liens_tags' => n, 'blocs_vides' => n].
 */
function importerNotesV1(PDO $db, int $camp_id, int $mj_id, array $choix_types, array $noms_tags): array {
  $bilan = ['notes' => 0, 'sections' => 0, 'liens_tags' => 0, 'blocs_vides' => 0];
  $maintenant = date('Y-m-d H:i:s');

  $notes = $db->query('SELECT no_id, no_tyno_id, no_nom, no_date FROM dd_v1_notes WHERE no_importe_no_id IS NULL ORDER BY no_id')->fetchAll();
  $blocs = $db->prepare('SELECT noc_dd, noc_texte FROM dd_v1_notes_contenus WHERE noc_no_id = ? ORDER BY noc_dd, noc_id');
  $tags  = $db->prepare('SELECT notag_tag_id FROM dd_v1_notes_tags WHERE notag_no_id = ?');

  $ins_note = $db->prepare('INSERT INTO dd_notes (no_nom, no_camp_id, no_sce_id, no_tyno_id, no_texte, no_j_id, no_date) VALUES (?, ?, NULL, ?, ?, ?, ?)');
  $ins_sec  = $db->prepare('INSERT INTO dd_notes_contenus (noc_no_id, noc_ordre, noc_titre, noc_texte) VALUES (?, ?, NULL, ?)');
  $ins_cond = $db->prepare('INSERT INTO dd_notes_conditions (nocd_noc_id, nocd_comp_id, nocd_dd) VALUES (?, ?, ?)');
  $marquer  = $db->prepare('UPDATE dd_v1_notes SET no_importe_no_id = ? WHERE no_id = ?');
  $sel_tag  = $db->prepare('SELECT tag_id FROM dd_tags WHERE tag_j_id = ? AND tag_slug = ?');
  $ins_tag  = $db->prepare('INSERT INTO dd_tags (tag_nom, tag_slug, tag_j_id, tag_date) VALUES (?, ?, ?, ?)');
  $lien_tag = $db->prepare('INSERT IGNORE INTO dd_notes_tags (notag_no_id, notag_tag_id) VALUES (?, ?)');

  // Mots-clés v1 nommés → tag du MJ (trouvé ou créé)
  $tag_ids = [];
  foreach ($noms_tags as $v1 => $nom):
    $nom  = mb_substr(trim((string)$nom), 0, 80);
    $slug = _tabSlugify($nom);
    if ($nom === '' || $slug === '') continue;
    $sel_tag->execute([$mj_id, $slug]);
    $id = (int)$sel_tag->fetchColumn();
    if (!$id):
      $ins_tag->execute([$nom, $slug, $mj_id, $maintenant]);
      $id = (int)$db->lastInsertId();
    endif;
    $tag_ids[(int)$v1] = $id;
  endforeach;

  foreach ($notes as $n):
    $choix = $choix_types[(int)$n['no_tyno_id']];
    $blocs->execute([(int)$n['no_id']]);
    $tronc = []; $sections = [];
    foreach ($blocs->fetchAll() as $b):
      $html = nettoyerHtmlV1($b['noc_texte']);
      if (texteRicheVide($html)) { $bilan['blocs_vides']++; continue; }
      if ((int)$b['noc_dd'] <= 10) $tronc[] = $html;
      else $sections[] = ['dd' => max(1, min(60, (int)$b['noc_dd'])), 'html' => $html];
    endforeach;

    $ins_note->execute([mb_substr($n['no_nom'], 0, 200), $camp_id, $choix['tyno_id'], $tronc ? implode("\n", $tronc) : null, $mj_id, $n['no_date']]);
    $no_id = (int)$db->lastInsertId();

    foreach ($sections as $i => $s):
      $ins_sec->execute([$no_id, $i, $s['html']]);
      $noc_id = (int)$db->lastInsertId();
      foreach ($choix['comp_ids'] as $comp_id) $ins_cond->execute([$noc_id, $comp_id, $s['dd']]);
      $bilan['sections']++;
    endforeach;

    $tags->execute([(int)$n['no_id']]);
    foreach ($tags->fetchAll(PDO::FETCH_COLUMN) as $v1):
      if (!isset($tag_ids[(int)$v1])) continue;
      $lien_tag->execute([$no_id, $tag_ids[(int)$v1]]);
      $bilan['liens_tags'] += $lien_tag->rowCount();
    endforeach;

    $marquer->execute([$no_id, (int)$n['no_id']]);
    $bilan['notes']++;
  endforeach;

  return $bilan;
}
