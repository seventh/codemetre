# -*- coding: utf-8 -*-

"""
Ce paquetage permet d'obtenir des métriques pour un fichier donné, brutes ou
en comparaison d'une ancienne version dite "de référence"
"""

import copy
import sys
from codemetre import BIN_CODEMETRE

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

class Mesure:
    """
    Résultat de mesure unitaire de codemetre
    """
    def __init__(self):
        self.fichier = None
        self.nb_fichier = 0
        self.code = 0
        self.commentaire = 0
        self.total = 0

    def __str__(self):
        retour = self.fichier + " "
        retour += str(self.nb_fichier) + " "
        retour += str(self.code) + " "
        retour += str(self.commentaire)

        return retour

    def accumuler(self, autre):
        """
        Consolide les résultats dans l'instance courante
        """
        self.fichier = None
        self.nb_fichier = self.nb_fichier + autre.nb_fichier
        self.code = self.code + autre.code
        self.commentaire = self.commentaire + autre.commentaire
        self.total = self.total + autre.total

    def effectuer(self, fichier):
        """
        Réalise la mesure du fichier correspondant
        """
        self.fichier = fichier
        self.nb_fichier = 0
        self.code = 0
        self.commentaire = 0
        self.total = 0

        out, err = _appel_systeme([BIN_CODEMETRE, "--code", "--comment",
                                   "--total", fichier])
        out = out.split()
        err = err.split('\n')

        if len(err) == 1:
            self.nb_fichier = 1
            for i, v in enumerate(out):
                if v == "code":
                    self.code = int(out[i + 1])
                elif v == "comment":
                    self.commentaire = int(out[i + 1])
                elif v == "total":
                    self.total = int(out[i + 1])

    def effectuer_lot(self, p_lot):
        """
        Réalise la mesure du lot correspondant
        """
        self.__init__()
        tampon = copy.copy(self)
        for chemin in p_lot:
            tampon.effectuer(chemin)
            self.accumuler(tampon)


class Distance:
    """
    Résultat de mesure différentielle de codemetre
    """
    def __init__(self):
        self.fichier = None
        self.reference = None
        self.nb_fichier = 0
        self.avant = 0
        self.commun = 0
        self.apres = 0

    def __str__(self):
        retour = self.fichier + " "
        retour += str(self.nb_fichier) + " "
        retour += str(self.avant) + " "
        retour += str(self.apres) + " "
        retour += str(self.commun)

        return retour

    def accumuler(self, autre):
        """
        Consolide les résultats dans l'instance courante
        """
        self.fichier = None
        self.reference = None
        self.nb_fichier = self.nb_fichier + autre.nb_fichier
        self.avant = self.avant + autre.avant
        self.apres = self.apres + autre.apres
        self.commun = self.commun + autre.commun

    def effectuer(self, fichier, reference):
        """
        Réalise la mesure du fichier correspondant
        """
        self.fichier = fichier
        self.reference = reference
        self.nb_fichier = 0
        self.avant = 0
        self.apres = 0
        self.commun = 0

        avant = reference
        if reference is None or reference == "":
            avant = "-nil-"

        apres = fichier
        if fichier is None or fichier == "":
            apres = "-nil-"

        out, err = _appel_systeme([BIN_CODEMETRE, "--diff", "--code", "--model",
                                   "normal", avant, apres])
        out = out.split()
        err = err.split('\n')

        if len(err) == 1:
            self.nb_fichier = 1
            for i, v in enumerate(out):
                if v == "A":
                    self.avant = int(out[i + 1])
                elif v == "N":
                    self.apres = int(out[i + 1])
                elif v == "C":
                    self.commun = int(out[i + 1])

    def effectuer_lot(self, p_lot, p_lot_ref):
        """
        Réalise la comparaison des lots correspondants
        """
        self.__init__()
        tampon = copy.copy(self)
        lg_max = max(len(p_lot.chemins), len(p_lot_ref.chemins))

        for i in range(lg_max):
            try:
                avant = p_lot_ref.chemins[i]
            except IndexError:
                avant = None

            try:
                apres = p_lot.chemins[i]
            except IndexError:
                apres = None

            tampon.effectuer(apres, avant)
            self.accumuler(tampon)
