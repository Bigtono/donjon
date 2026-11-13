<?php
// include/ressource-suppression.php — Suppression en cascade d'une ressource (SP-AD6)
// ============================================================
// Une ressource emporte tout son contenu (contenuRessourceTables()) et tout ce qui
// en dépend. La base n'a presque aucune clé étrangère : chaque dépendance est donc
// décrite ici, une seule fois, dans ressourceRelations(). Cette carte sert à la fois :
//   1. à l'analyse affichée avant confirmation (ressourceSuppressionAnalyse()) ;
//   2. aux refus (personnages, données de campagne, contenu d'une autre ressource) ;
//   3. à la cascade elle-même (ressourceSupprimerCascade()) ;
//   4. à la vérification « zéro orphelin » faite AVANT le COMMIT (ressourceOrphelins()) ;
//   5. au rapport global des orphelins (admin/orphelins.php).
// Une relation oubliée ici l'est donc partout à la fois — et le test de couverture du
// schéma (voir DECISIONS_LOG, SP-AD6) le signale.
//
// Arbitrages (D-AD6, 2026-11-11) :
//   - un personnage qui utilise du contenu de la ressource BLOQUE la suppression ;
//   - un contenu d'une AUTRE ressource qui dépend d'une entrée supprimée (sous-classe,
//     règle enfant, compétence enfant) BLOQUE la suppression : on ne supprime jamais
//     rien hors de la ressource ;
//   - les liens faibles (opposition créée depuis un monstre, objet magique basé sur un
//     sort) sont COUPÉS (NULL), l'élément qui les porte reste ;
//   - une capacité spéciale n'est supprimée que si plus rien ne la référence (SP-DU6).
//
// Les noms de tables et de colonnes ne viennent que des tableaux statiques de ce
// fichier ; toutes les valeurs passent par des requêtes préparées.

require_once __DIR__ . '/helpers.php';

// Clé « entité » des capacités spéciales : elles n'ont pas de ressource, elles suivent
// leurs classes et leurs races.
const RS_CAPACITE = 'capacite';

// ============================================================
// Carte des dépendances
// ============================================================
// cible   : clé de contenuRessourceTables() (ou RS_CAPACITE) dont l'id est référencé
// table / col : la colonne qui référence cet id
// mode    : 'cascade'  → lignes supprimées avec la cible
//           'perso'    → donnée de personnage : bloque (pe = expression SQL du pe_id)
//           'campagne' → donnée de campagne du MJ : bloque (libelle = expression SQL)
//           'enfant'   → même table, enfant d'une autre ressource : bloque
//                        (res = colonne ressource de l'enfant, id/nom = colonnes de l'enfant)
//           'null'     → lien coupé (set = colonnes remises à NULL)
// libelle : nom lisible de la relation, pour l'analyse et le rapport
function ressourceRelations(): array {
  return [
    // --- Classes ---
    ['cible' => 'nb_classes', 'table' => 'dd_classe_capacite',   'col' => 'cc_cla_id',    'mode' => 'cascade', 'libelle' => 'Capacités attribuées aux classes'],
    ['cible' => 'nb_classes', 'table' => 'dd_classe_niveau',     'col' => 'cn_cla_id',    'mode' => 'cascade', 'libelle' => 'Progression des classes (niveaux)'],
    ['cible' => 'nb_classes', 'table' => 'dd_classe_competence', 'col' => 'ccomp_cla_id', 'mode' => 'cascade', 'libelle' => 'Compétences de classe'],
    ['cible' => 'nb_classes', 'table' => 'dd_classe_sort',       'col' => 'cs_cla_id',    'mode' => 'cascade', 'libelle' => 'Sorts toujours préparés (classe)'],
    ['cible' => 'nb_classes', 'table' => 'dd_sortclasse',        'col' => 'sc_cla_id',    'mode' => 'cascade', 'libelle' => 'Listes de sorts des classes'],
    ['cible' => 'nb_classes', 'table' => 'dd_classes',           'col' => 'cla_cla_id',   'mode' => 'enfant',  'libelle' => 'Sous-classe d\'une autre ressource',
     'res' => 'cla_res_id', 'id' => 'cla_id', 'nom' => 'cla_nom'],
    ['cible' => 'nb_classes', 'table' => 'dd_personnages_classes',             'col' => 'pc_cla_id',   'mode' => 'perso', 'libelle' => 'Classe d\'un personnage',            'pe' => 'pc_pe_id'],
    ['cible' => 'nb_classes', 'table' => 'dd_personnages_sorts_prepares',      'col' => 'pesp_cla_id', 'mode' => 'perso', 'libelle' => 'Sorts préparés d\'un personnage',     'pe' => 'pesp_pe_id'],
    ['cible' => 'nb_classes', 'table' => 'dd_personnages_choix',               'col' => 'pech_cla_id', 'mode' => 'perso', 'libelle' => 'Choix de capacité d\'un personnage', 'pe' => 'pech_pe_id'],
    ['cible' => 'nb_classes', 'table' => 'dd_personnages_possessions_elements', 'col' => 'ppe_cla_id', 'mode' => 'perso', 'libelle' => 'Possession d\'un personnage',
     'pe' => '(SELECT pp_pe_id FROM dd_personnages_possessions WHERE pp_id = ppe_pp_id)'],

    // --- Capacités spéciales (suivent les classes et les races) ---
    ['cible' => RS_CAPACITE, 'table' => 'dd_classe_capacite',   'col' => 'cc_cap_id',   'mode' => 'cascade', 'libelle' => 'Capacités attribuées aux classes'],
    ['cible' => RS_CAPACITE, 'table' => 'dd_race_capacite',     'col' => 'cr_cap_id',   'mode' => 'cascade', 'libelle' => 'Capacités attribuées aux races'],
    ['cible' => RS_CAPACITE, 'table' => 'dd_personnages_choix', 'col' => 'pech_cap_id', 'mode' => 'perso',   'libelle' => 'Choix de capacité d\'un personnage', 'pe' => 'pech_pe_id'],

    // --- Races ---
    ['cible' => 'nb_races', 'table' => 'dd_race_capacite', 'col' => 'cr_ra_id',  'mode' => 'cascade', 'libelle' => 'Capacités attribuées aux races'],
    ['cible' => 'nb_races', 'table' => 'dd_personnages',   'col' => 'pe_ra_id',  'mode' => 'perso',   'libelle' => 'Race d\'un personnage',      'pe' => 'pe_id'],
    ['cible' => 'nb_races', 'table' => 'dd_personnages',   'col' => 'pe_arc_id', 'mode' => 'perso',   'libelle' => 'Archétype d\'un personnage', 'pe' => 'pe_id'],

    // --- Sorts ---
    ['cible' => 'nb_sorts', 'table' => 'dd_sortclasse',  'col' => 'sc_so_id', 'mode' => 'cascade', 'libelle' => 'Listes de sorts des classes'],
    ['cible' => 'nb_sorts', 'table' => 'dd_sortdomaine', 'col' => 'sd_so_id', 'mode' => 'cascade', 'libelle' => 'Listes de sorts des domaines'],
    ['cible' => 'nb_sorts', 'table' => 'dd_classe_sort', 'col' => 'cs_so_id', 'mode' => 'cascade', 'libelle' => 'Sorts toujours préparés (classe)'],
    ['cible' => 'nb_sorts', 'table' => 'dd_objets_magiques', 'col' => 'om_so_id', 'mode' => 'null', 'libelle' => 'Objets magiques basés sur un sort',
     'set' => ['om_so_id', 'om_so_niveau']],
    ['cible' => 'nb_sorts', 'table' => 'dd_personnages_sorts', 'col' => 'pes_so_id', 'mode' => 'perso', 'libelle' => 'Sorts d\'un personnage',
     'pe' => '(SELECT pc_pe_id FROM dd_personnages_classes WHERE pc_id = pes_pc_id)'],
    ['cible' => 'nb_sorts', 'table' => 'dd_personnages_sorts_prepares',      'col' => 'pesp_so_id', 'mode' => 'perso', 'libelle' => 'Sorts préparés d\'un personnage', 'pe' => 'pesp_pe_id'],
    ['cible' => 'nb_sorts', 'table' => 'dd_personnages_possessions_elements', 'col' => 'ppe_so_id', 'mode' => 'perso', 'libelle' => 'Possession d\'un personnage',
     'pe' => '(SELECT pp_pe_id FROM dd_personnages_possessions WHERE pp_id = ppe_pp_id)'],

    // --- Domaines (DD3.5) ---
    ['cible' => 'nb_domaines', 'table' => 'dd_sortdomaine',         'col' => 'sd_do_id',   'mode' => 'cascade', 'libelle' => 'Listes de sorts des domaines'],
    ['cible' => 'nb_domaines', 'table' => 'dd_personnages_classes', 'col' => 'pc_do_id_1', 'mode' => 'perso',   'libelle' => 'Domaine d\'un personnage', 'pe' => 'pc_pe_id'],
    ['cible' => 'nb_domaines', 'table' => 'dd_personnages_classes', 'col' => 'pc_do_id_2', 'mode' => 'perso',   'libelle' => 'Domaine d\'un personnage', 'pe' => 'pc_pe_id'],

    // --- Dons ---
    ['cible' => 'nb_dons', 'table' => 'dd_personnages_dons',  'col' => 'ped_do_id',  'mode' => 'perso', 'libelle' => 'Don d\'un personnage',               'pe' => 'ped_pe_id'],
    ['cible' => 'nb_dons', 'table' => 'dd_personnages_choix', 'col' => 'pech_do_id', 'mode' => 'perso', 'libelle' => 'Choix de capacité d\'un personnage', 'pe' => 'pech_pe_id'],

    // --- Compétences ---
    ['cible' => 'nb_comp', 'table' => 'dd_competences_synergies', 'col' => 'syn_comp_source_id', 'mode' => 'cascade', 'libelle' => 'Synergies de compétences'],
    ['cible' => 'nb_comp', 'table' => 'dd_competences_synergies', 'col' => 'syn_comp_cible_id',  'mode' => 'cascade', 'libelle' => 'Synergies de compétences'],
    ['cible' => 'nb_comp', 'table' => 'dd_classe_competence',     'col' => 'ccomp_comp_id',      'mode' => 'cascade', 'libelle' => 'Compétences de classe'],
    ['cible' => 'nb_comp', 'table' => 'dd_competences',           'col' => 'comp_parent_id',     'mode' => 'enfant',  'libelle' => 'Compétence enfant d\'une autre ressource',
     'res' => 'comp_res_id', 'id' => 'comp_id', 'nom' => 'comp_nom'],
    ['cible' => 'nb_comp', 'table' => 'dd_personnages_competences', 'col' => 'pec_comp_id', 'mode' => 'perso', 'libelle' => 'Compétence d\'un personnage', 'pe' => 'pec_pe_id'],
    ['cible' => 'nb_comp', 'table' => 'dd_notes_conditions', 'col' => 'nocd_comp_id', 'mode' => 'campagne', 'libelle' => 'Condition d\'une note de campagne',
     'detail' => "(SELECT CONCAT(n.no_nom, IF(n.no_supprime = 1, ' (note supprimée)', ''))
                     FROM dd_notes_contenus c JOIN dd_notes n ON n.no_id = c.noc_no_id
                    WHERE c.noc_id = nocd_noc_id)"],

    // --- Historiques ---
    ['cible' => 'nb_hist', 'table' => 'dd_personnages', 'col' => 'pe_hi_id', 'mode' => 'perso', 'libelle' => 'Historique d\'un personnage', 'pe' => 'pe_id'],

    // --- Objets magiques ---
    ['cible' => 'nb_objets', 'table' => 'dd_personnages_possessions', 'col' => 'pp_om_id', 'mode' => 'perso', 'libelle' => 'Possession d\'un personnage', 'pe' => 'pp_pe_id'],
    ['cible' => 'nb_objets', 'table' => 'dd_personnages_possessions_elements', 'col' => 'ppe_om_id', 'mode' => 'perso', 'libelle' => 'Possession d\'un personnage',
     'pe' => '(SELECT pp_pe_id FROM dd_personnages_possessions WHERE pp_id = ppe_pp_id)'],

    // --- Monstres ---
    ['cible' => 'nb_monstres', 'table' => 'dd_oppositions', 'col' => 'opp_mo_id', 'mode' => 'null', 'libelle' => 'Oppositions de campagne créées depuis un monstre',
     'set' => ['opp_mo_id']],

    // --- Équipements ---
    ['cible' => 'nb_equipements', 'table' => 'dd_personnages_possessions', 'col' => 'pp_eqt_id', 'mode' => 'perso', 'libelle' => 'Possession d\'un personnage', 'pe' => 'pp_pe_id'],

    // --- Règles ---
    ['cible' => 'nb_regles', 'table' => 'dd_regles', 'col' => 'reg_reg_id', 'mode' => 'enfant', 'libelle' => 'Règle enfant d\'une autre ressource',
     'res' => 'reg_res_id', 'id' => 'reg_id', 'nom' => 'reg_nom'],

    // --- Tableaux ---
    ['cible' => 'nb_tableaux', 'table' => 'dd_campagnes_ecran', 'col' => 'ce_tab_id', 'mode' => 'cascade', 'libelle' => 'Tableaux de l\'écran du MJ'],
  ];
}

// Colonnes de référence volontairement HORS carte : tables héritées de la v1 ou de
// sauvegardes d'import, jamais lues par l'application. Le test de couverture du
// schéma les ignore.
function ressourceTablesHeritees(): array {
  return ['dd_objets_magiques_v1', 'dd_sorts_import', 'dd_classe_niveau_old',
          'dd_classe_niveau_backup_pe7a', 'dd_sorts_branche_backup_spma3', 'dnd35_dons'];
}

// Mot à ressaisir pour confirmer : l'abréviation, à défaut le nom (plusieurs
// ressources n'ont pas d'abréviation).
function ressourceMotDeConfirmation(array $res): string {
  $abr = trim((string)($res['res_abreviation'] ?? ''));
  return $abr !== '' ? $abr : trim((string)$res['res_nom']);
}

// ============================================================
// Outils
// ============================================================

// « ?,?,? » — jamais appelé avec un tableau vide (les appelants testent avant).
function _rsIn(array $ids): string {
  return resIdsPlaceholders($ids);
}

// Exécute une requête préparée et renvoie la première colonne.
function _rsColonne(PDO $db, string $sql, array $params): array {
  $stmt = $db->prepare($sql);
  $stmt->execute($params);
  return array_map('intval', $stmt->fetchAll(PDO::FETCH_COLUMN));
}

// Ids de chaque entité portée par la ressource : [cle => int[]]
function ressourceIdsContenu(PDO $db, int $res_id): array {
  $ids = [];
  foreach (contenuRessourceTables() as $cle => $t):
    $ids[$cle] = _rsColonne($db,
      'SELECT ' . $t['id'] . ' FROM ' . $t['table'] . ' WHERE ' . $t['champ'] . ' = ?', [$res_id]);
  endforeach;
  return $ids;
}

// Capacités spéciales qui n'auront plus aucun lien une fois les classes et races
// de la ressource supprimées. Un choix de personnage (pech_cap_id) les garde en vie
// — et s'il porte sur une classe supprimée, il bloque de toute façon.
function ressourceCapacitesSansLien(PDO $db, array $cla_ids, array $ra_ids): array {
  $candidates = [];
  if ($cla_ids):
    $candidates = _rsColonne($db,
      'SELECT DISTINCT cc_cap_id FROM dd_classe_capacite WHERE cc_cla_id IN (' . _rsIn($cla_ids) . ')', $cla_ids);
  endif;
  if ($ra_ids):
    $candidates = array_merge($candidates, _rsColonne($db,
      'SELECT DISTINCT cr_cap_id FROM dd_race_capacite WHERE cr_ra_id IN (' . _rsIn($ra_ids) . ')', $ra_ids));
  endif;
  $candidates = array_values(array_unique($candidates));
  if (!$candidates) return [];

  $sql = 'SELECT cap_id FROM dd_capacites_speciales WHERE cap_id IN (' . _rsIn($candidates) . ')
            AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite WHERE cc_cap_id = cap_id'
               . ($cla_ids ? ' AND cc_cla_id NOT IN (' . _rsIn($cla_ids) . ')' : '') . ')
            AND NOT EXISTS (SELECT 1 FROM dd_race_capacite WHERE cr_cap_id = cap_id'
               . ($ra_ids ? ' AND cr_ra_id NOT IN (' . _rsIn($ra_ids) . ')' : '') . ')
            AND NOT EXISTS (SELECT 1 FROM dd_personnages_choix WHERE pech_cap_id = cap_id)';
  return _rsColonne($db, $sql, array_merge($candidates, $cla_ids, $ra_ids));
}

// Règles de la ressource dans l'ordre de suppression : les feuilles d'abord
// (reg_reg_id est une clé étrangère RESTRICT).
function ressourceReglesFeuillesDabord(PDO $db, int $res_id): array {
  $stmt = $db->prepare('SELECT reg_id, reg_reg_id FROM dd_regles WHERE reg_res_id = ?');
  $stmt->execute([$res_id]);
  $parent = [];
  foreach ($stmt->fetchAll() as $r):
    $parent[(int)$r['reg_id']] = $r['reg_reg_id'] !== null ? (int)$r['reg_reg_id'] : null;
  endforeach;

  // Profondeur de chaque nœud dans l'arbre restreint à la ressource.
  // array_key_exists et non isset : une racine a un parent NULL, et isset(NULL) est faux.
  $profondeur = [];
  foreach (array_keys($parent) as $id):
    $p = 0;
    $n = $id;
    $vus = [];
    while ($parent[$n] !== null && array_key_exists($parent[$n], $parent) && !isset($vus[$n])):
      $vus[$n] = true;
      $n = $parent[$n];
      $p++;
    endwhile;
    $profondeur[$id] = $p;
  endforeach;
  arsort($profondeur);
  return array_map('intval', array_keys($profondeur));
}

// ============================================================
// Analyse (lecture seule) — affichée avant confirmation, refaite au moment d'agir
// ============================================================

function ressourceSuppressionAnalyse(PDO $db, int $res_id): array {
  $stmt = $db->prepare('SELECT * FROM dd_ressources WHERE res_id = ?');
  $stmt->execute([$res_id]);
  $res = $stmt->fetch();
  if (!$res) return ['trouvee' => false];

  $tables = contenuRessourceTables();
  $ids    = ressourceIdsContenu($db, $res_id);
  $ids[RS_CAPACITE] = ressourceCapacitesSansLien($db, $ids['nb_classes'], $ids['nb_races']);

  // Volumes de contenu
  $contenu = [];
  foreach ($tables as $cle => $t):
    if ($ids[$cle]) $contenu[] = ['libelle' => $t['label'], 'nb' => count($ids[$cle])];
  endforeach;
  if ($ids[RS_CAPACITE]) $contenu[] = ['libelle' => 'Capacités spéciales (sans autre usage)', 'nb' => count($ids[RS_CAPACITE])];

  $liaisons   = [];   // libellé => nb lignes supprimées
  $liens      = [];   // libellé => nb liens coupés
  $persos     = [];   // pe_id => ['nom' => …, 'elements' => [libellé…]]
  $campagne   = [];   // [libellé, détail]
  $dependants = [];   // [libellé, nom, ressource]

  foreach (ressourceRelations() as $rel):
    $cible = $ids[$rel['cible']] ?? [];
    if (!$cible) continue;
    $in = _rsIn($cible);

    switch ($rel['mode']):
      case 'cascade':
        $nb = (int)_rsColonne($db, "SELECT COUNT(*) FROM {$rel['table']} WHERE {$rel['col']} IN ($in)", $cible)[0];
        if ($nb > 0) $liaisons[$rel['libelle']] = ($liaisons[$rel['libelle']] ?? 0) + $nb;
        break;

      case 'null':
        // Les lignes de la ressource elle-même seront supprimées : on ne compte que les autres
        $sql    = "SELECT COUNT(*) FROM {$rel['table']} WHERE {$rel['col']} IN ($in)";
        $params = $cible;
        if ($rel['table'] === 'dd_objets_magiques'):
          $sql     .= ' AND om_res_id <> ?';
          $params[] = $res_id;
        endif;
        $nb = (int)_rsColonne($db, $sql, $params)[0];
        if ($nb > 0) $liens[$rel['libelle']] = ($liens[$rel['libelle']] ?? 0) + $nb;
        break;

      case 'perso':
        $cle_nom = $tables[$rel['cible']]['nom'] ?? 'cap_nom';
        $t_cible = $tables[$rel['cible']]['table'] ?? 'dd_capacites_speciales';
        $id_cible = $tables[$rel['cible']]['id'] ?? 'cap_id';
        $stmt = $db->prepare(
          "SELECT x.pe_id, pe.pe_nom, x.cible_id, c.$cle_nom AS cible_nom
             FROM (SELECT DISTINCT {$rel['pe']} AS pe_id, {$rel['col']} AS cible_id
                     FROM {$rel['table']} WHERE {$rel['col']} IN ($in)) x
             LEFT JOIN dd_personnages pe ON pe.pe_id = x.pe_id
             LEFT JOIN $t_cible c ON c.$id_cible = x.cible_id");
        $stmt->execute($cible);
        foreach ($stmt->fetchAll() as $r):
          $pe = (int)$r['pe_id'];
          $persos[$pe]['nom'] = $r['pe_nom'] ?? ('Personnage #' . $pe);
          $persos[$pe]['elements'][] = $rel['libelle'] . ' : ' . ($r['cible_nom'] ?? ('#' . $r['cible_id']));
        endforeach;
        break;

      case 'campagne':
        $stmt = $db->prepare("SELECT DISTINCT {$rel['detail']} AS detail FROM {$rel['table']} WHERE {$rel['col']} IN ($in)");
        $stmt->execute($cible);
        foreach ($stmt->fetchAll(PDO::FETCH_COLUMN) as $d):
          $campagne[] = ['libelle' => $rel['libelle'], 'detail' => $d ?? '—'];
        endforeach;
        break;

      case 'enfant':
        $stmt = $db->prepare(
          "SELECT e.{$rel['nom']} AS nom, r.res_abreviation AS res
             FROM {$rel['table']} e
             LEFT JOIN dd_ressources r ON r.res_id = e.{$rel['res']}
            WHERE e.{$rel['col']} IN ($in) AND NOT (e.{$rel['res']} <=> ?)");
        $stmt->execute(array_merge($cible, [$res_id]));
        foreach ($stmt->fetchAll() as $r):
          $dependants[] = ['libelle' => $rel['libelle'], 'nom' => $r['nom'], 'ressource' => $r['res'] ?? 'sans ressource'];
        endforeach;
        break;
    endswitch;
  endforeach;

  foreach ($persos as &$p):
    $p['elements'] = array_values(array_unique($p['elements']));
  endforeach;
  unset($p);

  // Sources des joueurs et des campagnes
  $nb_js = (int)_rsColonne($db, 'SELECT COUNT(*) FROM dd_joueurs_sources WHERE js_res_id = ?', [$res_id])[0];
  $nb_cs = (int)_rsColonne($db, 'SELECT COUNT(*) FROM dd_campagnes_sources WHERE cs_res_id = ?', [$res_id])[0];
  if ($nb_js) $liaisons['Sélections de sources des joueurs'] = $nb_js;
  if ($nb_cs) $liaisons['Sources des campagnes'] = $nb_cs;

  return [
    'trouvee'        => true,
    'ressource'      => $res,
    'ids'            => $ids,
    'contenu'        => $contenu,
    'liaisons'       => $liaisons,
    'liens_coupes'   => $liens,
    'personnages'    => $persos,
    'campagne'       => $campagne,
    'dependants'     => $dependants,
    'avertissements' => ressourceRenvoisTextuels($db, $res_id, $ids),
    'bloquee'        => (bool)($persos || $campagne || $dependants),
  ];
}

// Renvois textuels vers du contenu supprimé, hors de la ressource : ce ne sont pas des
// orphelins en base, mais des tags qui ne se résoudront plus. Non bloquant.
function ressourceRenvoisTextuels(PDO $db, int $res_id, array $ids): array {
  $avert = [];

  // [[tab:slug]] des tableaux de la ressource, dans les textes des autres ressources
  if ($ids['nb_tableaux']):
    $stmt = $db->prepare('SELECT tab_slug FROM dd_tableaux WHERE tab_id IN (' . _rsIn($ids['nb_tableaux']) . ')');
    $stmt->execute($ids['nb_tableaux']);
    $slugs = $stmt->fetchAll(PDO::FETCH_COLUMN);

    $res_col = ['dd_regles' => 'reg_res_id', 'dd_monstres' => 'mo_res_id', 'dd_sorts' => 'so_res_id',
                'dd_classes' => 'cla_res_id', 'dd_races' => 'ra_res_id', 'dd_dons' => 'do_res_id',
                'dd_competences' => 'comp_res_id', 'dd_objets_magiques' => 'om_res_id',
                'dd_historiques' => 'hi_res_id', 'dd_equipements' => 'eqt_res_id'];
    $corpus = [];
    foreach (tableauChampsHotesRs() as $h):
      $sql    = "SELECT {$h['champ']} FROM {$h['table']} WHERE {$h['champ']} LIKE ?";
      $params = ['%[[tab:%'];
      if (isset($res_col[$h['table']])):
        $sql     .= " AND NOT ({$res_col[$h['table']]} <=> ?)";
        $params[] = $res_id;
      elseif ($h['table'] === 'dd_capacites_speciales' && $ids[RS_CAPACITE]):
        $sql     .= ' AND cap_id NOT IN (' . _rsIn($ids[RS_CAPACITE]) . ')';
        $params   = array_merge($params, $ids[RS_CAPACITE]);
      endif;
      $stmt = $db->prepare($sql);
      $stmt->execute($params);
      $corpus[] = implode("\n", $stmt->fetchAll(PDO::FETCH_COLUMN));
    endforeach;
    $corpus = implode("\n", $corpus);

    $nb = 0;
    foreach ($slugs as $slug):
      $nb += substr_count($corpus, '[[tab:' . $slug . ']]');
    endforeach;
    if ($nb > 0) $avert[] = $nb . ' insertion(s) [[tab:…]] d\'un tableau supprimé dans des textes d\'autres ressources';
  endif;

  // @id@ / %id% (monstre-parser) vers une règle supprimée, dans les blocs de stats d'autres ressources
  if ($ids['nb_regles']):
    $regles = array_flip($ids['nb_regles']);
    $stmt = $db->prepare("SELECT mo_stats FROM dd_monstres WHERE mo_res_id <> ? AND (mo_stats LIKE '%@%' OR mo_stats LIKE '%\\%%')");
    $stmt->execute([$res_id]);
    $nb = 0;
    foreach ($stmt->fetchAll(PDO::FETCH_COLUMN) as $txt):
      if (preg_match_all('/[@%](\d+)[@%]/', (string)$txt, $m)):
        foreach ($m[1] as $id):
          if (isset($regles[(int)$id])) $nb++;
        endforeach;
      endif;
    endforeach;
    if ($nb > 0) $avert[] = $nb . ' renvoi(s) @id@ / %id% vers une règle supprimée dans des blocs de stats de monstres';
  endif;

  return $avert;
}

// Champs hôtes des tags [[tab:…]] : ceux de tableau-parser.php s'il est chargé, sinon
// la même liste (le moteur ne dépend pas de l'ordre des inclusions).
function tableauChampsHotesRs(): array {
  if (!function_exists('tableauChampsHotes')):
    require_once __DIR__ . '/tableau-parser.php';
  endif;
  return tableauChampsHotes();
}

// ============================================================
// Vérification « zéro orphelin »
// ============================================================
// $ids : [cle => ids SUPPRIMÉS]. Renvoie [libellé => nb] des références restantes.
// Appelée dans la transaction, avant le COMMIT : tout résultat non vide annule tout.
function ressourceOrphelins(PDO $db, array $ids, int $res_id): array {
  $restes = [];
  foreach (ressourceRelations() as $rel):
    $cible = $ids[$rel['cible']] ?? [];
    if (!$cible) continue;
    $nb = (int)_rsColonne($db,
      "SELECT COUNT(*) FROM {$rel['table']} WHERE {$rel['col']} IN (" . _rsIn($cible) . ')', $cible)[0];
    if ($nb > 0) $restes[$rel['table'] . '.' . $rel['col']] = $nb;
  endforeach;

  // Entités elles-mêmes, contenu encore rattaché à la ressource, sources
  $tables = contenuRessourceTables();
  foreach ($tables as $cle => $t):
    $nb = (int)_rsColonne($db, "SELECT COUNT(*) FROM {$t['table']} WHERE {$t['champ']} = ?", [$res_id])[0];
    if ($nb > 0) $restes[$t['table'] . '.' . $t['champ']] = $nb;
  endforeach;
  if ($ids[RS_CAPACITE] ?? []):
    $nb = (int)_rsColonne($db, 'SELECT COUNT(*) FROM dd_capacites_speciales WHERE cap_id IN (' . _rsIn($ids[RS_CAPACITE]) . ')', $ids[RS_CAPACITE])[0];
    if ($nb > 0) $restes['dd_capacites_speciales.cap_id'] = $nb;
  endif;
  foreach (['dd_joueurs_sources' => 'js_res_id', 'dd_campagnes_sources' => 'cs_res_id', 'dd_ressources' => 'res_id'] as $table => $col):
    $nb = (int)_rsColonne($db, "SELECT COUNT(*) FROM $table WHERE $col = ?", [$res_id])[0];
    if ($nb > 0) $restes[$table . '.' . $col] = $nb;
  endforeach;
  return $restes;
}

// ============================================================
// Cascade
// ============================================================
// Retour : ['ok' => bool, 'erreur' => string, 'volumes' => [libellé => nb]]
function ressourceSupprimerCascade(PDO $db, int $res_id): array {
  $an = ressourceSuppressionAnalyse($db, $res_id);
  if (!$an['trouvee']) return ['ok' => false, 'erreur' => 'Ressource introuvable.', 'volumes' => []];
  if ($an['bloquee']):
    return ['ok' => false, 'volumes' => [],
            'erreur' => 'Suppression refusée : des personnages, des notes de campagne ou le contenu d\'une autre ressource dépendent de cette ressource.'];
  endif;

  $ids     = $an['ids'];
  $tables  = contenuRessourceTables();
  $volumes = [];
  $exec = function (string $sql, array $params, string $libelle) use ($db, &$volumes) {
    $stmt = $db->prepare($sql);
    $stmt->execute($params);
    if ($stmt->rowCount() > 0) $volumes[$libelle] = ($volumes[$libelle] ?? 0) + $stmt->rowCount();
  };

  try {
    $db->beginTransaction();

    // 1. Liens faibles coupés
    foreach (ressourceRelations() as $rel):
      if ($rel['mode'] !== 'null' || !($ids[$rel['cible']] ?? [])) continue;
      $cible = $ids[$rel['cible']];
      $set   = implode(', ', array_map(fn($c) => "$c = NULL", $rel['set']));
      $exec("UPDATE {$rel['table']} SET $set WHERE {$rel['col']} IN (" . _rsIn($cible) . ')', $cible,
            'Liens coupés — ' . $rel['libelle']);
    endforeach;

    // 2. Lignes de liaison (relations en cascade), capacités comprises
    foreach (ressourceRelations() as $rel):
      if ($rel['mode'] !== 'cascade' || !($ids[$rel['cible']] ?? [])) continue;
      $cible = $ids[$rel['cible']];
      $exec("DELETE FROM {$rel['table']} WHERE {$rel['col']} IN (" . _rsIn($cible) . ')', $cible, $rel['libelle']);
    endforeach;

    // 3. Entités de la ressource (hors règles, supprimées des feuilles vers la racine)
    foreach ($tables as $cle => $t):
      if ($cle === 'nb_regles' || !$ids[$cle]) continue;
      $exec("DELETE FROM {$t['table']} WHERE {$t['champ']} = ?", [$res_id], $t['label']);
    endforeach;
    foreach (ressourceReglesFeuillesDabord($db, $res_id) as $reg_id):
      $exec('DELETE FROM dd_regles WHERE reg_id = ?', [$reg_id], $tables['nb_regles']['label']);
    endforeach;

    // 4. Capacités devenues sans lien (revérifié en SQL au moment de supprimer)
    if ($ids[RS_CAPACITE]):
      $in = _rsIn($ids[RS_CAPACITE]);
      $exec("DELETE FROM dd_capacites_speciales WHERE cap_id IN ($in)
               AND NOT EXISTS (SELECT 1 FROM dd_classe_capacite   WHERE cc_cap_id   = cap_id)
               AND NOT EXISTS (SELECT 1 FROM dd_race_capacite     WHERE cr_cap_id   = cap_id)
               AND NOT EXISTS (SELECT 1 FROM dd_personnages_choix WHERE pech_cap_id = cap_id)",
            $ids[RS_CAPACITE], 'Capacités spéciales');
    endif;

    // 5. Sources des joueurs et des campagnes, puis la ressource
    $exec('DELETE FROM dd_joueurs_sources   WHERE js_res_id = ?', [$res_id], 'Sélections de sources des joueurs');
    $exec('DELETE FROM dd_campagnes_sources WHERE cs_res_id = ?', [$res_id], 'Sources des campagnes');
    $exec('DELETE FROM dd_ressources        WHERE res_id    = ?', [$res_id], 'Ressource');

    // 6. Garantie : aucune référence ne doit rester vers ce qui vient d'être supprimé
    $restes = ressourceOrphelins($db, $ids, $res_id);
    if ($restes):
      throw new RuntimeException('Références restantes : ' . json_encode($restes));
    endif;

    $db->commit();
  } catch (Throwable $e) {
    if ($db->inTransaction()) $db->rollBack();
    error_log('ressourceSupprimerCascade(' . $res_id . ') : ' . $e->getMessage());
    return ['ok' => false, 'volumes' => [],
            'erreur' => 'La suppression a échoué et a été entièrement annulée (détail dans le journal du serveur).'];
  }

  error_log('ressourceSupprimerCascade(' . $res_id . ') — ' . json_encode($volumes, JSON_UNESCAPED_UNICODE));
  return ['ok' => true, 'erreur' => '', 'volumes' => $volumes];
}

// ============================================================
// Rapport global des orphelins (admin/orphelins.php) — lecture seule
// ============================================================
// Pour chaque relation : lignes qui référencent un id inexistant. Les colonnes
// nullables à NULL (ou à 0 pour pe_arc_id, « pas d'archétype ») ne sont pas des orphelins.
function ressourceRapportOrphelins(PDO $db): array {
  $cibles = contenuRessourceTables();
  $cibles[RS_CAPACITE] = ['table' => 'dd_capacites_speciales', 'id' => 'cap_id'];

  $lignes = [];
  $vus    = [];
  foreach (ressourceRelations() as $rel):
    $cle = $rel['table'] . '.' . $rel['col'];
    if (isset($vus[$cle])) continue;
    $vus[$cle] = true;
    $c = $cibles[$rel['cible']];
    $nb = (int)$db->query(
      "SELECT COUNT(*) FROM {$rel['table']} x
        WHERE x.{$rel['col']} IS NOT NULL AND x.{$rel['col']} <> 0
          AND NOT EXISTS (SELECT 1 FROM {$c['table']} c WHERE c.{$c['id']} = x.{$rel['col']})"
    )->fetchColumn();
    $lignes[] = ['relation' => $cle, 'cible' => $c['table'], 'libelle' => $rel['libelle'], 'nb' => $nb];
  endforeach;

  // Contenu dont la ressource n'existe plus
  foreach (contenuRessourceTables() as $t):
    $nb = (int)$db->query(
      "SELECT COUNT(*) FROM {$t['table']} x
        WHERE x.{$t['champ']} IS NOT NULL
          AND NOT EXISTS (SELECT 1 FROM dd_ressources r WHERE r.res_id = x.{$t['champ']})"
    )->fetchColumn();
    $lignes[] = ['relation' => $t['table'] . '.' . $t['champ'], 'cible' => 'dd_ressources',
                 'libelle' => $t['label'] . ' sans ressource existante', 'nb' => $nb];
  endforeach;

  // Capacités spéciales rattachées à rien
  $nb = (int)$db->query(
    'SELECT COUNT(*) FROM dd_capacites_speciales c
      WHERE NOT EXISTS (SELECT 1 FROM dd_classe_capacite   WHERE cc_cap_id   = c.cap_id)
        AND NOT EXISTS (SELECT 1 FROM dd_race_capacite     WHERE cr_cap_id   = c.cap_id)
        AND NOT EXISTS (SELECT 1 FROM dd_personnages_choix WHERE pech_cap_id = c.cap_id)'
  )->fetchColumn();
  $lignes[] = ['relation' => 'dd_capacites_speciales', 'cible' => 'classe / race',
               'libelle' => 'Capacités spéciales rattachées à aucune classe ni race', 'nb' => $nb];

  return $lignes;
}
