indexing

   auteur : "seventh"
   license : "GPL 3.0"

deferred class

   ESCLAVE[ M ]

      --
      -- Interface d'objet devant/pouvant dépendre d'un autre pour
      -- être fonctionnel.
      --

feature

   attacher( p_maitre : M ) is
         -- lie l'objet à son maître
      require
         not est_soumis
         maitre_valide : p_maitre /= void
      deferred
      ensure
         maitre_ok : maitre = p_maitre
      end

   detacher is
         -- rend l'indépendance à l'objet
      require
         est_soumis
      deferred
      ensure
         not est_soumis
      end

   est_soumis : BOOLEAN is
         -- l'objet a-t-il un maître ?
      do
         result := maitre /= void
      ensure
         definition : result = ( maitre /= void )
      end

   maitre : M is
         -- maître actuel de l'objet
      deferred
      end

end
