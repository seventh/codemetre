indexing

   auteur : "seventh"
   license : "GPL 3.0"

class

   LUAT_CONFIGURATION

      --
      -- Regroupe l'ensemble des choix par défaut :
      -- * soit ceux fait par l'utilisateur à travers son fichier
      -- de configuration personnel ;
      -- * soit ceux de l'application.
      --
      -- Ces choix incluent :
      -- * les associations entre extension de fichier et langage ;
      -- * le modèle de comparaison ;
      -- * la production d'un bilan en fin d'analyse ;
      -- * la sortie allégée lors des comparaisons ;
      -- * les filtres à appliquer / les sorties à produire.
      --

inherit

   LUAT_GLOBAL

   DANG_ADAPTATEUR

creation

   fabriquer

feature {}

   fabriquer is
         -- constructeur
      local
         i : INTEGER
      do
         -- options
         create differentiel.fabriquer
         create unitaire.fabriquer

         -- analyseurs lexicaux initiaux
         create analyseurs.with_capacity( 7 )
         analyseurs.add_last( analyseur_ada )
         analyseurs.add_last( analyseur_c )
         analyseurs.add_last( analyseur_c_plus_plus )
         analyseurs.add_last( analyseur_eiffel )
         analyseurs.add_last( analyseur_html )
         analyseurs.add_last( analyseur_shell )
         analyseurs.add_last( analyseur_sql )

         -- langages associés
         create langages.with_capacity( analyseurs.count + 1 )
         from i := analyseurs.lower
         variant analyseurs.upper - i
         until i > analyseurs.upper
         loop
            langages.add_last( analyseurs.item( i ).langage )
            i := i + 1
         end
         langages.add_last( analyseur_lot )
         tri.sort( langages )

         -- associations entre extension de fichier et langage
         create associations.fabriquer( create {LUAT_ORDRE_SUFFIXE} )
      end

feature

   appliquer_choix_initial is
         -- appliquer la configuration initiale, celle par défaut
      local
         suffixe : LUAT_SUFFIXE
      do
         configuration_par_defaut := true

         --
         -- section : 'diff'
         --

         differentiel.initialiser

         --
         -- section : 'language'
         --

         -- Ada

         create suffixe.fabriquer( once ".adb", analyseur_ada.langage )
         associations.ajouter( suffixe )
         create suffixe.fabriquer( once ".adc", analyseur_ada.langage )
         associations.ajouter( suffixe )
         create suffixe.fabriquer( once ".ads", analyseur_ada.langage )
         associations.ajouter( suffixe )

         -- C

         create suffixe.fabriquer( once ".c", analyseur_c.langage )
         associations.ajouter( suffixe )
         create suffixe.fabriquer( once ".h", analyseur_c.langage )
         associations.ajouter( suffixe )

         -- C++

         create suffixe.fabriquer( once ".C", analyseur_c_plus_plus.langage )
         associations.ajouter( suffixe )
         create suffixe.fabriquer( once ".cc", analyseur_c_plus_plus.langage )
         associations.ajouter( suffixe )
         create suffixe.fabriquer( once ".cpp", analyseur_c_plus_plus.langage )
         associations.ajouter( suffixe )
         create suffixe.fabriquer( once ".hh", analyseur_c_plus_plus.langage )
         associations.ajouter( suffixe )
         create suffixe.fabriquer( once ".hpp", analyseur_c_plus_plus.langage )
         associations.ajouter( suffixe )

         -- Eiffel

         create suffixe.fabriquer( once ".e", analyseur_eiffel.langage )
         associations.ajouter( suffixe )

         -- HTML

         create suffixe.fabriquer( once ".html", analyseur_html.langage )
         associations.ajouter( suffixe )

         -- Shell

         create suffixe.fabriquer( once ".bash", analyseur_shell.langage )
         associations.ajouter( suffixe )
         create suffixe.fabriquer( once ".ksh", analyseur_shell.langage )
         associations.ajouter( suffixe )
         create suffixe.fabriquer( once ".sh", analyseur_shell.langage )
         associations.ajouter( suffixe )

         -- SQL

         create suffixe.fabriquer( once ".sql", analyseur_sql.langage )
         associations.ajouter( suffixe )

         -- Lot codemètre

         create suffixe.fabriquer( once ".cmb", analyseur_lot )
         associations.ajouter( suffixe )

         --
         -- section : 'unit'
         --

         unitaire.initialiser
      end

   appliquer_choix_fichier is
         -- surcharge la configuration actuelle avec les éléments
         -- précisés dans le fichier de configuration de l'utilisateur
      local
         chargeur : DANG_ANALYSEUR
      do
         -- lecture

         create chargeur.fabriquer
         chargeur.ouvrir( nom_fichier_configuration )
         if chargeur.est_ouvert then
            configuration_par_defaut := false
            chargeur.lire( current )
            chargeur.fermer
         end
      end

   appliquer_choix_demande is
         -- surcharge la configuration actuelle avec les éléments
         -- précisés en ligne de commande
      do
         -- ici on devrait retrouver l'équivalent de :
         --
         --  {LUAT_LIGNE_COMMANDE_ANALYSEUR}.analyser
         --
         -- mais la question sera alors d'initaliser l'instance
         -- globale de LUAT_CONFIGURATION
      end

feature

   analyseur( p_nom_fichier : STRING ) : LUAT_ANALYSEUR is
         -- analyseur associé par la configuration (fichier de
         -- configuration ou ligne de commande) au fichier,
         -- éventuellement en fonction de son suffixe
      local
         i : INTEGER
         suffixe : LUAT_SUFFIXE
         it : ARN_ITERATEUR[ LUAT_SUFFIXE ]
      do
         if analyseur_force /= void then
            result := analyseur_force
         else
            i := p_nom_fichier.last_index_of( '.' )
            if not p_nom_fichier.valid_index( i ) then
                  std_error.put_string( traduire( once "Error: extension of file %"" ) )
                  std_error.put_string( p_nom_fichier )
                  std_error.put_string( traduire( once "%" is unknown" ) )
                  std_error.put_new_line
                  std_error.flush
            else
               create suffixe.fabriquer( p_nom_fichier.substring( i, p_nom_fichier.upper ),
                                         void )
               create it.attacher( associations )
               associations.trouver( suffixe, it )
               if not it.est_hors_borne then
                  result := trouver_analyseur( it.dereferencer.langage )
               else
                  std_error.put_string( traduire( once "Error: extension of file %"" ) )
                  std_error.put_string( p_nom_fichier )
                  std_error.put_string( traduire( once "%" is unknown" ) )
                  std_error.put_new_line
                  std_error.flush
               end
               it.detacher
            end
         end
      end

   est_lot( p_nom_fichier : STRING ) : BOOLEAN is
         -- vrai si et seulement si l'extension du nom passé en
         -- argument est celle d'un lot codemetre
      require
         nom_valide : not p_nom_fichier.is_empty
      local
         i : INTEGER
         suffixe : LUAT_SUFFIXE
         it : ARN_ITERATEUR[ LUAT_SUFFIXE ]
      do
         -- vu l'utilisation qui est faite de cette méthode, on ne
         -- remonte aucun message sur la sortie d'erreur. Ceci sera
         -- logiquement fait par la méthode 'analyseur'.

         i := p_nom_fichier.last_index_of( '.' )
         if p_nom_fichier.valid_index( i ) then
            create suffixe.fabriquer( p_nom_fichier.substring( i, p_nom_fichier.upper ),
                                      void )
            create it.attacher( associations )
            associations.trouver( suffixe, it )
            if not it.est_hors_borne then
               result := trouver_langage( it.dereferencer.langage ) = analyseur_lot
            end
            it.detacher
         end
      end

feature

   differentiel : LUAT_OPTION_DIFFERENTIEL
         -- ensemble des options associées aux commandes de comptage
         -- différentiel

   unitaire : LUAT_OPTION_UNITAIRE
         -- ensemble des options associées aux commandes de comptage
         -- unitaire

feature

   afficher is
         -- produit, sur la sortie standard, un fichier de
         -- configuration équivalent à la configuration actuelle
      local
         l : INTEGER
         it : ARN_ITERATEUR[ LUAT_SUFFIXE ]
         aucune_entree : BOOLEAN
         langage : STRING
      do
         -- en-tête

         std_output.put_string( once "# " )
         std_output.put_string( version_majeure )
         std_output.put_string( version_mineure )
         if not configuration_par_defaut then
            std_output.put_string( once " & " )
            std_output.put_string( nom_fichier_configuration )
         end
         std_output.put_new_line

         --
         -- section : 'diff'
         --

         std_output.put_string( once "[diff]%N" )
         differentiel.afficher( std_output )

         --
         -- section : 'language'
         --

         std_output.put_string( once "[language]%N" )

         create it.attacher( associations )
         from l := langages.lower
         variant langages.upper - l
         until l > langages.upper
         loop
            std_output.put_character( '%T' )
            langage := langages.item( l )
            langage.to_lower
            std_output.put_string( langage )
            std_output.put_string( once " := " )
            aucune_entree := true
            from it.pointer_premier
            until it.est_hors_borne
            loop
               if it.dereferencer.langage = langages.item( l ) then
                  if not aucune_entree then
                     std_output.put_string( once ", " )
                  end
                  std_output.put_string( it.dereferencer.suffixe )
                  aucune_entree := false
               end
               it.avancer
            end
            std_output.put_new_line
            l := l + 1
         end
         it.detacher

         --
         -- section 'unit'
         --

         std_output.put_string( once "[unit]%N" )
         unitaire.afficher( std_output )
      end

feature

   forcer_analyseur( p_langage : STRING ) : BOOLEAN is
         -- force le choix du langage (s'il existe)
      require
         langage_valide : not p_langage.is_empty
      local
         a : LUAT_ANALYSEUR
      do
         a := trouver_analyseur( p_langage )

         if a /= void then
            analyseur_force := a
            result := true
         end
      end

   forcer_metrique( p_metrique : STRING ) : BOOLEAN is
         -- choisit une métrique par son nom
      require
         metrique_valide : not p_metrique.is_empty
      local
         modele : LUAT_METRIQUE_DIFFERENTIEL
      do
         modele := trouver_metrique( p_metrique )

         if modele /= void then
            differentiel.met_modele( modele )
            result := true
         end
      end

feature

   appliquer_configuration_unitaire is
         -- modifie la configuration de tous les analyseurs
      do
         analyseurs.do_all( agent {LUAT_ANALYSEUR}.appliquer( unitaire.filtre ) )
      end

   appliquer_configuration_differentiel is
         -- modifie la configuration de tous les analyseurs
      do
         analyseurs.do_all( agent {LUAT_ANALYSEUR}.appliquer( differentiel.filtre ) )
         analyseurs.do_all( agent {LUAT_ANALYSEUR}.embrayer_fabrique )
      end

feature {LUAT_CONFIGURATION}

   analyseur_force : LUAT_ANALYSEUR
         -- analyseur à utiliser indépendamment du suffixe du fichier

   associations : ARN_ARBRE[ LUAT_SUFFIXE ]

feature {DANG_ANALYSEUR}

   ajouter( p_section : STRING
            p_variable : STRING
            p_valeur : STRING ) is
      local
         nouvel_analyseur : LUAT_ANALYSEUR_SIMPLET
         suffixe : LUAT_SUFFIXE
         it : ARN_ITERATEUR[ LUAT_SUFFIXE ]
         l : STRING
      do
         inspect p_section

         when "analysis" then
            avertir( once "analysis section is obsolete. Use diff:dump and unit:dump instead" )

         when "diff" then
            inspect p_variable
            when "dump" then
               avertir( once "diff:dump is not a list" )
            when "filter" then
               avertir( once "diff:filter can only have a single value" )
            when "model" then
               avertir( once "diff:model is not a list" )
            when "short" then
               avertir( once "diff:short is not a list" )
            when "status" then
               avertir( once "diff:status is not a list" )
            else
               avertir( once "unknown parameter in diff section" )
            end

         when "language" then
            -- retrouver l'analyseur ne peut reposer entièrement sur
            -- l'ensemble des associations connues. Si ce dernier
            -- devient vide à un moment donné, on ne saurait plus
            -- ensuite associer langages et extensions de fichier.

            l := trouver_langage( p_variable )

            if l = void then
               create nouvel_analyseur.fabriquer( p_variable.twin )
               analyseurs.add_last( nouvel_analyseur )
               tri.add( langages, nouvel_analyseur.langage )
               l := nouvel_analyseur.langage
            end

            create suffixe.fabriquer( p_valeur.twin, l )
            create it.attacher( associations )
            associations.trouver( suffixe, it )
            if it.est_hors_borne then
               associations.ajouter( suffixe )
            elseif it.dereferencer.langage /= suffixe.langage then
               avertir( once "suffix is already associated with another language" )
            else
               avertir( once "redundant association" )
            end
            it.detacher

         when "unit" then
            inspect p_variable
            when "dump" then
               avertir( once "unit:dump is not a list" )
            when "filter" then
               ajouter_filtre( unitaire.filtre, p_valeur )
            when "status" then
               avertir( once "unit:status is not a list" )
            else
               avertir( once "unknown parameter in unit section" )
            end

         else
            -- section inconnue
            avertir( once "unknown section" )
         end
      end

   effacer( p_section : STRING
            p_variable : STRING ) is
      local
         it : ARN_ITERATEUR[ LUAT_SUFFIXE ]
         l : STRING
      do
         inspect p_section

         when "analysis" then
            avertir( once "analysis section is obsolete. Use diff:dump and unit:dump instead" )

         when "diff" then
            inspect p_variable
            when "dump" then
               avertir( once "diff:dump is not clearable" )
            when "filter" then
               avertir( once "diff:filter is mandatory" )
            when "model" then
               avertir( once "diff:model is mandatory" )
            when "short" then
               avertir( once "diff:short is not clearable" )
            when "status" then
               avertir( once "diff:status is not clearable" )
            else
               avertir( once "unknown parameter in diff section" )
            end

         when "language" then
            -- retrouver l'analyseur ne peut reposer entièrement sur
            -- l'ensemble des associations connues. Si ce dernier
            -- devient vide à un moment donné, on ne saurait plus
            -- ensuite associer langages et extensions de fichier.

            l := trouver_langage( p_variable )
            if l /= void then
               create it.attacher( associations )
               from it.pointer_premier
               until it.est_hors_borne
               loop
                  if it.dereferencer.langage = l then
                     associations.retirer( it )
                     it.pointer_premier
                  else
                     it.avancer
                  end
               end
               it.detacher
            end

         when "unit" then
            inspect p_variable
            when "dump" then
               avertir( once "unit:dump is not clearable" )
            when "filter" then
               avertir( once "unit:filter is mandatory" )
            when "status" then
               avertir( once "unit:status is not clearable" )
            else
               avertir( once "unknown parameter in unit section" )
            end

         else
            -- section inconnue
            avertir( once "unknown section" )
         end
      end

   imposer( p_section : STRING
            p_variable : STRING
            p_valeur : STRING ) is
      do
         inspect p_section

         when "analysis" then
            avertir( once "analysis section is obsolete. Use diff:dump and unit:dump instead" )

         when "diff" then
            inspect p_variable
            when "dump" then
               differentiel.met_examen( p_valeur.to_boolean )
            when "filter" then
               imposer_filtre( differentiel.filtre, p_valeur )
            when "model" then
               if not forcer_metrique( p_valeur ) then
                  avertir( once "unknown diff model" )
               end
            when "short" then
               if p_valeur.is_boolean then
                  differentiel.met_abrege( p_valeur.to_boolean )
               else
                  avertir( once "invalid boolean value" )
               end
            when "status" then
               if p_valeur.is_boolean then
                  differentiel.met_statut( p_valeur.to_boolean )
               else
                  avertir( once "invalid boolean value" )
               end
            else
               avertir( once "unknown parameter in diff section" )
            end

         when "language" then
            effacer( p_section, p_variable )
            ajouter( p_section, p_variable, p_valeur )

         when "unit" then
            inspect p_variable
            when "dump" then
               unitaire.met_examen( p_valeur.to_boolean )
            when "filter" then
               imposer_filtre( unitaire.filtre, p_valeur )
            when "status" then
               if p_valeur.is_boolean then
                  unitaire.met_statut( p_valeur.to_boolean )
               else
                  avertir( once "invalid boolean value" )
               end
            else
               avertir( once "unknown parameter in unit section" )
            end

         else
            -- section inconnue
            avertir( once "unknown section" )
         end
      end

   retirer( p_section : STRING
            p_variable : STRING
            p_valeur : STRING ) is
      local
         suffixe : LUAT_SUFFIXE
         it : ARN_ITERATEUR[ LUAT_SUFFIXE ]
         l : STRING
      do
         inspect p_section

         when "analysis" then
            avertir( once "analysis section is obsolete. Use diff:dump and unit:dump instead" )

         when "diff" then
            inspect p_variable
            when "dump" then
               avertir( once "diff:dump is not a list" )
            when "filter" then
               avertir( once "diff:filter can only have a single value" )
            when "model" then
               avertir( once "diff:model is not a list" )
            when "short" then
               avertir( once "diff:short is not a list" )
            when "status" then
               avertir( once "diff:status is not a list" )
            else
               avertir( once "unknown parameter in diff section" )
            end

         when "language" then
            -- retrouver l'analyseur ne peut reposer entièrement sur
            -- l'ensemble des associations connues. Si ce dernier
            -- devient vide à un moment donné, on ne saurait plus
            -- ensuite associer langages et extensions de fichier.

            l := trouver_langage( p_variable )

            if l /= void then
               create suffixe.fabriquer( p_valeur.twin, l )
               create it.attacher( associations )
               associations.trouver( suffixe, it )
               if it.est_hors_borne then
                  avertir( once "no such association exists" )
               else
                  associations.retirer( it )
               end
               it.detacher
            end

         when "unit" then
            inspect p_variable
            when "dump" then
               avertir( once "unit:dump is not a list" )
            when "filter" then
               retirer_filtre( unitaire.filtre, p_valeur )
            when "status" then
               avertir( once "unit:status is not a list" )
            else
               avertir( once "unknown parameter in unit section" )
            end

         else
            -- section inconnue
            avertir( once "unknown section" )
         end
      end

   avertir( p_message : STRING ) is
      do
         std_error.put_string( traduire( once "Syntax error" ) )
         std_error.put_string( once " (" )
         std_error.put_string( nom_fichier_configuration )
         std_error.put_string( once "): " )
         std_error.put_string( traduire( p_message ) )
         std_error.put_new_line
         std_error.put_new_line
      end

feature {LUAT_CONFIGURATION}

   configuration_par_defaut : BOOLEAN

   nom_fichier_configuration : STRING is
         -- chemin absolu d'accès au fichier de configuration :
         -- - sous UNIX : équivalent à $HOME/.codemetrerc
         -- - sous WINDOWS : équivalent à %APPDATA%\codemetre.ini
      local
         sys : SYSTEM
      once
         -- l'implémentation a un biais : on détermine
         -- l'environnement par rapport à la définition ou non de la
         -- variable utilisée spécifiquement dans celui-ci

         -- environnement UNIX

         if result = void then
            result := sys.get_environment_variable( once "HOME" )
            if result /= void then
               result.append_string( once "/.codemetrerc" )
            end
         end

         -- environnement WINDOWS

         if result = void then
            result := sys.get_environment_variable( once "APPDATA" )
            if result /= void then
               result.append_string( once "\codemetre.ini" )
            end
         end

         -- environnement inconnu

         if result = void then
            create result.make_empty
         end
      ensure
         definition : result /= void
      end

feature {}

   analyseur_ada : LUAT_ANALYSEUR is
      once
         create {LUAT_ANALYSEUR_ADA} result.fabriquer
      end

   analyseur_c : LUAT_ANALYSEUR is
      once
         create {LUAT_ANALYSEUR_FAMILLE_C} result.fabriquer( once "c" )
      end

   analyseur_c_plus_plus : LUAT_ANALYSEUR is
      once
         create {LUAT_ANALYSEUR_FAMILLE_C} result.fabriquer( once "c++" )
      end

   analyseur_eiffel : LUAT_ANALYSEUR is
      once
         create {LUAT_ANALYSEUR_EIFFEL} result.fabriquer
      end

   analyseur_html : LUAT_ANALYSEUR is
      once
         create {LUAT_ANALYSEUR_HTML} result.fabriquer
      end

   analyseur_shell : LUAT_ANALYSEUR is
      once
         create {LUAT_ANALYSEUR_SHELL} result.fabriquer
      end

   analyseur_sql : LUAT_ANALYSEUR is
      once
         create {LUAT_ANALYSEUR_SQL} result.fabriquer
      end

   analyseur_lot : STRING is "batch"

   analyseurs : FAST_ARRAY[ LUAT_ANALYSEUR ]
         -- ensemble des analyseurs lexicaux

   trouver_analyseur( p_clef : STRING ) : LUAT_ANALYSEUR is
      require
         clef_valide : not p_clef.is_empty
      local
         i : INTEGER
      do
         i := trouver_element_configurable( analyseurs, p_clef )

         if analyseurs.valid_index( i ) then
            result := analyseurs.item( i )
         end
      end

feature {}

   langages : FAST_ARRAY[ STRING ]
         -- ensemble trié des langages reconnus (y compris le langage
         -- de lot de codemetre)

   trouver_langage( p_langage : STRING ) : STRING is
         -- permet de retrouver l'instance utilisée en interne d'une
         -- chaîne de valeur équivalente
      require
         clef_valide : not p_langage.is_empty
      local
         i : INTEGER
      do
         from i := langages.lower
         variant langages.upper - i
         until i > langages.upper
            or else langages.item( i ).is_equal( p_langage )
         loop
            i := i + 1
         end

         if langages.valid_index( i ) then
            result := langages.item( i )
         end
      ensure
         definition : result /= void implies result.is_equal( p_langage )
      end

feature {}

   extensions_lot : FAST_ARRAY[ STRING ]
         -- liste des extensions associées aux lots codemetre

feature {}

   metrique_effort : LUAT_METRIQUE_DIFFERENTIEL is
      once
         result := metriques.item( 0 )
      end

   metrique_normal : LUAT_METRIQUE_DIFFERENTIEL is
      once
         result := metriques.item( 1 )
      end

   metriques : FAST_ARRAY[ LUAT_METRIQUE_DIFFERENTIEL ] is
      once
         create result.with_capacity( 2 )
         result.add_last( create {LUAT_METRIQUE_EFFORT}.fabriquer )
         result.add_last( create {LUAT_METRIQUE_NORMAL}.fabriquer )
      end

   trouver_metrique( p_clef : STRING ) : LUAT_METRIQUE_DIFFERENTIEL is
      require
         clef_valide : not p_clef.is_empty
      local
         i : INTEGER
      do
         i := trouver_element_configurable( metriques, p_clef )

         if metriques.valid_index( i ) then
            result := metriques.item( i )
         end
      end

feature {}

   ajouter_filtre( p_filtre : LUAT_FILTRE
                   p_variable : STRING ) is
      require
         filtre_valide : p_filtre /= void
         variable_valide : not p_variable.is_empty
      do
         inspect p_variable
         when "code" then
            p_filtre.met_code( true )
         when "comment" then
            p_filtre.met_commentaire( true )
         when "total" then
            p_filtre.met_total( true )
         else
            avertir( once "unknown filter" )
         end
      end

   imposer_filtre( p_filtre : LUAT_FILTRE
                   p_variable : STRING ) is
      require
         filtre_valide : p_filtre /= void
         variable_valide : not p_variable.is_empty
      do
         inspect p_variable
         when "code" then
            p_filtre.met( true, false, false )
         when "comment" then
            p_filtre.met( false, true, false )
         when "total" then
            p_filtre.met( false, false, true )
         else
            avertir( once "unknown filter" )
         end
      end

   retirer_filtre( p_filtre : LUAT_FILTRE
                   p_variable : STRING ) is
      require
         filtre_valide : p_filtre.choix_est_effectue
         variable_valide : not p_variable.is_empty
      local
         old_filtre : like p_filtre
      do
         old_filtre := p_filtre.twin

         inspect p_variable
         when "code" then
            p_filtre.met_code( false )
         when "comment" then
            p_filtre.met_commentaire( false )
         when "total" then
            p_filtre.met_total( false )
         else
            avertir( once "unknown filter" )
         end

         if not p_filtre.choix_est_effectue then
            p_filtre.copy( old_filtre )
            avertir( once "removing filters leaves empty set" )
         end
      ensure
         filtre_ok : p_filtre.choix_est_effectue
      end

feature {}

   trouver_element_configurable( p_ensemble : COLLECTION[ LUAT_ELEMENT_CONFIGURABLE ]
                                 p_clef : STRING ) : INTEGER is
      require
         ensemble_valide : p_ensemble /= void
         clef_valide : not p_clef.is_empty
      do
         from result := p_ensemble.lower
         variant p_ensemble.upper - result
         until result > p_ensemble.upper
            or else p_ensemble.item( result ).clef.is_equal( p_clef )
         loop
            result := result + 1
         end
      ensure
         p_ensemble.valid_index( result ) implies p_ensemble.item( result ).clef.is_equal( p_clef )
      end

feature {}

   tri : COLLECTION_SORTER[ STRING ]

end
