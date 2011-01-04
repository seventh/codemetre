indexing

   auteur : "seventh"
   license : "GPL 3.0"
   reference : "Introduction à l'algorithmique - chapitre 14 - Cormen, Leiserson, Rivest"

class

   ARN_ITERATEUR[ E ]

      --
      -- Accesseur aux noeuds d'un Arbre Rouge et Noir
      --

inherit

   ARN
      undefine
         copy, is_equal
      end

   ITERATEUR_BIDIRECTIONNEL_ESCLAVE[ E, ARN_ARBRE[ E ] ]
      rename
         est_soumis as est_attache,
         maitre as arbre
      redefine
         copy, is_equal
      end

creation

   attacher

feature

   attacher( p_arbre : ARN_ARBRE[ E ] ) is
      do
         arbre := p_arbre
         noeud := p_arbre.nil
         arbre.abonner( current )
      end

   detacher is
      do
         arbre.oublier( current )
         arbre := void
         noeud := void
      end

   arbre : ARN_ARBRE[ E ]

feature

   est_hors_borne : BOOLEAN is
      do
         result := noeud = arbre.nil
      end

   dereferencer : E is
      do
         result := noeud.etiquette
      end

   pointer_hors_borne is
      do
         noeud := arbre.nil
      end

feature

   pointer_premier is
      do
         noeud := arbre.racine.minimum
      end

   pointer_dernier is
      do
         noeud := arbre.racine.maximum
      end

   avancer is
      do
         noeud := noeud.successeur
      end

   reculer is
      do
         noeud := noeud.predecesseur
      end

feature {ARN} -- implémentation

   noeud : ARN_NOEUD[ E ]
         -- noeud pointé par l'itérateur

feature {ARN} -- opérations de mise-à-jour extérieures

   met_noeud( p_noeud : like noeud ) is
         -- fait pointer sur le noeud correspondant
      require
         noeud_valide : p_noeud.arbre = arbre
      do
         noeud := p_noeud
      ensure
         noeud_ok : noeud = p_noeud
      end

feature

   copy( p_source : like current ) is
         -- réalise une copie de la source
      do
         if arbre /= p_source.arbre then
            if est_attache then
               detacher
            end
            if p_source.est_attache then
               attacher( p_source.arbre )
            end
         end
         noeud := p_source.noeud
      end

   is_equal( p_autre : like current ) : BOOLEAN is
         -- les deux itérateurs pointent-ils le même élément ?
      do
         -- ce test est suffisant car 'detacher' réinitialise la
         -- valeur de 'noeud'
         result := noeud = p_autre.noeud
      end

end
