<?
// include/helpers.php — Fonctions transverses
// À inclure après auth.php dans chaque page contrôleur

// ============================================================
// SÉCURITÉ / SORTIE
// ============================================================

// Échappe systématiquement pour l'affichage HTML
function h(string $val): string {
  return htmlspecialchars($val, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8');
}

// Nettoie un entier venant de l'input utilisateur
function intParam($val, int $default = 0): int {
  return (int)($val ?? $default);
}

// Nettoie une chaîne venant de l'input utilisateur
function strParam($val, string $default = ''): string {
  return trim((string)($val ?? $default));
}

// ============================================================
// AIDE CONTEXTUELLE
// ============================================================

// Icône (?) cliquable ouvrant la bulle d'aide associée à $cle (voir
// include/aide-contextuelle.php et include/ajax/aide.php). N'affiche rien
// si la clé n'existe pas, pour ne jamais casser un formulaire à cause d'une
// faute de frappe dans la clé.
function aideIcone(string $cle): string {
  static $cles = null;
  if ($cles === null) {
    $cles = require __DIR__ . '/aide-contextuelle.php';
  }
  if (!isset($cles[$cle])) {
    return '';
  }
  return '<span class="aide-icone" data-aide="' . h($cle) . '" tabindex="0" role="button" aria-label="Aide">?</span>';
}

// ============================================================
// FILTRAGE PROPRIÉTAIRE
// ============================================================

// Retourne le fragment SQL de filtrage propriétaire + les paramètres à binder
// Usage : [$where, $params] = ownerFilter('pe');
//         $stmt = $db->prepare("SELECT * FROM dd_personnages WHERE $where");
//         $stmt->execute($params);
function ownerFilter(string $prefix): array {
  if (isAdmin()) {
    return ['1=1', []];
  }
  return [
    $prefix . '_j_id = :owner_j_id',
    [':owner_j_id' => (int)$_SESSION['j_id']],
  ];
}

// Retourne true si l'utilisateur courant peut lire/écrire l'entité dont le j_id est fourni
function canAccess(int $entity_j_id): bool {
  return isAdmin() || (int)$_SESSION['j_id'] === $entity_j_id;
}

// ============================================================
// SÉLECTION DES SOURCES ACTIVES
// ============================================================

// Retourne le tableau des res_id actifs selon la chaîne de priorité :
//   1. Sélection de la campagne EN COURS du personnage en session (si ce
//      rattachement est actif et que la campagne a sa propre sélection)
//   2. Sélection personnelle de l'utilisateur (par ruleset)
//   3. Toutes les sources actives du ruleset (défaut absolu)
//
// $ruleset_var_id : ruleset à considérer. Par défaut celui de la session, ce qui
// convient au compendium (l'utilisateur consulte le ruleset qu'il a sélectionné).
// Les pages travaillant sur une entité dont le ruleset lui est propre — la fiche
// et l'overlay Personnage, dont le ruleset est figé à la création — doivent
// passer explicitement le ruleset de l'entité : sinon, consulter un personnage
// DD3.5 pendant une session DD2024 croise « compétences DD3.5 » avec « sources
// DD2024 » et ne remonte rien (cf. DECISIONS_LOG [2026-08-13]).
function getActiveResIds($db, ?int $ruleset_var_id = null): array {
  $ruleset_var_id = $ruleset_var_id ?? (int)($_SESSION['ruleset_var_id'] ?? 1);
  $j_id           = (int)($_SESSION['j_id'] ?? 0);

  // Priorité 1 : sélection de la campagne via last_pe_id
  if (!empty($_SESSION['last_pe_id'])) {
    $pe_id = (int)$_SESSION['last_pe_id'];

    // Cherche si le personnage est dans une campagne ayant sa propre sélection.
    //
    // Le périmètre est la **campagne en cours** du personnage (pe_camp_id), et
    // non l'ensemble de ses campagnes actives : un personnage traverse plusieurs
    // campagnes au cours de sa vie, et unionner leurs sources ferait apparaître
    // dans le compendium des ouvrages autorisés par une campagne terminée.
    // La liaison doit exister ET être active (cp_actif = 1, « participation en
    // cours ») — la table de liaison reste la source de vérité du rattachement,
    // pe_camp_id n'en est que le raccourci (cf. METIER_10 et SP-PE5).
    $stmt = $db->prepare('
      SELECT cs.cs_res_id
      FROM   dd_personnages pe
      JOIN   dd_campagnes_personnages cp ON cp.cp_camp_id = pe.pe_camp_id
                                        AND cp.cp_pe_id   = pe.pe_id
                                        AND cp.cp_actif   = 1
      JOIN   dd_campagnes_sources cs ON cs.cs_camp_id = cp.cp_camp_id
      WHERE  pe.pe_id = ?
    ');
    $stmt->execute([$pe_id]);
    $ids = $stmt->fetchAll(PDO::FETCH_COLUMN);

    if (!empty($ids)) {
      // Le supplément personnel de l'utilisateur courant est systématiquement
      // ajouté, même s'il n'a jamais été sélectionné explicitement dans les
      // sources de la campagne — cf. correctif équivalent du 2026-06-22 sur
      // getActiveResIdsCampagne(), qui n'avait pas été reporté ici (régression
      // corrigée le 2026-07-02). Cette fonction est scopée personnage/joueur
      // (pas MJ) : c'est donc le supplément de l'utilisateur courant ($j_id),
      // et non celui du propriétaire de la campagne, qui doit être ajouté.
      $supplement_res_id = $j_id > 0 ? getUserSupplementResId($db, $j_id, $ruleset_var_id) : null;
      if ($supplement_res_id !== null && !in_array($supplement_res_id, $ids, true)) {
        $ids[] = $supplement_res_id;
      }
      return $ids;
    }
  }

  // Priorité 2 : sélection personnelle
  if ($j_id > 0) {
    $stmt = $db->prepare('
      SELECT js_res_id
      FROM   dd_joueurs_sources
      WHERE  js_j_id = ? AND js_ruleset_var_id = ?
    ');
    $stmt->execute([$j_id, $ruleset_var_id]);
    $ids = $stmt->fetchAll(PDO::FETCH_COLUMN);
    if (!empty($ids)) return $ids;
  }

  // Priorité 3 : toutes les sources actives du ruleset
  $stmt = $db->prepare('
    SELECT res_id
    FROM   dd_ressources
    WHERE  res_ruleset_var_id = ? AND res_selection = 1 AND res_j_id IS NULL
  ');
  $stmt->execute([$ruleset_var_id]);
  return $stmt->fetchAll(PDO::FETCH_COLUMN);
}

// Génère des placeholders SQL pour un tableau d'ids
// Usage : $in = resIdsPlaceholders($ids); // retourne "?,?,?"
function resIdsPlaceholders(array $ids): string {
  return implode(',', array_fill(0, count($ids), '?'));
}

// Retourne le tableau des res_id actifs pour le contexte MJ d'une campagne
// (module Campagnes — recherche de monstre pour les oppositions).
// Distinct de getActiveResIds() qui est scopé personnage/joueur.
//   1. Sélection propre à la campagne (dd_campagnes_sources)
//   2. Repli : TOUTES les sources officielles du ruleset (res_j_id IS NULL).
//      Volontairement plus large que getActiveResIds() priorité 3 :
//      res_selection ne signifie « cochée par défaut à la création d'un
//      compte joueur », pas « source valide » — un MJ sans sélection
//      explicite doit voir l'intégralité du compendium du ruleset, y
//      compris les suppléments ajoutés après coup avec res_selection=0.
// Sources actives pour une campagne donnée. Si la campagne a des sources
// explicitement configurées (dd_campagnes_sources), on les utilise telles
// quelles ; sinon, repli sur toutes les sources officielles du ruleset.
//
// Dans les deux cas, le supplément personnel du PROPRIÉTAIRE de la campagne
// (camp_j_id) est toujours inclus, même s'il n'a jamais été ajouté
// explicitement aux sources de la campagne — un MJ doit pouvoir utiliser ses
// propres monstres homebrew pour construire ses oppositions sans étape
// manuelle supplémentaire. Avant ce correctif, le repli filtrait
// explicitement `res_j_id IS NULL` (sources officielles uniquement) et le
// formulaire de sélection des sources de campagne (modifier/campagne.php)
// ne propose lui non plus que des sources officielles : le supplément
// personnel n'avait donc AUCUN moyen d'entrer dans cette liste.
function getActiveResIdsCampagne(PDO $db, int $camp_id, int $ruleset_var_id): array {
  $stmt = $db->prepare('SELECT camp_j_id FROM dd_campagnes WHERE camp_id = ?');
  $stmt->execute([$camp_id]);
  $camp_j_id = (int)$stmt->fetchColumn();

  $supplement_res_id = $camp_j_id
    ? getUserSupplementResId($db, $camp_j_id, $ruleset_var_id)
    : null;

  $stmt = $db->prepare('SELECT cs_res_id FROM dd_campagnes_sources WHERE cs_camp_id = ?');
  $stmt->execute([$camp_id]);
  $ids = $stmt->fetchAll(PDO::FETCH_COLUMN);

  if (!empty($ids)):
    if ($supplement_res_id !== null && !in_array($supplement_res_id, $ids, true)):
      $ids[] = $supplement_res_id;
    endif;
    return $ids;
  endif;

  $stmt = $db->prepare('
    SELECT res_id FROM dd_ressources
    WHERE res_ruleset_var_id = ? AND res_j_id IS NULL
  ');
  $stmt->execute([$ruleset_var_id]);
  $ids = $stmt->fetchAll(PDO::FETCH_COLUMN);

  if ($supplement_res_id !== null):
    $ids[] = $supplement_res_id;
  endif;

  return $ids;
}

// ============================================================
// PROFILS D'INCANTATION (SP-MA0)
// ============================================================
//
// Le rapport d'une classe à ses sorts tient dans quatre profils, et quatre
// seulement — ce sont les combinaisons réellement présentes dans les règles
// (voir doc/METIER_7_SORTS.md §6). Ils remplacent les trois drapeaux
// cla_sort_connu / _compris / _prepare, dépréciés au 2026-08-27 : trois
// booléens indépendants offraient huit combinaisons dont quatre absurdes, et
// leur contenu en base s'était révélé faux (Magicien et Ensorceleur inversés).
//
// Les ids vivent dans dd_variables (var_cat = 'profinc'), posés par
// sql/2026-08-27_profil_incantation_sp-ma0.sql. Ils sont figés ici en
// constantes pour ne pas répéter l'écueil des littéraux clt_id dispersés
// dans le code (cf. ARCHITECTURE_0_REFERENCE.md, module Classes).

define('PROFINC_LISTE',      3);  // Réservoir = liste de classe entière, le personnage prépare
define('PROFINC_GRIMOIRE',   4);  // Réservoir = grimoire (pes_compris = 1), le personnage prépare
define('PROFINC_REPERTOIRE', 5);  // Répertoire figé (cn_sortConnu_n*), lancement spontané — DD3.5 uniquement
define('PROFINC_PACTE',      6);  // Emplacements uniformes, repos court — DD2024 uniquement

define('CADENCE_REPOS_LIBRE', 7);  // La liste peut être entièrement refaite à chaque repos long
define('CADENCE_REPOS_UN',    8);  // Un seul sort échangé par repos long — DD2024 uniquement
define('CADENCE_NIVEAU',      9);  // La liste ne change qu'en gagnant un niveau

// Cadences de renouvellement du réservoir (axe C, SP-MA4b). Pas de filtrage par
// ruleset : aucune valeur n'est impossible dans l'absolu — « un seul sort par
// repos long » n'est simplement utilisée par aucune classe DD3.5 du SRD, mais
// rien n'interdit à une classe maison de s'en servir.
function cadencesRenouvellement($db): array {
  return $db->query("SELECT var_id, var_valeur, var_commentaire FROM dd_variables
                     WHERE var_cat = 'cadence' ORDER BY var_ordre")->fetchAll();
}

// Profils proposables pour un ruleset donné, dans l'ordre d'affichage.
// Le filtrage est ici et nulle part ailleurs : « Répertoire spontané » n'existe
// qu'en DD3.5, « Magie de pacte » qu'en DD2024 (METIER_7_SORTS.md §4).
function profilsIncantation($db, int $ruleset_var_id): array {
  $exclu = $ruleset_var_id === 1 ? PROFINC_PACTE : PROFINC_REPERTOIRE;

  $stmt = $db->prepare('
    SELECT var_id, var_valeur, var_commentaire
    FROM   dd_variables
    WHERE  var_cat = \'profinc\' AND var_id <> ?
    ORDER  BY var_ordre, var_valeur
  ');
  $stmt->execute([$exclu]);
  return $stmt->fetchAll();
}

// ============================================================
// CARACTÉRISTIQUES — modificateur, sorts bonus, prérequis
// ============================================================
//
// Déplacé ici depuis personnage_helpers.php en SP-MA1 : ces fonctions servent
// au module Personnages, mais aussi au compendium et, plus tard, à l'écran du MJ.
//
// ATTENTION — deux de ces quatre fonctions ne valent QU'EN DD3.5 :
//   modCarac()         les deux rulesets
//   formatMod()        les deux rulesets (formatage pur)
//   bonusSortsCarac()  *[DD3.5]* — DD2024 n'accorde aucun sort bonus
//   peutLancerNiveau() *[DD3.5]* — DD2024 n'impose aucune valeur minimale
// Vérifié sur le SRD 5.2.1 : les deux règles ont disparu en 2024. Les seules
// occurrences 2024 de « 10 + le niveau du sort » y sont des DD de jet (dissiper,
// identifier), pas un prérequis. L'appelant doit donc brancher sur le ruleset.

/**
 * Modificateur d'une caractéristique (formule DD standard : floor((val - 10) / 2)).
 * Vaut dans les deux rulesets.
 *
 * Exemples : 10 → 0, 11 → 0, 12 → +1, 8 → -1, 18 → +4.
 */
function modCarac(int $valeur): int {
  // PHP : intdiv tronque vers zéro, donc on utilise floor pour les valeurs < 10.
  return (int) floor(($valeur - 10) / 2);
}

/**
 * Formate un modificateur signé pour affichage : 0 → "+0", 3 → "+3", -1 → "-1".
 * Formatage pur — vaut dans les deux rulesets.
 */
function formatMod(int $modificateur): string {
  return ($modificateur >= 0 ? '+' : '') . $modificateur;
}

/**
 * *[DD3.5]* Sorts en bonus accordés par une caractéristique élevée, pour un
 * niveau de sort donné. DD2024 n'a pas de sorts bonus : ne pas appeler.
 *
 * Formule, contrôlée ligne à ligne contre la « Table : modificateurs de
 * caractéristique et sorts en bonus » du SRD (DRS 01) :
 *
 *     bonus = mod >= N  ?  floor((mod - N) / 4) + 1  :  0
 *
 * Le niveau 0 ne reçoit jamais de sort bonus. Exemple de contrôle, mod +11 :
 * la formule redonne 3 3 3 2 2 2 2 1 1 pour les niveaux 1 à 9, comme le SRD.
 *
 * Le choix de la formule plutôt que de la table dd_modificateurs est arbitré :
 * une table plafonnée renvoie 0 en silence au-delà de sa dernière ligne, ce qui
 * est le pire mode de défaillance pour une aide de jeu (un magicien de niveau 20
 * équipé dépasse 30 sans peine). Voir DECISIONS_LOG.md [2026-08-27] D-MAG9.
 *
 * @param  int $valeur       Valeur brute de la caractéristique d'incantation
 * @param  int $niveau_sort  Niveau du sort (0 à 9)
 * @return int               Nombre de sorts bonus de ce niveau
 */
function bonusSortsCarac(int $valeur, int $niveau_sort): int {
  if ($niveau_sort < 1 || $niveau_sort > 9) return 0;
  $mod = modCarac($valeur);
  if ($mod < $niveau_sort) return 0;
  return (int) floor(($mod - $niveau_sort) / 4) + 1;
}

/**
 * *[DD3.5]* Prérequis de caractéristique : pour préparer ou lancer un sort de
 * niveau N, il faut au moins 10 + N dans la caractéristique de la classe.
 *
 * **DD2024 n'a pas cette règle** : aucune valeur minimale n'y conditionne
 * l'accès à un niveau de sort. Ne pas appeler pour un personnage DD2024 —
 * la fonction rendrait « non » à tort sur une caractéristique modeste.
 *
 * Aide à l'affichage, pas un filtre : la fiche signale, elle n'interdit pas
 * (principe « aide de jeu, pas moteur de règles » — ARCHITECTURE_0_REFERENCE §7.7).
 */
function peutLancerNiveau(int $valeur, int $niveau_sort): bool {
  return $valeur >= 10 + $niveau_sort;
}

// ============================================================
// VARIABLES DD (libellés et selects)
// ============================================================

// Retourne le libellé d'une variable par son id
function libVar($db, int $var_id): string {
  $stmt = $db->prepare('SELECT var_valeur FROM dd_variables WHERE var_id = ?');
  $stmt->execute([$var_id]);
  $row = $stmt->fetch();
  return $row ? h($row['var_valeur']) : '';
}

// Retourne un <select> rempli avec les variables d'une catégorie
function optionListVar($db, string $cat, string $name, int $selected = 0, string $class = ''): string {
  $stmt = $db->prepare('
    SELECT var_id, var_valeur
    FROM   dd_variables
    WHERE  var_cat = ?
    ORDER  BY var_ordre, var_valeur
  ');
  $stmt->execute([$cat]);
  $rows = $stmt->fetchAll();

  $cls = $class ? ' class="' . h($class) . '"' : '';
  $out = '<select name="' . h($name) . '"' . $cls . '>';
  $out .= '<option value="0">— Choisir —</option>';
  foreach ($rows as $r) {
    $sel  = (int)$r['var_id'] === $selected ? ' selected' : '';
    $out .= '<option value="' . (int)$r['var_id'] . '"' . $sel . '>' . h($r['var_valeur']) . '</option>';
  }
  $out .= '</select>';
  return $out;
}

// ============================================================
// PAGINATION
// ============================================================

function getPagination(int $total, int $per_page, int $current_page): array {
  $per_page     = max(1, $per_page);
  $total_pages  = max(1, (int)ceil($total / $per_page));
  $current_page = max(1, min($current_page, $total_pages));
  $offset       = ($current_page - 1) * $per_page;

  return [
    'total'        => $total,
    'per_page'     => $per_page,
    'current_page' => $current_page,
    'total_pages'  => $total_pages,
    'offset'       => $offset,
  ];
}

// ============================================================
// RULESET D'UNE ENTITÉ À L'ENREGISTREMENT
// ============================================================
// Le ruleset n'est ni saisi ni transmis par les formulaires — ni select, ni
// champ caché : il est imposé côté serveur. À la création c'est le ruleset actif
// en session, à la modification c'est celui déjà en base (une entité ne change
// jamais de ruleset : races, classes, sources, tableaux et glossaire qui lui sont
// rattachés en dépendent tous). Un POST forgé ne peut donc plus créer d'entrée
// dans l'autre ruleset, où elle serait invisible de toutes les listes.
//
// $table / $champ_id / $champ_ruleset sont des identifiants SQL écrits en dur par
// l'appelant, jamais issus de l'utilisateur — interpolation assumée, comme dans
// compendium-liste.php. Voir DECISIONS_LOG [2026-08-13].
function rulesetEnregistrement(PDO $db, string $table, string $champ_id,
                               string $champ_ruleset, int $id): int {
  if ($id > 0):
    $stmt = $db->prepare("SELECT $champ_ruleset FROM $table WHERE $champ_id = ?");
    $stmt->execute([$id]);
    $existant = $stmt->fetchColumn();
    if ($existant !== false && $existant !== null):
      return (int)$existant;
    endif;
  endif;
  return (int)($_SESSION['ruleset_var_id'] ?? 1);
}

// ============================================================
// CONTEXTE PERSONNAGE (last_pe_id)
// ============================================================

// Mémorise le dernier personnage consulté en session
function setLastPersonnage(int $pe_id) {
  $_SESSION['last_pe_id'] = $pe_id;
}

// Retourne le dernier pe_id consulté ou 0
function getLastPersonnage(): int {
  return (int)($_SESSION['last_pe_id'] ?? 0);
}

// ============================================================
// CONTEXTE CAMPAGNE (last_camp_id / last_sce_id / last_scc_id)
// ============================================================
// Mémorisation en cascade des derniers niveaux consultés dans la hiérarchie
// Campagne → Scénario → Chapitre → Rencontre, pour les boutons de retour
// rapide affichés dans le header sur toutes les pages. Appelée depuis chaque
// include/ajax/detail-pp/*.php, qui dispose déjà de la chaîne d'ancêtres via
// sa jointure remontante.
//
// Un niveau enfant n'est effacé QUE si l'id du niveau courant change
// réellement (sélection d'une autre campagne/scénario/chapitre) — revisiter
// le même niveau (ex. clic sur un bouton du header) préserve les niveaux
// enfants déjà mémorisés, tant qu'on ne change pas de campagne/scénario/
// chapitre. Le discriminant est l'id, pas le chemin emprunté pour y arriver.

// Mémorise la campagne ; n'efface les niveaux enfants que si l'id change.
function setLastCampagne(int $camp_id, string $camp_nom): void {
  $camp_change = ((int)($_SESSION['last_camp_id'] ?? 0)) !== $camp_id;
  $_SESSION['last_camp_id']  = $camp_id;
  $_SESSION['last_camp_nom'] = $camp_nom;
  if ($camp_change):
    unset($_SESSION['last_sce_id'], $_SESSION['last_sce_nom']);
    unset($_SESSION['last_scc_id'], $_SESSION['last_scc_nom']);
    unset($_SESSION['last_re_id'],  $_SESSION['last_re_nom']);
  endif;
}

// Mémorise le scénario (et sa campagne) ; n'efface chapitre/rencontre que si
// l'id du scénario change.
function setLastScenario(int $camp_id, string $camp_nom, int $sce_id, string $sce_nom): void {
  setLastCampagne($camp_id, $camp_nom);
  $sce_change = ((int)($_SESSION['last_sce_id'] ?? 0)) !== $sce_id;
  $_SESSION['last_sce_id']  = $sce_id;
  $_SESSION['last_sce_nom'] = $sce_nom;
  if ($sce_change):
    unset($_SESSION['last_scc_id'], $_SESSION['last_scc_nom']);
    unset($_SESSION['last_re_id'],  $_SESSION['last_re_nom']);
  endif;
}

// Mémorise le chapitre (et sa campagne + son scénario) ; n'efface la
// rencontre que si l'id du chapitre change.
function setLastChapitre(int $camp_id, string $camp_nom, int $sce_id, string $sce_nom,
                          int $scc_id, string $scc_nom): void {
  setLastScenario($camp_id, $camp_nom, $sce_id, $sce_nom);
  $scc_change = ((int)($_SESSION['last_scc_id'] ?? 0)) !== $scc_id;
  $_SESSION['last_scc_id']  = $scc_id;
  $_SESSION['last_scc_nom'] = $scc_nom;
  if ($scc_change):
    unset($_SESSION['last_re_id'], $_SESSION['last_re_nom']);
  endif;
}

// Mémorise la rencontre (et toute sa chaîne d'ancêtres) — c'est le niveau le
// plus profond, rien à effacer en dessous.
function setLastRencontre(int $camp_id, string $camp_nom, int $sce_id, string $sce_nom,
                           int $scc_id, string $scc_nom, int $re_id, string $re_nom): void {
  setLastChapitre($camp_id, $camp_nom, $sce_id, $sce_nom, $scc_id, $scc_nom);
  $_SESSION['last_re_id']  = $re_id;
  $_SESSION['last_re_nom'] = $re_nom;
}

// Retourne la liste ordonnée des niveaux campagne actifs (du plus haut au plus
// profond), prête à afficher dans le header. Aucune requête base — tout est en
// session, écrit au moment de la consultation par les handlers detail-pp.
function getHeaderCampagneContext(): array {
  $niveaux = [];

  if (!empty($_SESSION['last_camp_id'])):
    $niveaux[] = [
      'type' => 'campagne',
      'id'   => (int)$_SESSION['last_camp_id'],
      'nom'  => $_SESSION['last_camp_nom'] ?? '',
    ];
  endif;

  if (!empty($_SESSION['last_sce_id'])):
    $niveaux[] = [
      'type' => 'scenario',
      'id'   => (int)$_SESSION['last_sce_id'],
      'nom'  => $_SESSION['last_sce_nom'] ?? '',
    ];
  endif;

  if (!empty($_SESSION['last_scc_id'])):
    $niveaux[] = [
      'type' => 'chapitre',
      'id'   => (int)$_SESSION['last_scc_id'],
      'nom'  => $_SESSION['last_scc_nom'] ?? '',
    ];
  endif;

  if (!empty($_SESSION['last_re_id'])):
    $niveaux[] = [
      'type' => 'rencontre',
      'id'   => (int)$_SESSION['last_re_id'],
      'nom'  => $_SESSION['last_re_nom'] ?? '',
    ];
  endif;

  return $niveaux;
}

// Calcule les niveaux de contexte à afficher dans le header : la chaîne
// campagne/scénario/chapitre active, ou à défaut le dernier personnage
// consulté (cf. include/header.php et include/ajax/header-context.php, qui
// partagent cette fonction pour rester synchronisés sans recharger la page).
function getHeaderContextNiveaux(PDO $db): array {
  return getHeaderCampagneContext();
}

// Dernier personnage consulté, pour le raccourci de la ligne de titre du header
// (SP-RS6). Autrefois replié dans getHeaderContextNiveaux() comme niveau de
// contexte de repli — il en est sorti pour être affiché en permanence, y
// compris pendant la consultation d'une campagne.
function getHeaderPersonnage(PDO $db): ?array {
  $last_pe_id = getLastPersonnage();
  if ($last_pe_id <= 0) return null;

  $stmt = $db->prepare('SELECT pe_nom FROM dd_personnages WHERE pe_id = ?');
  $stmt->execute([$last_pe_id]);
  $pe_nom = $stmt->fetchColumn();
  if ($pe_nom === false) return null;

  return ['id' => $last_pe_id, 'nom' => $pe_nom];
}

// Invalide le contexte mémorisé quand l'élément supprimé (soft delete) est
// celui actuellement mémorisé à ce niveau — efface ce niveau et tout ce qui
// est en dessous, conserve les ancêtres. Appelée depuis campagnes/enregistrement.php
// juste après le commit de chaque supprimer*().
function invalidateLastCampagneContext(string $niveau, int $id): void {
  $prefixes = ['campagne' => 'camp', 'scenario' => 'sce', 'chapitre' => 'scc', 'rencontre' => 're'];
  if (!isset($prefixes[$niveau])) return;

  $cle_id = 'last_' . $prefixes[$niveau] . '_id';
  if ((int)($_SESSION[$cle_id] ?? 0) !== $id) return;

  $chaine = array_keys($prefixes);
  $depart = array_search($niveau, $chaine);
  foreach (array_slice($chaine, $depart) as $n):
    unset($_SESSION['last_' . $prefixes[$n] . '_id'], $_SESSION['last_' . $prefixes[$n] . '_nom']);
  endforeach;
}

// Efface tout le contexte de navigation dépendant du ruleset — personnage,
// campagne, scénario, chapitre, rencontre. Appelée au changement de ruleset
// (profil/index.php § paramètres) : ces entités appartiennent toutes à un
// ruleset donné, les garder en session après bascule affiche dans le header des
// niveaux du ruleset précédent et, surtout, fausse getActiveResIds() — qui
// remonte les sources de la campagne du dernier personnage consulté et
// croiserait alors « personnage DD3.5 » avec « sources DD2024 ».
function resetContexteRuleset(): void {
  unset($_SESSION['last_pe_id']);
  unset($_SESSION['last_camp_id'], $_SESSION['last_camp_nom']);
  unset($_SESSION['last_sce_id'],  $_SESSION['last_sce_nom']);
  unset($_SESSION['last_scc_id'],  $_SESSION['last_scc_nom']);
  unset($_SESSION['last_re_id'],   $_SESSION['last_re_nom']);
}

// ============================================================
// SUPPLÉMENT UTILISATEUR
// ============================================================
// Le supplément d'un utilisateur est une entrée dd_ressources avec
// res_j_id = j_id et res_camp_id IS NULL (réserve d'architecture activée —
// voir DECISIONS_LOG [2026-06-15]). Un supplément par utilisateur par ruleset.

// Retourne le res_id du supplément de l'utilisateur pour ce ruleset, ou null
// s'il n'a encore jamais créé d'entrée de supplément.
function getUserSupplementResId($db, int $j_id, int $ruleset_var_id): ?int {
  $stmt = $db->prepare('
    SELECT res_id
    FROM   dd_ressources
    WHERE  res_j_id = ? AND res_ruleset_var_id = ?
  ');
  $stmt->execute([$j_id, $ruleset_var_id]);
  $res_id = $stmt->fetchColumn();
  return $res_id !== false ? (int)$res_id : null;
}

// Crée le supplément de l'utilisateur s'il n'existe pas encore, puis retourne
// son res_id (création idempotente — un utilisateur n'a qu'un seul supplément
// par ruleset). Appelée depuis enregistrement.php au premier save d'une entrée
// de supplément ; ne gère pas sa propre transaction (le caller doit englober
// l'appel dans la transaction PDO de l'enregistrement).
function getOrCreateUserSupplement($db, int $j_id, int $ruleset_var_id): int {
  $res_id = getUserSupplementResId($db, $j_id, $ruleset_var_id);
  if ($res_id !== null) {
    return $res_id;
  }

  // Avant de créer le supplément : si l'utilisateur n'a encore aucune
  // sélection personnelle pour ce ruleset (dd_joueurs_sources vide), il
  // dépend du défaut absolu (priorité 3 de getActiveResIds() — toutes les
  // sources officielles res_selection=1). Ajouter le supplément SEUL dans
  // dd_joueurs_sources transformerait sa sélection personnelle en "supplément
  // seul" (priorité 2 non vide = court-circuit de la priorité 3), masquant
  // alors toutes les ressources officielles par défaut. On reproduit donc
  // ce défaut dans sa sélection personnelle avant d'y ajouter le supplément.
  $stmt = $db->prepare('
    SELECT COUNT(*) FROM dd_joueurs_sources
    WHERE js_j_id = ? AND js_ruleset_var_id = ?
  ');
  $stmt->execute([$j_id, $ruleset_var_id]);
  $a_deja_une_selection = (int)$stmt->fetchColumn() > 0;

  if (!$a_deja_une_selection) {
    $stmt = $db->prepare('
      INSERT INTO dd_joueurs_sources (js_j_id, js_res_id, js_ruleset_var_id)
      SELECT ?, res_id, ?
      FROM   dd_ressources
      WHERE  res_ruleset_var_id = ? AND res_selection = 1 AND res_j_id IS NULL
    ');
    $stmt->execute([$j_id, $ruleset_var_id, $ruleset_var_id]);
  }

  // Création de la ressource supplément
  $stmt = $db->prepare('SELECT j_pseudo FROM dd_joueurs WHERE j_id = ?');
  $stmt->execute([$j_id]);
  $pseudo = $stmt->fetchColumn();
  $nom    = 'Supplément de ' . ($pseudo !== false ? $pseudo : 'utilisateur');

  $stmt = $db->prepare('
    INSERT INTO dd_ressources (res_nom, res_abreviation, res_selection, res_ruleset_var_id, res_j_id)
    VALUES (?, ?, 0, ?, ?)
  ');
  $stmt->execute([$nom, 'Supp.', $ruleset_var_id, $j_id]);
  $res_id = (int)$db->lastInsertId();

  // Auto-ajout du supplément lui-même à la sélection personnelle
  // (priorité 2 de getActiveResIds() — getActiveResIds() reste inchangée)
  $stmt = $db->prepare('
    INSERT INTO dd_joueurs_sources (js_j_id, js_res_id, js_ruleset_var_id)
    VALUES (?, ?, ?)
  ');
  $stmt->execute([$j_id, $res_id, $ruleset_var_id]);

  return $res_id;
}

// Vrai si l'utilisateur courant peut modifier une entrée de compendium liée
// à la ressource $res_j_id (null = ressource officielle, sinon propriétaire
// du supplément). Contrôle PER-ENTRY — distinct de canEditCompendium()
// (auth.php) qui ne contrôle que l'accès global (bouton Ajouter, barre bulk).
// $db non utilisé actuellement, conservé pour cohérence de signature avec
// les autres fonctions can*() du projet qui interrogent la base.
function canEditCompendiumEntry($db, ?int $res_j_id): bool {
  if (isAdmin()) {
    return true;
  }
  if ($res_j_id !== null) {
    // Entrée de supplément : seul son propriétaire peut la modifier
    return (int)($_SESSION['j_id'] ?? 0) === $res_j_id;
  }
  // Entrée officielle : réservée aux gestionnaires du compendium
  return !empty($_SESSION['j_compendium_manager']);
}
