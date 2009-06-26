indexing

	auteur : "seventh"
	license : "GPL 3.0"

class

	LUAT_CONFIGURATION

		--
		-- Regroupe l'ensemble des choix par défaut :
		-- * soit ceux fait par l'utilisateur à travers son fichier
		-- de configuration personnel ;
		-- * soit ceux de l'application.
		--
		-- Ces choix incluent :
		-- * les associations entre extension de fichier et langage ;
		-- * le modèle de comparaison ;
		-- * la production d'un bilan en fin d'analyse ;
		-- * la sortie allégée lors des comparaisons ;
		-- * les filtres à appliquer / les sorties à produire.
		--

inherit

	LUAT_GLOBAL

	DANG_ADAPTATEUR

creation

	fabriquer

feature {}

	fabriquer is
			-- constructeur
		do
			create associations.fabriquer( create {LUAT_ORDRE_SUFFIXE} )
			create filtre_analyse.initialiser
			create filtre_differentiel.initialiser
			create filtre_unitaire.initialiser
		end

feature

	appliquer_choix_initial is
			-- appliquer la configuration initiale, celle par défaut
		local
			suffixe : LUAT_SUFFIXE
		do
			configuration_par_defaut := true

			--
			-- section : 'anal'
			--

			filtre_analyse.met_code( false )
			filtre_analyse.met_commentaire( false )
			filtre_analyse.met_total( true )

			--
			-- section : 'diff'
			--

			bilan_final_differentiel := false
			metrique := metrique_normal
			filtre_differentiel.met_code( true )
			filtre_differentiel.met_commentaire( false )
			filtre_differentiel.met_total( false )
			sortie_compacte := false

			--
			-- section : 'language'
			--

			-- Ada

			create suffixe.fabriquer( once ".adb", analyseur_ada )
			associations.ajouter( suffixe )
			create suffixe.fabriquer( once ".ads", analyseur_ada )
			associations.ajouter( suffixe )

			-- C

			create suffixe.fabriquer( once ".c", analyseur_c )
			associations.ajouter( suffixe )
			create suffixe.fabriquer( once ".h", analyseur_c )
			associations.ajouter( suffixe )

			-- C++

			create suffixe.fabriquer( once ".C", analyseur_c_plus_plus )
			associations.ajouter( suffixe )
			create suffixe.fabriquer( once ".cc", analyseur_c_plus_plus )
			associations.ajouter( suffixe )
			create suffixe.fabriquer( once ".cpp", analyseur_c_plus_plus )
			associations.ajouter( suffixe )
			create suffixe.fabriquer( once ".hh", analyseur_c_plus_plus )
			associations.ajouter( suffixe )
			create suffixe.fabriquer( once ".hpp", analyseur_c_plus_plus )
			associations.ajouter( suffixe )

			-- Eiffel

			create suffixe.fabriquer( once ".e", analyseur_eiffel )
			associations.ajouter( suffixe )

			--
			-- section : 'unit'
			--

			bilan_final_unitaire := false
			filtre_unitaire.met_code( true )
			filtre_unitaire.met_commentaire( true )
			filtre_unitaire.met_total( false )
		end

	appliquer_choix_fichier is
			-- surcharge la configuration actuelle avec les éléments
			-- précisés dans le fichier de configuration de l'utilisateur
		local
			chargeur : DANG_ANALYSEUR
		do
			-- lecture

			create chargeur.fabriquer
			chargeur.ouvrir( nom_fichier_configuration )
			if chargeur.est_ouvert then
				configuration_par_defaut := false
				chargeur.lire( current )
				chargeur.fermer
			end
		end

	appliquer_choix_demande is
			-- surcharge la configuration actuelle avec les éléments
			-- précisés en ligne de commande
		do
			-- ici on devrait retrouver l'équivalent de :
			--
			--  {LUAT_LIGNE_COMMANDE_ANALYSEUR}.analyser
			--
			-- mais la question sera alors d'initaliser l'instance
			-- globale de LUAT_CONFIGURATION
		end

feature

	analyseur( p_nom_fichier : STRING ) : LUAT_ANALYSEUR is
			-- analyseur associé par la configuration (fichier de
			-- configuration ou ligne de commande) au fichier,
			-- éventuellement en fonction de son suffixe
		local
			i : INTEGER
			suffixe : LUAT_SUFFIXE
			it : ARN_ITERATEUR[ LUAT_SUFFIXE ]
		do
			if analyseur_force /= void then
				result := analyseur_force
			else
				i := p_nom_fichier.last_index_of( '.' )
				if not p_nom_fichier.valid_index( i ) then
						std_error.put_string( traduire( once "Error: extension of file %"" ) )
						std_error.put_string( p_nom_fichier )
						std_error.put_string( traduire( once "%" is unknown" ) )
						std_error.put_new_line
						std_error.flush
				else
					create suffixe.fabriquer( p_nom_fichier.substring( i, p_nom_fichier.upper ),
													  void )
					create it.attacher( associations )
					associations.trouver( suffixe, it )
					if not it.est_hors_borne then
						result := it.dereferencer.langage
					else
						std_error.put_string( traduire( once "Error: extension of file %"" ) )
						std_error.put_string( p_nom_fichier )
						std_error.put_string( traduire( once "%" is unknown" ) )
						std_error.put_new_line
						std_error.flush
					end
					it.detacher
				end
			end
		end

	bilan_final_differentiel : BOOLEAN
			-- vrai si et seulement si un résumé doit être produit en
			-- fin de comptage différentiel

	bilan_final_unitaire : BOOLEAN
			-- vrai si et seulement si un résumé doit être produit en
			-- fin de comptage unitaire

	metrique : LUAT_METRIQUE_DIFFERENTIEL
			-- modèle de comparaison à utiliser

	filtre_analyse : LUAT_FILTRE
			-- ensemble des filtres à utiliser sur les fichiers en
			-- entrée par une commande d'analyse

	filtre_differentiel : LUAT_FILTRE
			-- ensemble des filtres à utiliser sur les fichiers en
			-- entrée par une commande de comptage différentiel

	filtre_unitaire : LUAT_FILTRE
			-- ensemble des filtres à utiliser sur les fichiers en
			-- entrée par une commande de comptage unitaire

	sortie_compacte : BOOLEAN
			-- vrai si et seulement le résultat des comparaisons doit
			-- être filtré

feature

	afficher is
			-- produit, sur la sortie standard, un fichier de
			-- configuration équivalent à la configuration actuelle
		local
			l : INTEGER
			it : ARN_ITERATEUR[ LUAT_SUFFIXE ]
			aucune_entree : BOOLEAN
			langage : STRING
		do
			-- en-tête

			std_output.put_string( once "# " )
			std_output.put_string( version_majeure )
			std_output.put_string( version_mineure )
			if not configuration_par_defaut then
				std_output.put_string( once " & " )
				std_output.put_string( nom_fichier_configuration )
			end
			std_output.put_new_line

			--
			-- section 'analysis'
			--

			std_output.put_string( once "[analysis]%N" )
			afficher_filtre( filtre_analyse, std_output )

			--
			-- section : 'diff'
			--

			std_output.put_string( once "[diff]%N" )
			afficher_filtre( filtre_differentiel, std_output )

			std_output.put_string( once "%Tmodel := " )
			std_output.put_string( metrique.nom )
			std_output.put_new_line

			std_output.put_string( once "%Tshort := " )
			std_output.put_boolean( sortie_compacte )
			std_output.put_new_line

			std_output.put_string( once "%Tstatus := " )
			std_output.put_boolean( bilan_final_differentiel )
			std_output.put_new_line

			--
			-- section : 'language'
			--

			std_output.put_string( once "[language]%N" )

			create it.attacher( associations )
			from l := analyseurs.lower
			variant analyseurs.upper - l
			until l > analyseurs.upper
			loop
				std_output.put_character( '%T' )
				langage := analyseurs.item( l ).langage
				langage.to_lower
				std_output.put_string( langage )
				std_output.put_string( once " := " )
				aucune_entree := true
				from it.pointer_premier
				until it.est_hors_borne
				loop
					if it.dereferencer.langage = analyseurs.item( l ) then
						if not aucune_entree then
							std_output.put_string( once ", " )
						end
						std_output.put_string( it.dereferencer.suffixe )
						aucune_entree := false
					end
					it.avancer
				end
				std_output.put_new_line
				l := l + 1
			end
			it.detacher

			--
			-- section 'unit'
			--

			std_output.put_string( once "[unit]%N" )
			afficher_filtre( filtre_unitaire, std_output )

			std_output.put_string( once "%Tstatus := " )
			std_output.put_boolean( bilan_final_unitaire )
			std_output.put_new_line
		end

feature

	forcer_analyseur( p_langage : STRING ) : BOOLEAN is
			-- force le choix du langage (s'il existe)
		require
			langage_valide : not p_langage.is_empty
		local
			a : LUAT_ANALYSEUR
		do
			a := trouver_analyseur( p_langage )

			if a /= void then
				analyseur_force := a
				result := true
			end
		end

	forcer_bilan_final_differentiel( p_bilan_final : BOOLEAN ) is
			-- met à jour la variable 'bilan_final_differentiel'
		do
			bilan_final_differentiel := p_bilan_final
		ensure
			bilan_final_ok : bilan_final_differentiel = p_bilan_final
		end

	forcer_bilan_final_unitaire( p_bilan_final : BOOLEAN ) is
			-- met à jour la variable 'bilan_final_unitaire'
		do
			bilan_final_unitaire := p_bilan_final
		ensure
			bilan_final_ok : bilan_final_unitaire = p_bilan_final
		end

	forcer_metrique( p_metrique : STRING ) : BOOLEAN is
			-- choisit une métrique par son nom
		require
			metrique_valide : not p_metrique.is_empty
		local
			m : LUAT_METRIQUE_DIFFERENTIEL
		do
			m := trouver_metrique( p_metrique )

			if m /= void then
				metrique := m
				result := true
			end
		end

	forcer_sortie_compacte( p_sortie_compacte : BOOLEAN ) is
		do
			sortie_compacte := p_sortie_compacte
		ensure
			sortie_compacte_ok : sortie_compacte = p_sortie_compacte
		end

feature {LUAT_CONFIGURATION}

	analyseur_force : LUAT_ANALYSEUR
			-- analyseur à utiliser indépendamment du suffixe du fichier

	associations : ARN_ARBRE[ LUAT_SUFFIXE ]

feature {DANG_ANALYSEUR}

	ajouter( p_section : STRING
				p_variable : STRING
				p_valeur : STRING ) is
		local
			suffixe : LUAT_SUFFIXE
			it : ARN_ITERATEUR[ LUAT_SUFFIXE ]
			a : LUAT_ANALYSEUR
		do
			inspect p_section

			when "analysis" then
				inspect p_variable
				when "filter" then
					traiter_erreur( once "analysis:filter can only have a single value" )
				else
					traiter_erreur( once "unknown parameter in analysis section" )
				end

			when "diff" then
				inspect p_variable
				when "filter" then
					traiter_erreur( once "diff:filter can only have a single value" )
				when "model" then
					traiter_erreur( once "diff:model is not a list" )
				when "short" then
					traiter_erreur( once "diff:short is not a list" )
				when "status" then
					traiter_erreur( once "diff:status is not a list" )
				else
					traiter_erreur( once "unknown parameter in diff section" )
				end

			when "language" then
				a := trouver_analyseur( p_variable )

				if a = void then
					traiter_erreur( once "language not yet supported" )
				else
					create suffixe.fabriquer( p_valeur.twin, a )
					create it.attacher( associations )
					associations.trouver( suffixe, it )
					if not it.est_hors_borne then
						if it.dereferencer.langage /= suffixe.langage then
							traiter_erreur( once "suffix is already associated with another language" )
						else
							traiter_erreur( once "redundant association" )
						end
					else
						associations.ajouter( suffixe )
					end
					it.detacher
				end

			when "unit" then
				inspect p_variable
				when "filter" then
					ajouter_filtre( filtre_unitaire, p_valeur )
				when "status" then
					traiter_erreur( once "unit:status is not a list" )
				else
					traiter_erreur( once "unknown parameter in unit section" )
				end

			else
				-- section inconnue
				traiter_erreur( once "unknown section" )
			end
		end

	imposer( p_section : STRING
				p_variable : STRING
				p_valeur : STRING ) is
		local
			it : ARN_ITERATEUR[ LUAT_SUFFIXE ]
			a : LUAT_ANALYSEUR
			m : LUAT_METRIQUE_DIFFERENTIEL
		do
			inspect p_section

			when "analysis" then
				inspect p_variable
				when "filter" then
					imposer_filtre( filtre_analyse, p_valeur )
				else
					traiter_erreur( once "unknown parameter in analysis section" )
				end

			when "diff" then
				inspect p_variable
				when "filter" then
					imposer_filtre( filtre_differentiel, p_valeur )
				when "model" then
					m := trouver_metrique( p_valeur )
					if m = void then
						traiter_erreur( once "unknown diff model" )
					else
						metrique := m
					end
				when "short" then
					if p_valeur.is_boolean then
						sortie_compacte := p_valeur.to_boolean
					else
						traiter_erreur( once "invalid boolean value" )
					end
				when "status" then
					if p_valeur.is_boolean then
						bilan_final_differentiel := p_valeur.to_boolean
					else
						traiter_erreur( once "invalid boolean value" )
					end
				else
					traiter_erreur( once "unknown parameter in diff section" )
				end

			when "language" then
				a := trouver_analyseur( p_variable )

				if a = void then
					traiter_erreur( once "language not yet supported" )
				else
					create it.attacher( associations )
					from it.pointer_premier
					until it.est_hors_borne
					loop
						if it.dereferencer.langage = a then
							associations.retirer( it )
							it.pointer_premier
						else
							it.avancer
						end
					end
					it.detacher

					ajouter( p_section, p_variable, p_valeur )
				end

			when "unit" then
				inspect p_variable
				when "filter" then
					imposer_filtre( filtre_unitaire, p_valeur )
				when "status" then
					if p_valeur.is_boolean then
						bilan_final_unitaire := p_valeur.to_boolean
					else
						traiter_erreur( once "invalid boolean value" )
					end
				else
					traiter_erreur( once "unknown parameter in unit section" )
				end

			else
				-- section inconnue
				traiter_erreur( once "unknown section" )
			end
		end

	retirer( p_section : STRING
				p_variable : STRING
				p_valeur : STRING ) is
		local
			suffixe : LUAT_SUFFIXE
			it : ARN_ITERATEUR[ LUAT_SUFFIXE ]
			a : LUAT_ANALYSEUR
		do
			inspect p_section

			when "analysis" then
				inspect p_variable
				when "filter" then
					traiter_erreur( once "analysis:filter can only have a single value" )
				else
					traiter_erreur( once "unknown parameter in analysis section" )
				end

			when "diff" then
				inspect p_variable
				when "filter" then
					traiter_erreur( once "diff:filter can only have a single value" )
				when "model" then
					traiter_erreur( once "diff:model is not a list" )
				when "short" then
					traiter_erreur( once "diff:short is not a list" )
				when "status" then
					traiter_erreur( once "diff:status is not a list" )
				else
					traiter_erreur( once "unknown parameter in diff section" )
				end

			when "language" then
				a := trouver_analyseur( p_variable )

				if a = void then
					traiter_erreur( once "language not yet supported" )
				else
					create suffixe.fabriquer( p_valeur.twin, a )
					create it.attacher( associations )
					associations.trouver( suffixe, it )
					if it.est_hors_borne then
						traiter_erreur( once "no such association exists" )
					else
						associations.retirer( it )
					end
					it.detacher
				end

			when "unit" then
				inspect p_variable
				when "filter" then
					retirer_filtre( filtre_unitaire, p_valeur )
				when "status" then
					traiter_erreur( once "unit:status is not a list" )
				else
					traiter_erreur( once "unknown parameter in unit section" )
				end

			else
				-- section inconnue
				traiter_erreur( once "unknown section" )
			end
		end

	traiter_erreur( p_message : STRING ) is
		do
			std_error.put_string( traduire( once "Syntax error" ) )
			std_error.put_string( once " (" )
			std_error.put_string( nom_fichier_configuration )
			std_error.put_string( once "): " )
			std_error.put_string( traduire( p_message ) )
			std_error.put_new_line
			std_error.put_new_line
		end

feature {LUAT_CONFIGURATION}

	configuration_par_defaut : BOOLEAN

	nom_fichier_configuration : STRING is
			-- chemin absolu d'accès au fichier de configuration :
			-- - sous UNIX : équivalent à $HOME/.codemetrerc
			-- - sous WINDOWS : équivalent à %APPDATA%\codemetre.ini
		local
			sys : SYSTEM
		once
			-- l'implémentation a un biais : on détermine
			-- l'environnement par rapport à la définition ou non de la
			-- variable utilisée spécifiquement dans celui-ci

			-- environnement UNIX

			if result = void then
				result := sys.get_environment_variable( once "HOME" )
				if result /= void then
					result.append_string( once "/.codemetrerc" )
				end
			end

			-- environnement WINDOWS

			if result = void then
				result := sys.get_environment_variable( once "APPDATA" )
				if result /= void then
					result.append_string( once "\codemetre.ini" )
				end
			end
		ensure
			definition : result /= void
		end

feature {}

	analyseur_ada : LUAT_ANALYSEUR is
		once
			result := analyseurs.item( 0 )
		end

	analyseur_c : LUAT_ANALYSEUR is
		once
			result := analyseurs.item( 1 )
		end

	analyseur_c_plus_plus : LUAT_ANALYSEUR is
		once
			result := analyseurs.item( 2 )
		end

	analyseur_eiffel : LUAT_ANALYSEUR is
		once
			result := analyseurs.item( 3 )
		end

	analyseurs : FAST_ARRAY[ LUAT_ANALYSEUR ] is
			-- ensemble des analyseurs lexicaux
		once
			create result.with_capacity( 4 )
			result.add_last( create {LUAT_ANALYSEUR_ADA}.fabriquer )
			result.add_last( create {LUAT_ANALYSEUR_FAMILLE_C}.fabriquer( once "c" ) )
			result.add_last( create {LUAT_ANALYSEUR_FAMILLE_C}.fabriquer( once "c++" ) )
			result.add_last( create {LUAT_ANALYSEUR_EIFFEL}.fabriquer )
		end

	trouver_analyseur( p_clef : STRING ) : LUAT_ANALYSEUR is
		require
			clef_valide : not p_clef.is_empty
		local
			i : INTEGER
		do
			i := trouver_element_configurable( analyseurs, p_clef )

			if analyseurs.valid_index( i ) then
				result := analyseurs.item( i )
			end
		end

feature {}

	metrique_effort : LUAT_METRIQUE_DIFFERENTIEL is
		once
			result := metriques.item( 0 )
		end

	metrique_normal : LUAT_METRIQUE_DIFFERENTIEL is
		once
			result := metriques.item( 1 )
		end

	metriques : FAST_ARRAY[ LUAT_METRIQUE_DIFFERENTIEL ] is
		once
			create result.with_capacity( 2 )
			result.add_last( create {LUAT_METRIQUE_EFFORT}.fabriquer )
			result.add_last( create {LUAT_METRIQUE_NORMAL}.fabriquer )
		end

	trouver_metrique( p_clef : STRING ) : LUAT_METRIQUE_DIFFERENTIEL is
		require
			clef_valide : not p_clef.is_empty
		local
			i : INTEGER
		do
			i := trouver_element_configurable( metriques, p_clef )

			if metriques.valid_index( i ) then
				result := metriques.item( i )
			end
		end

feature {}

	afficher_filtre( p_filtre : LUAT_FILTRE
						  p_flux : OUTPUT_STREAM ) is
		require
			filtre_valide : p_filtre.choix_est_effectue
			flux_valide : p_flux /= void
		local
			separateur_doit_etre_ajoute : BOOLEAN
		do
			p_flux.put_string( once "%Tfilter := " )

			if p_filtre.code then
				separateur_doit_etre_ajoute := true
				p_flux.put_string( once "code" )
			end
			if p_filtre.commentaire then
				if separateur_doit_etre_ajoute then
					p_flux.put_string( once ", " )
				end
				separateur_doit_etre_ajoute := true
				p_flux.put_string( once "comment" )
			end
			if p_filtre.total then
				if separateur_doit_etre_ajoute then
					p_flux.put_string( once ", " )
				end
				separateur_doit_etre_ajoute := true
				p_flux.put_string( once "total" )
			end

			p_flux.put_new_line
		end

	ajouter_filtre( p_filtre : LUAT_FILTRE
						 p_variable : STRING ) is
		require
			filtre_valide : p_filtre /= void
			variable_valide : not p_variable.is_empty
		do
			inspect p_variable
			when "code" then
				p_filtre.met_code( true )
			when "comment" then
				p_filtre.met_commentaire( true )
			when "total" then
				p_filtre.met_total( true )
			else
				traiter_erreur( once "unknown filter" )
			end
		end

	imposer_filtre( p_filtre : LUAT_FILTRE
						 p_variable : STRING ) is
		require
			filtre_valide : p_filtre /= void
			variable_valide : not p_variable.is_empty
		do
			inspect p_variable
			when "code" then
				p_filtre.met( true, false, false )
			when "comment" then
				p_filtre.met( false, true, false )
			when "total" then
				p_filtre.met( false, false, true )
			else
				traiter_erreur( once "unknown filter" )
			end
		end

	retirer_filtre( p_filtre : LUAT_FILTRE
						 p_variable : STRING ) is
		require
			filtre_valide : p_filtre.choix_est_effectue
			variable_valide : not p_variable.is_empty
		local
			old_filtre : like p_filtre
		do
			old_filtre := p_filtre.twin

			inspect p_variable
			when "code" then
				p_filtre.met_code( false )
			when "comment" then
				p_filtre.met_commentaire( false )
			when "total" then
				p_filtre.met_total( false )
			else
				traiter_erreur( once "unknown filter" )
			end

			if not p_filtre.choix_est_effectue then
				p_filtre.copy( old_filtre )
				traiter_erreur( once "removing filters leaves empty set" )
			end
		ensure
			filtre_ok : p_filtre.choix_est_effectue
		end

feature {}

	trouver_element_configurable( p_ensemble : COLLECTION[ LUAT_ELEMENT_CONFIGURABLE ]
											p_clef : STRING ) : INTEGER is
		require
			ensemble_valide : p_ensemble /= void
			clef_valide : not p_clef.is_empty
		do
			from result := p_ensemble.lower
			variant p_ensemble.upper - result
			until result > p_ensemble.upper
				or else p_ensemble.item( result ).clef.is_equal( p_clef )
			loop
				result := result + 1
			end
		ensure
			p_ensemble.valid_index( result ) implies p_ensemble.item( result ).clef.is_equal( p_clef )
		end

end
