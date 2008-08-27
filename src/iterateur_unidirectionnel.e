indexing

	auteur : "seventh"
	license : "GPL 3.0"

deferred class

	ITERATEUR_UNIDIRECTIONNEL[ E ]

		--
		-- Schéma de conception classique d'un itérateur
		--

feature -- requêtes

	est_hors_borne : BOOLEAN is
			-- un itérateur hors borne ne pointe sur aucun élément
		deferred
		end

	dereferencer : E is
			-- élément pointé par l'itérateur
		require
			not est_hors_borne
		deferred
		end

	pointer_hors_borne is
			-- rend l'itérateur hors borne
		deferred
		ensure
			est_hors_borne
		end

feature

	pointer_premier is
			-- déplace l'itérateur sur le premier élément de l'itération
		deferred
		end

	avancer is
			-- déplace l'itérateur vers le prochain élément
		require
			not est_hors_borne
		deferred
		end

end
