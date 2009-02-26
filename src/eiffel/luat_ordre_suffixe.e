indexing

	auteur : "seventh"
	license : "GPL 3.0"

class

	LUAT_ORDRE_SUFFIXE

		--
		-- Ordre entre LUAT_SUFFIXE, pour permettre la recherche
		-- d'éléments basés sur le suffixe
		--

inherit

	CAP_ORDRE[ LUAT_SUFFIXE ]

feature

	est_verifie( a, b : LUAT_SUFFIXE ) : BOOLEAN is
		do
			result := a.suffixe <= b.suffixe
		end

end
