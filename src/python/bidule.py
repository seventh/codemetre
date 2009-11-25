#!/usr/bin/python
# -*- coding: utf-8 -*-

prog = "bidule.py"
version = "0.3"

# nouveautés introduites en 0.3:
# - aide plus explicite
# - encodage du source en UTF-8
#
# nouveautés introduites en 0.2:
# - supporte le format windows pour les chaines de caracteres fichiers (en
# theorie, mais non teste)
# - correction du Bug de test de la ligne de commande
# - amelioration de la comparaison RAAF Vs FSTA par utilisation de deux
# dictionnaires crees a la lecture des fichiers d'entree
# - test du doublonnage des entrees RAAF et FSTA (seul un warning est affiche
# sur la console)
#
# nouveautés introduites en 0.1:
# - version initiale

import datetime
import getopt
import os
import time

from optparse import OptionParser

class refKeeperData :
	def __init__(self,p_fsta,p_raaf,p_user,p_fic1,p_fic2):
		self.nb_element_common =0
		self.BaseFSTA = p_fsta
		self.specificFSTA = []
		self.UpdatedFSTA = []
		self.RefRAAF = p_raaf
		self.sortedRAAF = []
		self.UserElt = p_user
		self.out1 = p_fic1
		self.out2 = p_fic2

	# pour chaque ligne du fichier Raaf de reference, on itere sur l'entree
	# FSTA afin de comparer les noms de fichiers (on elague donc le chemin)
	# si c'est identique, on ajoute l'entree considerée dans les deux
	# tableaux de sorties et on la supprime de la base FSTA.
	# doit y avoir plus sioux mais ca sera pour plus tard
	def writeCommonSection(self) :
		compteur = 0
		for i in self.BaseFSTA.keys() :
			if self.RefRAAF.has_key(i) :
				print "fichier %s commun raaf et fsta" % i
				compteur = compteur + 1
				self.UpdatedFSTA.append(self.BaseFSTA[i]+ os.sep +i+'\n')
				self.sortedRAAF.append(self.RefRAAF[i]+ os.sep +i+'\n')
			else :
				self.specificFSTA.append(self.BaseFSTA[i]+ os.sep +i+'\n')

		self.nb_element_common = compteur
		print "nb element commun : %s" % compteur



	# copie bestiale des lignes contenus dans le fichier specifiant le sous ensemble de RAAF correspondant au composant et specifie par l'utilisateur
	# pas de verification de doublonnage faite ici (enfin ... pas encore)
	def writeUserSpecificSection(self) :
		for i in self.UserElt :
			self.UpdatedFSTA.append('\n')
			self.sortedRAAF.append(i)

		print "nb element specifique : %s" % len(self.UserElt)

	# copie bestiale de la base FSTA restant apres suppression des elements communs RAAF
	def writeFSTAAddSection(self) :

		#for i in self.specificFSTA :
		for i in self.specificFSTA :
			self.UpdatedFSTA.append(i)
		print "nb elements ajoutes FSTA : %s" % len(self.specificFSTA)

	# ecriture des deux fichiers de sorti
	def writeOutputFiles(self) :

		prefix = str(datetime.date.today().year) + '_' + str(datetime.date.today().month) +  '_' + str(datetime.date.today().day) + '_'

		fichier1 = prefix+self.out1
		fichier2 = prefix+self.out2

		FstaOut = open(fichier1,'w')
		RaafOut = open(fichier2,'w')

		for i in self.UpdatedFSTA :
			FstaOut.write(i)

		for i in self.sortedRAAF :
			RaafOut.write(i)

		FstaOut.close()
		RaafOut.close()

		print "ecriture terminee"

	# TODO : verifier par rapport a la dernier base RAAF que des elements n'ont pas disparus hors elements specifies par l'utilsateur
	# la derniere base RAAF prise en compte se fera soit par entree utilisateur ( a rajouter) soit par regle de nommage fichier (le fichier le plus recent sera pris)
	# (element de la section commune donc ==> necessite de tagger chaque section dans le fichier de sortie)

def main():

	fsta = {}
	raaf = {}
	usage = "%s -a all_raaf -u spec_raaf -f fsta fstaUpdated newRef" % prog
	parser = OptionParser(usage)
	parser.add_option("-f", "--ftsa", action="store", type="string", dest="fstaFile")
	parser.add_option("-a", "--allRAAF", action="store", type="string", dest="raafFile")
	parser.add_option("-u", "--userFile", action="store", type="string", dest="userFile")

	# parsing des arguments et des options qui n en sont pas vraiments
	(options, args) = parser.parse_args()

	if len(args) != 2 \
		    or options.fstaFile is None \
		    or options.raafFile is None \
		    or options.userFile is None:
		parser.error("incorrect number of arguments\n")

	#ouverture, lecture ligne a ligne pour creer le dictionnaire FSTA et fermeture des fichier d'entree
	if os.path.isfile(options.fstaFile) :
		f_fsta = open(options.fstaFile,"r")

		for i in f_fsta.readlines() :

			# test des doublons FSTA
			if fsta.has_key(os.path.split(i.rstrip('\n'))[1]) :
				print "ATTENTION le fichier %s est en doublon dans la base FSTA" % os.path.split(i.rstrip('\n'))[1]

			fsta[os.path.split(i.rstrip('\n'))[1]] = os.path.split(i.rstrip('\n'))[0]

		f_fsta.close()
		print "taille fsta : %s " % len(fsta)
	else :
		print "file FSTA does not exist\n"

	#ouverture, lecture ligne a ligne pour creer le dictionnaire RAAF et fermeture des fichier d'entree
	if os.path.isfile(options.raafFile) :
		f_raaf = open(options.raafFile, "r")

		for i in f_raaf.readlines() :

			# test des doublons RAAF
			if raaf.has_key(os.path.split(i.rstrip('\n'))[1]) :
				print "ATTENTION le fichier %s est en doublon dans la base RAAF" % os.path.split(i.rstrip('\n'))[1]

			raaf[os.path.split(i.rstrip('\n'))[1]] = os.path.split(i.rstrip('\n'))[0]

		f_raaf.close()
		print "taille raaf : %s " % len(raaf)

	else :
		print "file RAAF does not exist\n"

	#ouverture, lecture ligne a ligne pour creer le tableau USER et fermeture des fichier d'entree
	if os.path.isfile(options.userFile) :
		f_user = open(options.userFile, "r");
		user = f_user.readlines()
		f_user.close()
		print "taille user : %s " % len(user)

	else :
		print "user entry file does not exist\n"

	# si tu fais pas de l'objet t'es vraiment bidon en ce bas monde.
	# donc, instanciation d'une classe qui fait papa, maman et le cafe
	# ( voir la classe elle meme)
	refKeeper = refKeeperData(fsta,raaf,user,args[0],args[1])
	refKeeper.writeCommonSection()
	refKeeper.writeUserSpecificSection()
	refKeeper.writeFSTAAddSection()
	refKeeper.writeOutputFiles()

if __name__ == "__main__":
	main()
