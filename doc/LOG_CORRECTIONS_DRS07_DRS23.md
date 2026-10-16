<!-- Mis à jour : 2026-10-15 12:00 -->

# Journal des corrections — import du DRS 07 (Équipement) et du DRS 23 (Objets magiques)

> Demandé le 2026-10-11 : le texte du DRS est repris tel quel **sauf** corrections de coquilles
> évidentes, toutes listées ici pour relecture ultérieure. Les PDF sources sont
> `DRS 07 (équipement).pdf` et `DRS 23 (objets magiques).pdf`
> (`C:\Users\jm-ml\OneDrive\Documents\JDR\D&D\DD 3.5\SRD\`).
>
> Les textes corrigés vivent dans trois fichiers de migration :
> `sql/2026-10-11_equipements_dd35_drs07_sp-po2.sql` (articles du compendium),
> `sql/2026-10-11_regles_dd35_drs07_sp-drs2.sql` et `…_drs23_sp-drs3.sql` (règles).
> Chaque ligne indique le fichier concerné : **EQ** = articles, **R07** = règles Équipement,
> **R23** = règles Objets magiques.

## 1. Normalisations globales (toutes les sources)

| # | Source | Traitement |
|---|---|---|
| G1 | Apostrophes typographiques `’` | remplacées par `'` (cohérent avec les lots DRS déjà importés) |
| G2 | Guillemets anglais `“ … ”` | remplacés par `« … »` |
| G3 | Multiplicateur extrait en `´` (accent aigu) ou `x` | rétabli en `×` (« ×2 », « 750 po × niveau… ») |
| G4 | Chiffres de note collés aux valeurs (« 1d23 », « +43 », « Fouet4 ») | séparés ; les notes sont devenues la colonne « Particularités » des armes (non létal, arme à allonge, arme double) ou des phrases de description |
| G5 | Poids « 0,5 kg » | écrit « 500 g » (cohérence de l'unité) |
| G6 | Espaces insécables dans prix et poids affichés | ajoutés au rendu (« 1 500 po ») ; la base stocke des nombres (pièces de cuivre, grammes) |

## 2. Coquilles corrigées

| # | Où | Texte du PDF | Correction |
|---|---|---|---|
| C1 | EQ — Arbalète lourde | « combat à deux armes à une **mai** » | « …à une **main** » |
| C2 | EQ — Arbalètes à répétition | « utilisée à une main ou à une dans chaque main » | « à une main, ou à raison d'une dans chaque main, » |
| C3 | EQ — Armure à pointes | la table de armes l'appelle « Arme à pointes » ; la description et le supplément disent « armure à pointes » | « **Armure** à pointes » |
| C4 | EQ — Nunchaku | la phrase « Le nunchaku est une arme de moine… » figure deux fois | un seul exemplaire conservé |
| C5 | EQ — Rondaches, écus | « Voir Les **amures** » | « Voir la section sur les armures (*Rondache en bois ou en acier*) » (renvoi reformulé) |
| C6 | EQ — Gantelet | « lorsqu'**il** se bat à coups de poings » | « lorsqu'**on** se bat… » |
| C7 | EQ — Trousse de déguisement | poids « 4 kg† » | « 4 kg » (symbole parasite) |
| C8 | EQ — Matériel d'escalade | « **Cet** outils idéaux » | « **Ces** outils idéaux » |
| C9 | EQ — Âne ou mulet | « Peu craintif, ils ont… s'avère capable… ne **lui** fasse guère plaisir » | « Peu craintifs, ils… s'avèrent capables… ne **leur** fasse guère plaisir » |
| C10 | EQ — Barque | « **Il** se déplace » | « **Elle** se déplace » |
| C11 | EQ — Habit de cour | « les **test** de compétence **associées** au Charisme » | « les **tests** de compétence **associés** » |
| C12 | R07 — Armures de maître | « **Tous les armures** et boucliers magiques » | « **Toutes les armures et tous les boucliers** magiques » |
| C13 | R07 — Catégories d'armes | « Les personnages **des toutes** les classes » | « …**de toutes** les classes » |
| C14 | R07 — Armes de maître | « Les armures et boucliers **de maîtres** » | « …**de maître** » |
| C15 | R23 — Coût de composante | « c'est le cas de **tous les baguettes**, bâtons… » | « de **toutes les baguettes**, de **tous les bâtons**, parchemins… » |
| C16 | R23 — Ajout de propriétés | « à **un l'objet** occupant » | « à **un objet** occupant » |
| C17 | R23 — Estimation du prix | « **Ajustement** finaux » | « **Ajustements** finaux » |
| C18 | R23 — Objets intelligents | « niveau de **lancer** de sorts » | « niveau de **lanceur** de sorts » |
| C19 | R23 — Table d'estimation | « Bonus à **un** armure » | « Bonus à **une** armure » |
| C20 | R23 — Table d'estimation | « au-dessus de **MR** 12 (**MR** 13 minimum) » (sigle anglais) | « **RM** 12 / **RM** 13 » |
| C21 | R23 — Objets à effets multiples | « 75 % du prix **de** deuxième effet » | « du prix **du** deuxième effet » |
| C22 | R23 — Table des potions et huiles | « 1 050 **p o** » (coupure de ligne) | « 1 050 po » |

## 3. Structure et contenu modifiés (hors coquilles)

| # | Où | Changement |
|---|---|---|
| S1 | EQ — Munitions | « Carreaux (10) » figure deux fois (arbalètes légère et lourde) → **une seule ligne** ; « Flèches (20) » figure quatre fois (une par arc) → **une seule ligne** ; « Billes (10) » devient « Billes de fronde (10) » ; les carreaux d'arbalète de poing et à répétition sont distingués par leur nom |
| S2 | EQ — Articles à variantes | éclatés en articles distincts : cadenas (4 qualités), bière (chope / litre), repas (3 qualités), séjour à l'auberge (3 qualités), vin (table / bon cru), selles (3) et selles spéciales (3), bardes (taille M / G), sorts à la demande (niveaux 0 à 9) |
| S3 | EQ — Descriptions communes | un texte décrivant plusieurs articles (« Menottes et menottes de qualité supérieure », « Rondache en bois ou en acier », « Écu en bois ou en acier », « Cadenas », « Barde », « Selle spéciale », « Destriers et poneys de guerre ») est **recopié sur chaque article concerné** |
| S4 | EQ — Armures | note 2 de la table (vitesse en armure lourde multipliée par 3) → ajoutée à la description des 4 armures lourdes ; note 3 du pavois → déjà dans sa description ; note 4 du gantelet d'armes → note sous la liste des armures (R07) |
| S5 | EQ — Eau bénite, torche éternelle | ajout de « ne peut pas être fabriquée à l'aide de la compétence Artisanat (alchimie) », tiré de l'introduction de la section « Substances spéciales » du PDF |
| S6 | EQ — Symboles sacrés | la description (commune) est portée par les deux articles ; le **symbole impie**, décrit mais absent de la table, figure dans le texte de R07 (liste des marchandises) et non comme article |
| S7 | EQ/R07 — Renvois de table | « Table : armes », « Table : armures et boucliers », etc. → « liste des armes », « liste des armures et boucliers » (ce sont désormais des listes dynamiques) |
| S8 | R07 — Tableaux | les tables « armes », « armures et boucliers » et « marchandises et services » ne sont plus des `dd_tableaux` : ce sont des **listes dynamiques** `[[liste:equipement|…]]`. Restent en tableaux statiques : types de pièces, produits de consommation courante, dégâts TP/G, armures pour créatures inhabituelles, enfiler/ôter, vitesse des bardes |
| S9 | R07 — Table des types de pièces | en-tête sur deux niveaux (« Valeur d'échange ») rétabli à partir du PDF |
| S10 | R23 — Table « Résumé des coûts de création » | la note ² de la ligne « Objet merveilleux » (« Non² ») n'existe pas dans le PDF → affichée « Non » |
| S11 | R23 — Tables de prix des baguettes, parchemins, potions | en-tête « Classe » ajouté au-dessus des colonnes `Dru, Mag, Prê / Ens / Bard / Pal, Rôd` (abréviations du PDF conservées) |
| S12 | R23 — Renvois | « Selon la Table : armes » → « Selon la table des armes » ; « voir la Table : estimation du prix des objets magiques » → « voir la table d'estimation du prix des objets magiques » |
| S13 | R23 — Renvoi sans cible | « Table : Intelligence, Sagesse, Charisme et propriétés des objets intelligents » et les tables de pouvoirs mineurs, majeurs et dédiés relèvent du **DRS 28**, non importé : le renvoi est laissé en texte simple |
| S14 | R23 — Titres | « Utilisation des objets » (source) ; « Détection de la magie et les objets magiques » raccourci en « Détection de la magie et objets magiques » ; les quatre modes d'activation reçoivent un `<h3>` |
| S15 | R23 — **Page ajoutée** | « Catalogue des objets magiques » : n'existe pas dans le DRS ; sert de démonstration du tag `[[liste:objet|…]]` avec une liste par catégorie |
| S16 | R07/R23 — Glossaire | 12 + 9 termes ajoutés (voir les fichiers de migration) — définitions écrites pour le projet, non issues du PDF |

## 4. À vérifier à la relecture

- **S1** : la fusion des munitions est la seule perte de lignes par rapport aux tables du PDF.
- **C3** : le PDF est cohérent en interne sur « armure à pointes » (description) ; la table du DRS anglais dit *armor spikes*.
- **S10** : retrouver la note ² dans le DRS 23 papier si elle existe.
- Valeurs lues sur le PDF en mode texte brut : un recoupement visuel des trois grandes tables (armes, armures, marchandises) est recommandé — les listes sont maintenant des données du compendium, modifiables article par article.

## 5. Source des articles (2026-10-15)

Les 269 articles ne sont plus rattachés à « DRS 3.5 » mais au **Manuel des joueurs 3.5** (`MdJ3.5`) :
`sql/2026-10-15_equipements_dd35_source_sp-po2b.sql`. Les pages de règles restent sous « DRS 3.5 ».
