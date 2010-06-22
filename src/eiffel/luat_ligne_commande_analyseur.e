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
			aucune_commande_executee := true
		end

feature {}

	etat_lecture_options : INTEGER is unique
	etat_choix_langage : INTEGER is unique
	etat_choix_modele : INTEGER is unique
	etat_coherence_options : INTEGER is unique
	etat_commande_comparaison : INTEGER is unique
	etat_commande_unitaire : INTEGER is unique
	etat_commande_bilan : INTEGER is unique
	etat_final : INTEGER is unique

	mode_indetermine : INTEGER is unique
	mode_comparaison : INTEGER is unique
	mode_unitaire : INTEGER is unique

feature

	analyser is
			-- analyse les arguments de la ligne de commande et produit
			-- les commandes en conséquences
		local
			examen_demande : BOOLEAN
			analyseur_precise : BOOLEAN
			apres_est_lot, apres_est_repertoire : BOOLEAN
			avant, apres : STRING
			avant_est_lot, avant_est_repertoire : BOOLEAN
			bilan_final_precise : BOOLEAN
			fichier_configuration_est_inhibe : BOOLEAN
			filtre : LUAT_FILTRE
			lexeme, etat, mode : INTEGER
			modele_precise : BOOLEAN
			sortie_compacte_precise : BOOLEAN
		do
			create filtre.initialiser
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

						-- analyse lexicale

					when "--dump" then
						if examen_demande then
							avertir( once "too many %"--dump%" option" )
							etat := etat_final
						else
							examen_demande := true
						end
						lexeme := lexeme + 1

						-- commande

					when "--diff" then
						if mode = mode_indetermine then
							mode := mode_comparaison
						else
							avertir( once "mode is enforced more than once" )
							etat := etat_final
						end
						lexeme := lexeme + 1

						-- configuration

					when "--config" then
						if lexeme = 1
							and argument_count = 1
						 then
							configuration.appliquer_choix_fichier
							commandes.add_last( create {LUAT_COMMANDE_CONFIGURATION}.fabriquer )
						else
							avertir( once "%"--config%" is incompatible with any other argument" )
						end
						etat := etat_final

					when "--noconfig" then
						fichier_configuration_est_inhibe := true
						lexeme := lexeme + 1

						-- filtres

					when "--code" then
						if filtre.code then
							avertir( once "too many %"--code%" option" )
							etat := etat_final
						else
							filtre.met_code( true )
						end
						lexeme := lexeme + 1

					when "--comment" then
						if filtre.commentaire then
							avertir( once "too many %"--comment%" option" )
							etat := etat_final
						else
							filtre.met_commentaire( true )
						end
						lexeme := lexeme + 1

					when "--total" then
						if filtre.total then
							avertir( once "too many %"--total%" option" )
							etat := etat_final
						else
							filtre.met_total( true )
						end
						lexeme := lexeme + 1

						-- langage

					when "--lang" then
						if analyseur_precise then
							avertir( once "language is enforced more than once" )
							etat := etat_final
						else
							analyseur_precise := true
							etat := etat_choix_langage
						end
						lexeme := lexeme + 1

						-- modèle différentiel

					when "--model" then
						if modele_precise then
							avertir( once "too many diff models" )
							etat := etat_final
						else
							modele_precise := true
							etat := etat_choix_modele
						end
						lexeme := lexeme + 1

						-- résumé final

					when "--status" then
						if bilan_final_precise then
							avertir( once "too many %"--status%" option" )
							etat := etat_final
						else
							bilan_final_precise := true
						end
						lexeme := lexeme + 1

						-- sortie compacte

					when "--short" then
						if sortie_compacte_precise then
							avertir( once "too many %"--short%" option" )
							etat := etat_final
						else
							sortie_compacte_precise := true
						end
						lexeme := lexeme + 1

						-- forçage de la fin des options

					when "--" then
						etat := etat_coherence_options
						lexeme := lexeme + 1

					else
						etat := etat_coherence_options
					end

				when etat_choix_langage then
					-- spécification du langage, indépendamment de ce qui
					-- pourrait être déterminé automatiquement à partir
					-- des extensions de fichier

					if configuration.forcer_analyseur( argument( lexeme ) ) then
						etat := etat_lecture_options
					else
						avertir( once "unknown language" )
						etat := etat_final
					end
					lexeme := lexeme + 1

				when etat_choix_modele then
					-- spécification d'un autre modèle de mesure
					-- différentielle que celui par défaut

					if configuration.forcer_metrique( argument( lexeme ) ) then
						etat := etat_lecture_options
					else
						avertir( once "unknown diff model" )
						etat := etat_final
					end
					lexeme := lexeme + 1

				when etat_coherence_options then
					-- la configuration utilisateur n'est chargée que s'il
					-- n'y a pas de contre-indication

					if not fichier_configuration_est_inhibe then
						configuration.appliquer_choix_fichier
					end

					-- sélection du spectre de l'analyse en fonction du
					-- type de commandes à effectuer

					if mode = mode_indetermine then
						mode := mode_unitaire
					end

					inspect mode
					when mode_comparaison then
						bilan.forcer_metrique( configuration.differentiel.modele )
						if bilan_final_precise then
							configuration.differentiel.met_statut( true )
						end
						if examen_demande then
							configuration.differentiel.met_examen( true )
						end
						if sortie_compacte_precise then
							configuration.differentiel.met_abrege( true )
						end

						if not filtre.choix_est_effectue then
							etat := etat_commande_comparaison
						elseif not filtre.choix_est_unique then
							avertir( once "one filter only for diff" )
							etat := etat_final
						else
							configuration.differentiel.filtre.copy( filtre )
							etat := etat_commande_comparaison
						end

					when mode_unitaire then
						bilan.forcer_metrique( create {LUAT_METRIQUE_UNITAIRE}.fabriquer )
						if bilan_final_precise then
							configuration.unitaire.met_statut( true )
						end
						if examen_demande then
							configuration.unitaire.met_examen( true )
						end

						if modele_precise then
							avertir( once "no diff model is required for measure" )
							etat := etat_final
						elseif sortie_compacte_precise then
							avertir( once "short output is available only for diff" )
							etat := etat_final
						elseif filtre.choix_est_effectue then
							configuration.unitaire.filtre.copy( filtre )
							etat := etat_commande_unitaire
						else
							etat := etat_commande_unitaire
						end
					end

				when etat_commande_comparaison then
					-- commande de type comparaison

					if lexeme + 1 /= argument_count then
						avertir( once "two files are required in diff mode" )
						etat := etat_final
					else
						avant := argument( lexeme )
						apres := argument( lexeme + 1 )

						if avant.is_equal( once "-nil-" ) then
							avant := void
						end
						if apres.is_equal( once "-nil-" ) then
							apres := void
						end

						if avant = void and apres = void then
							avertir( once "at least one of the two arguments shall exists" )
							etat := etat_final
						else
							if avant = void then
								avant_est_lot := false
								avant_est_repertoire := false
							else
								avant_est_lot := configuration.est_lot( avant )
								avant_est_repertoire := est_repertoire( avant )
							end
							if apres = void then
								apres_est_lot := false
								apres_est_repertoire := false
							else
								apres_est_lot := configuration.est_lot( apres )
								apres_est_repertoire := est_repertoire( apres )
							end

							-- l'un des deux au moins est un lot
							if avant_est_lot xor apres_est_lot then
								avertir( once "batch file cannot be compared to single file or directory" )
								etat := etat_final
							elseif avant_est_lot then
								produire_lot_commande_differentiel( avant, apres )

							-- l'un des deux au moins est un répertoire
							elseif avant_est_repertoire xor apres_est_repertoire then
								avertir( once "directory cannot be compared to single or batch file" )
								etat := etat_final
							elseif avant_est_repertoire then
								produire_arbre_commande_differentiel( avant, apres )

							-- les deux ne sont ni des lots ni des répertoires
							else
								produire_commande_differentiel( avant, apres )
							end
						end

						-- s'il n'y a pas eu d'erreur grossière sur la
						-- ligne de commande, on produit le bilan si demandé

						if etat /= etat_final
							and configuration.differentiel.statut
						 then
							etat := etat_commande_bilan
						else
							etat := etat_final
						end
					end

				when etat_commande_unitaire then
					-- commande de type mesure

					if configuration.est_lot( argument( lexeme ) ) then
						produire_liste_commande_unitaire( argument( lexeme ) )
					elseif est_repertoire( argument( lexeme ) ) then
						produire_arbre_commande_unitaire( argument( lexeme ) )
					else
						produire_commande_unitaire( argument( lexeme ) )
					end

					if lexeme = argument_count
						and configuration.unitaire.statut
					 then
						etat := etat_commande_bilan
					else
						lexeme := lexeme + 1
					end

				when etat_commande_bilan then
					-- commande de type bilan

					commandes.add_last( create {LUAT_COMMANDE_BILAN}.fabriquer )
					etat := etat_final

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
			-- traduction des directives de la ligne de commande en un
			-- ensemble de commandes

feature

	usage is
			-- affiche, sur la sortie d'erreur, une aide à l'utilisation
			-- de l'outil
		do
			std_error.put_string( traduire( once "usage:" ) )
			std_error.put_string( once "%Tcodemetre%N%T [--code] [--comment] [--total]%N%T [--dump] [--lang <>] [--status]%N%T [--diff [--model <>] [--short]]%N%T [--noconfig]%N%T [--]%N%T " )
			std_error.put_string( traduire( once "FILE|DIRECTORY|BATCH..." ) )
			std_error.put_new_line
			std_error.put_new_line

			std_error.put_string( once "%Tcodemetre --config" )
			std_error.put_new_line
			std_error.put_new_line

			std_error.put_new_line

			std_error.put_string( traduire( once "For further information:" ) )
			std_error.put_new_line
			std_error.put_string( traduire( once " - see " ) )
			std_error.put_string( once "%"man codemetre%"" )
			std_error.put_new_line
			std_error.put_string( traduire( once " - visit " ) )
			std_error.put_string( once "http://wiki.github.com/seventh/codemetre" )
			std_error.put_new_line

			std_error.put_new_line

			std_error.flush
		end

feature {}

	avertir( p_message : STRING ) is
			-- traduit le message attendu sur la sortie d'erreur
		do
			std_error.put_string( traduire( once "Syntax error: " ) )
			std_error.put_string( traduire( p_message ) )
			std_error.put_new_line
			std_error.put_new_line
			std_error.flush
		end

feature {}

	est_repertoire( p_nom : STRING ) : BOOLEAN is
			-- vrai si et seulement si le nom passé en argument est un
			-- nom de répertoire valide
		require
			nom_valide : not p_nom.is_empty
		local
			repertoire : DIRECTORY
		do
			create repertoire.scan( p_nom )
			result := repertoire.last_scan_status
		end

feature {}

	ouvrir_arbre( p_racine : STRING
					  p_est_trie : BOOLEAN ) : LUAT_LOT is
			-- fournit un descripteur de fichier sur le lot constitué de
			-- la liste des fichiers depuis la racine correspondante
		do
			if p_racine = void then
				create {LUAT_LOT_BLANC} result.fabriquer
			else
				create {LUAT_LOT_ARBRE} result.fabriquer( p_racine, p_est_trie )
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

	comparer( p_nom_1, p_nom_2 : STRING ) : INTEGER is
			-- résultat équivalent à p_nom_1.compare( p_nom_2 ), mais
			-- prend en plus en compte les cas spéciaux où p_nom_1 ou
			-- p_nom_2 valent 'void'
		require
			noms_valides : p_nom_1 /= void or p_nom_2 /= void
		do
			if p_nom_1 = void then
				result := 1
			elseif p_nom_2 = void then
				result := -1
			else
				result := p_nom_1.compare( p_nom_2 )
			end
		ensure
			domaine : result.in_range( -1, 1 )
		end

	produire_arbre_commande_differentiel( p_racine_avant, p_racine_apres : STRING ) is
			-- ajoute autant de commandes de comparaison à la liste de
			-- commandes qu'il n'y a de fichiers présents sous chacune
			-- des racines, sauf pour ceux dont le langage ne peut être
			-- déterminé
		local
			avant, apres : STRING
			lot_avant, lot_apres : LUAT_LOT
			ordre : INTEGER
		do
			lot_avant := ouvrir_arbre( p_racine_avant, true )
			lot_apres := ouvrir_arbre( p_racine_apres, true )

			from
				lot_avant.lire
				lot_apres.lire
			until lot_avant.est_epuise
				and lot_apres.est_epuise
			loop
				avant := lot_avant.entree_courte
				apres := lot_apres.entree_courte

				-- deux fichiers sont comparés s'ils sont sous le même
				-- chemin par rapport à la racine

				ordre := comparer( avant, apres )
				inspect ordre
				when -1 then
					produire_commande_differentiel( lot_avant.entree, void )
					lot_avant.lire
				when 0 then
					produire_commande_differentiel( lot_avant.entree, lot_apres.entree )
					lot_avant.lire
					lot_apres.lire
				when 1 then
					produire_commande_differentiel( void, lot_apres.entree )
					lot_apres.lire
				end
			end
		end

	produire_lot_commande_differentiel( p_lot_avant, p_lot_apres : STRING ) is
			-- ajoute autant de commandes de comparaison à la liste de
			-- commandes qu'il n'y a de fichiers énumérés dans le lot,
			-- sauf pour ceux dont le langage ne peut être déterminé
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

				-- les fichiers sont comparés ligne à ligne

				-- afin d'éviter toute erreur intempestive, on s'assure
				-- de ne demander que des commandes qui ont un sens

				if avant /= void
					or apres /= void
				 then
					produire_commande_differentiel( avant, apres )
				end

				lot_avant.lire
				lot_apres.lire
			end

			lot_avant.clore
			lot_apres.clore
		end

	produire_commande_differentiel( p_avant, p_apres : STRING ) is
			-- ajoute une commande de comparaison à la liste des
			-- commandes, à moins que le langage ne puisse être
			-- déterminé
		local
			analyseur : LUAT_ANALYSEUR
			commande : LUAT_COMMANDE_DIFFERENTIEL
		do
			if p_avant = void
				and p_apres = void
			 then
				avertir( once "at least one of the two arguments shall exists" )
			else
				-- détermination du langage si nécessaire

				if p_apres /= void then
					analyseur := configuration.analyseur( p_apres )
				end
				if analyseur = void
					and p_avant /= void
				 then
					analyseur := configuration.analyseur( p_avant )
				end

				-- création de la commande de comparaison si un langage a
				-- été précisé ou déviné

				if analyseur /= void then
					create commande.fabriquer( analyseur, p_avant, p_apres )
					commande.executer
					aucune_commande_executee := false
				end
			end
		end

feature {}

	produire_arbre_commande_unitaire( p_racine : STRING ) is
			-- ajoute autant de commandes de mesure à la liste de
			-- commandes qu'il n'y a de fichiers sous racine, sauf pour
			-- ceux dont le langage ne peut être déterminé
		require
			racine_valide : p_racine /= void
		local
			lot : LUAT_LOT
		do
			lot := ouvrir_arbre( p_racine, false )
			produire_lot_commande_unitaire( lot )
			lot.clore
		end

	produire_liste_commande_unitaire( p_liste : STRING ) is
			-- ajoute autant de commandes de mesure à la liste de
			-- commandes qu'il n'y a de fichiers énumérés dans la liste,
			-- sauf pour ceux dont le langage ne peut être déterminé
		require
			liste_valide : p_liste /= void
		local
			lot : LUAT_LOT
		do
			lot := ouvrir_liste( p_liste )
			produire_lot_commande_unitaire( lot )
			lot.clore
		end

	produire_lot_commande_unitaire( p_lot : LUAT_LOT ) is
			-- ajoute autant de commandes de mesure à la liste de
			-- commandes qu'il n'y a de fichiers énumérés dans le lot,
			-- sauf pour ceux dont le langage ne peut être déterminé
		require
			lot_valide : p_lot /= void
		local
			nom_fichier : STRING
		do
			from p_lot.lire
			until p_lot.est_epuise
			loop
				nom_fichier := p_lot.entree
				if nom_fichier /= void then
					produire_commande_unitaire( nom_fichier )
				end
				p_lot.lire
			end
		end

	produire_commande_unitaire( p_nom_fichier : STRING ) is
			-- ajoute une commande de mesure à la liste des commandes, à
			-- moins que le langage ne puisse être déterminé
		require
			nom_valide : p_nom_fichier /= void
		local
			analyseur : LUAT_ANALYSEUR
			commande : LUAT_COMMANDE_UNITAIRE
		do
			analyseur := configuration.analyseur( p_nom_fichier )

			if analyseur /= void then
				create commande.fabriquer( analyseur, p_nom_fichier )
				commande.executer
				aucune_commande_executee := false
			end
		end

feature

	aucune_commande_executee : BOOLEAN
			-- vrai si et seulement si aucune commande n'a été exécutée
			-- suite à l'analyse de la ligne de commande

end
