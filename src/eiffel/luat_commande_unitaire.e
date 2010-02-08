indexing

	auteur : "seventh"
	license : "GPL 3.0"

class

	LUAT_COMMANDE_UNITAIRE

		--
		-- Cette commande affiche les métriques unitaires demandées pour
		-- un source donné
		--

inherit

	LUAT_COMMANDE

creation

	fabriquer

feature {}

	fabriquer( p_analyseur : LUAT_ANALYSEUR
				  p_nom_fichier : STRING ) is
			-- constructeur
		require
			analyseur_valide : p_analyseur /= void
			nom_valide : p_nom_fichier /= void
		do
			analyseur := p_analyseur
			nom_fichier := p_nom_fichier
		ensure
			analyseur_ok : analyseur = p_analyseur
			nom_ok : p_nom_fichier = p_nom_fichier
		end

feature

	executer is
		local
			source : LUAT_LISTAGE
			metrique : LUAT_METRIQUE_UNITAIRE
			nom_sortie : STRING
			sortie : TEXT_FILE_WRITE
		do
			-- configuration de l'analyseur

			analyseur.appliquer( filtre )

			if analyseur.est_utilise_fabrique then
				analyseur.debrayer_fabrique
			end

			-- chargement du fichier

			source := analyseur.lire( nom_fichier )

			-- production des métriques

			if source /= void then
				-- mesure

				create metrique.fabriquer
				metrique.mesurer( source )

				bilan.accumuler( analyseur.langage, metrique )

				-- sortie

				std_output.put_string( nom_fichier )
				std_output.put_string( once " (" )
				std_output.put_string( analyseur.langage )
				std_output.put_string( once ") " )

				metrique.afficher( std_output )

				std_output.put_new_line
				std_output.flush

				-- production du fichier d'analyse

				if configuration.unitaire.analyse then
					nom_sortie := nom_fichier.twin
					nom_sortie.append( once ".cma" )
					create sortie.connect_to( nom_sortie )
					if sortie.is_connected then
						source.afficher( sortie )
						sortie.disconnect
					else
						std_error.put_string( traduire( once "*** Error: file %"" ) )
						std_error.put_string( nom_sortie )
						std_error.put_string( traduire( once "%" cannot be written" ) )
						std_error.put_new_line
					end
				end
			end
		end

feature {}

	filtre : LUAT_FILTRE is
			-- filtres de l'analyse
		do
			result := configuration.unitaire.filtre
		ensure
			contrat : result.choix_est_effectue
		end

end
