indexing

	auteur : "seventh"
	license : "GPL 3.0"

class

	LUAT_ORDRE_LIGNE

		--
		-- Relation d'ordre entre LIGNE
		--

inherit

	CAP_ORDRE[ LUAT_LIGNE ]

feature

	est_verifie( a, b : LUAT_LIGNE ) : BOOLEAN is
		local
			i, commun : INTEGER
		do
			commun := a.nb_element.min( b.nb_element )

			from i := 0
			variant commun - 1 - i
			until i >= commun
				or else a.element( i ) /= b.element( i )
			loop
				i := i + 1
			end

			if i = commun then
				result := a.nb_element <= b.nb_element
			else -- if i < commun then
				result := ordre_source.est_verifie( a.element( i ), b.element( i ) )
			end
		end

feature {}

	ordre_source : LUAT_ORDRE_SOURCE is
			-- ordre utilitaire entre SOURCE
		once
			create result
		end

end
