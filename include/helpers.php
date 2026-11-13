<?php
// include/helpers.php — Fonctions transverses
// À inclure après auth.php dans chaque page contrôleur

// ============================================================
// SÉCURITÉ / SORTIE
// ============================================================

// Échappe systématiquement pour l'affichage HTML
function h(string $val): string {
  return htmlspecialchars($val, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8');
}

// URL d'une feuille CSS ou d'un script du projet ("css/main.css"), suffixée de
// la date de modification du fichier : le navigateur recharge dès qu'il change,
// sans qu'un rechargement forcé soit nécessaire après un déploiement.
function assetUrl(string $chemin): string {
  $fichier = __DIR__ . '/../' . $chemin;
  $v = is_file($fichier) ? (int)filemtime($fichier) : 0;
  return h(BASE_URL . '/' . $chemin . ($v ? '?v=' . $v : ''));
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
// ENVOI DE MAIL (SP-ML)
// ============================================================

// Sujet et texte du mail de réinitialisation, partagés entre la vraie demande et
// sa simulation dans admin/test-email.php : le test porte sur le contenu réel.
const SUJET_MAIL_REINITIALISATION = '[Codex DD] Réinitialisation de votre mot de passe';

function corpsMailReinitialisation(string $pseudo, string $lien): string {
  $corps  = "Bonjour " . $pseudo . ",\n\n";
  $corps .= "Vous avez demandé la réinitialisation de votre mot de passe.\n\n";
  $corps .= "Cliquez sur ce lien (valable 1 heure) :\n" . $lien . "\n\n";
  $corps .= "Si vous n'êtes pas à l'origine de cette demande, ignorez cet email.\n\n";
  $corps .= "— Codex DD";
  return $corps;
}

// Vrai si la configuration déclare un envoi SMTP complet, mot de passe compris
function smtpConfigure(): bool {
  return defined('SMTP_HOTE') && defined('SMTP_PORT') && defined('SMTP_UTILISATEUR')
    && defined('SMTP_MOT_DE_PASSE') && SMTP_MOT_DE_PASSE !== '';
}

// Point de passage unique des mails du site. L'expéditeur vient de la
// configuration, jamais de HTTP_HOST. Passe par le SMTP authentifié quand il est
// configuré, par mail() sinon ; un échec SMTP ne retombe PAS sur mail(), dont les
// messages se perdaient sans erreur en production (D-ML4). Retourne true si le
// serveur a ACCEPTÉ le message, ce qui ne garantit pas qu'il soit délivré. Le
// journal ne contient ni le destinataire ni le corps, qui peut porter un token de
// réinitialisation. $erreur reçoit la raison d'un échec, $reponses les réponses du
// serveur SMTP (diagnostic de la page de test, SP-ML5).
function envoyerMail(string $dest, string $sujet, string $corps, ?string &$erreur = null, ?array &$reponses = null): bool {
  $erreur   = null;
  $reponses = [];

  if (!defined('MAIL_EXPEDITEUR') || !filter_var(MAIL_EXPEDITEUR, FILTER_VALIDATE_EMAIL)):
    $erreur = 'MAIL_EXPEDITEUR absente ou invalide dans config/db.config.php';
    error_log('[envoyerMail] ' . $erreur);
    return false;
  endif;

  if (!filter_var($dest, FILTER_VALIDATE_EMAIL)):
    $erreur = 'destinataire invalide';
    error_log('[envoyerMail] ' . $erreur);
    return false;
  endif;

  if (smtpConfigure()):
    return envoyerMailSmtp($dest, $sujet, $corps, $erreur, $reponses);
  endif;

  $sujet_encode = mb_encode_mimeheader($sujet, 'UTF-8', 'B', "\r\n", strlen('Subject: '));
  $entetes = [
    'From'                      => 'Codex DD <' . MAIL_EXPEDITEUR . '>',
    'Reply-To'                  => MAIL_EXPEDITEUR,
    'MIME-Version'              => '1.0',
    'Content-Type'              => 'text/plain; charset=UTF-8',
    'Content-Transfer-Encoding' => '8bit',
  ];

  $accepte = @mail($dest, $sujet_encode, $corps, $entetes, '-f' . MAIL_EXPEDITEUR);
  if (!$accepte):
    $erreur = 'mail() a refusé le message : ' . (error_get_last()['message'] ?? 'raison inconnue');
    error_log('[envoyerMail] ' . $erreur);
  endif;

  return $accepte;
}

// Envoi authentifié (SP-ML3). TLS implicite, certificat vérifié par défaut.
// PHPMailer n'est chargé que pour cet usage.
function envoyerMailSmtp(string $dest, string $sujet, string $corps, ?string &$erreur = null, ?array &$reponses = null): bool {
  require_once __DIR__ . '/phpmailer/Exception.php';
  require_once __DIR__ . '/phpmailer/SMTP.php';
  require_once __DIR__ . '/phpmailer/PHPMailer.php';

  $envoi = new \PHPMailer\PHPMailer\PHPMailer(true);
  try {
    $envoi->isSMTP();
    $envoi->Host       = SMTP_HOTE;
    $envoi->Port       = SMTP_PORT;
    $envoi->SMTPSecure = \PHPMailer\PHPMailer\PHPMailer::ENCRYPTION_SMTPS;
    $envoi->SMTPAuth   = true;
    $envoi->Username   = SMTP_UTILISATEUR;
    $envoi->Password   = SMTP_MOT_DE_PASSE;
    $envoi->Timeout    = 15;
    // Seules les réponses du serveur sont retenues, jamais ce que le client envoie
    // (identifiants) ; les étapes 334 d'authentification sont écartées aussi.
    $envoi->SMTPDebug   = \PHPMailer\PHPMailer\SMTP::DEBUG_SERVER;
    $envoi->Debugoutput = function ($ligne) use (&$reponses) {
      $prefixe = 'SERVER -> CLIENT: ';
      if (strpos($ligne, $prefixe) !== 0) return;
      $texte = trim(substr($ligne, strlen($prefixe)));
      if (strpos($texte, '334') !== 0) $reponses[] = $texte;
    };
    $envoi->CharSet    = \PHPMailer\PHPMailer\PHPMailer::CHARSET_UTF8;
    $envoi->Encoding   = \PHPMailer\PHPMailer\PHPMailer::ENCODING_8BIT;
    $envoi->setFrom(MAIL_EXPEDITEUR, 'Codex DD');
    $envoi->addAddress($dest);
    $envoi->Subject = $sujet;
    $envoi->Body    = $corps;
    $envoi->isHTML(false);
    return $envoi->send();
  } catch (\Throwable $e) {
    $erreur = 'SMTP : ' . $envoi->ErrorInfo;
    error_log('[envoyerMail] ' . $erreur);
    return false;
  }
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
// SOURCES ACTIVES (SP-RE, D-RE1 → D-RE6)
// ============================================================
//
// Plus aucune sélection par utilisateur ni par campagne (dd_joueurs_sources et
// dd_campagnes_sources sont abandonnées). Pour un ruleset, les sources montrées
// sont l'union de :
//   1. les ressources officielles ACTIVES (res_j_id IS NULL, res_selection = 1),
//      liste tenue par l'admin seul ;
//   2. le supplément de l'utilisateur courant — toujours, qu'il soit public ou privé ;
//   3. le supplément du MJ de la campagne de contexte, même privé : les joueurs d'une
//      campagne utilisent le contenu de leur MJ ;
//   4. si les suppléments de MJ sont demandés : ceux des MJ dont le supplément est
//      public (j_supplement_public = 1) — pour un admin, TOUS les suppléments.
//
// $opts :
//   'supplements' bool — point 4. Défaut : préférence de profil j_voir_supplements
//                        (en session). Le filtre « Suppléments de MJ » des listes le force.
//   'camp_id'     int  — campagne de contexte (point 3), connue de l'appelant.
//   'pe_id'       int  — personnage de contexte : sa campagne en cours, si la liaison
//                        est active. Sans 'camp_id' ni 'pe_id', le dernier personnage
//                        ouvert ($_SESSION['last_pe_id']) sert de contexte.
//
// $ruleset_var_id : par défaut celui de la session (compendium). Les pages travaillant
// sur une entité à ruleset propre (personnage) passent le sien (DECISIONS_LOG [2026-08-13]).
function getActiveResIds($db, ?int $ruleset_var_id = null, array $opts = []): array {
  $ruleset_var_id = $ruleset_var_id ?? (int)($_SESSION['ruleset_var_id'] ?? 1);
  $j_id           = (int)($_SESSION['j_id'] ?? 0);
  $avec_supps     = array_key_exists('supplements', $opts)
                    ? (bool)$opts['supplements']
                    : !empty($_SESSION['j_voir_supplements']);

  // 1. Ressources officielles actives
  $stmt = $db->prepare('
    SELECT res_id FROM dd_ressources
     WHERE res_ruleset_var_id = ? AND res_selection = 1 AND res_j_id IS NULL
  ');
  $stmt->execute([$ruleset_var_id]);
  $ids = array_map('intval', $stmt->fetchAll(PDO::FETCH_COLUMN));

  // 2. Supplément de l'utilisateur courant
  $proprietaires = [];
  if ($j_id > 0) $proprietaires[] = $j_id;

  // 3. Supplément du MJ de la campagne de contexte
  $mj_id = mjCampagneContexte($db, $opts);
  if ($mj_id > 0) $proprietaires[] = $mj_id;

  foreach (array_unique($proprietaires) as $owner):
    $res_id = getUserSupplementResId($db, $owner, $ruleset_var_id);
    if ($res_id !== null) $ids[] = $res_id;
  endforeach;

  // 4. Suppléments de MJ (publics ; tous pour un admin)
  if ($avec_supps):
    $ids = array_merge($ids, supplementsVisiblesIds($db, $ruleset_var_id));
  endif;

  return array_values(array_unique($ids));
}

// res_id des suppléments de MJ visibles par l'utilisateur courant pour ce ruleset :
// les suppléments publics, ou tous pour un admin (un supplément privé n'est vu que
// de son MJ et des admins, D-RE2).
function supplementsVisiblesIds($db, int $ruleset_var_id): array {
  if (isAdmin()):
    $stmt = $db->prepare('
      SELECT res_id FROM dd_ressources
       WHERE res_ruleset_var_id = ? AND res_j_id IS NOT NULL
    ');
  else:
    $stmt = $db->prepare('
      SELECT res.res_id
        FROM dd_ressources res
        JOIN dd_joueurs j ON j.j_id = res.res_j_id
       WHERE res.res_ruleset_var_id = ? AND j.j_supplement_public = 1
    ');
  endif;
  $stmt->execute([$ruleset_var_id]);
  return array_map('intval', $stmt->fetchAll(PDO::FETCH_COLUMN));
}

// j_id du MJ (camp_j_id) de la campagne de contexte, 0 sans contexte. Voir les
// options 'camp_id' / 'pe_id' de getActiveResIds(). La campagne d'un personnage est
// sa campagne EN COURS (pe_camp_id) et la liaison doit être active (cp_actif = 1) :
// une campagne terminée n'ouvre plus le supplément de son MJ (cf. SP-PE5).
function mjCampagneContexte($db, array $opts): int {
  $camp_id = (int)($opts['camp_id'] ?? 0);
  if ($camp_id > 0):
    $stmt = $db->prepare('SELECT camp_j_id FROM dd_campagnes WHERE camp_id = ?');
    $stmt->execute([$camp_id]);
    return (int)$stmt->fetchColumn();
  endif;

  $pe_id = array_key_exists('pe_id', $opts)
           ? (int)$opts['pe_id']
           : (int)($_SESSION['last_pe_id'] ?? 0);
  if ($pe_id <= 0) return 0;

  $stmt = $db->prepare('
    SELECT camp.camp_j_id
      FROM dd_personnages pe
      JOIN dd_campagnes_personnages cp ON cp.cp_camp_id = pe.pe_camp_id
                                      AND cp.cp_pe_id   = pe.pe_id
                                      AND cp.cp_actif   = 1
      JOIN dd_campagnes camp ON camp.camp_id = pe.pe_camp_id
     WHERE pe.pe_id = ?
  ');
  $stmt->execute([$pe_id]);
  return (int)$stmt->fetchColumn();
}

// Génère des placeholders SQL pour un tableau d'ids
// Usage : $in = resIdsPlaceholders($ids); // retourne "?,?,?"
function resIdsPlaceholders(array $ids): string {
  return implode(',', array_fill(0, count($ids), '?'));
}

// Sources pour le contexte MJ d'une campagne (recherche de monstre des oppositions,
// rencontre, écran du MJ) : la règle commune, avec la campagne pour contexte — son
// MJ en apporte le supplément même s'il est privé et que l'admin le consulte.
function getActiveResIdsCampagne(PDO $db, int $camp_id, int $ruleset_var_id): array {
  return getActiveResIds($db, $ruleset_var_id, ['camp_id' => $camp_id]);
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

// Types de classe (dd_classe_type). Figés ici pour la même raison que les
// PROFINC_* ci-dessous : les littéraux clt_id se dispersaient dans le code.
//   1 Base / 2 Prestige / 3 PNJ  → ruleset DD3.5
//   4 Base / 5 Sous-classe       → ruleset DD2024
define('CLT_BASE_35',     1);
define('CLT_PRESTIGE',    2);  // DD3.5 — affichée en italique sur la fiche
define('CLT_PNJ',         3);
define('CLT_BASE_2024',   4);
define('CLT_SOUS_CLASSE', 5);  // DD2024 — rattachée à sa classe par cla_cla_id

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

// Mémorise le dernier personnage consulté en session. $ruleset_var_id (ruleset
// du personnage) : s'il diffère de celui de la session, le personnage est aussi
// rangé comme dernier consulté de SON ruleset, que la bascule du header
// retrouvera (SP-RB).
function setLastPersonnage(int $pe_id, ?int $ruleset_var_id = null) {
  // Une fiche consultée en popup (SP-CP13b) ne devient pas le contexte du header :
  // la page d'où elle est ouverte reste la page de travail.
  if (modePopup()) return;
  $_SESSION['last_pe_id'] = $pe_id;
  if ($ruleset_var_id !== null && $ruleset_var_id !== (int)($_SESSION['ruleset_var_id'] ?? 1)):
    memoriserPersonnageRuleset($pe_id, $ruleset_var_id);
  endif;
}

// Page affichée dans un popup (iframe) — paramètre GET popup=1 (SP-CP13b).
// header.php / footer.php omettent alors l'en-tête, le contexte et le pied du site.
function modePopup(): bool {
  return !empty($_GET['popup']);
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

// ------------------------------------------------------------
// PV max d'une opposition lus dans son bloc de stats (SP-CP11)
// ------------------------------------------------------------
// Première valeur qui suit « PV » / « Pv » / « Points de vie » : couvre « PV : 42
// chacun (5 DV) », « Pv 81 (18d8) », « PV 82 chacun (12 DV) ». 0 si rien n'est
// trouvé. Sert de valeur par défaut quand opp_pv_max n'est pas renseigné.
function pvMaxDepuisStats(?string $stats): int {
  if ($stats === null || $stats === '') return 0;
  return preg_match('/\b(?:pv|points de vie)\s*:?\s*(\d{1,4})\b/iu', strip_tags($stats), $m)
    ? (int)$m[1] : 0;
}

// ------------------------------------------------------------
// Onglets mémorisés des pages Campagnes (SP-CP10)
// ------------------------------------------------------------
// Chaque page de la hiérarchie (campagne, scénario, chapitre, rencontre) rouvre
// l'onglet que l'on y avait laissé. Mémoire de SESSION, par élément : la clé
// désigne l'élément (« re-12 »), et éventuellement un second niveau d'onglets
// (« re-12-opp » : fiche d'opposition sélectionnée). Écrite par la page
// elle-même (sous-pages de la campagne) ou par l'action AJAX memoriserOnglet.

// Clé admise : niveau-id, suivi d'un suffixe facultatif.
function cleOngletValide(string $cle): bool {
  return (bool)preg_match('/^(camp|sce|scc|re)-\d{1,10}(-[a-z]{1,10})?$/', $cle);
}

// Onglet mémorisé pour $cle, s'il figure parmi $permis ; $defaut sinon.
function ongletMemorise(string $cle, array $permis, string $defaut): string {
  $val = (string)($_SESSION['camp_onglets'][$cle] ?? '');
  return in_array($val, $permis, true) ? $val : $defaut;
}

function memoriserOnglet(string $cle, string $valeur): void {
  if (!cleOngletValide($cle) || !preg_match('/^[a-z0-9_-]{1,30}$/', $valeur)) return;
  $_SESSION['camp_onglets'][$cle] = $valeur;
}

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
// BASCULE DE RULESET (SP-RB)
// ============================================================
// Chaque ruleset garde son propre contexte de navigation (dernier personnage,
// chaîne campagne/scénario/chapitre/rencontre), mémorisé en session sous
// $_SESSION['contexte_ruleset'][ruleset_id]. Basculer met de côté le contexte
// du ruleset quitté et restaure celui du ruleset rejoint : l'aller-retour
// DD3.5 ⇄ DD2024 retrouve le personnage et la campagne laissés.

// Clés de session composant le contexte de navigation d'un ruleset.
const CONTEXTE_RULESET_CLES = [
  'last_pe_id',
  'last_camp_id', 'last_camp_nom',
  'last_sce_id',  'last_sce_nom',
  'last_scc_id',  'last_scc_nom',
  'last_re_id',   'last_re_nom',
];

// Mémorise un personnage comme dernier consulté de SON ruleset, sans toucher
// au contexte courant — appelée par setLastPersonnage() quand la fiche
// consultée appartient à un ruleset différent de celui de la session.
function memoriserPersonnageRuleset(int $pe_id, int $ruleset_var_id): void {
  $_SESSION['contexte_ruleset'][$ruleset_var_id]['last_pe_id'] = $pe_id;
}

// Bascule la session sur $nouveau ruleset : sauvegarde le contexte du ruleset
// quitté, purge, puis restaure le contexte mémorisé du ruleset rejoint après
// avoir vérifié que ses entités existent toujours (personnage supprimé,
// campagne supprimée entre-temps → niveau abandonné). Ne touche pas au
// ruleset par défaut du profil (dd_joueurs.j_default_ruleset_var_id).
function basculerRuleset(PDO $db, int $nouveau): void {
  $ancien = (int)($_SESSION['ruleset_var_id'] ?? 1);

  if ($ancien !== $nouveau):
    $sauvegarde = [];
    foreach (CONTEXTE_RULESET_CLES as $cle):
      if (isset($_SESSION[$cle])):
        $sauvegarde[$cle] = $_SESSION[$cle];
      endif;
    endforeach;

    // Un personnage d'un autre ruleset consulté pendant la session (fiche
    // ouverte depuis un lien) a déjà été rangé dans son propre ruleset par
    // setLastPersonnage() : il ne doit pas devenir le « dernier » du ruleset quitté.
    if (!empty($sauvegarde['last_pe_id'])):
      $stmt = $db->prepare('SELECT pe_ruleset_var_id FROM dd_personnages WHERE pe_id = ?');
      $stmt->execute([(int)$sauvegarde['last_pe_id']]);
      if ((int)$stmt->fetchColumn() !== $ancien):
        unset($sauvegarde['last_pe_id']);
        $pe_precedent = $_SESSION['contexte_ruleset'][$ancien]['last_pe_id'] ?? null;
        if ($pe_precedent):
          $sauvegarde['last_pe_id'] = $pe_precedent;
        endif;
      endif;
    endif;

    $_SESSION['contexte_ruleset'][$ancien] = $sauvegarde;
    resetContexteRuleset();

    $restaure = $_SESSION['contexte_ruleset'][$nouveau] ?? [];

    if (!empty($restaure['last_pe_id'])):
      $stmt = $db->prepare('SELECT 1 FROM dd_personnages WHERE pe_id = ? AND pe_ruleset_var_id = ?');
      $stmt->execute([(int)$restaure['last_pe_id'], $nouveau]);
      if ($stmt->fetchColumn()):
        $_SESSION['last_pe_id'] = (int)$restaure['last_pe_id'];
      endif;
    endif;

    if (!empty($restaure['last_camp_id'])):
      $stmt = $db->prepare('
        SELECT 1 FROM dd_campagnes
        WHERE  camp_id = ? AND camp_ruleset_var_id = ? AND camp_supprime = 0
      ');
      $stmt->execute([(int)$restaure['last_camp_id'], $nouveau]);
      if ($stmt->fetchColumn()):
        foreach (CONTEXTE_RULESET_CLES as $cle):
          if ($cle !== 'last_pe_id' && isset($restaure[$cle])):
            $_SESSION[$cle] = $restaure[$cle];
          endif;
        endforeach;
      endif;
    endif;
  endif;

  $_SESSION['ruleset_var_id'] = $nouveau;
  $_SESSION['rulesetRep']     = getRulesetRep($nouveau);
}

// Page équivalente à $retour (URI de la page courante) dans le ruleset qui
// vient d'être activé. Les pages de liste sont indépendantes du ruleset et sont
// rechargées telles quelles (sans leurs filtres, qui pointent souvent vers des
// entités du ruleset quitté). Les pages d'une entité rattachée à un ruleset
// (personnage, campagne, règle) se replient sur l'entité mémorisée du ruleset
// rejoint, ou à défaut sur l'index du module. Toute URI inattendue renvoie à
// l'accueil — la cible est reconstruite depuis BASE_URL, jamais reprise brute.
function pageEquivalenteRuleset(string $retour, int $ruleset_var_id): string {
  $accueil = BASE_URL . '/index.php';
  $chemin  = (string)parse_url($retour, PHP_URL_PATH);
  $prefixe = BASE_URL . '/';
  if (strpos($chemin, $prefixe) !== 0) return $accueil;

  $rel = substr($chemin, strlen($prefixe));
  if ($rel === '' || substr($rel, -1) === '/') $rel .= 'index.php';
  if (!preg_match('#^[a-z0-9_-]+(/[a-z0-9_-]+)*\.php$#', $rel)) return $accueil;
  if (strpos($rel, 'include/') === 0 || basename($rel) === 'enregistrement.php') return $accueil;
  if (!is_file(__DIR__ . '/../' . $rel)) return $accueil;

  $module = dirname($rel);
  $page   = basename($rel);

  // Personnage : sous-pages de la fiche → personnage mémorisé du ruleset.
  if ($module === 'personnages' && $page !== 'index.php'):
    $pe_id = getLastPersonnage();
    if ($page === 'objets.php') $page = 'possessions.php';
    return $pe_id > 0
      ? BASE_URL . '/personnages/' . $page . '?id=' . $pe_id
      : BASE_URL . '/personnages/index.php';
  endif;

  // Campagne : même niveau dans la chaîne mémorisée, ou le plus profond des
  // ancêtres disponibles, ou la liste.
  if ($module === 'campagnes' && $page !== 'index.php'):
    // Sous-pages de la campagne (SP-CP9) : même niveau que campagne.php,
    // placées avant elle pour que le repli tombe sur l'onglet Description.
    $niveaux = ['rencontre.php' => 're', 'chapitre.php' => 'scc', 'scenario.php' => 'sce',
                'campagne-personnages.php' => 'camp', 'campagne-scenarios.php' => 'camp',
                'campagne.php' => 'camp'];
    $depart  = array_search($page, array_keys($niveaux), true);
    if ($depart !== false):
      foreach (array_slice($niveaux, $depart, null, true) as $fichier => $prefixe_niv):
        $id = (int)($_SESSION['last_' . $prefixe_niv . '_id'] ?? 0);
        if ($id > 0) return BASE_URL . '/campagnes/' . $fichier . '?id=' . $id;
      endforeach;
    endif;
    return BASE_URL . '/campagnes/index.php';
  endif;

  // Règle : chaque règle appartient à un ruleset.
  if ($rel === 'regles/regle.php') return BASE_URL . '/regles/index.php';

  // Recherche dans les règles : le terme cherché vaut pour les deux rulesets.
  if ($rel === 'regles/recherche.php'):
    parse_str((string)parse_url($retour, PHP_URL_QUERY), $query);
    $q = trim((string)($query['q'] ?? ''));
    return BASE_URL . '/regles/recherche.php' . ($q !== '' ? '?q=' . rawurlencode($q) : '');
  endif;

  // Historiques : DD2024 uniquement.
  if ($rel === 'compendium/historiques.php' && $ruleset_var_id !== 2):
    return BASE_URL . '/compendium/index.php';
  endif;

  return BASE_URL . '/' . $rel;
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
// par ruleset). Ne gère pas sa propre transaction : appelée dans celle de
// l'enregistrement, ou seule (profil). Le supplément n'a pas à être « sélectionné » :
// getActiveResIds() inclut toujours celui de l'utilisateur courant (SP-RE).
function getOrCreateUserSupplement($db, int $j_id, int $ruleset_var_id): int {
  $res_id = getUserSupplementResId($db, $j_id, $ruleset_var_id);
  if ($res_id !== null) return $res_id;

  $stmt = $db->prepare('SELECT j_pseudo FROM dd_joueurs WHERE j_id = ?');
  $stmt->execute([$j_id]);
  $pseudo = $stmt->fetchColumn();
  $nom    = 'Supplément de ' . ($pseudo !== false ? $pseudo : 'utilisateur');

  // res_selection = 0 : un supplément n'entre jamais dans la liste des
  // ressources actives, son affichage est géré par getActiveResIds().
  $stmt = $db->prepare('
    INSERT INTO dd_ressources (res_nom, res_abreviation, res_selection, res_ruleset_var_id, res_j_id)
    VALUES (?, ?, 0, ?, ?)
  ');
  $stmt->execute([$nom, 'Supp.', $ruleset_var_id, $j_id]);
  return (int)$db->lastInsertId();
}

// Crée les suppléments d'un MJ, un par ruleset (DD3.5 et DD2024). Appelée quand
// l'utilisateur active la gestion de campagne dans son profil (SP-RE4, D-RE2).
function creerSupplementsMJ($db, int $j_id): void {
  foreach ([1, 2] as $ruleset_var_id):
    getOrCreateUserSupplement($db, $j_id, $ruleset_var_id);
  endforeach;
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
    // Entrée de supplément : seul son propriétaire peut la modifier, tant qu'il
    // est MJ (gestion de campagne active, D-RE2) ou gestionnaire du compendium
    return (int)($_SESSION['j_id'] ?? 0) === $res_j_id && canEditCompendium();
  }
  // Entrée officielle : réservée aux gestionnaires du compendium
  return canEditCompendiumOfficiel();
}


// ============================================================
// Contenu rattaché à une ressource (SP-AD3)
// Une ressource ne peut être supprimée que si toutes ces tables sont vides
// pour elle, contenu propre à une campagne compris. Liste unique, reprise par
// le contrôle de suppression, le panneau de détail et la liste admin.
// ============================================================

function contenuRessourceTables(): array {
  return [
    // 'id', 'nom' et 'detail' (SP-AD5) servent à lister les entrées d'une ressource
    // sur admin/ressource.php ; 'detail' = fiche de lecture sous include/ajax/detail-pp/.
    'nb_classes'     => ['table' => 'dd_classes',         'champ' => 'cla_res_id',  'label' => 'Classes',         'singulier' => 'classe',        'pluriel' => 'classes',         'id' => 'cla_id',  'nom' => 'cla_nom',  'detail' => 'classe.php'],
    'nb_races'       => ['table' => 'dd_races',           'champ' => 'ra_res_id',   'label' => 'Races',           'singulier' => 'race',          'pluriel' => 'races',           'id' => 'ra_id',   'nom' => 'ra_nom',   'detail' => 'race.php'],
    'nb_sorts'       => ['table' => 'dd_sorts',           'champ' => 'so_res_id',   'label' => 'Sorts',           'singulier' => 'sort',          'pluriel' => 'sorts',           'id' => 'so_id',   'nom' => 'so_nom',   'detail' => 'sort.php'],
    'nb_dons'        => ['table' => 'dd_dons',            'champ' => 'do_res_id',   'label' => 'Dons',            'singulier' => 'don',           'pluriel' => 'dons',            'id' => 'do_id',   'nom' => 'do_nom',   'detail' => 'don.php'],
    'nb_comp'        => ['table' => 'dd_competences',     'champ' => 'comp_res_id', 'label' => 'Compétences',     'singulier' => 'compétence',    'pluriel' => 'compétences',     'id' => 'comp_id', 'nom' => 'comp_nom', 'detail' => 'competence.php'],
    'nb_hist'        => ['table' => 'dd_historiques',     'champ' => 'hi_res_id',   'label' => 'Historiques',     'singulier' => 'historique',    'pluriel' => 'historiques',     'id' => 'hi_id',   'nom' => 'hi_nom',   'detail' => 'historique.php'],
    'nb_objets'      => ['table' => 'dd_objets_magiques', 'champ' => 'om_res_id',   'label' => 'Objets magiques', 'singulier' => 'objet magique', 'pluriel' => 'objets magiques', 'id' => 'om_id',   'nom' => 'om_nom',   'detail' => 'objet.php'],
    'nb_monstres'    => ['table' => 'dd_monstres',        'champ' => 'mo_res_id',   'label' => 'Monstres',        'singulier' => 'monstre',       'pluriel' => 'monstres',        'id' => 'mo_id',   'nom' => 'mo_nom',   'detail' => 'monstre.php'],
    'nb_equipements' => ['table' => 'dd_equipements',     'champ' => 'eqt_res_id',  'label' => 'Équipements',     'singulier' => 'équipement',    'pluriel' => 'équipements',     'id' => 'eqt_id',  'nom' => 'eqt_nom',  'detail' => 'equipement.php'],
    'nb_regles'      => ['table' => 'dd_regles',          'champ' => 'reg_res_id',  'label' => 'Règles',          'singulier' => 'règle',         'pluriel' => 'règles',          'id' => 'reg_id',  'nom' => 'reg_nom',  'detail' => 'regle.php'],
    'nb_tableaux'    => ['table' => 'dd_tableaux',        'champ' => 'tab_res_id',  'label' => 'Tableaux',        'singulier' => 'tableau',       'pluriel' => 'tableaux',        'id' => 'tab_id',  'nom' => 'tab_nom',  'detail' => 'tableau.php'],
    // Domaines divins DD3.5 (SP-AD6) : absents jusqu'ici du contrôle de suppression. Pas de fiche de lecture.
    'nb_domaines'    => ['table' => 'dd_domaines',        'champ' => 'do_res_id',   'label' => 'Domaines',        'singulier' => 'domaine',       'pluriel' => 'domaines',        'id' => 'do_id',   'nom' => 'do_nom',   'detail' => null],
  ];
}

// Sous-requête de comptage pour une liste dont dd_ressources porte l'alias res.
function contenuRessourceSql(string $cle): string {
  $t = contenuRessourceTables()[$cle];
  return '(SELECT COUNT(*) FROM ' . $t['table'] . ' WHERE ' . $t['champ'] . ' = res.res_id)';
}

// Retourne [cle => nombre]. Une erreur SQL remonte à l'appelant : un comptage
// impossible ne doit jamais passer pour une ressource vide.
function compterContenuRessource($db, int $res_id): array {
  $compteurs = [];
  foreach (contenuRessourceTables() as $cle => $t):
    $stmt = $db->prepare('SELECT COUNT(*) FROM ' . $t['table'] . ' WHERE ' . $t['champ'] . ' = ?');
    $stmt->execute([$res_id]);
    $compteurs[$cle] = (int)$stmt->fetchColumn();
  endforeach;
  return $compteurs;
}

// « 1 classe, 2 sorts » à partir de [cle => nombre] ; '' si tout est à zéro.
function decrireContenuRessource(array $compteurs): string {
  $details = [];
  foreach (contenuRessourceTables() as $cle => $t):
    $nb = (int)($compteurs[$cle] ?? 0);
    if ($nb > 0) $details[] = $nb . ' ' . ($nb > 1 ? $t['pluriel'] : $t['singulier']);
  endforeach;
  return implode(', ', $details);
}

// ============================================================
// Propriétés spéciales DD3.5 — jetons de restriction (SP-PO6)
// ============================================================
// om_restriction : jetons séparés par des espaces (sql/2026-11-06_sp-po6b_proprietes_speciales.sql).
// Emploi : l'objet de base doit satisfaire l'un des jetons présents ; dégâts : l'arme doit avoir
// au moins un des types cités. Lu par le formulaire d'objet et par le moteur de composition (SP-PO7).

function proprieteRestrictionsJetons(): array {
  return [
    'emploi' => [
      'cac'      => 'Arme de corps à corps',
      'distance' => 'Arme à distance',
      'jet'      => 'Arme de jet',
      'armure'   => 'Armure',
      'bouclier' => 'Bouclier',
      'ecu'      => 'Écu ou rondache',
    ],
    'degats' => [
      'tranchant'  => 'Tranchante',
      'perforant'  => 'Perforante',
      'contondant' => 'Contondante',
    ],
  ];
}

// Normalise une liste de jetons (tableau ou chaîne) : jetons connus seulement, ordre canonique.
// Retour : chaîne pour om_restriction, ou null si aucun jeton.
function proprieteRestrictionNormaliser($jetons): ?string {
  if (!is_array($jetons)) $jetons = preg_split('/\s+/', (string)$jetons, -1, PREG_SPLIT_NO_EMPTY);
  $retenus = [];
  foreach (proprieteRestrictionsJetons() as $groupe):
    foreach (array_keys($groupe) as $jeton):
      if (in_array($jeton, $jetons, true)) $retenus[] = $jeton;
    endforeach;
  endforeach;
  return $retenus ? implode(' ', $retenus) : null;
}
