<!-- Mis à jour : 2026-11-07 11:10 -->

# Journal des corrections — import du DRS 04 (Les compétences)

> Le texte du DRS est repris tel quel **sauf** corrections de coquilles évidentes, toutes listées
> ici pour relecture ultérieure (même principe que `LOG_CORRECTIONS_DRS07_DRS23.md`). Le PDF source
> est `DRS 04 (compétences).pdf` (`C:\Users\jm-ml\OneDrive\Documents\JDR\D&D\DD 3.5\SRD\`, 34 pages).
>
> Deux migrations portent le texte corrigé :
> - `sql/2026-10-31_regles_dd35_drs04_sp-drs4.sql` — **pages 1 à 4** (les règles générales, §1 à §4 ci-dessous) ;
> - `sql/2026-11-08_sp-drs4b_competences_dd35.sql` — **pages 5 à 34**, la description des 36 compétences
>   (compendium `dd_competences`) et leurs 40 tableaux (SP-DRS4b, §5).

## 1. Normalisations globales

| # | Source | Traitement |
|---|---|---|
| G1 | Apostrophes typographiques `’` | remplacées par `'` (cohérent avec les lots DRS déjà importés) |
| G2 | Guillemets `“ … ”` (le PDF met une espace à l'intérieur) | remplacés par `« … »` |
| G3 | Gras et italique du PDF | `<b>` → `<strong>`, `<i>` → `<em>` ; les espaces rangés hors des balises (le PDF écrit « **Faire 10. **Lorsque ») |
| G4 | Intertitres « au fil du texte » (« **Utilisation des compétences.** Voici la formule… ») | conservés en `<strong>` dans le paragraphe, comme dans les lots précédents |

Les tirets simples encadrant une incise (« la moitié - sans arrondir - de ce total ») et la tournure
« augmente **d'un** le degré de maîtrise » sont **laissés tels que dans le PDF**.

## 2. Coquilles corrigées

| # | Où | Texte du PDF | Correction |
|---|---|---|---|
| C1 | Utilisation des compétences | « jusqu'**à qu'**il réussisse du mieux possible » | « jusqu'**à ce qu'**il réussisse… » |
| C2 | La synergie | « (comme **Acrobatie** et Saut) » — la compétence s'appelle Acrobaties | « (comme **Acrobaties** et Saut) » |
| C3 | Test sans jet de dé | « beaucoup d'échecs **entre temps** » | « beaucoup d'échecs **entre-temps** » |
| C4 | Description des compétences | « leur race, leur classe ou **leur dons** » | « …ou **leurs dons** » |

## 3. Structure et contenu modifiés (hors coquilles)

| # | Où | Changement |
|---|---|---|
| S1 | Arborescence | Une racine **« Les compétences »** (`reg_ordre` 15, entre « Les bases du jeu » et « Le combat ») et **10 pages**, une par intertitre du DRS ou regroupement de deux sections courtes. Le titre de la première page, « Points de compétence et degrés de maîtrise », est **rédigé** : le DRS n'en donne pas, le texte suit directement le titre du chapitre. « Nouvelles tentatives » et « Test inné de compétence » partagent la page « Nouvelles tentatives et test inné » |
| S2 | Tableaux | Les deux tables du PDF (**Exemples de degrés de difficulté**, **Exemples de tests opposés**) sont saisies dans `dd_tableaux`. Dans la seconde, « Spécial1 » devient « Spécial (1) » avec sa note en bas de tableau ; « Arriver furtivement dans le dos de / quelqu'un » et « Presque impossible / (40) », coupés sur deux lignes par le PDF, sont recomposés |
| S3 | Description des compétences | « **La section suivante** décrit les compétences… » devient « **Le compendium** décrit les compétences… » : la section suivante n'existe pas dans le wiki, les descriptions vivent dans le compendium |
| S4 | Temps d'utilisation des compétences | Renvoi « (voir Les différents types d'actions) » → « (voir *Les actions au combat*) », titre réel de la page du chapitre « Le combat » |
| S5 | Renvois internes | « (voir Combiner ses compétences) » mis en italique, comme les renvois des lots précédents |
| S6 | Description des compétences | Les deux paragraphes « **Caractéristique associée.** … » et « *Exception* : Langue… », séparés par un retour à la ligne du PDF, sont fusionnés (la première ligne s'arrêtait trop court pour qu'« Exception » y tienne : c'est un simple renvoi à la ligne) |
| S7 | Glossaire | 11 termes **rédigés** (le DRS n'a pas de glossaire) : Compétence de classe, Compétence hors classe, Degré de difficulté (DD), Degré de maîtrise, Faire 10, Faire 20, Modificateur de compétence, Synergie (compétences), Test de caractéristique, Test inné de compétence, Test opposé |
| S8 | Glossaire | **« Test de compétence » est volontairement absent**, et « Synergie » porte un qualificatif. Le parseur lie la casse exacte et n'exclut pas `<strong>` : ces deux termes auraient lié, dans le compendium, l'intertitre « Test de compétence. » de 12 fiches de compétence et « Synergie. » de 8 autres. Même précaution que « Charges (objet magique) » au lot SP-DRS3 |

## 4. À relire

- Les **11 définitions de glossaire** et le titre de la page 1 (S1, S7) sont de ma rédaction, pas du DRS.
- Effet de bord assumé : « **Degré de maîtrise** » est maintenant un terme de glossaire ; il se lie à
  sa première occurrence dans 3 descriptions de dons DD3.5, où il apparaît à la casse exacte.

---

## 5. Descriptions des compétences (SP-DRS4b, 2026-11-07)

Contrôle préalable des règles générales (pages 1 à 4) : **rien ne manque** dans le wiki. Recouvrement
du texte du PDF de 97 % ; il ne manque que la mention OGL, les titres de section (portés par
`reg_nom`) et les titres des deux tables.

Les 36 fiches mères DD3.5 sont réécrites avec le texte intégral du DRS. Elles étaient incomplètes
(Bluff 3 %, Survie 5 %, Maîtrise des cordes 3 %…) ou quasi complètes, mais avec des tableaux HTML
intégrés et de petits manques (le don Voltigeur d'Acrobaties, par exemple). Après import, chaque
fiche compte autant de mots que le DRS. Le recouvrement mesuré va de 93 à 100 %, sauf Langue
(81 %) : c'est un artefact de mesure, car l'extraction du PDF mélange l'ordre des colonnes des
tableaux.

### 5.1 Normalisations

Celles des §1 (G1 à G4) s'appliquent, plus les suivantes :

| # | Traitement |
|---|---|
| N1 | L'en-tête « Acrobaties (Dex ; formation nécessaire ; malus d'armure aux tests) » n'est **pas repris** : la fiche affiche déjà caractéristique, formation et malus (l'ancien `<h4>` en doublon est supprimé). |
| N2 | Les intertitres du DRS (*Test de compétence*, *Action*, *Nouvelles tentatives*, *Spécial*, *Synergie*, *Restriction(s)*, *Test inné*), ainsi que les intertitres propres à une fiche (*Feinter en combat*, *Saut en longueur*…), ouvrent chacun un paragraphe en `<strong>`. Les tours de Dressage sont présentés de la même façon (`« Arrête ! » (DD 15).`). |
| N3 | Une *Synergie* qui énonce plusieurs bonus est mise en liste, une ligne par synergie, comme dans les anciennes fiches. |
| N4 | Les listes à puces « • » deviennent des `<ul>` (domaines de Connaissances, formes de Représentation, règles de Langue, étapes d'Artisanat). |
| N5 | « Influencer l'attitude des PNJ » (Diplomatie) et « Autres moyens de se débarrasser d'un piège » (Désamorçage) sont des titres de section : ils passent en `<h3>`. |
| N6 | Les renvois « (voir Combattre sur la défensive) » sont mis en italique, comme au §3 S5. |
| N7 | Le signe « ´ » mal extrait et le « x » de multiplication deviennent « × » (Artisanat, Estimation, Intimidation, Déguisement). |
| N8 | Les appels de note « 1 » collés aux cellules (« tourbière1 », « 201 ») deviennent « (1) », avec la note sous le tableau (`>`). Les cellules et lignes coupées par la mise en page du PDF sont recomposées. |
| N9 | Les noms de sorts ne sont pas mis en italique : l'extraction du PDF ne garde pas l'italique. |

### 5.2 Coquilles corrigées

| # | Fiche | Texte du PDF | Correction |
|---|---|---|---|
| D1 | Acrobaties, Saut | « Acrobatie » (×4) | « Acrobaties » |
| D2 | Acrobaties (tableau) | « augmente **de** DD de +2 » | « augmente **le** DD de +2 » |
| D3 | Art de la magie | « test d'Art de la magie Lorsque » | point ajouté |
| D4 | Art de la magie, Décryptage, UOM | « Utilisation **des** objets magiques » | « Utilisation **d'**objets magiques » (nom de la compétence) |
| D5 | Artisanat | « fabrication d'un un objet » ; « estimez le » ; « ou l'estimer au cas » | « d'un objet » ; « estimez-le » ; « ou estimez-le au cas » |
| D6 | Bluff | « Il est aussi de tenter » ; « Chance tentative » | « Il est aussi possible de tenter » ; « Chaque tentative » |
| D7 | Bluff | « supérieur au résultat de ce test spécial de **Bluff** » | « … de **Psychologie** » (le test de la cible) |
| D8 | Diplomatie | « modifier **d'**attitude d'un animal » | « modifier **l'**attitude » |
| D9 | Discrétion, Escalade | « à – 10 », « malus de – 5 » | « –10 », « –5 » |
| D10 | Décryptage | « dix action complexes » | « dix actions complexes » |
| D11 | Déguisement | « 1d3x10 minutes de travail Nouvelles tentatives » ; « …modification d'apparence, confèrent » | point ajouté ; « confère » |
| D12 | Détection | « c'est-àdire » ; « (La lecture sur les lèvres… » | « c'est-à-dire » ; minuscule |
| D13 | Escalade | « audessus » ; « ce qui signifie le personnage » ; « une seul action » ; « vitesse de déplacement normal » | « au-dessus » ; « signifie que » ; « une seule » ; « normale » |
| D14 | Équilibre | « cidessus » ; « ne **peur** courir » (note du tableau) | « ci-dessus » ; « ne peut » |
| D15 | Équitation | « une créature qui n'est faite pour cela » | « qui n'est **pas** faite » |
| D16 | Évasion | « le DD associés » ; « les passages dans laquelle » | « les DD associés » ; « dans lesquels » |
| D17 | Maîtrise des cordes | « de façon à **se** qu'il » | « à **ce** qu'il » |
| D18 | Perception auditive | « On peut jouer lui-même le test » ; « commun auquel il ajoute » | « **Le MJ** peut jouer lui-même » ; « auquel on ajoute » (le sujet manquait) |
| D19 | Premiers secours | « …du sort Soigner un empoisonnement. » ; « Premier secours » (×2) | point ajouté avant l'intertitre ; « Premiers secours » |
| D20 | Profession | « main d'œuvre » | « main-d'œuvre » |
| D21 | Saut | « battre **de** DD » ; « milongueur » ; « un rebords élevé ou se s'accrocher » ; « 6mètres » ; « d'un chute » ; « il font » ; « aucun dégâts » | « le DD » ; « mi-longueur » ; « un rebord élevé ou de s'accrocher » ; « 6 mètres » ; « d'une chute » ; « ils font » ; « aucun dégât » |
| D22 | Dressage | « à subit » ; « son adversaire son vaincu » ; « trois semaine » ; « entraîné être une monture » | « a subi » ; « soit vaincu » ; « trois semaines » ; « entraîné pour être » |
| D23 | Dressage | Cinq fonctions recopient « …pour devenir un **animal de combat** prend N semaines » | Le nom de la fonction décrite (animal de garde, travailleur de force, animal de chasse, animal de foire, monture) |
| D24 | Déguisement, Renseignements | « degré de maîtrise de 5 en … » | « de 5 **ou plus** », formule de toutes les autres synergies |

### 5.3 Tableaux : valeurs corrigées

| # | Tableau | PDF | Saisi | Raison |
|---|---|---|---|---|
| T1 | `competence-saut-hauteur` | 2,40 m → **21** | **32** | La règle du texte (hauteur ÷ 7,5) donne 32, et la progression du tableau est de +4 |
| T2 | `competence-saut-longueur`, `competence-saut-hauteur` | note « élan d'au moins **3** mètres » | **6** mètres | Le texte dit 6 mètres (deux fois), comme le SRD anglais (20 pieds) |
| T3 | `competence-dressage-fonctions` | Animal de foire **12** ; « Monture de guerre » | **15** ; « Monture de combat » | Le texte donne « Animal de foire (DD 15) » et nomme la fonction « Monture de combat » |
| T4 | Bluff, Déguisement (familiarité), Représentation, Utilisation d'objets magiques, Langue | colonnes décalées d'une ligne à l'extraction | réalignées | Valeurs remises en face de leur ligne d'après la progression et le SRD (ex. Bluff : –5 / 0 / +5 / +10 / +20) |

Quatorze tableaux existaient en HTML dans les anciennes fiches : ils sont **ressaisis depuis le PDF**,
pas convertis (ils portaient les mêmes artefacts, « tourbière1 »). Les 40 tableaux prennent la
catégorie **Compétence** et la source « DRS 3.5 ». Les deux tableaux des règles générales restent dans
la catégorie « Règle ».

### 5.4 Dressage : contenu conservé hors DRS

L'ancienne fiche contenait environ 1 800 mots absents du DRS. Ils sont **conservés** et placés après le
texte du DRS : don Caravanier et don Présence réconfortante, 19 tours supplémentaires (« Attaque avec
moi ! », « Embuscade ! »…), les ajouts de *Drow of the Underdark* (vermines) et de *Campagnes
légendaires* (temps de dressage réduit), avec leurs deux tableaux. Ce texte n'est pas relu contre une
source. Seules les fautes évidentes sont corrigées (« ce tout » → « ce tour », « a » → « à »,
« connaitre », « entrainé »). Les liens vers gemmaline.com sont retirés, les noms des dons restent.

### 5.5 Autres changements

- **Noms** : « Art de la magie » et « Utilisation d'objets magiques » portaient un blanc final (espace,
  tabulation). Il est retiré. La collation ignore les blancs finaux : la migration compare donc les
  longueurs.
- **Source** : les fiches restent rattachées au *Manuel des joueurs v3.5*. Passer à « DRS 3.5 » les
  aurait masquées dans les campagnes et sélections qui n'activent pas cette source (D-DRS5).
- **Synergies** (`dd_competences_synergies`, non modifiée) : toutes les synergies entre compétences
  du DRS y figurent. La table en compte **deux de plus** que le DRS : Décryptage → Art de la magie
  (cercle runique) et Représentation → Concentration (chahut). Elles sont à vérifier contre leur
  source d'origine. Les synergies du DRS vers autre chose qu'une compétence (savoir bardique,
  renvoi des morts-vivants, empathie sauvage) restent du texte seulement.
