indexing

   auteur : "seventh"
   license : "GPL 3.0"

class

   LUAT_ORDRE_SOURCE

      --
      -- Relation d'ordre entre SOURCE. Si les deux sources sont du
      -- même type, ils sont comparés à l'aide de la relation d'ordre
      -- associée à ce type. Sinon on compare les noms de type.
      --

inherit

   CAP_ORDRE[ LUAT_SOURCE ]
      redefine
         trichotomie
      end

feature

   est_verifie( a, b : LUAT_SOURCE ) : BOOLEAN is
      do
         if a.est_code xor b.est_commentaire then
            result := a.lexeme <= b.lexeme
         else
            result := a.est_code
         end
      end

feature

   trichotomie( a, b : LUAT_SOURCE ) : INTEGER is
      do
         if a.est_code xor b.est_commentaire then
            result := a.lexeme.compare( b.lexeme )
         elseif a.est_code then
            result := -1
         else -- if b.est_code then
            result := 1
         end
      end

end
