ENTREE := luat_codemetre.e

PREFIXE := codemetre

VERSION := 0.15.0

SE := compile

.PHONY: info debug sedb release clean

info :
	@echo "options : debug, sedb, release ou clean"

debug : .Prod
	$(SE) -debug -all_check $(ENTREE) -o .Prod/$(PREFIXE)_debug

sedb : .Prod
	$(SE) -debug -all_check -sedb $(ENTREE) -o .Prod/$(PREFIXE)_sedb

release : .Prod
	$(SE) -clean -boost -c_mode release $(ENTREE) -o .Prod/$(PREFIXE)

clean :
	$(RM) -Rf .Prod
	clean $(ENTREE)

.Prod:
	mkdir .Prod
