PKG_ROOT    = .
PKG_VERSION = $(shell gawk '/^Version:/{print $$2}' $(PKG_ROOT)/DESCRIPTION)
PKG_NAME    = $(shell gawk '/^Package:/{print $$2}' $(PKG_ROOT)/DESCRIPTION)

RFILES    = $(wildcard $(PKG_ROOT)/R/*.R)
VIGNETTES = $(wildcard $(PKG_ROOT)/vignettes/*.Rmd)

.PHONY: all check check-as-cran install clean

all: $(PKG_NAME)_$(PKG_VERSION).tar.gz

.document.Rout: $(RFILES) $(VIGNETTES) $(PKG_ROOT)/DESCRIPTION
	R --vanilla --quiet -e "devtools::document('$(PKG_ROOT)')"
	touch $@

$(PKG_NAME)_$(PKG_VERSION).tar.gz: .document.Rout
	R CMD build --md5 $(PKG_ROOT)

check: $(PKG_NAME)_$(PKG_VERSION).tar.gz
	R CMD check $(PKG_NAME)_$(PKG_VERSION).tar.gz

check-as-cran: $(PKG_NAME)_$(PKG_VERSION).tar.gz
	R CMD check --as-cran $(PKG_NAME)_$(PKG_VERSION).tar.gz

install: $(PKG_NAME)_$(PKG_VERSION).tar.gz
	R CMD INSTALL $(PKG_NAME)_$(PKG_VERSION).tar.gz

clean:
	$(RM)  $(PKG_NAME)_$(PKG_VERSION).tar.gz
	$(RM) -r $(PKG_NAME).Rcheck
	$(RM) .document.Rout

