# -*- coding: utf-8 -*-

"""
Abstraction d'un lot de fichiers pour traitement par codemetre. La
représentation interne des noms de fichier est sous la forme d'URL pour assurer
la portabilité.
"""

import codemetre.metreur as metreur
import os
import sys
import urllib

class Lot:
    """
    Liste de fichiers à traiter
    """
    def __init__(self):
        """
        Constructeur
        """
        self._urls = []

    @property
    def urls(self):
        """
        Liste des entrées du Lot
        """
        return self._urls

    def __iter__(self):
        """
        Itérateur sur les fichiers du Lot
        """
        for url in self.urls:
            yield url

    def __str__(self):
        """
        Forme affichable du Lot. Produit une directive "#dirname:=" et liste
        le contenu dans le format local d'accès aux fichiers
        """
        retour = "#dirname:="
        racine = self.racine()
        retour += racine
        retour += "\n"
        for url in self.urls:
            entree = url[len(racine):]
            retour += urllib.url2pathname(entree) + "\n"
        return retour

    def charger(self, p_nom_lot):
        """
        Mémorise le lot dans une table en résolvant les effets des directives
        """
        self.urls[:] = []
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

                # On prend en compte les directives
                if chemin_et_fichier.startswith("#dirname:="):
                    racine = chemin_et_fichier[10:]

                # On charge les fichiers
                else:
                    chemin_et_fichier = os.path.join(racine,
                                                     chemin_et_fichier)
                    self.urls.append(urllib.pathname2url(chemin_et_fichier))
            flux.close()

    def ajouter(self, p_chemin):
        """
        Ajouter le fichier de chemin correspondant à la fin du Lot, en prenant
        soin d'effectuer les conversions nécessaires
        """
        url = urllib.pathname2url(p_chemin)
        self.urls.append(p_chemin)

    def lister(self, p_racine):
        """
        Initialise le lot à partir de la liste des fichiers du répertoire de
        racine correspondante
        """
        self.urls[:] = []
        for racine, repertoires, fichiers in os.walk(p_racine):
            for fichier in fichiers:
                chemin_et_fichier = os.path.join(racine, fichier)
                self.urls.append(urllib.pathname2url(chemin_et_fichier))

    def racine(self):
        """
        Détermine le plus long répertoire commun entre toutes les entrées du lot
        """
        retour = ""

        # Détermination du plus long préfixe commun à toutes les entrées
        for url in self.urls:
            retour = _prefixe_commun(retour, url)

        # Remontée jusqu'au dernier séparateur
        i = retour.rfind("/")
        return retour[:i + 1]

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
        retour = []

        evol = self._table_en_dictionnaire(p_hauteur)

        # On parcourt le Lot de référence dans l'ordre de ses entrées
        for url in p_reference.urls:
            clef = _extraire_clef(url, p_hauteur)
            # Pour chaque entrée, soit une entrée de clef identique est
            # présente dans le Lot courant : il y a correspondance
            if clef in evol:
                self.urls.remove(evol[clef])
                retour.append(evol[clef])
                del evol[clef]
            # soit il n'y en a pas, et on laisse une ligne vide
            else:
                retour.append("")

        # On ajoute à la fin toutes les entrées non associées
        for url in self.urls:
            if url != "":
                retour.append(url)

        self.urls[:] = retour

    def oter_doublons(self, p_hauteur = 0):
        """
        Deux entrées sont considérées comme doublons si elles ont la
        même clef. La clef est constituée du nom du fichier préfixé d'un
        certain nombre de répertoires, nombre paramétré par l'argument
        'hauteur'
        """
        retour = []
        clefs = []
        for url in self.urls:
            clef = _extraire_clef(url, p_hauteur)
            if clef in clefs:
                print >> sys.stderr, "Attention doublon sur", url
            else:
                retour.append(url)
                clefs.append(clef)
        self.urls[:] = retour

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

        for url in self.urls:
            if url != "":
                fichier = _extraire_clef(url, p_hauteur)
                if fichier in retour:
                    print >> sys.stderr, "Attention doublon sur", fichier
                else:
                    retour[fichier] = url

        return retour

def _prefixe_commun(p_a, p_b):
    """
    Préfixe commun aux deux chaînes a et b le plus long
    """

    if p_a == "":
        return p_b
    elif p_b == "":
        return p_a
    else:
        # Création d'une sous-liste appariant les caractères, dimensionnée
        # par l'entrée la plus courte
        paires = zip(p_a, p_b)

        # On avance dans la sous-liste tant que chaque paire a ses deux
        # éléments identiques
        for i, (a, b) in enumerate(paires):
            if a != b:
                return p_a[:i]

        # Sinon, on a épuisé l'entrée la plus courte : c'est le plus long
        # préfixe commun
        return p_a[:len(paires) + 1]

def _extraire_clef(p_chemin_et_fichier, p_hauteur):
    """
    Fournit un suffixe de 'chemin_et_fichier' afin de servir de clef. La clef
    contient exactement 'hauteur' séparateurs de répertoires
    """
    parties = p_chemin_et_fichier.rsplit("/", p_hauteur+1)
    return "/".join(parties[1:])
