indexing

	auteur : "seventh"
	license : "GPL 3.0"

deferred class

	LUAT_METRIQUE

		--
		-- Interface commune de métrique
		--

inherit

	LUAT_ELEMENT_CONFIGURABLE
		rename
			clef as nom
		end

	LUAT_GLOBAL

feature {}

	fabriquer is
			-- constructeur
		do
		end

feature

	nom : STRING is
			-- identifiant du modèle de comparaison
		deferred
		end

feature

	accumuler( p_contribution : like current ) is
			-- cumule les résultats intermédiaires de la contribution
			-- dans l'instance courante
		require
			contribution_valide : p_contribution /= void
		deferred
		end

	afficher( p_flux : OUTPUT_STREAM ) is
			-- produit une forme lisible sur le flux correspondant
		deferred
		end

end
