indexing

	auteur : "seventh"
	license : "GPL 3.0"

deferred class

	LUAT_GLOBAL

		--
		-- Variables globales au projet
		--

feature

	usine_metrique : LUAT_FABRIQUE_METRIQUE is
			-- fabrique de métriques différentielles. Permet de
			-- configurer dynamiquement le modèle de comparaison
		once
			create result.fabriquer
		end

end
