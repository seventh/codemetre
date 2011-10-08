# -*- coding: utf-8 -*-

"""
Classes utilitaires pour interfacer codemetre en Python et outiller la
gestion des lots
"""

__all__ = ["lot", "metreur"]

import sys

if sys.platform == "win32":
    BIN_CODEMETRE = "codemetre.exe"
else:
    BIN_CODEMETRE = "codemetre"

from codemetre.lot import Lot
from codemetre.metreur import Mesure, Distance
