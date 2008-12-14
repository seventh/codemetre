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
		do
			processus := usine.create_process
			lg_racine := p_racine.count

			if p_est_trie then
				processus.execute_command_line( "find " + p_racine + " -type f | sort", true )
			else
				processus.execute_command_line( "find " + p_racine + " -type f", true )
			end

			processus.error.read_line
			if not processus.error.end_of_input then
				erreur := true
			end
		end

feature

	entree : STRING

	entree_courte : STRING

	lire is
		do
			if not processus.output.end_of_input then
				processus.output.read_line
				if processus.output.end_of_input then
					entree := void
					entree_courte := void
				else
					entree := processus.output.last_string.twin
					entree_courte := entree.substring( entree.lower + lg_racine, entree.upper )
				end
			end
		end

	est_epuise : BOOLEAN is
		do
			result := processus.output.end_of_input
		end

	clore is
		do
			processus.wait
		end

feature

	erreur : BOOLEAN

feature {}

	processus : PROCESS

	lg_racine : INTEGER
			-- nombre de caractères constituant la racine

end
