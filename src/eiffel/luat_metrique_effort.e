indexing

	auteur : "seventh"
	license : "GPL 3.0"

class

	LUAT_METRIQUE_EFFORT

		--
		-- Compte le nombre de lignes nouvelles par rapport au nombre
		-- de lignes conservées
		--

inherit

	LUAT_METRIQUE

creation

	fabriquer

feature

	nom : STRING is "effort"

feature

	effort : INTEGER
			-- taux de modification, en pourcentage

feature

	mesurer( p_ancien, p_nouvel : LUAT_LISTAGE ) is
		local
			commun : INTEGER
		do
			-- définition : effort = ( N - C ) / N

			if p_ancien = void then
				effort := 100
			elseif p_nouvel = void then
				effort := 0
			else
				if p_nouvel.est_equivalent( p_ancien ) then
					effort := 0
				else
					commun := nb_ligne_partage( p_ancien.contenu, p_nouvel.contenu )
					effort := ( 100 * ( p_nouvel.nb_ligne - commun ) / p_nouvel.nb_ligne ).rounded.force_to_integer_32
				end
			end
		ensure
			domaine : effort.in_range( 0, 100 )
		end

	afficher( p_flux : OUTPUT_STREAM ) is
		do
			p_flux.put_string( once "Effort " )
			p_flux.put_integer( effort )
			p_flux.put_character( '%%' )
		end

end
