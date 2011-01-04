#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
Rajoute des directives 'dirtype' et 'dirname' en tête de lot pour en
faciliter la comparaison
"""

import sys
from codemetre.lot import Lot

if __name__ == "__main__":
    LOT = Lot()

    for argument in sys.argv[1:]:
        LOT.charger(argument)
        flux = open(argument, "w")
        print >> flux, str(LOT),
