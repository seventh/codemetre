# -*- coding: utf-8 -*-

"""
Abstraction d'un lot de fichiers pour traitement par codemetre
"""

import metreur
import os
import sys

class Lot:
    """Liste de fichiers à traiter"""

    def __init__(self):
        """Constructeur"""
        self.lignes = []

    def charger(self, p_nom_lot):
        """
        Mémorise le lot dans une table en résolvant les effets des directives
        """
        self.lignes[:] = []
        racine = ""
        flux = None
        try:
            flux = open(p_nom_lot, "r")
        except IOError:
            pass

        if flux is not None:
            for chemin_et_fichier in flux:
                # Suppression des sauts de ligne
                chemin_et_fichier = chemin_et_fichier.translate(None, '\n\r')

                # On filtre les commentaires, et on prend en compte les
                # directives
                if chemin_et_fichier.startswith("#dirname:="):
                    racine = chemin_et_fichier[10:]

                # On charge les fichiers
                else:
                    if chemin_et_fichier != "" and racine != "":
                        chemin_et_fichier = racine + chemin_et_fichier
                self.lignes.append(chemin_et_fichier)

            flux.close()

    def lister(self, p_racine):
        """
        Initialise le lot à partir de la liste des fichiers du répertoire de
        racine correspondante
        """
        self.lignes[:] = []
        for racine, repertoires, fichiers in os.walk(p_racine):
            for fichier in fichiers:
                self.lignes.append(os.path.join(racine, fichier))

    def racine(self):
        """
        Détermine le plus long répertoire commun entre toutes les entrées du lot
        """
        retour = ""

        for ligne in self.lignes:
            retour = _prefixe_commun(retour, ligne)

        # on remonte jusqu'au séparateur
        i = len(retour)
        while i >= 0 and retour[i - 1] != '/':
            i = i - 1
        return retour[:i]

    def aligner(self, p_reference, p_hauteur=0):
        """
        Modifie le lot courant en établissant une correspondance sur les noms
        de fichiers en considérant le nom du fichier et leurs arborescences
        relatives. À hauteur nulle, seul le nom de fichier compte. Le répertoire
        amont est pris en compte pour une hauteur de 1, et ainsi de suite. Les
        fichiers ne trouvant pas de correspondance sont décalés à la fin, de
        manière à ne pas provoquer d'association non désirée.
        """
        retour = []

        # On extrait d'abord la liste de clefs issues de la référence sur
        # laquelle il faudra s'aligner

        evol = self._table_en_dictionnaire(p_hauteur)

        for ligne in p_reference.lignes:
            clef = _extraire_clef(ligne, p_hauteur)
            if clef in evol:
                self.lignes.remove(evol[clef])
                retour.append(evol[clef])
                del evol[clef]
            else:
                retour.append("")
        for ligne in self.lignes:
            retour.append(ligne)

        self.lignes[:] = retour

    def oter_doublons(self, p_hauteur=0):
        """
        Deux entrées sont considérées comme doublons si elles ont la même clef.
        La clef est constituée du nom du fichier préfixé d'un certain nombre de
        répertoires, nombre paramétré par l'argument 'hauteur'
        """
        retour = []
        clefs = []
        for ligne in self.lignes:
            clef = _extraire_clef(ligne, p_hauteur)
            if clef in clefs:
                print >> sys.stderr, "Attention doublon sur", ligne
            else:
                retour.append(ligne)
                clefs.append(clef)
        self.lignes[:] = retour

    def mesurer(self):
        """
        Fournit une mesure unitaire du lot
        """
        retour = metreur.Mesure()
        retour.effectuer_lot(self)
        return retour

    def comparer(self, p_reference):
        """
        Fournit une mesure comparative du lot par rapport à la référence donnée
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

        for chemin_et_fichier in self.lignes:
            if chemin_et_fichier != "":
                fichier = _extraire_clef(chemin_et_fichier, p_hauteur)
                if fichier in retour:
                    print >> sys.stderr, "Attention doublon sur", fichier
                else:
                    retour[fichier] = chemin_et_fichier

        return retour

def _prefixe_commun(p_a, p_b):
    """Préfixe commun aux deux chaînes a et b le plus long"""

    if p_a == "":
        return p_b
    elif p_b == "":
        return p_a
    else:
        l = min(len(p_a), len(p_b))

        i = 0
        while i < l and p_a[i] == p_b[i]:
            i = i + 1

    return p_a[:i]

def _extraire_clef(p_chemin_et_fichier, p_hauteur):
    """Fournit un suffixe de 'chemin_et_fichier' afin de servir de clef. La clef
    contient exactement 'hauteur' séparateurs de répertoires"""
    parties = p_chemin_et_fichier.rsplit("/", p_hauteur+1)
    return "/".join(parties[1:])

def _extraire_valeur(p_ligne):
    """Supprime les marques de fin de ligne d'une chaîne de caractère"""
    return p_ligne.translate(None, '\n\r')
