indexing

	auteur : "seventh"
	license : "GPL 3.0"

class

	LUAT_BILAN

		--
		-- Quoiqu'il advienne, le bilan publié en fin d'analyse reprend
		-- le nombre de commandes traitées
		--

creation

	fabriquer

feature {}

	fabriquer is
			-- constructeur
		do
		end

feature

	nb_commandes_executees : INTEGER
			-- nombre de commandes exécutées. Ce nombre est au mieux
			-- égal au nombre de commandes demandées, au pire inférieur.

	metrique : LUAT_METRIQUE
			-- accumulateur de statistiques

feature

	forcer_metrique( p_modele : LUAT_METRIQUE ) is
			-- force le choix de la métrique qui sera accumulée
		require
			modele_valide : p_modele /= void
		do
			metrique := p_modele.twin
		end

feature

	accumuler( p_contribution : like metrique ) is
			-- intègre la contribution au bilan
		do
			nb_commandes_executees := nb_commandes_executees + 1
			metrique.accumuler( p_contribution )
		end

	afficher( p_flux : OUTPUT_STREAM ) is
			-- produit une forme lisible sur le flux correspondant
		do
			p_flux.put_new_line
			p_flux.put_string( once "[status] files " )
			p_flux.put_integer( nb_commandes_executees )
			p_flux.put_spaces( 1 )
			metrique.afficher( p_flux )
			p_flux.put_new_line
		end

end
