ENTREE := luat_codemetre.e

PREFIXE := codemetre

VERSION_MAJEURE := 0.18.5
VERSION_MINEURE :=
VERSION := $(VERSION_MAJEURE)$(VERSION_MINEURE)

SE := compile

.PHONY: info debug sedb profile release delivery src clean

info :
	@echo "options : debug, sedb, profile, release, delivery, src ou clean"

debug : .Prod
	$(SE) -debug -all_check $(ENTREE) -o .Prod/$(PREFIXE)_debug

sedb : .Prod
	$(SE) -debug -all_check -sedb $(ENTREE) -o .Prod/$(PREFIXE)_sedb

profile : .Prod
	$(SE) -boost -c_mode profile $(ENTREE) -o .Prod/$(PREFIXE)_profile

release : .Prod
	$(SE) -clean -boost -c_mode release $(ENTREE) -o .Prod/$(PREFIXE)

delivery : $(PREFIXE)-$(VERSION) $(PREFIXE)-$(VERSION)/doc $(PREFIXE)-$(VERSION)/i18n $(PREFIXE)-$(VERSION)/man $(PREFIXE)-$(VERSION)/src
	$(SE)_to_c -boost -c_mode release $(ENTREE) -o $(PREFIXE)
	cp Information/* $(PREFIXE)-$(VERSION)/doc
	cp Internationalisation/codemetre.fr.UTF-8.mo $(PREFIXE)-$(VERSION)/i18n/fr/LC_MESSAGES/codemetre.mo
	cp Manuel/* $(PREFIXE)-$(VERSION)/man
	cp $(patsubst %.e,%,$(ENTREE)).[chim]* $(PREFIXE)-$(VERSION)/src
	tar cjvf $(PREFIXE)-$(VERSION).c.tar.bz2 $(PREFIXE)-$(VERSION)
	clean $(ENTREE)
	$(RM) -Rf $(PREFIXE)-$(VERSION)

src :
	./livraison_src.sh $(VERSION)

clean :
	$(RM) -Rf .Prod
	clean $(ENTREE)

.Prod:
	mkdir .Prod

$(PREFIXE)-$(VERSION) :
	mkdir $(PREFIXE)-$(VERSION)

$(PREFIXE)-$(VERSION)/doc : $(PREFIXE)-$(VERSION)
	mkdir $(PREFIXE)-$(VERSION)/doc

$(PREFIXE)-$(VERSION)/i18n : $(PREFIXE)-$(VERSION)
	mkdir -p $(PREFIXE)-$(VERSION)/i18n/fr/LC_MESSAGES

$(PREFIXE)-$(VERSION)/man : $(PREFIXE)-$(VERSION)
	mkdir $(PREFIXE)-$(VERSION)/man

$(PREFIXE)-$(VERSION)/src : $(PREFIXE)-$(VERSION)
	mkdir $(PREFIXE)-$(VERSION)/src
