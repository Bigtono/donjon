// ============================================================
// ImportNPC.js — Script Roll20 API (Pro requis)
// ============================================================
// Importe un personnage NPC dans Roll20 à partir d'un JSON
// généré par Codex DD (include/ajax/export/monstre-roll20.php).
//
// PRÉREQUIS
//   - Compte Roll20 Pro avec accès à l'API
//   - Coller le JSON dans un Handout Roll20 (onglet GM Notes)
//
// UTILISATION
//   1. Ouvrir la campagne Roll20
//   2. Créer un Handout nommé "Import NPC" (ou autre)
//   3. Dans l'onglet "GM Notes", coller le contenu du fichier .json
//   4. Dans le chat, taper : !import-npc
//      (ou !import-npc MonHandout si le nom n'est pas "Import NPC")
//   5. Le personnage est créé dans la bibliothèque de personnages
//
// V2 PRÉVUE
//   - Support spelloutput = "ATTACK" pour les sorts offensifs des PNJ
//     (nécessite la résolution sort → jet d'attaque Roll20)
//   - Champ d'avatar : URL image à renseigner manuellement pour l'instant
// ============================================================

var ImportNPC = ImportNPC || (function () {
  'use strict';

  var HANDOUT_DEFAULT = 'Import NPC';
  var CMD             = '!import-npc';

  // ── Écoute des commandes chat ─────────────────────────

  on('ready', function () {
    log('[ImportNPC] Prêt. Commande : ' + CMD + ' [nom_handout]');
  });

  on('chat:message', function (msg) {
    if (msg.type !== 'api') return;
    if (msg.content.indexOf(CMD) !== 0) return;

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
        var json = nettoyerNotes(notes);
        var data;
        try {
          data = JSON.parse(json);
        } catch (e) {
          whisper(msg.who, '❌ JSON invalide : ' + e.message);
          return;
        }
        importerNpc(data, msg.who);
      });
    });
  });

  // ── Recherche du handout ──────────────────────────────

  function trouverHandout(nom, callback) {
    var handouts = findObjs({ _type: 'handout', name: nom });
    callback(handouts.length ? handouts[0] : null);
  }

  // ── Nettoyage des GM Notes ────────────────────────────
  // Roll20 encode les GM Notes en HTML et en URI (unescape).

  function nettoyerNotes(notes) {
    // Décoder l'URI encoding de Roll20
    try {
      notes = unescape(notes);
    } catch (e) { /* pas encodé */ }
    // Supprimer les balises HTML (Roll20 wrapper <div> etc.)
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

  function importerNpc(data, who) {
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
        + ' Renommez le handout source ou supprimez le doublon avant d\'importer.');
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

    whisper(who,
      '✅ **' + charName + '** importé avec succès.'
      + ' (' + nbOk + '/' + nbTotal + ' attributs créés)'
    );
    log('[ImportNPC] Import terminé : ' + charName + ' (charId=' + charId
      + ', attrs=' + nbOk + '/' + nbTotal + ')');
  }

  // ── Utilitaire whisper ────────────────────────────────

  function whisper(who, msg) {
    sendChat('ImportNPC', '/w ' + who + ' ' + msg);
  }

  return { CMD: CMD };
}());
