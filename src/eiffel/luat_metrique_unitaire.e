indexing

	auteur : "seventh"
	license : "GPL 3.0"

class

	LUAT_METRIQUE_UNITAIRE

		--
		-- Métrique lié à l'état instantané d'un fichier, hors
		-- comparaison
		--

inherit

	LUAT_METRIQUE

creation

	fabriquer

feature

	nom : STRING is "unitaire"

feature

	mesurer( p_actuel : LUAT_LISTAGE ) is
			-- stocke les mesures caractéristiques du listage
			-- correspondant
		do
			instruction := p_actuel.nb_ligne_code
			commentaire := p_actuel.nb_ligne_commentaire
			integralite := p_actuel.nb_ligne
		end

feature

	instruction : INTEGER
			-- nombre de lignes associées à des instructions

	commentaire : INTEGER
			-- nombre de lignes associées à des commentaires

	integralite : INTEGER
			-- nombre total de lignes

feature

	accumuler( p_contribution : like current ) is
		do
			instruction := instruction + p_contribution.instruction
			commentaire := commentaire + p_contribution.commentaire
			integralite := integralite + p_contribution.integralite
		ensure
			definition_1 : instruction = old instruction + p_contribution.instruction
			definition_2 : commentaire = old commentaire + p_contribution.commentaire
			definition_3 : integralite = old integralite + p_contribution.integralite
		end

	afficher( p_flux : OUTPUT_STREAM ) is
		local
			affichage : BOOLEAN
		do
			if configuration.filtre_unitaire.code then
				p_flux.put_string( once "code " )
				p_flux.put_integer( instruction )
				affichage := true
			end

			if configuration.filtre_unitaire.commentaire then
				if affichage then
					p_flux.put_spaces( 1 )
				end
				p_flux.put_string( once "comment " )
				p_flux.put_integer( commentaire )
				affichage := true
			end

			if configuration.filtre_unitaire.total then
				if affichage then
					p_flux.put_spaces( 1 )
				end
				p_flux.put_string( once "total " )
				p_flux.put_integer( integralite )
			end
		end

end
