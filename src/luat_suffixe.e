indexing

	auteur : "seventh"
	license : "GPL 3.0"

class

	LUAT_SUFFIXE

		--
		-- Association entre un suffixe de fichier et un analyseur de
		-- langage de programmation
		--

creation

	fabriquer

feature {}

	fabriquer( p_suffixe : STRING
				  p_langage : LUAT_ANALYSEUR ) is
			-- constructeur
		require
			suffixe_valide : not p_suffixe.is_empty
		do
			suffixe := p_suffixe
			langage := p_langage
		ensure
			suffixe_ok : suffixe = p_suffixe
			langage_ok : langage = p_langage
		end

feature

	suffixe : STRING
			-- clef utilisée pour vérifier l'appartenance d'un fichier
			-- au langage associé

	langage : LUAT_ANALYSEUR
			-- analyseur syntaxique du langage de programmation associé

end
