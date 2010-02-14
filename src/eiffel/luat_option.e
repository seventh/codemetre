indexing

	auteur : "seventh"
	license : "GPL 3.0"

deferred class

	LUAT_OPTION

		--
		-- Options communes à tous les modes
		--

feature {}

	fabriquer is
			-- constructeur
		do
			create filtre.initialiser
		end

feature

	initialiser is
			-- valeur par défaut
		do
			examen := false
			statut := false
		ensure
			aucun_examen : not examen
			aucun_statut : not statut
		end

feature

	examen : BOOLEAN
			-- une analyse de chaque fichier doit-elle être produite ?

	filtre : LUAT_FILTRE
			-- éléments à prendre en compte pour l'analyse et la
			-- production de métriques

	statut : BOOLEAN
			-- un bilan final doit-il être produit ?

feature

	met_examen( p_examen : BOOLEAN ) is
			-- modifie la valeur de 'examen'
		do
			examen := p_examen
		ensure
			examen_ok : examen = p_examen
		end

	met_statut( p_statut : BOOLEAN ) is
			-- modifie la valeur de 'statut'
		do
			statut := p_statut
		ensure
			statut_ok : statut = p_statut
		end

feature

	afficher( p_flux : OUTPUT_STREAM ) is
			-- produit une forme lisible sur le flux correspondant
		do
			p_flux.put_string( once "%Tdump := " )
			p_flux.put_boolean( examen )
			p_flux.put_new_line

			filtre.afficher( p_flux )

			p_flux.put_string( once "%Tstatus := " )
			p_flux.put_boolean( statut )
			p_flux.put_new_line
		end

end
