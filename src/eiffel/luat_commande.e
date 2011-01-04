indexing

   auteur : "seventh"
   license : "GPL 3.0"

deferred class

   LUAT_COMMANDE

      --
      -- Demande telle qu'elle est formulée par l'utilisateur. La
      -- demande se charge d'analyser le(s) fichier(s) pour ensuite
      -- fournir un résultat.
      --

inherit

   LUAT_GLOBAL

feature

   analyseur : LUAT_ANALYSEUR
         -- analyseur syntaxique utilisé pour la lecture du fichier

   nom_fichier : STRING
         -- chemin du fichier à analyser

feature

   executer is
         -- réalise la demande
      deferred
      end

feature {}

   produire_analyse( p_nom : STRING
                     p_listage : LUAT_LISTAGE ) is
         -- enregistre le résultat de l'analyse lexicale dans un
         -- fichier dont le nom est le paramètre suffixé de ".cma"
      require
         nom_valide : p_nom /= void
         listage_valide : p_listage /= void
      local
         nom_sortie : STRING
         sortie : TEXT_FILE_WRITE
      do
         nom_sortie := p_nom.twin
         nom_sortie.append( once ".cma" )
         create sortie.connect_to( nom_sortie )
         if sortie.is_connected then
            p_listage.afficher( sortie )
            sortie.disconnect
         else
            std_error.put_string( traduire( once "*** Error: file %"" ) )
            std_error.put_string( nom_sortie )
            std_error.put_string( traduire( once "%" cannot be written" ) )
            std_error.put_new_line
         end
      end

end
