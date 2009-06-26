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

	LUAT_METRIQUE_DIFFERENTIEL

creation

	fabriquer

feature

	nom : STRING is "effort"

feature

	rajout : INTEGER
			-- nombre de lignes ajoutées par rapport à la version commune

	nouvel : INTEGER
			-- nombre de lignes totales de la version courante

	effort : INTEGER is
			-- taux de modification, en pourcentage
		do
			if nouvel = 0 then
				result := 0
			else
				result := ( 100 * rajout / nouvel ).rounded.force_to_integer_32
			end
		ensure
			domaine : result.in_range( 0, 100 )
		end


feature

	mesurer( p_ancien, p_nouvel : LUAT_LISTAGE ) is
		local
			commun : INTEGER
		do
			-- définition : effort = ( N - C ) / N

			if p_nouvel = void then
				rajout := 0
				nouvel := 0
			elseif p_ancien = void then
				rajout := p_nouvel.nb_ligne
				nouvel := p_nouvel.nb_ligne
			elseif p_nouvel.est_equivalent( p_ancien ) then
				rajout := 0
				nouvel := p_nouvel.nb_ligne
			else
				commun := nb_ligne_partage( p_ancien.contenu, p_nouvel.contenu )
				rajout := p_nouvel.nb_ligne - commun
				nouvel := p_nouvel.nb_ligne
			end
		ensure
			intervalle : rajout.in_range( 0, nouvel )
		end

	accumuler( p_contribution : like current ) is
		do
			rajout := rajout + p_contribution.rajout
			nouvel := nouvel + p_contribution.nouvel
		ensure
			definition_1 : rajout = old rajout + p_contribution.rajout
			definition_2 : nouvel = old nouvel + p_contribution.nouvel
		end

	afficher( p_flux : OUTPUT_STREAM ) is
		do
			p_flux.put_string( once "effort " )
			p_flux.put_integer( effort )
			p_flux.put_character( '%%' )
		end

end
