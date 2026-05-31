<!-- Mis à jour : 2026-05-30 -->

# Codex DD v2 — Métier : Races

> Règles fonctionnelles et comportement attendu côté utilisateur.
> Aucune notion de code ou de base de données dans ce document.

---

## 1. Concepts métier

### Race et archétype

Tout personnage possède obligatoirement une **race**. En DD3.5, la race est appelée **race de base** et peut être complétée par un **archétype**, qui est un second type racial optionnel venant s'ajouter à la race de base. Un personnage DD3.5 a donc une race de base et, optionnellement, un archétype.

En DD2024, la race est appelée **espèce**. Il n'existe pas d'archétype : chaque personnage a une espèce, et une seule.

Les types de race possibles (race de base, archétype, et tout type introduit par de futurs suppléments) sont définis dans un référentiel dédié.

### Modificateur de niveau global (DD3.5 uniquement)

Certaines races DD3.5 sont plus puissantes que les races ordinaires. Pour compenser cette puissance, elles imposent un **modificateur de niveau** : une valeur entière positive qui s'ajoute aux niveaux de classe du personnage pour calculer son **niveau global effectif**.

Exemple : un personnage de niveau 5 qui joue une race avec un modificateur de niveau de +2 est traité comme un personnage de niveau 7 pour les calculs d'expérience et de progression.

Ce concept est absent du ruleset DD2024.

### Capacités raciales

Une race peut posséder un nombre quelconque de **capacités raciales**, aussi appelées capacités spéciales dans ce contexte. Ces capacités décrivent les aptitudes innées conférées par la race : sens particuliers, résistances, pouvoirs naturels, etc.

Le fait de jouer une race donne **immédiatement et intégralement** accès à toutes ses capacités raciales, sans condition de niveau ni de progression. Il n'y a pas de notion d'acquisition progressive pour les capacités raciales, contrairement aux capacités de classe.

Les capacités raciales partagent le même référentiel que les capacités de classe. Une même capacité spéciale peut théoriquement être attribuée à plusieurs races ou classes.

### Type d'une capacité spéciale (DD3.5)

En DD3.5, chaque capacité spéciale appartient à un type qui précise sa nature magique ou physique (exemples : Extraordinaire, Magique, Surnaturelle). Ce type est une information de règle affichée à côté du nom de la capacité pour aider le joueur à en comprendre les implications mécaniques.

En DD2024, cette notion de type n'est pas utilisée.

---

## 2. Affichage d'une race — ce que voit l'utilisateur

### DD3.5

La fiche d'une race présente dans l'ordre :

1. Le **nom** de la race
2. Le **type de race** (race de base, archétype…)
3. Le **modificateur de niveau**, affiché uniquement s'il est supérieur à zéro, sous la forme : *Modificateur de niveau : +N*
4. La **description** générale de la race (texte libre enrichi)
5. La **liste des capacités raciales**, dans l'ordre défini par le gestionnaire du compendium, à raison d'une capacité par ligne :
   - Nom de la capacité, suivi de son type entre parenthèses — ex. : *Vision dans le noir (Ext.)*
   - Description de la capacité

### DD2024

La fiche d'une espèce présente dans l'ordre :

1. Le **nom** de l'espèce
2. La **description** générale (texte libre enrichi)
3. La **liste des capacités raciales**, dans l'ordre défini par le gestionnaire du compendium, à raison d'une capacité par ligne :
   - Nom de la capacité
   - Description de la capacité

---

## 3. Gestion du compendium — ce que fait le gestionnaire

### Liste des races

Le gestionnaire dispose d'une liste de toutes les races du ruleset actif. Il peut filtrer par type de race. En DD3.5, il peut également filtrer pour n'afficher que les races ayant un modificateur de niveau.

### Créer ou modifier une race

La saisie d'une race comprend :

- Le nom
- Le type de race (sélection parmi les types disponibles pour le ruleset)
- La source (supplément d'origine)
- Une description générale en texte enrichi
- En DD3.5 uniquement : le modificateur de niveau global (entier, 0 par défaut)

Les **capacités raciales** se gèrent dans un bloc séparé, disponible uniquement après que la race a été créée une première fois. Ce bloc affiche la liste des capacités déjà attribuées à la race. Le gestionnaire peut :

- Ajouter une nouvelle capacité (nom, description, type en DD3.5)
- Modifier une capacité existante
- Supprimer une capacité de la race
- **Réordonner les capacités par glisser-déposer** — l'ordre défini ici est l'ordre d'affichage dans la fiche

Toutes les modifications (données de base + capacités) sont enregistrées en une seule validation.

### Supprimer une race

La suppression d'une race est refusée si des personnages utilisent cette race (que ce soit comme race de base ou comme archétype en DD3.5). Un message indique le nombre de personnages concernés.

La suppression d'une race ne supprime pas les capacités spéciales elles-mêmes : celles-ci peuvent être partagées avec d'autres races ou classes.