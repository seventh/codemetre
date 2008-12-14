indexing

	auteur : "seventh"
	license : "GPL 3.0"
	reference : "Ada 2005 reference manual, http://www.adaic.com/standards/05rm/html/RM-P.html"

class

	LUAT_ANALYSEUR_ADA

		--
		-- Analyseur syntaxique du langage ADA
		--

inherit

	LUAT_ANALYSEUR
		redefine
			gerer_erreur
		end

creation

	fabriquer

feature

	langage : STRING is "Ada"

feature {LUAT_ANALYSEUR}

	analyser is
		local
			sauvegarde : CHARACTER
			autoriser_lecture : BOOLEAN
		do
			check
				chaine.is_empty
				ligne.is_empty
			end

			indice_ligne := 1
			erreur := false
			message_erreur := once ""
			autoriser_lecture := true

			from etat := etat_initial
			until etat = etat_final
			loop
				if autoriser_lecture then
					fichier.avancer
				else
					autoriser_lecture := true
				end

				inspect etat
				when etat_final then
					-- aucun traitement

				when etat_initial then
					traiter_etat_initial( caractere )

				when etat_apres_lettre then
					inspect caractere
					when '0' .. '9', 'A' .. 'Z', 'a' .. 'z' then
						chaine.add_last( caractere )
					when '_' then
						chaine.add_last( caractere )
						etat := etat_apres_souligne_dans_identifiant
					else
						produire_code
						traiter_etat_initial( caractere )
					end

				when etat_apres_souligne_dans_identifiant then
					inspect caractere
					when '0' .. '9', 'A' .. 'Z', 'a' .. 'z' then
						chaine.add_last( caractere )
						etat := etat_apres_lettre
					else
						gerer_erreur( once "incomplete identifier" )
					end

				when etat_apres_chiffre then
					inspect caractere
					when '0' .. '9' then
						chaine.add_last( caractere )
					when '_' then
						chaine.add_last( caractere )
						etat := etat_apres_souligne_dans_entier
					when '#', ':' then
						chaine.add_last( caractere )
						etat := etat_apres_base_dans_litteral_numerique
					when '.' then
						chaine.add_last( caractere )
						etat := etat_apres_separateur_dans_litteral_numerique
					when 'e', 'E' then
						chaine.add_last( caractere )
						etat := etat_apres_exposant
					else
						produire_code
						traiter_etat_initial( caractere )
					end

				when etat_apres_souligne_dans_entier then
					if caractere.in_range( '0', '9' ) then
						chaine.add_last( caractere )
						etat := etat_apres_chiffre
					else
						gerer_erreur( once "incomplete integer constant" )
					end

				when etat_apres_base_dans_litteral_numerique then
					inspect caractere
					when '0' .. '9', 'A' .. 'F', 'a' .. 'f' then
						chaine.add_last( caractere )
						etat := etat_apres_chiffre_dans_litteral_numerique_base
					else
						gerer_erreur( once "forbidden character in based integer constant" )
					end

				when etat_apres_chiffre_dans_litteral_numerique_base then
					-- nombre entier basé après au moins un chiffre de la
					-- valeur dans la base

					inspect caractere
					when '0' .. '9', 'a' .. 'f', 'A' .. 'F' then
						chaine.add_last( caractere )
					when '_' then
						chaine.add_last( caractere )
						etat := etat_apres_base_dans_litteral_numerique
					when '.' then
						chaine.add_last( caractere )
						etat := etat_apres_separateur_dans_litteral_numerique_base
					when '#', ':' then
						chaine.add_last( caractere )
						etat := etat_apres_valeur_dans_litteral_numerique_base
					else
						gerer_erreur( once "wrong value in based integer constant" )
					end

				when etat_apres_separateur_dans_litteral_numerique_base then
					-- après séparateur décimal dans entier basé

					inspect caractere
					when '0' .. '9', 'A' .. 'F', 'a' .. 'f' then
						chaine.add_last( caractere )
						etat := etat_apres_chiffre_decimal_dans_litteral_numerique_base
					else
						gerer_erreur( once "forbidden character in decimal part of based integer constant" )
					end

				when etat_apres_chiffre_decimal_dans_litteral_numerique_base then
					-- après au moins un chiffre de la partie décimale
					-- d'un entier basé

					inspect caractere
					when '0' .. '9', 'A' .. 'F', 'a' .. 'f' then
						chaine.add_last( caractere )
					when '_' then
						chaine.add_last( caractere )
						etat := etat_apres_separateur_dans_litteral_numerique_base
					when '#', ':' then
						chaine.add_last( caractere )
						etat := etat_apres_valeur_dans_litteral_numerique_base
					else
						gerer_erreur( once "forbidden character in decimal part of based integer constant" )
					end

				when etat_apres_valeur_dans_litteral_numerique_base then
					-- fin de la partie basée d'un entier basé

					inspect caractere
					when 'E', 'e' then
						chaine.add_last( caractere )
						etat := etat_apres_exposant
					else
						produire_code
						traiter_etat_initial( caractere )
					end

				when etat_apres_exposant then
					-- début de l'exposant d'un nombre réel

					inspect caractere
					when '0' .. '9' then
						chaine.add_last( caractere )
						etat := etat_apres_chiffre_dans_exposant
					when '+', '-' then
						chaine.add_last( caractere )
						etat := etat_apres_separateur_dans_exposant
					else
						gerer_erreur( once "incomplete exponent in integer constant" )
					end

				when etat_apres_chiffre_dans_exposant then
					-- après au moins un chiffre de l'exposant

					if caractere = '_' then
						chaine.add_last( caractere )
						etat := etat_apres_separateur_dans_exposant
					else
						produire_code
						traiter_etat_initial( caractere )
					end

				when etat_apres_separateur_dans_exposant then
					-- dans l'exposant

					if caractere.in_range( '0', '9' ) then
						chaine.add_last( caractere )
						etat := etat_apres_chiffre_dans_exposant
					else
						gerer_erreur( once "wrong exponent in integer constant" )
					end

				when etat_apres_separateur_dans_litteral_numerique then
					-- après le séparateur décimal

					inspect caractere
					when '0' .. '9' then
						chaine.add_last( caractere )
						etat := etat_apres_valeur_entiere_dans_litteral_numerique
					when '.' then
						chaine.remove_last
						produire_code
						chaine.copy( once ".." )
						produire_code
						etat := etat_initial
					else
						gerer_erreur( once "wrong decimal part in integer constant" )
					end

				when etat_apres_valeur_entiere_dans_litteral_numerique then
					-- après au moins un chiffre de la partie décimale

					inspect caractere
					when '0' .. '9' then
						chaine.add_last( caractere )
					when '_' then
						chaine.add_last( caractere )
						etat := etat_apres_souligne_dans_partie_decimale
					when 'E', 'e' then
						chaine.add_last( caractere )
						etat := etat_apres_exposant
					else
						produire_code
						traiter_etat_initial( caractere )
					end

				when etat_apres_souligne_dans_partie_decimale then
					inspect caractere
					when '0' .. '9' then
						chaine.add_last( caractere )
						etat := etat_apres_valeur_entiere_dans_litteral_numerique
					else
						gerer_erreur( once "forbidden character in decimal part of integer constant" )
					end

				when etat_apres_apostrophe then
					if caractere >= ' ' then
						chaine.add_last( caractere )
						etat := etat_apres_apostrophe_caractere
					else
						chaine.add_last( '%'' )
						produire_code
						traiter_etat_initial( caractere )
					end

				when etat_apres_apostrophe_caractere then
					inspect caractere
					when '%U' then
						sauvegarde := chaine.last
						chaine.remove_last
						produire_code
						chaine.add_last( sauvegarde )
						produire_code
						etat := etat_final
					when '%'' then
						chaine.add_last( caractere )
						produire_code
						etat := etat_initial
					else
						sauvegarde := chaine.last
						chaine.remove_last
						produire_code

						traiter_etat_initial( sauvegarde )
						autoriser_lecture := false
					end

				when etat_apres_guillemets then
					inspect caractere
					when '%U' then
						gerer_erreur( once "incomplete string constant" )
					when '%"' then
						chaine.add_last( caractere )
						etat := etat_apres_guillemets_dans_litteral_chaine
					else
						chaine.add_last( caractere )
					end

				when etat_apres_guillemets_dans_litteral_chaine then
					if caractere = '%"' then
						chaine.add_last( caractere )
						etat := etat_apres_guillemets
					else
						produire_code
						traiter_etat_initial( caractere )
					end

				when etat_apres_pourcentage then
					inspect caractere
					when ' ' .. '!', '#' .. '$', '&' .. '~' then
						chaine.add_last( caractere )
					when '%%' then
						chaine.add_last( caractere )
						etat := etat_apres_pourcentage_dans_litteral_chaine
					else
						gerer_erreur( once "forbidden character in character constant" )
					end

				when etat_apres_pourcentage_dans_litteral_chaine then
					if caractere = '%%' then
						chaine.add_last( caractere )
						etat := etat_apres_pourcentage
					else
						produire_code
						traiter_etat_initial( caractere )
					end

				when etat_apres_point then
					if caractere = '.' then
						chaine.add_last( caractere )
						produire_code
						etat := etat_initial
					else
						produire_code
						traiter_etat_initial( caractere )
					end

				when etat_apres_barre_oblique then
					if caractere = '=' then
						chaine.add_last( caractere )
						produire_code
						etat := etat_initial
					else
						produire_code
						traiter_etat_initial( caractere )
					end

				when etat_apres_chevron_ouvrant then
					inspect caractere
					when '<', '=', '>' then
						chaine.add_last( caractere )
						produire_code
						etat := etat_initial
					else
						produire_code
						traiter_etat_initial( caractere )
					end

				when etat_apres_chevron_fermant then
					inspect caractere
					when '=', '>' then
						chaine.add_last( caractere )
						produire_code
						etat := etat_initial
					else
						produire_code
						traiter_etat_initial( caractere )
					end

				when etat_apres_deux_points then
					if caractere = '=' then
						chaine.add_last( caractere )
						produire_code
						etat := etat_initial
					else
						produire_code
						traiter_etat_initial( caractere )
					end

				when etat_apres_etoile then
					if caractere = '*' then
						chaine.add_last( caractere )
						produire_code
						etat := etat_initial
					else
						produire_code
						traiter_etat_initial( caractere )
					end

				when etat_apres_egal then
					if caractere = '>' then
						chaine.add_last( caractere )
						produire_code
						etat := etat_initial
					else
						produire_code
						traiter_etat_initial( caractere )
					end

				when etat_apres_tiret then
					if caractere = '-' then
						chaine.add_last( caractere )
						etat := etat_apres_double_tiret
					else
						produire_code
						traiter_etat_initial( caractere )
					end

				when etat_apres_double_tiret then
					if caractere /= '%N' then
						chaine.add_last( caractere )
					else
						if not chaine.is_empty then
							produire_commentaire
						end
						produire_ligne
						etat := etat_initial
					end

				else
					-- cas non géré

					gerer_erreur( once "lexer is buggy!" )
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

	etat_apres_lettre : INTEGER is unique
	etat_apres_souligne_dans_identifiant : INTEGER is unique

	etat_apres_chiffre : INTEGER is unique
	etat_apres_souligne_dans_entier : INTEGER is unique
	etat_apres_base_dans_litteral_numerique : INTEGER is unique
	etat_apres_chiffre_dans_litteral_numerique_base : INTEGER is unique
	etat_apres_separateur_dans_litteral_numerique_base : INTEGER is unique
	etat_apres_chiffre_decimal_dans_litteral_numerique_base : INTEGER is unique
	etat_apres_exposant : INTEGER is unique
	etat_apres_valeur_dans_litteral_numerique_base : INTEGER is unique
	etat_apres_chiffre_dans_exposant : INTEGER is unique
	etat_apres_separateur_dans_exposant : INTEGER is unique
	etat_apres_separateur_dans_litteral_numerique : INTEGER is unique
	etat_apres_valeur_entiere_dans_litteral_numerique : INTEGER is unique
	etat_apres_souligne_dans_partie_decimale : INTEGER is unique

	etat_apres_apostrophe : INTEGER is unique
	etat_apres_apostrophe_caractere : INTEGER is unique

	etat_apres_guillemets : INTEGER is unique
	etat_apres_guillemets_dans_litteral_chaine : INTEGER is unique

	etat_apres_pourcentage : INTEGER is unique
	etat_apres_pourcentage_dans_litteral_chaine : INTEGER is unique

	etat_apres_point : INTEGER is unique
	etat_apres_barre_oblique : INTEGER is unique
	etat_apres_chevron_ouvrant : INTEGER is unique
	etat_apres_chevron_fermant : INTEGER is unique
	etat_apres_deux_points : INTEGER is unique
	etat_apres_etoile : INTEGER is unique
	etat_apres_egal : INTEGER is unique

	etat_apres_tiret : INTEGER is unique
	etat_apres_double_tiret : INTEGER is unique

	etat_final : INTEGER is -1
			-- état puits

feature {}

	traiter_etat_initial( p_caractere : CHARACTER ) is
			-- aucun préfixe
		do
			inspect p_caractere
			when '0' .. '9' then
				chaine.add_last( p_caractere )
				etat := etat_apres_chiffre
			when 'A' .. 'Z', 'a' .. 'z' then
				chaine.add_last( p_caractere )
				etat := etat_apres_lettre
			when '%'' then
				chaine.add_last( p_caractere )
				etat := etat_apres_apostrophe
			when '%"' then
				chaine.add_last( p_caractere )
				etat := etat_apres_guillemets
			when '%%' then
				chaine.add_last( p_caractere )
				etat := etat_apres_pourcentage
			when '.' then
				chaine.add_last( p_caractere )
				etat := etat_apres_point
			when '/' then
				chaine.add_last( p_caractere )
				etat := etat_apres_barre_oblique
			when '<' then
				chaine.add_last( p_caractere )
				etat := etat_apres_chevron_ouvrant
			when '>' then
				chaine.add_last( p_caractere )
				etat := etat_apres_chevron_fermant
			when ':' then
				chaine.add_last( p_caractere )
				etat := etat_apres_deux_points
			when '*' then
				chaine.add_last( p_caractere )
				etat := etat_apres_etoile
			when '-' then
				chaine.add_last( p_caractere )
				etat := etat_apres_tiret
			when '=' then
				chaine.add_last( p_caractere )
				etat := etat_apres_egal
			when '&', '(', ')', '+', ',', ';', '|', '!' then
				chaine.add_last( p_caractere )
				produire_code
				etat := etat_initial
			when ' ', '%F', '%R', '%T' then
				-- les séparateurs ne sont pas mémorisés
				etat := etat_initial
			when '%N' then
				produire_ligne
				etat := etat_initial
			when '%U' then
				-- fin de fichier
				etat := etat_final
			else
				gerer_erreur( once "forbidden character" )
			end
		end

feature {}

	gerer_erreur( p_message : STRING ) is
		do
			precursor( p_message )
			etat := etat_final
		end

end
