indexing

   auteur : "seventh"
   license : "GPL 3.0"

class

   LUAT_LOT_ARBRE

      --
      -- Itérateur de la liste des fichiers accessibles depuis un
      -- répertoire 'racine', éventuellement préalablement triée.
      --

inherit

   LUAT_LOT

creation

   fabriquer

feature {}

   fabriquer( p_racine : STRING
              p_est_trie : BOOLEAN ) is
         -- constructeur
      local
         tri : COLLECTION_SORTER[ STRING ]
      do
         -- La liste des fichiers est établie dès l'instanciation,
         -- ceci car on peut vouloir itérer sur une liste triée.
         --
         -- Une alternative a été envisagée de construire la liste au
         -- fur et à mesure des appels à LUAT_LOT_ARBRE.lire, en
         -- assurant que tout ce qui n'avait pas encore été parcouru
         -- était mémorisé ordonné.
         -- Cependant, la méthode DIRECTORY.scan fournit des entrées
         -- dont le type est indéterminé. Le seul moyen de savoir si
         -- un DIRECTORY.item est un répertoire ou non est d'y
         -- appliquer DIRECTORY.scan à son tour, ce qui va à
         -- l'encontre de l'idée d'une construction minimale et
         -- progressive.
         --
         -- Typiquement, supposons que l'on ait deux entrées :
         --  * ip2
         --  * ip2.c
         -- Alors elles seront mémorisées dans cet ordre en attendant
         -- d'être elles-même analysées ; analyse qui révélera que
         -- "ip2" est un répertoire, l'ordre aurait donc dû être :
         --  * ip2.c
         --  * ip2/
         -- L'ordre ne peut donc être garanti, il faut nécessairement
         -- connaître tous les fichiers pour pouvoir les trier.

         lister_fichier( p_racine )
         ligne := fichiers.lower - 1

         -- remontée d'erreur

         if fichiers.is_empty then
            std_error.put_string( traduire( once "Error: %"" ) )
            std_error.put_string( p_racine )
            std_error.put_string( traduire( once "%" is empty" ) )
            std_error.put_new_line
            std_error.flush

         -- tri si requis

         elseif p_est_trie then
            tri.sort( fichiers )
         end
      end

feature

   entree : STRING

   entree_courte : STRING

   lire is
      do
         if ligne <= fichiers.upper then
            ligne := ligne + 1
            if ligne > fichiers.upper then
               entree := void
               entree_courte := void
               est_epuise := true
            else
               entree := fichiers.item( ligne )
               entree_courte := entree.substring( entree.lower + lg_racine, entree.upper )
            end
         end
      end

   est_epuise : BOOLEAN

   clore is
      do
         fichiers.clear_count
      end

feature {}

   lister_fichier( p_racine : STRING ) is
         -- produit la liste des fichiers enracinés en 'racine'
      require
         racine_valide : not p_racine.is_empty
      local
         i, j : INTEGER
         repertoire : DIRECTORY
      do
         -- initialisation

         create repertoire.make
         create fichiers.with_capacity( 1 )

         -- détermination de la correspondance entre racines

         repertoire.scan( p_racine )
         lg_racine := p_racine.count

         if repertoire.last_scan_status then
            if p_racine.last /= repertoire.path.last then
               p_racine.add_last( repertoire.path.last )
               lg_racine := lg_racine + 1
            end
            fichiers.add_last( p_racine )
         end

         -- recherche de tous les fichiers de la sous-arborescence

         from i := fichiers.lower
         until i > fichiers.upper
         loop
            repertoire.scan( fichiers.item( i ) )
            if not repertoire.last_scan_status then

               -- l'entrée est un fichier, on la conserve

               i := i + 1
            else

               -- l'entrée est bien un répertoire, on ajoute à la
               -- file tous les noms qui nous permettent de
               -- poursuivre l'itération, soit toutes les entrées
               -- sauf '.' et '..'

               if fichiers.item( i ).last /= repertoire.path.last then
                  fichiers.item( i ).add_last( repertoire.path.last )
               end

               from j := repertoire.lower
               variant repertoire.upper - j
               until j > repertoire.upper
               loop
                  if not ( repertoire.item( j ).is_equal( "." )
                           or repertoire.item( j ).is_equal( ".." ) )
                   then
                     fichiers.add_last( fichiers.item( i ) + repertoire.item( j ) )
                  end
                  j := j + 1
               end

               -- on supprime le nom du répertoire de la liste,
               -- puisque on ne veut conserver que des noms de fichier

               fichiers.swap( i, fichiers.upper )
               fichiers.remove_last
            end
         end
      end

feature {}

   lg_racine : INTEGER
         -- nombre de caractères constituant la racine

   fichiers : FAST_ARRAY[ STRING ]
         -- ensemble des fichiers trouvés sous la racine

   ligne : INTEGER
         -- indice du dernier élément lu

end
