indexing

	auteur : "seventh"
	license : "GPL 3.0"
	reference : "C ISO/IEC 9899:1999"
	reference : "C++ ISO/IEC 14882:2003"

class

	LUAT_ANALYSEUR_FAMILLE_C

		--
		-- Analyseur syntaxique des langages de la famille C : C99, C++03
		--

inherit

	LUAT_ANALYSEUR
		rename
			fabriquer as fabriquer_analyseur
		redefine
			retenir_erreur
		end

creation

	fabriquer

feature {}

	fabriquer( p_langage : STRING ) is
			-- constructeur
		do
			fabriquer_analyseur
			langage := p_langage
		ensure
			langage_ok : langage = p_langage
		end

feature

	langage : STRING

feature {LUAT_ANALYSEUR}

	analyser is
		local
			sauvegarde : STRING
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

				when etat_lexeme_identifiant then
					traiter_etat_lexeme_identifiant

				when etat_apres_apostrophe then
					traiter_etat_apres_apostrophe

				when etat_apres_guillemets then
					traiter_etat_apres_guillemets

				when etat_apres_chiffre_non_nul then
					inspect caractere
					when '0' .. '9' then
						chaine.add_last( caractere )
					when 'l', 'L' then
						chaine.add_last( caractere )
						etat := etat_constante_litterale_entiere_longue
					when 'u', 'U' then
						chaine.add_last( caractere )
						etat := etat_constante_litterale_entiere_non_signee
					when '.' then
						chaine.add_last( caractere )
						etat := etat_constante_litterale_reelle_apres_separateur
					when 'e', 'E' then
						chaine.add_last( caractere )
						etat := etat_constante_litterale_reelle_apres_exposant
					else
						produire_code
						traiter_etat_initial
					end

				when etat_apres_point_interrogation then
					if caractere = '?' then
						chaine.add_last( caractere )
						etat := etat_apres_double_point_interrogation
					else
						produire_code
						traiter_etat_initial
					end

				when etat_apres_pourcent then
					inspect caractere
					when '>', '=' then
						chaine.add_last( caractere )
						produire_code
						etat := etat_initial
					when ':' then
						chaine.add_last( caractere )
						etat := etat_apres_pourcent_deux_points
					else
						produire_code
						traiter_etat_initial
					end

				when etat_apres_chevron_ouvrant then
					inspect caractere
					when '%%', ':', '=' then
						chaine.add_last( caractere )
						produire_code
						etat := etat_initial
					when '<' then
						chaine.add_last( caractere )
						etat := etat_apres_egal_ou_chapeau_ou_double_chevron
					else
						produire_code
						traiter_etat_initial
					end

				when etat_apres_chevron_fermant then
					inspect caractere
					when '=' then
						chaine.add_last( caractere )
						produire_code
						etat := etat_initial
					when '>' then
						chaine.add_last( caractere )
						etat := etat_apres_egal_ou_chapeau_ou_double_chevron
					else
						produire_code
						traiter_etat_initial
					end

				when etat_apres_deux_points then
					inspect caractere
					when '>', ':' then
						chaine.add_last( caractere )
						produire_code
						etat := etat_initial
					else
						produire_code
						traiter_etat_initial
					end

				when etat_apres_point_exclamation then
					if caractere = '=' then
						chaine.add_last( caractere )
						produire_code
						etat := etat_initial
					else
						produire_code
						traiter_etat_initial
					end

				when etat_apres_diese then
					inspect caractere
					when '#' then
						chaine.add_last( caractere )
						produire_code
						etat := etat_initial
					when 'w' then
						chaine.add_last( caractere )
						etat := etat_apres_diese_w
					else
						produire_code
						traiter_etat_initial
					end

				when etat_apres_esperluette then
					inspect caractere
					when '=', '&' then
						chaine.add_last( caractere )
						produire_code
						etat := etat_initial
					else
						produire_code
						traiter_etat_initial
					end

				when etat_apres_etoile then
					if caractere = '=' then
						chaine.add_last( caractere )
						produire_code
						etat := etat_initial
					else
						produire_code
						traiter_etat_initial
					end

				when etat_apres_plus then
					inspect caractere
					when '=', '+' then
						chaine.add_last( caractere )
						produire_code
						etat := etat_initial
					else
						produire_code
						traiter_etat_initial
					end

				when etat_apres_barre_verticale then
					inspect caractere
					when '=', '|' then
						chaine.add_last( caractere )
						produire_code
						etat := etat_initial
					else
						produire_code
						traiter_etat_initial
					end

				when etat_apres_tiret then
					inspect caractere
					when '=', '-' then
						chaine.add_last( caractere )
						produire_code
						etat := etat_initial
					when '>' then
						chaine.add_last( caractere )
						etat := etat_apres_tiret_chevron
					else
						produire_code
						traiter_etat_initial
					end

				when etat_apres_point then
					inspect caractere
					when '*' then
						chaine.add_last( caractere )
						produire_code
						etat := etat_initial
					when '.' then
						chaine.add_last( caractere )
						etat := etat_apres_double_point
					when '0' .. '9' then
						chaine.add_last( caractere )
						etat := etat_constante_litterale_reelle_apres_separateur
					else
						produire_code
						traiter_etat_initial
					end

				when etat_apres_slash then
					inspect caractere
					when '=' then
						chaine.add_last( caractere )
						produire_code
						etat := etat_initial
					when '/' then
						chaine.add_last( caractere )
						etat := etat_apres_double_slash
					when '*' then
						chaine.add_last( caractere )
						etat := etat_commentaire_multiligne
					else
						produire_code
						traiter_etat_initial
					end

				when etat_apres_egal_ou_chapeau_ou_double_chevron then
					-- lexème débutant par "=", "^", "<<" ou ">>"

					if caractere = '=' then
						chaine.add_last( caractere )
						produire_code
						etat := etat_initial
					else
						produire_code
						traiter_etat_initial
					end

				when etat_exception_dans_constante_chaine then
					-- après un anti-slash dans une chaîne isolée par des
					-- guillemets

					inspect caractere
					when '%U' then
						retenir_erreur( once "incomplete string constant" )
					when 'u', 'U', 'x', 'X' then
						chaine.add_last( caractere )
						etat := etat_notation_hexadecimale_dans_constante_chaine
					when '0' .. '7' then
						chaine.add_last( caractere )
						etat := etat_notation_octale_dans_constante_chaine
					when ' ', '%F', '%R', '%T' then
						etat := etat_exception_et_blanc_dans_constante_chaine
					when '%N' then
						produire_code
						produire_ligne
						etat := etat_apres_guillemets
					else
						chaine.add_last( caractere )
						etat := etat_apres_guillemets
					end

				when etat_apres_double_slash then
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

				when etat_apres_zero then
					inspect caractere
					when 'x', 'X' then
						chaine.add_last( caractere )
						etat := etat_lexeme_debutant_par_zero_x
					when '.' then
						chaine.add_last( caractere )
						etat := etat_constante_litterale_reelle_apres_separateur
					when 'e', 'E' then
						chaine.add_last( caractere )
						etat := etat_constante_litterale_reelle_apres_exposant
					when '0' .. '7' then
						chaine.add_last( caractere )
						etat := etat_notation_octale
					else
						produire_code
						traiter_etat_initial
					end

				when etat_lexeme_debutant_par_zero_x then
					inspect caractere
					when '0' .. '9', 'a' .. 'f', 'A' .. 'F' then
						chaine.add_last( caractere )
					when 'l', 'L' then
						chaine.add_last( caractere )
						etat := etat_constante_litterale_entiere_longue
					when 'u', 'U' then
						chaine.add_last( caractere )
						etat := etat_constante_litterale_entiere_non_signee
					else
						produire_code
						traiter_etat_initial
					end


				when etat_notation_octale then
					inspect caractere
					when '0' .. '7' then
						chaine.add_last( caractere )
					when 'u', 'U' then
						chaine.add_last( caractere )
						etat := etat_constante_litterale_entiere_non_signee
					when 'l', 'L' then
						chaine.add_last( caractere )
						etat := etat_constante_litterale_entiere_longue
					else
						produire_code
						traiter_etat_initial
					end

				when etat_constante_litterale_entiere_longue then
					inspect caractere
					when 'u', 'U' then
						chaine.add_last( caractere )
						produire_code
						etat := etat_initial
					else
						produire_code
						traiter_etat_initial
					end

				when etat_constante_litterale_entiere_non_signee then
					inspect caractere
					when 'l', 'L' then
						chaine.add_last( caractere )
						produire_code
						etat := etat_initial
					else
						produire_code
						traiter_etat_initial
					end

				when etat_constante_litterale_reelle_apres_separateur then
					-- constante littérale réelle après le séparateur
					-- décimal

					inspect caractere
					when '0' .. '9' then
						chaine.add_last( caractere )
					when 'e', 'E' then
						chaine.add_last( caractere )
						etat := etat_constante_litterale_reelle_apres_exposant
					when 'f', 'F', 'l', 'L' then
						chaine.add_last( caractere )
						produire_code
						etat := etat_initial
					else
						produire_code
						traiter_etat_initial
					end

				when etat_constante_litterale_reelle_apres_exposant then
					-- constante littérale réelle après mention d'un
					-- exposant par 'e' ou 'E'

					inspect caractere
					when '0' .. '9' then
						chaine.add_last( caractere )
						etat := etat_constante_litterale_reelle_apres_valeur_exposant
					when '+', '-' then
						chaine.add_last( caractere )
						etat := etat_constante_litterale_reelle_apres_signe_exposant
					else
						retenir_erreur( once "forgotten exponent in numerical constant" )
					end

				when etat_constante_litterale_reelle_apres_signe_exposant then
					-- constante littérale réelle après mention du signe
					-- de l'exposant

					if caractere.in_range( '0', '9' ) then
						chaine.add_last( caractere )
						etat := etat_constante_litterale_reelle_apres_valeur_exposant
					else
						retenir_erreur( once "forgotten exponent in numerical constant" )
					end

				when etat_constante_litterale_reelle_apres_valeur_exposant then
					-- constante littérale réelle après mention d'au moins
					-- un chiffre de l'exposant

					inspect caractere
					when '0' .. '9' then
						chaine.add_last( caractere )
					when 'f', 'F', 'l', 'L' then
						chaine.add_last( caractere )
						produire_code
						etat := etat_initial
					else
						produire_code
						traiter_etat_initial
					end

				when etat_apres_tiret_chevron then
					if caractere = '*' then
						chaine.add_last( caractere )
						produire_code
						etat := etat_initial
					else
						produire_code
						traiter_etat_initial
					end

				when etat_apres_pourcent_deux_points then
					-- lexème débutant par "%:"

					if caractere = '%%' then
						chaine.add_last( caractere )
						etat := etat_apres_pourcent_deux_points_pourcent
					else
						produire_code
						etat := etat_initial
					end

				when etat_apres_pourcent_deux_points_pourcent then
					-- lexème débutant par "%:%"

					if caractere = ':' then
						chaine.add_last( caractere )
						produire_code
						etat := etat_initial
					else
						retenir_erreur( once "incomplete '%%:%%:' separator" )
					end

				when etat_apres_double_point_interrogation then
					inspect caractere
					when '!', '%'', '(', ')', '-', '/', '<', '=', '>' then
						chaine.add_last( caractere )
						produire_code
						etat := etat_initial
					else
						retenir_erreur( once "incomplete triglyph" )
					end

				when etat_exception_dans_constante_caractere then
					-- lexème débutant par une apostrophe, après le
					-- caractère d'exception

					inspect caractere
					when '%U' then
						retenir_erreur( once "incomplete character constant" )
					when 'u', 'U', 'x', 'X' then
						chaine.add_last( caractere )
						etat := etat_notation_hexadecimale_dans_constante_caractere
					when '0' .. '7' then
						chaine.add_last( caractere )
						etat := etat_notation_octale_dans_constante_caractere
					else
						chaine.add_last( caractere )
						etat := etat_apres_apostrophe
					end

				when etat_notation_hexadecimale_dans_constante_caractere then
					inspect caractere
					when '0' .. '9', 'a' .. 'f', 'A' .. 'F' then
						chaine.add_last( caractere )
					else
						traiter_etat_apres_apostrophe
					end

				when etat_notation_octale_dans_constante_caractere then
					-- caractère en notation octale dans une chaîne
					-- délimitée par des apostrophes

					if caractere.in_range( '0', '7' ) then
						chaine.add_last( caractere )
					else
						traiter_etat_apres_apostrophe
					end

				when etat_notation_hexadecimale_dans_constante_chaine then
					inspect caractere
					when '0' .. '9', 'a' .. 'f', 'A' .. 'F' then
						chaine.add_last( caractere )
					else
						traiter_etat_apres_guillemets
					end

				when etat_notation_octale_dans_constante_chaine then
					-- caractère en notation octale dans une chaîne
					-- délimitée par des guillemets

					if caractere.in_range( '0', '7' ) then
						chaine.add_last( caractere )
					else
						traiter_etat_apres_guillemets
					end

				when etat_exception_et_blanc_dans_constante_chaine then
					-- retour-chariot après un caractère d'exception dans
					-- une chaîne délimitée par des guillemets

					if caractere = '%N' then
						produire_code
						produire_ligne
						etat := etat_apres_guillemets
					elseif not ( caractere = ' '
									 or caractere = '%F'
									 or caractere = '%R'
									 or caractere = '%T' )
					 then
						retenir_erreur( once "non respected end-of-line marker in split string" )
					end

				when etat_commentaire_multiligne then
					-- commentaire multi-ligne

					traiter_commentaire_multiligne

				when etat_commentaire_multiligne_apres_etoile then
					if caractere = '/' then
						chaine.add_last( caractere )
						produire_commentaire
						etat := etat_initial
					else
						traiter_commentaire_multiligne
					end

				when etat_apres_double_point then
					if caractere = '.' then
						chaine.add_last( caractere )
						produire_code
						etat := etat_initial
					else
						retenir_erreur( once "incomplete ellipsis" )
					end

				when etat_apres_antislash then
					inspect caractere
					when ' ', '%T' then
					when '%N' then
						produire_code
						produire_ligne
						etat := etat_initial
					else
						retenir_erreur( once "non respected end-of-line marker" )
					end

				when etat_apres_diese_w then
					if caractere = 'a' then
						chaine.add_last( caractere )
						etat := etat_apres_diese_wa
					else
						sauvegarde := chaine.twin
						sauvegarde.remove_first

						chaine.clear_count
						chaine.add_last( '#' )
						produire_code

						chaine.copy( sauvegarde )
						traiter_etat_lexeme_identifiant
					end

				when etat_apres_diese_wa then
					if caractere = 'r' then
						chaine.add_last( caractere )
						etat := etat_apres_diese_war
					else
						sauvegarde := chaine.twin
						sauvegarde.remove_first

						chaine.clear_count
						chaine.add_last( '#' )
						produire_code

						chaine.copy( sauvegarde )
						traiter_etat_lexeme_identifiant
					end

				when etat_apres_diese_war then
					if caractere = 'n' then
						chaine.add_last( caractere )
						etat := etat_apres_diese_warn
					else
						sauvegarde := chaine.twin
						sauvegarde.remove_first

						chaine.clear_count
						chaine.add_last( '#' )
						produire_code

						chaine.copy( sauvegarde )
						traiter_etat_lexeme_identifiant
					end

				when etat_apres_diese_warn then
					if caractere = 'i' then
						chaine.add_last( caractere )
						etat := etat_apres_diese_warni
					else
						sauvegarde := chaine.twin
						sauvegarde.remove_first

						chaine.clear_count
						chaine.add_last( '#' )
						produire_code

						chaine.copy( sauvegarde )
						traiter_etat_lexeme_identifiant
					end

				when etat_apres_diese_warni then
					if caractere = 'n' then
						chaine.add_last( caractere )
						etat := etat_apres_diese_warnin
					else
						sauvegarde := chaine.twin
						sauvegarde.remove_first

						chaine.clear_count
						chaine.add_last( '#' )
						produire_code

						chaine.copy( sauvegarde )
						traiter_etat_lexeme_identifiant
					end

				when etat_apres_diese_warnin then
					if caractere = 'g' then
						chaine.add_last( caractere )
						produire_code
						etat := etat_apres_diese_warning
					else
						sauvegarde := chaine.twin
						sauvegarde.remove_first

						chaine.clear_count
						chaine.add_last( '#' )
						produire_code

						chaine.copy( sauvegarde )
						traiter_etat_lexeme_identifiant
					end

				when etat_apres_diese_warning then
					inspect caractere
					when '\' then
						chaine.add_last( caractere )
						etat := etat_apres_diese_warning_antislash
					when '%N' then
						produire_code
						produire_ligne
						etat := etat_initial
					else
						chaine.add_last( caractere )
					end

				when etat_apres_diese_warning_antislash then
					if caractere = '%N' then
						produire_code
						produire_ligne
						etat := etat_apres_diese_warning
					elseif not ( caractere = ' '
									 or caractere = '%F'
									 or caractere = '%R'
									 or caractere = '%T' )
					 then
						chaine.add_last( caractere )
						etat := etat_apres_diese_warning
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

	etat_apres_antislash : INTEGER is unique
	etat_apres_apostrophe : INTEGER is unique
	etat_apres_barre_verticale : INTEGER is unique
	etat_apres_chevron_fermant : INTEGER is unique
	etat_apres_chevron_ouvrant : INTEGER is unique
	etat_apres_chiffre_non_nul : INTEGER is unique
	etat_apres_deux_points : INTEGER is unique
	etat_apres_diese : INTEGER is unique
	etat_apres_diese_w : INTEGER is unique
	etat_apres_diese_wa : INTEGER is unique
	etat_apres_diese_war : INTEGER is unique
	etat_apres_diese_warn : INTEGER is unique
	etat_apres_diese_warni : INTEGER is unique
	etat_apres_diese_warnin : INTEGER is unique
	etat_apres_diese_warning : INTEGER is unique
	etat_apres_diese_warning_antislash : INTEGER is unique
	etat_apres_double_point : INTEGER is unique
	etat_apres_double_point_interrogation : INTEGER is unique
	etat_apres_double_slash : INTEGER is unique
	etat_apres_egal_ou_chapeau_ou_double_chevron : INTEGER is unique
	etat_apres_esperluette : INTEGER is unique
	etat_apres_etoile : INTEGER is unique
	etat_apres_guillemets : INTEGER is unique
	etat_apres_plus : INTEGER is unique
	etat_apres_point : INTEGER is unique
	etat_apres_point_exclamation : INTEGER is unique
	etat_apres_point_interrogation : INTEGER is unique
	etat_apres_pourcent : INTEGER is unique
	etat_apres_pourcent_deux_points : INTEGER is unique
	etat_apres_pourcent_deux_points_pourcent : INTEGER is unique
	etat_apres_slash : INTEGER is unique
	etat_apres_tiret : INTEGER is unique
	etat_apres_tiret_chevron : INTEGER is unique
	etat_apres_zero : INTEGER is unique
	etat_commentaire_multiligne : INTEGER is unique
	etat_commentaire_multiligne_apres_etoile : INTEGER is unique
	etat_constante_litterale_entiere_longue : INTEGER is unique
	etat_constante_litterale_entiere_non_signee : INTEGER is unique
	etat_constante_litterale_reelle_apres_exposant : INTEGER is unique
	etat_constante_litterale_reelle_apres_separateur : INTEGER is unique
	etat_constante_litterale_reelle_apres_signe_exposant : INTEGER is unique
	etat_constante_litterale_reelle_apres_valeur_exposant : INTEGER is unique
	etat_exception_dans_constante_caractere : INTEGER is unique
	etat_exception_dans_constante_chaine : INTEGER is unique
	etat_exception_et_blanc_dans_constante_chaine : INTEGER is unique
	etat_lexeme_debutant_par_zero_x : INTEGER is unique
	etat_lexeme_identifiant : INTEGER is unique
	etat_notation_hexadecimale_dans_constante_caractere : INTEGER is unique
	etat_notation_hexadecimale_dans_constante_chaine : INTEGER is unique
	etat_notation_octale : INTEGER is unique
	etat_notation_octale_dans_constante_caractere : INTEGER is unique
	etat_notation_octale_dans_constante_chaine : INTEGER is unique

	etat_final : INTEGER is -1
			-- état puits

feature {}

	traiter_etat_initial is
			-- aucun préfixe
		require
			chaine.is_empty
		do
			inspect caractere
			when 'a' .. 'z', 'A' .. 'Z', '_' then
				chaine.add_last( caractere )
				etat := etat_lexeme_identifiant
			when '1' .. '9' then
				chaine.add_last( caractere )
				etat := etat_apres_chiffre_non_nul
			when '%'' then
				chaine.add_last( caractere )
				etat := etat_apres_apostrophe
			when '%"' then
				chaine.add_last( caractere )
				etat := etat_apres_guillemets
			when '?' then
				chaine.add_last( caractere )
				etat := etat_apres_point_interrogation
			when '%%' then
				chaine.add_last( caractere )
				etat := etat_apres_pourcent
			when '<' then
				chaine.add_last( caractere )
				etat := etat_apres_chevron_ouvrant
			when '>' then
				chaine.add_last( caractere )
				etat := etat_apres_chevron_fermant
			when ':' then
				chaine.add_last( caractere )
				etat := etat_apres_deux_points
			when '!' then
				chaine.add_last( caractere )
				etat := etat_apres_point_exclamation
			when '#' then
				chaine.add_last( caractere )
				etat := etat_apres_diese
			when '&' then
				chaine.add_last( caractere )
				etat := etat_apres_esperluette
			when '*' then
				chaine.add_last( caractere )
				etat := etat_apres_etoile
			when '+' then
				chaine.add_last( caractere )
				etat := etat_apres_plus
			when '-' then
				chaine.add_last( caractere )
				etat := etat_apres_tiret
			when '.' then
				chaine.add_last( caractere )
				etat := etat_apres_point
			when '/' then
				chaine.add_last( caractere )
				etat := etat_apres_slash
			when '=', '^' then
				chaine.add_last( caractere )
				etat := etat_apres_egal_ou_chapeau_ou_double_chevron
			when '|' then
				chaine.add_last( caractere )
				etat := etat_apres_barre_verticale
			when '(', ')', ',', ';', '[', ']', '{', '}', '~' then
				chaine.add_last( caractere )
				produire_code
				etat := etat_initial
			when ' ', '%F', '%R', '%T' then
				-- les séparateurs ne sont pas mémorisés
				etat := etat_initial
			when '%N' then
				produire_ligne
				etat := etat_initial
			when '0' then
				chaine.add_last( caractere )
				etat := etat_apres_zero
			when '\' then
				chaine.add_last( caractere )
				etat := etat_apres_antislash
			when '%U' then
				-- fin de fichier
				if not chaine.is_empty then
					produire_code
				end
				produire_ligne
				etat := etat_final
			else
				retenir_erreur( once "unknown prefix" )
			end
		end

	traiter_etat_lexeme_identifiant is
			-- Attention : la prise en compte du caractère '$' ne
			-- fait pas partie du standard
		do
			inspect caractere
			when 'a' .. 'z', 'A' .. 'Z', '0' .. '9', '_', '$' then
				chaine.add_last( caractere )
				etat := etat_lexeme_identifiant
			else
				produire_code
				traiter_etat_initial
			end
		end

	traiter_etat_apres_apostrophe is
			-- lexème débutant par une apostrophe
		do
			inspect caractere
			when '%U' then
				retenir_erreur( once "incomplete character constant" )
			when '\' then
				chaine.add_last( caractere )
				etat := etat_exception_dans_constante_caractere
			when '%'' then
				chaine.add_last( caractere )
				produire_code
				etat := etat_initial
			when '%N' then
				retenir_erreur( once "end-of-line in character constant" )
			else
				chaine.add_last( caractere )
				etat := etat_apres_apostrophe
			end
		end

	traiter_etat_apres_guillemets is
			-- lexème débutant par des guillemets
		do
			inspect caractere
			when '%U' then
				retenir_erreur( once "incomplete string constant" )
			when '\' then
				chaine.add_last( caractere )
				etat := etat_exception_dans_constante_chaine
			when '%"' then
				chaine.add_last( caractere )
				produire_code
				etat := etat_initial
			when '%N' then
				retenir_erreur( once "end-of-line in string constant" )
			else
				chaine.add_last( caractere )
				etat := etat_apres_guillemets
			end
		end

	traiter_commentaire_multiligne is
			-- commentaire multi-ligne
		do
			inspect caractere
			when '%U' then
				retenir_erreur( once "incomplete multiline comment" )
			when '%N' then
				if not chaine.is_empty then
					produire_commentaire
				end
				produire_ligne
				etat := etat_commentaire_multiligne
			when ' ', '%F', '%R', '%T' then
				if not chaine.is_empty then
					produire_commentaire
				end
				etat := etat_commentaire_multiligne
			when '*' then
				chaine.add_last( caractere )
				etat := etat_commentaire_multiligne_apres_etoile
			else
				chaine.add_last( caractere )
				etat := etat_commentaire_multiligne
			end
		end

feature {}

	retenir_erreur( p_message : STRING ) is
		do
			precursor( p_message )
			etat := etat_final
		end

end
