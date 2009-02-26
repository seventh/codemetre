indexing

	auteur : "seventh"
	license : "GPL 3.0"

deferred class

	ITERATEUR_BIDIRECTIONNEL_ESCLAVE[ E, M ]

		--
		-- Itérateur attachable à l'ensemble parcouru et pouvant se
		-- déplacer dans les deux sens d'une même direction
		--

inherit

	ITERATEUR_UNIDIRECTIONNEL_ESCLAVE[ E, M ]

	ITERATEUR_BIDIRECTIONNEL[ E ]

feature

	pointer_dernier is
		require
			est_soumis
		deferred
		end

end
