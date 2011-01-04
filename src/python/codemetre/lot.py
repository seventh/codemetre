# -*- coding: utf-8 -*-

"""
Abstraction d'un lot de fichiers pour traitement par codemetre.
"""

import codemetre.metreur as metreur
import os
import sys

import ntpath as notation_windows
import os.path as notation_locale
import posixpath as notation_unix

class Lot:
    """
    Liste de fichiers à traiter
    """
    def __init__(self):
        """
        Constructeur
        """
        self.chemins = []
        self.notation = notation_locale

    def __iter__(self):
        """
        Itérateur sur les fichiers du Lot
        """
        for chemin in self.chemins:
            yield chemin

    def __str__(self):
        """
        Forme affichable du Lot. Produit une directive "#dirname:=" et liste
        le contenu dans le format local d'accès aux fichiers
        """
        racine = self.racine()
        lg_racine = len(racine)

        # Directives 'dirtype' et 'dirname'
        retour = "#dirtype:="
        if self.notation == notation_windows:
            retour += "windows"
        else:
            retour += "unix"
        retour += "\n"

        retour += "#dirname:=" + racine + "\n"

        # Liste des chemins
        for chemin in self.chemins:
            entree = chemin[lg_racine:]
            retour += entree + "\n"
        return retour

    def charger(self, p_nom_lot):
        """
        Mémorise le lot dans une table en résolvant les effets des
        directives
        """
        self.chemins[:] = []
        self.notation = notation_locale

        racine = ""
        with open(p_nom_lot, "r") as flux:
            for chemin_et_fichier in flux:
                # Suppression des sauts de ligne
                chemin_et_fichier = chemin_et_fichier.rstrip()

                # On prend en compte les directives
                if chemin_et_fichier.startswith("#dirtype:="):
                    notation = chemin_et_fichier[10:]
                    if notation == "windows":
                        self.notation = notation_windows
                    else:
                        self.notation = notation_unix
                elif chemin_et_fichier.startswith("#dirname:="):
                    racine = chemin_et_fichier[10:]
                elif chemin_et_fichier.startswith("#"):
                    pass

                # On charge les fichiers
                else:
                    chemin_et_fichier = self.notation.join(racine,
                                                           chemin_et_fichier)
                    self.chemins.append(chemin_et_fichier)

    def ajouter(self, p_chemin):
        """
        Ajouter le fichier de chemin correspondant à la fin du Lot, en
        prenant soin d'effectuer les conversions nécessaires
        """
        self.chemins.append(p_chemin)

    def lister(self, p_racine):
        """
        Initialise le lot à partir de la liste des fichiers du répertoire de
        racine correspondante
        """
        self.chemins[:] = []
        self.notation = notation_locale
        for racine, repertoires, fichiers in os.walk(p_racine):
            for fichier in fichiers:
                chemin_et_fichier = self.notation.join(racine, fichier)
                self.chemins.append(chemin_et_fichier)

    def racine(self):
        """
        Détermine le plus long répertoire commun entre toutes les entrées du
        lot
        """
        retour = self.notation.dirname(self.notation.commonprefix(self.chemins))
        if len(retour) > 0:
            retour += self.notation.sep
        return retour

    def aligner(self, p_reference, p_hauteur = 0):
        """
        Modifie le lot courant en établissant une correspondance sur les
        noms de fichiers en considérant le nom du fichier et leurs
        arborescences relatives. À hauteur nulle, seul le nom de fichier
        compte. Le répertoire amont est pris en compte pour une hauteur
        de 1, et ainsi de suite. Les fichiers ne trouvant pas de
        correspondance sont décalés à la fin, de manière à ne pas
        provoquer d'association non désirée.
        """
        evol = self._table_en_dictionnaire(p_hauteur)
        self.chemins[:] = []

        # On parcourt le Lot de référence dans l'ordre de ses entrées
        for chemin in p_reference.chemins:
            clef = self._extraire_clef(chemin, p_hauteur)
            # Pour chaque entrée, soit une entrée de clef identique est
            # présente dans le Lot courant : il y a correspondance
            if clef in evol:
                self.chemins.append(evol[clef])
                del evol[clef]
            # soit il n'y en a pas, et on laisse une ligne vide
            else:
                self.chemins.append("")

        # On ajoute à la fin toutes les entrées non associées
        self.chemins.extend(evol.itervalues())

    def oter_doublons(self, p_hauteur = 0):
        """
        Deux entrées sont considérées comme doublons si elles ont la
        même clef. La clef est constituée du nom du fichier préfixé d'un
        certain nombre de répertoires, nombre paramétré par l'argument
        'hauteur'. L'ordre des entrées n'est pas conservé.
        """
        chemins_par_clef = self._table_en_dictionnaire(p_hauteur)
        self.chemins[:] = list(chemins_par_clef.itervalues())

    def mesurer(self):
        """
        Fournit une mesure unitaire du lot
        """
        retour = metreur.Mesure()
        retour.effectuer_lot(self)
        return retour

    def comparer(self, p_reference):
        """
        Fournit une mesure comparative du lot par rapport à la référence
        donnée
        """
        retour = metreur.Distance()
        retour.effectuer_lot(self, p_reference)
        return retour

    def _table_en_dictionnaire(self, p_hauteur):
        """
        À partir de la liste de fichiers de la table, produit un dictionnaire
        dont la clef est le nom de fichier précédé du nombre de répertoires
        précisé par 'hauteur'
        """
        retour = {}

        for chemin in self.chemins:
            if chemin != "":
                fichier = self._extraire_clef(chemin, p_hauteur)
                if fichier in retour:
                    print >> sys.stderr, "Attention doublon sur", fichier
                else:
                    retour[fichier] = chemin

        return retour

    def _extraire_clef(self, p_chemin_et_fichier, p_hauteur):
        """
        Fournit un suffixe de 'chemin_et_fichier' afin de servir de clef. La
        clef contient exactement 'hauteur' séparateurs de répertoires
        """
        parties = p_chemin_et_fichier.rsplit(self.notation.sep, p_hauteur+1)
        return "/".join(parties[1:])
