indexing

	auteur : "seventh"
	license : "GPL 3.0"

deferred class

	LUAT_LOT

		--
		-- Interface générique d'accès à un descripteur de lot de
		-- fichiers
		--

feature

	lire : STRING is
			-- nouvelle entrée du lot tant qu'il n'est pas épuisé, et
			-- void sinon
		deferred
		end

	est_epuise : BOOLEAN is
			-- vrai si et seulement s'il n'y a plus d'entrées dans le lot
		deferred
		end

	clore is
			-- suspend l'accès au descripteur
		deferred
		end

end
