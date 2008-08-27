indexing

	auteur : "seventh"
	license : "GPL 3.0"

class

	LUAT_LIGNE_COMMANDE_ANALYSEUR

		--
		-- Analyse les arguments de la ligne de commande
		--

inherit

	ARGUMENTS

	LUAT_GLOBAL

creation

	fabriquer

feature {}

	fabriquer is
			-- constructeur
		do
			create commandes.with_capacity( 1 )
		end

feature {}

	etat_lecture_options : INTEGER is unique
	etat_coherence_options : INTEGER is unique
	etat_commande_analyse : INTEGER is unique
	etat_commande_comparaison : INTEGER is unique
	etat_commande_unitaire : INTEGER is unique
	etat_final : INTEGER is unique

	mode_indetermine : INTEGER is unique
	mode_analyse : INTEGER is unique
	mode_comparaison : INTEGER is unique
	mode_unitaire : INTEGER is unique

feature

	analyser is
			-- analyse les arguments de la ligne de commande et produit
			-- les commandes en conséquences
		local
			lexeme, etat, mode : INTEGER
			analyseur : LUAT_ANALYSEUR
			option : LUAT_OPTION
			avant, apres : STRING
			modele_precise : BOOLEAN
			lot_active : BOOLEAN
		do
			create option.fabriquer
			mode := mode_indetermine

			-- analyse de la ligne de commande à l'aide d'un automate
			-- d'état

			lexeme := 1
			from etat := etat_lecture_options
			until etat = etat_final
			loop
				if lexeme > argument_count then
					etat := etat_final
				end

				inspect etat
				when etat_final then
					-- état puits

				when etat_lecture_options then
					-- accumulation des options. La liste des options
					-- s'arrête au premier argument qui n'est pas reconnu
					-- comme une option, ou à partir de "--".

					inspect argument( lexeme )

						-- langage

					when "--ada" then
						if analyseur = void then
							create {LUAT_ANALYSEUR_ADA} analyseur.fabriquer
						else
							afficher_erreur( once "le langage est spécifié au moins deux fois" )
							etat := etat_final
						end
						lexeme := lexeme + 1

					when "--c++" then
						if analyseur = void then
							create {LUAT_ANALYSEUR_C_PLUS_PLUS} analyseur.fabriquer
						else
							afficher_erreur( once "le langage est spécifié au moins deux fois" )
							etat := etat_final
						end
						lexeme := lexeme + 1

					when "--eiffel" then
						if analyseur = void then
							create {LUAT_ANALYSEUR_EIFFEL} analyseur.fabriquer
						else
							afficher_erreur( once "le langage est spécifié au moins deux fois" )
							etat := etat_final
						end
						lexeme := lexeme + 1

						-- filtre

					when "--code" then
						if option.code then
							afficher_erreur( once "option %"--code%" surnuméraire" )
							etat := etat_final
						else
							option.met_code( true )
						end
						lexeme := lexeme + 1

					when "--commentaire" then
						if option.commentaire then
							afficher_erreur( once "option %"--commentaire%" surnuméraire" )
							etat := etat_final
						else
							option.met_commentaire( true )
						end
						lexeme := lexeme + 1

					when "--total" then
						if option.total then
							afficher_erreur( once "option %"--total%" surnuméraire" )
							etat := etat_final
						else
							option.met_total( true )
						end
						lexeme := lexeme + 1

						-- modèle différentiel

					when "--effort" then
						if modele_precise then
							afficher_erreur( once "le modèle de comparaison est précisé au moins deux fois" )
							etat := etat_final
						else
							modele_precise := true
							usine_metrique.met_modele( create {LUAT_METRIQUE_EFFORT}.fabriquer )
						end
						lexeme := lexeme + 1

					when "--normal" then
						if modele_precise then
							afficher_erreur( once "le modèle de comparaison est précisé au moins deux fois" )
							etat := etat_final
						else
							modele_precise := true
							usine_metrique.met_modele( create {LUAT_METRIQUE_NORMALE}.fabriquer )
						end
						lexeme := lexeme + 1

						-- lot

					when "--lot" then
						if not lot_active then
							lot_active := true
						else
							afficher_erreur( once "option %"--lot%" surnuméraire" )
							etat := etat_final
						end
						lexeme := lexeme + 1

						-- commande

					when "--analyse" then
						if mode = mode_indetermine then
							mode := mode_analyse
						else
							afficher_erreur( once "le mode est spécifié au moins deux fois" )
							etat := etat_final
						end
						lexeme := lexeme + 1

					when "--diff" then
						if mode = mode_indetermine then
							mode := mode_comparaison
						else
							afficher_erreur( once "le mode est spécifié au moins deux fois" )
							etat := etat_final
						end
						lexeme := lexeme + 1

					when "--" then
						etat := etat_coherence_options
						lexeme := lexeme + 1

					else
						etat := etat_coherence_options
					end

				when etat_coherence_options then
					-- sélection du spectre de l'analyse en fonction du
					-- type de commandes à effectuer

					if mode = mode_indetermine then
						mode := mode_unitaire
					end

					inspect mode
					when mode_analyse then
						if modele_precise then
							afficher_erreur( once "il n'est pas utile de préciser le modèle de comptage différentiel pour une analyse" )
							etat := etat_final
						elseif not option.choix_est_effectue then
							option.met_total( true )
							etat := etat_commande_analyse
						elseif not option.choix_est_unique then
							afficher_erreur( once "une seule option autorisée lors d'une demande d'analyse" )
							etat := etat_final
						else
							etat := etat_commande_analyse
						end

					when mode_comparaison then
						if not option.choix_est_effectue then
							option.met_code( true )
							etat := etat_commande_comparaison
						elseif not option.choix_est_unique then
							afficher_erreur( once "une seule option autorisée lors d'une demande de comparaison" )
							etat := etat_final
						else
							etat := etat_commande_comparaison
						end

					when mode_unitaire then
						if modele_precise then
							afficher_erreur( once "il n'est pas utile de préciser le modèle de comptage différentiel pour un comptage unitaire" )
							etat := etat_final
						elseif not option.choix_est_effectue then
							option.met( true, true, false )
							etat := etat_commande_unitaire
						end
					end

				when etat_commande_analyse then
					-- commande de type analyse

					if lot_active then
						produire_lot_commande_analyse( analyseur, argument( lexeme ), option )
					else
						produire_commande_analyse( analyseur, argument( lexeme ), option )
					end
					lexeme := lexeme + 1

				when etat_commande_comparaison then
					-- commande de type comparaison

					if lexeme + 1 /= argument_count then
						afficher_erreur( once "il faut deux fichiers en mode différentiel" )
					else
						avant := argument( lexeme )
						apres := argument( lexeme + 1 )

						if lot_active then
							produire_lot_commande_differentiel( analyseur, avant, apres, option )
						else
							if avant.is_equal( once "-rien-" ) then
								avant := void
							end
							if apres.is_equal( once "-rien-" ) then
								apres := void
							end

							if avant = void
								and apres = void
							 then
								afficher_erreur( once "on ne peut comparer ce qui n'existait pas et ce qui n'existe plus" )
							else
								produire_commande_differentiel( analyseur, avant, apres, option )
							end
						end
					end
					etat := etat_final

				when etat_commande_unitaire then
					-- commande de type mesure

					if lot_active then
						produire_lot_commande_unitaire( analyseur, argument( lexeme ), option )
					else
						produire_commande_unitaire( analyseur, argument( lexeme ), option )
					end
					lexeme := lexeme + 1

				else
					debug
						std_error.put_string( once "Tiens, un bogue ! 'etat' = " )
						std_error.put_integer( etat )
						std_error.put_new_line
						std_error.flush
					end
					etat := etat_final
				end
			end
		end

	commandes : FAST_ARRAY[ LUAT_COMMANDE ]
			-- traduction des options de la ligne de commande en un
			-- ensemble de commandes

feature

	usage is
			-- affiche, sur la sortie d'erreur, une aide à l'utilisation
			-- de l'outil
		do
			std_error.put_string( once "[
usage : codemetre [--ada|--c++|--eiffel] [--code] [--commentaire] [--total]
[--analyse|--diff] [--normal|--effort] [--lot] [--] FICHIER...

Pour de plus amples informations, tapez "man codemetre"

                                      ]")
			std_error.flush
		end

feature {}

	afficher_erreur( p_message : STRING ) is
			-- produit sur la sortie d'erreur le message correspondant
		do
			std_error.put_string( once "Syntaxe incorrecte : " )
			std_error.put_string( p_message )
			std_error.put_new_line
			std_error.put_new_line
			std_error.flush
		end

feature {}

	produire_lot_commande_analyse( p_analyseur : LUAT_ANALYSEUR
											 p_lot : STRING
											 p_option : LUAT_OPTION ) is
			-- ajoute autant de commandes d'analyse à la liste de
			-- commandes qu'il n'y a de fichiers énumérés dans le lot,
			-- sauf pour ceux dont le langage ne peut être déterminé
		require
			lot_valide : p_lot /= void
			option_valide : p_option /= void
		local
			lot : TEXT_FILE_READ
		do
			create lot.connect_to( p_lot )
			if not lot.is_connected then
				std_error.put_string( once "*** Erreur : le lot %"" )
				std_error.put_string( p_lot )
				std_error.put_string( once "%" est inaccessible en lecture" )
				std_error.put_new_line
				std_error.flush
			else
				from lot.read_line
				until lot.end_of_input
				loop
					produire_commande_analyse( p_analyseur, lot.last_string.twin, p_option )
					lot.read_line
				end
				lot.disconnect
			end
		end

	produire_commande_analyse( p_analyseur : LUAT_ANALYSEUR
										p_nom_fichier : STRING
										p_option : LUAT_OPTION ) is
			-- ajoute une commande d'analyse à la liste des commandes, à
			-- moins que le langage ne puisse être déterminé
		require
			nom_valide : p_nom_fichier /= void
			option_valide : p_option /= void
		local
			analyseur : LUAT_ANALYSEUR
			commande : LUAT_COMMANDE_ANALYSE
		do
			if p_analyseur /= void then
				analyseur := p_analyseur
			else
				analyseur := deviner_langage( p_nom_fichier )
			end

			if analyseur /= void then
				create commande.fabriquer( analyseur, p_nom_fichier, p_option )
				commandes.add_last( commande )
			else
				std_error.put_string( once "L'extension du fichier " )
				std_error.put_string( p_nom_fichier )
				std_error.put_string( once " n'est pas reconnue" )
				std_error.put_new_line
				std_error.flush
			end
		end

feature {}

	produire_lot_commande_differentiel( p_analyseur : LUAT_ANALYSEUR
													p_lot_avant, p_lot_apres : STRING
													p_option : LUAT_OPTION ) is
			-- ajoute autant de commandes de comparaison à la liste de
			-- commandes qu'il n'y a de fichiers énumérés dans le lot,
			-- sauf pour ceux dont le langage ne peut être déterminé
		require
			lots_valides : p_lot_avant /= void and p_lot_apres /= void
			option_valide : p_option /= void
		local
			lot_avant, lot_apres : TEXT_FILE_READ
			avant, apres : STRING
		do
			create lot_avant.connect_to( p_lot_avant )
			create lot_apres.connect_to( p_lot_apres )

			if not lot_avant.is_connected then
				std_error.put_string( once "*** Erreur : le lot %"" )
				std_error.put_string( p_lot_avant )
				std_error.put_string( once "%" est inaccessible en lecture" )
				std_error.put_new_line
				std_error.flush
			elseif not lot_apres.is_connected then
				std_error.put_string( once "*** Erreur : le lot %"" )
				std_error.put_string( p_lot_apres )
				std_error.put_string( once "%" est inaccessible en lecture" )
				std_error.put_new_line
				std_error.flush
				lot_avant.disconnect
			else
				from
					lot_avant.read_line
					if not lot_avant.end_of_input then
						avant := lot_avant.last_string.twin
					end
					lot_apres.read_line
					if not lot_apres.end_of_input then
						apres := lot_apres.last_string.twin
					end
				until lot_avant.end_of_input
					or lot_apres.end_of_input
				loop
					if avant.is_equal( once "-rien-" ) then
						avant := void
					end
					if apres.is_equal( once "-rien-" ) then
						apres := void
					end

					if avant = void
						and apres = void
					 then
						afficher_erreur( once "on ne peut comparer ce qui n'existait pas et ce qui n'existe plus" )
					else
						produire_commande_differentiel( p_analyseur, avant, apres, p_option )
					end

					lot_avant.read_line
					if not lot_avant.end_of_input then
						avant := lot_avant.last_string.twin
					end
					lot_apres.read_line
					if not lot_apres.end_of_input then
						apres := lot_apres.last_string.twin
					end
				end

				-- production d'un avertissement au cas où les lots ne
				-- feraient pas la même taille

				if not ( lot_avant.end_of_input
							and lot_apres.end_of_input )
				 then
					std_error.put_string( once "*** Avertissement : les deux lots ne font pas la même taille." )
					std_error.put_new_line
					std_error.flush
				end

				lot_avant.disconnect
				lot_apres.disconnect
			end
		end

	produire_commande_differentiel( p_analyseur : LUAT_ANALYSEUR
											  p_avant, p_apres : STRING
											  p_option : LUAT_OPTION ) is
			-- ajoute une commande de comparaison à la liste des
			-- commandes, à moins que le langage ne puisse être
			-- déterminé
		require
			noms_valides : p_avant /= void or p_apres /= void
			option_valide : p_option /= void
		local
			analyseur : LUAT_ANALYSEUR
			commande : LUAT_COMMANDE_DIFFERENTIEL
		do
			if p_analyseur /= void then
				analyseur := p_analyseur
			else
				if p_apres /= void then
					analyseur := deviner_langage( p_apres )
				end
				if analyseur = void and p_avant /= void then
					analyseur := deviner_langage( p_avant )
				end
			end

			if analyseur /= void then
				create commande.fabriquer( analyseur, p_avant, p_apres, p_option )
				commandes.add_last( commande )
			else
				std_error.put_string( once "Aucune extension de fichier n'a été reconnue" )
				std_error.put_new_line
			end
		end

feature {}

	produire_lot_commande_unitaire( p_analyseur : LUAT_ANALYSEUR
											  p_lot : STRING
											  p_option : LUAT_OPTION ) is
			-- ajoute autant de commandes de mesure à la liste de
			-- commandes qu'il n'y a de fichiers énumérés dans le lot,
			-- sauf pour ceux dont le langage ne peut être déterminé
		require
			lot_valide : p_lot /= void
			option_valide : p_option /= void
		local
			lot : TEXT_FILE_READ
		do
			create lot.connect_to( p_lot )
			if not lot.is_connected then
				std_error.put_string( once "*** Erreur : le lot %"" )
				std_error.put_string( p_lot )
				std_error.put_string( once "%" est inaccessible en lecture" )
				std_error.put_new_line
			else
				from lot.read_line
				until lot.end_of_input
				loop
					produire_commande_unitaire( p_analyseur, lot.last_string.twin, p_option )
					lot.read_line
				end
				lot.disconnect
			end
		end

	produire_commande_unitaire( p_analyseur : LUAT_ANALYSEUR
										 p_nom_fichier : STRING
										 p_option : LUAT_OPTION ) is
			-- ajoute une commande de mesure à la liste des commandes, à
			-- moins que le langage ne puisse être déterminé
		require
			nom_valide : p_nom_fichier /= void
			option_valide : p_option /= void
		local
			analyseur : LUAT_ANALYSEUR
			commande : LUAT_COMMANDE_UNITAIRE
		do
			if p_analyseur /= void then
				analyseur := p_analyseur
			else
				analyseur := deviner_langage( p_nom_fichier )
			end

			if analyseur /= void then
				create commande.fabriquer( analyseur, p_nom_fichier, p_option )
				commandes.add_last( commande )
			else
				std_error.put_string( once "L'extension du fichier " )
				std_error.put_string( p_nom_fichier )
				std_error.put_string( once " n'est pas reconnue" )
				std_error.put_new_line
			end
		end

feature {}

	deviner_langage( p_nom_fichier : STRING ) : LUAT_ANALYSEUR is
			-- tente de fournir l'analyseur le plus à même de
			-- correspondre en fonction de l'extension du fichier
		require
			nom_valide : p_nom_fichier /= void
		local
			suffixe : STRING
			i : INTEGER
		do
			-- isolement du suffixe
			i := p_nom_fichier.last_index_of( '.' )
			if p_nom_fichier.valid_index( i ) then
				suffixe := p_nom_fichier.substring( i + 1, p_nom_fichier.upper )
			else
				suffixe := once ""
			end

			inspect suffixe
			when "e" then
				result := analyseur_eiffel
			when "ads", "adb" then
				result := analyseur_ada
			when "hpp", "C", "cc", "cpp" then
				result := analyseur_c_plus_plus
			else
			end
		end

	analyseur_ada : LUAT_ANALYSEUR_ADA is
		once
			create result.fabriquer
		end

	analyseur_c_plus_plus : LUAT_ANALYSEUR_C_PLUS_PLUS is
		once
			create result.fabriquer
		end

	analyseur_eiffel : LUAT_ANALYSEUR_EIFFEL is
		once
			create result.fabriquer
		end

end
