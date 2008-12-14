indexing

	auteur : "seventh"
	license : "GPL 3.0"

class

	LUAT_LOT_LISTE

		--
		-- Itérateur de fichier texte, chaque ligne représentant le nom
		-- d'un fichier
		--

inherit

	LUAT_LOT

creation

	fabriquer

feature {}

	fabriquer( p_flux : INPUT_STREAM ) is
			-- constructeur
		require
			lot_valide : p_flux.is_connected
		do
			flux := p_flux
		ensure
			flux_ok : flux = p_flux
		end

feature

	entree : STRING is
		attribute
		end

	entree_courte : STRING is
		do
			result := entree
		ensure
			definition : result = entree
		end

	lire is
		do
			if not flux.end_of_input then
				flux.read_line
				if flux.end_of_input
					or else flux.last_string.is_empty
				 then
					entree := void
				else
					entree := flux.last_string.twin
				end
			end
		end

	est_epuise : BOOLEAN is
		do
			result := flux.end_of_input
		end

	clore is
		do
			flux.disconnect
		end

feature {}

	flux : INPUT_STREAM
			-- accesseur au fichier de lot

end
