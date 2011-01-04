indexing

   auteur : "seventh"
   license : "GPL 3.0"

deferred class

   LUAT_ELEMENT_CONFIGURABLE

      --
      -- Interface minimale d'un élément pouvant être configuré par
      -- ligne de commande ou bien dans le fichier de configuration
      -- du projet.
      --
      -- Typiquement, le choix du modèle de comparaison, ou
      -- l'affichage compact sont des éléments configurables
      --

feature

   clef : STRING is
         -- identifiant de l'élément. Doit être unique dans
         -- l'ensemble à discriminer considéré.
      deferred
      ensure
         contrainte_minimale : not result.is_empty
      end

end
