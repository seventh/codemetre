indexing

	auteur : "seventh"
	license : "GPL 3.0"

class

	LUAT_OPTION_ANALYSE

		--
		-- Ensemble des options et états associés pour les commandes
		-- d'analyse
		--

creation

	fabriquer

feature {}

	fabriquer is
			-- constructeur
		do
			create filtre.initialiser
		end

feature

	initialiser is
			-- reconfigure l'instance aux valeurs par défaut
		do
			filtre.met( false, false, true )
		ensure
			filtre_code : not filtre.code
			filtre_commentaire : not filtre.commentaire
			filtre_total : filtre.total
		end

feature

	filtre : LUAT_FILTRE
			-- éléments à prendre en compte pour l'analyse

end
