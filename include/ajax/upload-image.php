<?php
// include/ajax/upload-image.php
// Endpoint d'upload d'image pour TinyMCE (images_upload_url).
// Reçoit un POST multipart avec un champ fichier (TinyMCE envoie 'file').
// Retourne { "location": "URL_du_fichier" } en cas de succès,
// ou { "error": "message" } avec un code HTTP non-2xx en cas d'échec
// (format attendu par le plugin image de TinyMCE).

require_once __DIR__ . '/../db.php';
require_once __DIR__ . '/../auth.php';
require_once __DIR__ . '/../helpers.php';

requireAuth();
header('Content-Type: application/json');

// TinyMCE envoie toujours le fichier sous la clé 'file'
if (!isset($_FILES['file']) || $_FILES['file']['error'] !== UPLOAD_ERR_OK):
  http_response_code(400);
  echo json_encode(['error' => "Aucun fichier reçu ou erreur d'upload."]);
  exit;
endif;

$fichier = $_FILES['file'];

// --- Validation taille (5 Mo max) ---
$tailleMax = 5 * 1024 * 1024;
if ($fichier['size'] > $tailleMax):
  http_response_code(400);
  echo json_encode(['error' => 'Fichier trop volumineux (5 Mo maximum).']);
  exit;
endif;

// --- Validation type MIME réel (pas le Content-Type déclaré par le client) ---
$mimesAutorises = [
  'image/jpeg' => 'jpg',
  'image/png'  => 'png',
  'image/gif'  => 'gif',
  'image/webp' => 'webp',
];

$finfo    = new finfo(FILEINFO_MIME_TYPE);
$mimeReel = $finfo->file($fichier['tmp_name']);

if (!isset($mimesAutorises[$mimeReel])):
  http_response_code(400);
  echo json_encode(['error' => 'Format non autorisé (jpg, png, gif, webp uniquement).']);
  exit;
endif;

$extension = $mimesAutorises[$mimeReel];

// --- Répertoire cible : img/uploads/ (créé à la volée si absent) ---
$dirCible = __DIR__ . '/../../img/uploads';
if (!is_dir($dirCible)):
  if (!mkdir($dirCible, 0755, true) && !is_dir($dirCible)):
    http_response_code(500);
    echo json_encode(['error' => "Impossible de créer le répertoire d'upload."]);
    exit;
  endif;
endif;

// --- Nom de fichier généré (jamais le nom d'origine — évite collision et injection de chemin) ---
$nomFichier  = bin2hex(random_bytes(16)) . '.' . $extension;
$cheminCible = $dirCible . '/' . $nomFichier;

if (!move_uploaded_file($fichier['tmp_name'], $cheminCible)):
  http_response_code(500);
  echo json_encode(['error' => "Échec de l'enregistrement du fichier."]);
  exit;
endif;

chmod($cheminCible, 0644);

echo json_encode(['location' => BASE_URL . '/img/uploads/' . $nomFichier]);
