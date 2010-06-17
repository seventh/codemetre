# -*- coding: utf-8 -*-

"""
Ce paquetage permet d'obtenir des métriques pour un fichier donné,
éventuellement en comparaison d'une ancienne version dite "de référence"
"""

import copy
import subprocess

BIN_CODEMETRE = "codemetre"

class Mesure:
    """Résultat de mesure unitaire de codemetre"""

    def __init__(self):
        self.fichier = None
        self.nb_fichier = 0
        self.code = 0
        self.commentaire = 0
        self.total = 0

    def __repr__(self):
        retour = self.fichier + " "
        retour += str(self.nb_fichier) + " "
        retour += str(self.code) + " "
        retour += str(self.commentaire)

        return retour

    def accumuler(self, autre):
        """Consolide les résultats dans l'instance courante"""
        self.fichier = None
        self.nb_fichier = self.nb_fichier + autre.nb_fichier
        self.code = self.code + autre.code
        self.commentaire = self.commentaire + autre.commentaire
        self.total = self.total + autre.total

    def effectuer(self, fichier):
        """Réalise la mesure du fichier correspondant"""
        self.fichier = fichier
        self.nb_fichier = 0
        self.code = 0
        self.commentaire = 0
        self.total = 0

        sp = subprocess.Popen([BIN_CODEMETRE,
                               "--code", "--comment", "--total",
                               fichier],
                              stdout=subprocess.PIPE,
                              stderr=subprocess.PIPE)
        out, err = sp.communicate()
        out = out.split()
        err = err.split('\n')

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
        """Réalise la mesure du fichier correspondant"""
        self.__init__()
        tampon = copy.copy(self)
        for fichier in p_lot.lignes:
            tampon.effectuer(fichier)
            self.accumuler(tampon)


class Distance:
    """Résultat de mesure différentielle de codemetre"""
    def __init__(self):
        self.fichier = None
        self.reference = None
        self.nb_fichier = 0
        self.avant = 0
        self.commun = 0
        self.apres = 0

    def __repr__(self):
        retour = self.fichier + " "
        retour += str(self.nb_fichier) + " "
        retour += str(self.avant) + " "
        retour += str(self.apres) + " "
        retour += str(self.commun)

        return retour

    def accumuler(self, autre):
        """Consolide les résultats dans l'instance courante"""
        self.fichier = None
        self.reference = None
        self.nb_fichier = self.nb_fichier + autre.nb_fichier
        self.avant = self.avant + autre.avant
        self.apres = self.apres + autre.apres
        self.commun = self.commun + autre.commun

    def effectuer(self, fichier, reference):
        """Réalise la mesure du fichier correspondant"""
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

        sp = subprocess.Popen([BIN_CODEMETRE, "--diff", "--code", avant, apres],
                              stdout=subprocess.PIPE,
                              stderr=subprocess.PIPE)
        out, err = sp.communicate()
        out = out.split()
        err = err.split('\n')

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
        """Réalise la mesure du fichier correspondant"""
        self.__init__()
        tampon = copy.copy(self)
        lg_min = min(len(p_lot.lignes), len(p_lot_ref.lignes))

        for i in range(lg_min):
            tampon.effectuer(p_lot.lignes[i], p_lot_ref.lignes[i])
            self.accumuler(tampon)
        for i in range(lg_min, len(p_lot.lignes)):
            tampon.effectuer(p_lot.lignes[i], None)
            self.accumuler(tampon)
        for i in range(lg_min, len(p_lot_ref.lignes)):
            tampon.effectuer(None, p_lot_ref.lignes[i])
            self.accumuler(tampon)
