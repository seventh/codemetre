indexing

   auteur : "seventh"
   license : "GPL 3.0"

class

   LUAT_COMMANDE_VERSION

      --
      -- Cette commande produit, sur la sortie standard,
      -- l'identifiant de l'exécutable
      --

inherit

   LUAT_COMMANDE

creation

   fabriquer

feature {}

   fabriquer is
         -- constructeur
      do
         -- rien de particulier
      end

feature

   executer is
      do
         std_output.put_string( once "codemetre " )
         std_output.put_string( version_majeure )
         std_output.put_string( version_mineure )
         std_output.put_new_line

         std_output.put_string( once "Copyright © 2005,2006,2007,2008,2009,2010,2011 Guillaume Lemaître%N" )

         std_output.put_string( traduire( once "[
This program comes with ABSOLUTELY NO WARRANTY. This is free software, and you
are welcome to redistribute it under certain conditions.


                                          ]" ) )
         std_output.flush
      end

end
