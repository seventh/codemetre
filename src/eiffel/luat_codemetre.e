indexing

   auteur : "seventh"
   license : "GPL 3.0"

class

   LUAT_CODEMETRE

      --
      -- Outil de métrologie pour différents langages de
      -- programmation
      --

inherit

   ARGUMENTS

   LUAT_GLOBAL

creation

   principal

feature

   principal is
         -- programme principal
      local
         analyseur : LUAT_LIGNE_COMMANDE_ANALYSEUR
      do
         -- analyse de la ligne de commande et exécution simultanée
         -- des commandes que celle-ci provoque

         create analyseur.fabriquer

         analyseur.analyser

         -- une seule commande peut être différée (le statut final)

         if analyseur.commande_statut /= void then
            analyseur.commande_statut.executer
         elseif analyseur.aucune_commande_executee then
            analyseur.usage
         end
      end

end
