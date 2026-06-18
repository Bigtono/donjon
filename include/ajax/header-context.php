<?php
// include/ajax/header-context.php
// Retourne le HTML du bloc de contexte de navigation (header), recalculé à
// chaud après consultation d'une campagne/scénario/chapitre/personnage dans
// #detail-pp — appelé par js/main.js pour que les boutons apparaissent sans
// recharger la page (cf. include/header-context.php pour le rendu partagé).

require_once __DIR__ . '/../db.php';
require_once __DIR__ . '/../auth.php';
require_once __DIR__ . '/../helpers.php';

requireAuth();

$header_context_niveaux = getHeaderContextNiveaux($db);

include __DIR__ . '/../header-context.php';
