indexing

   auteur : "seventh"
   license : "GPL 3.0"

class

   LUAT_TRADUCTEUR

      --
      -- Localisation et internationalisation
      --


inherit

   GNU_GET_TEXT
      rename
         translation as traduire
      end

creation

   fabriquer

feature {}

   fabriquer is
         -- constructeur
      do
         -- init_in_current_working_directory
         init_in_default_directory
      end

feature

   text_domain : STRING is "codemetre"

end
