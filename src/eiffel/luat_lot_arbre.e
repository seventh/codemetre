indexing

	auteur : "seventh"
	license : "GPL 3.0"

class

	LUAT_LOT_ARBRE

		--
		-- Réunit l'ensemble des fichiers à partir d'un répertoire
		-- nommé 'racine'. Cet ensemble peut-être trié sur demande
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
			-- récupération des fichiers

			lister_fichier( p_racine )
			if p_est_trie then
				tri.sort( fichiers )
			end

			ligne := fichiers.lower - 1

			-- fin de la commande système

			if fichiers.is_empty then
				std_error.put_string( traduire( once "Error: %"" ) )
				std_error.put_string( p_racine )
				std_error.put_string( traduire( once "%" is not a valid directory name" ) )
				std_error.put_new_line
				std_error.flush
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
			if repertoire.last_scan_status
				and then p_racine.last /= repertoire.path.last
			 then
				p_racine.add_last( repertoire.path.last )
			end
			lg_racine := p_racine.count

			-- recherche de tous les fichiers de la sous-arborescence

			fichiers.add_last( p_racine )

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
