indexing

	auteur : "seventh"
	license : "GPL 3.0"

class

	LUAT_CONFIGURATION

		--
		-- Permet de déterminer les associations entre suffixe de
		-- fichier et langage supposé
		--

inherit

	LUAT_GLOBAL

	DANG_ADAPTATEUR

insert

	SYSTEM

creation

	fabriquer

feature {}

	fabriquer is
			-- constructeur
		do
			create ordre
			create associations.fabriquer( ordre )
			configuration_par_defaut := true
		end

feature

	initialiser is
			-- initialise la configuration par défaut
		local
			suffixe : LUAT_SUFFIXE
		do
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
		end

feature

	forcer( p_langage : STRING ) is
			-- force le choix du langage
		require
			p_langage.is_equal( "ada" )
				or p_langage.is_equal( "c" )
				or p_langage.is_equal( "c++" )
				or p_langage.is_equal( "eiffel" )
		do
			inspect p_langage
			when "ada" then
				analyseur_force := analyseur_ada
			when "c" then
				analyseur_force := analyseur_c
			when "c++" then
				analyseur_force := analyseur_c_plus_plus
			when "eiffel" then
				analyseur_force := analyseur_eiffel
			end
		ensure
			mode_force
		end

	mode_force : BOOLEAN is
			-- vrai si et seulement si la sélection du langage est
			-- forcée par l'utilisateur
		do
			result := analyseur_force /= void
		end

	analyseur( p_nom_fichier : STRING ) : LUAT_ANALYSEUR is
			-- analyseur associé par la configuration (fichier de
			-- configuration ou ligne de commande) au fichier,
			-- éventuellement en fonction de son suffixe
		local
			i : INTEGER
			suffixe : LUAT_SUFFIXE
			it : ARN_ITERATEUR[ LUAT_SUFFIXE ]
		do
			if mode_force then
				result := analyseur_force
			else
				i := p_nom_fichier.last_index_of( '.' )
				if p_nom_fichier.valid_index( i ) then
					create suffixe.fabriquer( p_nom_fichier.substring( i, p_nom_fichier.upper ),
													  void )
					create it.attacher( associations )
					associations.trouver( suffixe, it )
					if it.est_hors_borne then
						std_error.put_string( traduire( once "Error: extension of file %"" ) )
						std_error.put_string( p_nom_fichier )
						std_error.put_string( traduire( once "%" is unknown" ) )
						std_error.put_new_line
						std_error.flush
					else
						result := it.dereferencer.langage
					end
					it.detacher
				end
			end
		end

feature {}

	analyseur_force : LUAT_ANALYSEUR

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

			-- section : langage

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
							std_output.put_character( ',' )
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
		end

	lire is
			-- surcharge la configuration par défaut avec celle de
			-- l'utilisateur le cas échéant
		local
			chargeur : DANG_ANALYSEUR
		do
			create chargeur.fabriquer
			chargeur.ouvrir( nom_fichier_configuration )
			if chargeur.est_ouvert then
				configuration_par_defaut := false
				chargeur.lire( current )
				chargeur.fermer
			end
		end

feature {DANG_ANALYSEUR}

	ajouter( p_section : STRING
				p_variable : STRING
				p_suffixe : STRING ) is
		local
			suffixe : LUAT_SUFFIXE
			it : ARN_ITERATEUR[ LUAT_SUFFIXE ]
		do
			inspect p_section
			when "language" then
				inspect p_variable
				when "ada" then
					create suffixe.fabriquer( p_suffixe.twin, analyseur_ada )
				when "c" then
					create suffixe.fabriquer( p_suffixe.twin, analyseur_c )
				when "c++" then
					create suffixe.fabriquer( p_suffixe.twin, analyseur_c_plus_plus )
				when "eiffel" then
					create suffixe.fabriquer( p_suffixe.twin, analyseur_eiffel )
				else
					remonter_erreur( once "language not yet supported" )
				end

				if suffixe /= void then
					create it.attacher( associations )
					associations.trouver( suffixe, it )
					if not it.est_hors_borne then
						if it.dereferencer.langage /= suffixe.langage then
							remonter_erreur( once "suffix is already associated with another language" )
						else
							remonter_erreur( once "redundant association" )
						end
					else
						associations.ajouter( suffixe )
					end
					it.detacher
				end
			else
				-- section inconnue
				remonter_erreur( once "unknown section" )
			end
		end

	effacer( p_section : STRING
				p_variable : STRING ) is
		local
			it : ARN_ITERATEUR[ LUAT_SUFFIXE ]
			a : LUAT_ANALYSEUR
		do
			inspect p_section
			when "language" then
				inspect p_variable
				when "ada" then
					a := analyseur_ada
				when "c" then
					a := analyseur_c
				when "c++" then
					a := analyseur_c_plus_plus
				when "eiffel" then
					a := analyseur_eiffel
				else
					remonter_erreur( once "language not yet supported" )
				end

				if a /= void then
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
				end
			else
				-- section inconnue
				remonter_erreur( once "unknown section" )
			end
		end

	remonter_erreur( p_message : STRING ) is
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

	associations : ARN_ARBRE[ LUAT_SUFFIXE ]

	ordre : LUAT_ORDRE_SUFFIXE

	configuration_par_defaut : BOOLEAN

	nom_fichier_configuration : STRING is
		once
			result := get_environment_variable( once "HOME" )
			if result = void then
				create result.make_empty
			end
			result.append_string( once "/.codemetrerc" )
		ensure
			definition : result /= void
		end

feature {}

	analyseur_ada : LUAT_ANALYSEUR_ADA is
		once
			create result.fabriquer
			analyseurs.add_last( result )
		end

	analyseur_c : LUAT_ANALYSEUR_FAMILLE_C is
		once
			create result.fabriquer( once "C" )
			analyseurs.add_last( result )
		end

	analyseur_c_plus_plus : LUAT_ANALYSEUR_FAMILLE_C is
		once
			create result.fabriquer( once "C++" )
			analyseurs.add_last( result )
		end

	analyseur_eiffel : LUAT_ANALYSEUR_EIFFEL is
		once
			create result.fabriquer
			analyseurs.add_last( result )
		end

	analyseurs : FAST_ARRAY[ LUAT_ANALYSEUR ] is
		once
			create result.with_capacity( 4 )
		end

end
