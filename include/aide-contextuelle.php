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
      <ul>
        <li>Cellule <strong>vide</strong> : fusion avec la cellule de gauche.</li>
        <li>Cellule <code>^</code> : fusion avec la cellule du dessus.</li>
      </ul>
      <p>Dans une ligne de données, une cellule vide reste une cellule vide —
      c\'est ce qui permet les grilles à colonnes inégales.</p>

      <p><strong>Exemple — en-tête sur deux niveaux</strong></p>
      <pre class="aide-exemple">! | Rythme | | | Effet
! Distance par… | Rapide | Normal | Lent | ^
Minute | 120 m | 90 m | 60 m | —</pre>

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

];
