<!-- Mis à jour : 2026-11-09 12:00 -->

# Journal des corrections — import du DRS 08a, 08b et 15 (classes de prestige et de PNJ)

> Le texte du DRS est repris tel quel **sauf** les corrections de coquilles évidentes et les
> réparations d'extraction listées ici, pour relecture ultérieure (même principe que
> `LOG_CORRECTIONS_DRS04.md`). PDF sources : `DRS 08a`, `DRS 08b` (classes de prestige) et `DRS 15`
> (classes de PNJ), dans `C:\Users\jm-ml\OneDrive\Documents\JDR\D&D\DD 3.5\SRD\`.
>
> Une migration porte ce texte : `sql/2026-11-09_sp-drs10_classes_prestige_pnj_dd35.sql` (SP-DRS10a).
> Elle met en conformité les 15 classes de prestige déjà présentes (source Guide du maître, conservée)
> et crée les 5 classes de PNJ (D-DRS10 à D-DRS12).

## 1. Normalisations globales

| # | Source | Traitement |
|---|---|---|
| G1 | Apostrophes typographiques `’` | remplacées par `'` (comme les lots DRS précédents) |
| G2 | Intertitres « au fil du texte » des capacités (« Don du divin (Sur). », « Aquatique. ») | `<strong>` en tête de paragraphe ; l'intertitre de la capacité elle-même est porté par `cap_nom`, la mention (Ext/Sur/Mag) par `cap_type` |
| G3 | Conditions d'accès soudées par la justification (« … Discrétion. Dons : Attaque en puissance… ») | recoupées à chaque libellé (Race, Alignement, Bonus de base à l'attaque, Compétences, Dons, Sorts, Spécial, Langue) ; un paragraphe `<strong>Libellé.</strong>` par condition, valeur à majuscule initiale |
| G4 | Tableaux secondaires (serviteur fiélon, griffes et morsure, souffle, secrets du gardien du savoir, alignements opposés du hiérophante) | **ressaisis à la main** en convention texte (`dd_tableaux`, catégorie Classe, slugs `classe-<classe>-<objet>`) et appelés par `[[tab:…]]` à leur place dans la capacité |
| G5 | Notes « 1 » des listes de sorts et des tableaux | « (1) » + note du tableau (`>`) |
| G6 | Liste de sorts de l'adepte : « 5e niveau. » soudé à la fin du 4e niveau | recoupé : deux paragraphes, chaque sort lié à son niveau |
| G7 | Équipement de départ des PNJ (« Pour 2d4 x 10 po d'équipement. ») | « × » ; paragraphe « Équipement de départ » de `cla_description` (`cla_po_niveau1` n'est pas affiché) |

## 2. Coquilles corrigées

| # | Où | Texte du PDF | Correction |
|---|---|---|---|
| C1 | Adepte › Sorts (DRS 15) | « incapable de **lanceur** des sorts de soins » | « de **lancer** des sorts » |
| C2 | Archimage › Grand arcane (DRS 08a) | « emplacement de **sorts** du 7e » | « emplacement de **sort** » |
| C3 | Archimage, Hiérophante › Pouvoir magique | « le nombre d'**utilisation quotidienne** » | « d'**utilisations quotidiennes** » |
| C4 | Arpenteur d'horizon › Maîtrise de terrain (×5) | « bénéficie **un** bonus » | « bénéficie **d'un** bonus » |
| C5 | Arpenteur d'horizon › Maîtrise de terrain | « il **le** possède où qu'il se trouve » | « il **les** possède » |
| C6 | Arpenteur d'horizon › Froid (planaire) | « sous-type du **froid** » | « du **Froid** » |
| C7 | Arpenteur d'horizon › Autre (planaire) | « **githyani** » | « **githyankis** » |
| C8 | Champion occultiste › Don supplémentaire | « aptitudes de **classes** liées » | « de **classe** liées » |
| C9 | Chevalier noir › Paladins déchus, 11+ | « peut**-il** instantanément » | « peut instantanément » |
| C10 | Chevalier noir / Maître des ombres › serviteur, compagnon | « les **bonus correspondants** aux bonus » ; « pouvoirs **correspondants** aux niveaux » | « **correspondant** » (participe présent, invariable) |
| C11 | Disciple draconien › Souffle | « **Le** nature et la forme » | « **La** nature » |
| C12 | Disciple draconien › Apothéose / ailes | « de plus en évidentes » | « de plus **en plus** évidentes » |
| C13 | Hiérophante › Pouvoir spécial | « l'un des pouvoirs **suivant** » | « **suivants** » |
| C14 | Hiérophante › Don du divin | « une ou plusieurs **utilisation** » | « **utilisations** » |
| C15 | Maître des ombres › Appel du compagnon ombre | « ne peut pas être **remplacée** » | « **remplacé** » (le compagnon) |
| C16 | Protecteur nain › Bonus à la CA | « +1 à la CA **au niveau**, qui augmente » | « au niveau **1** » |
| C17 | Protecteur nain › Position défensive | « un **bons** de +4 » | « un **bonus** » |
| C18 | Thaumaturge › Compagnon d'arme planaire | « 1 000 po **´** les DV » (signe × perdu) | « 1 000 po **×** les DV » |
| C19 | Thaumaturge › Compagnon d'arme planaire | « l'un des sorts d'**allié naturel** » | « d'**allié d'outreplan** » — **correction d'interprétation** : aucun sort « allié naturel » n'existe, la condition d'accès et la capacité précédente parlent d'allié d'outreplan (*lesser planar ally* en VO). À relire |
| C20 | Assassin › liste de sorts | « clairvoyance/**clairaudiance** » | « **clairaudience** » |

## 3. Base redressée sur le PDF (classes de prestige existantes)

| # | Classe | En base avant | Selon le DRS |
|---|---|---|---|
| B1 | toutes | conditions d'accès, armes et armures, compétences de classe absentes (seul l'archer-mage avait ses 8 compétences) ; `cap_type` vide ; texte des capacités couvrant de 0 à 84 % du DRS | remplis ; texte intégral de chaque capacité |
| B2 | Archer-mage | nom « Archer-Mage » ; 5 capacités « Flèche magique (+1) » à « (+5) » | « Archer-mage » ; **une** capacité « Flèche magique », le bonus en précision des niveaux 1, 3, 5, 7, 9 (les 4 doublons sont supprimés) |
| B3 | Arpenteur d'horizon, Champion occultiste | blanc final dans le nom | retiré |
| B4 | 12 classes | abréviation vide (seules As, CN et Th existaient) | AM, Arc, AH, CO, DD, Due, GS, Hié, MO, MP, PN, TM |
| B5 | Hiérophante, Thaumaturge | niveau maximal 10 | **5** (5 niveaux en base, inchangés) |
| B6 | Disciple draconien | niveau 7 : Vigueur et Volonté +6 | **+5** |
| B7 | Maître des ombres | niveau 0 : Esquive instinctive supérieure ; niveau 2 : Attaque sournoise ; rien pour Esquive totale et Vision dans le noir | Esquive totale, Vision dans le noir et Esquive instinctive au niveau 2 ; Esquive instinctive supérieure au **niveau 5** — la table du PDF écrit « Esquive instinctive » au niveau 5, le texte dit « supérieure » : le texte fait foi. Pas d'attaque sournoise |
| B8 | Protecteur nain | colonne « Bonus à la CA » absente | `cla_pouvoir1` « Bonus à la CA » : +1, +1, +1, +2, +2, +2, +3, +3, +3, +4, et capacité « Bonus à la CA (protecteur nain) » |
| B9 | Maître des ombres | téléportation « 6m » | « 6 m », « 12 m », « 24 m », « 48 m » |
| B10 | plusieurs | noms de capacités : « Détection du bien », « Châtiment du bien », « Contrôle des morts vivants », « Roulé boulé », « Appel du compagnon d'ombre », « Augmentation naturelle d'armure », « Augmentation de caractéristiques », « Utilisation de poison » | intertitres du DRS : « Détection du Bien », « Châtiment du Bien », « Contrôle des morts-vivants », « Roulé-boulé », « Appel du compagnon ombre », « Augmentation d'armure naturelle », « Augmentation de caractéristique », « Utilisation du poison » |
| B11 | Assassin, Chevalier noir, Mystificateur, Maître des ombres, Protecteur nain | capacités partagées avec le roublard, le barbare ou le moine (Attaque sournoise, Esquive instinctive (supérieure), Discrétion totale, Esquive extraordinaire, Sens des pièges, Réduction des dégâts) | **variante propre à la classe** quand le texte du DRS diffère (D-DRS11) ; la capacité partagée n'est plus liée à cette classe |

## 4. Classes de PNJ (DRS 15)

- Progressions : bonus de base à l'attaque et sauvegardes calculés selon les trois rythmes du DRS
  (fort, moyen, faible ; sauvegarde forte = 2 + niveau/2, faible = niveau/3) et contrôlés contre les
  tables : adepte (attaque faible, Volonté forte), expert et noble (attaque moyenne, Volonté forte),
  gens du peuple (tout faible), homme d'armes (attaque forte, Vigueur forte).
- Coquille de table : homme d'armes, niveau 20, « +20/**15**/+10/+5 » → « 20/15/10/5 ».
- Sorts par jour de l'adepte : la table du PDF colle les chiffres (« 32 0 » = 3 sorts du niveau 0,
  2 du 1er, 0 du 2e) ; recomposée niveau par niveau.
- L'expert n'a pas de liste fermée (« jusqu'à dix compétences au choix ») : aucune compétence de
  classe liée, le texte est dans `cla_description`.

## 5. Écarts laissés en l'état — à relire

| # | Où | Constat |
|---|---|---|
| E1 | Assassin › liste de sorts, 2e niveau | « Texte illusoire » **absent de `dd_sorts`** : le sort reste dans le texte de la liste mais n'est pas lié à la classe |
| E2 | Gardien du savoir › compétences de classe | « Scrutation » (compétence de la v3.0, absente de la v3.5) : ignorée, non liée |
| E3 | Protecteur nain › Position défensive | « ne peut le faire qu'au cours d'une action » — la VO dit « pendant son propre tour » ; laissé tel quel |
| E4 | Chevalier noir, Adepte › listes de sorts | 6 sorts n'existent en base que dans leur version du Manuel des joueurs v3.0 (convocation de monstres I à IV ; détection de l'invisibilité, résistance aux énergies destructives) : liés à celle-ci. Les autres sont liés à leur version v3.5 |
| E5 | Classes de PNJ | le DRS 15 n'a pas d'introduction : le texte de la page de règles « Classes de PNJ » est rédigé, pas repris du DRS |
| E6 | Chevalier noir | « Paladins déchus » et « Corruption d'arme » sont des encadrés du DRS, pas des aptitudes à niveau : capacités liées au niveau 1 pour être consultables depuis la fiche (D-DRS12) |
