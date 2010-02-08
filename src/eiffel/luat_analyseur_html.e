indexing

	auteur : "seventh"
	license : "GPL 3.0"

class

	LUAT_ANALYSEUR_HTML

		--
		-- Analyseur syntaxique du langage HTML
		--

inherit

	LUAT_ANALYSEUR
		redefine
			retenir_erreur
		end

creation

	fabriquer

feature

	langage : STRING is "html"

feature {LUAT_ANALYSEUR}

	analyser is
		do
			check
				chaine.is_empty
				ligne.is_empty
			end

			indice_ligne := 1
			erreur := false
			message_erreur := once ""

			from etat := etat_initial
			until etat = etat_final
			loop
				fichier.avancer

				inspect etat
				when etat_initial then
					traiter_etat_initial

				-- code

				when etat_code then
					inspect caractere
					when ' ', '%F', '%R', '%T' then
						produire_code
						etat := etat_initial
					when '%N' then
						produire_code
						produire_ligne
						etat := etat_initial
					when '%U' then
						produire_code
						produire_ligne
						etat := etat_final
					else
						chaine.add_last( caractere )
					end

				-- détection de la marque de début de commentaire

				when etat_apres_chevron_ouvrant then
					inspect caractere
					when '!' then
						chaine.add_last( caractere )
						etat := etat_apres_chevron_ouvrant_exclamation
					else
						produire_code
						traiter_etat_initial
					end

				when etat_apres_chevron_ouvrant_exclamation then
					inspect caractere
					when '-' then
						chaine.add_last( caractere )
						etat := etat_apres_chevron_ouvrant_exclamation_tiret
					else
						produire_code
						traiter_etat_initial
					end

				when etat_apres_chevron_ouvrant_exclamation_tiret then
					inspect caractere
					when '-' then
						chaine.add_last( caractere )
						produire_commentaire
						etat := etat_commentaire
					else
						produire_code
						traiter_etat_initial
					end

				-- commentaire

				when etat_commentaire then
					traiter_etat_commentaire

				-- détection de la marque de fin de commentaire

				when etat_commentaire_apres_tiret then
					inspect caractere
					when '-' then
						chaine.add_last( caractere )
						etat := etat_commentaire_apres_tiret_tiret
					else
						produire_commentaire
						traiter_etat_commentaire
					end

				when etat_commentaire_apres_tiret_tiret then
					inspect caractere
					when '>' then
						chaine.add_last( caractere )
						produire_commentaire
						etat := etat_initial
					else
						produire_commentaire
						traiter_etat_commentaire
					end

				else
					-- cas non géré

					retenir_erreur( once "lexer is buggy!" )
				end
			end

			-- gestion de l'erreur d'analyse

			if erreur then
				listage := void
				chaine.clear_count
				ligne.clear_count
			end

			check
				chaine.is_empty
				ligne.is_empty
			end
		end

feature {}

	etat : INTEGER
			-- état courant de l'automate de reconnaissance de lexèmes

	etat_initial : INTEGER is 0
			-- aucun contexte

	etat_code : INTEGER is 10

	etat_apres_chevron_ouvrant : INTEGER is unique
	etat_apres_chevron_ouvrant_exclamation : INTEGER is unique
	etat_apres_chevron_ouvrant_exclamation_tiret : INTEGER is unique

	etat_commentaire : INTEGER is 100

	etat_commentaire_apres_tiret : INTEGER is unique
	etat_commentaire_apres_tiret_tiret : INTEGER is unique

	etat_final : INTEGER is -1
			-- état puits

	marqueur_chaine : CHARACTER

feature {}

	traiter_etat_initial is
			-- aucun préfixe
		do
			inspect caractere
			when '<' then
				chaine.add_last( caractere )
				etat := etat_apres_chevron_ouvrant
			when ' ', '%F', '%R', '%T' then
				-- les séparateurs ne sont pas mémorisés
				etat := etat_initial
			when '%N' then
				produire_ligne
				etat := etat_initial
			when '%U' then
				-- fin de fichier
				produire_ligne
				etat := etat_final
			else
				chaine.add_last( caractere )
				etat := etat_code
			end
		end

	traiter_etat_commentaire is
		-- commentaire multi-ligne
		do
			inspect caractere
			when '-' then
				produire_commentaire
				chaine.add_last( caractere )
				etat := etat_commentaire_apres_tiret
			when '%N' then
				produire_commentaire
				produire_ligne
				etat := etat_commentaire
			when '%U' then
				retenir_erreur( once "incomplete comment" )
			else
				chaine.add_last( caractere )
				etat := etat_commentaire
			end
		end

feature {}

	retenir_erreur( p_message : STRING ) is
		do
			precursor( p_message )
			etat := etat_final
		end

end
