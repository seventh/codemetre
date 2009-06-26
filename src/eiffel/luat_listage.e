indexing

	auteur : "seventh"
	license : "GPL 3.0"

class

	LUAT_LISTAGE

		--
		-- Ensemble de lignes de source
		--

inherit

	ANY
		redefine
			copy, is_equal
		end

creation

	fabriquer

feature {}

	fabriquer( p_nom : STRING
				  p_langage : STRING ) is
			-- constructeur
		require
			nom_valide : p_nom /= void
			langage_valide : p_langage /= void
		do
			langage := p_langage
			nom := p_nom

			create contenu.with_capacity( 0 )
		ensure
			nom_ok : nom = p_nom
			langage_ok : langage = p_langage
			est_vide
		end

feature

	langage : STRING
			-- langage du listage

	nom : STRING
			-- nom du fichier dont est issu le listage

feature

	est_vide : BOOLEAN is
			-- vrai si et seulement si le nombre de ligne est nul
		do
			result := contenu.is_empty
		ensure
			definition : result = ( nb_ligne = 0 )
		end

	nb_ligne : INTEGER is
			-- nombre total de lignes
		do
			result := contenu.count
		end

feature

	indice_valide( p_indice : INTEGER ) : BOOLEAN is
			-- vrai si et seulement si l'indice permet d'accéder à une
			-- ligne
		do
			result := contenu.valid_index( p_indice )
		ensure
			definition : result = p_indice.in_range( 0, nb_ligne - 1 )
		end

	ligne( p_indice : INTEGER ) : LUAT_LIGNE is
			-- accesseur de ligne
		require
			indice_valide( p_indice )
		do
			result := contenu.item( p_indice )
		end

feature

	ajouter( p_ligne : LUAT_LIGNE ) is
			-- ajoute une ligne en fin de listage
		require
			ligne_valide : p_ligne /= void and then not p_ligne.est_vide
		do
			contenu.add_last( p_ligne )
		ensure
			nb_ligne = old nb_ligne + 1
			ligne( nb_ligne - 1 ) = p_ligne
		end

feature

	nb_ligne_code : INTEGER is
			-- nombre de lignes contenant du code
		local
			i : INTEGER
		do
			from i := contenu.lower
			variant contenu.upper - i
			until i > contenu.upper
			loop
				if contenu.item( i ).contient_code then
					result := result + 1
				end
				i := i + 1
			end
		ensure
			domaine : result.in_range( 0, nb_ligne )
		end

	nb_ligne_commentaire : INTEGER is
			-- nombre de lignes contenant au moins un commentaire
		local
			i : INTEGER
		do
			from i := contenu.lower
			variant contenu.upper - i
			until i > contenu.upper
			loop
				if contenu.item( i ).contient_commentaire then
					result := result + 1
				end
				i := i + 1
			end
		ensure
			domaine : result.in_range( 0, nb_ligne )
		end

feature

	est_equivalent( p_autre : like current ) : BOOLEAN is
			-- vrai si et seulement si les deux instances ont le même
			-- contenu. La comparaison ligne à ligne est effectuée avec
			-- '='
		require
			autre_valide : p_autre /= void
		do
			result := contenu.is_equal( p_autre.contenu )
		end

	afficher( p_flux : OUTPUT_STREAM ) is
			-- produit une forme lisible sur le flux correspondant
		local
			i : INTEGER
		do
			p_flux.put_string( once "$LANGAGE:" )
			p_flux.put_string( langage )
			p_flux.put_string( once "$%N" )

			from i := contenu.lower
			variant contenu.upper - i
			until i > contenu.upper
			loop
				contenu.item( i ).afficher( p_flux )
				i := i + 1
			end
		end

feature

	copy( p_source : like current ) is
			-- réalise une copie de la source
		do
			nom := p_source.nom
			langage := p_source.langage
			contenu := p_source.contenu.twin
		end

	is_equal( p_autre : like current ) : BOOLEAN is
			-- les deux instances sont-elles équivalentes ?
		do
			result := nom.is_equal( p_autre.nom )
				and then langage.is_equal( p_autre.langage )
				and then contenu.is_equal( p_autre.contenu )
		end

feature {LUAT_LISTAGE, LUAT_METRIQUE_DIFFERENTIEL}

	contenu : FAST_ARRAY[ LUAT_LIGNE ]
			-- ensemble des lignes du listage

end
