-- sql/2026-08-28_capacites_drop_categorie.sql
-- Suppression de dd_capacites_speciales.cap_categorie_var_id.
--
-- MOTIF (arbitrage utilisateur du 2026-08-28) : reliquat de l'application v1.
-- La colonne servait à dire si la capacité venait d'une race (91) ou d'une
-- classe (92). L'information est portée depuis par les tables de liaison
-- elles-mêmes — dd_race_capacite d'un côté, dd_classe_capacite de l'autre —
-- et une même capacité peut légitimement relever des deux.
--
-- État relevé avant suppression : 508 lignes à 92, 47 à 91, 41 à NULL. Les
-- valeurs 91 et 92 ne désignaient plus rien : dd_variables ne contient plus que
-- les catégories « profinc » et « ruleset ». Le seul lecteur du code
-- (include/ajax/detail-pp/capacite.php) faisait un LEFT JOIN qui ne ramenait
-- donc jamais de libellé — le bloc d'affichage était mort.
--
-- ⚠ NON IDEMPOTENT ET IRRÉVERSIBLE. Vérifier avant rejeu :
--     SHOW COLUMNS FROM dd_capacites_speciales LIKE 'cap_categorie_var_id';
--
-- Code mis à jour dans la même livraison : la requête et le bloc d'affichage de
-- include/ajax/detail-pp/capacite.php, et les patchs SP-IM3 / SP-IM4 qui
-- renseignaient la colonne. Aucune écriture n'existait ailleurs — les INSERT et
-- UPDATE de compendium/enregistrement.php ne l'ont jamais touchée.
--
-- Ordre d'application libre vis-à-vis de SP-IM3 et SP-IM4 : depuis leur mise à
-- jour, ces deux patchs ne référencent plus la colonne.

ALTER TABLE dd_capacites_speciales
  DROP COLUMN cap_categorie_var_id;
