indexing

	auteur : "seventh"
	license : "GPL 3.0"

class

	LUAT_ENTREE

		--
		-- Tampon d'entrée ne permettant que d'avancer caractère par
		-- caractère, et filtrant les retours-chariot (%R) avant les
		-- nouvelles lignes (%N)
		--
		-- La fin d'un fichier est matérialisée par la valeur de
		-- 'caractere' qui est alors positionné à '%U'
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
			create fichier.make
			create tampon.with_capacity( 2 )
		end

feature

	initialiser( p_fichier : STRING ) is
			-- fait pointer la tête de lecture au début du fichier s'il
			-- existe
		require
			not est_ouvert
		do
			fichier.connect_to( p_fichier )
			tampon.clear_count
		end

	terminer is
			-- clos le fichier
		require
			est_ouvert
		do
			fichier.disconnect
			tampon.clear_count
		ensure
			not est_ouvert
		end

	est_ouvert : BOOLEAN is
			-- un fichier est-il actuellement ouvert ?
		do
			result := fichier.is_connected
		end

feature

	avancer is
			-- passe au caractère suivant, tout en sautant tout
			-- retour-chariot précédant une nouvelle ligne
		require
			est_ouvert
			not est_epuise
		do
			-- l'implémentation ne peut se reposer uniquement sur
			-- TEXT_FILE_READ.unread_character qui, bien qu'en cours de
			-- correction par l'équipe de développement de SmartEiffel,
			-- n'assure pas d'être toujours possible.

			if tampon.upper > tampon.lower then
				-- au moins deux caractères sont dans le tampon

				tampon.remove_first
			else
				fichier.read_character

				-- on utilise 'ARRAY.force' car le tampon est vide à la
				-- première lecture

				if fichier.end_of_input then
					tampon.force( '%U', tampon.lower )
				else
					tampon.force( fichier.last_character, tampon.lower )

					if fichier.last_character = '%R' then
						fichier.read_character
						if fichier.end_of_input then
							tampon.add_last( '%U' )
						elseif fichier.last_character = '%N' then
							tampon.put( fichier.last_character, tampon.lower )
						else
							tampon.add_last( fichier.last_character )
						end
					end
				end
			end
		ensure
			caractere_est_disponible
		end

	caractere_est_disponible : BOOLEAN is
			-- vrai si et seulement si la dernière demande de lecture a
			-- réussi
		do
			result := not tampon.is_empty
		end

	caractere : CHARACTER is
			-- caractère actuellement pointé par la tête de lecture
		require
			caractere_est_disponible
		do
			result := tampon.first
		end

	est_epuise : BOOLEAN is
			-- vrai si et seulement si la tête de lecture est arrivée en
			-- fin de fichier
		do
			result := not tampon.is_empty and then tampon.first = '%U'
		ensure
			definition : result implies caractere = '%U'
		end

feature

	copy( p_source : like current ) is
			-- réalise une copie de la source
		do
			if fichier = void then
				fichier := p_source.fichier.twin
				tampon := p_source.tampon.twin
			else
				fichier.copy( p_source.fichier )
				tampon.copy( p_source.tampon )
			end
		end

	is_equal( p_autre : like current ) : BOOLEAN is
			-- les deux instances sont-elles équivalentes ?
		do
			result := fichier.is_equal( p_autre.fichier )
				and tampon.is_equal( p_autre.tampon )
		end

feature {LUAT_ENTREE}

	fichier : TEXT_FILE_READ

	tampon : FAST_ARRAY[ CHARACTER ]

end
