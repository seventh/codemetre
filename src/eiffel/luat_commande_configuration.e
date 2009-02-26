indexing

	auteur : "seventh"
	license : "GPL 3.0"

class

	LUAT_COMMANDE_CONFIGURATION

		--
		-- Cette commande produit, sur la sortie standard, la
		-- configuration actuelle, issue de la configuration par défaut
		-- éventuellement adaptée par la configuration utilisateur
		--

inherit

	LUAT_COMMANDE

	LUAT_GLOBAL

creation

	fabriquer

feature {}

	fabriquer is
			-- constructeur
		do
			-- rien de particulier
		end

feature

	executer is
		do
			configuration.afficher
		end

end
