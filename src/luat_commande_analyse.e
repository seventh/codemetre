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
				  p_nom_fichier : STRING
				  p_option : LUAT_OPTION ) is
			-- constructeur
		require
			analyseur_valide : p_analyseur /= void
			nom_valide : p_nom_fichier /= void
			option_valide : p_option.choix_est_unique
		do
			analyseur := p_analyseur
			nom_fichier := p_nom_fichier
			option := p_option
		ensure
			analyseur_ok : analyseur = p_analyseur
			nom_ok : nom_fichier = p_nom_fichier
			option_ok : option = p_option
		end

feature

	executer is
		local
			source : LUAT_LISTAGE
			nom_sortie : STRING
			sortie : TEXT_FILE_WRITE
		do
			-- Configuration de l'analyseur

			appliquer_option

			if analyseur.est_utilise_fabrique then
				analyseur.debrayer_fabrique
			end

			-- Chargement du fichier

			source := analyseur.lire( nom_fichier )

			-- Production du fichier d'analyse

			if source /= void then
				nom_sortie := nom_fichier.twin
				nom_sortie.append( once ".codemetre" )
				create sortie.connect_to( nom_sortie )
				if not sortie.is_connected then
					std_error.put_string( once "*** Erreur : impossible de créer le fichier d'analyse " )
					std_error.put_string( nom_sortie )
					std_error.put_string( once " !%N" )
				else
					source.afficher( sortie )
					sortie.disconnect
				end
			end
		end

end
