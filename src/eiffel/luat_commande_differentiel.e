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
		rename
			nom_fichier as nom_but
		end

creation

	fabriquer

feature {}

	fabriquer( p_analyseur : LUAT_ANALYSEUR
				  p_nom_nid, p_nom_but : STRING ) is
		require
			analyseur_ok : p_analyseur /= void
			nom_valide : p_nom_nid /= void or p_nom_but /= void
		do
			analyseur := p_analyseur
			nom_nid := p_nom_nid
			nom_but := p_nom_but
		ensure
			analyseur_ok : analyseur = p_analyseur
			nom_ok : nom_but = p_nom_but
			reference_ok : nom_nid = p_nom_nid
		end

feature

	nom_nid : STRING
			-- chemin de la version de référence du fichier

feature

	executer is
		local
			metrique : LUAT_METRIQUE
			nid, but : LUAT_LISTAGE
			erreur : BOOLEAN
		do
			-- configuration de l'analyseur

			if not analyseur.est_utilise_fabrique then
				analyseur.embrayer_fabrique
			end

			analyseur.appliquer( filtre )

			-- chargement des fichiers : si théoriquement il ne sert à
			-- rien de lire le second fichier si l'analyse du premier
			-- sort en erreur, en pratique cette analyse est également
			-- menée, pour pouvoir remonter un maximum d'information à
			-- l'utilisateur quant à la conformité de ses entrées.

			if nom_nid /= void then
				nid := analyseur.lire( nom_nid )
				erreur := nid = void
			end

			if nom_but /= void then
				but := analyseur.lire( nom_but )
				erreur := but = void
			end

			-- Production des métriques différentielles

			if not erreur then
				-- l'ordre des tests et l'utilisation de 'or else' est
				-- ici très important pour les performances de
				-- l'application
				if not configuration.sortie_compacte
					or else not sont_equivalents( nid, but )
				 then
					-- mesure

					metrique := configuration.metrique.twin
					metrique.mesurer( nid, but )

					-- sortie

					if but = void then
						std_output.put_string( once "ø" )
					else
						std_output.put_string( nom_but )
					end

					std_output.put_string( once " (" )
					std_output.put_string( analyseur.langage )
					std_output.put_string( once ") " )

					if filtre.total then
						std_output.put_string( once "[total|" )
					elseif filtre.code then
						std_output.put_string( once "[code|" )
					else -- if filtre.commentaire then
						std_output.put_string( once "[comment|" )
					end

					if nid = void then
						std_output.put_string( once "ø" )
					else
						std_output.put_string( nom_nid )
					end

					std_output.put_string( once "] " )

					metrique.afficher( std_output )

					std_output.put_new_line
				end
			end

			-- Réinitialisation de l'analyseur pour limiter la
			-- consommation de mémoire, et potentiellement améliorer la
			-- vitesse : moins de symboles implique plus de facilité à
			-- trouver les doublons

			analyseur.reinitialiser
		end

feature {}

	filtre : LUAT_FILTRE is
			-- filtres de l'analyse
		do
			result := configuration.filtre_differentiel
		ensure
			contrat : result.choix_est_unique
		end

	sont_equivalents( p_a, p_b : LUAT_LISTAGE ) : BOOLEAN is
		do
			if p_a = void then
				result := p_b = void
			elseif p_b /= void then
				result := p_a.est_equivalent( p_b )
			end
		end
end
