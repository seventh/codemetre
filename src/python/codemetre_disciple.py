#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
Utilitaire d'alignement de différents Lots codemetre pour en faciliter la
comparaison
"""

from codemetre.lot import Lot
import getopt
import sys


def usage():
    """
    Affiche sur la sortie standard une aide rapide et sort immédiatement
    """
    print """
Usage : %s [-p N] <reference.txt> <evolution.txt> [...]

         Réordonne les différents fichiers de manière à faire coïncider les
        entrées ligne à ligne, tout en permettant à 'evolution.txt' d'être une
        référence de comparaison pour le fichier suivant, et ainsi de suite, sur
        la base du seul nom de fichier.

         Le paramètre optionnel -p permet de fixer la hauteur du contexte à
        prendre en compte pour déterminer l'unicité des fichiers. La valeur par
        défaut est 0.
""" % sys.argv[0]
    exit(0)

if __name__ == "__main__":
    # Récupération des paramètres : hauteur d'unicité et nom des fichiers
    try:
        OPTS, ARGS = getopt.getopt(sys.argv[1:], "p:")
    except getopt.GetoptError, erreur:
        print str(erreur)
        usage()

    LG_PREFIXE = 0
    for opt, arg in OPTS:
        if opt == "-p":
            LG_PREFIXE = int(arg)
    if len(ARGS) < 2:
        usage()

    # On compare chaque fichier avec le suivant et la référence consolidée,
    # et on produit une nouvelle version de celui-ci.

    REFERENCE = Lot()

    for fichier in ARGS:
        LOT = Lot()
        LOT.charger(fichier)
        LOT.aligner(REFERENCE, LG_PREFIXE)

        flux = open(fichier, "w")
        print >> flux, str(LOT),
        flux.close()

        REFERENCE.chemins.extend(LOT.chemins[:len(REFERENCE.chemins)])
