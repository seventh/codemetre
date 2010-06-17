#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
from codemetre.lot import *

lot = Lot()

for i in range(1,len(sys.argv)):
    lot.charger(sys.argv[i])
    racine = lot.racine()
    longueur_racine = len(racine)

    flux = open(sys.argv[i], "w")

    print >> flux, "#dirname:=" + racine
    for l in lot.lignes:
        print >> flux, l[longueur_racine:]
