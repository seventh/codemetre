# -*- coding: utf-8 -*-

"""
Ce paquetage permet d'obtenir des métriques pour un fichier donné, brutes ou
en comparaison d'une ancienne version dite "de référence"
"""

import copy
from popen2 import popen3
import sys
import urllib

if sys.platform == "win32":
    BIN_CODEMETRE = "codemetre.exe"
else:
    BIN_CODEMETRE = "codemetre"

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

        f_out, f_in, f_err = popen3(BIN_CODEMETRE + " --code --comment" \
                                        + " --total " + fichier)
        out = f_out.read().split()
        err = f_err.read().split('\n')

        if len(err) <= 5:
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
        for url in p_lot:
            tampon.effectuer(urllib.url2pathname(url))
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

        f_out, f_in, f_err = popen3(BIN_CODEMETRE + " --diff --code" \
                                        + " --model normal " + avant \
                                        + " " + apres)
        out = f_out.read().split()
        err = f_err.read().split('\n')

        if len(err) <= 5:
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
        lg_max = max(len(p_lot.lignes), len(p_lot_ref.lignes))

        for i in range(lg_max):
            try:
                avant = urllib.url2pathname(p_lot_ref.urls[i])
            except IndexError:
                avant = None

            try:
                apres = urllib.url2pathname(p_lot.urls[i])
            except IndexError:
                apres = None

            tampon.effectuer(apres, avant)
            self.accumuler(tampon)
