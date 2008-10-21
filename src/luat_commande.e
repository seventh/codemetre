indexing

	auteur : "seventh"
	license : "GPL 3.0"

deferred class

	LUAT_COMMANDE

		--
		-- Demande telle qu'elle est formulée par l'utilisateur. La
		-- demande se charge d'analyser le(s) fichier(s) pour ensuite
		-- fournir un résultat.
		--

feature

	analyseur : LUAT_ANALYSEUR
			-- analyseur syntaxique utilisé pour la lecture du fichier

	nom_fichier : STRING
			-- chemin du fichier à analyser

	option : LUAT_OPTION
			-- options de l'analyse

feature

	executer is
			-- réalise la demande
		deferred
		end

end
