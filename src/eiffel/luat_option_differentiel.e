indexing

	auteur : "seventh"
	license : "GPL 3.0"

class

	LUAT_OPTION_DIFFERENTIEL

		--
		-- Ensemble des options et états associés pour les commandes
		-- de comparaison
		--

creation

	fabriquer

feature {}

	fabriquer is
			-- constructeur
		do
			create filtre.initialiser
			create {LUAT_METRIQUE_NORMAL} modele.fabriquer
		end

feature

	initialiser is
			-- reconfigure l'instance aux valeurs par défaut
		do
			abrege := false
			filtre.met( true, false, false )
			create {LUAT_METRIQUE_NORMAL} modele.fabriquer
			statut := false
		ensure
			aucun_abrege : not abrege
			filtre_code : filtre.code
			filtre_commentaire : not filtre.commentaire
			filtre_total : not filtre.total
			aucun_statut : not statut
		end

feature

	abrege : BOOLEAN
			-- est-ce que seuls les fichiers en écarts doivent produire
			-- des métriques ?

	filtre : LUAT_FILTRE
			-- éléments à prendre en compte pour l'analyse et la
			-- production de métriques

	modele : LUAT_METRIQUE_DIFFERENTIEL
			-- modèle de métrique à produire

	statut : BOOLEAN
			-- un bilan final doit-il être produit ?

feature

	met_abrege( p_abrege : BOOLEAN ) is
			-- modifie la valeur de 'abrege'
		do
			abrege := p_abrege
		ensure
			abrege_ok : abrege = p_abrege
		end

	met_modele( p_modele : LUAT_METRIQUE_DIFFERENTIEL ) is
			-- modifie la valeur de 'modele'
		require
			modele_valide : p_modele /= void
		do
			modele := p_modele
		ensure
			modele_ok : modele = p_modele
		end

	met_statut( p_statut : BOOLEAN ) is
			-- modifie la valeur de 'statut'
		do
			statut := p_statut
		ensure
			statut_ok : statut = p_statut
		end

end
