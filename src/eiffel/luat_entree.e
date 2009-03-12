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
			create tampon.make( taille )
			indice := tampon.upper + 1
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
			indice := tampon.upper + 1
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
			-- on s'assure qu'il y a toujours au moins deux caractères
			-- disponibles dans le tampon (sauf lorsque le fichier est
			-- épuisé)

			if tampon.valid_index( indice + 2 ) then
				indice := indice + 1
			else
				if tampon.valid_index( indice + 1 ) then
					tampon.keep_tail( 1 )
				else
					tampon.clear_count
				end
				fichier.read_available_in( tampon, taille )

				if tampon.is_empty then
					tampon.append_character( '%U' )
				end
				indice := tampon.lower
			end

			-- on saute les retours-chariot s'ils précèdent un retour à
			-- la ligne

			if tampon.item( indice ) = '%R'
				and ( tampon.valid_index( indice + 1 )
						and then tampon.item( indice + 1 ) = '%N' )
			 then
				indice := indice + 1
			end
		ensure
			caractere_est_disponible
		end

	caractere_est_disponible : BOOLEAN is
			-- vrai si et seulement si la dernière demande de lecture a
			-- réussi
		do
			result := tampon.valid_index( indice )
		end

	caractere : CHARACTER is
			-- caractère actuellement pointé par la tête de lecture
		require
			caractere_est_disponible
		do
			result := tampon.item( indice )
		end

	est_epuise : BOOLEAN is
			-- vrai si et seulement si la tête de lecture est arrivée en
			-- fin de fichier
		do
			result := not tampon.is_empty
				and then tampon.first = '%U'
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
			indice := p_source.indice
		end

	is_equal( p_autre : like current ) : BOOLEAN is
			-- les deux instances sont-elles équivalentes ?
		do
			result := fichier.is_equal( p_autre.fichier )
				and tampon.is_equal( p_autre.tampon )
				and indice = p_autre.indice
		end

feature {LUAT_ENTREE}

	fichier : TEXT_FILE_READ
			-- flux à filtrer

	tampon : STRING
			-- tampon de prélecture

	indice : INTEGER
			-- position du caractère actuellement lu dans le tampon

	taille : INTEGER is 4_096
			-- taille du tampon de lecture. Doit au minimum valoir 2

end
