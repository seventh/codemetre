indexing

	auteur : "seventh"
	license : "GPL 3.0"
	reference : "Introduction à l'algorithmique - chapitre 14 - Cormen, Leiserson, Rivest"

class

	ARN

		--
		-- Contexte global des Arbres Rouge et Noir
		--

feature {ARN}

	usine_couleur : ARN_ENUMERATION_COULEUR is
		once
			create result.fabriquer
		end

end
