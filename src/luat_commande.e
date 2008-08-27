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

inherit

	COMMANDE

feature

	analyseur : LUAT_ANALYSEUR
			-- Analyseur du langage présumé dans lequel a été écrit le
			-- code

	nom_fichier : STRING
			-- chemin vers le fichier à analyser

feature

	option : LUAT_OPTION
			-- options de l'analyse

	appliquer_option is
			-- paramètre l'analyseur pour qu'il prenne en compte les
			-- options demandées
		do
			if option.code
				or option.total
			 then
				analyseur.activer_code
			else
				analyseur.desactiver_code
			end

			if option.commentaire
				or option.total
			 then
				analyseur.activer_commentaire
			else
				analyseur.desactiver_commentaire
			end
		end

end
