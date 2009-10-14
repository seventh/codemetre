indexing

	auteur : "seventh"
	license : "GPL 3.0"

deferred class

	LUAT_GLOBAL

		--
		-- Variables globales au projet
		--

feature {LUAT_GLOBAL}

	bilan : LUAT_BILAN is
			-- statut final affiché en fin d'exécution, si commandé
		once
			create result.fabriquer
		end

feature {LUAT_GLOBAL}

	configuration : LUAT_CONFIGURATION is
			-- ensemble des variables de configuration utilisateur
		once
			create result.fabriquer
			result.appliquer_choix_initial
			result.appliquer_choix_fichier
		end

feature {LUAT_GLOBAL}

	traduire( p_message : STRING ) : STRING is
			-- traduction locale du message d'origine
		do
			result := traducteur.traduire( p_message )
		end

feature {LUAT_GLOBAL}

	version_majeure : STRING is "v0.24.0"
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
