# -*- coding: utf-8 -*-

"""
Classes utilitaires pour interfacer codemetre en Python et outiller la
gestion des lots
"""

__all__ = ["lot", "metreur"]

import sys

if sys.platform == "win32":
    BIN_CODEMETRE = "codemetre.exe"
else:
    BIN_CODEMETRE = "codemetre"

from codemetre.lot import Lot
from codemetre.metreur import Mesure, Distance

################################################################################

# BAS NIVEAU

# Interface unifiée multi-plateforme pour pouvoir faire des appels systèmes
# fiables quelque soit la version 2.x de Python

if sys.platform == "win32" and sys.version_info < (2, 6):
    from popen2 import popen3

    def _appel_systeme(arguments):
        commande = " ".join(arguments)
        f_out, f_in, f_err = popen3(commande)
        out = f_out.read()
        err = f_err.read()
        return out, err
else:
    import subprocess

    def _appel_systeme(arguments):
        sp = subprocess.Popen(arguments,
                              stdout=subprocess.PIPE,
                              stderr=subprocess.PIPE)
        return sp.communicate()

def mesurer(*entrees, **parametres):
    """Fournit, pour chaque entrée, un dictionnaire d'attributs tels que :
    - "name" : le nom du fichier évalué ;
    - "status" : "OK" où un message d'erreur expliquant l'impossibilité de
    l'évaluation ;
    - "language" : le nom du langage de programmation ;
    - "code" : le nombre de lignes de code du fichier ;
    - "comment" : le nombre de lignes de commentaire ;
    - "total" : le nombre total de lignes, code et commentaires confondus.

    Si une entrée est un répertoire, tous les fichiers de ce répertoire sont
    évalués.

    Fonctionne comme un itérateur (fournit une sortie à la fois)
    """

    # On constitue la ligne de commande en analysant les paramètres. Le seul
    # paramètre intéressant/dimensionnant est le choix du langage. Produire
    # ou non le nombre de commentaire par exemple n'a pas un énorme impact
    # sur les performances
    commande = [BIN_CODEMETRE, "--code", "--comment", "--total"]
    if "lang" in parametres:
        commande += ["--lang", parametres[lang]]
    commande += list(*entrees)

    # Exécution de la commande
    sorties = dict()
    out, err = _appel_systeme(commande)
    out = out.split('\n')
    err = err.split('\n')

    for ligne in out:
        champs = ligne.split()
        sortie.clear()
        sortie["name"] = champs[0]
        sortie["status"] = "OK"
        sortie["language"] = champs[-7]
        for i, v in enumerate(champs):
            if v == "code" \
                    or v == "comment" \
                    or v == "total":
                sortie[v] = int(champs[i + 1])
            yield sortie

    for ligne in err:
        champs = ligne.split()
        sortie.clear()
        sortie["name"] = None
        sortie["status"] = "Error"
        sortie["language"] = None
        sortie["code"] = None
        sortie["comment"] = None
        sortie["total"] = None
        yield sortie

# HAUT NIVEAU

class Entry(object):
    def __init__(self, name):
        self._name = name
        self._status = None
        self._language = None


    def status(self):
        return self._status


    def language(self):
        return self._language



class Group(object):
    def __init__(self, name):
        self._name = name
        self._entries = OrderedDict()


    def entries(self):
        return self._entries.itervalues()



class Project(object):
    def __init__(self, *names):
        """If some of the names point to directories, these ones are expanded
        to get all their leaves immediately
        """
        self._names = list(*names)
        self._groups = dict()
        self._entries = dict()


    def names(self):
        return self._names


    def entries(self, group=None):
        if group is None:
            for name in self._names:
                if name in self._groups:
                    for entry in self._groups[name].entries():
                        yield entry
                else: # if name in self._entries:
                    yield self._entries[name]
        elif group in self._groups:
            for entry in self._groups[name].entries():
                yield entry
        else:
            raise ValueError("no such name in Project : %s" % name)


    def entry(self, name):
        if name not in self._names:
            raise ValueError("no such entry in Project : %s" % name)
        elif name in self._groups:
