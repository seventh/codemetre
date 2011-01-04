indexing

   auteur : "seventh"
   license : "GPL 3.0"

class

   LUAT_OPTION_UNITAIRE

      --
      -- Ensemble des options et états associés pour les commandes
      -- unitaires
      --

inherit

   LUAT_OPTION
      redefine
         initialiser
      end

creation

   fabriquer

feature

   initialiser is
         -- reconfigure l'instance aux valeurs par défaut
      do
         filtre.met( true, true, false )
      ensure then
         filtre_code : filtre.code
         filtre_commentaire : filtre.commentaire
         filtre_total : not filtre.total
      end

end
