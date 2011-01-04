indexing

   auteur : "seventh"
   license : "GPL 3.0"

class

   LUAT_LOT_BLANC

      --
      -- Itérateur (à l'infini) de lot vide : toutes les entrées sont
      -- vides
      --

inherit

   LUAT_LOT

creation

   fabriquer

feature {}

   fabriquer is
         -- constructeur
      do
      end

feature

   entree : STRING is
      attribute
      ensure
         definition : result = void
      end

   entree_courte : STRING is
      attribute
      ensure
         definition : result = void
      end

   lire is
      do
      end

   est_epuise : BOOLEAN is true

   clore is
      do
      end

end
