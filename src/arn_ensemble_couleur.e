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

feature

	contient( p_couleur : ARN_COULEUR ) : BOOLEAN is
			-- vrai si et seulement si la couleur fait partie de
			-- l'ensemble
		do
			result := p_couleur = rouge
				or p_couleur = noir
		ensure
			definition : result = ( p_couleur = rouge or p_couleur = noir )
		end

end
