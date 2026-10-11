<?php
// admin/deploiement/export-classes-lib.php — Export de classes vers la production (SP-XC)
//
// MODULE LOCAL UNIQUEMENT (dossier admin/deploiement/, jamais transféré).
//
// Produit une migration sql/AAAA-MM-JJ_xc-HHMMSS_<classes>.sql qui recopie en
// production les classes choisies avec toutes leurs données : fiche, table de
// progression, capacités spéciales, compétences de classe, sorts toujours
// préparés et, en option, liste de sorts. Le déploiement l'envoie par SFTP et
// la fait jouer par le serveur (jeton à usage unique) : même canal sécurisé
// que les migrations de structure (§6b).
//
// Le fichier ne contient AUCUN identifiant local. Chaque ligne est retrouvée en
// production par son nom (clés naturelles, D-XC1) :
//   ressource  : res_nom + ruleset
//   classe     : cla_nom + ruleset + classe parente, hors homebrew de campagne
//   sort       : so_nom + ruleset + ressource — un même sort DD3.5 existe en
//                version 3.0 et 3.5, sous deux livres distincts
//   compétence : comp_nom + ruleset
//   capacité   : celle de même nom déjà rattachée à la classe ; à défaut
//                nom + classe d'origine + texte identique, puis nom + classe
//                d'origine si ce couple est univoque ; à défaut, création
// Les identifiants de référentiel (types de classe, caractéristiques, profils
// d'incantation, cadences) sont recopiés tels quels : ces tables sont
// identiques des deux côtés.
//
// Règle d'écrasement (D-XC2) : la ligne dd_classes est créée si absente, puis
// mise à jour sur place — jamais supprimée, les personnages de la production y
// sont rattachés. Ses lignes liées sont supprimées puis réinsérées. Les
// capacités spéciales sont créées ou mises à jour (D-XC3). Le script est donc
// rejouable sans effet de bord.
//
// Garde-fous : toutes les vérifications sont jouées AVANT la première écriture.
// Une ressource, une classe parente, un sort ou une compétence absents de la
// production font échouer le script sur un message explicite, et le moteur
// s'arrête sans rien avoir écrit. Le déclencheur est un SET dont la
// sous-requête renvoie deux lignes (erreur 1242) : seul moyen portable, sans
// procédure stockée ni DELIMITER, de lever une erreur conditionnelle en SQL
// pur. Pas de DO : MariaDB y évalue la sous-requête sans lever l'erreur. Le
// message est placé en tête de l'instruction, là où le moteur en cite un
// extrait.

require_once __DIR__ . '/../../include/migrations.php';

const XC_RULESETS = [1 => 'DD3.5', 2 => 'DD2024'];

// Colonnes jamais recopiées telles quelles : identifiants et clés étrangères,
// recalculés en production.
const XC_EXCLUSIONS = [
  'dd_classes'             => ['cla_id', 'cla_res_id', 'cla_cla_id', 'cla_camp_id'],
  'dd_classe_niveau'       => ['cn_id', 'cn_cla_id'],
  'dd_capacites_speciales' => ['cap_id', 'cap_classe_initiale'],
  'dd_classe_capacite'     => ['cc_id', 'cc_cla_id', 'cc_cap_id'],
  'dd_classe_competence'   => ['ccomp_id', 'ccomp_cla_id', 'ccomp_comp_id'],
  'dd_classe_sort'         => ['cs_id', 'cs_cla_id', 'cs_so_id'],
  'dd_sortclasse'          => ['sc_id', 'sc_cla_id', 'sc_so_id'],
];

// Classes proposées à l'export pour un ruleset : hors homebrew de campagne (les
// campagnes n'ont pas les mêmes identifiants des deux côtés). Les sous-classes
// suivent leur classe de base.
function xcClassesExportables(PDO $db, int $ruleset): array {
  $stmt = $db->prepare('
    SELECT c.cla_id, c.cla_nom, c.cla_cla_id, p.cla_nom AS parent_nom, r.res_nom, t.clt_nom,
           (SELECT COUNT(*) FROM dd_classe_niveau   WHERE cn_cla_id = c.cla_id) AS nb_niveaux,
           (SELECT COUNT(*) FROM dd_classe_capacite WHERE cc_cla_id = c.cla_id) AS nb_capacites,
           (SELECT COUNT(*) FROM dd_sortclasse      WHERE sc_cla_id = c.cla_id) AS nb_sorts
    FROM   dd_classes c
    JOIN   dd_ressources r      ON r.res_id = c.cla_res_id
    LEFT JOIN dd_classes p      ON p.cla_id = c.cla_cla_id
    LEFT JOIN dd_classe_type t  ON t.clt_id = c.cla_clt_id
    WHERE  c.cla_ruleset_var_id = :ruleset AND c.cla_camp_id IS NULL
    ORDER  BY COALESCE(p.cla_nom, c.cla_nom), c.cla_cla_id IS NOT NULL, c.cla_nom
  ');
  $stmt->execute([':ruleset' => $ruleset]);
  return $stmt->fetchAll();
}

// Colonnes recopiées d'une table, lues dans le schéma local : une colonne
// ajoutée par une migration suit sans retoucher ce fichier.
function xcColonnes(PDO $db, string $table): array {
  $colonnes = [];
  foreach ($db->query('SHOW COLUMNS FROM ' . $table)->fetchAll() as $colonne) {
    if (!in_array($colonne['Field'], XC_EXCLUSIONS[$table], true)) {
      $colonnes[] = $colonne['Field'];
    }
  }
  return $colonnes;
}

function xcValeur(PDO $db, $valeur): string {
  if ($valeur === null) {
    return 'NULL';
  }
  if (is_int($valeur) || is_float($valeur)) {
    return (string)$valeur;
  }
  return $db->quote((string)$valeur);
}

function xcListe(PDO $db, array $valeurs): string {
  return implode(', ', array_map(fn($v) => xcValeur($db, $v), $valeurs));
}

// Instruction qui échoue si $condition est vraie en production, avec $message
// en tête de l'extrait cité par le moteur.
function xcGarde(PDO $db, string $message, string $condition): string {
  return 'SET @xc_garde := (SELECT ' . $db->quote('XC : ' . $message) . " UNION ALL SELECT '' FROM DUAL WHERE " . $condition . ');';
}

// Condition WHERE qui retrouve une classe en production par son nom.
// $parent : expression SQL de l'identifiant de la classe parente en
// production, ou null pour une classe sans parent.
function xcCleClasse(PDO $db, array $classe, ?string $parent): string {
  return 'cla_nom = ' . xcValeur($db, $classe['cla_nom'])
    . ' AND cla_ruleset_var_id = ' . (int)$classe['cla_ruleset_var_id']
    . ' AND cla_camp_id IS NULL AND '
    . ($parent === null ? 'IFNULL(cla_cla_id, 0) = 0' : 'cla_cla_id = ' . $parent);
}

// Condition WHERE qui retrouve un sort en production : nom, ruleset et livre
// ($sort['xc_res'] : variable de la ressource résolue en tête de script).
// Le nom est comparé octet par octet : la collation confond « Maths faciles »
// et « Maths Faciles », deux sorts distincts.
function xcCleSort(PDO $db, array $sort): string {
  return 'BINARY so_nom = ' . xcValeur($db, $sort['so_nom'])
    . ' AND so_ruleset_var_id = ' . (int)$sort['so_ruleset_var_id']
    . ' AND so_res_id = ' . $sort['xc_res'];
}

// Sélection du sort en production : parmi les homonymes exacts d'un même livre
// (« Faux-semblant » existe deux fois dans le MdJ 3.5), le rang local par
// identifiant désigne le même exemplaire qu'en production, où l'ordre
// d'insertion est le même.
function xcSelectSort(PDO $db, array $sort): string {
  return ' FROM dd_sorts WHERE ' . xcCleSort($db, $sort) . ' ORDER BY so_id LIMIT ' . (int)$sort['xc_rang'] . ', 1';
}

function xcLireClasse(PDO $db, int $cla_id): ?array {
  $stmt = $db->prepare('SELECT * FROM dd_classes WHERE cla_id = :id');
  $stmt->execute([':id' => $cla_id]);
  return $stmt->fetch() ?: null;
}

// Refuse une classe dont le nom ne la désigne pas sans ambiguïté en local :
// elle serait confondue avec sa jumelle en production.
function xcVerifierUnicite(PDO $db, array $classe): void {
  $stmt = $db->prepare('
    SELECT COUNT(*) FROM dd_classes
    WHERE  cla_nom = :nom AND cla_ruleset_var_id = :ruleset AND cla_camp_id IS NULL
      AND  IFNULL(cla_cla_id, 0) = :parent
  ');
  $stmt->execute([
    ':nom'     => $classe['cla_nom'],
    ':ruleset' => $classe['cla_ruleset_var_id'],
    ':parent'  => (int)$classe['cla_cla_id'],
  ]);
  if ((int)$stmt->fetchColumn() > 1) {
    throw new RuntimeException('Plusieurs classes « ' . $classe['cla_nom'] . ' » portent le même nom dans ce ruleset : renommer avant d\'exporter.');
  }
}

// Garde « tous ces noms existent en production ». Chaque groupe porte son
// filtre local et son équivalent en production (ressource résolue par
// variable). Le nombre attendu est compté en local par la même requête : même
// comparaison des deux côtés, donc mêmes homonymes absorbés par COUNT(DISTINCT).
// $champNom peut être une expression (« BINARY so_nom »).
function xcGardeNoms(PDO $db, string $message, string $table, string $champNom, array $groupes): array {
  $lignes = [];
  foreach ($groupes as $groupe) {
    $noms    = 'IN (' . xcListe($db, array_values(array_unique($groupe['noms']))) . ')';
    $compter = fn(string $filtre) => 'SELECT COUNT(DISTINCT ' . $champNom . ') FROM ' . $table
      . ' WHERE ' . $filtre . ' AND ' . $champNom . ' ' . $noms;
    $attendu  = (int)$db->query($compter($groupe['local']))->fetchColumn();
    $lignes[] = xcGarde($db, $message, '(' . $compter($groupe['prod']) . ') < ' . $attendu);
  }
  return $lignes;
}

// Génère le script d'export. $ids : classes cochées. $listeSorts : recopier
// aussi dd_sortclasse. Retour : ['sql' => …, 'classes' => [noms], 'resume' => [...]]
function xcGenerer(PDO $db, array $ids, bool $listeSorts): array {
  $ids = array_values(array_unique(array_filter(array_map('intval', $ids))));
  if (!$ids) {
    throw new RuntimeException('Aucune classe sélectionnée.');
  }

  // Classes cochées : les classes sans parent d'abord, pour que leurs
  // sous-classes les trouvent déjà créées.
  $classes = [];
  foreach ($ids as $id) {
    $classe = xcLireClasse($db, $id);
    if (!$classe || $classe['cla_camp_id'] !== null) {
      throw new RuntimeException('Classe ' . $id . ' introuvable ou propre à une campagne.');
    }
    xcVerifierUnicite($db, $classe);
    $classes[$id] = $classe;
  }
  uasort($classes, fn($a, $b) => [(int)($a['cla_cla_id'] > 0), $a['cla_nom']] <=> [(int)($b['cla_cla_id'] > 0), $b['cla_nom']]);

  // Variable SQL portant l'identifiant de production d'une classe.
  $varClasse = fn(int $id) => '@xc_cla_' . $id;

  $gardes      = [];
  $resolutions = [];
  $parents     = []; // id local → expression SQL de l'id du parent en production
  $ressources  = [];

  // Ressource (d'une classe ou d'un sort) : doit exister en production, où
  // elle est retrouvée par son nom. Retourne la variable SQL de son id.
  $varRessource = function (int $res_id) use ($db, &$ressources, &$resolutions): string {
    $var = '@xc_res_' . $res_id;
    if (!isset($ressources[$res_id])) {
      $stmt = $db->prepare('SELECT res_nom, res_ruleset_var_id FROM dd_ressources WHERE res_id = :id');
      $stmt->execute([':id' => $res_id]);
      $ressource = $stmt->fetch();
      if (!$ressource) {
        throw new RuntimeException('Ressource ' . $res_id . ' introuvable en local.');
      }
      $ressources[$res_id] = $ressource;
      $resolutions[] = 'SET ' . $var . ' := (SELECT MIN(res_id) FROM dd_ressources WHERE res_nom = '
        . xcValeur($db, $ressource['res_nom']) . ' AND res_ruleset_var_id = ' . (int)$ressource['res_ruleset_var_id'] . ');';
      $resolutions[] = xcGarde($db, 'ressource absente en production : ' . $ressource['res_nom'], $var . ' IS NULL');
    }
    return $var;
  };

  foreach ($classes as $id => $classe) {
    $varRessource((int)$classe['cla_res_id']);

    // Parent d'une sous-classe : exporté avec elle, ou déjà en production.
    $parent_id = (int)$classe['cla_cla_id'];
    if ($parent_id === 0) {
      $parents[$id] = null;
    } elseif (isset($classes[$parent_id])) {
      $parents[$id] = $varClasse($parent_id);
    } else {
      $parent = xcLireClasse($db, $parent_id);
      if (!$parent || (int)$parent['cla_cla_id'] > 0) {
        throw new RuntimeException('Classe parente de « ' . $classe['cla_nom'] . ' » introuvable ou elle-même sous-classe.');
      }
      $var = '@xc_par_' . $parent_id;
      $parents[$id] = $var;
      $resolutions[] = 'SET ' . $var . ' := (SELECT MIN(cla_id) FROM dd_classes WHERE ' . xcCleClasse($db, $parent, null) . ');';
      $resolutions[] = xcGarde($db, 'classe parente absente en production : ' . $parent['cla_nom'], $var . ' IS NULL');
    }
  }

  // --- Lecture des lignes liées, et gardes sur les sorts et compétences ------
  $colsNiveau = xcColonnes($db, 'dd_classe_niveau');
  $colsCap    = xcColonnes($db, 'dd_capacites_speciales');
  $colsCc     = xcColonnes($db, 'dd_classe_capacite');
  $colsComp   = xcColonnes($db, 'dd_classe_competence');
  $colsCs     = xcColonnes($db, 'dd_classe_sort');
  $colsSc     = xcColonnes($db, 'dd_sortclasse');

  $donnees = [];
  foreach ($classes as $id => $classe) {
    $stmt = $db->prepare('SELECT * FROM dd_classe_niveau WHERE cn_cla_id = :id ORDER BY cn_niveau');
    $stmt->execute([':id' => $id]);
    $niveaux = $stmt->fetchAll();

    $stmt = $db->prepare('
      SELECT cc.*, cap.*, k.cla_id AS ci_id
      FROM   dd_classe_capacite cc
      JOIN   dd_capacites_speciales cap ON cap.cap_id = cc.cc_cap_id
      LEFT JOIN dd_classes k ON k.cla_id = cap.cap_classe_initiale
      WHERE  cc.cc_cla_id = :id
      ORDER  BY cc.cc_niveau, cap.cap_nom
    ');
    $stmt->execute([':id' => $id]);
    $capacites = $stmt->fetchAll();

    $stmt = $db->prepare('
      SELECT ccomp.*, comp.comp_nom, comp.comp_ruleset_var_id
      FROM   dd_classe_competence ccomp
      JOIN   dd_competences comp ON comp.comp_id = ccomp.ccomp_comp_id
      WHERE  ccomp.ccomp_cla_id = :id
      ORDER  BY comp.comp_nom
    ');
    $stmt->execute([':id' => $id]);
    $competences = $stmt->fetchAll();

    $stmt = $db->prepare('
      SELECT cs.*, so.so_id, so.so_nom, so.so_ruleset_var_id, so.so_res_id
      FROM   dd_classe_sort cs
      JOIN   dd_sorts so ON so.so_id = cs.cs_so_id
      WHERE  cs.cs_cla_id = :id
      ORDER  BY cs.cs_niveau, so.so_nom
    ');
    $stmt->execute([':id' => $id]);
    $sortsPrepares = $stmt->fetchAll();

    $listeDeSorts = [];
    if ($listeSorts) {
      $stmt = $db->prepare('
        SELECT sc.*, so.so_id, so.so_nom, so.so_ruleset_var_id, so.so_res_id
        FROM   dd_sortclasse sc
        JOIN   dd_sorts so ON so.so_id = sc.sc_so_id
        WHERE  sc.sc_cla_id = :id
        ORDER  BY sc.sc_niveau, so.so_nom
      ');
      $stmt->execute([':id' => $id]);
      $listeDeSorts = $stmt->fetchAll();
    }

    // Deux capacités distinctes de même nom dans une même classe seraient
    // confondues en production, où elles sont retrouvées par leur nom.
    $cles = [];
    foreach ($capacites as $cap) {
      $cle = mb_strtolower($cap['cap_nom']);
      if (isset($cles[$cle]) && $cles[$cle] !== (int)$cap['cap_id']) {
        throw new RuntimeException('Deux capacités « ' . $cap['cap_nom'] . ' » distinctes dans « ' . $classe['cla_nom'] . ' » : fusionner ou renommer avant d\'exporter.');
      }
      $cles[$cle] = (int)$cap['cap_id'];
    }

    // Sorts : un même nom existe souvent dans plusieurs livres (versions 3.0
    // et 3.5 en DD3.5), la ressource fait donc partie de la clé. Un sort sans
    // livre (so_res_id = 0, 73 sorts DD3.5 hérités de la v1) garde sa valeur
    // telle quelle : il n'y a pas de nom à retrouver.
    $exprRes = function (array $sort) use ($db, $varRessource): string {
      $stmt = $db->prepare('SELECT COUNT(*) FROM dd_ressources WHERE res_id = :id');
      $stmt->execute([':id' => (int)$sort['so_res_id']]);
      return (int)$stmt->fetchColumn() > 0 ? $varRessource((int)$sort['so_res_id']) : (string)(int)$sort['so_res_id'];
    };
    $rang = $db->prepare('
      SELECT COUNT(*) FROM dd_sorts
      WHERE  BINARY so_nom = :nom AND so_ruleset_var_id = :ruleset AND so_res_id = :res AND so_id < :id
    ');
    foreach ([&$sortsPrepares, &$listeDeSorts] as &$liste) {
      foreach ($liste as &$sort) {
        $sort['xc_res'] = $exprRes($sort);
        $rang->execute([':nom' => $sort['so_nom'], ':ruleset' => $sort['so_ruleset_var_id'], ':res' => $sort['so_res_id'], ':id' => $sort['so_id']]);
        $sort['xc_rang'] = (int)$rang->fetchColumn();
      }
      unset($sort);
    }
    unset($liste);

    $sorts = [];
    foreach (array_merge($sortsPrepares, $listeDeSorts) as $sort) {
      $cle = (int)$sort['so_ruleset_var_id'] . '|' . (int)$sort['so_res_id'];
      $sorts[$cle] ??= [
        'local' => 'so_ruleset_var_id = ' . (int)$sort['so_ruleset_var_id'] . ' AND so_res_id = ' . (int)$sort['so_res_id'],
        'prod'  => 'so_ruleset_var_id = ' . (int)$sort['so_ruleset_var_id'] . ' AND so_res_id = ' . $sort['xc_res'],
        'noms'  => [],
      ];
      $sorts[$cle]['noms'][] = $sort['so_nom'];
    }
    if ($sorts) {
      $gardes = array_merge($gardes, xcGardeNoms($db, 'sort(s) absent(s) en production pour ' . $classe['cla_nom'], 'dd_sorts', 'BINARY so_nom', $sorts));
    }
    $comps = [];
    foreach ($competences as $comp) {
      $filtre = 'comp_ruleset_var_id = ' . (int)$comp['comp_ruleset_var_id'];
      $comps[$filtre] ??= ['local' => $filtre, 'prod' => $filtre, 'noms' => []];
      $comps[$filtre]['noms'][] = $comp['comp_nom'];
    }
    if ($comps) {
      $gardes = array_merge($gardes, xcGardeNoms($db, 'compétence(s) absente(s) en production pour ' . $classe['cla_nom'], 'dd_competences', 'comp_nom', $comps));
    }

    $donnees[$id] = compact('niveaux', 'capacites', 'competences', 'sortsPrepares', 'listeDeSorts');
  }

  // --- Écriture du script ----------------------------------------------------
  $noms = array_map(fn($c) => $c['cla_nom'] . ' (' . (XC_RULESETS[(int)$c['cla_ruleset_var_id']] ?? '?') . ')', $classes);
  $sql  = [];
  $sql[] = '-- Export de classes (SP-XC) — généré le ' . date('Y-m-d H:i') . ' depuis la base locale.';
  $sql[] = '-- Classes : ' . implode(', ', $noms);
  $sql[] = '-- Liste de sorts (dd_sortclasse) : ' . ($listeSorts ? 'incluse' : 'non incluse, laissée intacte en production');
  $sql[] = '-- Rejouable : chaque ligne est retrouvée par son nom ; la classe est mise à jour sur place,';
  $sql[] = '-- ses lignes liées sont remplacées. Aucune écriture si un garde-fou échoue.';
  $sql[] = '-- Ne pas modifier : fichier généré par admin/deploiement/export-classes.php.';
  $sql[] = '';
  $sql[] = '-- 1. Garde-fous et résolution des références (aucune écriture)';
  $sql   = array_merge($sql, $resolutions, $gardes);
  $sql[] = '';

  // Classes : création si absente, puis mise à jour sur place.
  $colsClasse = xcColonnes($db, 'dd_classes');
  $sql[] = '-- 2. Fiches des classes';
  foreach ($classes as $id => $classe) {
    $var    = $varClasse($id);
    $cle    = xcCleClasse($db, $classe, $parents[$id]);
    $res    = '@xc_res_' . (int)$classe['cla_res_id'];
    // Sans parent : valeur locale reprise telle quelle (0 en DD3.5, NULL en DD2024).
    $parent = $parents[$id] ?? xcValeur($db, $classe['cla_cla_id']);
    $sql[] = '-- ' . $classe['cla_nom'];
    $sql[] = 'SET ' . $var . ' := (SELECT MIN(cla_id) FROM dd_classes WHERE ' . $cle . ');';
    $sql[] = 'INSERT INTO dd_classes (cla_nom, cla_ruleset_var_id, cla_res_id, cla_cla_id, cla_camp_id) SELECT '
      . xcValeur($db, $classe['cla_nom']) . ', ' . (int)$classe['cla_ruleset_var_id'] . ', ' . $res . ', ' . $parent
      . ', NULL FROM DUAL WHERE ' . $var . ' IS NULL;';
    $sql[] = 'SET ' . $var . ' := (SELECT MIN(cla_id) FROM dd_classes WHERE ' . $cle . ');';
    $affectations = array_map(fn($col) => $col . ' = ' . xcValeur($db, $classe[$col]), $colsClasse);
    $affectations[] = 'cla_res_id = ' . $res;
    $affectations[] = 'cla_cla_id = ' . $parent;
    $affectations[] = 'cla_camp_id = NULL';
    $sql[] = 'UPDATE dd_classes SET ' . implode(', ', $affectations) . ' WHERE cla_id = ' . $var . ';';
  }
  $sql[] = '';

  $sql[] = '-- 3. Données liées';
  $ambigue = $db->prepare('
    SELECT COUNT(*) FROM dd_capacites_speciales
    WHERE  cap_nom = :nom AND IFNULL(cap_classe_initiale, 0) = :ci
  ');
  $resume = [];
  foreach ($classes as $id => $classe) {
    $var = $varClasse($id);
    $d   = $donnees[$id];
    $sql[] = '-- ' . $classe['cla_nom'];

    // Table de progression
    $sql[] = 'DELETE FROM dd_classe_niveau WHERE cn_cla_id = ' . $var . ';';
    if ($d['niveaux']) {
      $lignes = array_map(fn($n) => '(' . $var . ', ' . xcListe($db, array_map(fn($col) => $n[$col], $colsNiveau)) . ')', $d['niveaux']);
      $sql[] = 'INSERT INTO dd_classe_niveau (cn_cla_id, ' . implode(', ', $colsNiveau) . ") VALUES\n  " . implode(",\n  ", $lignes) . ';';
    }

    // Capacités spéciales : retrouvées, créées ou mises à jour, PUIS rattachées.
    // Clé de production, dans l'ordre : la capacité de même nom déjà rattachée
    // à cette classe (lue avant la suppression des liens) ; nom + classe
    // d'origine + texte identique (capacité partagée avec une autre classe) ;
    // nom + classe d'origine, si ce couple désigne une seule capacité en local
    // (« Armes et armures » existe en 5 exemplaires sans origine) ; à défaut,
    // création.
    $parCapacite = [];
    foreach ($d['capacites'] as $cap) {
      $parCapacite[(int)$cap['cap_id']][] = $cap;
    }
    foreach ($parCapacite as $cap_id => $liens) {
      $cap    = $liens[0];
      $varCap = '@xc_cap_' . $cap_id;
      $ci     = (int)$cap['ci_id'];
      if ($ci === 0) {
        $exprCi = 'NULL';
      } elseif (isset($classes[$ci])) {
        $exprCi = $varClasse($ci);
      } else {
        $origine    = xcLireClasse($db, $ci);
        $exprParent = null;
        if ((int)$origine['cla_cla_id'] > 0) {
          $grandParent = xcLireClasse($db, (int)$origine['cla_cla_id']);
          $exprParent  = $grandParent
            ? '(SELECT MIN(cla_id) FROM dd_classes WHERE ' . xcCleClasse($db, $grandParent, null) . ')'
            : 'NULL';
        }
        $exprCi = '(SELECT MIN(cla_id) FROM dd_classes WHERE ' . xcCleClasse($db, $origine, $exprParent) . ')';
      }
      $nom = xcValeur($db, $cap['cap_nom']);
      $sql[] = 'SET @xc_ci := ' . $exprCi . ';';
      $sql[] = 'SET ' . $varCap . ' := (SELECT MIN(cap.cap_id) FROM dd_capacites_speciales cap'
        . ' JOIN dd_classe_capacite cc ON cc.cc_cap_id = cap.cap_id WHERE cc.cc_cla_id = ' . $var . ' AND cap.cap_nom = ' . $nom . ');';
      $sql[] = 'SET ' . $varCap . ' := IFNULL(' . $varCap . ', (SELECT MIN(cap_id) FROM dd_capacites_speciales'
        . ' WHERE cap_nom = ' . $nom . ' AND IFNULL(cap_classe_initiale, 0) = IFNULL(@xc_ci, 0)'
        . ' AND BINARY IFNULL(cap_description, \'\') = ' . xcValeur($db, (string)$cap['cap_description']) . '));';
      $ambigue->execute([':nom' => $cap['cap_nom'], ':ci' => (int)$cap['cap_classe_initiale']]);
      if ((int)$ambigue->fetchColumn() === 1) {
        $sql[] = 'SET ' . $varCap . ' := IFNULL(' . $varCap . ', (SELECT MIN(cap_id) FROM dd_capacites_speciales'
          . ' WHERE cap_nom = ' . $nom . ' AND IFNULL(cap_classe_initiale, 0) = IFNULL(@xc_ci, 0)));';
      }
      $sql[] = 'INSERT INTO dd_capacites_speciales (' . implode(', ', $colsCap) . ', cap_classe_initiale) SELECT '
        . xcListe($db, array_map(fn($col) => $cap[$col], $colsCap)) . ', @xc_ci FROM DUAL WHERE ' . $varCap . ' IS NULL;';
      // LAST_INSERT_ID() n'est retenu que si la capacité restait introuvable,
      // c'est-à-dire si l'INSERT ci-dessus vient d'avoir lieu.
      $sql[] = 'SET ' . $varCap . ' := IFNULL(' . $varCap . ', LAST_INSERT_ID());';
      $sql[] = 'UPDATE dd_capacites_speciales SET '
        . implode(', ', array_map(fn($col) => $col . ' = ' . xcValeur($db, $cap[$col]), $colsCap))
        . ', cap_classe_initiale = @xc_ci WHERE cap_id = ' . $varCap . ';';
    }
    $sql[] = 'DELETE FROM dd_classe_capacite WHERE cc_cla_id = ' . $var . ';';
    foreach ($parCapacite as $cap_id => $liens) {
      $lignes = array_map(fn($l) => '(' . $var . ', @xc_cap_' . $cap_id . ', ' . xcListe($db, array_map(fn($col) => $l[$col], $colsCc)) . ')', $liens);
      $sql[] = 'INSERT INTO dd_classe_capacite (cc_cla_id, cc_cap_id, ' . implode(', ', $colsCc) . ') VALUES ' . implode(', ', $lignes) . ';';
    }

    // Compétences de classe
    $sql[] = 'DELETE FROM dd_classe_competence WHERE ccomp_cla_id = ' . $var . ';';
    foreach ($d['competences'] as $comp) {
      $sql[] = 'INSERT INTO dd_classe_competence (ccomp_cla_id, ccomp_comp_id, ' . implode(', ', $colsComp) . ') SELECT '
        . $var . ', MIN(comp_id), ' . xcListe($db, array_map(fn($col) => $comp[$col], $colsComp))
        . ' FROM dd_competences WHERE comp_nom = ' . xcValeur($db, $comp['comp_nom'])
        . ' AND comp_ruleset_var_id = ' . (int)$comp['comp_ruleset_var_id'] . ' HAVING MIN(comp_id) IS NOT NULL;';
    }

    // Sorts toujours préparés (DD2024)
    $sql[] = 'DELETE FROM dd_classe_sort WHERE cs_cla_id = ' . $var . ';';
    foreach ($d['sortsPrepares'] as $sort) {
      $sql[] = 'INSERT INTO dd_classe_sort (cs_cla_id, cs_so_id, ' . implode(', ', $colsCs) . ') SELECT '
        . $var . ', so_id, ' . xcListe($db, array_map(fn($col) => $sort[$col], $colsCs)) . xcSelectSort($db, $sort) . ';';
    }

    // Liste de sorts, sur option : sans elle, celle de la production reste intacte.
    if ($listeSorts) {
      $sql[] = 'DELETE FROM dd_sortclasse WHERE sc_cla_id = ' . $var . ';';
      foreach ($d['listeDeSorts'] as $sort) {
        $sql[] = 'INSERT INTO dd_sortclasse (sc_cla_id, sc_so_id, ' . implode(', ', $colsSc) . ') SELECT '
          . $var . ', so_id, ' . xcListe($db, array_map(fn($col) => $sort[$col], $colsSc)) . xcSelectSort($db, $sort) . ';';
      }
    }
    $sql[] = '';

    $resume[] = [
      'nom'         => $noms[$id],
      'niveaux'     => count($d['niveaux']),
      'capacites'   => count($parCapacite),
      'competences' => count($d['competences']),
      'prepares'    => count($d['sortsPrepares']),
      'liste'       => $listeSorts ? count($d['listeDeSorts']) : null,
    ];
  }

  return ['sql' => implode("\n", $sql), 'classes' => array_values(array_map(fn($c) => $c['cla_nom'], $classes)), 'resume' => $resume];
}

// Nom de la migration : daté du jour, préfixé « xc-HHMMSS » pour passer après
// les migrations de structure déjà écrites ce jour-là (ordre alphabétique),
// suivi des premières classes en ASCII.
function xcNomFichier(array $classes): string {
  $morceaux = [];
  foreach (array_slice($classes, 0, 3) as $nom) {
    $ascii = preg_replace('/&([a-z]{1,2})(?:acute|grave|circ|uml|cedil|tilde|ring|slash|lig);/i', '$1', htmlentities($nom, ENT_QUOTES, 'UTF-8'));
    $morceaux[] = trim(preg_replace('/[^a-z0-9]+/', '-', strtolower(html_entity_decode($ascii, ENT_QUOTES, 'UTF-8'))), '-');
  }
  $slug = substr(implode('_', array_filter($morceaux)), 0, 60);
  if (count($classes) > 3) {
    $slug .= '_etc';
  }
  return date('Y-m-d') . '_xc-' . date('His') . '_' . ($slug !== '' ? $slug : 'classes') . '.sql';
}

// Écrit la migration dans sql/ et la déclare appliquée sur la base locale, dont
// elle reproduit le contenu : seule la production la jouera. Retourne le nom.
function xcEcrireMigration(PDO $db, array $export): string {
  $nom    = xcNomFichier($export['classes']);
  $chemin = migrationsDossier() . '/' . $nom;
  if (!preg_match(MIGRATIONS_MOTIF, $nom)) {
    throw new RuntimeException('Nom de migration invalide : ' . $nom);
  }
  if (is_file($chemin)) {
    throw new RuntimeException('La migration ' . $nom . ' existe déjà : réessayer dans une seconde.');
  }
  if (file_put_contents($chemin, $export['sql'] . "\n", LOCK_EX) === false) {
    throw new RuntimeException('Impossible d\'écrire ' . $chemin . '.');
  }
  migrationsMarquer($db, $nom);
  return $nom;
}
