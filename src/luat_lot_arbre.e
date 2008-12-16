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
			usine : PROCESS_FACTORY
			processus : PROCESS
		do
			processus := usine.create_process
			lg_racine := p_racine.count

			-- attention, il se peut qu'un bogue soit ici introduit, du
			-- fait que la relation d'ordre imposée par 'sort' ne soit
			-- pas la même que celle utilisée en interne lors de la
			-- comparaison lexicographique de chaînes de caractères

			if p_est_trie then
				processus.execute_command_line( "find " + p_racine + " -type f | sort", true )
			else
				processus.execute_command_line( "find " + p_racine + " -type f", true )
			end

			-- comme il est très difficile de déterminer les échecs du
			-- processus précédent, on préfère charger en mémoire le
			-- résultat

			create fichiers.with_capacity( 0 )
			from processus.output.read_line
			until processus.output.end_of_input
			loop
				fichiers.add_last( processus.output.last_string.twin )
				processus.output.read_line
			end
			ligne := fichiers.lower - 1

			processus.wait
			if processus.status /= 0 then
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

	est_epuise : BOOLEAN is
		attribute
		end

	clore is
		do
			fichiers.clear_count
		end

feature {}

	lg_racine : INTEGER
			-- nombre de caractères constituant la racine

	fichiers : FAST_ARRAY[ STRING ]

	ligne : INTEGER
end
