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
				  p_nom_fichier : STRING
				  p_option : LUAT_OPTION ) is
			-- constructeur
		require
			analyseur_valide : p_analyseur /= void
			nom_valide : p_nom_fichier /= void
			option_valide : p_option.choix_est_effectue
		do
			analyseur := p_analyseur
			nom_fichier := p_nom_fichier
			option := p_option
		ensure
			analyseur_ok : analyseur = p_analyseur
			nom_ok : p_nom_fichier = p_nom_fichier
			option_ok : option = p_option
		end

feature

	executer is
		local
			source : LUAT_LISTAGE
		do
			-- Configuration de l'analyseur

			appliquer_option

			if analyseur.est_utilise_fabrique then
				analyseur.debrayer_fabrique
			end

			-- Chargement du fichier

			source := analyseur.lire( nom_fichier )

			-- Production des métriques

			if source /= void then
				std_output.put_string( nom_fichier )
				std_output.put_string( once " (" )
				std_output.put_string( analyseur.langage )
				std_output.put_string( once ")" )

				if option.code then
					std_output.put_string( once " code " )
					std_output.put_integer( source.nb_ligne_code )
				end
				if option.commentaire then
					std_output.put_string( once " commentaire " )
					std_output.put_integer( source.nb_ligne_commentaire )
				end
				if option.total then
					std_output.put_string( once " total " )
					std_output.put_integer( source.nb_ligne )
				end
				std_output.put_new_line
				std_output.flush
			end
		end

end
