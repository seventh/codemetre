indexing

	auteur : "seventh"
	license : "GPL 3.0"

deferred class

	LUAT_GLOBAL

		--
		-- Variables globales au projet
		--

feature {LUAT_GLOBAL}

	configuration : LUAT_CONFIGURATION is
			-- ensemble des variables de configuration utilisateur
		once
			create result.fabriquer
			result.initialiser
			result.lire
		end

feature

	usine_metrique : LUAT_FABRIQUE_METRIQUE is
			-- fabrique de métriques différentielles. Permet de
			-- configurer dynamiquement le modèle de comparaison
		once
			create result.fabriquer
		end

feature

	traduire( p_message : STRING ) : STRING is
			-- traduction locale du message d'origine
		do
			result := traducteur.traduire( p_message )
		end

feature

	version_majeure : STRING is "v0.19.2"
			-- identifiant de la branche officielle

	version_mineure : STRING is ""
			-- identifiant de la branche dédiée (par rapport à la
			-- branche officielle)

feature {}

	traducteur : LUAT_TRADUCTEUR is
			-- siège de l'internationalisation des messages de sortie et
			-- d'erreur
		once
			create result.fabriquer
		end

end