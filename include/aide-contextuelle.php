<?
// include/aide-contextuelle.php — Contenu des bulles d'aide contextuelle
// Chaque entrée est une closure (PDO $db, int $ruleset_id) -> string HTML,
// résolue par include/ajax/aide.php. Permet d'inclure du contenu dynamique
// (requête base) sans changer l'API d'appel côté formulaire (aideIcone()).
// Référence : doc/DECISIONS_LOG.md [2026-06-25] — système d'aide contextuelle.

return [

  'monstre-tags-description' => function (PDO $db, int $ruleset_id): string {
    return '
      <p>Le texte de la description peut contenir des tags résolus
      automatiquement en liens cliquables :</p>
      <ul>
        <li><code>#Nom#</code> — don, par nom</li>
        <li><code>$Nom$</code> — sort, par nom</li>
        <li><code>&amp;Nom&amp;</code> — objet magique, par nom</li>
        <li><code>@id@</code> — règle, par identifiant</li>
        <li><code>%id%</code> — terme de glossaire, par identifiant</li>
      </ul>
      <p>Les noms de sorts, dons et objets connus du compendium sont aussi
      liés automatiquement sans tag, dès qu\'ils apparaissent tels quels
      dans le texte.</p>
    ';
  },

];
