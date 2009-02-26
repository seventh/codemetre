indexing

	auteur : "seventh"
	license : "GPL 3.0"
	reference : "Introduction à l'algorithmique - chapitre 14 - Cormen, Leiserson, Rivest"

class

	ARN_NOEUD[ E ]

		--
		-- Noeud interne d'un Arbre Rouge et Noir
		--

inherit

	ARN

creation {ARN_ARBRE}

	fabriquer, fabriquer_nil

feature {}

	fabriquer( p_arbre : ARN_ARBRE[ E ] ) is
			-- crée un noeud quelconque, en l'attachant à l'arbre voulu
			-- puis en l'initialisant
		require
			appel_judicieux : not est_attache
		do
			attacher( p_arbre )
			initialiser
		ensure
			est_attache
			couleur = couleurs.rouge
			pere = arbre.nil
			fils_gauche = arbre.nil
			fils_droite = arbre.nil
		end

	fabriquer_nil( p_arbre : ARN_ARBRE[ E ] ) is
			-- crée le noeud spécifique 'nil', en l'attachant à l'arbre
			-- voulu et en l'initialisant spécifiquement
		require
			appel_judicieux : not est_attache
		do
			attacher( p_arbre )
			initialiser_nil
		ensure
			est_attache
			couleur = couleurs.noir
			pere = current
			fils_gauche = current
			fils_droite = current
		end

feature {ARN_ARBRE}

	attacher( p_arbre : ARN_ARBRE[ E ] ) is
			-- déclare l'arbre voulu comme propriétaire du noeud
		require
			appel_judicieux : not est_attache
		do
			arbre := p_arbre
		ensure
			est_attache
		end

	detacher is
			-- déclare le noeud comme indépendant de tout arbre
		require
			appel_judicieux : est_attache
			lien_pere : pere.fils_gauche /= current and pere.fils_droite /= current
			lien_fils : fils_gauche.pere /= current and fils_droite.pere /= current
		do
		ensure
			not est_attache
		end

feature

	est_attache : BOOLEAN is
			-- le noeud est-il inclus dans un arbre ?
		do
			result := arbre /= void
		ensure
			definition : result = ( arbre /= void )
		end

	arbre : ARN_ARBRE[ E ]
			-- arbre auquel appartient le noeud

feature {ARN_ARBRE}

	initialiser is
			-- initialise le noeud comme un noeud quelconque de l'arbre
		do
			couleur := couleurs.rouge
			pere := arbre.nil
			fils_gauche := arbre.nil
			fils_droite := arbre.nil
		ensure
			couleur = couleurs.rouge
			pere = arbre.nil
			fils_gauche = arbre.nil
			fils_droite = arbre.nil
		end

	initialiser_nil is
			-- initialise le noeud comme le noeud spécial 'nil'
		do
			couleur := couleurs.noir
			pere := current
			fils_gauche := current
			fils_droite := current
		ensure
			couleur = couleurs.noir
			pere = current
			fils_gauche = current
			fils_droite = current
		end

feature {ARN_ARBRE}

	couleur : ARN_COULEUR is
			-- couleur du noeud
		require
			est_attache
		attribute
		ensure
			couleurs.contient( result )
		end

	met_couleur( p_couleur : ARN_COULEUR ) is
			-- modifie la couleur du noeud
		require
			est_attache
			couleur_valide : couleurs.contient( p_couleur )
		do
			couleur := p_couleur
		ensure
			couleur_ok : couleur = p_couleur
		end

feature {ARN_ARBRE, ARN_NOEUD}

	pere : like current is
			-- ascendant du noeud
		require
			est_attache
		attribute
		ensure
			meme_arbre : result.pere.arbre = arbre
		end

	met_pere( p_noeud : like current ) is
			-- modifie l'ascenant du noeud
		require
			est_attache
			noeud_valide : p_noeud.arbre = arbre
		do
			pere := p_noeud
		ensure
			pere_ok : pere = p_noeud
		end

feature {ARN_ARBRE, ARN_NOEUD}

	fils_gauche : like current is
			-- premier descendant du noeud
		require
			est_attache
		attribute
		ensure
			meme_arbre : result.pere.arbre = arbre
		end

	met_fils_gauche( p_noeud : like current ) is
			-- modifie le premier descendant
		require
			est_attache
			noeud_valide : p_noeud.arbre = arbre
		do
			fils_gauche := p_noeud
		ensure
			fils_gauche_ok : fils_gauche = p_noeud
		end

feature {ARN_ARBRE, ARN_NOEUD}

	fils_droite : like current is
			-- second descendant du noeud
		require
			est_attache
		attribute
		ensure
			meme_arbre : result.pere.arbre = arbre
		end

	met_fils_droite( p_noeud : like current ) is
			-- modifie le second descendant
		require
			est_attache
			noeud_valide : p_noeud.arbre = arbre
		do
			fils_droite := p_noeud
		ensure
			fils_droite_ok : fils_droite = p_noeud
		end

feature

	etiquette : E is
			-- valeur portée par le noeud
		require
			est_attache
		attribute
		end

	met_etiquette( p_valeur : E ) is
			-- modifie la valeur portée par le noeud
		require
			est_attache
		do
			etiquette := p_valeur
		ensure
			etiquette_ok : etiquette = p_valeur
		end

feature {ARN}

	minimum : like current is
			-- noeud d'étiquette minimale du sous-arbre enraciné en ce
			-- noeud
		require
			appel_judicieux : current /= arbre.nil
		do
			from result := current
			until result.fils_gauche = arbre.nil
			loop
				result := result.fils_gauche
			end
		ensure
			ordre_respecte : arbre.ordre.inferieur_ou_egal( result.etiquette, etiquette )
		end

	maximum : like current is
			-- noeud d'étiquette maximale du sous-arbre enraciné en ce
			-- noeud
		require
			appel_judicieux : current /= arbre.nil
		do
			from result := current
			until result.fils_droite = arbre.nil
			loop
				result := result.fils_droite
			end
		ensure
			ordre_respecte : arbre.ordre.superieur_ou_egal( result.etiquette, etiquette )
		end

	predecesseur : like current is
			-- noeud d'étiquette directement inférieure ou égale à
			-- l'étiquette de ce noeud. nil si un tel noeud n'existe pas.
		require
			appel_judicieux : current /= arbre.nil
		local
			noeud : ARN_NOEUD[ E ]
		do
			if fils_gauche /= arbre.nil then
				result := fils_gauche.maximum
			else
				from
					noeud := current
					result := pere
				until result = arbre.nil
					or else noeud /= result.fils_gauche
				loop
					noeud := result
					result := noeud.pere
				end
			end
		ensure
			autre_noeud : result /= current
			ordre_respecte : result /= arbre.nil implies arbre.ordre.inferieur_ou_egal( result.etiquette, etiquette )
		end

	successeur : like current is
			-- noeud d'étiquette directement supérieure ou égale à
			-- l'étiquette de ce noeud. nil si un tel noeud n'existe pas.
		require
			appel_judicieux : current /= arbre.nil
		local
			noeud : ARN_NOEUD[ E ]
		do
			if fils_droite /= arbre.nil then
				result := fils_droite.minimum
			else
				from
					noeud := current
					result := pere
				until result = arbre.nil
					or else noeud /= result.fils_droite
				loop
					noeud := result
					result := noeud.pere
				end
			end
		ensure
			autre_noeud : result /= current
			ordre_respecte : result /= arbre.nil implies arbre.ordre.superieur_ou_egal( result.etiquette, etiquette )
		end

end
