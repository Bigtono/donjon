// js/campagne.js — Interactions de la page liste des campagnes.
// Les URLs sont injectées en variables globales par index.php :
//   campUrlDetail, campUrlModifier, campUrlEnreg
// Le formulaire (modifier/campagne.php) gère sa propre soumission en IIFE.
'use strict';

const campagneListe = {

  // Ouvre la fiche détail (contexte 'liste' → la liste se rafraîchit à la fermeture).
  ouvrir(id) {
    actualiserPage(campUrlDetail, { id: id }, 'liste');
  },

  // Ouvre le formulaire de création.
  nouvelle() {
    ouvrirModifier(campUrlModifier, 0);
  },

  // Supprime une campagne (suppression douce en cascade côté serveur).
  supprimer(id, nom) {
    const message = 'Supprimer la campagne « ' + nom + ' » ?\n\n'
      + 'Ses scénarios, rencontres et oppositions seront également supprimés. '
      + 'Cette action est définitive.';
    confirmer(message, async () => {
      try {
        const data = await postAjax(campUrlEnreg, {
          action: 'supprimerCampagne',
          id: id,
        });
        if (data.ok) {
          fermerDetailPP();
          rafraichirListe();
        } else {
          alert(data.erreur || 'Erreur lors de la suppression.');
        }
      } catch (err) {
        alert('Erreur : ' + err);
      }
    });
  },

};
