<!-- Mis à jour : 2026-10-16 15:00 -->

# Journal des corrections — import du chapitre « Équipement » du SRD 5.2.1 (DD2024)

> Source : `FR_SRD_CC_v5.2.1-equipements.pdf` (`C:\Users\jm-ml\OneDrive\Documents\JDR\D&D\DD 2024\SRD\`).
> Même principe que pour le DD3.5 (`LOG_CORRECTIONS_DRS07_DRS23.md`) : texte repris tel quel, sauf coquilles
> évidentes, toutes listées ici. **EQ** = articles (`sql/2026-10-16_equipements_dd2024_srd_sp-po5.sql`) ;
> **R** = règles (`sql/2026-10-16_regles_dd2024_equipement_sp-po5.sql`).

## 1. Normalisations globales

| # | Traitement |
|---|---|
| G1 | Apostrophes `’` → `'` ; guillemets conservés en `« … »` |
| G2 | « 3 m x 3 m » → « 3 m × 3 m » ; « 1,50 m x 1,50 m » → « 1,50 m × 1,50 m » |
| G3 | Les renvois à une « table » du chapitre (« table Armes », « table Armures »…) deviennent des renvois à la « liste » : ce sont désormais des listes dynamiques `[[liste:equipement|…]]` |
| G4 | Prix et poids stockés en nombres (pièces de cuivre, grammes) ; « 0,5 kg » est affiché « 500 g », comme pour le DD3.5 (la valeur ne change pas) |

## 2. Coquilles corrigées

| # | Où | Texte du PDF | Correction |
|---|---|---|---|
| C1 | EQ — Billes | « sur une **suface** plane » | « **surface** » |
| C2 | R — Fabrication, Temps | « par **exmple** nécessaires » | « par **exemple** » |
| C3 | R — Harmonisation | « méditation (pour **un** baguette) » | « (pour **une** baguette) » |
| C4 | R — Propriété Finesse | « Lorsque effectuez une attaque » | « Lorsque **vous** effectuez » |

## 3. Structure et contenu modifiés (hors coquilles)

| # | Où | Changement |
|---|---|---|
| S1 | EQ — Boîte de jeux, Instrument de musique | l'entrée générique « (variable) » n'est **pas** un article : chaque variante a le sien (4 jeux, 10 instruments), nommé « Boîte de jeux : dés », « Instrument de musique : luth »…, avec prix et poids propres ; la ligne « Utilisation » est recopiée sur chacun |
| S2 | EQ — Repas, séjour, vin, sorts | lignes éclatées en articles distincts : « Repas misérable »…, « Séjour à l'auberge misérable (par jour) »…, « Vin ordinaire / fin (bouteille) », sept services d'incantation (« Sort des 4e et 5e niveaux », « Sort des 6e à 8e niveaux » regroupent deux niveaux, comme le PDF) |
| S3 | EQ — Armures | la durée pour enfiler/retirer, donnée en tête de chaque catégorie de la table, est recopiée dans la description de chaque armure ; la règle du bouclier (action Utilisation) dans sa description |
| S4 | EQ — Parchemin de sort | « (sort mineur) ou (1er niveau) … respectivement » : le PDF décrit les deux d'un seul texte ; la phrase est ramenée au singulier et copiée sur les deux articles |
| S5 | EQ — Outre | le PDF donne « 2,5 kg (pleine) » : phrase ajoutée à la description (« Le poids indiqué est celui d'une outre pleine ») |
| S6 | EQ — Matériel d'aventurier | les entrées génériques « Munitions », « Focaliseur arcanique », « Focaliseur druidique », « Symbole sacré » (prix et poids « Variable ») sont conservées comme articles, **et** leurs formes ont leur propre ligne dans les familles « Munitions », « Focaliseurs arcaniques », « Focaliseurs druidiques », « Symboles sacrés » |
| S7 | EQ — Selles, employés | les descriptions du texte (« Selles », « Employés ») sont portées par chaque article concerné ; la **Barde** (armure de monture, ×4 prix, ×2 poids) n'est pas un article : elle reste une règle de la page « Montures et véhicules » |
| S8 | EQ — Armes | la table unique est répartie en 4 familles (courantes / de guerre × corps à corps / distance) ; la botte d'arme, les propriétés et les dégâts sont des attributs ; la colonne « Prix » reste en dernière position |
| S9 | R — Train de vie | table « Train de vie » ajoutée (le PDF n'en a pas : les 7 niveaux sont dans le texte) ; les descriptions du texte sont conservées en paragraphes |
| S10 | R — Monnaie | la règle existante (id 196) n'avait pas sa table et ses mots étaient collés (« leursaventures », « laliste ») : **texte remplacé** et table « Monnaie et valeurs » ajoutée |
| S11 | R — Objets magiques | la section « Objets magiques » du chapitre Équipement du PDF (identifier, harmoniser, porter) est la page « Utiliser les objets magiques » sous le chapitre existant « Objets magiques » |
| S12 | R — Propriétés | « Armes improvisées » (renvoi au glossaire dans le PDF) est conservée en sous-section de « Propriétés des armes » |

## 4. À vérifier à la relecture

- **S6/S1** : la structure des variantes et des entrées « Variable » est un choix de modélisation, pas une donnée du PDF.
- **Focaliseurs druidiques** : le PDF n'en liste que trois (baguette d'if, bâton en bois, branche de houx) ; conservés tels quels.
- **Introduction du chapitre « Équipement »** (règle existante, id 15) : ses mots sont collés (« ventedes », « lespersonnages ») et elle emploie « MD » ; **non modifiée** ici, à reprendre à la main ou par une migration dédiée.
- Prix/poids recoupés avec une seconde extraction du PDF : 207 articles sur 238 retrouvés automatiquement ; les 31 autres ont un nom coupé sur deux lignes ou recomposé (S1, S2) et ont été relus à l'œil.
