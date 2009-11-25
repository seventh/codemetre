#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
from codemetre.lot import *

if len(sys.argv) != 3:
    print "Erreur !"
    exit(1)

longueur_racine = len(sys.argv[1])

lot = Lot()
lot.charger(sys.argv[2])

print "#dirname:=" + sys.argv[1]
for l in lot.lignes:
    print l[longueur_racine:]
