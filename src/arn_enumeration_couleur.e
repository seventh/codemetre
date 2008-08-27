indexing

	auteur : "seventh"
	license : "GPL 3.0"
	reference : "Introduction à l'algorithmique - chapitre 14 - Cormen, Leiserson, Rivest"

class

	ARN_ENUMERATION_COULEUR

		--
		-- Enumération des couleurs possibles pour les noeuds.
		-- L'ordre est quelconque.
		--

inherit

	ARN_ENSEMBLE_COULEUR

	ENUMERATION_TABLE[ ARN_COULEUR ]
		rename
			fabriquer as fabriquer_enum
		end

creation

	fabriquer

feature {}

	fabriquer is
		do
			fabriquer_enum( << noir, rouge >> )
		end

end
