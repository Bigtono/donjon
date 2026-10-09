<?php
// admin/migrations-auto.php — Migrations déclenchées par le déployeur (SP-DP6)
//
// Appelé en POST par le module de déploiement local, au milieu d'un envoi :
// le moteur et les nouvelles migrations viennent d'être transférés, le reste
// du code ne l'est pas encore. Le site est alors en maintenance ; ce point
// d'entrée est le seul à passer outre (MAINTENANCE_IGNOREE).
//
// Authentification par jeton à usage unique, sans aucun secret stocké en
// production :
//   1. le déployeur dépose par SFTP config/.migrations-jeton, qui contient
//      l'empreinte SHA-256 d'un jeton aléatoire (jamais le jeton lui-même) ;
//   2. il poste le jeton ici ; le fichier est comparé, puis supprimé.
// Seul celui qui peut écrire sur l'espace SFTP peut donc déclencher. Un jeton
// intercepté (le site est en HTTP) est déjà consommé, et ce script n'exécute
// que des fichiers déjà présents sur le disque, jamais du SQL reçu dans la
// requête : au pire, un tiers appliquerait en avance une migration légitime.
//
// Volontairement minimal : ni session, ni auth.php, ni helpers.php. Il ne doit
// dépendre que de fichiers transférés AVANT lui (cf. deploiementPrioritaire()).

define('MAINTENANCE_IGNOREE', true);
require_once __DIR__ . '/../include/db.php';
require_once __DIR__ . '/../include/migrations.php';

const JETON_DUREE_VIE = 300; // secondes, mesurées à l'horloge du serveur

function repondreMigrations(int $code, array $donnees): void {
  http_response_code($code);
  header('Content-Type: application/json; charset=UTF-8');
  header('Cache-Control: no-store');
  echo json_encode($donnees, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
  exit;
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST'):
  repondreMigrations(405, ['ok' => false, 'erreur' => 'Méthode non autorisée.']);
endif;

$jeton        = (string)($_POST['jeton'] ?? '');
$fichierJeton = __DIR__ . '/../config/.migrations-jeton';

if (!preg_match('/^[0-9a-f]{64}$/', $jeton) || !is_file($fichierJeton)):
  repondreMigrations(403, ['ok' => false, 'erreur' => 'Jeton absent ou invalide.']);
endif;

$attendu = json_decode((string)file_get_contents($fichierJeton), true);
if (!is_array($attendu) || !hash_equals((string)($attendu['empreinte'] ?? ''), hash('sha256', $jeton))):
  // Le fichier n'est pas supprimé : un tiers ne doit pas pouvoir griller le
  // jeton du déployeur en postant n'importe quoi.
  repondreMigrations(403, ['ok' => false, 'erreur' => 'Jeton absent ou invalide.']);
endif;

$age = time() - (int)filemtime($fichierJeton);
unlink($fichierJeton); // usage unique, avant toute autre chose

if ($age > JETON_DUREE_VIE):
  repondreMigrations(403, ['ok' => false, 'erreur' => 'Jeton expiré.']);
endif;

@set_time_limit(300);
$resultat = migrationsAppliquerEnAttente($db);
repondreMigrations($resultat['ok'] ? 200 : 500, $resultat);
