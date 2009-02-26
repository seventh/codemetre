indexing

	auteur : "seventh"
	license : "GPL 3.0"

class

	LUAT_FABRIQUE_METRIQUE

		--
		-- Met à disposition un modèle de métrique différentielle. Ceci
		-- permet de configurer dynamiquement le type de métrique
		-- différentielle que l'on souhaite produire.
		--

creation

	fabriquer

feature {}

	fabriquer is
			-- constructeur
		do
			create {LUAT_METRIQUE_NORMALE} modele.fabriquer
		ensure
			modele_determine : modele /= void
		end

feature

	modele : LUAT_METRIQUE
			-- référence pour la production de métrique différentielle

	met_modele( p_modele : LUAT_METRIQUE ) is
			-- modifie le modèle de référence
		require
			modele_valide : p_modele /= void
		do
			modele := p_modele
		ensure
			modele_ok : modele = p_modele
		end

feature

	mesurer( p_ancien, p_nouvel : LUAT_LISTAGE ) : LUAT_METRIQUE is
			-- réalise l'analyse différentielle entre les deux listages
			-- selon le modèle retenu
		require
			au_moins_un : p_ancien /= void or p_nouvel /= void
		do
			result := modele.twin
			result.mesurer( p_ancien, p_nouvel )
		end

end
