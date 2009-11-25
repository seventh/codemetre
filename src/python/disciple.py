#!/usr/bin/env python
# -*- coding: utf-8 -*-

from codemetre.lot import *
import os
import sys

def table_en_dictionnaire(p_table):
    retour = {}

    for chemin_et_fichier in p_table:
        if chemin_et_fichier != "":
            fichier = os.path.basename(chemin_et_fichier)
            if fichier in retour:
                print >> sys.stderr, "Attention doublon sur", fichier
            else:
                retour[fichier] = chemin_et_fichier

    return retour


if len(sys.argv) < 3:
    print """
Usage : %s <reference.txt> <evolution1.txt> [<evolution2.txt> ...]

         Réordonne les différents fichiers de manière à faire coïncider les
        entrées ligne à ligne, tout en permettant à 'evolution1.txt' d'être une
        référence de comparaison pour 'evolution2.txt', et ainsi de suite, sur
        la base du seul nom de fichier.
""" % sys.argv[0]
    exit(0)


lot = Lot()

# La table 'reference' liste les clefs dans l'ordre
reference = []

# On compare chaque fichier avec le suivant et la référence consolidée, et on
# produit une nouvelle version de celui-ci.

for i in range(1,len(sys.argv)):
    # Conversion du lot en dictionnaire
    lot.charger(sys.argv[i])
    base = table_en_dictionnaire(lot.lignes)

    if i == len(sys.argv)-1:
        evol = {}
    else:
        lot.charger(sys.argv[i+1])
        evol = table_en_dictionnaire(lot.lignes)

    flux = open(sys.argv[i], "w")

    # alignement sur la référence
    print >> flux, "#Base"
    for clef in reference:
        if clef in base:
            print >> flux, base[clef]
            del base[clef]
        else:
            print >> flux, ""

    # production des lignes à la fois dans la base et l'évolution
    print >> flux, "#Commun"
    ref = base.copy()
    for clef in ref:
        if clef in evol:
            reference.append(clef)
            print >> flux, base[clef]
            del base[clef]

    # production des lignes uniquement dans la base
    print >> flux, "#Spécifique"
    for clef in base:
        reference.append(clef)
        print >> flux, base[clef]

    flux.close()
