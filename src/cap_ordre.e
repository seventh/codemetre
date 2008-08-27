indexing

	auteur : "seventh"
	license : "GPL 3.0"

deferred class

	CAP_ORDRE[ E ]

		--
		-- Interface d'une relation d'ordre (total ou partiel).
		--
		-- Une relation d'ordre R est définie par trois propriétés :
		--  * réflexivité : a R a
		--  * antisymétrie : ( a R b et b R a ) ==> a = b
		--  * transitivité : ( a R b et b R c ) ==> a R c
		--
		-- La réflexivité permet de différencier une relation d'ordre
		-- d'un ordre strict (qui n'est donc pas une relation d'ordre).
		--

feature -- relation fondamentale

	est_verifie( a, b : E ) : BOOLEAN is
			-- la relation d'ordre entre a et b est-elle vérifiée ?
		deferred
		end

feature

	comparable( a, b : E ) : BOOLEAN is
			-- deux éléments sont dits comparables lorsque l'une au
			-- moins des deux relations est vérifiée :
			--  * est_verifie( a, b )
			--  * est_verifie( b, a )
		do
			result := est_verifie( b, a )
				or else est_verifie( a, b )
		ensure
			definition : result = ( est_verifie( a, b ) or est_verifie( b, a ) )
		end

feature -- notations usuelles

	inferieur_strict( a, b : E ) : BOOLEAN is
			-- a < b
		require
			comparable( a, b )
		do
			result := not est_verifie( b, a )
		ensure
			definition : result = not est_verifie( b, a )
		end

	inferieur_ou_egal( a, b : E ) : BOOLEAN is
			-- a <= b
		require
			comparable( a, b )
		do
			result := est_verifie( a, b )
		ensure
			definition : result = not inferieur_strict( b, a )
		end

	superieur_strict( a, b : E ) : BOOLEAN is
			-- a > b
		require
			comparable( a, b )
		do
			result := not est_verifie( a, b )
		ensure
			definition : result = inferieur_strict( b, a )
		end

	superieur_ou_egal( a, b : E ) : BOOLEAN is
			-- a >= b
		require
			comparable( a, b )
		do
			result := est_verifie( b, a )
		ensure
			definition : result = not inferieur_strict( a, b )
		end

	egal( a, b : E ) : BOOLEAN is
			-- a = b
		require
			comparable( a, b )
		do
			result := est_verifie( b, a )
				and then est_verifie( a, b )
		ensure
			definition : result = ( not inferieur_strict( a, b ) and not inferieur_strict( b, a ) )
		end

	different( a, b : E ) : BOOLEAN is
			-- a /= b
		require
			comparable( a, b )
		do
			-- Pour des raisons de performance, on utilise le résultat
			-- de 'egal', dont l'évaluation nécessite au plus la
			-- vérification de la relation d'ordre dans les deux sens,
			-- là où l'utilisation de xor obligerait à réaliser les deux
			-- comparaisons systématiquement.

			result := not egal( a, b )
		ensure
			definition : result = ( inferieur_strict( a, b ) or inferieur_strict( b, a ) )
		end

feature

	trichotomie( a, b : E ) : INTEGER is
			-- permet de distinguer trois cas : infériorité stricte,
			-- égalité ou supériorité stricte
		require
			comparable( a, b )
		do
			if not est_verifie( a, b ) then
				-- not( a <= b ) <==> a > b
				result := 1
			elseif not est_verifie( b, a ) then
				-- not( b <= a ) <==> a < b
				result := -1
			end
		ensure
			domaine : result.in_range( -1, 1 )
			definition_1 : ( result = -1 ) = inferieur_strict( a, b )
			definition_2 : ( result =  0 ) = egal( a, b )
			definition_3 : ( result = +1 ) = superieur_strict( a, b )
		end

end
