indexing

	auteur : "seventh"
	license : "GPL 3.0"
	reference : "MySQL 5.0 reference manual, http://dev.mysql.com/doc/refman/5.0/fr/language-structure.html"

class

	LUAT_ANALYSEUR_SQL

		--
		-- Analyseur syntaxique du langage SQL
		--

inherit

	LUAT_ANALYSEUR

creation

	fabriquer

feature

	langage : STRING is "sql"

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

				when etat_apres_chiffre then
					inspect caractere
					when '0' .. '9' then
						chaine.add_last( caractere )
					else
						produire_code
						traiter_etat_initial
					end

				when etat_apres_lettre then
					inspect caractere
					when '0' .. '9', 'A' .. 'Z', 'a' .. 'z', '$', '_', '.' then
						chaine.add_last( caractere )
					else
						produire_code
						traiter_etat_initial
					end

				when etat_apres_arobase then
					-- variable utilisateur
					inspect caractere
					when '@' then
						chaine.add_last( caractere )
					when '0'.. '9', 'A' .. 'Z', 'a' .. 'z', '$', '_', '.' then
						chaine.add_last( caractere )
						etat := etat_apres_lettre
					else
						produire_code
						traiter_etat_initial
					end

				when etat_apres_deux_points then
					inspect caractere
					when '=' then
						chaine.add_last( caractere )
						produire_code
						etat := etat_initial
					else
						produire_code
						traiter_etat_initial
					end

				when etat_apres_et_commercial then
					inspect caractere
					when '&' then
						chaine.add_last( caractere )
						produire_code
						etat := etat_initial
					else
						produire_code
						traiter_etat_initial
					end

				when etat_apres_barre_verticale then
					inspect caractere
					when '|' then
						chaine.add_last( caractere )
						produire_code
						etat := etat_initial
					else
						produire_code
						traiter_etat_initial
					end

				when etat_apres_chevron_ouvrant then
					inspect caractere
					when '=' then
						chaine.add_last( caractere )
						etat := etat_apres_chevron_ouvrant_egal
					when '<', '>' then
						chaine.add_last( caractere )
						produire_code
						etat := etat_initial
					else
						produire_code
						traiter_etat_initial
					end

				when etat_apres_chevron_fermant then
					inspect caractere
					when '>', '=' then
						chaine.add_last( caractere )
						produire_code
						etat := etat_initial
					else
						produire_code
						traiter_etat_initial
					end

				when etat_apres_exclamation then
					inspect caractere
					when '=' then
						chaine.add_last( caractere )
						produire_code
						etat := etat_initial
					else
						produire_code
						traiter_etat_initial
					end

				when etat_apres_chevron_ouvrant_egal then
					inspect caractere
					when '>' then
						chaine.add_last( caractere )
						produire_code
						etat := etat_initial
					else
						produire_code
						traiter_etat_initial
					end

				when etat_apres_tiret then
					if caractere = '-' then
						chaine.add_last( caractere )
						etat := etat_apres_double_tiret
					else
						produire_code
						traiter_etat_initial
					end

				when etat_apres_double_tiret then
					inspect caractere
					when ' ' then
						chaine.add_last( caractere )
						etat := etat_apres_marque_commentaire_monoligne
					else
						produire_code
						traiter_etat_initial
					end

				when etat_apres_marque_commentaire_monoligne then
					inspect caractere
					when '%U' then
						produire_commentaire
						produire_ligne
						etat := etat_final
					when '%N' then
						produire_commentaire
						produire_ligne
						etat := etat_initial
					else
						chaine.add_last( caractere )
					end

				when etat_apres_barre_oblique then
					inspect caractere
					when '*' then
						chaine.add_last( caractere )
						etat := etat_dans_commentaire_multiligne
					else
						produire_code
						traiter_etat_initial
					end

				when etat_dans_commentaire_multiligne then
					inspect caractere
					when '*' then
						chaine.add_last( caractere )
						etat := etat_dans_commentaire_multiligne_apres_etoile
					when '%N' then
						produire_commentaire
						produire_ligne
					when '%U' then
						retenir_erreur( once "incomplete multiline comment" )
					else
						chaine.add_last( caractere )
					end

				when etat_dans_commentaire_multiligne_apres_etoile then
					inspect caractere
					when '/' then
						chaine.add_last( caractere )
						produire_commentaire
						etat := etat_initial
					when '%N' then
						produire_commentaire
						produire_ligne
						etat := etat_dans_commentaire_multiligne
					when '%U' then
						retenir_erreur( once "incomplete multiline comment" )
					when '*' then
						chaine.add_last( caractere )
					else
						chaine.add_last( caractere )
						etat := etat_dans_commentaire_multiligne
					end

					--
					-- Chaîne de caractères
					--

				when etat_dans_chaine then
					if caractere = marqueur_chaine then
						chaine.add_last( caractere )
						etat := etat_dans_chaine_apres_marqueur
					elseif caractere = '\' then
						chaine.add_last( caractere )
						etat := etat_dans_chaine_apres_barre_oblique
					elseif caractere = '%U' then
						retenir_erreur( once "incomplete string constant" )
					else
						chaine.add_last( caractere )
					end

				when etat_dans_chaine_apres_barre_oblique then
					inspect caractere
					when '%U' then
						retenir_erreur( once "incomplete string constant" )
					else
						chaine.add_last( caractere )
						etat := etat_dans_chaine
					end

				when etat_dans_chaine_apres_marqueur then
					if caractere = marqueur_chaine then
						chaine.add_last( caractere )
						etat := etat_dans_chaine
					else
						produire_code
						traiter_etat_initial
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

	etat_apres_chiffre : INTEGER is unique
	etat_apres_lettre : INTEGER is unique
	etat_apres_marque_commentaire_monoligne : INTEGER is unique

	etat_apres_arobase : INTEGER is unique
	etat_apres_barre_oblique : INTEGER is unique
	etat_apres_barre_verticale : INTEGER is unique
	etat_apres_chevron_ouvrant : INTEGER is unique
	etat_apres_chevron_ouvrant_egal : INTEGER is unique
	etat_apres_chevron_fermant : INTEGER is unique
	etat_apres_deux_points : INTEGER is unique
	etat_apres_diese : INTEGER is unique
	etat_apres_et_commercial : INTEGER is unique
	etat_apres_exclamation : INTEGER is unique
	etat_apres_comparateur : INTEGER is unique
	etat_apres_tiret : INTEGER is unique
	etat_apres_double_tiret : INTEGER is unique

	etat_dans_chaine : INTEGER is unique
	etat_dans_chaine_apres_barre_oblique : INTEGER is unique
	etat_dans_chaine_apres_marqueur : INTEGER is unique

	etat_dans_commentaire_multiligne : INTEGER is unique
	etat_dans_commentaire_multiligne_apres_etoile : INTEGER is unique

	marqueur_chaine : CHARACTER

feature {}

	traiter_etat_initial is
			-- aucun préfixe
		do
			inspect caractere
			when '0' .. '9' then
				chaine.add_last( caractere )
				etat := etat_apres_chiffre
			when 'A' .. 'Z', 'a' .. 'z' then
				chaine.add_last( caractere )
				etat := etat_apres_lettre
			when ',', '(', ')', ';', '=', '.', '*', '+', '%%', '^', '~' then
				chaine.add_last( caractere )
				produire_code
				etat := etat_initial
			when '|' then
				chaine.add_last( caractere )
				etat := etat_apres_barre_verticale
			when '_' then
				chaine.add_last( caractere )
				etat := etat_apres_lettre
			when '<' then
				chaine.add_last( caractere )
				etat := etat_apres_chevron_ouvrant
			when '>' then
				chaine.add_last( caractere )
				etat := etat_apres_chevron_fermant
			when '!' then
				chaine.add_last( caractere )
				etat := etat_apres_exclamation
			when ':' then
				chaine.add_last( caractere )
				etat := etat_apres_deux_points
			when '@' then
				chaine.add_last( caractere )
				etat := etat_apres_arobase
			when '&' then
				chaine.add_last( caractere )
				etat := etat_apres_et_commercial
			when '/' then
				chaine.add_last( caractere )
				etat := etat_apres_barre_oblique
			when '-' then
				chaine.add_last( caractere )
				etat := etat_apres_tiret
			when '#' then
				chaine.add_last( caractere )
				etat := etat_apres_marque_commentaire_monoligne
			when '%'', '%"', '`' then
				chaine.add_last( caractere )
				marqueur_chaine := caractere
				etat := etat_dans_chaine
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
				retenir_erreur( once "unauthorized character" )
			end
		end

end
