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

			-- analyse la ligne de commande et détermine l'action
			-- souhaitée par l'utilsateur

			create analyseur.fabriquer

			analyseur.analyser

			-- si la commande est valide, on la lance

			if analyseur.commandes.is_empty then
				analyseur.usage
			else
				analyseur.commandes.do_all( agent {LUAT_COMMANDE}.executer )
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
			std_error.put_string( once " (c) 2005-2010 seventh oOo%N" )

			std_error.put_string( traduire( once "[
This program comes with ABSOLUTELY NO WARRANTY. This is free software, and you
are welcome to redistribute it under certain conditions.


														]" ) )
			std_error.flush
		end

end
