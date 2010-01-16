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
			create analyse.fabriquer
			create differentiel.fabriquer
			create unitaire.fabriquer
		end

feature

	appliquer_choix_initial is
			-- appliquer la configuration initiale, celle par défaut
		local
			suffixe : LUAT_SUFFIXE
		do
			configuration_par_defaut := true

			--
			-- section : 'analysis'
			--

			analyse.initialiser

			--
			-- section : 'diff'
			--

			differentiel.initialiser

			--
			-- section : 'language'
			--

			-- Ada

			create suffixe.fabriquer( once ".adb", analyseur_ada.langage )
			associations.ajouter( suffixe )
			create suffixe.fabriquer( once ".ads", analyseur_ada.langage )
			associations.ajouter( suffixe )

			-- C

			create suffixe.fabriquer( once ".c", analyseur_c.langage )
			associations.ajouter( suffixe )
			create suffixe.fabriquer( once ".h", analyseur_c.langage )
			associations.ajouter( suffixe )

			-- C++

			create suffixe.fabriquer( once ".C", analyseur_c_plus_plus.langage )
			associations.ajouter( suffixe )
			create suffixe.fabriquer( once ".cc", analyseur_c_plus_plus.langage )
			associations.ajouter( suffixe )
			create suffixe.fabriquer( once ".cpp", analyseur_c_plus_plus.langage )
			associations.ajouter( suffixe )
			create suffixe.fabriquer( once ".hh", analyseur_c_plus_plus.langage )
			associations.ajouter( suffixe )
			create suffixe.fabriquer( once ".hpp", analyseur_c_plus_plus.langage )
			associations.ajouter( suffixe )

			-- Eiffel

			create suffixe.fabriquer( once ".e", analyseur_eiffel.langage )
			associations.ajouter( suffixe )

			-- SQL

			create suffixe.fabriquer( once ".sql", analyseur_sql.langage )
			associations.ajouter( suffixe )

			-- Lot codemètre

			create suffixe.fabriquer( once ".cmb", analyseur_lot )
			associations.ajouter( suffixe )

			--
			-- section : 'unit'
			--

			unitaire.initialiser
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
						result := trouver_analyseur( it.dereferencer.langage )
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

	est_lot( p_nom_fichier : STRING ) : BOOLEAN is
			-- vrai si et seulement si l'extension du nom passé en
			-- argument est celle d'un lot codemetre
		require
			nom_valide : not p_nom_fichier.is_empty
		local
			i : INTEGER
			suffixe : LUAT_SUFFIXE
			it : ARN_ITERATEUR[ LUAT_SUFFIXE ]
		do
			-- vu l'utilisation qui est faite de cette méthode, on ne
			-- remonte aucun message sur la sortie d'erreur. Ceci sera
			-- logiquement fait par la méthode 'analyseur'.

			i := p_nom_fichier.last_index_of( '.' )
			if p_nom_fichier.valid_index( i ) then
				create suffixe.fabriquer( p_nom_fichier.substring( i, p_nom_fichier.upper ),
												  void )
				create it.attacher( associations )
				associations.trouver( suffixe, it )
				if not it.est_hors_borne then
					result := trouver_langage( it.dereferencer.langage ) = analyseur_lot
				end
				it.detacher
			end
		end

feature

	analyse : LUAT_OPTION_ANALYSE
			-- ensemble des options associées aux commandes d'analyse

	differentiel : LUAT_OPTION_DIFFERENTIEL
			-- ensemble des options associées aux commandes de comptage
			-- différentiel

	unitaire : LUAT_OPTION_UNITAIRE
			-- ensemble des options associées aux commandes de comptage
			-- unitaire

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
			afficher_filtre( analyse.filtre, std_output )

			--
			-- section : 'diff'
			--

			std_output.put_string( once "[diff]%N" )
			afficher_filtre( differentiel.filtre, std_output )

			std_output.put_string( once "%Tmodel := " )
			std_output.put_string( differentiel.modele.nom )
			std_output.put_new_line

			std_output.put_string( once "%Tshort := " )
			std_output.put_boolean( differentiel.abrege )
			std_output.put_new_line

			std_output.put_string( once "%Tstatus := " )
			std_output.put_boolean( differentiel.statut )
			std_output.put_new_line

			--
			-- section : 'language'
			--

			std_output.put_string( once "[language]%N" )

			create it.attacher( associations )
			from l := langages.lower
			variant langages.upper - l
			until l > langages.upper
			loop
				std_output.put_character( '%T' )
				langage := langages.item( l )
				langage.to_lower
				std_output.put_string( langage )
				std_output.put_string( once " := " )
				aucune_entree := true
				from it.pointer_premier
				until it.est_hors_borne
				loop
					if it.dereferencer.langage = langages.item( l ) then
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
			afficher_filtre( unitaire.filtre, std_output )

			std_output.put_string( once "%Tstatus := " )
			std_output.put_boolean( unitaire.statut )
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

	forcer_metrique( p_metrique : STRING ) : BOOLEAN is
			-- choisit une métrique par son nom
		require
			metrique_valide : not p_metrique.is_empty
		local
			modele : LUAT_METRIQUE_DIFFERENTIEL
		do
			modele := trouver_metrique( p_metrique )

			if modele /= void then
				differentiel.met_modele( modele )
				result := true
			end
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
			l : STRING
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
				l := trouver_langage( p_variable )

				if l = void then
					traiter_erreur( once "language not yet supported" )
				else
					create suffixe.fabriquer( p_valeur.twin, l )
					create it.attacher( associations )
					associations.trouver( suffixe, it )
					if it.est_hors_borne then
						associations.ajouter( suffixe )
					elseif it.dereferencer.langage /= suffixe.langage then
						traiter_erreur( once "suffix is already associated with another language" )
					else
						traiter_erreur( once "redundant association" )
					end
					it.detacher
				end

			when "unit" then
				inspect p_variable
				when "filter" then
					ajouter_filtre( unitaire.filtre, p_valeur )
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

	effacer( p_section : STRING
				p_variable : STRING ) is
		local
			it : ARN_ITERATEUR[ LUAT_SUFFIXE ]
			l : STRING
		do
			inspect p_section

			when "analysis" then
				inspect p_variable
				when "filter" then
					traiter_erreur( once "analysis:filter is mandatory" )
				else
					traiter_erreur( once "unknown parameter in analysis section" )
				end

			when "diff" then
				inspect p_variable
				when "filter" then
					traiter_erreur( once "diff:filter is mandatory" )
				when "model" then
					traiter_erreur( once "diff:model is mandatory" )
				when "short" then
					traiter_erreur( once "diff:short is not clearable" )
				when "status" then
					traiter_erreur( once "diff:status is not clearable" )
				else
					traiter_erreur( once "unknown parameter in diff section" )
				end

			when "language" then
				l := trouver_langage( p_variable )

				if l = void then
					traiter_erreur( once "language not yet supported" )
				else
					create it.attacher( associations )
					from it.pointer_premier
					until it.est_hors_borne
					loop
						if it.dereferencer.langage = l then
							associations.retirer( it )
							it.pointer_premier
						else
							it.avancer
						end
					end
					it.detacher
				end

			when "unit" then
				inspect p_variable
				when "filter" then
					traiter_erreur( once "unit:filter is mandatory" )
				when "status" then
					traiter_erreur( once "unit:status is not clearable" )
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
			l : STRING
		do
			inspect p_section

			when "analysis" then
				inspect p_variable
				when "filter" then
					imposer_filtre( analyse.filtre, p_valeur )
				else
					traiter_erreur( once "unknown parameter in analysis section" )
				end

			when "diff" then
				inspect p_variable
				when "filter" then
					imposer_filtre( differentiel.filtre, p_valeur )
				when "model" then
					if not forcer_metrique( p_valeur ) then
						traiter_erreur( once "unknown diff model" )
					end
				when "short" then
					if p_valeur.is_boolean then
						differentiel.met_abrege( p_valeur.to_boolean )
					else
						traiter_erreur( once "invalid boolean value" )
					end
				when "status" then
					if p_valeur.is_boolean then
						differentiel.met_statut( p_valeur.to_boolean )
					else
						traiter_erreur( once "invalid boolean value" )
					end
				else
					traiter_erreur( once "unknown parameter in diff section" )
				end

			when "language" then
				l := trouver_langage( p_variable )

				if l = void then
					traiter_erreur( once "language not yet supported" )
				else
					create it.attacher( associations )
					from it.pointer_premier
					until it.est_hors_borne
					loop
						if it.dereferencer.langage = l then
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
					imposer_filtre( unitaire.filtre, p_valeur )
				when "status" then
					if p_valeur.is_boolean then
						unitaire.met_statut( p_valeur.to_boolean )
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
			l : STRING
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
				l := trouver_langage( p_variable )

				if l = void then
					traiter_erreur( once "language not yet supported" )
				else
					create suffixe.fabriquer( p_valeur.twin, l )
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
					retirer_filtre( unitaire.filtre, p_valeur )
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

	analyseur_sql : LUAT_ANALYSEUR is
		once
			result := analyseurs.item( 4 )
		end

	analyseur_lot : STRING is "batch"

	analyseurs : FAST_ARRAY[ LUAT_ANALYSEUR ] is
			-- ensemble des analyseurs lexicaux
		once
			create result.with_capacity( 5 )
			result.add_last( create {LUAT_ANALYSEUR_ADA}.fabriquer )
			result.add_last( create {LUAT_ANALYSEUR_FAMILLE_C}.fabriquer( once "c" ) )
			result.add_last( create {LUAT_ANALYSEUR_FAMILLE_C}.fabriquer( once "c++" ) )
			result.add_last( create {LUAT_ANALYSEUR_EIFFEL}.fabriquer )
			result.add_last( create {LUAT_ANALYSEUR_SQL}.fabriquer )
		end

	langages : FAST_ARRAY[ STRING ] is
			-- ensemble des langages reconnus (y compris le langage de
			-- lot de codemetre)
		local
			tri : COLLECTION_SORTER[ STRING ]
			i : INTEGER
		once
			create result.with_capacity( analyseurs.count + 1 )
			from i := analyseurs.lower
			variant analyseurs.upper - i
			until i > analyseurs.upper
			loop
				result.add_last( analyseurs.item( i ).langage )
				i := i + 1
			end
			result.add_last( analyseur_lot )

			tri.sort( result )
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

	trouver_langage( p_langage : STRING ) : STRING is
			-- permet de retrouver l'instance utilisée en interne d'une
			-- chaîne de valeur équivalente
		require
			clef_valide : not p_langage.is_empty
		local
			i : INTEGER
		do
			from i := langages.lower
			variant langages.upper - i
			until i > langages.upper
				or else langages.item( i ).is_equal( p_langage )
			loop
				i := i + 1
			end

			if langages.valid_index( i ) then
				result := langages.item( i )
			end
		ensure
			definition : result /= void implies result.is_equal( p_langage )
		end

feature {}

	extensions_lot : FAST_ARRAY[ STRING ]
			-- liste des extensions associées aux lots codemetre

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
