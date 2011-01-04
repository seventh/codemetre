indexing

   auteur : "seventh"
   license : "GPL 3.0"

class

   LUAT_FILTRE

      --
      -- Réunit les options d'analyse du code et des commentaires
      -- pour tout type de commande
      --

creation

   initialiser

feature {}

   initialiser is
         -- oublie toute les demandes effectuées
      do
         code := false
         commentaire := false
         total := false
      ensure
         code_desactive : not code
         commentaire_desactive : not commentaire
         total_desactive : not total
      end

feature

   code : BOOLEAN
         -- vrai si et seulement une demande de prise en compte du
         -- code a été faite

   met_code( p_code : BOOLEAN ) is
         -- modifie la valeur de 'code'
      do
         code := p_code
      ensure
         code_ok : code = p_code
      end

feature

   commentaire : BOOLEAN
         -- vrai si et seulement si une demande de prise en compte
         -- des commentaires a été faite

   met_commentaire( p_commentaire : BOOLEAN ) is
         -- modifie la valeur de 'commentaire'
      do
         commentaire := p_commentaire
      ensure
         commentaire_ok : commentaire = p_commentaire
      end

feature

   total : BOOLEAN
         -- vrai si et seulement si une demande de prise en compte de
         -- l'ensemble a été faite. L'interprétation de cette option
         -- par rapport à la valeur combinée de 'code' et
         -- 'commentaire' est différente d'une commande à l'autre

   met_total( p_total : BOOLEAN ) is
         -- modifie la valeur de 'total'
      do
         total := p_total
      ensure
         total_ok : total = p_total
      end

feature

   choix_est_effectue : BOOLEAN is
         -- vrai si et seulement si au moins une demande a été faite
         -- parmi (code, commentaire, total)
      do
         result := code or commentaire or total
      ensure
         definition : result = code or commentaire or total
      end

   choix_est_unique : BOOLEAN is
         -- vrai si et seulement si une seule demande a été faite
         -- parmi (code, commentaire, total)
      do
         result := ( code and not commentaire and not total )
            or ( not code and commentaire and not total )
            or ( not code and not commentaire and total )
      end

   met( p_code, p_commentaire, p_total : BOOLEAN ) is
         -- modifie simultanément les valeurs de (code, commentaire,
         -- total)
      do
         met_code( p_code )
         met_commentaire( p_commentaire )
         met_total( p_total )
      ensure
         code_ok : code = p_code
         commentaire_ok : commentaire = p_commentaire
         total_ok : total = p_total
      end

feature

   afficher( p_flux : OUTPUT_STREAM ) is
         -- produit une forme lisible sur le flux correspondant
      local
         separateur_doit_etre_ajoute : BOOLEAN
      do
         p_flux.put_string( once "%Tfilter := " )

         if code then
            separateur_doit_etre_ajoute := true
            p_flux.put_string( once "code" )
         end
         if commentaire then
            if separateur_doit_etre_ajoute then
               p_flux.put_string( once ", " )
            end
            separateur_doit_etre_ajoute := true
            p_flux.put_string( once "comment" )
         end
         if total then
            if separateur_doit_etre_ajoute then
               p_flux.put_string( once ", " )
            end
            separateur_doit_etre_ajoute := true
            p_flux.put_string( once "total" )
         end

         p_flux.put_new_line
      end

end
