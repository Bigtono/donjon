// ============================================================
// CharacterExport.js — Script Roll20 API (Pro requis)
// ============================================================
// Exporte une fiche de personnage de Roll20 au format JSON
//
// PRÉREQUIS
//   - Compte Roll20 Pro avec accès à l'API
//
// 1. sélectionner le token du personnage ;
// 2. lancer !export-char ;
// 3. le script récupère tous les attributs de la fiche ;
// 4. il les transforme en JSON ;
// 5. le JSON est placé dans le handout « Character Export » (pratique pour les gros volumes de données).
// ============================================================

on('chat:message', function (msg) {
  if (msg.type !== 'api')
    return;

  if (!msg.content.startsWith('!export-char'))
    return;

  if (!msg.selected || !msg.selected.length) {
    sendChat('Export', '/w "' + msg.who + '" Sélectionnez un token.');
    return;
  }

  const token = getObj('graphic', msg.selected[0]._id);

  if (!token)
    return;

  const character = getObj('character', token.get('represents'));

  if (!character) {
    sendChat('Export', '/w "' + msg.who + '" Le token n\'est lié à aucun personnage.');
    return;
  }

  const attrs = findObjs({
    type: 'attribute',
    characterid: character.id
  });

  const exportData = {
    character: {
      id: character.id,
      name: character.get('name'),
      avatar: character.get('avatar'),
      bio: character.get('bio'),
      gmnotes: character.get('gmnotes')
    },
    attributes: []
  };

  attrs.forEach(function (attr) {
    exportData.attributes.push({
      name: attr.get('name'),
      current: attr.get('current'),
      max: attr.get('max')
    });
  });

  exportData.attributes.sort(function (a, b) {
    return a.name.localeCompare(b.name);
  });

  const json = JSON.stringify(exportData, null, 2);

  let handout = findObjs({
    type: 'handout',
    name: 'Character Export'
  })[0];

  if (!handout) {
    handout = createObj('handout', {
      name: 'Character Export'
    });
  }

  handout.set('notes', '<pre>' + _.escape(json) + '</pre>');

  sendChat(
    'Export',
    '/w "' + msg.who + '" Export terminé : handout "Character Export".'
  );
});