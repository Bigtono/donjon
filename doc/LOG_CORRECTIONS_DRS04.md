<!-- Mis à jour : 2026-10-31 18:50 -->

# Journal des corrections — import du DRS 04 (Les compétences)

> Le texte du DRS est repris tel quel **sauf** corrections de coquilles évidentes, toutes listées
> ici pour relecture ultérieure (même principe que `LOG_CORRECTIONS_DRS07_DRS23.md`). Le PDF source
> est `DRS 04 (compétences).pdf` (`C:\Users\jm-ml\OneDrive\Documents\JDR\D&D\DD 3.5\SRD\`, 34 pages).
>
> Le texte corrigé vit dans une seule migration : `sql/2026-10-31_regles_dd35_drs04_sp-drs4.sql`.
> **Périmètre : pages 1 à 4 du PDF** (les règles générales). Les pages 5 à 34 — la description des
> 36 compétences — sont des données du compendium (`dd_competences`) et ne sont **pas** reprises ici.

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
