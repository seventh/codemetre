indexing

	auteur : "seventh"
	license : "GPL 3.0"

class

	LUAT_COMMANDE_ANALYSE

		--
		-- Cette commande crée un fichier suffixé .codemetre
		-- contenant le fichier d'origine dont les unités lexicales
		-- sont qualifiées et séparées
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
			nom_ok : nom_fichier = p_nom_fichier
		end

feature

	executer is
		local
			source : LUAT_LISTAGE
			nom_sortie : STRING
			sortie : TEXT_FILE_WRITE
		do
			-- configuration de l'analyseur

			analyseur.appliquer( option )

			if analyseur.est_utilise_fabrique then
				analyseur.debrayer_fabrique
			end

			-- chargement du fichier

			source := analyseur.lire( nom_fichier )

			-- production du fichier d'analyse

			if source /= void then
				nom_sortie := nom_fichier.twin
				nom_sortie.append( once ".codemetre" )
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

feature {}

	option : LUAT_OPTION is
			-- options de l'analyse
		do
			result := configuration.option_analyse
		ensure
			contrat : result.choix_est_unique
		end

end
