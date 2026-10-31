-- sql/2026-10-31_choix_capacites_dd35_sp-ch6b.sql — SANS EFFET, remplacée par 2026-10-31_choix_capacites_sp-ch6b_dd35.sql
--
-- Ce fichier s'appelait ainsi à l'origine ; son nom passait AVANT 2026-10-31_choix_capacites_sp-ch0.sql dans l'ordre
-- alphabétique du moteur de migrations (« d » < « s »), donc il jouait avant la création des colonnes dont il dépend.
-- Le contenu a été déplacé dans le fichier au nouveau nom. Celui-ci est conservé vide : s'il reste sur un serveur,
-- il passe sans rien faire au lieu d'échouer. À supprimer une fois la production à jour.

SET NAMES utf8mb4;
