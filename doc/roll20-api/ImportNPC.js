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
// VERSIONS 
//  v1.0 : verison original
//  v1.0.1 : corrections de bugs d'imports
//  v1.0.2 : corrections de bugs d'imports
//  V1.2 : ajout fonction d'import depuis un token
//  v1.2.1 : met à jour le token par défaut de la fiche depuis le token ayant servi à l'import
//  v1.3 : - "Chuchoter les jets au MJ" forcé à Toujours (wtype) sur la fiche importée,
//           en filet de sécurité indépendant du JSON source
//         - Mode token : redimensionne le token à 70x70 px
//         - Mode token : configure les barres (Barre1=CA, Barre2=Perception passive,
//           Barre3=PV) et la position des barres sur "En dessous"
//         - Mode token : utilise setDefaultTokenForCharacter() pour que ces réglages
//           soient aussi repris dans le token par défaut de la fiche
//
// V2 PRÉVUE
//   - Support spelloutput = "ATTACK" pour les sorts offensifs des PNJ
//     (nécessite la résolution sort → jet d'attaque Roll20)
//   - Champ d'avatar : URL image à renseigner manuellement pour l'instant
// ============================================================

var ImportNPC = ImportNPC || (function () {
  'use strict';

  var HANDOUT_DEFAULT = 'Import NPC';
  var CMD_HANDOUT = '!import-npc';
  var CMD_TOKEN = '!import-npc-token';
  var CMD_PING = '!import-npc-ping';

  // ── Écoute des commandes chat ─────────────────────────

  on('ready', function () {
    log('[ImportNPC] v1.3 chargé et prêt. Commandes disponibles : '
      + CMD_HANDOUT + ' [nom_handout]  |  '
      + CMD_TOKEN + ' (token sélectionné)  |  '
      + CMD_PING + ' (test de connectivité)');
  });

  on('chat:message', function (msg) {
    try {
      handleMessage(msg);
    } catch (e) {
      // Toute exception est journalisée dans l'API Console ET chuchotée
      // au joueur, pour éviter un échec totalement silencieux.
      log('[ImportNPC] ERREUR : ' + (e && e.stack ? e.stack : e));
      if (msg && msg.who) {
        sendChat('ImportNPC', '/w ' + msg.who
          + ' ❌ Erreur interne du script (voir API Console pour le détail).');
      }
    }
  });

  function handleMessage(msg) {
    if (msg.type !== 'api') return;

    // ── Test de connectivité ──────────────────────────
    if (msg.content.indexOf(CMD_PING) === 0) {
      whisper(msg.who, '✅ ImportNPC est actif et reçoit bien les commandes.');
      log('[ImportNPC] Ping reçu de ' + msg.who);
      return;
    }

    // ── Mode token sélectionné ───────────────────────
    if (msg.content.indexOf(CMD_TOKEN) === 0) {
      importerDepuisToken(msg);
      return;
    }

    // ── Mode handout ──────────────────────────────────
    if (msg.content.indexOf(CMD_HANDOUT) === 0) {
      var parts = msg.content.split(/\s+/);
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
  }

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

    // ⚠ Contrairement à Character/Handout (où notes/gmnotes/bio sont
    // asynchrones et nécessitent un callback), gmnotes sur un Graphic
    // (token) est une propriété SYNCHRONE. Utiliser le pattern callback
    // ici fait que le callback n'est tout simplement jamais invoqué —
    // aucune exception, aucun message, silence total.
    var notes = token.get('gmnotes');

    if (!notes || notes === 'null') {
      whisper(msg.who, '❌ Les GM Notes de ce token sont vides. Collez-y le JSON exporté'
        + ' depuis Codex DD (clic droit sur le token > Modifier > GM Notes).');
      return;
    }
    var data = parserJsonDepuisNotes(notes, msg.who);
    if (data) importerNpc(data, msg.who, token);
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
    var avatar = data.character.avatar || '';

    // Vérifier si un personnage du même nom existe déjà
    var existants = findObjs({ _type: 'character', name: charName });
    if (existants.length) {
      whisper(who, '⚠️ Un personnage nommé **' + charName + '** existe déjà.'
        + ' Renommez le handout/token source ou supprimez le doublon avant d\'importer.');
      return;
    }

    // Créer le personnage
    var charObj = createObj('character', {
      name: charName,
      avatar: avatar,
    });

    if (!charObj) {
      whisper(who, '❌ Impossible de créer le personnage.');
      return;
    }

    var charId = charObj.id;
    var nbOk = 0;
    var nbTotal = data.attributes.length;

    // Conserve une référence par nom vers chaque attribut créé : nécessaire
    // pour forcer wtype, et pour lier les barres de jeton (CA/Perception
    // passive/PV) en mode token.
    var attrByName = {};

    // Créer tous les attributs (current + max)
    for (var i = 0; i < nbTotal; i++) {
      var a = data.attributes[i];
      if (!a || !a.name) continue;
      var obj = createObj('attribute', {
        characterid: charId,
        name: String(a.name),
        current: a.current !== undefined ? a.current : '',
        max: a.max !== undefined ? a.max : '',
      });
      if (obj) {
        nbOk++;
        attrByName[String(a.name)] = obj;
      }
    }

    // "Chuchoter les jets au MJ" forcé à Toujours (wtype = '/w gm '), en
    // filet de sécurité indépendant de ce que contient le JSON source —
    // garantit ce comportement même si l'export PHP venait à régresser.
    forcerWhisperToujours(attrByName, charId);

    // Mode token : lier le token au personnage, le renommer, le redimensionner,
    // configurer ses barres, puis synchroniser avatar + token par défaut de la
    // fiche depuis ce même token via setDefaultTokenForCharacter().
    // (Lier représente le token <-> fiche pour les jets, mais ne copie pas
    //  l'image ni les réglages visuels : la fiche et le token restent deux
    //  objets distincts tant qu'on ne les synchronise pas explicitement.)
    if (token) {
      token.set({
        represents: charId,
        name: charName,
        width: 70,
        height: 70,
        bar_location: 'bottom', // "Options des barres de jeton" > Position = En dessous
      });

      configurerBarresToken(token, attrByName);

      var imgsrc = token.get('imgsrc');
      var cleanSrc = getCleanImgsrc(imgsrc);
      if (cleanSrc) {
        charObj.set({ avatar: cleanSrc });
      } else {
        log('[ImportNPC] Avertissement : image du token (' + imgsrc + ') hors bibliothèque'
          + ' utilisateur — avatar non synchronisé (limitation API Roll20).');
      }

      // _defaulttoken est en lecture seule côté API : on ne peut pas l'écrire
      // directement. setDefaultTokenForCharacter() est la fonction utilitaire
      // Roll20 dédiée à cet usage — elle capture l'état COURANT du token
      // (image, taille, barres, position des barres...) donc elle doit être
      // appelée en dernier, après toutes les modifications ci-dessus.
      setDefaultTokenForCharacter(charObj, token);

      whisper(who,
        '✅ **' + charName + '** importé et lié au token sélectionné.'
        + (cleanSrc ? ' Avatar et token par défaut synchronisés.' : ' ⚠️ Avatar non synchronisé (image hors bibliothèque).')
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

  // ── Chuchotage forcé des jets au MJ ───────────────────
  // wtype porte directement la valeur utilisée dans les macros de jet
  // Roll20 (@{wtype}&{template:...}). '/w gm ' = chuchotage systématique,
  // quoi que contienne le JSON source.

  function forcerWhisperToujours(attrByName, charId) {
    if (attrByName.wtype) {
      attrByName.wtype.set('current', '/w gm ');
    } else {
      var obj = createObj('attribute', {
        characterid: charId,
        name: 'wtype',
        current: '/w gm ',
        max: '',
      });
      if (obj) attrByName.wtype = obj;
    }
  }

  // ── Configuration des barres de jeton ─────────────────
  // Barre 1 = CA (npc_ac), Barre 2 = Perception passive (passive_wisdom),
  // Barre 3 = PV (hp). Décision confirmée par Jean-Michel (2026-06-30).
  // Chaque barre est liée (bar*_link) à l'attribut correspondant : Roll20
  // resynchronise alors automatiquement la barre <-> l'attribut.

  function configurerBarresToken(token, attrByName) {
    appliquerBarre(token, 1, attrByName['npc_ac']);
    appliquerBarre(token, 2, attrByName['passive_wisdom']);
    appliquerBarre(token, 3, attrByName['hp'], true);
  }

  function appliquerBarre(token, numero, attrObj, estPv) {
    if (!attrObj) return;

    var current = attrObj.get('current');
    var max = attrObj.get('max');

    // Filet de sécurité : si les PV courants sont vides (valeur connue côté
    // export pour les nouveaux PNJ), afficher les PV max plutôt qu'une barre
    // vide, et resynchroniser l'attribut en conséquence.
    if (estPv && (current === '' || current === undefined || current === null)) {
      current = max;
      attrObj.set('current', current);
    }

    var props = {};
    props['bar' + numero + '_link'] = attrObj.id;
    props['bar' + numero + '_value'] = current;
    if (max !== '' && max !== undefined && max !== null) {
      props['bar' + numero + '_max'] = max;
    }
    token.set(props);
  }

  // ── Conversion d'une URL d'image vers sa variante "thumb" ─────
  // L'API Roll20 ne peut écrire un avatar/_defaulttoken que si la source
  // est la variante "thumb" d'une image déjà présente dans la bibliothèque
  // utilisateur. Retourne undefined si l'URL ne correspond pas à ce format
  // (image externe, upload hors bibliothèque…).
  // Pattern documenté : Roll20 Wiki > Mod Scripts (API): Cookbook.

  function getCleanImgsrc(imgsrc) {
    var parts = imgsrc && imgsrc.match(/(.*\/images\/.*)(thumb|med|original|max)([^?]*)(\?[^?]+)?$/);
    if (parts) {
      return parts[1] + 'thumb' + parts[3] + (parts[4] ? parts[4] : ('?' + Math.round(Math.random() * 9999999)));
    }
    return undefined;
  }

  // ── Utilitaire whisper ────────────────────────────────

  function whisper(who, msg) {
    sendChat('ImportNPC', '/w ' + who + ' ' + msg);
  }

  return { CMD_HANDOUT: CMD_HANDOUT, CMD_TOKEN: CMD_TOKEN };
}());
