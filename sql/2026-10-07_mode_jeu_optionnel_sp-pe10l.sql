-- 2026-10-07_mode_jeu_optionnel_sp-pe10l.sql
-- SP-PE10l — Le bloc « Mode jeu » de la fiche personnage devient optionnel.
--
-- Il ne porte encore qu'un emplacement réservé (le suivi des PV et des
-- variables de partie relève de SP-PE8) : une préférence permet de le masquer
-- en attendant, comme `j_mode_campagne` masque le menu Campagnes.
--
-- Défaut à 0 : le bloc est replié et vide, le montrer par défaut reviendrait à
-- imposer une barre d'en-tête pour rien. Un joueur qui le veut l'active.
--
-- Local (préfixe dd_) ; sur OVH, le script de renommage applique dd2_.

ALTER TABLE dd_joueurs
  ADD COLUMN j_affichage_mode_jeu TINYINT(1) NOT NULL DEFAULT 0
  AFTER j_affichage_ruleset;
