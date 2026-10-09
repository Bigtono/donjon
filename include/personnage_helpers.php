<?php
// include/personnage_helpers.php
// Helpers PHP spécifiques au module Personnages.
// Chargé à la demande par les pages du module (fiche.php, modifier.php,
// enregistrement.php, magie.php) — PAS automatiquement par header.php.
//
// SP-PE0 : socle — chargement contexte + listes auxiliaires pour
// les selects de modification.
// SP-PE5 : rattachement aux campagnes — getCampagnesPersonnage() étendue,
//          getCampagnesRattachables().
// SP-PE6 : contexte NLS prestige DD3.5 — getPersonnageNls(),
//          libelleProgressionNls().
// Le calcul du NLS effectif et des emplacements de sorts par jour sera
// ajouté en SP-PE7 (vue Magie).
//
// PRÉREQUIS : ce fichier suppose que include/db.php, include/auth.php et
// include/helpers.php sont déjà chargés (variable globale $db disponible).

if (!function_exists('h')):
  die('personnage_helpers.php : include/helpers.php doit être chargé en premier.');
endif;

// ============================================================
// CHARGEMENT DU CONTEXTE PERSONNAGE
// ============================================================

/**
 * Charge un personnage et vérifie le droit d'accès du joueur courant.
 *
 * @param  PDO  $db
 * @param  int  $pe_id
 * @return array|null  Ligne dd_personnages (étendue de la race / ruleset / alignement / campagne),
 *                     ou null si introuvable ou interdit.
 */
function getPersonnageContext(PDO $db, int $pe_id): ?array {
  if ($pe_id <= 0) return null;

  $stmt = $db->prepare('
    SELECT pe.*,
           ra_base.ra_nom    AS race_nom,
           ra_arc.ra_nom     AS archetype_nom,
           hi.hi_nom         AS historique_nom,
           al.al_nom         AS alignement_nom,
           al.al_abreviation AS alignement_abr,
           camp.camp_nom     AS campagne_courante_nom,
           var.var_valeur    AS ruleset_label
      FROM dd_personnages pe
      LEFT JOIN dd_races       ra_base ON ra_base.ra_id = pe.pe_ra_id
      LEFT JOIN dd_races       ra_arc  ON ra_arc.ra_id  = pe.pe_arc_id AND pe.pe_arc_id > 0
      LEFT JOIN dd_historiques hi      ON hi.hi_id      = pe.pe_hi_id
      LEFT JOIN dd_alignements al      ON al.al_id      = pe.pe_al_id
      LEFT JOIN dd_campagnes   camp    ON camp.camp_id  = pe.pe_camp_id
      LEFT JOIN dd_variables   var     ON var.var_id    = pe.pe_ruleset_var_id
     WHERE pe.pe_id = ?
     LIMIT 1
  ');
  $stmt->execute([$pe_id]);
  $perso = $stmt->fetch();

  if (!$perso) return null;

  // Contrôle de propriété (le module Personnages est strictement personnel)
  if (!canAccess((int)$perso['pe_j_id'])) return null;

  return $perso;
}

/**
 * Liste des classes (+ niveaux + domaines DD3.5) d'un personnage,
 * ordonnée par nom de classe.
 *
 * @param  PDO  $db
 * @param  int  $pe_id
 * @return array
 */
function getPersonnageClasses(PDO $db, int $pe_id): array {
  $stmt = $db->prepare('
    SELECT pc.pc_id,
           pc.pc_cla_id,
           pc.pc_niveau,
           pc.pc_do_id_1,
           pc.pc_do_id_2,
           cla.cla_nom,
           cla.cla_clt_id,
           cla.cla_cla_id,
           cla.cla_mag_id,
           cla.cla_niveauMax,
           cla.cla_domaine_divin,
           do1.do_nom AS domaine1_nom,
           do2.do_nom AS domaine2_nom
      FROM dd_personnages_classes pc
      JOIN dd_classes cla ON cla.cla_id = pc.pc_cla_id
      LEFT JOIN dd_domaines do1 ON do1.do_id = pc.pc_do_id_1
      LEFT JOIN dd_domaines do2 ON do2.do_id = pc.pc_do_id_2
     WHERE pc.pc_pe_id = ?
     ORDER BY cla.cla_clt_id ASC, cla.cla_nom ASC
  ');
  $stmt->execute([$pe_id]);
  return $stmt->fetchAll();
}

/**
 * Campagne en cours + historique des campagnes traversées par le personnage.
 * La campagne en cours (`pe_camp_id`) est marquée par `est_courante = 1`.
 *
 * La table de liaison `dd_campagnes_personnages` est la **source de vérité** du
 * rattachement (cf. METIER_10) ; `pe_camp_id` n'est qu'un raccourci de contexte.
 * La requête part donc de `dd_campagnes` avec un LEFT JOIN sur la liaison, et
 * retient une campagne si **l'une des deux** conditions est vraie : ligne de
 * liaison présente, ou campagne désignée comme courante. Une campagne courante
 * dont la liaison manquerait (donnée héritée d'avant SP-PE5) reste ainsi visible
 * au lieu de disparaître silencieusement de la fiche.
 *
 * `cp_actif = 0` signifie « participation terminée » — la campagne reste dans
 * l'historique mais ses sources ne s'appliquent plus (cf. getActiveResIds()).
 *
 * @param  PDO  $db
 * @param  int  $pe_id
 * @param  int  $pe_camp_id  Campagne en cours (0/NULL = aucune)
 * @return array  [{camp_id, camp_nom, camp_resume, univers_nom, cp_actif,
 *                  est_liee, est_courante}, …]
 */
function getCampagnesPersonnage(PDO $db, int $pe_id, int $pe_camp_id): array {
  $stmt = $db->prepare('
    SELECT camp.camp_id,
           camp.camp_nom,
           camp.camp_resume,
           un.un_nom AS univers_nom,
           COALESCE(cp.cp_actif, 1) AS cp_actif,
           (cp.cp_id IS NOT NULL)   AS est_liee,
           (camp.camp_id = ?)       AS est_courante
      FROM dd_campagnes camp
      LEFT JOIN dd_campagnes_personnages cp
             ON cp.cp_camp_id = camp.camp_id
            AND cp.cp_pe_id   = ?
      LEFT JOIN dd_univers un ON un.un_id = camp.camp_un_id
     WHERE camp.camp_supprime = 0
       AND (cp.cp_id IS NOT NULL OR camp.camp_id = ?)
     ORDER BY est_courante DESC, camp.camp_nom
  ');
  $stmt->execute([$pe_camp_id, $pe_id, $pe_camp_id]);
  return $stmt->fetchAll();
}

/**
 * Campagnes proposées au rattachement d'un personnage (SP-PE5).
 *
 * Périmètre volontairement restreint aux campagnes **du propriétaire du
 * personnage** : l'application n'a aucun mécanisme d'invitation, un joueur ne
 * peut donc rattacher son personnage qu'à ses propres campagnes. Le filtre
 * porte sur `pe_j_id` et non sur l'utilisateur en session, pour que la liste
 * reste la même quand un admin consulte la fiche d'un autre joueur.
 *
 * Le ruleset filtré est celui du **personnage** (figé à sa création), jamais
 * celui de la session — même règle que le reste du module (archi §7.7).
 *
 * @param  PDO  $db
 * @param  int  $j_id        Propriétaire du personnage (pe_j_id)
 * @param  int  $ruleset_id  Ruleset du personnage (pe_ruleset_var_id)
 * @return array  [{camp_id, camp_nom, camp_resume, univers_nom}, …]
 */
function getCampagnesRattachables(PDO $db, int $j_id, int $ruleset_id): array {
  $stmt = $db->prepare('
    SELECT camp.camp_id,
           camp.camp_nom,
           camp.camp_resume,
           un.un_nom AS univers_nom
      FROM dd_campagnes camp
      LEFT JOIN dd_univers un ON un.un_id = camp.camp_un_id
     WHERE camp.camp_j_id           = ?
       AND camp.camp_ruleset_var_id = ?
       AND camp.camp_supprime       = 0
     ORDER BY camp.camp_nom
  ');
  $stmt->execute([$j_id, $ruleset_id]);
  return $stmt->fetchAll();
}

/**
 * Compétences du ruleset, avec le niveau de maîtrise du personnage (SP-PE3).
 *
 * Renvoie **toutes** les compétences du ruleset bornées par les sources actives
 * (chaîne campagne → perso → défaut), y compris celles à maîtrise 0 : la même
 * liste sert au mode lecture (filtré sur pec_maitrise > 0 par l'appelant) et à
 * l'éditeur inline, qui affiche le tableau complet.
 *
 * Une compétence déjà saisie dont la source n'est plus active reste dans la
 * liste (`OR pec.pec_id IS NOT NULL`) : désactiver un ouvrage ne doit jamais
 * faire disparaître silencieusement une donnée du joueur.
 *
 * Le JOIN sur `dd_caracteristiques` est un **LEFT JOIN** : certaines
 * compétences n'ont pas de caractéristique associée (`comp_car_id = 0`, ex.
 * « Langue » en DD3.5). `car_nom`/`car_diminutif` sont alors NULL et l'appelant
 * affiche « — » ; un INNER JOIN les ferait disparaître de la fiche.
 *
 * @param  PDO    $db
 * @param  int    $pe_id
 * @param  int    $ruleset_id
 * @param  array  $res_ids     Sources actives ; si vide, aucun filtre de source
 * @return array  [{comp_id, comp_nom, comp_car_id, comp_formation,
 *                  comp_malusArmure, car_nom, car_diminutif, pec_maitrise}, …]
 */
function getPersonnageCompetences(PDO $db, int $pe_id, int $ruleset_id, array $res_ids): array {
  $filtre_res = !empty($res_ids);
  $ph         = $filtre_res ? resIdsPlaceholders($res_ids) : '';

  $sql = '
    SELECT comp.comp_id,
           comp.comp_nom,
           comp.comp_car_id,
           comp.comp_formation,
           comp.comp_malusArmure,
           car.car_nom,
           car.car_diminutif,
           COALESCE(pec.pec_maitrise, 0) AS pec_maitrise
      FROM dd_competences comp
      LEFT JOIN dd_caracteristiques car ON car.car_id = comp.comp_car_id
      LEFT JOIN dd_personnages_competences pec
             ON pec.pec_comp_id = comp.comp_id
            AND pec.pec_pe_id   = ?
     WHERE comp.comp_ruleset_var_id = ?'
    . ($filtre_res ? " AND (comp.comp_res_id IN ($ph) OR pec.pec_id IS NOT NULL)" : '') . '
     ORDER BY comp.comp_nom';

  $params = $filtre_res
    ? array_merge([$pe_id, $ruleset_id], $res_ids)
    : [$pe_id, $ruleset_id];

  $stmt = $db->prepare($sql);
  $stmt->execute($params);
  return $stmt->fetchAll();
}

/**
 * Contexte NLS prestige du personnage (SP-PE6 — DD3.5 uniquement).
 *
 * Construit tout ce que le bloc NLS de la fiche consomme : les classes de base
 * lanceuses de sorts (réceptrices), les classes de prestige qui influent sur le
 * NLS et, niveau par niveau, les drapeaux de progression (`cn_niveauSortArcane`
 * / `Divin` / `Effectif` de `dd_classe_niveau`) et l'affectation déjà saisie
 * dans `dd_personnages_nls`.
 *
 * Renvoie null si le bloc n'a pas lieu d'être affiché (archi §7.5d) : aucune
 * classe de base lanceuse, ou aucune classe de prestige dont au moins un niveau
 * détenu fait progresser le NLS. Un niveau absent de `dd_classe_niveau` est
 * traité comme sans progression — la saisie du compendium peut être incomplète,
 * le bloc ne doit pas inventer une affectation à faire.
 *
 * @param  PDO    $db
 * @param  array  $classes  Sortie de getPersonnageClasses() (pc_id, pc_niveau,
 *                          cla_clt_id, cla_mag_id, cla_nom déjà chargés)
 * @param  int    $pe_id
 * @return array|null  ['bases' => [{pc_id, nom, mag_id}, …],
 *                      'prestiges' => [{pc_id, nom, niveau,
 *                        'niveaux' => [n => {arcane, divin, effectif, base_pc_id}]}, …]]
 */
function getPersonnageNls(PDO $db, array $classes, int $pe_id): ?array {
  // Classes de base lanceuses (réceptrices) et classes de prestige détenues.
  // Littéraux DD3.5 : clt_id 1 = base, 2 = prestige (cf. SCHEMA_SQL dd_classe_type).
  $bases     = [];
  $prestiges = [];
  foreach ($classes as $c):
    if ((int)$c['cla_clt_id'] === 1 && (int)$c['cla_mag_id'] > 0):
      $bases[] = [
        'pc_id'  => (int)$c['pc_id'],
        'nom'    => $c['cla_nom'],
        'mag_id' => (int)$c['cla_mag_id'],
      ];
    elseif ((int)$c['cla_clt_id'] === 2):
      $prestiges[(int)$c['pc_cla_id']] = [
        'pc_id'   => (int)$c['pc_id'],
        'nom'     => $c['cla_nom'],
        'niveau'  => (int)$c['pc_niveau'],
        'niveaux' => [],
      ];
    endif;
  endforeach;

  if (empty($bases) || empty($prestiges)) return null;

  // Drapeaux de progression des niveaux détenus, en une seule requête
  $ph   = implode(',', array_fill(0, count($prestiges), '?'));
  $stmt = $db->prepare("
    SELECT cn_cla_id, cn_niveau,
           cn_niveauSortArcane, cn_niveauSortDivin, cn_niveauSortEffectif
      FROM dd_classe_niveau
     WHERE cn_cla_id IN ($ph)
  ");
  $stmt->execute(array_keys($prestiges));
  $flags = [];
  foreach ($stmt->fetchAll() as $row):
    $flags[(int)$row['cn_cla_id']][(int)$row['cn_niveau']] = $row;
  endforeach;

  // Affectations existantes, indexées par (pc de prestige, niveau)
  $stmt = $db->prepare('
    SELECT penl.penl_pc_id_prestige, penl.penl_niveau, penl.penl_pc_id_base
      FROM dd_personnages_nls penl
      JOIN dd_personnages_classes pc ON pc.pc_id = penl.penl_pc_id_prestige
     WHERE pc.pc_pe_id = ?
  ');
  $stmt->execute([$pe_id]);
  $affectations = [];
  foreach ($stmt->fetchAll() as $row):
    $affectations[(int)$row['penl_pc_id_prestige']][(int)$row['penl_niveau']]
      = (int)$row['penl_pc_id_base'];
  endforeach;

  // Assemblage : une entrée par niveau détenu, drapeaux + affectation.
  // Seules les classes de prestige dont au moins un niveau détenu fait
  // progresser le NLS sont retenues (condition d'affichage du bloc).
  $retenues = [];
  foreach ($prestiges as $cla_id => $p):
    $influe = false;
    for ($n = 1; $n <= $p['niveau']; $n++):
      $f = $flags[$cla_id][$n] ?? null;
      $niveau = [
        'arcane'     => $f ? (int)$f['cn_niveauSortArcane']   : 0,
        'divin'      => $f ? (int)$f['cn_niveauSortDivin']    : 0,
        'effectif'   => $f ? (int)$f['cn_niveauSortEffectif'] : 0,
        'base_pc_id' => (int)($affectations[$p['pc_id']][$n] ?? 0),
      ];
      if ($niveau['arcane'] || $niveau['divin'] || $niveau['effectif']):
        $influe = true;
      endif;
      $p['niveaux'][$n] = $niveau;
    endfor;
    if ($influe):
      $retenues[] = $p;
    endif;
  endforeach;

  if (empty($retenues)) return null;

  return ['bases' => $bases, 'prestiges' => $retenues];
}

/**
 * Libellé de progression NLS d'un niveau de prestige, depuis ses drapeaux
 * (aide d'affichage du bloc NLS — SP-PE6). Ex. « Arcane », « Effectif »,
 * « Arcane + Divin ». Chaîne vide si le niveau ne fait pas progresser le NLS.
 *
 * @param  array  $niveau  {arcane, divin, effectif}
 * @return string
 */
function libelleProgressionNls(array $niveau): string {
  $parts = [];
  if (!empty($niveau['effectif'])) $parts[] = 'Effectif';
  if (!empty($niveau['arcane']))   $parts[] = 'Arcane';
  if (!empty($niveau['divin']))    $parts[] = 'Divin';
  return implode(' + ', $parts);
}

// ============================================================
// CONTEXTE MAGIE (SP-PE7a)
// ============================================================
//
// Point d'entrée unique de la vue Magie : getMagieContexte() rend une entrée par
// classe lanceuse du personnage, avec tout ce que la page doit afficher — profil,
// caractéristique, NLS effectif, emplacements, plafonds, sorts toujours préparés.
//
// Le regroupement de premier rang est LA CLASSE, jamais le niveau de sort : un
// multiclassé a autant d'entrées que de classes lanceuses, et un monoclasse une
// seule (objectif produit, METIER_7_SORTS.md §10.1).
//
// Quatre pièges portés ici plutôt que dans la page (cf. §0, ligne SP-PE7) :
//   1. L'Occultiste lit ses emplacements dans cn_pouvoir1..3, pas cn_sort_n1..9.
//   2. Les sorts toujours préparés sont cumulatifs (cs_niveau <= niveau).
//   3. bonusSortsCarac() et peutLancerNiveau() sont DD3.5 uniquement.
//   4. La cadence conditionne l'action « Réinitialiser la liste préparée ».

/**
 * Progression d'emplacements du LANCEUR COMPLET d'un ruleset.
 *
 * Sert au multiclassage DD2024 : les emplacements d'un Paladin 4 / Clerc 4 ne se
 * lisent dans la table d'AUCUNE de ses deux classes, mais dans celle du lanceur
 * complet au niveau d'incantateur agrégé (6 ici → 4/3/3). La table « Incantateur
 * multiclassé » du SRD est identique à celle d'un lanceur complet — vérifié ligne
 * à ligne en SP-MA2.
 *
 * La classe de référence est DÉDUITE et non codée en dur : un lanceur complet est
 * celui qui atteint les emplacements de 9e niveau à son niveau 20.
 *
 * @return array [niveau_de_classe => [niveau_de_sort => nb]]
 */
function progressionLanceurComplet(PDO $db, int $ruleset_var_id): array {
  static $cache = [];
  if (isset($cache[$ruleset_var_id])) return $cache[$ruleset_var_id];

  $stmt = $db->prepare('
    SELECT cn.cn_cla_id
      FROM dd_classe_niveau cn
      JOIN dd_classes cla ON cla.cla_id = cn.cn_cla_id
     WHERE cla.cla_ruleset_var_id = ? AND cn.cn_niveau = 20 AND cn.cn_sort_n9 > 0
     ORDER BY cn.cn_cla_id LIMIT 1
  ');
  $stmt->execute([$ruleset_var_id]);
  $ref = $stmt->fetchColumn();
  if (!$ref) return $cache[$ruleset_var_id] = [];

  $stmt2 = $db->prepare('SELECT * FROM dd_classe_niveau WHERE cn_cla_id = ? ORDER BY cn_niveau');
  $stmt2->execute([(int)$ref]);
  $out = [];
  foreach ($stmt2->fetchAll() as $r):
    $l = [];
    for ($n = 1; $n <= 9; $n++) $l[$n] = (int)($r['cn_sort_n' . $n] ?? 0);
    $out[(int)$r['cn_niveau']] = $l;
  endforeach;
  return $cache[$ruleset_var_id] = $out;
}

/**
 * Ligne de dd_classe_niveau d'une classe à un niveau donné (null si absente).
 */
function ligneNiveauClasse(PDO $db, int $cla_id, int $niveau): ?array {
  static $cache = [];
  $k = $cla_id . ':' . $niveau;
  if (array_key_exists($k, $cache)) return $cache[$k];
  $stmt = $db->prepare('SELECT * FROM dd_classe_niveau WHERE cn_cla_id = ? AND cn_niveau = ?');
  $stmt->execute([$cla_id, $niveau]);
  $r = $stmt->fetch();
  return $cache[$k] = ($r ?: null);
}

/**
 * Sorts toujours préparés d'une classe (ou sous-classe) jusqu'à un niveau.
 *
 * CUMULATIF : le SRD dit « pour votre niveau et les niveaux inférieurs ». On
 * filtre donc sur cs_niveau <= $niveau, jamais sur l'égalité.
 *
 * @return array lignes [so_id, so_nom, so_niveau, cs_niveau, cs_variante, cs_usages, cs_recharge]
 */
function sortsToujoursPrepares(PDO $db, array $cla_ids, int $niveau): array {
  $cla_ids = array_values(array_filter(array_map('intval', $cla_ids)));
  if (!$cla_ids) return [];
  $ph = implode(',', array_fill(0, count($cla_ids), '?'));
  $stmt = $db->prepare("
    SELECT cs.cs_cla_id, cs.cs_niveau, cs.cs_variante, cs.cs_usages, cs.cs_recharge,
           so.so_id, so.so_nom, so.so_niveau, cla.cla_nom AS porteur
      FROM dd_classe_sort cs
      JOIN dd_sorts   so  ON so.so_id  = cs.cs_so_id
      JOIN dd_classes cla ON cla.cla_id = cs.cs_cla_id
     WHERE cs.cs_cla_id IN ($ph) AND cs.cs_niveau <= ?
     ORDER BY cs.cs_variante, cs.cs_niveau, so.so_nom
  ");
  $stmt->execute(array_merge($cla_ids, [$niveau]));
  return $stmt->fetchAll();
}
/**
 * NLS effectif d'une classe de base DD3.5 : son niveau, plus les niveaux de
 * classe de prestige qui lui ont été affectés (bloc NLS de SP-PE6) et dont le
 * drapeau est compatible avec son type de magie.
 *
 *   cn_niveauSortArcane   -> n'avance qu'une base profane (cla_mag_id = 1)
 *   cn_niveauSortDivin    -> n'avance qu'une base divine  (cla_mag_id = 2)
 *   cn_niveauSortEffectif -> avance n'importe quelle base
 *
 * @return array ['nls' => int, 'base' => int, 'prestige' => int]
 */
function nlsEffectif35(array $classe, ?array $nls): array {
  $base  = (int)$classe['pc_niveau'];
  $ajout = 0;
  if ($nls):
    $mag = (int)$classe['cla_mag_id'];
    foreach ($nls['prestiges'] as $p):
      foreach ($p['niveaux'] as $niv):
        if ((int)$niv['base_pc_id'] !== (int)$classe['pc_id']) continue;
        $compatible = $niv['effectif']
          || ($niv['arcane'] && $mag === 1)
          || ($niv['divin']  && $mag === 2);
        if ($compatible) $ajout++;
      endforeach;
    endforeach;
  endif;
  return ['nls' => $base + $ajout, 'base' => $base, 'prestige' => $ajout];
}

/**
 * Niveau d'incantateur agrégé DD2024, pour le multiclassage (SRD, cf.
 * METIER_7_SORTS.md §4.5) :
 *     tous les niveaux des lanceurs complets
 *   + la moitié arrondie au supérieur des niveaux de Paladin et de Rôdeur
 *
 * L'Occultiste en est EXCLU : sa Magie de pacte a ses propres emplacements.
 *
 * Le caractère « complet » ou « demi » est déduit de la donnée — un demi-lanceur
 * plafonne aux emplacements de 5e niveau — et non d'une liste de noms de classe.
 */
function niveauIncantateur2024(PDO $db, array $classes): int {
  $total = 0;
  foreach ($classes as $c):
    if ((int)$c['cla_mag_id'] <= 0) continue;
    if ((int)($c['cla_profil_incantation'] ?? 0) === PROFINC_PACTE) continue;
    $max     = ligneNiveauClasse($db, (int)$c['pc_cla_id'], 20);
    $complet = $max && (int)($max['cn_sort_n9'] ?? 0) > 0;
    $total  += $complet ? (int)$c['pc_niveau'] : (int)ceil((int)$c['pc_niveau'] / 2);
  endforeach;
  return $total;
}

/**
 * Contexte Magie complet d'un personnage : UNE ENTRÉE PAR CLASSE LANCEUSE.
 *
 * @param  array $perso    sortie de getPersonnageContext()
 * @param  array $classes  sortie de getPersonnageClasses()
 * @return array
 */
function getMagieContexte(PDO $db, array $perso, array $classes): array {
  $ruleset_id = (int)$perso['pe_ruleset_var_id'];
  $est35      = ($ruleset_id === 1);

  // Colonnes de classe dont getPersonnageClasses() n'a pas besoin par ailleurs.
  $ids = array_map(fn($c) => (int)$c['pc_cla_id'], $classes);
  $sup = [];
  if ($ids):
    $ph   = implode(',', array_fill(0, count($ids), '?'));
    $stmt = $db->prepare("
      SELECT cla.cla_id, cla.cla_profil_incantation, cla.cla_renouvellement,
             cla.cla_car_id, cla.cla_cla_id, car.car_nom, car.car_diminutif
        FROM dd_classes cla
        LEFT JOIN dd_caracteristiques car ON car.car_id = cla.cla_car_id
       WHERE cla.cla_id IN ($ph)
    ");
    $stmt->execute($ids);
    foreach ($stmt->fetchAll() as $r) $sup[(int)$r['cla_id']] = $r;
  endif;
  foreach ($classes as &$c) $c += ($sup[(int)$c['pc_cla_id']] ?? []);
  unset($c);

  $nls          = $est35 ? getPersonnageNls($db, $classes, (int)$perso['pe_id']) : null;
  $nivIncant    = $est35 ? 0 : niveauIncantateur2024($db, $classes);
  $progComplete = $est35 ? [] : progressionLanceurComplet($db, $ruleset_id);
  // Niveau global du personnage : les SOUS-CLASSES sont exclues — une sous-classe
  // DD2024 est une ligne de dd_personnages_classes mais n'ajoute aucun niveau.
  $niveauGlobal = 0;
  foreach ($classes as $cc):
    if ((int)($cc['cla_clt_id'] ?? 0) === 5) continue;
    $niveauGlobal += (int)$cc['pc_niveau'];
  endforeach;
  $bonusMaitr   = $est35 ? 0 : getBonusMaitrise($db, $ruleset_id, $niveauGlobal);

  $out = [];
  foreach ($classes as $c):
    if ((int)$c['cla_mag_id'] <= 0) continue;

    $profil = (int)($c['cla_profil_incantation'] ?? 0);
    $niveau = (int)$c['pc_niveau'];
    $carVal = !empty($c['car_diminutif'])
      ? (int)($perso['pe_' . strtolower($c['car_diminutif'])] ?? 0) : 0;
    $carMod = $carVal ? modCarac($carVal) : 0;
    $avert  = [];

    // ---- NLS effectif -------------------------------------------------
    if ($est35):
      $nlsDet = nlsEffectif35($c, $nls);
    elseif ($profil === PROFINC_PACTE):
      // La Magie de pacte ne s'agrège pas : elle vit sur son seul niveau de classe.
      $nlsDet = ['nls' => $niveau, 'base' => $niveau, 'prestige' => 0];
    else:
      $nlsDet = ['nls' => $nivIncant, 'base' => $niveau, 'prestige' => $nivIncant - $niveau];
    endif;
    $nlsEff = $nlsDet['nls'];

    // ---- Emplacements -------------------------------------------------
    // $ligne  : la ligne au NIVEAU DE CLASSE — pour les plafonds (sorts mineurs
    //           DD2024, sorts préparés), qui suivent le niveau réel.
    // $ligneS : la ligne au NLS EFFECTIF — pour les EMPLACEMENTS, qui suivent le
    //           niveau de lanceur. Un magicien 15 / archimage 5 lit ses
    //           emplacements à la ligne 20, pas à la ligne 15.
    $ligne  = ligneNiveauClasse($db, (int)$c['pc_cla_id'], min($niveau, 20));
    $ligneS = ligneNiveauClasse($db, (int)$c['pc_cla_id'], min(max($nlsEff, 1), 20));
    $empl   = array_fill(0, 10, 0);
    $detail = [];
    $pacte  = null;

    if ($profil === PROFINC_PACTE):
      // PIÈGE 1 — l'Occultiste porte ses emplacements dans cn_pouvoir1..3
      // (Manifestations / Emplacements / Niveau des emplacements), posés par
      // SP-IM2. cn_sort_n1..9 restent à 0 : les lire donnerait un lanceur
      // dépourvu de magie. Cas particulier explicite, arbitré le 2026-09-01.
      $nb  = (int)($ligne['cn_pouvoir2'] ?? 0);
      $niv = (int)($ligne['cn_pouvoir3'] ?? 0);
      if ($nb && $niv):
        $empl[$niv] = $nb;
        $pacte = ['nb' => $nb, 'niveau' => $niv, 'recharge' => 'court'];
      endif;
      if ($niveau >= 11):
        $avert[] = "Arcanum mystique (niveau 11 et plus) : sorts choisis par le joueur, non suivis par l'application.";
      endif;
    else:
      // Valeurs BRUTES : la distinction NULL / 0 porte du sens (SRD 3.5).
      //   NULL (« — ») : ce niveau de sort est inaccessible — ni emplacement,
      //                  ni sort bonus, ni emplacement de domaine.
      //   0            : accessible, mais uniquement par les sorts en bonus
      //                  (« Quand la table indique 0, le personnage ne peut
      //                   lancer que les sorts en bonus de ce niveau »).
      $brut = [];
      if ($est35):
        for ($n = 0; $n <= 9; $n++):
          $v = $ligneS['cn_sort_n' . $n] ?? null;
          $brut[$n] = ($v === null || $v === '') ? null : (int)$v;
        endfor;
      else:
        // Multiclassage DD2024 : les emplacements se lisent dans la table du
        // LANCEUR COMPLET au niveau d'incantateur agrégé, dans celle d'aucune
        // des classes du personnage. Le niveau 0 n'y est pas un emplacement
        // (les sorts mineurs sont illimités) : il reste hors du tableau.
        $prog = $progComplete[min(max($nlsEff, 1), 20)] ?? [];
        $brut[0] = null;
        for ($n = 1; $n <= 9; $n++) $brut[$n] = (int)($prog[$n] ?? 0) ?: null;
      endif;

      for ($n = 0; $n <= 9; $n++):
        if ($brut[$n] === null):
          $detail[$n] = ['table' => null, 'bonus' => 0, 'domaine' => 0, 'accessible' => false];
          continue;
        endif;
        $table = $brut[$n];
        // PIÈGE 3 — sorts bonus de caractéristique : DD3.5 UNIQUEMENT, et jamais
        // au niveau 0 qui n'en reçoit pas.
        $bonus   = ($est35 && $n >= 1) ? bonusSortsCarac($carVal, $n) : 0;
        // Emplacement de domaine : un par niveau de sort accessible, à partir du 1er.
        $domaine = ($est35 && $n >= 1 && (int)($c['cla_domaine_divin'] ?? 0) === 1) ? 1 : 0;
        $empl[$n]   = $table + $bonus + $domaine;
        $detail[$n] = ['table' => $table, 'bonus' => $bonus, 'domaine' => $domaine, 'accessible' => true];
      endfor;
    endif;

    // ---- Plafond du répertoire figé (DD3.5 spontané) -------------------
    $connus = null;
    if ($est35 && $profil === PROFINC_REPERTOIRE):
      $connus = [];
      for ($n = 0; $n <= 9; $n++):
        $v = $ligneS['cn_sortConnu_n' . $n] ?? null;
        $connus[$n] = ($v === null || $v === '') ? 0 : (int)$v;
      endfor;
    endif;

    // ---- Sorts toujours préparés : la classe ET la sous-classe DÉTENUE --
    // Une sous-classe DD2024 est une classe (cla_clt_id = 5) : le personnage en
    // détient une ligne dans dd_personnages_classes. On ne retient donc QUE
    // celles qu'il possède — prendre toutes les sous-classes de la classe
    // afficherait les sorts du Domaine de la Vie à n'importe quel clerc.
    $porteurs = [(int)$c['pc_cla_id']];
    foreach ($classes as $autre):
      if ((int)($autre['cla_cla_id'] ?? 0) === (int)$c['pc_cla_id']):
        $porteurs[] = (int)$autre['pc_cla_id'];
      endif;
    endforeach;
    // PIÈGE 2 — cumulatif : cs_niveau <= niveau, jamais l'égalité.
    $toujours = sortsToujoursPrepares($db, $porteurs, $niveau);

    // ---- Prérequis de caractéristique (DD3.5 seul, avertissement) ------
    if ($est35 && $carVal):
      for ($n = 9; $n >= 1; $n--):
        if ($empl[$n] > 0 && !peutLancerNiveau($carVal, $n)):
          $avert[] = sprintf('%s %d insuffisante pour les sorts de niveau %d (il en faut %d).',
            $c['car_nom'] ?? 'Caractéristique', $carVal, $n, 10 + $n);
          break;
        endif;
      endfor;
    endif;

    $out[] = [
      'pc_id'          => (int)$c['pc_id'],
      'cla_id'         => (int)$c['pc_cla_id'],
      'cla_nom'        => $c['cla_nom'],
      'niveau'         => $niveau,
      'profil'         => $profil,
      'profil_lib'     => $profil ? libVar($db, $profil) : '',
      'cadence'        => (int)($c['cla_renouvellement'] ?? 0),
      'cadence_lib'    => !empty($c['cla_renouvellement']) ? libVar($db, (int)$c['cla_renouvellement']) : '',
      'car_nom'        => $c['car_nom'] ?? '',
      'car_valeur'     => $carVal,
      'car_mod'        => $carMod,
      // DD3.5 : le DD dépend du niveau du sort (10 + niveau + mod), il est donc
      // calculé à l'affichage. DD2024 : valeur unique (8 + mod + maîtrise).
      'dd_base'        => $est35 ? 10 : (8 + $carMod + $bonusMaitr),
      'dd_par_niveau'  => $est35,
      'attaque'        => $est35 ? null : ($carMod + $bonusMaitr),
      'nls'            => $nlsEff,
      // 'ecart' : ce qui s'ajoute au niveau de classe — apport des classes de
      // prestige en DD3.5, agrégation multiclasse en DD2024 (négative possible :
      // un demi-lanceur ne compte que pour la moitié de ses niveaux).
      'nls_detail'     => $nlsDet + ['origine' => $est35 ? 'prestige' : 'agregation'],
      'emplacements'   => $empl,
      'empl_detail'    => $detail,
      'pacte'          => $pacte,
      // cn_sort_n0 porte DEUX sens : en DD2024 le nombre de sorts mineurs
      // connus, en DD3.5 les emplacements de niveau 0 par jour — déjà rendus
      // dans 'emplacements'. D'où la clé nulle en DD3.5.
      'sorts_mineurs'  => (!$est35 && $ligne) ? (int)($ligne['cn_sort_n0'] ?? 0) : null,
      // cn_sortPrepare est un plafond DD2024 ; il vaut 0 en DD3.5, sans objet.
      'sorts_prepares' => (!$est35 && $ligne && $ligne['cn_sortPrepare'] !== null)
                            ? (int)$ligne['cn_sortPrepare'] : null,
      'sorts_connus'   => $connus,
      'toujours'       => $toujours,
      'domaines'       => array_values(array_filter([$c['domaine1_nom'] ?? null, $c['domaine2_nom'] ?? null])),
      'avertissements' => $avert,
    ];
  endforeach;

  return $out;
}
// ============================================================
// LISTES AUXILIAIRES POUR LES SELECTS DE MODIFICATION
// ============================================================

/**
 * Liste complète des alignements (référentiel commun à tous les rulesets).
 * Renvoie un tableau prêt à itérer pour un <select>.
 *
 * @param  PDO  $db
 * @return array  [{al_id, al_nom, al_abreviation}, …]
 */
function getAlignements(PDO $db): array {
  $stmt = $db->query('
    SELECT al_id, al_nom, al_abreviation
      FROM dd_alignements
     ORDER BY al_ordre
  ');
  return $stmt->fetchAll();
}

// ============================================================
// CALCULS LÉGERS (aide d'affichage — pas du moteur de règles)
// ============================================================

// modCarac() et formatMod() ont été déplacés dans include/helpers.php (SP-MA1) :
// bonusSortsCarac() a besoin de la même formule de modificateur, et dupliquer
// celle-ci dans deux fichiers était le meilleur moyen de la voir diverger.
// helpers.php est chargé avant ce fichier par les 7 points d'entrée du module,
// les appels existants n'ont donc pas bougé.

/**
 * Bonus de maîtrise DD2024 au niveau global du personnage (`dd_bonus_maitrise`).
 * Renvoie 0 si le ruleset n'a pas de table de bonus (DD3.5) ou si le niveau
 * demandé n'y figure pas — la fiche affiche alors le seul modificateur de carac.
 *
 * @param  PDO  $db
 * @param  int  $ruleset_id
 * @param  int  $niveau      Niveau global (somme des niveaux de classe)
 * @return int
 */
function getBonusMaitrise(PDO $db, int $ruleset_id, int $niveau): int {
  if ($niveau < 1):
    $niveau = 1;
  endif;
  // Le PALIER le plus élevé qui ne dépasse pas le niveau, et non la ligne de
  // niveau exact : `dd_bonus_maitrise` s'arrête au niveau 20, si bien qu'un
  // personnage multiclassé totalisant davantage — un magicien 20 / clerc 10 de
  // la base de test — ne trouvait aucune ligne et repartait avec un bonus de
  // ZÉRO. Toutes ses compétences affichaient alors leur seul modificateur de
  // caractéristique, maîtrise et expertise comprises (SP-PE10j).
  $stmt = $db->prepare('
    SELECT bm_bonus
      FROM dd_bonus_maitrise
     WHERE bm_ruleset_var_id = ?
       AND bm_niveau <= ?
  ORDER BY bm_niveau DESC
     LIMIT 1
  ');
  $stmt->execute([$ruleset_id, $niveau]);
  $bonus = $stmt->fetchColumn();
  return $bonus !== false ? (int)$bonus : 0;
}

/**
 * Bonus total d'une compétence — aide d'affichage (SP-PE3).
 *
 * DD3.5   : rangs + modificateur de caractéristique.
 * DD2024  : modificateur de caractéristique + bonus de maîtrise
 *           (×1 si maîtrise, ×2 si expertise, rien sinon).
 *
 * Volontairement **hors équipement, armure et bonus divers** : ces données ne
 * sont pas saisies dans le module (cf. archi §7.1). Le total est une aide de
 * calcul, pas une valeur de fiche opposable — la fiche l'annonce explicitement.
 *
 * @param  int     $maitrise        pec_maitrise (rangs DD3.5 / 0-1-2 DD2024)
 * @param  int     $mod_carac       Modificateur de la caractéristique associée
 * @param  string  $ruleset_rep     'DD3.5' ou 'DD2024'
 * @param  int     $bonus_maitrise  Bonus de maîtrise DD2024 (0 en DD3.5)
 * @return int
 */
function bonusCompetence(int $maitrise, int $mod_carac, string $ruleset_rep, int $bonus_maitrise): int {
  if ($ruleset_rep === 'DD2024'):
    return $mod_carac + ($bonus_maitrise * min(max($maitrise, 0), 2));
  endif;
  return $mod_carac + $maitrise;
}
