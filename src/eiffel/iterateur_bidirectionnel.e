indexing

   auteur : "seventh"
   license : "GPL 3.0"

deferred class

   ITERATEUR_BIDIRECTIONNEL[ E ]

      --
      -- Itérateur pouvant se déplacer dans les deux sens d'une même
      -- direction
      --

inherit

   ITERATEUR_UNIDIRECTIONNEL[ E ]

feature

   pointer_dernier is
         -- déplace l'itérateur sur le dernier élément de l'itération
      deferred
      end

   reculer is
         -- déplace l'itérateur vers l'élément précédent
      require
         not est_hors_borne
      deferred
      end

end
