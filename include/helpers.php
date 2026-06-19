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
//   1. Sélection campagne (si personnage en session rattaché à une campagne avec sa propre sélection)
//   2. Sélection personnelle de l'utilisateur (par ruleset)
//   3. Toutes les sources actives du ruleset (défaut absolu)
function getActiveResIds($db): array {
  $ruleset_var_id = (int)($_SESSION['ruleset_var_id'] ?? 1);
  $j_id           = (int)($_SESSION['j_id'] ?? 0);

  // Priorité 1 : sélection de la campagne via last_pe_id
  if (!empty($_SESSION['last_pe_id'])) {
    $pe_id = (int)$_SESSION['last_pe_id'];

    // Cherche si le personnage est dans une campagne ayant sa propre sélection
    $stmt = $db->prepare('
      SELECT cs.cs_res_id
      FROM   dd_campagnes_personnages cp
      JOIN   dd_campagnes_sources cs ON cs.cs_camp_id = cp.cp_camp_id
      WHERE  cp.cp_pe_id = ? AND cp.cp_actif = 1
    ');
    $stmt->execute([$pe_id]);
    $ids = $stmt->fetchAll(PDO::FETCH_COLUMN);
    if (!empty($ids)) return $ids;
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
function getActiveResIdsCampagne(PDO $db, int $camp_id, int $ruleset_var_id): array {
  $stmt = $db->prepare('SELECT cs_res_id FROM dd_campagnes_sources WHERE cs_camp_id = ?');
  $stmt->execute([$camp_id]);
  $ids = $stmt->fetchAll(PDO::FETCH_COLUMN);
  if (!empty($ids)) return $ids;

  $stmt = $db->prepare('
    SELECT res_id FROM dd_ressources
    WHERE res_ruleset_var_id = ? AND res_j_id IS NULL
  ');
  $stmt->execute([$ruleset_var_id]);
  return $stmt->fetchAll(PDO::FETCH_COLUMN);
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
// Campagne → Scénario → Chapitre (→ Rencontre, SP3), pour les boutons de
// retour rapide affichés dans le header sur toutes les pages. Appelée depuis
// include/ajax/detail-pp/{campagne,scenario,chapitre}.php, qui disposent déjà
// de la chaîne d'ancêtres via leur jointure remontante.

// Mémorise la campagne et efface tout niveau enfant mémorisé précédemment.
function setLastCampagne(int $camp_id, string $camp_nom): void {
  $_SESSION['last_camp_id']  = $camp_id;
  $_SESSION['last_camp_nom'] = $camp_nom;
  unset($_SESSION['last_sce_id'], $_SESSION['last_sce_nom']);
  unset($_SESSION['last_scc_id'], $_SESSION['last_scc_nom']);
  unset($_SESSION['last_re_id'],  $_SESSION['last_re_nom']);
}

// Mémorise le scénario (et sa campagne) ; efface chapitre/rencontre mémorisés.
function setLastScenario(int $camp_id, string $camp_nom, int $sce_id, string $sce_nom): void {
  setLastCampagne($camp_id, $camp_nom);
  $_SESSION['last_sce_id']  = $sce_id;
  $_SESSION['last_sce_nom'] = $sce_nom;
}

// Mémorise le chapitre (et sa campagne + son scénario) ; efface la rencontre mémorisée.
function setLastChapitre(int $camp_id, string $camp_nom, int $sce_id, string $sce_nom,
                          int $scc_id, string $scc_nom): void {
  setLastScenario($camp_id, $camp_nom, $sce_id, $sce_nom);
  $_SESSION['last_scc_id']  = $scc_id;
  $_SESSION['last_scc_nom'] = $scc_nom;
}

// Mémorise la rencontre (et toute sa chaîne d'ancêtres).
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
  $niveaux = getHeaderCampagneContext();
  if (!empty($niveaux)):
    return $niveaux;
  endif;

  $last_pe_id = getLastPersonnage();
  if ($last_pe_id > 0):
    $stmt = $db->prepare('SELECT pe_nom FROM dd_personnages WHERE pe_id = ?');
    $stmt->execute([$last_pe_id]);
    $pe_nom = $stmt->fetchColumn();
    if ($pe_nom !== false):
      $niveaux[] = ['type' => 'personnage', 'id' => $last_pe_id, 'nom' => $pe_nom];
    endif;
  endif;

  return $niveaux;
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
