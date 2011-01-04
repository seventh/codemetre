indexing

   auteur : "seventh"
   license : "GPL 3.0"

class

   LUAT_METRIQUE_NORMAL

      --
      -- Métrique dont le sens est directement interprétable
      --

inherit

   LUAT_METRIQUE_DIFFERENTIEL

creation

   fabriquer

feature

   nom : STRING is "normal"

feature

   a : INTEGER
         -- nombre de ligne de l'ancienne version

   met_a( p_a : INTEGER ) is
         -- modifie la valeur de 'a'
      require
         a_valide : p_a >= 0
                    c.in_range( 0, p_a.min( n ) )
      do
         a := p_a
      ensure
         a_ok : a = p_a
      end

   n : INTEGER
         -- nombre de lignes de la nouvelle version

   met_n( p_n : INTEGER ) is
         -- modifie la valeur de 'n'
      require
         n_valide : p_n >= 0
                    c.in_range( 0, a.min( p_n ) )
      do
         n := p_n
      ensure
         n_ok : n = p_n
      end

   c : INTEGER
         -- nombre de lignes communes entre l'ancienne et la nouvelle
         -- version

   met_c( p_c : INTEGER ) is
         -- modifie la valeur de 'c'
      require
         c_valide : p_c.in_range( 0, a.min( n ) )
      do
         c := p_c
      ensure
         c_ok : c = p_c
      end

feature

   mesurer( p_ancien, p_nouvel : LUAT_LISTAGE ) is
      do
         if p_ancien = void then
            a := 0
            n := p_nouvel.nb_ligne
            c := 0
         elseif p_nouvel = void then
            a := p_ancien.nb_ligne
            n := 0
            c := 0
         else
            a := p_ancien.nb_ligne
            n := p_nouvel.nb_ligne
            if p_nouvel.est_equivalent( p_ancien ) then
               c := n
            else
               c := nb_ligne_partage( p_ancien.contenu, p_nouvel.contenu )
            end
         end
      end

   accumuler( p_contribution : like current ) is
      do
         a := a + p_contribution.a
         n := n + p_contribution.n
         c := c + p_contribution.c
      ensure
         definition_1 : a = old a + p_contribution.a
         definition_2 : n = old n + p_contribution.n
         definition_3 : c = old c + p_contribution.c
      end

   afficher( p_flux : OUTPUT_STREAM ) is
      do
         p_flux.put_string( once "A " )
         p_flux.put_integer( a )

         p_flux.put_spaces( 1 )

         p_flux.put_string( once "N " )
         p_flux.put_integer( n )

         p_flux.put_spaces( 1 )

         p_flux.put_string( once "C " )
         p_flux.put_integer( c )
      end

end
