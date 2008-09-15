indexing

	auteur : "seventh"
	license : "GPL 3.0"

class

	LUAT_LOT_REEL

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

	lire : STRING is
		do
			if not flux.end_of_input then
				flux.read_line
				if not flux.end_of_input
					and then not flux.last_string.is_empty
				 then
					result := flux.last_string.twin
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

end
