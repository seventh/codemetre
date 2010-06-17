#!/usr/bin/env python
# -*- coding: utf-8 -*-

from codemetre.lot import *
import os
import string
import sys

def table_en_dictionnaire(p_table, p_lg_prefixe):
    retour = {}

    for chemin_et_fichier in p_table:
        if chemin_et_fichier != "":
            parties = string.rsplit(chemin_et_fichier,"/",p_lg_prefixe+1)
            fichier = string.join(parties[1:],"/")
            if fichier in retour:
                print >> sys.stderr, "Attention doublon sur", fichier
            else:
                retour[fichier] = chemin_et_fichier

    return retour

# Récupération des paramètres : hauteur d'unicité et nom des fichiers

lg_prefixe = 0
fichiers = []
try:
    fichiers[:] = sys.argv[1:]
    if sys.argv[1] == '-p':
        lg_prefixe = max(lg_prefixe,int(sys.argv[2]))
        fichiers[:] = sys.argv[3:]
except Exception, e:
    pass

# Vérification de la ligne de commande hors paramètres optionnels

if len(fichiers) < 2:
    print """
Usage : %s [-p N] <reference.txt> <evolution1.txt> [<evolution2.txt> ...]

         Réordonne les différents fichiers de manière à faire coïncider les
        entrées ligne à ligne, tout en permettant à 'evolution1.txt' d'être une
        référence de comparaison pour 'evolution2.txt', et ainsi de suite, sur
        la base du seul nom de fichier.

         Le paramètre optionnel -p permet de fixer la hauteur du contexte à
        prendre en compte pour déterminer l'unicité des fichiers. La valeur par
        défaut est 0.
""" % sys.argv[0]
    exit(0)


lot = Lot()

# La table 'reference' liste les clefs dans l'ordre
reference = []

# On compare chaque fichier avec le suivant et la référence consolidée, et on
# produit une nouvelle version de celui-ci.

for i, fichier in enumerate(fichiers):
    # Conversion du lot en dictionnaire
    lot.charger(fichier)
    base = table_en_dictionnaire(lot.lignes, lg_prefixe)

    if i == len(fichiers)-1:
        evol = {}
    else:
        lot.charger(fichiers[i+1])
        evol = table_en_dictionnaire(lot.lignes, lg_prefixe)

    flux = open(fichier, "w")

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
