<!-- Mis à jour : 2026-06-01 16:55 -->

# Règles métier — Module Campagnes

> Règles fonctionnelles du module Campagnes (sans référence au code).
> Pour l'architecture technique, voir `ARCHITECTURE_8_CAMPAGNES.md`.
> Pour le schéma des tables, voir `SCHEMA_SQL.md` (section 7).

---

# Définition d'une campagne

Une campagne est l'unité d'organisation d'une partie menée par un MJ. Elle regroupe l'histoire,
les adversaires, les sources de règles autorisées et les personnages qui y participent.

Une campagne appartient à **un seul propriétaire** (le MJ, `camp_j_id`). Le rôle de MJ n'est pas
un rôle structurel : il est inféré de la propriété de la campagne. Chaque utilisateur est donc MJ
de ses propres campagnes.

# Données d'une campagne

Une campagne est décrite par :
- un nom ;
- un résumé court (texte simple) ;
- une description complète (texte enrichi, images autorisées) ;
- un ruleset (DD3.5 ou DD2024) — **choisi à la création et maître pour tout le contenu** ;
- un univers (optionnel) ;
- une date de création (automatique).

## Ruleset maître

Le ruleset est choisi au niveau de la campagne et **hérité** par tout son contenu : scénarios,
chapitres, rencontres et oppositions. Il n'est jamais redéfini à un niveau inférieur. Une campagne
DD3.5 ne contient que du contenu DD3.5.

## Univers

Une campagne est reliée à **au plus un univers**. Les univers sont **agnostiques du ruleset** :
un même univers peut servir de décor à une campagne DD3.5 et à une campagne DD2024. Une campagne
sans univers est autorisée.

## Sources de la campagne

Une campagne définit ses propres sources de règles actives (livres autorisés). Ces sources
**priment** sur la sélection personnelle du joueur lorsqu'il joue dans le contexte de la campagne
(priorité 1 de la chaîne de sélection : campagne > sélection personnelle > défaut du ruleset).

## Personnages

La relation entre personnages et campagnes est **plusieurs-à-plusieurs** : un personnage peut
participer à plusieurs campagnes, une campagne accueille plusieurs personnages. Un personnage peut
être marqué actif ou inactif dans une campagne.

La table de liaison est la **source de vérité** du rattachement. Par commodité, le personnage
mémorise aussi sa **dernière campagne jouée** (campagne « en cours »), qui n'est qu'un raccourci
de contexte et ne fait pas autorité sur le lien.

> Les notes privées du MJ sur un personnage rattaché sont **prévues mais non actives** dans cette
> version (le système de notes n'est pas finalisé et dépend du module Personnages).

---

# Hiérarchie du contenu

```
Campagne
  └─ Scénario (plusieurs par campagne)
       └─ Chapitre (plusieurs par scénario)
            └─ Rencontre (plusieurs par chapitre)
                 └─ Opposition (plusieurs par rencontre)
```

## Scénario

Un scénario est une étape narrative de la campagne. Il porte un nom, un ordre d'affichage et une
description enrichie (images autorisées). Il appartient à une campagne et hérite de son ruleset.

## Chapitre

Un chapitre découpe un scénario. Il porte un nom, un ordre, une abréviation optionnelle et une
description.

## Rencontre

Une rencontre est un moment de jeu (combat, scène, énigme). Elle appartient **obligatoirement** à
un chapitre — il n'existe pas de rencontre « orpheline ». Elle porte un nom, un code de référence
libre, une description enrichie (images autorisées) et un champ **composition**.

### Composition de la rencontre

Le détail des effectifs et de la disposition d'une rencontre est décrit **littéralement** dans un
champ texte mis en évidence (nombre d'adversaires, vagues, placement…). Il n'existe pas de
comptage chiffré stocké séparément : c'est ce texte qui fait foi pour le MJ en session.

## Opposition

Une opposition est un adversaire d'une rencontre. C'est une **copie éditable d'un monstre du
compendium** : le MJ choisit un monstre modèle, ses données sont recopiées, puis le MJ peut les
ajuster et les annoter pour sa partie **sans jamais modifier le compendium**.

Données recopiées à la création (toutes éditables ensuite, sauf le lien au modèle) :
- le nom du monstre → nom de l'opposition ;
- le libellé de sa catégorie → catégorie de l'opposition (texte libre, modifiable) ;
- son bloc de statistiques → statistiques de l'opposition ;
- l'identifiant du monstre modèle est **conservé pour traçabilité** et **non modifiable** par le MJ.

Le choix du monstre modèle se fait parmi les monstres du **ruleset courant** et des **sources
actives**. Une rencontre contient en général plusieurs oppositions.

---

# Duplication

Le module permet de **dupliquer** un scénario, une rencontre ou une opposition. La copie reprend
le nom de l'original suivi de « - copie ».

- Dupliquer un **scénario** recopie en cascade ses chapitres, rencontres et oppositions.
- Dupliquer une **rencontre** la recopie avec ses oppositions, vers le même scénario ou un autre.
- Une rencontre peut être copiée vers un scénario d'une **autre campagne**.

**Toute duplication est limitée au ruleset courant.** Il n'est pas possible de copier du contenu
d'une campagne vers une campagne d'un autre ruleset (les références de monstres ne seraient pas
valides). Aucune exception dans cette version.

---

# Pièces jointes et images

- **Images** : les descriptions de campagne, de scénario et de rencontre acceptent des images
  insérées dans le texte enrichi. Les images sont **téléversées sur le serveur**.
- **Fichiers attachés** : on peut attacher des fichiers **PDF uniquement** à une campagne, un
  scénario ou une rencontre. Le téléchargement d'une pièce jointe est réservé aux personnes
  autorisées (le MJ propriétaire de la campagne).

---

# Suppression

Les données de jeu suivent une stratégie de **suppression douce** (jamais d'effacement définitif
immédiat). Le détail (marquage, cascade scénario → chapitres → rencontres → oppositions, sort des
pièces jointes) sera précisé dans une note dédiée avant implémentation.

---

# Accès et responsive

Le module Campagnes est un outil de préparation et d'animation **réservé au MJ propriétaire**. Il
est conçu pour un usage **desktop** et n'est pas responsive. Le menu Campagnes n'est visible que si
l'utilisateur a activé le mode campagne.
