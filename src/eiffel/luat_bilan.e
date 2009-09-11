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
			create langages.with_capacity( 4 )
			create nb_fichiers.with_capacity( 4 )
			create metriques.with_capacity( 4 )
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

			langages.clear_count
			nb_fichiers.clear_count
			metriques.clear_count
		end

feature

	accumuler( p_nom_langage : STRING
				  p_contribution : like metrique ) is
			-- intègre la contribution au bilan
		require
			nom_langage_valide : p_nom_langage /= void
		local
			i : INTEGER
			tri : COLLECTION_SORTER[ STRING ]
		do
			-- bilan global
			nb_commandes_executees := nb_commandes_executees + 1
			metrique.accumuler( p_contribution )

			-- bilan détaillé
			i := langages.fast_first_index_of( p_nom_langage )
			if langages.valid_index( i ) then
				nb_fichiers.put( nb_fichiers.item( i ) + 1, i )
				metriques.item( i ).accumuler( p_contribution )
			else
				i := tri.insert_index( langages, p_nom_langage )
				langages.add( p_nom_langage, i )
				nb_fichiers.add( 1, i )
				metriques.add( p_contribution.twin, i )
			end
		end

	afficher( p_flux : OUTPUT_STREAM ) is
			-- produit une forme lisible sur le flux correspondant
		local
			i : INTEGER
		do
			p_flux.put_new_line

			-- bilans intermédiaires, par langage

			from i := langages.lower
			variant langages.upper - i
			until i > langages.upper
			loop
				p_flux.put_string( once "[status] (" )
				p_flux.put_string( langages.item( i ) )
				p_flux.put_string( once ") files " )
				p_flux.put_integer( nb_fichiers.item( i ) )
				p_flux.put_spaces( 1 )
				metriques.item( i ).afficher( p_flux )
				p_flux.put_new_line
				i := i + 1
			end

			p_flux.put_string( once "[status] () files " )
			p_flux.put_integer( nb_commandes_executees )
			p_flux.put_spaces( 1 )
			metrique.afficher( p_flux )
			p_flux.put_new_line
		end

feature {LUAT_BILAN}

	langages : FAST_ARRAY[ STRING ]
			-- noms des différents langages

	nb_fichiers : FAST_ARRAY[ INTEGER ]
			-- nombre de fichiers analysés par langage

	metriques : FAST_ARRAY[ LUAT_METRIQUE ]
			-- bilan intermédiaire par langage

end
