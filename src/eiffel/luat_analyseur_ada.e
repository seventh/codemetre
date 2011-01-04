indexing

   auteur : "seventh"
   license : "GPL 3.0"
   reference : "Ada 2005 reference manual, http://www.adaic.com/standards/05rm/html/RM-P.html"
   reference : "GCC 4.3.3 source code"

class

   LUAT_ANALYSEUR_ADA

      --
      -- Analyseur syntaxique du langage ADA
      --

inherit

   LUAT_ANALYSEUR
      redefine
         fabriquer,
         produire_code
      end

creation

   fabriquer

feature {}

   fabriquer is
      do
         precursor
         create avant.make_empty
      end

feature

   langage : STRING is "ada"

feature {LUAT_ANALYSEUR}

   produire_code is
      do
         -- On mémorise le lexème produit. Ceci est nécessaire pour
         -- pouvoir effectuer l'analyse lexicale correctement.
         -- Conserver la référence sans faire de copie est suffisant,
         -- car 'precursor' regénère une nouvelle instance à chaque
         -- appel

         avant := chaine
         precursor
      end

   avant : STRING
         -- dernier lexème reconnu

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

            when etat_apres_lettre then
               inspect caractere
               when '0' .. '9', 'A' .. 'Z', 'a' .. 'z' then
                  chaine.add_last( caractere )
               when '_' then
                  chaine.add_last( caractere )
                  etat := etat_apres_souligne_dans_identifiant
               else
                  produire_code
                  traiter_etat_initial
               end

            when etat_apres_souligne_dans_identifiant then
               inspect caractere
               when '0' .. '9', 'A' .. 'Z', 'a' .. 'z' then
                  chaine.add_last( caractere )
                  etat := etat_apres_lettre
               else
                  retenir_erreur( once "incomplete identifier" )
               end

            when etat_apres_chiffre then
               inspect caractere
               when '0' .. '9' then
                  chaine.add_last( caractere )
               when '_' then
                  chaine.add_last( caractere )
                  etat := etat_apres_souligne_dans_entier
               when '#', ':' then
                  chaine.add_last( caractere )
                  etat := etat_apres_base_dans_litteral_numerique
               when '.' then
                  chaine.add_last( caractere )
                  etat := etat_apres_separateur_dans_litteral_numerique
               when 'e', 'E' then
                  chaine.add_last( caractere )
                  etat := etat_apres_exposant
               else
                  produire_code
                  traiter_etat_initial
               end

            when etat_apres_souligne_dans_entier then
               if caractere.in_range( '0', '9' ) then
                  chaine.add_last( caractere )
                  etat := etat_apres_chiffre
               else
                  retenir_erreur( once "incomplete integer constant" )
               end

            when etat_apres_base_dans_litteral_numerique then
               inspect caractere
               when '0' .. '9', 'A' .. 'F', 'a' .. 'f' then
                  chaine.add_last( caractere )
                  etat := etat_apres_chiffre_dans_litteral_numerique_base
               else
                  retenir_erreur( once "forbidden character in based integer constant" )
               end

            when etat_apres_chiffre_dans_litteral_numerique_base then
               -- nombre entier basé après au moins un chiffre de la
               -- valeur dans la base

               inspect caractere
               when '0' .. '9', 'a' .. 'f', 'A' .. 'F' then
                  chaine.add_last( caractere )
               when '_' then
                  chaine.add_last( caractere )
                  etat := etat_apres_base_dans_litteral_numerique
               when '.' then
                  chaine.add_last( caractere )
                  etat := etat_apres_separateur_dans_litteral_numerique_base
               when '#', ':' then
                  chaine.add_last( caractere )
                  etat := etat_apres_valeur_dans_litteral_numerique_base
               else
                  retenir_erreur( once "wrong value in based integer constant" )
               end

            when etat_apres_separateur_dans_litteral_numerique_base then
               -- après séparateur décimal dans entier basé

               inspect caractere
               when '0' .. '9', 'A' .. 'F', 'a' .. 'f' then
                  chaine.add_last( caractere )
                  etat := etat_apres_chiffre_decimal_dans_litteral_numerique_base
               else
                  retenir_erreur( once "forbidden character in decimal part of based integer constant" )
               end

            when etat_apres_chiffre_decimal_dans_litteral_numerique_base then
               -- après au moins un chiffre de la partie décimale
               -- d'un entier basé

               inspect caractere
               when '0' .. '9', 'A' .. 'F', 'a' .. 'f' then
                  chaine.add_last( caractere )
               when '_' then
                  chaine.add_last( caractere )
                  etat := etat_apres_separateur_dans_litteral_numerique_base
               when '#', ':' then
                  chaine.add_last( caractere )
                  etat := etat_apres_valeur_dans_litteral_numerique_base
               else
                  retenir_erreur( once "forbidden character in decimal part of based integer constant" )
               end

            when etat_apres_valeur_dans_litteral_numerique_base then
               -- fin de la partie basée d'un entier basé

               inspect caractere
               when 'E', 'e' then
                  chaine.add_last( caractere )
                  etat := etat_apres_exposant
               else
                  produire_code
                  traiter_etat_initial
               end

            when etat_apres_exposant then
               -- début de l'exposant d'un nombre réel

               inspect caractere
               when '0' .. '9' then
                  chaine.add_last( caractere )
                  etat := etat_apres_chiffre_dans_exposant
               when '+', '-' then
                  chaine.add_last( caractere )
                  etat := etat_apres_separateur_dans_exposant
               else
                  retenir_erreur( once "incomplete exponent in integer constant" )
               end

            when etat_apres_chiffre_dans_exposant then
               -- après au moins un chiffre de l'exposant

               if caractere = '_' then
                  chaine.add_last( caractere )
                  etat := etat_apres_separateur_dans_exposant
               else
                  produire_code
                  traiter_etat_initial
               end

            when etat_apres_separateur_dans_exposant then
               -- dans l'exposant

               if caractere.in_range( '0', '9' ) then
                  chaine.add_last( caractere )
                  etat := etat_apres_chiffre_dans_exposant
               else
                  retenir_erreur( once "wrong exponent in integer constant" )
               end

            when etat_apres_separateur_dans_litteral_numerique then
               -- après le séparateur décimal

               inspect caractere
               when '0' .. '9' then
                  chaine.add_last( caractere )
                  etat := etat_apres_valeur_entiere_dans_litteral_numerique
               when '.' then
                  chaine.remove_last
                  produire_code
                  chaine.copy( once ".." )
                  produire_code
                  etat := etat_initial
               else
                  retenir_erreur( once "wrong decimal part in integer constant" )
               end

            when etat_apres_valeur_entiere_dans_litteral_numerique then
               -- après au moins un chiffre de la partie décimale

               inspect caractere
               when '0' .. '9' then
                  chaine.add_last( caractere )
               when '_' then
                  chaine.add_last( caractere )
                  etat := etat_apres_souligne_dans_partie_decimale
               when 'E', 'e' then
                  chaine.add_last( caractere )
                  etat := etat_apres_exposant
               else
                  produire_code
                  traiter_etat_initial
               end

            when etat_apres_souligne_dans_partie_decimale then
               inspect caractere
               when '0' .. '9' then
                  chaine.add_last( caractere )
                  etat := etat_apres_valeur_entiere_dans_litteral_numerique
               else
                  retenir_erreur( once "forbidden character in decimal part of integer constant" )
               end

            when etat_apres_apostrophe then
               inspect caractere
               when '%U' then
                  retenir_erreur( once "incomplete character constant" )
               else
                  chaine.add_last( caractere )
                  etat := etat_apres_apostrophe_caractere
               end

            when etat_apres_apostrophe_caractere then
               inspect caractere
               when '%'' then
                  chaine.add_last( caractere )
                  produire_code
                  etat := etat_initial
               else
                  retenir_erreur( once "incomplete character constant" )
               end

            when etat_apres_guillemets then
               inspect caractere
               when '%U' then
                  retenir_erreur( once "incomplete string constant" )
               when '%"' then
                  chaine.add_last( caractere )
                  etat := etat_apres_guillemets_dans_litteral_chaine
               else
                  chaine.add_last( caractere )
               end

            when etat_apres_guillemets_dans_litteral_chaine then
               if caractere = '%"' then
                  chaine.add_last( caractere )
                  etat := etat_apres_guillemets
               else
                  produire_code
                  traiter_etat_initial
               end

            when etat_apres_pourcentage then
               inspect caractere
               when ' ' .. '!', '#' .. '$', '&' .. '~' then
                  chaine.add_last( caractere )
               when '%%' then
                  chaine.add_last( caractere )
                  etat := etat_apres_pourcentage_dans_litteral_chaine
               else
                  retenir_erreur( once "forbidden character in character constant" )
               end

            when etat_apres_pourcentage_dans_litteral_chaine then
               if caractere = '%%' then
                  chaine.add_last( caractere )
                  etat := etat_apres_pourcentage
               else
                  produire_code
                  traiter_etat_initial
               end

            when etat_apres_point then
               if caractere = '.' then
                  chaine.add_last( caractere )
                  produire_code
                  etat := etat_initial
               else
                  produire_code
                  traiter_etat_initial
               end

            when etat_apres_barre_oblique then
               if caractere = '=' then
                  chaine.add_last( caractere )
                  produire_code
                  etat := etat_initial
               else
                  produire_code
                  traiter_etat_initial
               end

            when etat_apres_chevron_ouvrant then
               inspect caractere
               when '<', '=', '>' then
                  chaine.add_last( caractere )
                  produire_code
                  etat := etat_initial
               else
                  produire_code
                  traiter_etat_initial
               end

            when etat_apres_chevron_fermant then
               inspect caractere
               when '=', '>' then
                  chaine.add_last( caractere )
                  produire_code
                  etat := etat_initial
               else
                  produire_code
                  traiter_etat_initial
               end

            when etat_apres_deux_points then
               if caractere = '=' then
                  chaine.add_last( caractere )
                  produire_code
                  etat := etat_initial
               else
                  produire_code
                  traiter_etat_initial
               end

            when etat_apres_etoile then
               if caractere = '*' then
                  chaine.add_last( caractere )
                  produire_code
                  etat := etat_initial
               else
                  produire_code
                  traiter_etat_initial
               end

            when etat_apres_egal then
               if caractere = '>' then
                  chaine.add_last( caractere )
                  produire_code
                  etat := etat_initial
               else
                  produire_code
                  traiter_etat_initial
               end

            when etat_apres_tiret then
               if caractere = '-' then
                  chaine.add_last( caractere )
                  etat := etat_apres_double_tiret
               else
                  produire_code
                  traiter_etat_initial
               end

            when etat_apres_double_tiret then
               inspect caractere
               when '%U' then
                  produire_commentaire
                  produire_ligne
                  etat := etat_final
               when '%N' then
                  produire_commentaire
                  produire_ligne
                  etat := etat_initial
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

   etat_apres_lettre : INTEGER is unique
   etat_apres_souligne_dans_identifiant : INTEGER is unique

   etat_apres_chiffre : INTEGER is unique
   etat_apres_souligne_dans_entier : INTEGER is unique
   etat_apres_base_dans_litteral_numerique : INTEGER is unique
   etat_apres_chiffre_dans_litteral_numerique_base : INTEGER is unique
   etat_apres_separateur_dans_litteral_numerique_base : INTEGER is unique
   etat_apres_chiffre_decimal_dans_litteral_numerique_base : INTEGER is unique
   etat_apres_exposant : INTEGER is unique
   etat_apres_valeur_dans_litteral_numerique_base : INTEGER is unique
   etat_apres_chiffre_dans_exposant : INTEGER is unique
   etat_apres_separateur_dans_exposant : INTEGER is unique
   etat_apres_separateur_dans_litteral_numerique : INTEGER is unique
   etat_apres_valeur_entiere_dans_litteral_numerique : INTEGER is unique
   etat_apres_souligne_dans_partie_decimale : INTEGER is unique

   etat_apres_apostrophe : INTEGER is unique
   etat_apres_apostrophe_caractere : INTEGER is unique

   etat_apres_guillemets : INTEGER is unique
   etat_apres_guillemets_dans_litteral_chaine : INTEGER is unique

   etat_apres_pourcentage : INTEGER is unique
   etat_apres_pourcentage_dans_litteral_chaine : INTEGER is unique

   etat_apres_point : INTEGER is unique
   etat_apres_barre_oblique : INTEGER is unique
   etat_apres_chevron_ouvrant : INTEGER is unique
   etat_apres_chevron_fermant : INTEGER is unique
   etat_apres_deux_points : INTEGER is unique
   etat_apres_etoile : INTEGER is unique
   etat_apres_egal : INTEGER is unique

   etat_apres_tiret : INTEGER is unique
   etat_apres_double_tiret : INTEGER is unique

feature {}

   traiter_etat_initial is
         -- aucun préfixe
      do
         inspect caractere
         when '0' .. '9' then
            chaine.add_last( caractere )
            etat := etat_apres_chiffre
         when 'A' .. 'Z', 'a' .. 'z' then
            chaine.add_last( caractere )
            etat := etat_apres_lettre
         when '%'' then
            chaine.add_last( caractere )
            -- on considère qu'on a affaire à une simple apostrophe
            -- si cette apostrophe suit :
            -- * un identifiant (donc pas un mot-clef) ;
            -- * une parenthèse fermante ;
            -- * une constante littérale chaîne ou caractère ;
            if avant.is_empty then
               etat := etat_apres_apostrophe
            else
               inspect avant.first
               when 'A' .. 'Z', 'a' .. 'z' then
                  if avant.count = 2
                     and then ( avant.item( 1 ) = 'I' or avant.item( 1 ) = 'i' )
                     and then ( avant.item( 2 ) = 'N' or avant.item( 2 ) = 'n' )
                   then
                     etat := etat_apres_apostrophe
                  elseif avant.count = 4
                     and then ( avant.item( 1 ) = 'W' or avant.item( 1 ) = 'w' )
                     and then ( avant.item( 2 ) = 'H' or avant.item( 2 ) = 'h' )
                     and then ( avant.item( 3 ) = 'E' or avant.item( 3 ) = 'e' )
                     and then ( avant.item( 4 ) = 'N' or avant.item( 4 ) = 'n' )
                   then
                     etat := etat_apres_apostrophe
                  elseif avant.count = 5
                     and then ( avant.item( 1 ) = 'R' or avant.item( 1 ) = 'r' )
                     and then ( avant.item( 2 ) = 'A' or avant.item( 2 ) = 'a' )
                     and then ( avant.item( 3 ) = 'N' or avant.item( 3 ) = 'n' )
                     and then ( avant.item( 4 ) = 'G' or avant.item( 4 ) = 'g' )
                     and then ( avant.item( 5 ) = 'E' or avant.item( 5 ) = 'e' )
                   then
                     etat := etat_apres_apostrophe
                  else
                     produire_code
                     etat := etat_initial
                  end
               when '%"', '%'', ')' then
                  produire_code
                  etat := etat_initial
               else
                  etat := etat_apres_apostrophe
               end
            end
         when '%"' then
            chaine.add_last( caractere )
            etat := etat_apres_guillemets
         when '%%' then
            chaine.add_last( caractere )
            etat := etat_apres_pourcentage
         when '.' then
            chaine.add_last( caractere )
            etat := etat_apres_point
         when '/' then
            chaine.add_last( caractere )
            etat := etat_apres_barre_oblique
         when '<' then
            chaine.add_last( caractere )
            etat := etat_apres_chevron_ouvrant
         when '>' then
            chaine.add_last( caractere )
            etat := etat_apres_chevron_fermant
         when ':' then
            chaine.add_last( caractere )
            etat := etat_apres_deux_points
         when '*' then
            chaine.add_last( caractere )
            etat := etat_apres_etoile
         when '-' then
            chaine.add_last( caractere )
            etat := etat_apres_tiret
         when '=' then
            chaine.add_last( caractere )
            etat := etat_apres_egal
         when '&', '(', ')', '+', ',', ';', '|', '!', '[', ']' then
            chaine.add_last( caractere )
            produire_code
            etat := etat_initial
         when ' ', '%F', '%R', '%T' then
            -- les séparateurs ne sont pas mémorisés
            etat := etat_initial
         when '%N' then
            produire_ligne
            etat := etat_initial
         when '%U' then
            -- fin de fichier
            etat := etat_final
         else
            retenir_erreur( once "forbidden character" )
         end
      end

end
