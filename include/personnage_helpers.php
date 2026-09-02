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
  $stmt = $db->prepare('
    SELECT bm_bonus
      FROM dd_bonus_maitrise
     WHERE bm_ruleset_var_id = ?
       AND bm_niveau = ?
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
