indexing

	auteur : "seventh"
	license : "GPL 3.0"

deferred class

	LUAT_ANALYSEUR

		--
		-- Interface générique d'analyseur pour langage de programmation
		--

inherit

	LUAT_GLOBAL

	LUAT_ELEMENT_CONFIGURABLE
		rename
			clef as langage
		end

feature {}

	fabriquer is
			-- constructeur
		do
			create fabrique.fabriquer

			create fichier.fabriquer
			create chaine.make_empty
			create ligne.with_capacity( 0 )
		end

feature

	langage : STRING is
			-- langage reconnu
		deferred
		end

feature

	code_pris_en_compte : BOOLEAN
			-- vrai si et seulement si les instructions de code sont
			-- prises en compte lors de la lecture

	activer_code is
			-- active la prise en compte du code lors de la lecture
		do
			code_pris_en_compte := true
		ensure
			code_pris_en_compte
		end

	desactiver_code is
			-- désactive la prise en compte du code lors de la lecture
		do
			code_pris_en_compte := false
		ensure
			not code_pris_en_compte
		end

feature

	commentaire_pris_en_compte : BOOLEAN
			-- vrai si et seulement si les commentaires sont pris en
			-- compte lors de la lecture

	activer_commentaire is
			-- active la prise en compte des commentaires lors de la
			-- lecture

		do
			commentaire_pris_en_compte := true
		ensure
			commentaire_pris_en_compte
		end

	desactiver_commentaire is
			-- désactive la prise en compte des commentaires lors de la
			-- lecture
		do
			commentaire_pris_en_compte := false
		ensure
			not commentaire_pris_en_compte
		end

feature

	appliquer( p_filtre : LUAT_FILTRE ) is
			-- paramètre l'analyseur en fonction des filtres correspondantes
		do
			if p_filtre.code
				or p_filtre.total
			 then
				activer_code
			else
				desactiver_code
			end

			if p_filtre.commentaire
				or p_filtre.total
			 then
				activer_commentaire
			else
				desactiver_commentaire
			end
		ensure
			p_filtre.code implies code_pris_en_compte
			p_filtre.commentaire implies commentaire_pris_en_compte
			p_filtre.total implies ( code_pris_en_compte and commentaire_pris_en_compte )
		end

feature

	embrayer_fabrique is
			-- active l'utilisation d'une fabrique : deux lexèmes
			-- produits équivalents seront égaux
		require
			lecture_non_debutee : listage = void or else listage.est_vide
			appel_judicieux : not est_utilise_fabrique
		do
			fabrique.activer_memoire
		ensure
			est_utilise_fabrique
		end

	debrayer_fabrique is
			-- désactive l'utilisation d'une fabrique : deux lexèmes
			-- équivalents seront malgré tout différents
		require
			lecture_non_debutee : listage = void or else listage.est_vide
			appel_judicieux : est_utilise_fabrique
		do
			fabrique.desactiver_memoire
		ensure
			not est_utilise_fabrique
		end

	est_utilise_fabrique : BOOLEAN is
			-- vrai si et seulement si une fabrique est utilisée pour la
			-- lecture
		do
			result := fabrique.est_active_memoire
		end

	reinitialiser is
			-- réinitialise la fabrique
		do
			fabrique.reinitialiser
		end

feature

	lire( p_fichier : STRING ) : LUAT_LISTAGE is
			-- tente de produire un listage en analysant le fichier dont
			-- le nom est passé en argument
		do
			fichier.initialiser( p_fichier )
			if not fichier.est_ouvert then
				std_error.put_string( traduire( once "*** Error: file %"" ) )
				std_error.put_string( p_fichier )
				std_error.put_string( traduire( once "%" is unreachable." ) )
				std_error.put_new_line
				std_error.flush
			else
				create listage.fabriquer( p_fichier, langage )
				analyser
				result := listage
				fichier.terminer

				if result = void then
					std_error.put_string( traduire( once "*** Error: file %"" ) )
					std_error.put_string( p_fichier )
					std_error.put_string( traduire( once "%" is not written in " ) )
					std_error.put_string( langage )

					std_error.put_spaces( 1 )
					std_error.put_character( '(' )
					std_error.put_string( message_erreur )
					std_error.put_character( ')' )

					std_error.put_new_line
					std_error.flush
				end
			end
		end

feature {LUAT_ANALYSEUR}

	fabrique : LUAT_FABRIQUE
			-- ensemble de lexèmes typés ou non

	produire_code is
			-- ajoute un élément de code à la ligne courante
		require
			not chaine.is_empty
		do
			if code_pris_en_compte then
				ligne.add_last( fabrique.produire_code( chaine ) )
			end
			create chaine.make_empty
		ensure
			code_pris_en_compte implies not ligne.is_empty
			chaine.is_empty
		end

	produire_commentaire is
			-- ajoute un élément de commentaire à la ligne courante
		require
			not chaine.is_empty
		do
			if commentaire_pris_en_compte then
				ligne.add_last( fabrique.produire_commentaire( chaine ) )
			end
			create chaine.make_empty
		ensure
			commentaire_pris_en_compte implies not ligne.is_empty
			chaine.is_empty
		end

	produire_ligne is
			-- ajoute la ligne courante au listage si elle est non vide,
			-- et la vide
		require
			chaine.is_empty
		do
			if not ligne.is_empty then
				listage.ajouter( fabrique.produire_ligne( ligne ) )
				create ligne.with_capacity( 0 )
			end
			indice_ligne := indice_ligne + 1
		ensure
			not old ligne.is_empty implies not listage.est_vide
			ligne.is_empty
			indice_ligne = old indice_ligne + 1
		end

feature {}

	analyser is
			-- sépare le flux d'entrée en lexème. Si l'opération est un
			-- échec, 'listage' repasse à 'void'
		require
			appel_judicieux : not fichier.est_epuise
			listage_cree : listage.est_vide
		deferred
		end

	fichier : LUAT_ENTREE

	chaine : STRING

	ligne : FAST_ARRAY[ LUAT_SOURCE ]

	listage : LUAT_LISTAGE

feature {}

	caractere : CHARACTER is
			-- dernier caractère lu
		require
			fichier.caractere_est_disponible
		do
			result := fichier.caractere
		end

	indice_ligne : INTEGER
			-- numéro de la ligne en cours de lecture

feature {}

	erreur : BOOLEAN
			-- vrai si et seulement si une erreur lexicale a été rencontrée

	message_erreur : STRING
			-- précision textuelle sur la nature de l'erreur rencontrée

	gerer_erreur( p_message : STRING ) is
			-- affecte à 'message_erreur' une traduction du message
			-- d'erreur correspondant, accompagné de la position de
			-- l'erreur
		require
			message_valide : p_message /= void
		do
			message_erreur := traduire( once "line " ).twin
			message_erreur.append_string( indice_ligne.to_string )
			if not p_message.is_empty then
				message_erreur.append_string( once " : " )
				message_erreur.append_string( traduire( p_message ) )
			end

			erreur := true
		ensure
			definition : erreur
		end

end
