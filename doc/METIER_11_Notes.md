<!-- Mis à jour : 2026-11-06 11:15 -->

# Règles métier — Module Notes

> Règles fonctionnelles du module Notes (sans référence au code).
> Suivi des phases : `ARCHITECTURE_0_REFERENCE.md` §0, chantier **SP-NO**.
> Schéma des tables : `SCHEMA_SQL.md` (section 9). Décisions : `DECISIONS_LOG.md` (D-NO0 → D-NO15).

---

# Définition d'une note

Une note est une information que le MJ diffuse à un ou plusieurs personnages de sa campagne :
le contenu d'un parchemin, ce qu'un personnage sait d'une région, d'une faction ou d'un dieu, un indice,
une vision… Elle contient du texte enrichi et des images.

Une note est rattachée :
- à **une campagne** (obligatoire) — elle en hérite le **ruleset** ;
- à **un scénario** de cette campagne (facultatif) : sans scénario, elle vaut pour toute la campagne ;
- à **une catégorie** (obligatoire), choisie parmi les catégories du ruleset de la campagne ;
- à des **mots-clés** libres (facultatifs), propres au MJ ;
- à une **date**, proposée à la création et modifiable, qui sert au tri.

Seul le MJ de la campagne crée, modifie et supprime ses notes. La suppression est douce ; supprimer la
campagne supprime ses notes. Supprimer un **scénario** ne supprime pas ses notes : elles remontent au niveau
de la campagne (sans scénario), pour que les joueurs ne perdent pas des informations déjà reçues.

Les mots-clés sont propres au MJ et réutilisés d'une note à l'autre ; deux saisies qui ne diffèrent que par
la casse ou les accents (« Valombre », « valombre ») désignent le même mot-clé.

# Structure : tronc commun et sections

Une note se compose :
- d'un **tronc commun**, toujours lisible par tous ses destinataires (il peut être vide) ;
- de **sections**, ordonnées, avec un intertitre facultatif.

Chaque section peut être réservée aux personnages qui ont assez de savoir : c'est la reprise des
« niveaux de connaissance » de la première version de l'application. Plus le personnage est savant,
plus il lit de sections.

# Conditions d'accès par compétence

Une section peut être rattachée à **une ou plusieurs compétences**, chacune avec un **DD**.

- **Sans condition**, la section est lisible par tous les destinataires.
- **Avec conditions**, le personnage la lit s'il satisfait **au moins une** d'entre elles (OU).
- Une condition est satisfaite si **le score du personnage dans la compétence (son bonus total) ≥ DD**.
  On ne « prend » plus 10 : le DD se lit directement contre le score affiché sur la fiche. La règle est la
  même en DD3.5 et en DD2024.
- En DD3.5, une compétence qui exige une formation ne satisfait jamais la condition si le personnage
  n'y a aucun rang.

Le bonus total est celui du bloc Compétences de la fiche (rangs ou maîtrise, modificateur de caractéristique,
modificateur divers et, en DD3.5, synergies sans condition ; hors équipement). Le contrôle est recalculé à chaque consultation : un personnage qui progresse découvre de nouvelles
sections sans intervention du MJ. Une section inaccessible n'est jamais transmise au joueur — ni affichée,
ni présente dans la page — et la recherche par mots du joueur n'y regarde pas.

Une note diffusée dont le tronc commun est vide et dont aucune section n'est accessible n'apparaît pas
dans la liste du personnage.

# Diffusion

Le MJ choisit l'un des deux modes de diffusion d'une note :

- **Toute la campagne** : tout personnage rattaché à la campagne la lit, inactif compris, y compris ceux qui la
  rejoignent plus tard. Un personnage qui quitte la campagne la perd ; s'il revient, il la retrouve, lue ou non lue
  comme il l'avait laissée.
- **Personnages choisis** : le MJ coche les destinataires parmi les personnages rattachés à la campagne.

Les notes existantes ne changent pas de mode d'elles-mêmes : une action groupée de la liste les bascule. Repasser
une note en « personnages choisis » en fait les destinataires de tous les membres actuels de la campagne.

Dans les deux modes, un personnage ne voit que les notes dont il peut lire quelque chose (voir plus haut) : une note
sans tronc commun reste absente de sa liste tant qu'aucune section ne lui est accessible, et y apparaît, marquée
« nouvelle », dès que ses compétences progressent assez, sans que le MJ intervienne.

En mode « personnages choisis » :
Un personnage qui a quitté la campagne garde les notes reçues ; il reste proposé, coché, dans le formulaire
de la note, et le décocher les lui retire. Retirer un destinataire lui retire la note. La date de diffusion
et la première lecture sont conservées : le joueur voit une pastille « nouveau » sur une note qu'il n'a pas
encore ouverte.

Modifier une note ne la rend pas « nouvelle » d'office : une case du formulaire, « Signaler la mise à jour
aux destinataires », la remet à « non lue » pour tous ses destinataires. Le MJ la coche pour une
modification qui compte, pas pour une coquille.

# Interfaces

## Côté MJ (module Campagnes)

- Liste des notes de ses campagnes, filtrable par campagne, scénario, catégorie et mots-clés, avec
  recherche dans le titre et le texte, triable par date croissante ou décroissante.
- Formulaire : titre, catégorie, scénario, date, mots-clés, tronc commun, sections et leurs conditions,
  destinataires.
- Fiche de la note : toutes les sections avec leurs conditions, les destinataires et, pour chacun,
  les sections qu'il peut lire.
- Actions groupées sur les notes cochées de la liste : supprimer, changer de campagne, changer de catégorie,
  ajouter ou retirer des destinataires. Chacune ouvre un panneau qui rappelle les notes choisies ; la suppression
  y demande une validation explicite. L'action « Diffusion » fait passer les notes cochées en « toute la campagne » ou en
  « personnages choisis » ; ajouter ou retirer des destinataires ne concerne que les notes en « personnages choisis ». Une note qui change de campagne perd son scénario et les destinataires qui
  ne font pas partie de la nouvelle campagne ; on ne propose que les campagnes du même ruleset. Un destinataire
  n'est ajouté qu'aux notes de ses campagnes. Une note appartient toujours à une campagne.
- Accès depuis l'outil « Notes » des pages de campagne, la section Notes d'un scénario (avec création d'une note
  déjà rattachée au scénario) et le lien « Notes » du menu. La liste s'ouvre sur la dernière campagne consultée.
- Prévu pour ordinateur, comme le reste du module Campagnes.

## Côté joueur (fiche du personnage)

- **Page dédiée** « Notes » du sous-menu de la fiche, au même titre que Magie ou Possessions : les notes reçues
  par le personnage.
- Mêmes filtres (campagne, scénario, catégorie, mots-clés, recherche) et même tri par date. Par défaut,
  la campagne en cours ou toutes les campagnes, selon la préférence mémorisée sur le personnage.
- Lecture d'une note dans le panneau de détail : tronc commun puis sections accessibles, sans titre ni condition des
  sections masquées. Ouvrir la note la marque lue (pastille « Nouveau » retirée) ; un administrateur qui consulte la
  fiche d'un joueur ne la marque pas.
- Sans campagne en cours, la page montre les notes de toutes les campagnes.
- **Optimisée pour smartphone** : liste en cartes, filtres repliables, lecture plein écran.

# Catégories

Les catégories sont propres à chaque ruleset. Onze catégories sont fournies au départ, identiques pour
DD3.5 et DD2024 : Histoire, Géographie et lieux, Personnages, Organisations et factions, Religions et
divinités, Magie et arcanes, Créatures, Objets et artefacts, Culture et société, Indices et documents,
Divers. Leur gestion relève de l'administration (écran « Catégories de notes ») : ajout, renommage, ordre
d'affichage, suppression. Une catégorie qui contient des notes ne peut être ni supprimée ni passée à l'autre ruleset.

# Reprise des notes de la première version

Les 57 notes de la v1 (DD3.5, campagne de la Trilogie des Avatars) s'importent depuis l'administration dans une
campagne choisie : les blocs de DD 10 forment le tronc commun, chaque bloc de DD supérieur devient une section
conditionnée au même DD. La v1 n'enregistrait pas de compétence : l'administrateur en choisit une ou deux par type de
note v1 (par défaut selon la catégorie : Histoire pour les lieux, l'histoire, les cultures et les organisations,
Arcanes pour la magie, Investigation pour les indices). Les libellés des mots-clés v1, absents de l'export, sont
saisis au moment de l'import. Les images de la v1 sont retirées. Les destinataires sont à redéfinir par le MJ, la
v1 ne les ayant pas exportés. Un import relancé ne crée pas de doublon.
