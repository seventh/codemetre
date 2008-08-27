indexing

	auteur : "seventh"
	license : "GPL 3.0"
	reference : "Introduction à l'algorithmique - chapitre 14 - Cormen, Leiserson, Rivest"

class

	ARN_ENSEMBLE_COULEUR

		--
		-- Ensemble des couleurs possibles pour les noeuds de l'arbre
		--

feature

	rouge : ARN_COULEUR is
		once
			create result
		end

	noir : ARN_COULEUR is
		once
			create result
		end

end
