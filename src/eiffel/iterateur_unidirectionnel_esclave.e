indexing

   auteur : "seventh"
   license : "GPL 3.0"

deferred class

   ITERATEUR_UNIDIRECTIONNEL_ESCLAVE[ E, M ]

      --
      -- Itérateur attachable à l'ensemble parcouru
      --

inherit

   ESCLAVE[ M ]

   ITERATEUR_UNIDIRECTIONNEL[ E ]

feature

   est_hors_borne : BOOLEAN is
      require
         est_soumis
      deferred
      end

   pointer_hors_borne is
      require
         est_soumis
      deferred
      end

feature

   pointer_premier is
      require
         est_soumis
      deferred
      end

end
