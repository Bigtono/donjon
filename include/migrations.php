<?php
// include/migrations.php — Moteur de migrations SQL (SP-DP5)
//
// Une migration est un fichier sql/AAAA-MM-JJ_*.sql. Le moteur les joue dans
// l'ordre alphabétique de leur nom (donc chronologique), une seule fois
// chacune : dd_migrations garde la trace de celles qui sont passées.
//
// Le même code tourne en local et en production. En production, il est appelé
// par le déployeur (admin/migrations-auto.php) ou depuis l'écran
// admin/migrations.php ; la base OVH refuse toute connexion venue de
// l'extérieur, le SQL ne peut donc être exécuté que par le serveur lui-même.
//
// Chaque script est découpé en instructions (migrationsInstructions()), jouées
// une à une par query() + closeCursor(). Pas de PDO::exec() sur le script
// entier : dès qu'une instruction renvoie un résultat (SELECT, SHOW, OPTIMIZE…),
// exec() rend la main sans lire la suite, laisse passer les erreurs des
// instructions suivantes et bloque la connexion (erreur 2014).
//
// MySQL n'annule pas un ALTER TABLE : une migration qui échoue en cours de
// route reste partiellement appliquée. Le moteur s'arrête alors à la première
// erreur, désigne l'instruction fautive, et ne joue pas les migrations suivantes.

const MIGRATIONS_MOTIF = '/^\d{4}-\d{2}-\d{2}_[A-Za-z0-9._-]+\.sql$/';

// Statuts d'une ligne de dd_migrations. « en_attente » n'est jamais stocké :
// c'est l'état d'un fichier sans ligne.
const MIGRATION_EXECUTEE = 'executee';  // jouée par le moteur
const MIGRATION_REFERENCE = 'reference'; // antérieure au moteur (référence initiale)
const MIGRATION_MARQUEE  = 'marquee';   // jouée à la main, déclarée depuis l'écran admin

function migrationsDossier(): string {
  return dirname(__DIR__) . '/sql';
}

// Crée dd_migrations au premier appel et y inscrit la référence initiale
// (include/migrations-reference.php). Sans cette référence, le moteur
// rejouerait les 37 migrations antérieures, dont la plupart échoueraient.
function migrationsAssurerTable(PDO $db): void {
  static $fait = false;
  if ($fait) {
    return;
  }
  $db->exec("
    CREATE TABLE IF NOT EXISTS dd_migrations (
      mig_id       INT UNSIGNED NOT NULL AUTO_INCREMENT,
      mig_fichier  VARCHAR(190) NOT NULL COMMENT 'Nom du fichier dans sql/',
      mig_checksum CHAR(64)     NOT NULL COMMENT 'SHA-256 du fichier au moment de son application',
      mig_statut   VARCHAR(12)  NOT NULL COMMENT 'executee | reference | marquee',
      mig_date     DATETIME     NOT NULL,
      mig_duree_ms INT UNSIGNED          DEFAULT NULL COMMENT 'Durée d''exécution (statut executee)',
      PRIMARY KEY (mig_id),
      UNIQUE KEY uk_mig_fichier (mig_fichier)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
  ");

  $nb = (int)$db->query('SELECT COUNT(*) FROM dd_migrations')->fetchColumn();
  if ($nb === 0) {
    $reference = require __DIR__ . '/migrations-reference.php';
    $stmt = $db->prepare('
      INSERT IGNORE INTO dd_migrations (mig_fichier, mig_checksum, mig_statut, mig_date)
      VALUES (:fichier, :checksum, :statut, NOW())
    ');
    foreach ($reference as $fichier => $checksum) {
      $stmt->execute([':fichier' => $fichier, ':checksum' => $checksum, ':statut' => MIGRATION_REFERENCE]);
    }
  }
  $fait = true;
}

// Fichiers de migration présents sur le disque, triés : nom => chemin complet.
// Les autres fichiers de sql/ (dumps, seeds, imports, scripts) sont ignorés.
function migrationsFichiers(): array {
  $fichiers = [];
  foreach (scandir(migrationsDossier()) ?: [] as $nom) {
    $chemin = migrationsDossier() . '/' . $nom;
    if (preg_match(MIGRATIONS_MOTIF, $nom) && is_file($chemin)) {
      $fichiers[$nom] = $chemin;
    }
  }
  ksort($fichiers, SORT_STRING);
  return $fichiers;
}

// État de chaque migration présente sur le disque, dans l'ordre d'application.
// 'modifiee' signale un fichier retouché après son application : il n'est
// jamais rejoué, mais l'écart doit se voir.
function migrationsEtat(PDO $db): array {
  migrationsAssurerTable($db);
  $lignes = $db->query('
    SELECT mig_fichier, mig_checksum, mig_statut, mig_date, mig_duree_ms
    FROM   dd_migrations
  ')->fetchAll(PDO::FETCH_UNIQUE | PDO::FETCH_ASSOC);

  $etat = [];
  foreach (migrationsFichiers() as $nom => $chemin) {
    $checksum = hash_file('sha256', $chemin);
    $ligne    = $lignes[$nom] ?? null;
    $etat[] = [
      'fichier'  => $nom,
      'statut'   => $ligne ? $ligne['mig_statut'] : 'en_attente',
      'date'     => $ligne['mig_date'] ?? null,
      'duree_ms' => $ligne['mig_duree_ms'] ?? null,
      'modifiee' => $ligne !== null && !hash_equals($ligne['mig_checksum'], $checksum),
    ];
  }
  return $etat;
}

// Découpe un script SQL en instructions, commentaires retirés. Comprend les
// chaînes '…' et "…" (échappement \ et guillemet doublé), les identifiants
// `…`, et les commentaires « -- » (suivi d'un blanc, comme pour MySQL), « # »
// et /* … */. Les commentaires exécutables /*! … */ et les indications
// /*+ … */ sont conservés : MySQL les interprète.
// Retirer les commentaires n'est pas cosmétique : PDO cherche des marqueurs
// :nom dans le texte qu'on lui passe, et « 10:30 » dans un commentaire en
// serait un.
function migrationsInstructions(string $sql): array {
  $instructions = [];
  $courante     = '';
  $n            = strlen($sql);

  for ($i = 0; $i < $n; $i++) {
    $c       = $sql[$i];
    $suivant = $sql[$i + 1] ?? '';

    // Chaîne ou identifiant : recopié tel quel jusqu'au délimiteur fermant.
    if ($c === "'" || $c === '"' || $c === '`') {
      $courante .= $c;
      for ($i++; $i < $n; $i++) {
        $courante .= $sql[$i];
        if ($sql[$i] === '\\' && $c !== '`') {
          if ($i + 1 < $n) {
            $courante .= $sql[++$i]; // caractère échappé
          }
          continue;
        }
        if ($sql[$i] === $c) {
          if (($sql[$i + 1] ?? '') === $c) {
            $courante .= $sql[++$i]; // délimiteur doublé
            continue;
          }
          break;
        }
      }
      continue;
    }

    if ($c === '#' || ($c === '-' && $suivant === '-' && ($i + 2 >= $n || ctype_space($sql[$i + 2])))) {
      $fin = strpos($sql, "\n", $i);
      $i   = $fin === false ? $n : $fin;
      $courante .= "\n";
      continue;
    }

    if ($c === '/' && $suivant === '*') {
      $fin    = strpos($sql, '*/', $i + 2);
      $fin    = $fin === false ? $n : $fin + 2;
      $marque = $sql[$i + 2] ?? '';
      $courante .= ($marque === '!' || $marque === '+') ? substr($sql, $i, $fin - $i) : ' ';
      $i = $fin - 1;
      continue;
    }

    if ($c === ';') {
      if (trim($courante) !== '') {
        $instructions[] = trim($courante);
      }
      $courante = '';
      continue;
    }

    $courante .= $c;
  }

  if (trim($courante) !== '') {
    $instructions[] = trim($courante);
  }
  return $instructions;
}

// Joue une migration et l'inscrit dans dd_migrations si elle a réussi.
// Retour : ['ok' => bool, 'fichier' => …, 'duree_ms' => … | 'erreur' => …]
function migrationsAppliquer(PDO $db, string $nom): array {
  $chemin = migrationsDossier() . '/' . $nom;
  if (!preg_match(MIGRATIONS_MOTIF, $nom) || !is_file($chemin)) {
    return ['ok' => false, 'fichier' => $nom, 'erreur' => 'Fichier de migration introuvable.'];
  }

  $brut     = file_get_contents($chemin);
  $checksum = hash('sha256', $brut);
  $sql      = preg_replace('/^\xEF\xBB\xBF/', '', $brut); // BOM UTF-8
  // DELIMITER est une commande du client mysql, inconnue du serveur : un
  // script qui en contient ne peut pas passer par PDO.
  if (preg_match('/^\s*DELIMITER\s/mi', $sql)) {
    return [
      'ok'      => false,
      'fichier' => $nom,
      'erreur'  => 'Le script contient DELIMITER (commande du client mysql) : à appliquer via phpMyAdmin, puis à marquer comme appliqué.',
    ];
  }

  $instructions = migrationsInstructions($sql);
  $debut        = hrtime(true);
  foreach ($instructions as $rang => $instruction) {
    try {
      $db->query($instruction)->closeCursor();
    } catch (PDOException $e) {
      $extrait = mb_substr(preg_replace('/\s+/', ' ', $instruction), 0, 80);
      return [
        'ok'      => false,
        'fichier' => $nom,
        'erreur'  => 'instruction ' . ($rang + 1) . '/' . count($instructions) . ' « ' . $extrait . ' » : ' . $e->getMessage(),
      ];
    }
  }
  $duree = (int)round((hrtime(true) - $debut) / 1e6);

  $stmt = $db->prepare('
    INSERT INTO dd_migrations (mig_fichier, mig_checksum, mig_statut, mig_date, mig_duree_ms)
    VALUES (:fichier, :checksum, :statut, NOW(), :duree)
  ');
  $stmt->execute([
    ':fichier'  => $nom,
    ':checksum' => $checksum,
    ':statut'   => MIGRATION_EXECUTEE,
    ':duree'    => $duree,
  ]);
  return ['ok' => true, 'fichier' => $nom, 'duree_ms' => $duree];
}

// Joue toutes les migrations en attente, dans l'ordre, et s'arrête à la
// première erreur : les suivantes supposent presque toujours la précédente.
// Retour : ['ok' => bool, 'appliquees' => [...], 'echec' => [...] | null,
//           'modifiees' => [noms des fichiers retouchés après application]]
function migrationsAppliquerEnAttente(PDO $db): array {
  $etat       = migrationsEtat($db);
  $appliquees = [];
  $modifiees  = array_values(array_map(
    fn($m) => $m['fichier'],
    array_filter($etat, fn($m) => $m['modifiee'])
  ));

  foreach ($etat as $migration) {
    if ($migration['statut'] !== 'en_attente') {
      continue;
    }
    $resultat = migrationsAppliquer($db, $migration['fichier']);
    if (!$resultat['ok']) {
      error_log('Migration en échec [' . $migration['fichier'] . '] : ' . $resultat['erreur']);
      return ['ok' => false, 'appliquees' => $appliquees, 'echec' => $resultat, 'modifiees' => $modifiees];
    }
    $appliquees[] = $resultat;
  }
  return ['ok' => true, 'appliquees' => $appliquees, 'echec' => null, 'modifiees' => $modifiees];
}

// Déclare appliquée une migration jouée à la main (phpMyAdmin), sans l'exécuter.
function migrationsMarquer(PDO $db, string $nom): bool {
  $chemin = migrationsDossier() . '/' . $nom;
  if (!preg_match(MIGRATIONS_MOTIF, $nom) || !is_file($chemin)) {
    return false;
  }
  migrationsAssurerTable($db);
  $stmt = $db->prepare('
    INSERT IGNORE INTO dd_migrations (mig_fichier, mig_checksum, mig_statut, mig_date)
    VALUES (:fichier, :checksum, :statut, NOW())
  ');
  $stmt->execute([
    ':fichier'  => $nom,
    ':checksum' => hash_file('sha256', $chemin),
    ':statut'   => MIGRATION_MARQUEE,
  ]);
  return $stmt->rowCount() === 1;
}
