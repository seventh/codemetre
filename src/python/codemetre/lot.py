#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import sys

class Lot:
    """Liste de fichiers à traiter"""

    lignes = []

    def __init__(self):
        """Constructeur"""
        pass


    def charger(self, p_nom_lot):
        """Mémorise le lot dans une table en résolvant les effets des directives"""
        self.lignes = []
        racine = ""
        flux = open(p_nom_lot, "r")

        for chemin_et_fichier in flux:
            chemin_et_fichier = self._extraire_valeur(chemin_et_fichier)

            # On filtre les commentaires, et on prend en compte les directives

            if len(chemin_et_fichier) > 0 and chemin_et_fichier[0] == '#':
                if len(chemin_et_fichier) > 10 and chemin_et_fichier[0:10] == "#dirname:=":
                    racine = chemin_et_fichier[10:]

            # On charge les fichiers

            else:
                if chemin_et_fichier != "" and racine != "":
                    chemin_et_fichier = racine + chemin_et_fichier
                self.lignes.append(chemin_et_fichier)

        flux.close()


    def racine(self):
        """
        Détermine le plus long répertoire commun entre toutes les entrées du lot
        """
        retour = ""

        for i in range(len(self.lignes)):
            retour = self._prefixe_commun(retour, self.lignes[i])

        # on remonte jusqu'au séparateur
        i = len(retour)
        while i >= 0 and retour[i - 1] != '/':
            i = i - 1
        return retour[:i]


    def _prefixe_commun(self, p_a, p_b):
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


    def _extraire_valeur(self, p_ligne):
        """Supprime les marques de fin de ligne d'une chaîne de caractère"""
        retour = p_ligne
        while len(retour) > 0 and retour[-1] in ( '\n', '\r' ):
            retour = retour[:-1]

            return retour
