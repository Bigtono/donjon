<?php
// admin/deploiement/lib.php — Déploiement SFTP vers la production (SP-DP)
//
// MODULE LOCAL UNIQUEMENT. Quatre verrous indépendants l'empêchent d'agir
// ailleurs que sur le poste de développement :
//   1. ce dossier s'exclut lui-même du transfert, en dur
//      (DEPLOIEMENT_EXCLUSIONS_FIXES), quoi que dise .deployignore ;
//   2. paramètres et mot de passe vivent HORS du projet
//      (deploiementDossierPrive()) : hors webroot, hors git, hors OneDrive ;
//   3. chaque requête doit venir de la machine qui la sert : adresse du
//      client identique à celle du serveur, et non publique
//      (deploiementEstLocal()) — jamais HTTP_HOST ni DEV_MODE, que le client
//      choisit ;
//   4. .htaccess « Require local » sur ce dossier.
// S'il partait quand même en production (transfert manuel), il y resterait
// inerte : aucun paramètre, aucun secret, et Apache refuse tout client distant.
//
// Principe : git calcule la liste des fichiers du projet (même sémantique que
// .gitignore, sans réimplémentation), .deployignore en retire ce qui n'a rien à
// faire en production, et un manifeste stocké sur le serveur (hors www/)
// mémorise l'empreinte de chaque fichier réellement envoyé. Seuls les fichiers
// nouveaux ou modifiés partent.

// Jamais transférés, quel que soit le contenu de .deployignore. Une entrée
// terminée par « / » couvre tout un dossier.
const DEPLOIEMENT_EXCLUSIONS_FIXES = [
  'admin/deploiement/',       // ce module
  'config/db.config.php',     // identifiants de base, propres à chaque hébergement
  'config/.migrations-jeton', // jeton à usage unique, posé par le déployeur lui-même
  '.maintenance',             // drapeau de maintenance, posé par le déployeur lui-même
  '.git/',
];

// Envoyés AVANT l'application des migrations : tout ce dont le point d'entrée
// admin/migrations-auto.php a besoin pour tourner au milieu d'un envoi, plus
// les migrations elles-mêmes (cf. deploiementPrioritaire()).
const DEPLOIEMENT_PRIORITAIRES = [
  'include/db.php',
  'include/maintenance.php',
  'include/migrations.php',
  'include/migrations-reference.php',
  'admin/migrations-auto.php',
  'config/.htaccess',
  'sql/.htaccess',
];

const DEPLOIEMENT_LOT_FICHIERS = 20;              // fichiers par appel AJAX
const DEPLOIEMENT_LOT_OCTETS   = 4 * 1024 * 1024; // … ou ce volume, au premier atteint
const DEPLOIEMENT_PLAN_DUREE   = 900;             // un aperçu plus vieux est recalculé
const DEPLOIEMENT_VERROU_DUREE = 3600;            // au-delà, un verrou est réputé orphelin
const DEPLOIEMENT_CURLE_ABSENT = 78;              // CURLE_REMOTE_FILE_NOT_FOUND

const DEPLOIEMENT_CONFIG_DEFAUT = [
  'hote'           => '',
  'port'           => 22,
  'utilisateur'    => '',
  'mot_de_passe'   => '',
  'chemin_distant' => 'www/donjon',
  'dossier_prive'  => 'donjon-deploiement',
  'url_production' => 'http://maikastel.fr/donjon',
  'empreinte'      => '',
  'git'            => '',
];

// ============================================================
// GARDE ET EMPLACEMENTS
// ============================================================

// Vrai si la requête vient de la machine qui la sert : adresse du client
// IDENTIQUE à celle du serveur, et non publique. Couvre localhost (::1,
// 127.0.0.1) comme l'adresse réseau du poste (http://192.168.1.10/donjon/,
// l'accès habituel) ; c'est la définition de « Require local » d'Apache.
// Refusés : un autre appareil du réseau (adresse différente) et tout serveur
// public — l'adresse d'un hébergement OVH n'est jamais privée.
function deploiementEstLocal(): bool {
  $client  = (string)($_SERVER['REMOTE_ADDR'] ?? '');
  $serveur = (string)($_SERVER['SERVER_ADDR'] ?? '');
  return filter_var($client, FILTER_VALIDATE_IP) !== false
      && $client === $serveur
      && filter_var($client, FILTER_VALIDATE_IP, FILTER_FLAG_NO_PRIV_RANGE | FILTER_FLAG_NO_RES_RANGE) === false;
}

// Racine du projet, chemin réel (le raccourci htdocs/donjon est une jonction).
function deploiementRacine(): string {
  return str_replace('\\', '/', realpath(dirname(__DIR__, 2)));
}

// Dossier des paramètres, du journal et du verrou : à côté de htdocs
// (C:/xampp/private/donjon-deploiement), donc hors du site, hors du dépôt et
// hors de OneDrive où vit le projet.
function deploiementDossierPrive(): string {
  $docRoot = rtrim(str_replace('\\', '/', (string)($_SERVER['DOCUMENT_ROOT'] ?? '')), '/');
  if ($docRoot === '') {
    throw new RuntimeException('DOCUMENT_ROOT inconnu : impossible de situer le dossier privé.');
  }
  $dossier = dirname($docRoot) . '/private/donjon-deploiement';
  if (str_starts_with($dossier . '/', deploiementRacine() . '/')) {
    throw new RuntimeException('Le dossier privé ne doit pas se trouver dans le projet.');
  }
  return $dossier;
}

function deploiementEcrirePrive(string $nom, string $contenu, int $drapeaux = LOCK_EX): void {
  $dossier = deploiementDossierPrive();
  if (!is_dir($dossier) && !mkdir($dossier, 0700, true)) {
    throw new RuntimeException('Création du dossier privé impossible : ' . $dossier);
  }
  if (file_put_contents($dossier . '/' . $nom, $contenu, $drapeaux) === false) {
    throw new RuntimeException('Écriture impossible : ' . $dossier . '/' . $nom);
  }
}

// ============================================================
// PARAMÈTRES
// ============================================================

// Le mot de passe y figure en clair : le chiffrer avec une clé rangée à côté
// ne protégerait de rien. Sa protection, c'est l'emplacement du fichier.
function deploiementConfig(): array {
  $fichier = deploiementDossierPrive() . '/config.json';
  $lu = is_file($fichier) ? json_decode((string)file_get_contents($fichier), true) : [];
  return array_merge(
    DEPLOIEMENT_CONFIG_DEFAUT,
    is_array($lu) ? array_intersect_key($lu, DEPLOIEMENT_CONFIG_DEFAUT) : []
  );
}

function deploiementEnregistrerConfig(array $config): void {
  $config = array_intersect_key($config, DEPLOIEMENT_CONFIG_DEFAUT);
  deploiementEcrirePrive('config.json', json_encode($config, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE));
}

// Prêt à déployer : tout est renseigné ET l'empreinte du serveur est approuvée.
function deploiementConfigComplete(array $config): bool {
  foreach (['hote', 'utilisateur', 'mot_de_passe', 'chemin_distant', 'dossier_prive', 'url_production', 'empreinte'] as $cle) {
    if ((string)$config[$cle] === '') {
      return false;
    }
  }
  return true;
}

// Chemin distant relatif au dossier d'accueil SFTP (« www/donjon ») ou absolu
// (« /homez.123/compte/www/donjon »). Segments simples uniquement : ni « .. »,
// ni guillemet, ni espace — ils finissent dans des commandes SFTP.
function deploiementCheminValide(string $chemin): bool {
  $segments = explode('/', ltrim($chemin, '/'));
  foreach ($segments as $segment) {
    if ($segment === '' || $segment === '.' || $segment === '..' || !preg_match('/^[A-Za-z0-9._-]+$/', $segment)) {
      return false;
    }
  }
  return true;
}

function deploiementNormaliserChemin(string $chemin): string {
  $chemin = trim(str_replace('\\', '/', $chemin));
  return (str_starts_with($chemin, '/') ? '/' : '') . trim($chemin, '/');
}

// Valide la saisie du formulaire de paramètres. Retour : [config, erreurs].
// Un mot de passe laissé vide conserve celui qui est enregistré.
function deploiementValiderConfig(array $saisie, array $actuelle): array {
  $erreurs = [];
  $config  = $actuelle;

  $config['hote'] = strtolower(trim((string)($saisie['hote'] ?? '')));
  if (!preg_match('/^[a-z0-9]([a-z0-9.-]*[a-z0-9])?$/', $config['hote'])) {
    $erreurs[] = 'Hôte invalide (ex. ftp.cluster029.hosting.ovh.net).';
  }

  $config['port'] = (int)($saisie['port'] ?? 22);
  if ($config['port'] < 1 || $config['port'] > 65535) {
    $erreurs[] = 'Port invalide.';
  }

  $config['utilisateur'] = trim((string)($saisie['utilisateur'] ?? ''));
  if (!preg_match('/^[A-Za-z0-9._@-]+$/', $config['utilisateur'])) {
    $erreurs[] = 'Utilisateur invalide.';
  }

  $motDePasse = (string)($saisie['mot_de_passe'] ?? '');
  if ($motDePasse !== '') {
    $config['mot_de_passe'] = $motDePasse;
  }
  if ($config['mot_de_passe'] === '') {
    $erreurs[] = 'Mot de passe requis.';
  }

  $config['chemin_distant'] = deploiementNormaliserChemin((string)($saisie['chemin_distant'] ?? ''));
  if (!deploiementCheminValide($config['chemin_distant'])) {
    $erreurs[] = 'Chemin du site invalide.';
  }

  $config['dossier_prive'] = deploiementNormaliserChemin((string)($saisie['dossier_prive'] ?? ''));
  $prive = $config['dossier_prive'];
  if (!deploiementCheminValide($prive)) {
    $erreurs[] = 'Dossier privé invalide.';
  } elseif ($prive === $config['chemin_distant'] || str_starts_with($prive, $config['chemin_distant'] . '/')
      || $prive === 'www' || str_starts_with($prive, 'www/')) {
    $erreurs[] = 'Le dossier privé doit être hors du site et hors de www/ : le manifeste ne doit pas être accessible par le web.';
  }

  $config['url_production'] = rtrim(trim((string)($saisie['url_production'] ?? '')), '/');
  if (!filter_var($config['url_production'], FILTER_VALIDATE_URL)
      || !preg_match('#^https?://#', $config['url_production'])) {
    $erreurs[] = 'URL de production invalide.';
  }

  $config['git'] = trim(str_replace('\\', '/', (string)($saisie['git'] ?? '')));
  if ($config['git'] !== '' && !is_file($config['git'])) {
    $erreurs[] = 'Exécutable git introuvable : ' . $config['git'];
  }

  // Une empreinte approuvée ne vaut que pour le serveur qui l'a présentée.
  if ($config['hote'] !== $actuelle['hote'] || $config['port'] !== (int)$actuelle['port']) {
    $config['empreinte'] = '';
  }

  return [$config, $erreurs];
}

function deploiementCheminSite(array $config, string $relatif): string {
  return $config['chemin_distant'] . '/' . $relatif;
}

function deploiementCheminPrive(array $config, string $nom): string {
  return $config['dossier_prive'] . '/' . $nom;
}

// ============================================================
// PÉRIMÈTRE — git fait foi
// ============================================================

function deploiementGitExecutable(array $config): string {
  if ($config['git'] !== '') {
    return $config['git'];
  }
  foreach (['C:/Program Files/Git/cmd/git.exe', 'C:/Program Files/Git/bin/git.exe', 'C:/Program Files (x86)/Git/cmd/git.exe'] as $candidat) {
    if (is_file($candidat)) {
      return $candidat;
    }
  }
  return 'git';
}

// Lance git sans shell (tableau d'arguments) et renvoie les chemins d'une
// sortie -z. safe.directory : le dépôt est sur OneDrive, git refuserait de
// travailler si le propriétaire du dossier lui semblait douteux.
function deploiementGit(array $config, array $arguments): array {
  $racine   = deploiementRacine();
  $commande = array_merge(
    [deploiementGitExecutable($config), '-C', $racine, '-c', 'safe.directory=' . $racine, '-c', 'core.quotepath=off'],
    $arguments
  );
  $processus = proc_open($commande, [1 => ['pipe', 'w'], 2 => ['pipe', 'w']], $tubes);
  if (!is_resource($processus)) {
    throw new RuntimeException('Impossible de lancer git (' . deploiementGitExecutable($config) . ').');
  }
  $sortie = stream_get_contents($tubes[1]);
  $erreur = stream_get_contents($tubes[2]);
  fclose($tubes[1]);
  fclose($tubes[2]);
  $code = proc_close($processus);
  if ($code !== 0) {
    throw new RuntimeException('git a échoué (code ' . $code . ') : ' . trim($erreur));
  }
  return array_values(array_unique(array_filter(explode("\0", $sortie), fn($c) => $c !== '')));
}

function deploiementExclusionFixe(string $chemin): bool {
  foreach (DEPLOIEMENT_EXCLUSIONS_FIXES as $exclusion) {
    if (str_ends_with($exclusion, '/') ? str_starts_with($chemin, $exclusion) : $chemin === $exclusion) {
      return true;
    }
  }
  return false;
}

// Un nom transmis tel quel dans une URL et une commande SFTP : pas de
// guillemet, de barre oblique inverse, de caractère de contrôle ni de « .. ».
function deploiementNomAcceptable(string $chemin): bool {
  return !preg_match('/["\\\\\x00-\x1F]/', $chemin)
      && !str_starts_with($chemin, '/')
      && !in_array('..', explode('/', $chemin), true);
}

// Ce qui part en production. Retour : ['fichiers' => [chemins triés],
// 'exclus' => [chemin => raison]].
//   - candidats : fichiers suivis + nouveaux non ignorés = l'arbre de travail
//     tel qu'il est testé en local, commité ou non ;
//   - moins les fichiers suivis que .gitignore ignore (commités avant d'être
//     ignorés : export/, tools/) ;
//   - moins .deployignore, interprété par git lui-même ;
//   - moins les exclusions fixes.
// $rapport ajoute aux exclus les fichiers non suivis ignorés par .gitignore,
// dossiers regroupés — pour l'écran de paramétrage, pas pour le transfert.
function deploiementPerimetre(array $config, bool $rapport = false): array {
  $racine        = deploiementRacine();
  $candidats     = deploiementGit($config, ['ls-files', '-z', '-c', '-o', '--exclude-standard']);
  $ignoresSuivis = array_flip(deploiementGit($config, ['ls-files', '-z', '-c', '-i', '--exclude-standard']));
  $deployignore  = is_file($racine . '/.deployignore')
    ? array_flip(deploiementGit($config, ['ls-files', '-z', '-c', '-o', '-i', '--exclude-from=.deployignore']))
    : [];

  $fichiers = [];
  $exclus   = [];
  foreach ($candidats as $chemin) {
    if (!is_file($racine . '/' . $chemin)) {
      continue; // supprimé dans l'arbre de travail : le manifeste s'en charge
    }
    if (deploiementExclusionFixe($chemin)) {
      $exclus[$chemin] = 'exclusion fixe';
    } elseif (isset($ignoresSuivis[$chemin])) {
      $exclus[$chemin] = '.gitignore';
    } elseif (isset($deployignore[$chemin])) {
      $exclus[$chemin] = '.deployignore';
    } elseif (!deploiementNomAcceptable($chemin)) {
      $exclus[$chemin] = 'nom de fichier refusé';
    } else {
      $fichiers[] = $chemin;
    }
  }

  if ($rapport) {
    foreach (deploiementGit($config, ['ls-files', '-z', '-o', '-i', '--exclude-standard', '--directory']) as $chemin) {
      $exclus[$chemin] = deploiementExclusionFixe($chemin) ? 'exclusion fixe' : '.gitignore';
    }
  }

  sort($fichiers, SORT_STRING);
  ksort($exclus, SORT_STRING);
  return ['fichiers' => $fichiers, 'exclus' => $exclus];
}

function deploiementEstMigration(string $chemin): bool {
  return preg_match('#^sql/\d{4}-\d{2}-\d{2}_[A-Za-z0-9._-]+\.sql$#', $chemin) === 1;
}

function deploiementPrioritaire(string $chemin): bool {
  return in_array($chemin, DEPLOIEMENT_PRIORITAIRES, true) || deploiementEstMigration($chemin);
}

// ============================================================
// TRANSPORT
// ============================================================

// Opérations distantes dont le déploiement a besoin. Les chemins sont relatifs
// au dossier d'accueil du compte, ou absolus.
interface DeploiementTransport
{
  public function envoyer(string $local, string $distant): void;
  public function ecrire(string $distant, string $contenu): void;
  public function lire(string $distant): ?string;     // null si le fichier n'existe pas
  public function supprimer(string $distant): void;   // tolère un fichier déjà absent
  public function lister(string $dossier): array;
}

// SFTP par l'extension curl de PHP (libssh2), sans dépendance à installer.
// L'empreinte de la clé du serveur est épinglée : un serveur qui se ferait
// passer pour OVH est refusé avant toute authentification.
class DeploiementSftp implements DeploiementTransport
{
  private $ch = null;

  public function __construct(private array $config)
  {
  }

  public function __destruct()
  {
    if ($this->ch !== null) {
      curl_close($this->ch);
    }
  }

  // Lit l'empreinte SHA-256 de la clé du serveur, sans s'authentifier :
  // l'épinglage est volontairement faux, la poignée de main échoue avant
  // l'envoi de tout identifiant et libcurl cite l'empreinte réelle.
  public static function decouvrirEmpreinte(string $hote, int $port): string
  {
    $journal = fopen('php://temp', 'w+');
    $ch = curl_init('sftp://' . $hote . ':' . $port . '/');
    curl_setopt_array($ch, [
      CURLOPT_PROTOCOLS                  => CURLPROTO_SFTP,
      CURLOPT_SSH_HOST_PUBLIC_KEY_SHA256 => str_repeat('A', 43),
      CURLOPT_USERNAME                   => 'empreinte',
      CURLOPT_NOBODY                     => true,
      CURLOPT_CONNECTTIMEOUT             => 20,
      CURLOPT_VERBOSE                    => true,
      CURLOPT_STDERR                     => $journal,
    ]);
    curl_exec($ch);
    $erreur = curl_error($ch);
    curl_close($ch);
    rewind($journal);
    $trace = stream_get_contents($journal);
    fclose($journal);

    if (preg_match('/fingerprint: ([A-Za-z0-9+\/]{43})=?/', $trace . "\n" . $erreur, $m)) {
      return $m[1];
    }
    throw new RuntimeException('Empreinte non lue : ' . ($erreur !== '' ? $erreur : 'serveur injoignable.'));
  }

  public function envoyer(string $local, string $distant): void
  {
    $flux = fopen($local, 'rb');
    if ($flux === false) {
      throw new RuntimeException('Lecture locale impossible : ' . $local);
    }
    try {
      $this->televerser($flux, (int)filesize($local), $distant);
    } finally {
      fclose($flux);
    }
  }

  public function ecrire(string $distant, string $contenu): void
  {
    $flux = fopen('php://temp', 'w+b');
    fwrite($flux, $contenu);
    rewind($flux);
    try {
      $this->televerser($flux, strlen($contenu), $distant);
    } finally {
      fclose($flux);
    }
  }

  public function lire(string $distant): ?string
  {
    $this->preparer([CURLOPT_URL => $this->url($distant)]);
    $contenu = curl_exec($this->ch);
    if ($contenu === false) {
      if (curl_errno($this->ch) === DEPLOIEMENT_CURLE_ABSENT) {
        return null;
      }
      throw new RuntimeException('Lecture de ' . $distant . ' : ' . curl_error($this->ch));
    }
    return $contenu;
  }

  public function supprimer(string $distant): void
  {
    // Pas de « * » (qui ferait ignorer tout échec) : seule l'absence du fichier
    // est tolérée. Une suppression ratée en silence avait laissé la production
    // en maintenance après un déploiement « réussi » (D-DP11).
    $this->preparer([
      CURLOPT_URL    => $this->urlAccueil(),
      CURLOPT_NOBODY => true,
      CURLOPT_QUOTE  => ['rm ' . $this->argument($distant)],
    ]);
    if (curl_exec($this->ch) === false && !str_contains(curl_error($this->ch), 'No such file')) {
      throw new RuntimeException('Suppression de ' . $distant . ' : ' . curl_error($this->ch));
    }
  }

  public function lister(string $dossier): array
  {
    $this->preparer([CURLOPT_URL => $this->url($dossier) . '/', CURLOPT_DIRLISTONLY => true]);
    $sortie = (string)$this->executer('Lecture du dossier ' . $dossier);
    $noms   = array_map('trim', explode("\n", $sortie));
    return array_values(array_filter($noms, fn($n) => $n !== '' && $n !== '.' && $n !== '..'));
  }

  private function televerser($flux, int $taille, string $distant): void
  {
    $this->preparer([
      CURLOPT_URL                     => $this->url($distant),
      CURLOPT_UPLOAD                  => true,
      CURLOPT_INFILE                  => $flux,
      CURLOPT_INFILESIZE              => $taille,
      CURLOPT_FTP_CREATE_MISSING_DIRS => CURLFTP_CREATE_DIR,
      CURLOPT_NEW_FILE_PERMS          => 0644,
      CURLOPT_NEW_DIRECTORY_PERMS     => 0755,
    ]);
    $this->executer('Envoi de ' . $distant);
  }

  // Une seule poignée curl pour toute la durée de l'objet : curl_reset() remet
  // les options à zéro mais garde la connexion SSH ouverte d'un fichier à
  // l'autre.
  private function preparer(array $options): void
  {
    if ($this->config['empreinte'] === '') {
      throw new RuntimeException('Empreinte du serveur non approuvée : connexion refusée.');
    }
    if ($this->ch === null) {
      $this->ch = curl_init();
    } else {
      curl_reset($this->ch);
    }
    curl_setopt_array($this->ch, $options + [
      CURLOPT_PROTOCOLS                  => CURLPROTO_SFTP,
      CURLOPT_USERNAME                   => $this->config['utilisateur'],
      CURLOPT_PASSWORD                   => $this->config['mot_de_passe'],
      CURLOPT_SSH_AUTH_TYPES             => CURLSSH_AUTH_PASSWORD | CURLSSH_AUTH_KEYBOARD,
      CURLOPT_SSH_HOST_PUBLIC_KEY_SHA256 => $this->config['empreinte'],
      CURLOPT_CONNECTTIMEOUT             => 20,
      CURLOPT_TIMEOUT                    => 300,
      CURLOPT_RETURNTRANSFER             => true,
    ]);
  }

  private function executer(string $operation)
  {
    $resultat = curl_exec($this->ch);
    if ($resultat === false) {
      throw new RuntimeException($operation . ' : ' . curl_error($this->ch));
    }
    return $resultat;
  }

  private function base(): string
  {
    return 'sftp://' . $this->config['hote'] . ':' . (int)$this->config['port'];
  }

  private function urlAccueil(): string
  {
    return $this->base() . '/~/';
  }

  // « ~ » désigne le dossier d'accueil du compte dans une URL sftp://.
  private function url(string $chemin): string
  {
    $segments = array_map('rawurlencode', explode('/', trim($chemin, '/')));
    return $this->base() . (str_starts_with($chemin, '/') ? '' : '/~') . '/' . implode('/', $segments);
  }

  // Argument d'une commande SFTP (CURLOPT_QUOTE). Contrairement à l'URL, « ~ »
  // n'y est PAS traduit : un chemin relatif l'est au dossier d'ouverture de la
  // session, le dossier d'accueil. Les noms ont été filtrés
  // (deploiementNomAcceptable).
  private function argument(string $chemin): string
  {
    return '"' . $chemin . '"';
  }
}

// ============================================================
// MANIFESTE — ce qui a réellement été envoyé
// ============================================================

// Rangé dans le dossier privé distant (hors www/), jamais servi par le web.
// null : aucun manifeste, c'est un premier déploiement.
function deploiementLireManifeste(DeploiementTransport $transport, array $config): ?array {
  $brut = $transport->lire(deploiementCheminPrive($config, 'manifeste.json'));
  if ($brut === null) {
    return null;
  }
  $manifeste = json_decode($brut, true);
  if (!is_array($manifeste) || !is_array($manifeste['fichiers'] ?? null)) {
    throw new RuntimeException('Manifeste distant illisible : relancez avec « Renvoyer tous les fichiers ».');
  }
  return $manifeste['fichiers'];
}

function deploiementEcrireManifeste(DeploiementTransport $transport, array $config, array $fichiers): void {
  ksort($fichiers, SORT_STRING);
  $transport->ecrire(
    deploiementCheminPrive($config, 'manifeste.json'),
    json_encode(['version' => 1, 'maj' => date('Y-m-d H:i:s'), 'fichiers' => $fichiers], JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE)
  );
}

// ============================================================
// PLAN — aperçu, puis étapes
// ============================================================

// Compare l'arbre local au manifeste distant. $complet renvoie aussi les
// fichiers inchangés (manifeste douteux, fichier modifié à la main en prod).
function deploiementCalculerPlan(DeploiementTransport $transport, array $config, bool $complet = false): array {
  $perimetre = deploiementPerimetre($config);
  $racine    = deploiementRacine();
  $locaux    = [];
  foreach ($perimetre['fichiers'] as $chemin) {
    $locaux[$chemin] = hash_file('sha256', $racine . '/' . $chemin);
  }

  $distants = deploiementLireManifeste($transport, $config);
  $premier  = $distants === null;
  $distants = $distants ?? [];

  $nouveaux = $modifies = $renvoyes = $supprimes = [];
  foreach ($locaux as $chemin => $empreinte) {
    if (!isset($distants[$chemin])) {
      $nouveaux[] = $chemin;
    } elseif ($distants[$chemin] !== $empreinte) {
      $modifies[] = $chemin;
    } elseif ($complet) {
      $renvoyes[] = $chemin;
    }
  }
  // Seuls les fichiers que l'outil a lui-même déployés peuvent être supprimés :
  // il ne touche jamais à ce qu'il ne connaît pas (logs, config, fichiers
  // créés en production).
  foreach (array_keys($distants) as $chemin) {
    if (!isset($locaux[$chemin]) && !deploiementExclusionFixe($chemin) && deploiementNomAcceptable($chemin)) {
      $supprimes[] = $chemin;
    }
  }

  return [
    'id'          => bin2hex(random_bytes(8)),
    'cree'        => time(),
    'premier'     => $premier,
    'complet'     => $complet,
    'nb_perimetre' => count($locaux),
    'nouveaux'    => $nouveaux,
    'modifies'    => $modifies,
    'renvoyes'    => $renvoyes,
    'supprimes'   => $supprimes,
    'migrations'  => array_values(array_filter($nouveaux, 'deploiementEstMigration')),
    'migrations_retouchees' => array_values(array_filter($modifies, 'deploiementEstMigration')),
    'locaux'      => $locaux,
    'manifeste'   => $distants,
  ];
}

// Découpe une liste de fichiers en lots (nombre ou volume, au premier atteint).
function deploiementLots(array $fichiers): array {
  $lots   = [];
  $lot    = [];
  $octets = 0;
  foreach ($fichiers as $chemin) {
    $taille = (int)filesize(deploiementRacine() . '/' . $chemin);
    if ($lot && (count($lot) >= DEPLOIEMENT_LOT_FICHIERS || $octets + $taille > DEPLOIEMENT_LOT_OCTETS)) {
      $lots[] = $lot;
      $lot    = [];
      $octets = 0;
    }
    $lot[]   = $chemin;
    $octets += $taille;
  }
  if ($lot) {
    $lots[] = $lot;
  }
  return $lots;
}

// Ordre d'un déploiement :
//   maintenance → moteur + migrations → application des migrations
//   → reste du code → suppressions → fin de maintenance.
// Le schéma évolue AVANT le code : les migrations ajoutent (colonnes, tables),
// l'ancien code supporte donc le nouveau schéma, alors que l'inverse plante.
function deploiementEtapes(array $plan, bool $migrations, bool $supprimer): array {
  $aEnvoyer     = array_merge($plan['nouveaux'], $plan['modifies'], $plan['renvoyes']);
  $prioritaires = array_values(array_filter($aEnvoyer, 'deploiementPrioritaire'));
  $reste        = array_values(array_diff($aEnvoyer, $prioritaires));
  sort($prioritaires, SORT_STRING);
  sort($reste, SORT_STRING);
  $aSupprimer   = $supprimer ? $plan['supprimes'] : [];
  // Rien à transférer : pas de maintenance pour une simple vérification des
  // migrations.
  $maintenance  = $aEnvoyer || $aSupprimer;

  $etapes = [];
  if ($maintenance) {
    $etapes[] = ['type' => 'maintenance', 'active' => true, 'libelle' => 'Mise en maintenance du site'];
  }
  foreach (deploiementLots($prioritaires) as $lot) {
    $etapes[] = ['type' => 'envoi', 'fichiers' => $lot, 'libelle' => 'Envoi du moteur et des migrations (' . count($lot) . ' fichier' . (count($lot) > 1 ? 's' : '') . ')'];
  }
  if ($migrations) {
    $etapes[] = ['type' => 'migrations', 'libelle' => 'Application des migrations SQL en production'];
  }
  foreach (deploiementLots($reste) as $lot) {
    $etapes[] = ['type' => 'envoi', 'fichiers' => $lot, 'libelle' => 'Envoi de ' . count($lot) . ' fichier' . (count($lot) > 1 ? 's' : '')];
  }
  foreach (array_chunk($aSupprimer, 50) as $lot) {
    $etapes[] = ['type' => 'suppression', 'fichiers' => $lot, 'libelle' => 'Suppression de ' . count($lot) . ' fichier' . (count($lot) > 1 ? 's' : '')];
  }
  if ($maintenance) {
    $etapes[] = ['type' => 'maintenance', 'active' => false, 'libelle' => 'Fin de la maintenance'];
  }
  $etapes[] = ['type' => 'fin', 'libelle' => 'Clôture et journal'];
  return $etapes;
}

// Exécute une étape. Les étapes sont rejouables : en cas d'échec, « Reprendre »
// relance la même (envois écrasés, suppressions tolérantes, moteur de
// migrations qui saute ce qui est déjà passé). Le manifeste distant est
// réécrit après chaque lot, même interrompu : il ne décrit que ce qui a
// réellement été envoyé.
function deploiementExecuterEtape(DeploiementTransport $transport, array $config, array &$plan, int $index): string {
  $etape = $plan['etapes'][$index];

  if ($etape['type'] === 'maintenance') {
    $chemin = deploiementCheminSite($config, '.maintenance');
    if ($etape['active']) {
      $transport->ecrire($chemin, date('c'));
      return 'Site en maintenance.';
    }
    $transport->supprimer($chemin);
    return 'Site rouvert.';
  }

  if ($etape['type'] === 'envoi') {
    try {
      foreach ($etape['fichiers'] as $chemin) {
        $transport->envoyer(deploiementRacine() . '/' . $chemin, deploiementCheminSite($config, $chemin));
        $plan['manifeste'][$chemin] = $plan['locaux'][$chemin];
      }
    } finally {
      deploiementEcrireManifeste($transport, $config, $plan['manifeste']);
    }
    return implode(', ', $etape['fichiers']);
  }

  if ($etape['type'] === 'suppression') {
    try {
      foreach ($etape['fichiers'] as $chemin) {
        $transport->supprimer(deploiementCheminSite($config, $chemin));
        unset($plan['manifeste'][$chemin]);
      }
    } finally {
      deploiementEcrireManifeste($transport, $config, $plan['manifeste']);
    }
    return implode(', ', $etape['fichiers']);
  }

  if ($etape['type'] === 'migrations') {
    return deploiementAppliquerMigrations($transport, $config);
  }

  return '';
}

// Dépose par SFTP l'empreinte d'un jeton à usage unique, puis demande au
// serveur d'appliquer ses migrations en attente (admin/migrations-auto.php).
function deploiementAppliquerMigrations(DeploiementTransport $transport, array $config): string {
  $jeton       = bin2hex(random_bytes(32));
  $cheminJeton = deploiementCheminSite($config, 'config/.migrations-jeton');
  $transport->ecrire($cheminJeton, json_encode(['empreinte' => hash('sha256', $jeton)]));

  try {
    $ch = curl_init($config['url_production'] . '/admin/migrations-auto.php');
    curl_setopt_array($ch, [
      CURLOPT_POST           => true,
      CURLOPT_POSTFIELDS     => http_build_query(['jeton' => $jeton]),
      CURLOPT_RETURNTRANSFER => true,
      CURLOPT_PROTOCOLS      => CURLPROTO_HTTP | CURLPROTO_HTTPS,
      CURLOPT_FOLLOWLOCATION => true,
      CURLOPT_POSTREDIR      => CURL_REDIR_POST_ALL, // http → https sans perdre le POST
      CURLOPT_MAXREDIRS      => 3,
      CURLOPT_CONNECTTIMEOUT => 20,
      CURLOPT_TIMEOUT        => 320,
    ]);
    $corps  = curl_exec($ch);
    $code   = (int)curl_getinfo($ch, CURLINFO_RESPONSE_CODE);
    $erreur = curl_error($ch);
    curl_close($ch);
  } finally {
    // Normalement déjà consommé par le serveur ; sinon, ne pas le laisser traîner.
    $transport->supprimer($cheminJeton);
  }

  if ($corps === false) {
    throw new RuntimeException('Appel des migrations impossible : ' . $erreur);
  }
  $reponse = json_decode($corps, true);
  if (!is_array($reponse)) {
    $extrait = trim(preg_replace('/\s+/', ' ', strip_tags($corps)));
    throw new RuntimeException('Réponse inattendue du serveur (HTTP ' . $code . ') : ' . mb_substr($extrait, 0, 200));
  }
  if (empty($reponse['ok'])) {
    $nb     = count($reponse['appliquees'] ?? []);
    $detail = isset($reponse['echec'])
      ? $reponse['echec']['fichier'] . ' — ' . $reponse['echec']['erreur']
      : (string)($reponse['erreur'] ?? 'erreur inconnue');
    throw new RuntimeException(($nb > 0 ? $nb . ' migration(s) appliquée(s), puis échec sur ' : 'Échec des migrations : ') . $detail);
  }

  $noms    = array_column($reponse['appliquees'] ?? [], 'fichier');
  $message = $noms
    ? count($noms) . ' migration' . (count($noms) > 1 ? 's appliquées' : ' appliquée') . ' : ' . implode(', ', $noms)
    : 'Aucune migration en attente.';
  if (!empty($reponse['modifiees'])) {
    $message .= ' Retouchées après application (non rejouées) : ' . implode(', ', $reponse['modifiees']) . '.';
  }
  return $message;
}

// ============================================================
// VÉRIFICATION DE LA CONNEXION
// ============================================================

// Exerce chaque opération dont un déploiement a besoin, sur un fichier témoin
// du dossier privé. Retour : liste de ['ok' => bool, 'texte' => string].
function deploiementTester(array $config): array {
  $resultats = [];
  $sftp      = new DeploiementSftp($config);
  try {
    $temoin = 'test-connexion-' . bin2hex(random_bytes(4)) . '.txt';
    $chemin = deploiementCheminPrive($config, $temoin);
    $texte  = 'Codex DD — test de connexion ' . date('c');

    $sftp->ecrire($chemin, $texte);
    $resultats[] = ['ok' => true, 'texte' => 'Authentification, puis écriture dans ' . $config['dossier_prive'] . '/'];

    $resultats[] = ['ok' => $sftp->lire($chemin) === $texte, 'texte' => 'Relecture du fichier témoin'];

    $sftp->supprimer($chemin);
    $resultats[] = ['ok' => !in_array($temoin, $sftp->lister($config['dossier_prive']), true), 'texte' => 'Suppression du fichier témoin'];

    $contenu = $sftp->lister($config['chemin_distant']);
    $resultats[] = in_array('index.php', $contenu, true)
      ? ['ok' => true, 'texte' => 'Dossier du site ' . $config['chemin_distant'] . ' : index.php présent']
      : ['ok' => false, 'texte' => 'Dossier du site ' . $config['chemin_distant'] . ' : pas d\'index.php — chemin à vérifier'];
  } catch (Throwable $e) {
    $resultats[] = ['ok' => false, 'texte' => $e->getMessage()];
  }

  // Le point d'entrée des migrations répond 405 à un GET quand il est en place.
  $ch = curl_init($config['url_production'] . '/admin/migrations-auto.php');
  curl_setopt_array($ch, [CURLOPT_RETURNTRANSFER => true, CURLOPT_CONNECTTIMEOUT => 15, CURLOPT_TIMEOUT => 20]);
  curl_exec($ch);
  $code = (int)curl_getinfo($ch, CURLINFO_RESPONSE_CODE);
  curl_close($ch);
  if ($code === 405) {
    $resultats[] = ['ok' => true, 'texte' => 'Production joignable, moteur de migrations en place'];
  } elseif ($code === 404) {
    $resultats[] = ['ok' => true, 'texte' => 'Production joignable ; moteur de migrations absent, il sera installé au premier déploiement'];
  } else {
    $resultats[] = ['ok' => false, 'texte' => 'Production : réponse HTTP ' . ($code ?: 'nulle') . ' sur ' . $config['url_production']];
  }
  return $resultats;
}

// ============================================================
// VERROU ET JOURNAL
// ============================================================

function deploiementVerrou(): ?array {
  $fichier = deploiementDossierPrive() . '/verrou.json';
  if (!is_file($fichier)) {
    return null;
  }
  $verrou = json_decode((string)file_get_contents($fichier), true);
  if (!is_array($verrou) || time() - (int)($verrou['debut'] ?? 0) > DEPLOIEMENT_VERROU_DUREE) {
    return null;
  }
  return $verrou;
}

function deploiementPoserVerrou(string $planId): void {
  $verrou = deploiementVerrou();
  if ($verrou && $verrou['plan'] !== $planId) {
    throw new RuntimeException('Un autre déploiement est en cours depuis ' . date('H:i', (int)$verrou['debut']) . '.');
  }
  deploiementEcrirePrive('verrou.json', json_encode(['plan' => $planId, 'debut' => time()]));
}

function deploiementLeverVerrou(): void {
  $fichier = deploiementDossierPrive() . '/verrou.json';
  if (is_file($fichier)) {
    unlink($fichier);
  }
}

function deploiementJournaliser(array $entree): void {
  $entree = ['date' => date('Y-m-d H:i:s')] + $entree;
  deploiementEcrirePrive('journal.jsonl', json_encode($entree, JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE) . "\n", FILE_APPEND | LOCK_EX);
}

// Dernières entrées du journal, la plus récente en tête.
function deploiementJournal(int $limite = 20): array {
  $fichier = deploiementDossierPrive() . '/journal.jsonl';
  if (!is_file($fichier)) {
    return [];
  }
  $lignes  = array_slice(file($fichier, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES), -$limite);
  $entrees = array_filter(array_map(fn($l) => json_decode($l, true), $lignes), 'is_array');
  return array_reverse(array_values($entrees));
}
