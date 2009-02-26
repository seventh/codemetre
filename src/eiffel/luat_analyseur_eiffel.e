indexing

	auteur : "seventh"
	license : "GPL 3.0"
	reference : "Eiffel, le langage, B. Meyer, InterEditions"

class

	LUAT_ANALYSEUR_EIFFEL

		--
		-- Analyseur syntaxique du langage Eiffel
		--

inherit

	LUAT_ANALYSEUR
		redefine
			fabriquer,
			gerer_erreur
		end

insert

	PLATFORM

creation

	fabriquer

feature

	langage : STRING is "Eiffel"

feature {}

	fabriquer is
		do
			precursor
			create chaine_litterale.make_empty
		end

feature {LUAT_ANALYSEUR}

	analyser is
		local
			suffixe : STRING
			indentation : INTEGER
			indentation_minimum : INTEGER
			nb_chiffres : INTEGER
			unicode : INTEGER
			unicode_string_buffer : UNICODE_STRING
			code_ascii : INTEGER
		do
			check
				chaine.is_empty
				ligne.is_empty
				chaine_litterale.is_empty
			end

			indice_ligne := 1
			erreur := false
			message_erreur := once ""

			create unicode_string_buffer.make_empty
			create suffixe.with_capacity( 2 )

			from etat := etat_initial
			until etat = etat_final
			loop
				fichier.avancer

				inspect etat
				when etat_final then
					-- état puits

				when etat_initial then
					traiter_etat_initial

					--
					-- identifiants
					--

				when etat_apres_lettre then
					inspect caractere
					when '0' .. '9', 'A' .. 'Z', '_', 'a' .. 'z' then
						chaine.add_last( caractere )
					else
						produire_code
						traiter_etat_initial
					end

				when etat_apres_u_majuscule then
					inspect caractere
					when '%"' then
						chaine.add_last( caractere )
						chaine_litterale.add_last( caractere )
						etat := etat_dans_litteral_chaine
					when '0' .. '9', 'A' .. 'Z', '_', 'a' .. 'z' then
						chaine.add_last( caractere )
						chaine_litterale.clear_count
						etat := etat_apres_lettre
					else
						produire_code
						chaine_litterale.clear_count
						traiter_etat_initial
					end

					--
					-- littéral numérique
					--

				when etat_apres_chiffre then
					inspect caractere
					when '0' .. '9' then
						chaine.add_last( caractere )
					when '_' then
						chaine.add_last( caractere )
						etat := etat_apres_souligne_dans_nombre_entier
					when '.' then
						chaine.add_last( caractere )
						etat := etat_apres_separateur_decimal
					when 'E', 'e' then
						chaine.add_last( caractere )
						etat := etat_apres_mention_exposant
					else
						produire_code
						traiter_etat_initial
					end

				when etat_apres_souligne_dans_nombre_entier then
					inspect caractere
					when '0' .. '9', '_' then
						chaine.add_last( caractere )
					else
						produire_code
						traiter_etat_initial
					end

				when etat_apres_separateur_decimal then
					inspect caractere
					when '0' .. '9' then
						chaine.add_last( caractere )
					when 'E', 'e' then
						chaine.add_last( caractere )
						etat := etat_apres_mention_exposant
					else
						produire_code
						traiter_etat_initial
					end

				when etat_apres_mention_exposant then
					inspect caractere
					when '+', '-' then
						chaine.add_last( caractere )
						etat := etat_apres_signe_exposant
					when '0' .. '9' then
						chaine.add_last( caractere )
						etat := etat_dans_exposant
					else
						gerer_erreur( once "incomplete real constant" )
					end

				when etat_apres_signe_exposant then
					-- nombre décimal après mention du signe de l'exposant

					if caractere.in_range( '0', '9' ) then
						chaine.add_last( caractere )
						etat := etat_dans_exposant
					else
						gerer_erreur( once "incomplete real constant" )
					end

				when etat_dans_exposant then
					-- nombre décimal après mention d'au moins un des
					-- chiffres de l'exposant

					if caractere.in_range( '0', '9' ) then
						chaine.add_last( caractere )
					else
						produire_code
						traiter_etat_initial
					end

					--
					-- littéral caractère
					--

				when etat_apres_apostrophe then
					inspect caractere
					when '%'' then
						chaine.add_last( caractere )
						produire_code
						etat := etat_initial
					when '%%' then
						chaine.add_last( caractere )
						etat := etat_apres_exception_dans_litteral_caractere
					when '%U' then
						gerer_erreur( once "incomplete character constant" )
					else
						chaine.add_last( caractere )
					end

				when etat_apres_exception_dans_litteral_caractere then
					if caractere = '%U' then
						gerer_erreur( once "incomplete character constant" )
					else
						chaine.add_last( caractere )
						etat := etat_apres_apostrophe
					end

					--
					-- littéral chaîne
					--
					-- automate repris état pour état de celui de
					-- PARSER.a_manifest_string
					--

				when etat_dans_litteral_chaine then
					inspect caractere
					when '%U' then
						gerer_erreur( once "incomplete string constant" )
					when '%N' then
						-- on supprime les derniers blancs du suffixe
						from
						until chaine_litterale.last /= ' '
							and chaine_litterale.last /= '%T'
						loop
							chaine_litterale.remove_last
						end

						inspect chaine_litterale.last
						when '[' then
							indentation_minimum := 0
							indentation := 1
							suffixe.copy( chaine_litterale )
							if suffixe.first = 'U' then
								suffixe.remove_first
							end
							suffixe.put( ']', suffixe.lower )
							suffixe.put( '%"', suffixe.upper )
							produire_code
							produire_ligne
							etat := etat_dans_litteral_chaine_apres_crochet
						when '{' then
							indentation_minimum := 1
							indentation := 1
							suffixe.copy( chaine_litterale )
							if suffixe.first = 'U' then
								suffixe.remove_first
							end
							suffixe.put( '}', suffixe.lower )
							suffixe.put( '%"', suffixe.upper )
							produire_code
							produire_ligne
							etat := etat_dans_litteral_chaine_apres_accolade
						else
							gerer_erreur( once "unexpected end-of-line in string constant" )
						end
					when '%"' then
						chaine.add_last( caractere )
						produire_code
						chaine_litterale.clear_count
						-- suffixe.clear_count
						etat := etat_initial
					when '%%' then
						chaine.add_last( caractere )
						etat := etat_dans_litteral_chaine_apres_pourcent
					else
						chaine.add_last( caractere )
						chaine_litterale.add_last( caractere )
					end

				when etat_dans_litteral_chaine_apres_pourcent then
					inspect caractere
					when '%N' then
						produire_code
						produire_ligne
						etat := etat_dans_litteral_chaine_avant_pourcent
					when 'A' then
						chaine.add_last( caractere )
						chaine_litterale.extend('%A')
						etat := etat_dans_litteral_chaine
					when 'B' then
						chaine.add_last( caractere )
						chaine_litterale.extend('%B')
						etat := etat_dans_litteral_chaine
					when 'C' then
						chaine.add_last( caractere )
						chaine_litterale.extend('%C')
						etat := etat_dans_litteral_chaine
					when 'D' then
						chaine.add_last( caractere )
						chaine_litterale.extend('%D')
						etat := etat_dans_litteral_chaine
					when 'F' then
						chaine.add_last( caractere )
						chaine_litterale.extend('%F')
						etat := etat_dans_litteral_chaine
					when 'H' then
						chaine.add_last( caractere )
						chaine_litterale.extend('%H')
						etat := etat_dans_litteral_chaine
					when 'L' then
						chaine.add_last( caractere )
						chaine_litterale.extend('%L')
						etat := etat_dans_litteral_chaine
					when 'N' then
						chaine.add_last( caractere )
						chaine_litterale.extend('%N')
						etat := etat_dans_litteral_chaine
					when 'Q' then
						chaine.add_last( caractere )
						chaine_litterale.extend('%Q')
						etat := etat_dans_litteral_chaine
					when 'R' then
						chaine.add_last( caractere )
						chaine_litterale.extend('%R')
						etat := etat_dans_litteral_chaine
					when 'S' then
						chaine.add_last( caractere )
						chaine_litterale.extend('%S')
						etat := etat_dans_litteral_chaine
					when 'T' then
						chaine.add_last( caractere )
						chaine_litterale.extend('%T')
						etat := etat_dans_litteral_chaine
					when 'U' then
						chaine.add_last( caractere )
						chaine_litterale.extend('%U')
						etat := etat_dans_litteral_chaine
					when 'V' then
						chaine.add_last( caractere )
						chaine_litterale.extend('%V')
						etat := etat_dans_litteral_chaine
					when '%%' then
						chaine.add_last( caractere )
						chaine_litterale.extend('%%')
						etat := etat_dans_litteral_chaine
					when '%'' then
						chaine.add_last( caractere )
						chaine_litterale.extend('%'')
						etat := etat_dans_litteral_chaine
					when '%"' then
						chaine.add_last( caractere )
						chaine_litterale.extend('%"')
						etat := etat_dans_litteral_chaine
					when '(' then
						chaine.add_last( caractere )
						chaine_litterale.extend('%(')
						etat := etat_dans_litteral_chaine
					when ')' then
						chaine.add_last( caractere )
						chaine_litterale.extend('%)')
						etat := etat_dans_litteral_chaine
					when '<' then
						chaine.add_last( caractere )
						chaine_litterale.extend('%<')
						etat := etat_dans_litteral_chaine
					when '>' then
						chaine.add_last( caractere )
						chaine_litterale.extend('%>')
						etat := etat_dans_litteral_chaine
					when '/' then
						chaine.add_last( caractere )
						code_ascii := 0
						nb_chiffres := 0
						etat := etat_dans_litteral_chaine_code_ascii_apres_slash
					when ' ', '%T' then
						etat := etat_dans_litteral_chaine_apres_pourcent_espace
					else
						gerer_erreur( once "unknown special character" )
					end

				when etat_dans_litteral_chaine_apres_pourcent_espace then
					inspect caractere
					when ' ', '%T' then
						-- les espaces sont tolérés, mais non significatifs
					when '%N' then
						produire_code
						produire_ligne
						etat := etat_dans_litteral_chaine_avant_pourcent
					else
						gerer_erreur( once "unknown character after '%%' mark" )
					end

				when etat_dans_litteral_chaine_avant_pourcent then
					inspect caractere
					when ' ', '%T' then
						-- les espaces sont non significatifs
					when '%%' then
						chaine.add_last( caractere )
						etat := etat_dans_litteral_chaine
					when '%N' then
						gerer_erreur( once "unexpected end-of-line in string constant" )
					else
						gerer_erreur( once "unknown character after '%%' mark" )
					end

				when etat_dans_litteral_chaine_code_ascii_apres_slash then
					inspect caractere
					when '0' .. '9' then
						chaine.add_last( caractere )
						nb_chiffres := nb_chiffres + 1
						code_ascii := code_ascii * 10 + caractere.decimal_value
					when 'x' then
						if nb_chiffres = 1
							and code_ascii = 0
						 then
							chaine.add_last( caractere )
							nb_chiffres := 0
							etat := etat_dans_litteral_chaine_code_ascii_apres_slash_0x
						else
							gerer_erreur( once "unexpected character in ASCII code" )
						end
					when 'U' then
						if nb_chiffres = 0 then
							chaine.add_last( caractere )
							etat := etat_dans_litteral_chaine_code_ascii_apres_slash_u
						else
							gerer_erreur( once "unexpected character in ASCII code" )
						end
					when '/' then
						chaine.add_last( caractere )
						chaine_litterale.extend(code_ascii.to_character)
						etat := etat_dans_litteral_chaine
						if nb_chiffres = 0 then
							gerer_erreur( once "nul length ASCII code" )
						elseif code_ascii > Maximum_character_code then
							gerer_erreur( once "ASCII code is out of range" )
						end
					else
						gerer_erreur( once "unexpected character in ASCII code" )
					end

				when etat_dans_litteral_chaine_code_ascii_apres_slash_u then
					if caractere = 'x' then
						chaine.add_last( caractere )
						etat := etat_dans_litteral_chaine_unicode_apres_slash_ux
						unicode := 0
						nb_chiffres := 0
					else
						gerer_erreur( once "unexpected character in ASCII code" )
					end

				when etat_dans_litteral_chaine_code_ascii_apres_slash_0x then
					inspect caractere
					when '0' .. '9', 'A' .. 'F', 'a' .. 'f' then
						chaine.add_last( caractere )
						code_ascii := code_ascii * 16 + caractere.hexadecimal_value
						nb_chiffres := nb_chiffres + 1
						if nb_chiffres.is_even then
							chaine_litterale.extend(code_ascii.to_character)
							code_ascii := 0
						end
					when '/' then
						chaine.add_last( caractere )
						etat := etat_dans_litteral_chaine
						if nb_chiffres = 0 then
							gerer_erreur( once "nul length ASCII code" )
						elseif nb_chiffres.is_odd then
							gerer_erreur( once "hexadecimal constant shall be made of an even number of digits" )
						end
					else
						gerer_erreur( once "unexpected character in ASCII code" )
					end

				when etat_dans_litteral_chaine_unicode_apres_slash_ux then
					inspect caractere
					when '0' .. '9', 'A' .. 'F', 'a' .. 'f' then
						chaine.add_last( caractere )
						unicode := unicode * 16 + caractere.hexadecimal_value
						nb_chiffres := nb_chiffres + 1
					when '/' then
						chaine.add_last( caractere )
						if nb_chiffres = 0 then
							gerer_erreur( once "nul length ASCII code" )
						elseif nb_chiffres > 8 then
							gerer_erreur( once "hexadecimal code of unicode character is 8 digits max" )
						else
							if unicode_string_buffer.valid_unicode(unicode) then
								unicode_string_buffer.add_last(unicode)
								unicode_string_buffer.utf8_encode_in(chaine_litterale)
								unicode_string_buffer.clear_count
								etat := etat_dans_litteral_chaine
							else
								gerer_erreur( once "wrong unicode spelling" )
							end
						end
					else
						gerer_erreur( once "unexpected character in ASCII code" )
					end

				when etat_dans_litteral_chaine_apres_crochet then
					inspect caractere
					when '%U' then
						gerer_erreur( once "unexpected end-of-file in multiline constant string" )
					when ' ', '%T' then
						indentation := indentation + 1
					when '%N' then
						if chaine.is_empty then
							chaine.add_last( ' ' )
						end
						produire_code
						produire_ligne
						chaine_litterale.extend( '%N' )
						indentation := 1
					else
						chaine.add_last( caractere )
						chaine_litterale.extend( caractere )
						if indentation_minimum = 0 then
							indentation_minimum := indentation
						end
						etat := etat_dans_litteral_chaine_apres_accolade
					end

				when etat_dans_litteral_chaine_apres_accolade then
					indentation := indentation + 1
					inspect caractere
					when '%U' then
						gerer_erreur( once "unexpected end-of-file in multiline constant string" )
					when ' ', '%T' then
						if indentation >= indentation_minimum then
							chaine.add_last( caractere )
							chaine_litterale.extend( caractere )
						end
					when '%N' then
						if chaine.is_empty then
							chaine.add_last( ' ' )
						end
						produire_code
						produire_ligne
						chaine_litterale.extend( caractere )
						indentation := 0
					when '%"' then
						chaine.add_last( caractere )
						chaine_litterale.extend( caractere )
						if chaine_litterale.has_suffix( suffixe ) then
							produire_code
							chaine_litterale.clear_count
							etat := etat_initial
						end
					else
						if indentation < indentation_minimum then
							if caractere = suffixe.first then
								chaine.add_last( caractere )
								chaine_litterale.extend( caractere )
								etat := etat_dans_litteral_chaine_attente_suffixe
							else
								gerer_erreur( once "margins in string constant" )
							end
						else
							chaine.add_last( caractere )
							chaine_litterale.add_last( caractere )
						end
					end

				when etat_dans_litteral_chaine_attente_suffixe then
					inspect caractere
					when '%U' then
						gerer_erreur( once "unexpected end-of-file in multiline constant string" )
					when '%"' then
						chaine.add_last( caractere )
						chaine_litterale.extend( caractere )
						if chaine_litterale.has_suffix( suffixe ) then
							produire_code
							chaine_litterale.clear_count
							etat := etat_initial
						end
					else
						chaine.add_last( caractere )
						chaine_litterale.extend( caractere )
					end

					--
					-- Lexème débutant par un point
					--

				when etat_apres_point then
					inspect caractere
					when '.' then
						chaine.add_last( caractere )
						produire_code
						etat := etat_initial
					when '0' .. '9' then
						chaine.add_last( caractere )
						etat := etat_apres_separateur_decimal
					else
						produire_code
						traiter_etat_initial
					end

					--
					-- Lexème débutant par un slash
					--

				when etat_apres_slash then
					inspect caractere
					when '/', '=' then
						chaine.add_last( caractere )
						produire_code
						etat := etat_initial
					else
						produire_code
						traiter_etat_initial
					end

					--
					--
					--

				when etat_apres_chevron_ouvrant then
					inspect caractere
					when '<', '=' then
						chaine.add_last( caractere )
						produire_code
						etat := etat_initial
					else
						produire_code
						traiter_etat_initial
					end

					--
					--
					--

				when etat_apres_chevron_fermant then
					inspect caractere
					when '=', '>' then
						chaine.add_last( caractere )
						produire_code
						etat := etat_initial
					else
						produire_code
						traiter_etat_initial
					end

					--
					--
					--

				when etat_apres_point_interrogation then
					-- lexème débutant par "?"

					if caractere = '=' then
						chaine.add_last( caractere )
						produire_code
						etat := etat_initial
					elseif caractere = ':' then
						chaine.add_last( caractere )
						etat := etat_attente_egal
					else
						produire_code
						traiter_etat_initial
					end

				when etat_apres_deux_points then
					-- lexème débutant par ":"

					if caractere = '=' then
						chaine.add_last( caractere )
						produire_code
						etat := etat_initial
					elseif caractere = ':' then
						chaine.add_last( caractere )
						etat := etat_attente_egal
					else
						produire_code
						traiter_etat_initial
					end

				when etat_attente_egal then
					-- lexème débutant par "::" ou "?:"

					if caractere = '=' then
						chaine.add_last( caractere )
						produire_code
						etat := etat_initial
					else
						gerer_erreur( once "unknown operator" )
					end

					--
					--
					--

				when etat_apres_tiret then
					-- lexème débutant par "-"

					if caractere = '-' then
						chaine.add_last( caractere )
						etat := etat_apres_double_tiret
					elseif caractere = '>' then
						chaine.add_last( caractere )
						produire_code
						etat := etat_initial
					else
						produire_code
						traiter_etat_initial
					end

				when etat_apres_double_tiret then
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

					--
					--
					--

				when etat_apres_antislash then
					if caractere = '\' then
						chaine.add_last( caractere )
						produire_code
						etat := etat_initial
					else
						gerer_erreur( once "unknown operator %"\%"" )
					end

					--
					-- opérateur personnalisé
					--

				when etat_operateur_personalise then
					inspect caractere
					when ' ', '%T' then
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

				else
					-- cas non géré

					gerer_erreur( once "lexer is buggy!" )
				end

			end

			-- gestion de l'erreur d'analyse

			if erreur then
				listage := void
				chaine.clear_count
				chaine_litterale.clear_count
				ligne.clear_count
			else
				produire_ligne
			end

			check
				chaine.is_empty
				ligne.is_empty
				chaine_litterale.is_empty
			end
		end

feature {}

	etat : INTEGER
			-- état courant de l'automate de reconnaissance de lexèmes

	etat_initial : INTEGER is unique
			-- aucun contexte

	etat_apres_lettre : INTEGER is unique
	etat_apres_u_majuscule : INTEGER is unique

	etat_apres_chiffre : INTEGER is unique
	etat_apres_souligne_dans_nombre_entier : INTEGER is unique
	etat_apres_separateur_decimal : INTEGER is unique
	etat_apres_mention_exposant : INTEGER is unique
	etat_apres_signe_exposant : INTEGER is unique
	etat_dans_exposant : INTEGER is unique

	etat_apres_apostrophe : INTEGER is unique
	etat_apres_exception_dans_litteral_caractere : INTEGER is unique

	etat_dans_litteral_chaine : INTEGER is unique
	etat_dans_litteral_chaine_apres_accolade : INTEGER is unique
	etat_dans_litteral_chaine_apres_crochet : INTEGER is unique
	etat_dans_litteral_chaine_apres_pourcent : INTEGER is unique
	etat_dans_litteral_chaine_apres_pourcent_espace : INTEGER is unique
	etat_dans_litteral_chaine_attente_suffixe : INTEGER is unique
	etat_dans_litteral_chaine_avant_pourcent : INTEGER is unique
	etat_dans_litteral_chaine_code_ascii_apres_slash : INTEGER is unique
	etat_dans_litteral_chaine_code_ascii_apres_slash_0x : INTEGER is unique
	etat_dans_litteral_chaine_code_ascii_apres_slash_u : INTEGER is unique
	etat_dans_litteral_chaine_unicode_apres_slash_ux : INTEGER is unique

	etat_apres_point : INTEGER is unique

	etat_apres_slash : INTEGER is unique
	etat_apres_chevron_ouvrant : INTEGER is unique
	etat_apres_chevron_fermant : INTEGER is unique
	etat_apres_point_interrogation : INTEGER is unique
	etat_apres_deux_points : INTEGER is unique
	etat_apres_tiret : INTEGER is unique
	etat_apres_antislash : INTEGER is unique
	etat_apres_double_tiret : INTEGER is unique
	etat_attente_egal : INTEGER is unique
	etat_operateur_personalise : INTEGER is unique

	etat_final : INTEGER is unique
			-- état puits

	chaine_litterale : STRING
			-- littéral chaîne après interprétation

feature {}

	traiter_etat_initial is
			-- aucun préfixe
		do
			inspect caractere
			when '0' .. '9' then
				chaine.add_last( caractere )
				etat := etat_apres_chiffre
			when 'A' .. 'T', 'V' .. 'Z', '_', 'a' .. 'z' then
				chaine.add_last( caractere )
				etat := etat_apres_lettre
			when 'U' then
				chaine.add_last( caractere )
				chaine_litterale.add_last( caractere )
				etat := etat_apres_u_majuscule
			when '%'' then
				chaine.add_last( caractere )
				etat := etat_apres_apostrophe
			when '%"' then
				chaine.add_last( caractere )
				chaine_litterale.add_last( caractere )
				etat := etat_dans_litteral_chaine
			when '.' then
				chaine.add_last( caractere )
				etat := etat_apres_point
			when '/' then
				chaine.add_last( caractere )
				etat := etat_apres_slash
			when '<' then
				chaine.add_last( caractere )
				etat := etat_apres_chevron_ouvrant
			when '>' then
				chaine.add_last( caractere )
				etat := etat_apres_chevron_fermant
			when '?' then
				chaine.add_last( caractere )
				etat := etat_apres_point_interrogation
			when ':' then
				chaine.add_last( caractere )
				etat := etat_apres_deux_points
			when '-' then
				chaine.add_last( caractere )
				etat := etat_apres_tiret
			when '\' then
				chaine.add_last( caractere )
				etat := etat_apres_antislash
			when '#', '&', '@', '|' then
				chaine.add_last( caractere )
				etat := etat_operateur_personalise
			when '!', '$', '(', ')', '*', '+', ',', ';', '=', '[', ']', '^', '{', '}', '~' then
				chaine.add_last( caractere )
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
