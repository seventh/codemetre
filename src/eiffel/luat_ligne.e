indexing

	auteur : "seventh"
	license : "GPL 3.0"

class

	LUAT_LIGNE

		--
		-- Ligne de source pouvant contenir du code et des commentaires
		--

creation

	fabriquer

feature {}

	fabriquer( p_phrase : COLLECTION[ LUAT_SOURCE ] ) is
		require
			phrase_valide : p_phrase /= void
		do
			contenu := p_phrase
		end

feature

	est_vide : BOOLEAN is
			-- une ligne est vide quand elle ne contient aucun élément
		do
			result := contenu.is_empty
		ensure
			result = ( nb_element = 0 )
		end

	element( p_indice : INTEGER ) : LUAT_SOURCE is
			-- ième élément de la ligne
		require
			indice_valide( p_indice )
		do
			result := contenu.item( p_indice )
		end

	nb_element : INTEGER is
			-- nombre total d'éléments de cette ligne
		do
			result := contenu.count
		end

	indice_valide( p_indice : INTEGER ) : BOOLEAN is
			-- l'indice correspond-il à un élément ?
		do
			result := contenu.valid_index( p_indice )
		ensure
			result = p_indice.in_range( 0, nb_element - 1 )
		end

feature

	contient_commentaire : BOOLEAN is
			-- vrai si et seulement si la ligne contient au moins un
			-- commentaire
		local
			i : INTEGER
		do
			from i := contenu.lower
			variant contenu.upper - i
			until i > contenu.upper
				or else contenu.item( i ).est_commentaire
			loop
				i := i + 1
			end

			result := i <= contenu.upper
		end

	contient_code : BOOLEAN is
			-- vrai si et seulement si la ligne contient au moins un
			-- élément de code
		local
			i : INTEGER
		do
			from i := contenu.lower
			variant contenu.upper - i
			until i > contenu.upper
				or else contenu.item( i ).est_code
			loop
				i := i + 1
			end

			result := i <= contenu.upper
		end

feature {LUAT_ORDRE_LIGNE}

	contenu : COLLECTION[ LUAT_SOURCE ]

feature

	afficher( p_flux : OUTPUT_STREAM ) is
			-- produit une forme lisible sur le flux correspondant
		local
			i : INTEGER
		do
			from i := contenu.lower
			variant contenu.upper - i
			until i > contenu.upper
			loop
				contenu.item( i ).afficher( p_flux )
				if i < contenu.upper then
					p_flux.put_spaces( 1 )
				else
					p_flux.put_new_line
				end
				i := i + 1
			end
		end

end
