indexing

	auteur : "seventh"
	license : "GPL 3.0"

class

	LUAT_ORDRE_LEXEME

		--
		-- Relation d'ordre entre lexèmes
		--

inherit

	CAP_ORDRE[ STRING ]

feature

	est_verifie( a, b : STRING ) : BOOLEAN is
		do
			result := a <= b
		end

end
