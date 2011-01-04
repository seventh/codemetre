indexing

   auteur : "seventh"
   license : "GPL 3.0"

class

   LUAT_OPTION_DIFFERENTIEL

      --
      -- Ensemble des options et états associés pour les commandes
      -- de comparaison
      --

inherit

   LUAT_OPTION
      redefine
         fabriquer, initialiser, afficher
      end

creation

   fabriquer

feature {}

   fabriquer is
      do
         precursor
         create {LUAT_METRIQUE_NORMAL} modele.fabriquer
      end

feature

   initialiser is
         -- reconfigure l'instance aux valeurs par défaut
      do
         abrege := false
         filtre.met( true, false, false )
         create {LUAT_METRIQUE_NORMAL} modele.fabriquer
         statut := false
      ensure then
         aucun_abrege : not abrege
         filtre_code : filtre.code
         filtre_commentaire : not filtre.commentaire
         filtre_total : not filtre.total
      end

feature

   abrege : BOOLEAN
         -- est-ce que seuls les fichiers en écarts doivent produire
         -- des métriques ?

   modele : LUAT_METRIQUE_DIFFERENTIEL
         -- modèle de métrique à produire

feature

   met_abrege( p_abrege : BOOLEAN ) is
         -- modifie la valeur de 'abrege'
      do
         abrege := p_abrege
      ensure
         abrege_ok : abrege = p_abrege
      end

   met_modele( p_modele : LUAT_METRIQUE_DIFFERENTIEL ) is
         -- modifie la valeur de 'modele'
      require
         modele_valide : p_modele /= void
      do
         modele := p_modele
      ensure
         modele_ok : modele = p_modele
      end

feature

   afficher( p_flux : OUTPUT_STREAM ) is
      do
         precursor( p_flux )

         std_output.put_string( once "%Tmodel := " )
         std_output.put_string( modele.nom )
         std_output.put_new_line

         std_output.put_string( once "%Tshort := " )
         std_output.put_boolean( abrege )
         std_output.put_new_line
      end

end
