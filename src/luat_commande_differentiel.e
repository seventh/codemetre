indexing

	auteur : "seventh"
	license : "GPL 3.0"

class

	LUAT_COMMANDE_DIFFERENTIEL

		--
		-- Cette commande produit les métriques obtenues en comparant
		-- deux fichiers
		--

inherit

	LUAT_COMMANDE

	LUAT_GLOBAL

creation

	fabriquer

feature {}

	fabriquer( p_analyseur : LUAT_ANALYSEUR
				  p_nom_reference, p_nom_fichier : STRING
				  p_option : LUAT_OPTION ) is
		require
			analyseur_ok : p_analyseur /= void
			nom_valide : p_nom_fichier /= void or p_nom_reference /= void
			option_valide : p_option.choix_est_unique
		do
			analyseur := p_analyseur
			nom_fichier := p_nom_fichier
			nom_reference := p_nom_reference
			option := p_option
		ensure
			analyseur_ok : analyseur = p_analyseur
			nom_ok : nom_fichier = p_nom_fichier
			reference_ok : nom_reference = p_nom_reference
			option_ok : option = p_option
		end

feature

	nom_reference : STRING

feature

	executer is
		local
			metrique : LUAT_METRIQUE
			source, reference : LUAT_LISTAGE
			erreur : BOOLEAN
		do
			-- Configuration de l'analyseur

			if not analyseur.est_utilise_fabrique then
				analyseur.embrayer_fabrique
			end

			appliquer_option

			-- Chargement des fichiers

			if nom_fichier /= void then
				source := analyseur.lire( nom_fichier )
				erreur := source = void
			end

			if not erreur
				and nom_reference /= void
			 then
				reference := analyseur.lire( nom_reference )
				erreur := reference = void
			end

			-- Production des métriques différentielles

			if not erreur then
				-- mesure

				metrique := usine_metrique.mesurer( reference, source )

				-- sortie

				if source = void then
					std_output.put_string( once "ø" )
				else
					std_output.put_string( nom_fichier )
				end

				std_output.put_string( once " (" )
				std_output.put_string( analyseur.langage )
				std_output.put_string( once ") " )

				if option.total
					or ( option.code and option.commentaire )
				 then
					std_output.put_string( once "[total|" )
				elseif option.code then
					std_output.put_string( once "[code|" )
				else -- if option.commentaire then
					std_output.put_string( once "[commentaire|" )
				end

				if reference = void then
					std_output.put_string( once "ø" )
				else
					std_output.put_string( nom_reference )
				end

				std_output.put_string( once "] " )

				metrique.afficher( std_output )

				std_output.put_new_line
			end
		end

end
