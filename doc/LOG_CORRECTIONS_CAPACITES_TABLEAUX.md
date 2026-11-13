<!-- Mis à jour : 2026-11-11 15:10 -->

# Journal — tableaux HTML des capacités spéciales converties (SP-CR4)

Contrôle des descriptions de `dd_capacites_speciales` : 7 capacités (DD3.5) portaient encore un `<table>` HTML.
Chaque bloc est remplacé par `<p>[[tab:slug]]</p>` et le tableau saisi dans `dd_tableaux` (convention texte, §9c).
Migration : `sql/2026-11-11_sp-cr4_tableaux_capacites_classes.sql`, produite par `tools/generer-sp-cr4-tableaux-capacites.php`
(outil local). Capacités retrouvées par nom + classe / race ; chaque réécriture est gardée par le MD5 du texte local.

| Capacité (local `cap_id`) | Classe / race | Tableau(x) | Catégorie |
|---|---|---|---|
| 31 Compagnon animal (druide) (ext) | Druide | `classe-druide-compagnon-animal` | Classe |
| 44 Appel de familier | Magicien | `classe-magicien-familiers`, `classe-magicien-familier-progression` | Classe |
| 106 Combat à mains nues | Moine | `classe-moine-mains-nues-taille` | Classe |
| 107 Pistage | Rôdeur | `pistage` (existant, créé en local dans l'appli), `classe-rodeur-pistage-modificateurs` | Classe |
| 179 Secret | Olin Gisir | `classe-olin-gisir-secrets` | Classe |
| 275 Particularités célestes | Céleste (**race**) | `race-celeste-particularites` | **Race** |
| 1255 Pistage | Rôdeur bédouin | `pistage` (déjà posé), `classe-rodeur-pistage-modificateurs` (partagé avec 107) | Classe |

Source (`tab_res_id`) : celle de la classe ou de la race concernée ; `pistage` garde le DRS 3.5.

## Retouches de texte

- **Moine** : la légende en gras « Table : dégêts à mains nues des moines de taille P et G » est retirée de la description
  et devient le titre du tableau (« Dégâts à mains nues des moines de taille P et G ») ; « dégêts » corrigé en « dégâts »
  dans le titre et l'en-tête. Le reste du texte de la capacité (qui contient encore « dégêts ») n'est pas touché.
- **Pistage** : « écoutées » → « écoulées » (tranche de 24 heures). Le tableau d'origine avait trois colonnes dont une de retrait
  (23 espaces insécables) et des cellules fusionnées en lignes de données, ce que la convention texte n'autorise pas : il est
  rendu en deux colonnes (Conditions en vigueur / Mod. DD), les lignes de titre de groupe (« Taille des créatures traquées¹ : »,
  « Mauvaise visibilité² : ») ayant leur cellule de modificateur vide et leurs sous-lignes préfixées d'un tiret. Les notes ¹ ²
  restent dans le texte sous le tableau.
- **Familiers** : les exposants `<sup>1</sup>` et `<sup>2</sup>` des cellules « Corbeau » et « Serpent » deviennent `¹` et `²`
  (le contenu d'une cellule est échappé, aucun tableau ne contient de `<sup>`). Les notes restent dans le texte.
- **Compagnon animal** : cellules vides des niveaux 12–14 et 18–20 (« &nbsp; » à l'origine) laissées vides.
- **Particularités célestes** : l'en-tête, saisi en `<td>`, passe en ligne `!`.
- **Secret** : contenu inchangé.

## Hors périmètre, restent à traiter

`<table>` HTML encore présents ailleurs (non demandé) : `dd_races.ra_description` (Demi-dragon), `dd_dons.do_texte`
(Pistage, Compagnon exalté), `dd_sorts.so_description` (5 : Contrôle du climat, Confusion, Convocation de monstre I et III,
Contagion), `dd_objets_magiques.om_description` (5 relevés : flèche mortelle, Boule de cristal, Cartes fantasmagoriques,
Chapelet de prières courant et majeur ; liste non exhaustive, limitée à 5 par table).
