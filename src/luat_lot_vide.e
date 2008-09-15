indexing

	auteur : "seventh"
	license : "GPL 3.0"

class

	LUAT_LOT_VIDE

inherit

	LUAT_LOT

creation

	fabriquer

feature {}

	fabriquer is
			-- constructeur
		do
		end

feature

	lire : STRING is
		do
		ensure
			definition : result = void
		end

	est_epuise : BOOLEAN is true

	clore is
		do
		end

end
