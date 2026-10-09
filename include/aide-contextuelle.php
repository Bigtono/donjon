<?
// include/aide-contextuelle.php — Contenu des bulles d'aide contextuelle
// Chaque entrée est une closure (PDO $db, int $ruleset_id) -> string HTML,
// résolue par include/ajax/aide.php. Permet d'inclure du contenu dynamique
// (requête base) sans changer l'API d'appel côté formulaire (aideIcone()).
//
// ⚠ Chaque clé doit décrire EXACTEMENT les parsers appliqués à son champ.
// Tous les champs ne subissent pas les mêmes passes :
//
//   Champ                        | Parsers au rendu
//   -----------------------------|--------------------------------------------
//   reg_texte, descriptions      | lierGlossaireAuto() + resoudreTagsTableaux()
//   du compendium                |   -> glossaire auto + [[tab:slug]]
//   tab_contenu (cellules)       | resoudreTagsExplicites()
//                                |   -> #don# $sort$ &objet& @id@ %id%
//   mo_stats                     | resoudreTagsExplicites() + lierAuto()
//                                |   + [[tab:slug]] (ligne seule)
//
// Annoncer un tag là où il n'est pas résolu se paie en saisies inutilisables.
// Référence : doc/DECISIONS_LOG.md [2026-06-25] — système d'aide contextuelle.
//             doc/ARCHITECTURE_0_REFERENCE.md §9c (tableaux) et §9d (glossaire).

return [

  // ==========================================================
  // Champs de prose : reg_texte + les 9 descriptions du compendium
  // Parsers : lierGlossaireAuto() puis resoudreTagsTableaux()
  // ==========================================================
  'texte-parsers' => function (PDO $db, int $ruleset_id): string {
    // Nombre de termes de glossaire réellement disponibles : sur un ruleset
    // qui n'en a pas encore (DD3.5), autant le dire plutôt que de laisser
    // l'utilisateur attendre des renvois qui ne viendront jamais.
    $stmt = $db->prepare("
      SELECT COUNT(*) FROM dd_regles
      WHERE  reg_type = 'glossaire' AND reg_visible = 1
        AND  reg_camp_id IS NULL AND reg_ruleset_var_id = ?
    ");
    $stmt->execute([$ruleset_id]);
    $nb = (int)$stmt->fetchColumn();

    $glossaire = $nb > 0
      ? '<p><strong>Renvois de glossaire — automatiques.</strong> Les '
        . $nb . ' termes du glossaire de ce ruleset deviennent cliquables
        dès qu\'ils apparaissent dans le texte. Rien à saisir.</p>
        <ul>
          <li><strong>La casse doit être exacte</strong> : « le Désavantage »
          est lié, « un désavantage » ne l\'est pas. C\'est ce qui distingue
          le terme de jeu du mot courant.</li>
          <li>Seule la <strong>première occurrence</strong> de chaque terme
          est liée — au-delà, c\'est du bruit.</li>
          <li>Le pluriel simple est reconnu (« Chutes » → « Chute »).</li>
          <li>Aucun renvoi n\'est posé dans un titre, un lien existant,
          du code ou à l\'intérieur d\'un tableau.</li>
        </ul>'
      : '<p><strong>Renvois de glossaire.</strong> Aucun terme de glossaire
        n\'est encore saisi pour ce ruleset : aucun renvoi ne sera produit.</p>';

    return '
      <p>Ce champ est enrichi <strong>à l\'affichage</strong>. Rien n\'est
      transformé en base : le texte saisi reste tel quel.</p>

      <p><strong>Insérer un tableau</strong></p>
      <ul>
        <li><code>[[tab:slug]]</code> — affiche un tableau de la bibliothèque.</li>
        <li>Le tag doit être <strong>seul dans son paragraphe</strong>.</li>
        <li>Le bouton <em>tableau</em> de la barre d\'outils l\'insère
        correctement : préférez-le à la saisie manuelle.</li>
        <li>Un slug inconnu s\'affiche en rouge encadré au lieu du tableau.</li>
      </ul>

      ' . $glossaire . '

      <p class="aide-note">Les tags <code>#don#</code>, <code>$sort$</code>,
      <code>&amp;objet&amp;</code> ne fonctionnent <strong>pas</strong> ici :
      ils sont réservés au bloc de stats des monstres et aux cellules de
      tableau.</p>
    ';
  },

  // ==========================================================
  // Contenu d'un tableau de règles (dd_tableaux.tab_contenu)
  // Parsers : resoudreTagsExplicites() sur chaque cellule
  // ==========================================================
  'tableau-convention' => function (PDO $db, int $ruleset_id): string {
    return '
      <p>Une ligne = une ligne de tableau. <code>|</code> sépare les cellules.
      Aucun HTML : la mise en forme est entièrement gérée par le CSS.</p>

      <table class="aide-table">
        <tr><td><code>!</code></td>
            <td>Ligne d\'en-tête. Plusieurs <code>!</code> consécutifs =
                en-tête sur plusieurs niveaux.</td></tr>
        <tr><td><code>#</code></td>
            <td>Ligne de section, fusionnée sur toute la largeur.</td></tr>
        <tr><td><code>&gt;</code></td>
            <td>Note affichée sous le tableau.</td></tr>
        <tr><td><em>(rien)</em></td>
            <td>Ligne de données.</td></tr>
        <tr><td><em>(vide)</em></td>
            <td>Ligne ignorée — sert à aérer la saisie.</td></tr>
      </table>

      <p><strong>Fusions — uniquement dans les lignes <code>!</code></strong></p>

      <p><em>Horizontale</em> — une cellule <strong>vide</strong> est absorbée par
      la cellule de gauche. Comptez <strong>une cellule vide par colonne à
      absorber</strong>.</p>

      <p><strong>⚠ Le <code>|</code> de fermeture.</strong> Une cellule vide en
      fin de ligne est ignorée (pour qu\'on puisse terminer une ligne par
      <code>|</code> sans créer de colonne fantôme). Si la fusion va jusqu\'à la
      <strong>dernière</strong> colonne du tableau, ajoutez donc un
      <code>|</code> supplémentaire.</p>

      <p>Exemples sur un tableau de <strong>6 colonnes</strong> :</p>
      <pre class="aide-exemple">Fusionner 4 et 5
! C1 | C2 | C3 | Groupe | | C6

Fusionner 3 à 6 — dernière colonne incluse,
donc un | de plus en fin de ligne
! C1 | C2 | Groupe | | | |

Deux groupes : 2-3 et 5-6
! C1 | G1 | | C4 | G2 | |</pre>

      <p><em>Verticale</em> — une cellule <code>^</code> est absorbée par la
      cellule du dessus, dans la même colonne.</p>

      <pre class="aide-exemple">! C1 | C2 | C3 | Groupe | | C6
! ^  | ^  | ^  | C4 | C5 | ^</pre>

      <p>Le second niveau ne déclare que les colonnes réellement subdivisées :
      les <code>^</code> font descendre les autres en-têtes sur les deux lignes.</p>

      <p>Dans une ligne de <strong>données</strong>, aucune fusion : une cellule
      vide reste une cellule vide — c\'est ce qui permet les grilles à colonnes
      inégales.</p>

      <p><strong>Liens dans les cellules</strong></p>
      <ul>
        <li><code>#Nom du don#</code> — don, par nom</li>
        <li><code>$Nom du sort$</code> — sort, par nom</li>
        <li><code>&amp;Nom de l\'objet&amp;</code> — objet magique, par nom</li>
        <li><code>@id@</code> — règle, par identifiant</li>
        <li><code>%id%</code> — terme de glossaire, par identifiant</li>
      </ul>

      <p class="aide-note">Le nombre de colonnes est déduit de la ligne la plus
      large ; les lignes plus courtes sont complétées automatiquement.
      L\'alignement ne se saisit pas ici mais dans le champ
      <em>Alignement</em>.</p>
    ';
  },

  // ==========================================================
  // Bloc de stats d'un monstre (mo_stats)
  // Parsers : resoudreTagsExplicites() + lierAuto() + [[tab:slug]]
  // ==========================================================
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

      <p><strong>Insérer un tableau</strong></p>
      <ul>
        <li><code>[[tab:slug]]</code> — affiche un tableau de la bibliothèque.</li>
        <li>Le tag doit occuper <strong>une ligne à lui seul</strong> ; sur une
        ligne partagée avec du texte, il ne sera pas résolu.</li>
      </ul>
    ';
  },

  // ==========================================================
  // Vue Magie du personnage (SP-PE7b)
  // Les libellés étaient auparavant en clair sous chaque titre de bloc :
  // ils encombraient la lecture pour une information qu'on ne consulte
  // qu'une fois. Passés en bulle, et reformulés pour dire le POURQUOI.
  // ==========================================================

  'magie-prepares' => function (PDO $db, int $ruleset_id): string {
    return $ruleset_id === 1
      ? '<p><strong>Les sorts que vous pouvez lancer aujourd\'hui.</strong></p>
         <p>En DD3.5, préparer un sort revient à <em>réserver un emplacement pour ce
         sort précis</em> : une fois lancé, l\'emplacement est consommé et ne peut
         pas servir à autre chose.</p>
         <p>Un même sort peut être préparé plusieurs fois — il occupe alors autant
         d\'emplacements et peut être lancé autant de fois.</p>
         <p>La liste se refait après une nuit de repos et la période de préparation
         propre à la classe.</p>'
      : '<p><strong>Les sorts que vous rendez disponibles pour la journée.</strong></p>
         <p>En DD2024, préparer ne réserve rien : les emplacements sont une réserve
         générique. Vous choisissez au moment de lancer quel sort préparé utiliser,
         et avec quel niveau d\'emplacement.</p>
         <p>Les sorts <em>toujours préparés</em>, accordés par votre classe ou votre
         sous-classe, s\'ajoutent à cette liste <strong>sans compter</strong> dans
         le plafond.</p>';
  },

  'magie-grimoire' => function (PDO $db, int $ruleset_id): string {
    return '<p><strong>Les sorts que vous pouvez préparer.</strong></p>
      <p>Un sort n\'est préparable qu\'une fois <em>recopié dans votre grimoire</em>.
      C\'est le grimoire, et non la liste de la classe, qui borne ce que vous
      pouvez mémoriser chaque jour.</p>
      <p>Il s\'enrichit de deux sorts à chaque niveau gagné, et par la copie des
      parchemins et grimoires trouvés en aventure.</p>';
  },

  'magie-connus' => function (PDO $db, int $ruleset_id): string {
    return '<p><strong>Ce que vous avez sous la main, sans pouvoir encore l\'utiliser.</strong></p>
      <p>Parchemins ramassés, grimoire d\'un adversaire, sort aperçu chez un
      confrère : vous y avez accès, mais tant qu\'il n\'est pas recopié dans votre
      propre grimoire, il <strong>n\'est pas préparable</strong>.</p>
      <p>Notez-les ici pour ne pas les oublier, puis recopiez-les quand vous en
      aurez le temps et les fonds — comptez une journée et 100 po par page.</p>';
  },

  'magie-emplacements' => function (PDO $db, int $ruleset_id): string {
    return $ruleset_id === 1
      ? '<p><strong>Combien de sorts de chaque niveau vous pouvez lancer par jour.</strong></p>
         <p>Le total additionne la table de votre classe (lue à votre niveau de
         lanceur effectif), les sorts en bonus dus à votre caractéristique, et
         l\'emplacement de domaine si votre classe en accorde un.</p>
         <p>Un <strong>0</strong> ne signifie pas « aucun sort » : le niveau vous
         est accessible, mais par les seuls sorts en bonus.</p>
         <p>Survolez un chiffre pour voir sa décomposition.</p>'
      : '<p><strong>Votre réserve de puissance pour la journée.</strong></p>
         <p>Un emplacement peut lancer n\'importe quel sort préparé de son niveau
         ou d\'un niveau inférieur. Dépenser un emplacement plus élevé rend le sort
         plus puissant lorsque sa description le prévoit.</p>
         <p>Tous les emplacements sont restitués après un repos long.</p>';
  },

];