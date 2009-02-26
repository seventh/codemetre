indexing

	auteur : "seventh"
	license : "GPL 3.0"

class

	LUAT_ORDRE_SOURCE

		--
		-- Relation d'ordre entre SOURCE. Si les deux sources sont du
		-- même type, ils sont comparés à l'aide de la relation d'ordre
		-- associée à ce type. Sinon on compare les noms de type.
		--

inherit

	CAP_ORDRE[ LUAT_SOURCE ]

feature

	est_verifie( a, b : LUAT_SOURCE ) : BOOLEAN is
		do
			if a.est_code xor b.est_commentaire then
				result := ordre_lexeme.est_verifie( a.lexeme, b.lexeme )
			else
				result := a.est_code
			end
		end

feature {}

	ordre_lexeme : LUAT_ORDRE_LEXEME is
			-- ordre utilitaire entre LEXEME
		once
			create result
		end

end
