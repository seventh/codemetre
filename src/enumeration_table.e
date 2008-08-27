indexing

	auteur : "seventh"
	license : "GPL 3.0"

deferred class

	ENUMERATION_TABLE[ E ]

		--
		-- Ensemble de valeurs de même type prises dans un ordre
		-- (croissant) donné. Une énumération fait correspondre un
		-- identifiant, appelé 'indice', à chacune de ses valeurs.
		--
		-- Comme 'precedent' et 'suivant' retourne la valeur spéciale
		-- 'void' en cas d'échec, une énumération ne peut pas contenir
		-- cette valeur.
		--
		-- Implémentation à base d'une simple table :
		--  * 'contient' : coût en O( taille ) ;
		--  * 'en_indice' : coût en O( taille ) ;
		--  * 'en_valeur' : coût en O( 1 ).
		--

inherit

	ENUMERATION[ E ]

feature

	contient( p_valeur : E ) : BOOLEAN is
		do
			result := valeurs.fast_has( p_valeur )
		end

feature

	en_indice( p_valeur : E ) : INTEGER is
		do
			result := valeurs.fast_first_index_of( p_valeur )
		end

end
