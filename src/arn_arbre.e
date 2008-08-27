indexing

	auteur : "seventh"
	license : "GPL 3.0"
	reference : "Introduction à l'algorithmique - chapitre 14 - Cormen, Leiserson, Rivest"

class

	ARN_ARBRE[ E ]

		--
		-- Arbre binaire de recherche auto-équilibrant. Utilise une
		-- relation d'ordre pour pouvoir trier les éléments entre eux
		--

inherit

	ARN

creation

	fabriquer

feature {}

	fabriquer( p_ordre : CAP_ORDRE[ E ] ) is
		do
			ordre := p_ordre
			create nil.fabriquer_nil( current )
			racine := nil
			create pointeurs.with_capacity( 0, 0 )
		ensure
			est_vide
		end

feature

	ordre : CAP_ORDRE[ E ]
			-- relation d'ordre s'appliquant aux éléments du conteneur

feature

	nb_element : INTEGER
			-- nombre d'éléments du conteneur

	est_vide : BOOLEAN is
			-- n'y a-t-il aucun élément dans le conteneur ?
		do
			result := racine = nil
		ensure
			definition : result = ( nb_element = 0 )
		end

	vider is
			-- retire tous les élements du conteneur
		require
			appel_judicieux : not est_vide
		local
			i : INTEGER
		do
			-- invalidation de tous les itérateurs

			from i := pointeurs.lower
			variant pointeurs.upper - i
			until i > pointeurs.upper
			loop
				pointeurs.item( i ).pointer_hors_borne
				i := i + 1
			end

			-- purge de l'arbre

			racine := nil
			pointeurs.with_capacity( 0, 0 )
			nb_element := 0
		ensure
			est_vide
		end

feature

	ajouter( p_valeur : E ) is
			-- ajoute la valeur au conteneur
		local
			nouveau : ARN_NOEUD[ E ]
		do
			create nouveau.fabriquer( current )
			nouveau.met_etiquette( p_valeur )
			i_inserer( nouveau )
			nb_element := nb_element + 1
		ensure
			nb_element = old nb_element + 1
			est_present_exact( p_valeur )
		end

	inserer( p_valeur : E
				p_pointeur : ARN_ITERATEUR[ E ] ) is
			-- ajoute la valeur au conteneur, et y donne accès à travers
			-- le pointeur
		require
			pointeur_valide : p_pointeur /= void
		local
			nouveau : ARN_NOEUD[ E ]
		do
			create nouveau.fabriquer( current )
			nouveau.met_etiquette( p_valeur )
			i_inserer( nouveau )

			nb_element := nb_element + 1
			if p_pointeur.arbre /= current then
				if p_pointeur.est_attache then
					p_pointeur.detacher
				end
				p_pointeur.attacher( current )
			end
			p_pointeur.met_noeud( nouveau )
		ensure
			nb_element = old nb_element + 1
			est_present_exact( p_valeur )
			p_pointeur.dereferencer = p_valeur
		end

	retirer( p_pointeur : ARN_ITERATEUR[ E ] ) is
			-- ôte l'élément pointé du conteneur
		require
			pointeur_valide : p_pointeur.arbre = current and not p_pointeur.est_hors_borne
		do
			i_retirer( p_pointeur.noeud )
			nb_element := nb_element - 1
		ensure
			nb_element = old nb_element - 1
			pointeur_invalide : p_pointeur.est_hors_borne
		end

feature

	est_present( p_valeur : E ) : BOOLEAN is
			-- la valeur est-elle dans le conteneur ?
			-- utilise 'ordre.egal'
		do
			result := i_trouver( p_valeur ) /= nil
		end

	trouver( p_valeur : E
				p_pointeur : ARN_ITERATEUR[ E ] ) is
			-- donne accès à une valeur stockée à travers le pointeur
			-- utilise 'ordre.egal'
		require
			pointeur_valide : p_pointeur /= void
		do
			if p_pointeur.arbre /= current then
				if p_pointeur.est_attache then
					p_pointeur.detacher
				end
				p_pointeur.attacher( current )
			end
			p_pointeur.met_noeud( i_trouver( p_valeur ) )
		ensure
			definition : est_present( p_valeur ) = not p_pointeur.est_hors_borne
			element_pointe : est_present( p_valeur ) implies ordre.egal( p_pointeur.dereferencer, p_valeur )
		end

feature

	est_present_exact( p_valeur : E ) : BOOLEAN is
			-- la valeur est-elle dans le conteneur ?
			-- utilise '='
		do
			result := i_trouver_exact( p_valeur ) /= nil
		end

	trouver_exact( p_valeur : E
						p_pointeur : ARN_ITERATEUR[ E ] ) is
			-- donne accès à une valeur stockée à travers le pointeur
			-- utilise '='
		require
			pointeur_valide : p_pointeur /= void
		do
			if p_pointeur.arbre /= current then
				if p_pointeur.est_attache then
					p_pointeur.detacher
				end
				p_pointeur.attacher( current )
			end
			p_pointeur.met_noeud( i_trouver_exact( p_valeur ) )
		ensure
			definition : est_present_exact( p_valeur ) = not p_pointeur.est_hors_borne
			element_pointe : est_present_exact( p_valeur ) implies p_pointeur.dereferencer = p_valeur
		end

feature {}

	rotation_droite( p_noeud : ARN_NOEUD[ E ] ) is
			-- effectue l'opération de rotation droite sur le noeud
		local
			autre : ARN_NOEUD[ E ]
		do
			autre := p_noeud.fils_gauche
			p_noeud.met_fils_gauche( autre.fils_droite )
			if autre.fils_droite /= nil then
				autre.fils_droite.met_pere( p_noeud )
			end

			autre.met_pere( p_noeud.pere )

			if p_noeud.pere = nil then
				racine := autre
			elseif p_noeud.pere.fils_droite = p_noeud then
				p_noeud.pere.met_fils_droite( autre )
			else
				p_noeud.pere.met_fils_gauche( autre )
			end

			autre.met_fils_droite( p_noeud )
			p_noeud.met_pere( autre )
		end

	rotation_gauche( p_noeud : ARN_NOEUD[ E ] ) is
			-- effectue l'opération de rotation gauche sur le noeud
		local
			autre : ARN_NOEUD[ E ]
		do
			autre := p_noeud.fils_droite
			p_noeud.met_fils_droite( autre.fils_gauche )
			if autre.fils_gauche /= nil then
				autre.fils_gauche.met_pere( p_noeud )
			end

			autre.met_pere( p_noeud.pere )

			if p_noeud.pere = nil then
				racine := autre
			elseif p_noeud.pere.fils_gauche = p_noeud then
				p_noeud.pere.met_fils_gauche( autre )
			else
				p_noeud.pere.met_fils_droite( autre )
			end

			autre.met_fils_gauche( p_noeud )
			p_noeud.met_pere( autre )
		end

	i_inserer( p_noeud : ARN_NOEUD[ E ] ) is
		local
			x, y, z : ARN_NOEUD[ E ]
		do
			z := p_noeud

			from

				-- 1 - insertion classique dans un arbre binaire de
				-- recherche

				from
					y := nil
					x := racine
				until
					x = nil
				loop
					y := x
					if ordre.est_verifie( z.etiquette, x.etiquette ) then
						x := x.fils_gauche
					else
						x := x.fils_droite
					end
				end
				z.met_pere( y )
				if y = nil then
					racine := z
				elseif ordre.est_verifie( z.etiquette, y.etiquette ) then
					y.met_fils_gauche( z )
				else
					y.met_fils_droite( z )
				end

			until

				z.pere.couleur /= usine_couleur.rouge

			loop

				-- 2 - rééquilibrage de l'arbre avec mise-à-jour des
				-- couleurs

				if z.pere = z.pere.pere.fils_gauche then
					y := z.pere.pere.fils_droite
					if y.couleur = usine_couleur.rouge then
						z.pere.met_couleur( usine_couleur.noir )
						y.met_couleur( usine_couleur.noir )
						z.pere.pere.met_couleur( usine_couleur.rouge )
						z := z.pere.pere
					else
						if z = z.pere.fils_droite then
							z := z.pere
							rotation_gauche( z )
						end
						z.pere.met_couleur( usine_couleur.noir )
						z.pere.pere.met_couleur( usine_couleur.rouge )
						rotation_droite( z.pere.pere )
					end
				else
					y := z.pere.pere.fils_gauche
					if y.couleur = usine_couleur.rouge then
						z.pere.met_couleur( usine_couleur.noir )
						y.met_couleur( usine_couleur.noir )
						z.pere.pere.met_couleur( usine_couleur.rouge )
						z := z.pere.pere
					else
						if z = z.pere.fils_gauche then
							z := z.pere
							rotation_droite( z )
						end
						z.pere.met_couleur( usine_couleur.noir )
						z.pere.pere.met_couleur( usine_couleur.rouge )
						rotation_gauche( z.pere.pere )
					end
				end

			end

			racine.met_couleur( usine_couleur.noir )
		end

	i_retirer( p_noeud : ARN_NOEUD[ E ] ) is
		local
			x, y, z : ARN_NOEUD[ E ]
		do
			-- initialisation

			z := p_noeud
			reformer( z )

			-- 1 - suppression

			-- y est le noeud à supprimer

			if z.fils_gauche = nil
				or z.fils_droite = nil
			 then
				y := z
			else
				y := z.successeur
			end

			-- x est un fils non nil de y s'il y en a un, ou nil sinon

			if y.fils_gauche /= nil then
				x := y.fils_gauche
			else
				x := y.fils_droite
			end

			-- on détache y

			x.met_pere( y.pere )
			if y.pere = nil then
				racine := x
			elseif y = y.pere.fils_gauche then
				y.pere.met_fils_gauche( x )
			else
				y.pere.met_fils_droite( x )
			end

			if y /= z then
				z.met_etiquette( y.etiquette )
				deplacer( y, z )
			end

			-- 2 - si la suppression de y provoque un changement de la
			-- hauteur rouge de l'arbre, on rééquilibre l'arbre

			if y.couleur = usine_couleur.noir then
				from
				until
					x = racine
						or else x.couleur /= usine_couleur.noir
				loop
					if x = x.pere.fils_gauche then
						z := x.pere.fils_droite
						if z.couleur = usine_couleur.rouge then
							z.met_couleur( usine_couleur.noir )
							x.pere.met_couleur( usine_couleur.rouge )
							rotation_gauche( x.pere )
							z := x.pere.fils_droite
						end
						if z.fils_gauche.couleur = usine_couleur.noir
							and then z.fils_droite.couleur = usine_couleur.noir
						 then
							z.met_couleur( usine_couleur.rouge )
							x := x.pere
						else
							if z.fils_droite.couleur = usine_couleur.noir then
								z.fils_gauche.met_couleur( usine_couleur.noir )
								z.met_couleur( usine_couleur.rouge )
								rotation_droite( z )
								z := x.pere.fils_droite
							end
							z.met_couleur( x.pere.couleur )
							x.pere.met_couleur( usine_couleur.noir )
							z.fils_droite.met_couleur( usine_couleur.noir )
							rotation_gauche( x.pere )
							x := racine
						end
					else
						z := x.pere.fils_gauche
						if z.couleur = usine_couleur.rouge then
							z.met_couleur( usine_couleur.noir )
							x.pere.met_couleur( usine_couleur.rouge )
							rotation_droite( x.pere )
							z := x.pere.fils_gauche
						end
						if z.fils_droite.couleur = usine_couleur.noir
							and then z.fils_gauche.couleur = usine_couleur.noir
						 then
							z.met_couleur( usine_couleur.rouge )
							x := x.pere
						else
							if z.fils_gauche.couleur = usine_couleur.noir then
								z.fils_droite.met_couleur( usine_couleur.noir )
								z.met_couleur( usine_couleur.rouge )
								rotation_gauche( z )
								z := x.pere.fils_gauche
							end
							z.met_couleur( x.pere.couleur )
							x.pere.met_couleur( usine_couleur.noir )
							z.fils_droite.met_couleur( usine_couleur.noir )
							rotation_droite( x.pere )
							x := racine
						end
					end
				end
				x.met_couleur( usine_couleur.noir )
			end
		end

	i_trouver( p_valeur : E ) : ARN_NOEUD[ E ] is
		do
			from
				result := racine
			until
				result = nil
					or else ordre.egal( p_valeur, result.etiquette )
			loop
				if ordre.inferieur_strict( p_valeur, result.etiquette ) then
					result := result.fils_gauche
				else
					result := result.fils_droite
				end
			end
		ensure
			result /= nil implies ordre.egal( result.etiquette, p_valeur )
		end

	i_trouver_exact( p_valeur : E ) : ARN_NOEUD[ E ] is
		local
			autre : ARN_NOEUD[ E ]
		do
			from
				result := racine
			until
				result = nil
					or else ordre.egal( p_valeur, result.etiquette )
			loop
				if ordre.inferieur_strict( p_valeur, result.etiquette ) then
					result := result.fils_gauche
				else
					result := result.fils_droite
				end
			end

			--
			if result /= nil then
				from
					autre := result
				until
					autre = nil
						or else not ordre.egal( autre.etiquette, p_valeur )
						or else autre.etiquette = p_valeur
				loop
					autre := autre.predecesseur
				end

				if autre.etiquette = p_valeur then
					result := autre
				else
					from
						autre := result.successeur
					until
						autre = nil
							or else not ordre.egal( autre.etiquette, p_valeur )
							or else autre.etiquette = p_valeur
					loop
						autre := autre.successeur
					end

					if autre.etiquette = p_valeur then
						result := autre
					else
						result := nil
					end
				end
			end
		ensure
			result /= nil implies ordre.egal( result.etiquette, p_valeur )
		end

feature {ARN_ITERATEUR}

	racine : ARN_NOEUD[ E ]

feature {ARN}

	nil : ARN_NOEUD[ E ]

feature {ARN_ITERATEUR} -- gestion des itérateurs

	pointeurs : ARRAY[ ARN_ITERATEUR[ E ] ]

	est_connu( p_pointeur : ARN_ITERATEUR[ E ] ) : BOOLEAN is
		require
			pointeur_valide : p_pointeur.arbre = current
		do
			result := pointeurs.fast_has( p_pointeur )
		end

	abonner( p_pointeur : ARN_ITERATEUR[ E ] ) is
			-- enregistre un itérateur auprès de l'ensemble qu'il permet
			-- de parcourir
		require
			pointeur_valide : not est_connu( p_pointeur )
		do
			pointeurs.add_last( p_pointeur )
		ensure
			definition : est_connu( p_pointeur )
		end

	oublier( p_pointeur : ARN_ITERATEUR[ E ] ) is
			-- supprime du registre l'itérateur correspondant
		require
			pointeur_valide : est_connu( p_pointeur )
		local
			position : INTEGER
		do
			position := pointeurs.fast_index_of( p_pointeur, pointeurs.lower )
			pointeurs.put( pointeurs.last, position )
			pointeurs.remove_last
		ensure
			definition : not est_connu( p_pointeur )
		end

	reformer( p_supprime : ARN_NOEUD[ E ] ) is
			-- modifie l'ensemble des itérateurs pointants sur le noeud
			-- supprimé pour les faire pointer hors borne
		require
			noeud_valide : p_supprime.arbre = current and p_supprime /= nil
		local
			position : INTEGER
		do
			from position := pointeurs.lower
			variant pointeurs.upper - position
			until	position > pointeurs.upper
			loop
				if pointeurs.item( position ).noeud = p_supprime then
					pointeurs.item( position ).pointer_hors_borne
				end
				position := position + 1
			end
		end

	deplacer( p_origine : ARN_NOEUD[ E ]
				 p_destination : ARN_NOEUD[ E ] ) is
			-- modifie l'ensemble des itérateurs pointants sur un noeud
			-- pour leur en faire pointer un autre
		require
			origine_valide : p_origine.arbre = current and p_origine /= nil
			destination_valide : p_destination.arbre = current and p_destination /= nil
			appel_judicieux : p_origine /= p_destination
		local
			position : INTEGER
		do
			from position := pointeurs.lower
			variant pointeurs.upper - position
			until position > pointeurs.upper
			loop
				if pointeurs.item( position ).noeud = p_origine then
					pointeurs.item( position ).met_noeud( p_destination )
				end
				position := position + 1
			end
		end

end
