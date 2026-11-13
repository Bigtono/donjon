-- 2026-11-12_sp-pe22_ca_vision_deplacement.sql
-- SP-PE22 — Fiche personnage : CA à trois valeurs (DD3.5), vision et déplacement.
--
-- `pe_ca` reste la CA OPTIMALE. `pe_ca_depourvu` (CA prise au dépourvu) et
-- `pe_ca_contact` (CA de contact) ne servent qu'en DD3.5 : en DD2024 les deux
-- colonnes existent mais ne sont ni saisies ni affichées.
-- Défaut 10 : la CA d'un personnage sans aucun modificateur. Les fiches
-- existantes ne sont pas rattrapées — rien ne permet de déduire une CA de
-- contact de la CA optimale ; elles se corrigent à la main.
--
-- `pe_vision` et `pe_deplacement` : textes courts libres, valables dans les
-- deux rulesets (ex. « Vision dans le noir (18 m), vision nocturne »,
-- « 15 m (10 cases), vol 45 m (bonne) »).
--
-- Le BBA n'a pas de colonne : il se calcule à l'affichage à partir de
-- `dd_classe_niveau.cn_bba` (voir bbaTotalPersonnage()).

ALTER TABLE dd_personnages
  ADD COLUMN pe_ca_depourvu SMALLINT NOT NULL DEFAULT 10 AFTER pe_ca,
  ADD COLUMN pe_ca_contact SMALLINT NOT NULL DEFAULT 10 AFTER pe_ca_depourvu,
  ADD COLUMN pe_vision VARCHAR(100) NOT NULL DEFAULT '' AFTER pe_pv,
  ADD COLUMN pe_deplacement VARCHAR(100) NOT NULL DEFAULT '' AFTER pe_vision;
