indexing

   auteur : "seventh"
   license : "GPL 3.0"

class

   LUAT_FABRIQUE

      --
      -- Fabrique maintenant une base de données des objets générés,
      -- afin de n'avoir qu'une copie de chaque instance possible.
      -- Le but de cette fabrique est d'accélérer les comparaisons
      -- ultérieures : en garantissant l'unicité, on peut utiliser
      -- '=' et non plus is_equal.
      --

creation

   fabriquer

feature {}

   fabriquer is
         -- constructeur
      do
         create dico_ligne.fabriquer( create {LUAT_ORDRE_LIGNE} )
         create dico_source.fabriquer( create {LUAT_ORDRE_SOURCE} )
      end

feature

   reinitialiser is
         -- purge l'ensemble des dictionnaires de la fabrique
      do
         if not dico_ligne.est_vide then
            dico_ligne.vider
         end
         if not dico_source.est_vide then
            dico_source.vider
         end
      ensure
         dico_ligne.est_vide
         dico_source.est_vide
      end

   activer_memoire is
         -- active l'utilisation des dictionnaires
      require
         appel_judicieux : not est_active_memoire
      do
         est_active_memoire := true
      ensure
         definition : est_active_memoire
      end

   desactiver_memoire is
         -- désactive l'utilisation des dictionnaires
      require
         appel_judicieux : est_active_memoire
      do
         est_active_memoire := false
      ensure
         definition : not est_active_memoire
      end

   est_active_memoire : BOOLEAN
         -- vrai si et seulement si les dictionnaires sont utilisés

feature

   produire_code( p_lexeme : STRING ) : LUAT_SOURCE is
         -- produit un élément de CODE à partir du lexème si un tel
         -- élement n'existait pas déjà. Sinon, fournit l'élément
         -- existant
      local
         it_source : ARN_ITERATEUR[ LUAT_SOURCE ]
      do
         create result.fabriquer_code( p_lexeme )

         if est_active_memoire then
            create it_source.attacher( dico_source )
            dico_source.trouver( result, it_source )

            if it_source.est_hors_borne then
               dico_source.ajouter( result )
            else
               result := it_source.dereferencer
            end
            it_source.detacher
         end
      ensure
         est_active_memoire implies est_connu_source( result )
      end

   produire_commentaire( p_lexeme : STRING ) : LUAT_SOURCE is
         -- produit un élément de COMMENTAIRE à partir du lexème si
         -- un tel élement n'existait pas déjà. Sinon, fournit
         -- l'élément existant
      local
         it_source : ARN_ITERATEUR[ LUAT_SOURCE ]
      do
         create result.fabriquer_commentaire( p_lexeme )

         if est_active_memoire then
            create it_source.attacher( dico_source )
            dico_source.trouver( result, it_source )

            if it_source.est_hors_borne then
               dico_source.ajouter( result )
            else
               result := it_source.dereferencer
            end
            it_source.detacher
         end
      ensure
         est_active_memoire implies est_connu_source( result )
      end

   produire_ligne( p_phrase : COLLECTION[ LUAT_SOURCE ] ) : LUAT_LIGNE is
         -- produit une LIGNE à partir de la phrase. Si cette ligne
         -- existait déjà, fournit l'ancienne.
      require
         est_active_memoire implies sont_connus_elements( p_phrase )
      local
         it_ligne : ARN_ITERATEUR[ LUAT_LIGNE ]
      do
         create result.fabriquer( p_phrase )

         if est_active_memoire then
            create it_ligne.attacher( dico_ligne )
            dico_ligne.trouver( result, it_ligne )

            if it_ligne.est_hors_borne then
               dico_ligne.ajouter( result )
            else
               result := it_ligne.dereferencer
            end
            it_ligne.detacher
         end
      ensure
         est_active_memoire implies est_connu_ligne( result )
      end

feature

   est_connu_source( p_source : LUAT_SOURCE ) : BOOLEAN is
         -- vrai si et seulement si l'élément est référencé
      do
         result := dico_source.est_present( p_source )
      end

feature

   sont_connus_elements( p_phrase : COLLECTION[ LUAT_SOURCE ] ) : BOOLEAN is
         -- vrai si et seulement si tous les éléments sont référencés
      do
         result := p_phrase.for_all( agent est_connu_source( ? ) )
      end

   est_connu_ligne( p_ligne : LUAT_LIGNE ) : BOOLEAN is
         -- vrai si et seulement si l'élément est référencé
      do
         result := dico_ligne.est_present( p_ligne )
      end

feature {}

   dico_ligne : ARN_ARBRE[ LUAT_LIGNE ]
         -- ensemble des lignes

   dico_source : ARN_ARBRE[ LUAT_SOURCE ]
         -- ensemble des éléments de code ou commentaire

end
