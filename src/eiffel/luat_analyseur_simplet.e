indexing

   auteur : "seventh"
   license : "GPL 3.0"

class

   LUAT_ANALYSEUR_SIMPLET

      --
      -- Analyseur lexical d'aucun langage en particulier. Toute
      -- ligne non vide une fois expurgés ses éventuels préfixes et
      -- suffixes blancs est considérée comme une instruction.
      --

inherit

   LUAT_ANALYSEUR
      rename
         fabriquer as fabriquer_analyseur
      end

creation

   fabriquer

feature {}

   fabriquer( p_langage : STRING ) is
         -- constructeur
      do
         fabriquer_analyseur
         langage := p_langage
      ensure
         langage_ok : langage = p_langage
      end

feature

   langage : STRING

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
               inspect caractere
               when ' ', '%F', '%R', '%T' then
                  -- les séparateurs ne sont pas mémorisés
               when '%N' then
                  produire_ligne
               when '%U' then
                  -- fin de fichier
                  produire_ligne
                  etat := etat_final
               else
                  chaine.add_last( caractere )
                  etat := etat_code
               end

            -- code

            when etat_code then
               inspect caractere
               when '%N' then
                  filtrer_blancs_terminaux
                  if not chaine.is_empty then
                     produire_code
                  end
                  produire_ligne
                  etat := etat_initial
               when '%U' then
                  -- fin de fichier
                  filtrer_blancs_terminaux
                  if not chaine.is_empty then
                     produire_code
                  end
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

feature {}

   filtrer_blancs_terminaux is
         -- supprime les blancs en fin de chaîne
      local
         i : INTEGER
      do
         from i := chaine.upper
         variant i - chaine.lower
         until i < chaine.lower
            or else ( chaine.item( i ) /= ' '
                      and chaine.item( i ) /= '%F'
                      and chaine.item( i ) /= '%R'
                      and chaine.item( i ) /= '%T' )
         loop
            i := i - 1
         end
         chaine.keep_head( i - chaine.lower + 1 )
      end

end
