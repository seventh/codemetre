indexing

	auteur : "seventh"
	license : "GPL 3.0"

class

	LUAT_OPTION_UNITAIRE

		--
		-- Ensemble des options et états associés pour les commandes
		-- unitaires
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
			filtre.met( true, true, false )
			statut := false
			analyse := false
		ensure
			filtre_code : filtre.code
			filtre_commentaire : filtre.commentaire
			filtre_total : not filtre.total
			aucun_statut : not statut
			pas_d_analyse : not analyse
		end

feature

	filtre : LUAT_FILTRE
			-- éléments à prendre en compte pour l'analyse et la
			-- production de métriques

	statut : BOOLEAN
			-- un bilan final doit-il être produit ?

	analyse : BOOLEAN
			-- une analyse de chaque fichier doit-elle être produite ?

feature

	met_statut( p_statut : BOOLEAN ) is
			-- modifie la valeur de 'statut'
		do
			statut := p_statut
		ensure
			statut_ok : statut = p_statut
		end

	met_analyse( p_analyse : BOOLEAN ) is
			-- modifie la valeur de 'analyse'
		do
			analyse := p_analyse
		ensure
			analyse_ok : analyse = p_analyse
		end

end
