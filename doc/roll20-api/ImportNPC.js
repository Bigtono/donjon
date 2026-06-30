// ============================================================
// ImportNPC.js — Script Roll20 API (Pro requis)
// ============================================================
// Importe un personnage NPC dans Roll20 à partir d'un JSON
// généré par Codex DD (include/ajax/export/monstre-roll20.php).
//
// PRÉREQUIS
//   - Compte Roll20 Pro avec accès à l'API
//
// DEUX MODES D'IMPORT
//
//   1) Depuis un Handout (!import-npc)
//      - Coller le JSON dans l'onglet "GM Notes" d'un Handout
//      - Commande : !import-npc [nom_handout]  (défaut : "Import NPC")
//      - Crée le personnage dans la bibliothèque (sans token lié)
//
//   2) Depuis un Token posé sur la carte (!import-npc-token)
//      - Poser le token sur la carte (depuis n'importe quelle image)
//      - Clic droit sur le token > Modifier > coller le JSON dans
//        "GM Notes" (icône bloc-notes du token)
//      - Sélectionner le token, taper !import-npc-token dans le chat
//      - Crée le personnage ET lie automatiquement le token (represents)
//      - Renomme aussi le token avec le nom du PNJ
//
// UTILISATION RAPIDE (mode token, recommandé en cours de partie)
//   1. Glisser n'importe quel jeton sur la carte
//   2. Clic droit > Modifier > coller le JSON dans GM Notes > Enregistrer
//   3. Sélectionner le jeton, taper !import-npc-token
//   4. Le jeton est immédiatement relié à la fiche PNJ complète
//
// V2 PRÉVUE
//   - Support spelloutput = "ATTACK" pour les sorts offensifs des PNJ
//     (nécessite la résolution sort → jet d'attaque Roll20)
//   - Champ d'avatar : URL image à renseigner manuellement pour l'instant
// ============================================================

var ImportNPC = ImportNPC || (function () {
  'use strict';

  var HANDOUT_DEFAULT = 'Import NPC';
  var CMD_HANDOUT      = '!import-npc';
  var CMD_TOKEN         = '!import-npc-token';

  // ── Écoute des commandes chat ─────────────────────────

  on('ready', function () {
    log('[ImportNPC] Prêt. Commandes : ' + CMD_HANDOUT + ' [nom_handout]  |  '
      + CMD_TOKEN + ' (token sélectionné)');
  });

  on('chat:message', function (msg) {
    if (msg.type !== 'api') return;

    // ── Mode token sélectionné ───────────────────────
    if (msg.content.indexOf(CMD_TOKEN) === 0) {
      importerDepuisToken(msg);
      return;
    }

    // ── Mode handout ──────────────────────────────────
    if (msg.content.indexOf(CMD_HANDOUT) === 0) {
      var parts       = msg.content.split(/\s+/);
      var handoutName = parts.slice(1).join(' ') || HANDOUT_DEFAULT;

      trouverHandout(handoutName, function (handout) {
        if (!handout) {
          whisper(msg.who, '❌ Handout introuvable : **' + handoutName + '**');
          return;
        }
        handout.get('gmnotes', function (notes) {
          if (!notes || notes === 'null') {
            whisper(msg.who, '❌ Le handout "' + handoutName + '" est vide (GM Notes).');
            return;
          }
          var data = parserJsonDepuisNotes(notes, msg.who);
          if (data) importerNpc(data, msg.who, null);
        });
      });
      return;
    }
  });

  // ── Mode token : lecture des GM Notes du token sélectionné ──

  function importerDepuisToken(msg) {
    if (!msg.selected || !msg.selected.length) {
      whisper(msg.who, '❌ Aucun token sélectionné. Sélectionnez le token cible avant de taper '
        + CMD_TOKEN + '.');
      return;
    }

    var token = getObj('graphic', msg.selected[0]._id);
    if (!token) {
      whisper(msg.who, '❌ Token introuvable.');
      return;
    }

    token.get('gmnotes', function (notes) {
      if (!notes || notes === 'null') {
        whisper(msg.who, '❌ Les GM Notes de ce token sont vides. Collez-y le JSON exporté'
          + ' depuis Codex DD (clic droit sur le token > Modifier > GM Notes).');
        return;
      }
      var data = parserJsonDepuisNotes(notes, msg.who);
      if (data) importerNpc(data, msg.who, token);
    });
  }

  // ── Recherche du handout ──────────────────────────────

  function trouverHandout(nom, callback) {
    var handouts = findObjs({ _type: 'handout', name: nom });
    callback(handouts.length ? handouts[0] : null);
  }

  // ── Parsing JSON depuis un champ notes/gmnotes ────────
  // Centralise le nettoyage + JSON.parse + gestion d'erreur whisperée.

  function parserJsonDepuisNotes(notes, who) {
    var json = nettoyerNotes(notes);
    try {
      return JSON.parse(json);
    } catch (e) {
      whisper(who, '❌ JSON invalide : ' + e.message);
      return null;
    }
  }

  // ── Nettoyage des GM Notes ────────────────────────────
  // Roll20 encode les GM Notes (token et handout) en HTML et en URI.

  function nettoyerNotes(notes) {
    // Décoder l'URI encoding de Roll20
    try {
      notes = unescape(notes);
    } catch (e) { /* pas encodé */ }
    // Supprimer les balises HTML (Roll20 wrapper <div>/<p> etc.)
    notes = notes.replace(/<br\s*\/?>/gi, '')
                 .replace(/<p[^>]*>/gi, '')
                 .replace(/<\/p>/gi, '')
                 .replace(/<div[^>]*>/gi, '')
                 .replace(/<\/div>/gi, '')
                 .replace(/&nbsp;/gi, ' ')
                 .replace(/&amp;/gi, '&')
                 .replace(/&lt;/gi, '<')
                 .replace(/&gt;/gi, '>')
                 .replace(/&quot;/gi, '"')
                 .replace(/<[^>]+>/g, '');
    return notes.trim();
  }

  // ── Import du NPC ─────────────────────────────────────
  // Si `token` est fourni (mode token), le token est automatiquement
  // lié au personnage créé (represents) et renommé.

  function importerNpc(data, who, token) {
    if (!data || !data.character || !data.attributes) {
      whisper(who, '❌ Format JSON invalide (clés "character" et "attributes" requises).');
      return;
    }

    var charName = data.character.name || 'NPC importé';
    var avatar   = data.character.avatar || '';

    // Vérifier si un personnage du même nom existe déjà
    var existants = findObjs({ _type: 'character', name: charName });
    if (existants.length) {
      whisper(who, '⚠️ Un personnage nommé **' + charName + '** existe déjà.'
        + ' Renommez le handout/token source ou supprimez le doublon avant d\'importer.');
      return;
    }

    // Créer le personnage
    var charObj = createObj('character', {
      name:   charName,
      avatar: avatar,
    });

    if (!charObj) {
      whisper(who, '❌ Impossible de créer le personnage.');
      return;
    }

    var charId  = charObj.id;
    var nbOk    = 0;
    var nbTotal = data.attributes.length;

    // Créer tous les attributs (current + max)
    for (var i = 0; i < nbTotal; i++) {
      var a = data.attributes[i];
      if (!a || !a.name) continue;
      var obj = createObj('attribute', {
        characterid: charId,
        name:        String(a.name),
        current:     a.current !== undefined ? a.current : '',
        max:         a.max     !== undefined ? a.max     : '',
      });
      if (obj) nbOk++;
    }

    // Mode token : lier le token au personnage et le renommer
    if (token) {
      token.set({
        represents: charId,
        name:       charName,
      });
      whisper(who,
        '✅ **' + charName + '** importé et lié au token sélectionné.'
        + ' (' + nbOk + '/' + nbTotal + ' attributs créés)'
      );
      log('[ImportNPC] Import token terminé : ' + charName + ' (charId=' + charId
        + ', tokenId=' + token.id + ', attrs=' + nbOk + '/' + nbTotal + ')');
      return;
    }

    whisper(who,
      '✅ **' + charName + '** importé avec succès dans la bibliothèque.'
      + ' (' + nbOk + '/' + nbTotal + ' attributs créés)'
    );
    log('[ImportNPC] Import handout terminé : ' + charName + ' (charId=' + charId
      + ', attrs=' + nbOk + '/' + nbTotal + ')');
  }

  // ── Utilitaire whisper ────────────────────────────────

  function whisper(who, msg) {
    sendChat('ImportNPC', '/w ' + who + ' ' + msg);
  }

  return { CMD_HANDOUT: CMD_HANDOUT, CMD_TOKEN: CMD_TOKEN };
}());
