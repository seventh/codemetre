indexing

   auteur : "seventh"
   license : "GPL 3.0"

class

   LUAT_ANALYSEUR_SHELL

      --
      -- Analyseur syntaxique du langage SHELL et ses variantes bash,
      -- ksh et sh
      --

inherit

   LUAT_ANALYSEUR

creation

   fabriquer

feature

   langage : STRING is "shell"

feature {LUAT_ANALYSEUR}

   analyser is
      do
         check
            chaine.is_empty
            ligne.is_empty
         end

         indice_ligne := 1
         erreur := false
         message_erreur := once ""

         from etat := etat_initial
         until etat = etat_final
         loop
            fichier.avancer

            inspect etat
            when etat_initial then
               traiter_etat_initial

            -- code

            when etat_code then
               inspect caractere
               when '#' then
                  produire_code
                  chaine.add_last( caractere )
                  etat := etat_commentaire
               when ' ', '%F', '%R', '%T' then
                  produire_code
                  etat := etat_initial
               when '%N' then
                  produire_code
                  produire_ligne
                  etat := etat_initial
               when '%U' then
                  -- fin de fichier
                  produire_ligne
                  etat := etat_final
               else
                  chaine.add_last( caractere )
                  etat := etat_code
               end

            -- commentaire

            when etat_commentaire then
               inspect caractere
               when '%N' then
                  produire_commentaire
                  produire_ligne
                  etat := etat_initial
               when '%U' then
                  produire_commentaire
                  produire_ligne
                  etat := etat_final
               else
                  chaine.add_last( caractere )
               end

            else
               -- cas non géré

               retenir_erreur( once "lexer is buggy!" )
            end
         end

         -- gestion de l'erreur d'analyse

         if erreur then
            listage := void
            chaine.clear_count
            ligne.clear_count
         end

         check
            chaine.is_empty
            ligne.is_empty
         end
      end

feature {}

   etat_code : INTEGER is unique

   etat_commentaire : INTEGER is unique

feature {}

   traiter_etat_initial is
         -- aucun préfixe
      do
         inspect caractere
         when '#' then
            chaine.add_last( caractere )
            etat := etat_commentaire
         when ' ', '%F', '%R', '%T' then
            -- les séparateurs ne sont pas mémorisés
            etat := etat_initial
         when '%N' then
            produire_ligne
            etat := etat_initial
         when '%U' then
            -- fin de fichier
            produire_ligne
            etat := etat_final
         else
            chaine.add_last( caractere )
            etat := etat_code
         end
      end

end
