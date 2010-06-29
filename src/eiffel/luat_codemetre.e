indexing

	auteur : "seventh"
	license : "GPL 3.0"

class

	LUAT_CODEMETRE

		--
		-- Outil de métrologie pour différents langages de
		-- programmation
		--

inherit

	ARGUMENTS

	LUAT_GLOBAL

creation

	principal

feature

	principal is
			-- programme principal
		local
			analyseur : LUAT_LIGNE_COMMANDE_ANALYSEUR
		do
			afficher_mention_legale

			-- analyse de la ligne de commande et exécution simultanée
			-- des commandes que celle-ci provoque

			create analyseur.fabriquer

			analyseur.analyser

			-- une seule commande peut être différée (le statut final)

			if analyseur.commande_statut /= void then
				analyseur.commande_statut.executer
			elseif analyseur.aucune_commande_executee then
				analyseur.usage
			end
		end

feature

	afficher_mention_legale is
			-- affiche une mention légale sur la sortie d'erreur, afin
			-- de ne pas polluer la sortie standard qui est dédiée aux
			-- sorties de mesures.
		do
			std_error.put_string( once "oOo CodeMetre " )
			std_error.put_string( version_majeure )
			std_error.put_string( version_mineure )
			std_error.put_string( once " (c) 2005,2006,2007,2008,2009,2010 Guillaume Lemaître oOo%N" )

			std_error.put_string( traduire( once "[
This program comes with ABSOLUTELY NO WARRANTY. This is free software, and you
are welcome to redistribute it under certain conditions.


														]" ) )
			std_error.flush
		end

end
