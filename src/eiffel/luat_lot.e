indexing

   auteur : "seventh"
   license : "GPL 3.0"

deferred class

   LUAT_LOT

      --
      -- Interface générique d'un itérateur de lot de fichiers
      --

inherit

   LUAT_GLOBAL

feature

   entree : STRING is
         -- dernière entrée lue du lot, et void lorsque celui-ci est
         -- épuisé
      deferred
      end

   entree_courte : STRING is
         -- sous-chaîne de l'entrée. La définition de cette
         -- sous-chaîne est propre à chaque lot
      deferred
      end

   lire is
         -- met à disposition la prochaine entrée du lot
      deferred
      end

   est_epuise : BOOLEAN is
         -- vrai si et seulement s'il n'y a plus d'entrées dans le lot
      deferred
      end

   clore is
         -- suspend l'accès au descripteur
      deferred
      end

end
