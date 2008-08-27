indexing

	auteur : "seventh"
	license : "GPL 3.0"

class

	LUAT_SOURCE

		--
		-- Elément de code de programmation
		--

creation

	fabriquer_code,
	fabriquer_commentaire

feature {}

	fabriquer_code( p_lexeme : STRING ) is
			-- génère un élément de code programmable
		require
			lexeme_valide : p_lexeme /= void
		do
			lexeme := p_lexeme
			est_code := true
		ensure
			est_code
			lexeme_ok : lexeme = p_lexeme
		end

	fabriquer_commentaire( p_lexeme : STRING ) is
			-- génère un élément de commentaire
		require
			lexeme_valide : p_lexeme /= void
		do
			lexeme := p_lexeme
		ensure
			est_commentaire
			lexeme_ok : lexeme = p_lexeme
		end

feature

	lexeme : STRING
			-- contenu textuel

	est_code : BOOLEAN
			-- vrai si et seulement si l'élément représente du code

	est_commentaire : BOOLEAN is
			-- vrai si et seulement si l'élément représente un
			-- commentaire
		do
			result := not est_code
		end

feature

	afficher( p_flux : OUTPUT_STREAM ) is
			-- produit une forme lisible sur le flux correspondant
		do
			if est_code then
				p_flux.put_string( once "$CODE:" )
			else
				p_flux.put_string( once "$COMMENTAIRE:" )
			end
			p_flux.put_string( lexeme )
			p_flux.put_character( '$' )
		end

end
