indexing

   auteur : "seventh"
   license : "GPL 3.0"

class

   LUAT_ORDRE_LIGNE

      --
      -- Relation d'ordre entre LIGNE
      --

inherit

   CAP_ORDRE[ LUAT_LIGNE ]

feature

   est_verifie( a, b : LUAT_LIGNE ) : BOOLEAN is
      local
         i : INTEGER
         ordre : INTEGER
      do
         -- pour des raisons d'efficacité, on choisit une relation
         -- d'ordre un peu particulière, avant tout liée à la
         -- longueur des chaînes plutôt qu'à leur contenu

         ordre := a.nb_element.compare( b.nb_element )
         inspect ordre
         when -1 then
            result := true
         when 0 then
            from i := 0
            variant a.nb_element - 1 - i
            until i = a.nb_element
               or else a.element( i ) /= b.element( i )
            loop
               i := i + 1
            end

            if i = a.nb_element then
               result := true
            else -- if i < a.nb_element then
               result := ordre_source.est_verifie( a.element( i ),
                                                   b.element( i ) )
            end
         else
            -- cette clause 'else' est obligatoire pour ne pas faire
            -- planter l'exécutable à l'exécution.
            -- result := false
         end
      end

feature {}

   ordre_source : LUAT_ORDRE_SOURCE is
         -- ordre utilitaire entre SOURCE
      once
         create result
      end

end
