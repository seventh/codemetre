indexing

	auteur : "seventh"
	license : "GPL 3.0"

class

	DANG_ANALYSEUR

		--
		-- Analyseur de fichier de configuration de type ".gitconfig"
		--

inherit

	ANY
		redefine
			copy, is_equal
		end

creation

	fabriquer

feature {}

	fabriquer is
			-- constructeur
		do
			create fichier.make_empty
			create associations.with_capacity( 1 )
		end

feature

	ouvrir( p_nom_fichier : STRING ) is
			-- connecte l'analyseur sur le fichier de nom correspondant
		require
			appel_judicieux : not est_ouvert
			nom_valide : p_nom_fichier /= void
		do
			create flux.connect_to( p_nom_fichier )
			est_ouvert := flux.is_connected
			ligne := 1
			colonne := 0
			fichier.copy( p_nom_fichier )
		end

	fermer is
			-- déconnecte l'analyseur
		require
			appel_judicieux : est_ouvert
		do
			flux.disconnect
			est_ouvert := false
			associations.clear_count
		ensure
			definition : not est_ouvert
		end

	est_ouvert : BOOLEAN
			-- vrai si et seulement si l'analyseur est connecté

feature

	lire( p_adaptateur : DANG_ADAPTATEUR ) is
			-- lit le flux auquel il est connecté, et remonte les
			-- informations à l'adaptateur correspondant
		require
			appel_judicieux : est_ouvert
		local
			section, variable, valeur : STRING
			caractere : CHARACTER
			etat : INTEGER
			mode : INTEGER
		do
			-- initialisation

			create section.make_empty
			create variable.make_empty
			create valeur.make_empty

			mode := mode_inconnu

			-- lecture par automate

			from etat := etat_initial
			until etat = etat_final
			loop
				flux.read_character
				if flux.end_of_input then
					etat := etat_final
				else
					caractere := flux.last_character
					colonne := colonne + 1
				end

				inspect etat
				when etat_final then
					-- état puits

				when etat_initial then
					inspect caractere
					when ' ', '%T' then
						-- l'indentation est tolérée
					when '[' then
						section.clear_count
						etat := etat_section
					when '#' then
						etat := etat_commentaire
					when 'A' .. 'Z', 'a' .. 'z' then
						variable.clear_count
						variable.append_character( caractere )
						etat := etat_variable
					when '%N' then
						ligne := ligne + 1
						colonne := 0
					else
						p_adaptateur.traiter_erreur( once "unauthorized character" )
						etat := etat_final
					end

				when etat_section then
					inspect caractere
					when 'A' .. 'Z', 'a' .. 'z' then
						section.append_character( caractere )
					when ']' then
						etat := etat_initial
					else
						p_adaptateur.traiter_erreur( once "wrong section name" )
						etat := etat_final
					end

				when etat_commentaire then
					inspect caractere
					when '%N' then
						ligne := ligne + 1
						colonne := 0
						etat := etat_initial
					else
						-- le commentaire n'est pas mémorisé
					end

				when etat_variable then
					inspect caractere
					when ' ', '%T' then
						if existe_association( section, variable ) then
							p_adaptateur.traiter_erreur( once "duplicated association" )
							etat := etat_final
						else
							ajouter_association( section, variable )
							etat := etat_apres_variable
						end
					when '%N' then
						p_adaptateur.traiter_erreur( once "unassociated variable" )
						etat := etat_final
					else
						variable.append_character( caractere )
					end

				when etat_apres_variable then
					inspect caractere
					when ':' then
						etat := etat_apres_double_point
					when '+' then
						etat := etat_apres_plus
					when '-' then
						etat := etat_apres_moins
					else
						p_adaptateur.traiter_erreur( once "unknown operator" )
						etat := etat_final
					end

				when etat_apres_double_point then
					if caractere = '=' then
						mode := mode_forcage
						etat := etat_attente_valeur
					else
						p_adaptateur.traiter_erreur( once "unknown operator" )
						etat := etat_final
					end

				when etat_apres_plus then
					if caractere = '=' then
						mode := mode_allonge
						etat := etat_attente_valeur
					else
						p_adaptateur.traiter_erreur( once "unknown operator" )
						etat := etat_final
					end

				when etat_apres_moins then
					if caractere = '=' then
						mode := mode_retrait
						etat := etat_attente_valeur
					else
						p_adaptateur.traiter_erreur( once "unknown operator" )
						etat := etat_final
					end

				when etat_attente_valeur then
					inspect caractere
					when ' ', '%T' then
						-- l'indentation est tolérée
					when 'A' .. 'Z', 'a' .. 'z', '.' then
						valeur.clear_count
						valeur.append_character( caractere )
						etat := etat_valeur
					when '%N' then
						p_adaptateur.traiter_erreur( once "no value associated to variable" )
						etat := etat_final
					else
						p_adaptateur.traiter_erreur( once "unauthorized character" )
						etat := etat_final
					end

				when etat_valeur then
					inspect caractere
					when 'A' .. 'Z', 'a' .. 'z', '.' then
						valeur.append_character( caractere )
					when '%N', ',' then
						inspect mode
						when mode_allonge then
							p_adaptateur.ajouter( section, variable, valeur )
						when mode_forcage then
							p_adaptateur.imposer( section, variable, valeur )
							mode := mode_allonge
						when mode_retrait then
							p_adaptateur.retirer( section, variable, valeur )
						else
							debug
								p_adaptateur.traiter_erreur( once "lexer is buggy!" )
								etat := etat_final
							end
						end

						if caractere = '%N' then
							ligne := ligne + 1
							colonne := 0
							mode := mode_inconnu
							etat := etat_initial
						else
							etat := etat_attente_valeur
						end
					else
						p_adaptateur.traiter_erreur( once "unauthorized character" )
						etat := etat_final
					end
				end
			end
		end

feature {DANG_ADAPTATEUR, DANG_ANALYSEUR}

	ligne : INTEGER is
			-- numéro de ligne pour situer l'avancement de la lecture
		require
			appel_judicieux : est_ouvert
		attribute
		end

	colonne : INTEGER is
			-- position dans la ligne
		require
			appel_judicieux : est_ouvert
		attribute
		end

	fichier : STRING is
			-- nom du fichier en cours d'analyse
		require
			appel_judicieux : est_ouvert
		attribute
		end

feature

	copy( p_source : like current ) is
			-- réalise une copie de la source
		do
			if fichier = void then
				fichier := p_source.fichier.twin
				flux := p_source.flux.twin
				associations := p_source.associations.twin
			else
				fichier.copy( p_source.fichier )
				flux.copy( p_source.flux )
				associations.copy( p_source.associations )
			end

			est_ouvert := p_source.est_ouvert
			ligne := p_source.ligne
			colonne := p_source.colonne
		end

	is_equal( p_autre : like current ) : BOOLEAN is
			-- les deux instances sont-elles équivalentes ?
		do
			result := fichier.is_equal( p_autre.fichier )
		end

feature {DANG_ANALYSEUR}

	flux : TEXT_FILE_READ
			-- source

	associations : FAST_ARRAY[ TUPLE[ STRING, STRING ] ]
			-- liste des paires (section,variable) déjà parcourues

feature {}

	ajouter_association( p_section : STRING
								p_variable : STRING ) is
			-- ajoute la paire (section,variable) à la liste des
			-- associations connues
		require
			not existe_association( p_section, p_variable )
		do
			associations.add_last( [ p_section.twin, p_variable.twin ] )
		ensure
			existe_association( p_section, p_variable )
		end

	existe_association( p_section : STRING
							  p_variable : STRING ) : BOOLEAN is
			-- vrai si et seulement si la paire (section,variable) est
			-- déjà dans la liste des associations connues
		local
			i : INTEGER
		do
			from i := associations.lower
			variant associations.upper - i
			until i > associations.upper
				or else ( associations.item( i ).first.is_equal( p_section )
							 and associations.item( i ).second.is_equal( p_variable ) )
			loop
				i := i + 1
			end

			result := i <= associations.upper
		end

feature {} -- états internes de l'automate de lecture

	etat_initial : INTEGER is unique

	etat_apres_double_point : INTEGER is unique
	etat_apres_moins : INTEGER is unique
	etat_apres_plus : INTEGER is unique
	etat_apres_variable : INTEGER is unique
	etat_attente_valeur : INTEGER is unique
	etat_commentaire : INTEGER is unique
	etat_section : INTEGER is unique
	etat_valeur : INTEGER is unique
	etat_variable : INTEGER is unique

	etat_final : INTEGER is unique

feature {} -- mode d'association entre variable et valeur

	mode_inconnu : INTEGER is unique

	mode_allonge : INTEGER is unique
	mode_forcage : INTEGER is unique
	mode_retrait : INTEGER is unique

end
