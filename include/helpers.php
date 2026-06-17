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
