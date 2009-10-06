indexing

	auteur : "seventh"
	license : "GPL 3.0"

class

	LUAT_SUFFIXE

		--
		-- Association d'un suffixe avec un type de fichier, que ce
		-- soit un lot ou un langage de programmation
		--

creation

	fabriquer

feature {}

	fabriquer( p_suffixe : STRING
				  p_langage : STRING ) is
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
			-- extension de nom de fichier

	langage : STRING
			-- nom du langage

end
