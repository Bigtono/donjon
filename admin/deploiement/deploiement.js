// admin/deploiement/deploiement.js — Panneau de déploiement (SP-DP4)
//
// Chargé par le bouton du header (admin/deploiement/bouton.php), en local
// uniquement. Ouvre l'aperçu dans #modification, demande une confirmation
// explicite, puis enchaîne les étapes une à une (ajax.php). Le serveur garde
// le plan : ce script n'envoie que l'identifiant du plan et l'index attendu.
//
// Un déploiement lancé continue si le panneau est fermé ; le résultat arrive
// alors par notifier(). Quitter la page l'interromprait : beforeunload avertit.
'use strict';

var DEPLOIEMENT_EN_COURS = false;

function ouvrirDeploiement(params) {
  if (DEPLOIEMENT_EN_COURS) {
    notifier('Déploiement en cours — patienter jusqu\'à la fin.', 'info');
    return;
  }
  actualiserPageModif(BASE_URL + '/admin/deploiement/panneau.php', params || {});
}

(function () {
  function appel(donnees) {
    return postAjax(BASE_URL + '/admin/deploiement/ajax.php', donnees);
  }

  // Les nœuds sont recherchés à chaque fois : le panneau a pu être fermé
  // (vidé) ou rouvert entre deux étapes.
  function element(selecteur) {
    var zone = document.getElementById('deploiement');
    return zone ? zone.querySelector(selecteur) : null;
  }

  // numero : rang réel de l'étape, conservé après une reprise (sinon la liste
  // renumérote à partir de 1).
  function ligneJournal(texte, etat, numero) {
    var liste = element('.deploiement__journal');
    if (!liste) return null;
    var li = document.createElement('li');
    li.className = 'deploiement__etape deploiement__etape--' + etat;
    if (numero) li.value = numero;
    var libelle = document.createElement('span');
    libelle.className = 'deploiement__etape-libelle';
    libelle.textContent = texte;
    li.appendChild(libelle);
    liste.appendChild(li);
    return li;
  }

  function terminerLigne(li, etat, detail) {
    if (!li || !li.isConnected) return;
    li.className = 'deploiement__etape deploiement__etape--' + etat;
    if (detail) {
      var d = document.createElement('div');
      d.className = 'deploiement__etape-detail';
      d.textContent = detail;
      li.appendChild(d);
    }
  }

  function progression(fait, total) {
    var barre = element('.deploiement__progression');
    if (!barre) return;
    barre.classList.remove('noDisplay');
    barre.max = total;
    barre.value = fait;
  }

  function boutonsReprise(visible) {
    var actions = element('.deploiement__actions-reprise');
    if (actions) actions.classList.toggle('noDisplay', !visible);
  }

  // Enchaîne les étapes à partir de index. En cas d'échec, s'arrête et propose
  // Reprendre (même étape) ou Abandonner (rouvrir le site).
  function executer(planId, etapes, index) {
    DEPLOIEMENT_EN_COURS = true;
    boutonsReprise(false);

    function suivante(i) {
      if (i >= etapes.length) return;
      var li = ligneJournal(etapes[i], 'encours', i + 1);
      appel({ action: 'etape', plan: planId, index: i })
        .then(function (r) {
          if (!r.ok) throw new Error(r.erreur || 'Erreur inconnue');
          terminerLigne(li, 'ok', r.detail);
          progression(i + 1, etapes.length);
          if (r.termine) {
            DEPLOIEMENT_EN_COURS = false;
            ligneJournal('Déploiement terminé.', 'fin');
            notifier('Déploiement terminé : ' + r.detail);
            return;
          }
          suivante(i + 1);
        })
        .catch(function (err) {
          DEPLOIEMENT_EN_COURS = false;
          terminerLigne(li, 'echec', err.message);
          // Pastille courte : le détail de l'erreur reste dans le panneau.
          notifier('Déploiement interrompu — détail dans le panneau.', 'erreur');
          // Le panneau a pu être fermé : le rouvrir affiche l'état inachevé.
          if (document.getElementById('deploiement')) {
            ouvrirReprise(planId, etapes, i);
          }
        });
    }
    suivante(index);
  }

  // Après un échec : boutons Reprendre / Abandonner sous le journal.
  function ouvrirReprise(planId, etapes, index) {
    var suivi = element('.deploiement__suivi');
    if (!suivi) return;
    var actions = element('.deploiement__actions-reprise');
    if (!actions) {
      actions = document.createElement('div');
      actions.className = 'form-actions deploiement__actions-reprise';
      actions.innerHTML =
        '<button type="button" class="btn btn-primary" data-deploiement="reprendre">'
        + '<i class="fa fa-rotate-right"></i> Reprendre</button>'
        + '<button type="button" class="btn btn-secondary" data-deploiement="abandonner">'
        + '<i class="fa fa-ban"></i> Abandonner et rouvrir le site</button>';
      suivi.parentNode.insertBefore(actions, suivi.nextSibling);
    }
    suivi.dataset.plan = planId;
    suivi.dataset.prochaine = index;
    suivi.dataset.etapes = JSON.stringify(etapes);
    boutonsReprise(true);
  }

  function question(conf) {
    var envoi = parseInt(conf.dataset.nbEnvoi, 10);
    var supprimer = element('input[name="supprimer"]');
    var migrations = element('input[name="migrations"]');
    var parties = [];
    if (envoi > 0) parties.push('envoyer ' + envoi + ' fichier' + (envoi > 1 ? 's' : ''));
    if (supprimer && supprimer.checked) {
      var nb = parseInt(conf.dataset.nbSuppression, 10);
      parties.push('supprimer ' + nb + ' fichier' + (nb > 1 ? 's' : ''));
    }
    if (migrations && migrations.checked) parties.push('appliquer les migrations SQL en attente');
    if (!parties.length) return 'Rien à faire avec ces options.';
    var texte = parties.join(', ').replace(/, ([^,]*)$/, ' et $1');
    return texte.charAt(0).toUpperCase() + texte.slice(1) + ' sur ' + conf.dataset.cible + ' ?'
      + (envoi > 0 || (supprimer && supprimer.checked)
        ? ' Le site de production sera en maintenance pendant l\'opération.'
        : '');
  }

  var actions = {
    // Étape 1 → 2 : afficher la confirmation explicite.
    demander: function () {
      var conf = element('.deploiement__confirmation');
      if (!conf) return;
      conf.querySelector('.deploiement__question').textContent = question(conf);
      conf.classList.remove('noDisplay');
      element('.deploiement__actions').classList.add('noDisplay');
    },

    annuler: function () {
      element('.deploiement__confirmation').classList.add('noDisplay');
      element('.deploiement__actions').classList.remove('noDisplay');
    },

    complet: function () {
      ouvrirDeploiement({ complet: 1 });
    },

    // Étape 2 → 3 : figer le plan côté serveur, puis dérouler.
    confirmer: function (bouton) {
      var conf = element('.deploiement__confirmation');
      var migrations = element('input[name="migrations"]');
      var supprimer = element('input[name="supprimer"]');
      bouton.disabled = true;
      element('.deploiement__options').classList.add('noDisplay');
      appel({
        action: 'demarrer',
        plan: conf.dataset.plan,
        migrations: migrations && migrations.checked ? 1 : 0,
        supprimer: supprimer && supprimer.checked ? 1 : 0
      })
        .then(function (r) {
          if (!r.ok) throw new Error(r.erreur || 'Erreur inconnue');
          conf.classList.add('noDisplay');
          element('.deploiement__suivi').classList.remove('noDisplay');
          progression(0, r.etapes.length);
          executer(conf.dataset.plan, r.etapes, 0);
        })
        .catch(function (err) {
          bouton.disabled = false;
          element('.deploiement__options').classList.remove('noDisplay');
          notifier(err.message, 'erreur');
        });
    },

    reprendre: function () {
      var suivi = element('.deploiement__suivi');
      if (!suivi || !suivi.dataset.plan) return;
      var etapes = JSON.parse(suivi.dataset.etapes);
      var index = parseInt(suivi.dataset.prochaine, 10);
      progression(index, etapes.length);
      executer(suivi.dataset.plan, etapes, index);
    },

    abandonner: function (bouton) {
      confirmer('Abandonner le déploiement ? Le site sera rouvert avec le code dans son état actuel, '
        + 'en partie neuf, en partie ancien. Un nouveau déploiement enverra ce qui manque.', function () {
        bouton.disabled = true;
        appel({ action: 'abandonner' })
          .then(function (r) {
            notifier(r.ok ? 'Déploiement abandonné, site rouvert.' : r.erreur, r.ok ? 'ok' : 'erreur');
            ouvrirDeploiement();
          })
          .catch(function (err) {
            bouton.disabled = false;
            notifier(err.message, 'erreur');
          });
      });
    }
  };

  document.addEventListener('click', function (e) {
    var bouton = e.target.closest('#deploiement [data-deploiement]');
    if (!bouton) return;
    var action = actions[bouton.getAttribute('data-deploiement')];
    if (!action || bouton.disabled) return;
    e.preventDefault();
    action(bouton);
  });

  window.addEventListener('beforeunload', function (e) {
    if (!DEPLOIEMENT_EN_COURS) return;
    e.preventDefault();
    e.returnValue = '';
  });
})();
