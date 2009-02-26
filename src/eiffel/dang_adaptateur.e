indexing

	auteur : "seventh"
	license : "GPL 3.0"

deferred class

	DANG_ADAPTATEUR

		--
		-- Cette interface est appelée par l'analyseur qui lui fournit
		-- les informations lues au fur et à mesure. L'adaptateur
		-- digère ces données.
		--

feature {DANG_ANALYSEUR}

	ajouter( p_section : STRING
				p_variable : STRING
				p_valeur : STRING ) is
			-- ajoute la valeur à la variable de la section
			-- correspondante
		require
			section_valide : not p_section.is_empty
			variable_valide : not p_variable.is_empty
			valeur_valide : not p_valeur.is_empty
		deferred
		end

	effacer( p_section : STRING
				p_variable : STRING ) is
			-- supprime la liste de valeurs associée à la variable de la
			-- section correspondante
		require
			section_valide : not p_section.is_empty
			variable_valide : not p_variable.is_empty
		deferred
		end

	remonter_erreur( p_message : STRING ) is
		require
			message_valide : not p_message.is_empty
		deferred
		end

end
