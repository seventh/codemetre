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
		do
			-- configuration de l'analyseur

			analyseur.appliquer( option )

			if analyseur.est_utilise_fabrique then
				analyseur.debrayer_fabrique
			end

			-- chargement du fichier

			source := analyseur.lire( nom_fichier )

			-- production des métriques

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
					std_output.put_string( once " comment " )
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

feature {}

	option : LUAT_OPTION is
			-- options de l'analyse
		do
			result := configuration.option_unitaire
		ensure
			contrat : result.choix_est_effectue
		end

end
