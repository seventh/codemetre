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
			arborescence_active : BOOLEAN
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
							analyseur := analyseur_ada
						else
							afficher_erreur( once "language is enforced more than once" )
							etat := etat_final
						end
						lexeme := lexeme + 1

					when "--c" then
						if analyseur = void then
							analyseur := analyseur_c
						else
							afficher_erreur( once "language is enforced more than once" )
							etat := etat_final
						end
						lexeme := lexeme + 1

					when "--c++" then
						if analyseur = void then
							analyseur := analyseur_c_plus_plus
						else
							afficher_erreur( once "language is enforced more than once" )
							etat := etat_final
						end
						lexeme := lexeme + 1

					when "--eiffel" then
						if analyseur = void then
							analyseur := analyseur_eiffel
						else
							afficher_erreur( once "language is enforced more than once" )
							etat := etat_final
						end
						lexeme := lexeme + 1

						-- filtre

					when "--code" then
						if option.code then
							afficher_erreur( once "too many %"--code%" option" )
							etat := etat_final
						else
							option.met_code( true )
						end
						lexeme := lexeme + 1

					when "--comment" then
						if option.commentaire then
							afficher_erreur( once "too many %"--comment%" option" )
							etat := etat_final
						else
							option.met_commentaire( true )
						end
						lexeme := lexeme + 1

					when "--total" then
						if option.total then
							afficher_erreur( once "too many %"--total%" option" )
							etat := etat_final
						else
							option.met_total( true )
						end
						lexeme := lexeme + 1

						-- modèle différentiel

					when "--effort" then
						if modele_precise then
							afficher_erreur( once "too many diff models" )
							etat := etat_final
						else
							modele_precise := true
							usine_metrique.met_modele( create {LUAT_METRIQUE_EFFORT}.fabriquer )
						end
						lexeme := lexeme + 1

					when "--normal" then
						if modele_precise then
							afficher_erreur( once "too many diff models" )
							etat := etat_final
						else
							modele_precise := true
							usine_metrique.met_modele( create {LUAT_METRIQUE_NORMALE}.fabriquer )
						end
						lexeme := lexeme + 1

						-- lot

					when "--batch" then
						if arborescence_active then
							afficher_erreur( once "conflict between %"--batch%" and %"--tree%" options" )
							etat := etat_final
						elseif not lot_active then
							lot_active := true
						else
							afficher_erreur( once "too many %"--batch%" option" )
							etat := etat_final
						end
						lexeme := lexeme + 1

					when "--tree" then
						if lot_active then
							afficher_erreur( once "conflict between %"--batch%" and %"--tree%" options" )
							etat := etat_final
						elseif not arborescence_active then
							arborescence_active := true
						else
							afficher_erreur( once "too many %"--tree%" option" )
							etat := etat_final
						end
						lexeme := lexeme + 1

						-- commande

					when "--anal" then
						if mode = mode_indetermine then
							mode := mode_analyse
						else
							afficher_erreur( once "mode is enforced more than once" )
							etat := etat_final
						end
						lexeme := lexeme + 1

					when "--diff" then
						if mode = mode_indetermine then
							mode := mode_comparaison
						else
							afficher_erreur( once "mode is enforced more than once" )
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
							afficher_erreur( once "no diff model is required for analysis" )
							etat := etat_final
						elseif not option.choix_est_effectue then
							option.met_total( true )
							etat := etat_commande_analyse
						elseif not option.choix_est_unique then
							afficher_erreur( once "one option only for analysis" )
							etat := etat_final
						else
							etat := etat_commande_analyse
						end

					when mode_comparaison then
						if not option.choix_est_effectue then
							option.met_code( true )
							etat := etat_commande_comparaison
						elseif not option.choix_est_unique then
							afficher_erreur( once "one option only for diff" )
							etat := etat_final
						else
							etat := etat_commande_comparaison
						end

					when mode_unitaire then
						if modele_precise then
							afficher_erreur( once "no diff model is required for measure" )
							etat := etat_final
						elseif not option.choix_est_effectue then
							option.met( true, true, false )
							etat := etat_commande_unitaire
						else
							etat := etat_commande_unitaire
						end
					end

				when etat_commande_analyse then
					-- commande de type analyse

					if lot_active then
						produire_liste_commande_analyse( analyseur, argument( lexeme ), option )
					elseif arborescence_active then
						produire_arbre_commande_analyse( analyseur, argument( lexeme ), option )
					else
						produire_commande_analyse( analyseur, argument( lexeme ), option )
					end
					lexeme := lexeme + 1

				when etat_commande_comparaison then
					-- commande de type comparaison

					if lexeme + 1 /= argument_count then
						afficher_erreur( once "two files are required in diff mode" )
					else
						avant := argument( lexeme )
						apres := argument( lexeme + 1 )

						if avant.is_equal( once "-nil-" ) then
							avant := void
						end
						if apres.is_equal( once "-nil-" ) then
							apres := void
						end

						if lot_active then
							produire_lot_commande_differentiel( analyseur, avant, apres, option )
						elseif arborescence_active then
							produire_arbre_commande_differentiel( analyseur, avant, apres, option )
						else
							produire_commande_differentiel( analyseur, avant, apres, option )
						end
					end
					etat := etat_final

				when etat_commande_unitaire then
					-- commande de type mesure

					if lot_active then
						produire_liste_commande_unitaire( analyseur, argument( lexeme ), option )
					elseif arborescence_active then
						produire_arbre_commande_unitaire( analyseur, argument( lexeme ), option )
					else
						produire_commande_unitaire( analyseur, argument( lexeme ), option )
					end
					lexeme := lexeme + 1

				else
					debug
						std_error.put_string( once "Debug: bogue dans l'analyseur de commande - 'etat' = " )
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
			std_error.put_string( traduire( once "usage:" ) )
			std_error.put_string( once " codemetre [--ada|--c|--c++|--eiffel] [--code] [--comment] [--total]%N[--batch|--tree] [--anal|--diff] [--normal|--effort] [--] " )
			std_error.put_string( traduire( once "FILE" ) )
			std_error.put_string( once "..." )
			std_error.put_new_line
			std_error.put_new_line

			std_error.put_string( traduire( once "For further information, see %"man codemetre%"" ) )
			std_error.put_new_line
			std_error.flush
		end

feature {}

	afficher_erreur( p_message : STRING ) is
			-- produit sur la sortie d'erreur le message correspondant
		do
			std_error.put_string( traduire( once "Syntax error: " ) )
			std_error.put_string( traduire( p_message ) )
			std_error.put_new_line
			std_error.put_new_line
			std_error.flush
		end

feature {}

	ouvrir_arbre( p_racine : STRING
					  p_est_trie : BOOLEAN ) : LUAT_LOT is
			-- fournit un descripteur de fichier sur le lot constitué de
			-- la liste des fichiers depuis la racine correspondante
		local
			arbre : LUAT_LOT_ARBRE
		do
			create arbre.fabriquer( p_racine, p_est_trie )
			if arbre.erreur then
				std_error.put_string( traduire( once "Error: %"" ) )
				std_error.put_string( p_racine )
				std_error.put_string( traduire( once "%" is not a valid directory name" ) )
				std_error.put_new_line
				std_error.flush

				create {LUAT_LOT_BLANC} result.fabriquer
			else
				result := arbre
			end
		end

	ouvrir_liste( p_nom_fichier : STRING ) : LUAT_LOT is
			-- fournit un descripteur de fichier sur le lot
			-- correspondant si possible
		local
			flux : TEXT_FILE_READ
		do
			if p_nom_fichier = void then
				create {LUAT_LOT_BLANC} result.fabriquer
			else
				create flux.connect_to( p_nom_fichier )
				if flux.is_connected then
					create {LUAT_LOT_LISTE} result.fabriquer( flux )
				else
					std_error.put_string( traduire( once "Error: batch file %"" ) )
					std_error.put_string( p_nom_fichier )
					std_error.put_string( traduire( once "%" cannot be open for reading" ) )
					std_error.put_new_line
					std_error.flush

					create {LUAT_LOT_BLANC} result.fabriquer
				end
			end
		end

feature {}

	produire_arbre_commande_analyse( p_analyseur : LUAT_ANALYSEUR
												p_racine : STRING
												p_option : LUAT_OPTION ) is
			-- ajoute autant de commandes d'analyse à la liste de
			-- commandes qu'il n'y a de fichiers sous la racine, sauf
			-- pour ceux dont le langage ne peut être déterminé
		require
			racine_valide : not p_racine.is_empty
			option_valide : p_option /= void
		local
			lot : LUAT_LOT
		do
			lot := ouvrir_arbre( p_racine, false )
			produire_lot_commande_analyse( p_analyseur, lot, p_option )
			lot.clore
		end

	produire_liste_commande_analyse( p_analyseur : LUAT_ANALYSEUR
												p_liste : STRING
												p_option : LUAT_OPTION ) is
			-- ajoute autant de commandes d'analyse à la liste de
			-- commandes qu'il n'y a de fichiers énumérés dans la liste,
			-- sauf pour ceux dont le langage ne peut être déterminé
		require
			liste_valide : p_liste /= void
			option_valide : p_option /= void
		local
			lot : LUAT_LOT
		do
			lot := ouvrir_liste( p_liste )
			produire_lot_commande_analyse( p_analyseur, lot, p_option )
			lot.clore
		end

	produire_lot_commande_analyse( p_analyseur : LUAT_ANALYSEUR
											 p_lot : LUAT_LOT
											 p_option : LUAT_OPTION ) is
			-- ajoute autant de commandes d'analyse à la liste de
			-- commandes qu'il n'y a de fichiers énumérés dans le lot,
			-- sauf pour ceux dont le langage ne peut être déterminé
		require
			lot_valide : p_lot /= void
			option_valide : p_option /= void
		local
			nom_fichier : STRING
		do
			from p_lot.lire
			until p_lot.est_epuise
			loop
				nom_fichier := p_lot.entree
				if nom_fichier /= void then
					produire_commande_analyse( p_analyseur, nom_fichier, p_option )
				end
				p_lot.lire
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
			end
		end

feature {}

	produire_arbre_commande_differentiel( p_analyseur : LUAT_ANALYSEUR
													  p_racine_avant, p_racine_apres : STRING
													p_option : LUAT_OPTION ) is
			-- ajoute autant de commandes de comparaison à la liste de
			-- commandes qu'il n'y a de fichiers présents sous chacune
			-- des racines, sauf pour ceux dont le langage ne peut être
			-- déterminé
		require
			option_valide : p_option /= void
		local
			avant, apres : STRING
			lot_avant, lot_apres : LUAT_LOT
		do
			lot_avant := ouvrir_arbre( p_racine_avant, true )
			lot_apres := ouvrir_arbre( p_racine_apres, true )

			from
				lot_avant.lire
				lot_apres.lire
			until lot_avant.est_epuise
				or lot_apres.est_epuise
			loop
				avant := lot_avant.entree
				if avant /= void then
					avant := avant.substring( avant.lower + p_racine_avant.count, avant.upper )
				end
				apres := lot_apres.entree
				if apres /= void then
					apres := apres.substring( apres.lower + p_racine_apres.count, apres.upper )
				end

				if avant < apres then
					produire_commande_differentiel( p_analyseur, lot_avant.entree, void, p_option )
					lot_avant.lire
				elseif avant > apres then
					produire_commande_differentiel( p_analyseur, void, lot_apres.entree, p_option )
					lot_apres.lire
				else
					produire_commande_differentiel( p_analyseur, lot_avant.entree, lot_apres.entree, p_option )
					lot_avant.lire
					lot_apres.lire
				end
			end

			from
			until lot_avant.est_epuise
				and lot_apres.est_epuise
			loop
				avant := lot_avant.entree
				apres := lot_apres.entree
				produire_commande_differentiel( p_analyseur, avant, apres, p_option )

				lot_avant.lire
				lot_apres.lire
			end

			lot_avant.clore
			lot_apres.clore
		end

	produire_lot_commande_differentiel( p_analyseur : LUAT_ANALYSEUR
													p_lot_avant, p_lot_apres : STRING
													p_option : LUAT_OPTION ) is
			-- ajoute autant de commandes de comparaison à la liste de
			-- commandes qu'il n'y a de fichiers énumérés dans le lot,
			-- sauf pour ceux dont le langage ne peut être déterminé
		require
			option_valide : p_option /= void
		local
			avant, apres : STRING
			lot_avant, lot_apres : LUAT_LOT
		do
			lot_avant := ouvrir_liste( p_lot_avant )
			lot_apres := ouvrir_liste( p_lot_apres )

			from
				lot_avant.lire
				lot_apres.lire
			until lot_avant.est_epuise
				and lot_apres.est_epuise
			loop
				avant := lot_avant.entree
				apres := lot_apres.entree
				produire_commande_differentiel( p_analyseur, avant, apres, p_option )

				lot_avant.lire
				lot_apres.lire
			end

			lot_avant.clore
			lot_apres.clore
		end

	produire_commande_differentiel( p_analyseur : LUAT_ANALYSEUR
											  p_avant, p_apres : STRING
											  p_option : LUAT_OPTION ) is
			-- ajoute une commande de comparaison à la liste des
			-- commandes, à moins que le langage ne puisse être
			-- déterminé
		require
			option_valide : p_option /= void
		local
			analyseur : LUAT_ANALYSEUR
			commande : LUAT_COMMANDE_DIFFERENTIEL
		do
			if p_avant = void
				and p_apres = void
			 then
				afficher_erreur( once "at least one of the two arguments shall exists" )
			else
				-- détermination du langage si nécessaire

				if p_analyseur /= void then
					analyseur := p_analyseur
				elseif p_apres /= void then
					analyseur := deviner_langage( p_apres )
				end
				if analyseur = void then
					analyseur := deviner_langage( p_avant )
				end

				-- création de la commande de comparaison si un langage a
				-- été précisé ou déviné

				if analyseur /= void then
					create commande.fabriquer( analyseur, p_avant, p_apres, p_option )
					commandes.add_last( commande )
				end
			end
		end

feature {}

	produire_arbre_commande_unitaire( p_analyseur : LUAT_ANALYSEUR
												 p_racine : STRING
												 p_option : LUAT_OPTION ) is
			-- ajoute autant de commandes de mesure à la liste de
			-- commandes qu'il n'y a de fichiers sous racine, sauf pour
			-- ceux dont le langage ne peut être déterminé
		require
			racine_valide : p_racine /= void
			option_valide : p_option /= void
		local
			lot : LUAT_LOT
		do
			lot := ouvrir_arbre( p_racine, false )
			produire_lot_commande_unitaire( p_analyseur, lot, p_option )
			lot.clore
		end

	produire_liste_commande_unitaire( p_analyseur : LUAT_ANALYSEUR
												 p_liste : STRING
											  p_option : LUAT_OPTION ) is
			-- ajoute autant de commandes de mesure à la liste de
			-- commandes qu'il n'y a de fichiers énumérés dans la liste,
			-- sauf pour ceux dont le langage ne peut être déterminé
		require
			liste_valide : p_liste /= void
			option_valide : p_option /= void
		local
			lot : LUAT_LOT
		do
			lot := ouvrir_liste( p_liste )
			produire_lot_commande_unitaire( p_analyseur, lot, p_option )
			lot.clore
		end

	produire_lot_commande_unitaire( p_analyseur : LUAT_ANALYSEUR
											  p_lot : LUAT_LOT
											  p_option : LUAT_OPTION ) is
			-- ajoute autant de commandes de mesure à la liste de
			-- commandes qu'il n'y a de fichiers énumérés dans le lot,
			-- sauf pour ceux dont le langage ne peut être déterminé
		require
			lot_valide : p_lot /= void
			option_valide : p_option /= void
		local
			nom_fichier : STRING
		do
			from p_lot.lire
			until p_lot.est_epuise
			loop
				nom_fichier := p_lot.entree
				if nom_fichier /= void then
					produire_commande_unitaire( p_analyseur, nom_fichier, p_option )
				end
				p_lot.lire
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
			when "ads", "adb" then
				result := analyseur_ada
			when "h", "c" then
				result := analyseur_c
			when "hpp", "C", "cc", "cpp" then
				result := analyseur_c_plus_plus
			when "e" then
				result := analyseur_eiffel
			else
				std_error.put_string( traduire( once "Error: extension of file %"" ) )
				std_error.put_string( p_nom_fichier )
				std_error.put_string( traduire( once "%" is unknown" ) )
				std_error.put_new_line
				std_error.flush
			end
		end

	analyseur_ada : LUAT_ANALYSEUR_ADA is
		once
			create result.fabriquer
		end

 	analyseur_c : LUAT_ANALYSEUR_FAMILLE_C is
		once
			create result.fabriquer( once "C" )
		end

 	analyseur_c_plus_plus : LUAT_ANALYSEUR_FAMILLE_C is
		once
			create result.fabriquer( once "C++" )
		end

	analyseur_eiffel : LUAT_ANALYSEUR_EIFFEL is
		once
			create result.fabriquer
		end

end
