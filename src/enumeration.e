indexing

	auteur : "seventh"
	license : "GPL 3.0"

deferred class

	ENUMERATION[ E ]

		--
		-- Ensemble de valeurs de même type prises dans un ordre
		-- (croissant) donné. Une énumération fait correspondre un
		-- identifiant, appelé 'indice', à chacune de ses valeurs.
		--
		-- Comme 'precedent' et 'suivant' retourne la valeur spéciale
		-- 'void' en cas d'échec, une énumération ne peut pas contenir
		-- cette valeur.
		--

feature {}

	fabriquer( p_valeurs : COLLECTION[ E ] ) is
			-- constructeur
		require
			valeurs_valide( p_valeurs )
		do
			valeurs := p_valeurs
		ensure
			valeurs_ok : valeurs = p_valeurs
		end

feature

	valeurs_valide( p_valeurs : COLLECTION[ E ] ) : BOOLEAN is
			-- vrai si et seulement si la liste de valeurs ne contient
			-- pas de doublon, ni la valeur spéciale 'void'
		local
			i : INTEGER
		do
			-- recherche de la valeur spéciale 'void'
			result := not p_valeurs.fast_has( void )

			-- recherche des doublons. Pour chaque valeur, on regarde si
			-- dans la suite de la liste on retrouve la même valeur
			if result then
				from i := p_valeurs.lower
				variant p_valeurs.upper - i
				until i > p_valeurs.upper
					or not result
				loop
					result := not p_valeurs.valid_index( p_valeurs.fast_index_of( p_valeurs.item( i ), i + 1 ) )
					i := i + 1
				end
			end
		end

feature

	taille : INTEGER is
			-- nombre d'éléménts de l'énumération
		do
			result := valeurs.count
		ensure
			densite : result = ( maximum - minimum + 1 )
		end

feature

	contient( p_valeur : E ) : BOOLEAN is
			-- l'énumération permet-t-elle d'atteindre la valeur demandée ?
		require
			valeur_valide : p_valeur /= void
		deferred
		end

	premier : E is
			-- première valeur
		do
			result := valeurs.first
		ensure
			indice_minimum : en_indice( result ) = minimum
		end

	dernier : E is
			-- dernière valeur
		do
			result := valeurs.last
		ensure
			indice_maximum : en_indice( result ) = maximum
		end

feature

	indice_valide( p_indice : INTEGER ) : BOOLEAN is
			-- l'indice est-il valide ?
		do
			result := valeurs.valid_index( p_indice )
		ensure
			definition : result = p_indice.in_range( minimum, maximum )
		end

	minimum : INTEGER is
			-- premier indice valide
		do
			result := valeurs.lower
		ensure
			premiere_valeur : en_valeur( result ) = premier
		end

	maximum : INTEGER is
			-- dernier indice valide
		do
			result := valeurs.upper
		ensure
			derniere_valeur : en_valeur( result ) = dernier
		end

feature

	precedent( p_valeur : E ) : E is
			-- valeur précédente si elle existe, 'void' sinon
		require
			valeur_valide : contient( p_valeur )
		do
			if p_valeur = premier then
				result := void
			else
				result := en_valeur( en_indice( p_valeur ) - 1 )
			end
		ensure
			indice_precedent : p_valeur /= premier implies en_indice( p_valeur ) = en_indice( result ) + 1
			borne_inferieure : p_valeur = premier implies result = void
		end

	suivant( p_valeur : E ) : E is
			-- valeur suivante si elle existe, 'void' sinon
		require
			valeur_valide : contient( p_valeur )
		do
			if p_valeur = dernier then
				result := void
			else
				result := en_valeur( en_indice( p_valeur ) + 1 )
			end
		ensure
			indice_suivant : p_valeur /= dernier implies en_indice( p_valeur ) = en_indice( result ) - 1
			borne_superieure : p_valeur = dernier implies result = void
		end

	precedent_circulaire( p_valeur : E ) : E is
			-- valeur précédente si elle existe, 'dernier' sinon
		require
			valeur_valide : contient( p_valeur )
		do
			if p_valeur = premier then
				result := dernier
			else
				result := en_valeur( en_indice( p_valeur ) - 1 )
			end
		ensure
			definition : p_valeur = premier and result = dernier
							 or en_indice( p_valeur ) = en_indice( result ) + 1
		end

	suivant_circulaire( p_valeur : E ) : E is
			-- valeur suivante si elle existe, 'premier' sinon
		require
			valeur_valide : contient( p_valeur )
		do
			if p_valeur = dernier then
				result := premier
			else
				result := en_valeur( en_indice( p_valeur ) + 1 )
			end
		ensure
			definition : p_valeur = dernier and result = premier
							 or en_indice( p_valeur ) = en_indice( result ) - 1
		end

feature

	en_indice( p_valeur : E ) : INTEGER is
			-- conversion en un entier
		require
			valeur_valide : contient( p_valeur )
		deferred
		ensure
			indice_valide( result )
			reciproque : en_valeur( result ) = p_valeur
		end

	en_valeur( p_indice : INTEGER ) : E is
			-- conversion depuis un entier
		require
			indice_valide( p_indice )
		do
			result := valeurs.item( p_indice )
		ensure
			valeur_valide : contient( result )
			reciproque : en_indice( result ) = p_indice
		end

feature {ENUMERATION}

	valeurs : COLLECTION[ E ]
			-- ensemble des valeurs de l'énumération par ordre croissant

end
