indexing

   auteur : "seventh"
   license : "GPL 3.0"

deferred class

   LUAT_METRIQUE_DIFFERENTIEL

      --
      -- Interface commune de métrique
      --

inherit

   LUAT_METRIQUE

feature

   nom : STRING is
         -- identifiant du modèle de comparaison
      deferred
      end

feature

   mesurer( p_ancien, p_nouvel : LUAT_LISTAGE ) is
         -- réalise l'analyse différentielle entre les deux listages
         -- et stocke le résultat
      require
         au_moins_un : p_ancien /= void or p_nouvel /= void
      deferred
      end

feature {}

   nb_ligne_partage( p_x, p_y : COLLECTION[ LUAT_LIGNE ] ) : INTEGER is
         -- calcul la longueur d'une plus-longue sous-suite commune
         -- de p_x et de p_y.
         -- utilise '=' pour comparer deux éléments
      require
         x_valide : p_x /= void
         y_valide : p_y /= void
      local
         i, j : INTEGER
         courant, precedent, tmp : ARRAY[ INTEGER ]
      do
         -- calcul de la longueur

         create courant.make( p_y.lower - 1, p_y.upper )
         create precedent.make( p_y.lower - 1, p_y.upper )

         from i := p_x.lower
         variant p_x.upper - i
         until i > p_x.upper
         loop
            tmp := precedent
            precedent := courant
            courant := tmp

            from j := p_y.lower
            variant p_y.upper - j
            until j > p_y.upper
            loop
               if p_x.item( i ) = p_y.item( j ) then
                  courant.put( precedent.item( j - 1 ) + 1, j )
               else
                  courant.put( precedent.item( j ).max( courant.item( j - 1 ) ), j )
               end
               j := j + 1
            end

            i := i + 1
         end

         -- terminaison

         result := courant.last
      end

end
