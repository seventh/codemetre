indexing

   auteur : "seventh"
   license : "GPL 3.0"

class

   LUAT_LOT_LISTE

      --
      -- Itérateur de fichier texte, chaque ligne représentant le nom
      -- d'un fichier
      --

inherit

   LUAT_LOT

creation

   fabriquer

feature {}

   fabriquer( p_flux : INPUT_STREAM ) is
         -- constructeur
      require
         lot_valide : p_flux.is_connected
      do
         flux := p_flux
         notation := notation_locale
      ensure
         flux_ok : flux = p_flux
      end

feature

   entree : STRING is
      attribute
      end

   entree_courte : STRING is
      do
         result := entree
      ensure
         definition : result = entree
      end

   lire is
      do
         if not flux.end_of_input then
            -- on saute les commentaires, et on traite les directives

            from flux.read_line
            until flux.end_of_input
               or else est_entree( flux.last_string )
            loop
               traiter_directive( flux.last_string )
               flux.read_line
            end

            -- on publie la première entrée suivante

            if flux.end_of_input
               or else flux.last_string.is_empty
             then
               entree := void
            else
               if racine = void then
                  entree := flux.last_string.twin
               else
                  entree := racine.twin
                  notation.to_subpath_with( entree, flux.last_string )
               end
            end
         end
      end

   est_epuise : BOOLEAN is
      do
         result := flux.end_of_input
      end

   clore is
      do
         flux.disconnect
      end

feature {}

   flux : INPUT_STREAM
         -- accesseur au fichier de lot

   racine : STRING
         -- valeur de la dernière directive de compilation "dirname:="

   notation : DIRECTORY_NOTATION

feature {}

   est_entree( p_ligne : STRING ) : BOOLEAN is
         -- vrai si et seulement si la ligne ne débute pas par une
         -- marque de commentaire
      do
         result := not p_ligne.has_prefix( once "#" )
      end

   traiter_directive( p_ligne : STRING ) is
         -- potentiellement, un commentaire peut être en fait une
         -- directive
      require
         not est_entree( p_ligne )
      local
         tampon : STRING
      do
         if p_ligne.has_prefix( once "#dirtype:=" ) then
            tampon := p_ligne.substring( p_ligne.lower + 10,
                                         p_ligne.upper )
            if tampon.is_empty then
               notation := notation_locale
            elseif tampon.is_equal( once "windows" ) then
               notation := notation_windows
            elseif tampon.is_equal( once "unix" ) then
               notation := notation_unix
            else
               std_error.put_string( traduire( once "Syntax error in batch file: " ) )
               std_error.put_string( traduire( once "%"dirtype%" directive shall either be empty, 'unix' or 'windows'" ) )
               std_error.put_new_line
               std_error.flush
            end

         elseif p_ligne.has_prefix( once "#dirname:=" ) then
            tampon := p_ligne.substring( p_ligne.lower + 10,
                                         p_ligne.upper )
            if tampon.is_empty then
               racine := void
            elseif not notation.is_valid_directory_path( tampon ) then
               std_error.put_string( traduire( once "Syntax error in batch file: " ) )
               std_error.put_string( traduire( once "%"dirname%" directive shall be a valid directory name" ) )
               std_error.put_new_line
               std_error.flush
            else
               racine := tampon
            end
         end
      end

feature {}

   notation_locale : DIRECTORY_NOTATION is
      local
         basique : BASIC_DIRECTORY
         poubelle : STRING
      once
         -- la routine 'current_working_directory' détermine la
         -- notation locale par effet de bord. C'est l'effet escompté
         poubelle := basique.current_working_directory

         result := basique.system_notation
      end

   notation_unix : UNIX_DIRECTORY_NOTATION is
      once
         create result
      end

   notation_windows : WINDOWS_DIRECTORY_NOTATION is
      once
         create result
      end

end
