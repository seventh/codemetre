indexing

   auteur : "seventh"
   license : "GPL 3.0"

class

   LUAT_COMMANDE_UNITAIRE

      --
      -- Cette commande affiche les métriques unitaires demandées pour
      -- un source donné
      --

inherit

   LUAT_COMMANDE

creation

   fabriquer

feature {}

   fabriquer( p_analyseur : LUAT_ANALYSEUR
              p_nom_fichier : STRING ) is
         -- constructeur
      require
         analyseur_valide : p_analyseur /= void
         nom_valide : p_nom_fichier /= void
      do
         analyseur := p_analyseur
         nom_fichier := p_nom_fichier
      ensure
         analyseur_ok : analyseur = p_analyseur
         nom_ok : p_nom_fichier = p_nom_fichier
      end

feature

   executer is
      require
         not analyseur.est_utilise_fabrique
      local
         source : LUAT_LISTAGE
         metrique : LUAT_METRIQUE_UNITAIRE
      do
         -- chargement du fichier

         source := analyseur.lire( nom_fichier )

         -- production des métriques

         if source /= void then
            -- mesure

            create metrique.fabriquer
            metrique.mesurer( source )

            bilan.accumuler( analyseur.langage, metrique )

            -- sortie

            std_output.put_string( nom_fichier )
            std_output.put_string( once " (" )
            std_output.put_string( analyseur.langage )
            std_output.put_string( once ") " )

            metrique.afficher( std_output )

            std_output.put_new_line
            std_output.flush

            -- production du fichier d'analyse

            if configuration.unitaire.examen then
               produire_analyse( nom_fichier, source )
            end
         end
      end

end
