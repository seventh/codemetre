indexing

	auteur : "seventh"
	license : "GPL 3.0"

class

	LUAT_COMMANDE_BILAN

		--
		-- Cette commande produit, sur la sortie standard, un bilan de
		-- toute l'analyse qui a pu être menée : nombre de fichiers, et
		-- cumul de métriques
		--

inherit

	LUAT_COMMANDE

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
			bilan.afficher( std_output )
		end

end
