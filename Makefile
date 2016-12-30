#
# Makefile:  Beersmith repack
#


SCRIPTROOT=$(shell dirname ./)
BUILDROOT=$(shell ( cd ${SCRIPTROOT} && pwd ))

PACKAGE=$(shell ( ls ${BUILDROOT}/DEBPACKAGE/*.deb | rev | cut -d '-' -f2 | cut -d '/' -f1 | rev ))
VERSION=$(shell ( ls ${BUILDROOT}/DEBPACKAGE/*.deb | rev | cut -d '-' -f1 | rev | cut -d '_' -f1 ))
RELEASE=1

SPECFILE=$(BUILDROOT)/SPECS/$(PACKAGE).spec
MAKEFILE=$(BUILDROOT)/Makefile

BASEDIR=$(BUILDROOT)/SOURCES/src
TARFILE=$(BUILDROOT)/SOURCES/$(PACKAGE)-$(VERSION).tar.gz
SRCPATH=$(BUILDROOT)/SOURCES/$(PACKAGE)-$(VERSION)


DEBFILE=$(shell ls ${BUILDROOT}/DEBPACKAGE/BeerSmith*.deb )

all: gen-spec rpm

build-dirs:
	mkdir -p $(BASEDIR)
	mkdir -p $(SRCPATH)
	mkdir -p $(BUILDROOT)/RPMS
	mkdir -p $(BUILDROOT)/SRPMS

rpm: clean build-dirs
	mv $(BASEDIR)/* $(SRCPATH)/
	cd $(BUILDROOT)/SOURCES && tar czf $(TARFILE) -C $(BUILDROOT)/SOURCES/ $(PACKAGE)-$(VERSION)
	cd $(BUILDROOT)/RPMS && rpmbuild -v --define "%version $(VERSION)" --define "%release $(RELEASE)" --define "%tarfile $(TARFILE)" --define "%_topdir $(BUILDROOT)"  --define "%srcdir $(SRCPATH)" -ba $(SPECFILE)

unpack-deb: clean build-dirs
	mkdir -p $(BUILDROOT)/tmp
	( cd $(BUILDROOT)/tmp && ar vx $(DEBFILE) )
	( cd $(BASEDIR) && tar xzf $(BUILDROOT)/tmp/data.tar.gz )
	rm -rf $(BUILDROOT)/tmp

gen-spec: unpack-deb
	/bin/bash $(BUILDROOT)/utils/gen-spec.sh

clean:
	rm -Rf $(BUILDROOT)/BUILD
	rm -Rf $(TARFILE)
	rm -Rf $(SRCPATH)
	find ./ -name "*~" -delete
	rm -Rf $(BUILDROOT)/BUILDROOT
	rm -Rf $(BUILDROOT)/RPMS
	rm -Rf $(BUILDROOT)/SRPMS
	rm -rf $(BUILDROOT)/SOURCES
	rm -rf $(BUILDROOT)/SPECS

debug:
	@ echo "PACKAGENAME.......................<$(PACKAGE)>"
	@ echo "VERSION...........................<$(VERSION)>"
	@ echo "RELEASE...........................<$(RELEASE)>"

help:
	@echo "Usage:"
	@echo "  help  ............. Dump message about targets"
	@echo "  clean ............. Cleans up build process artifacts"
	@echo "  rpm   ............. Builds rpms for all modules"
	@echo "  debug ............. Use to display environment etc for debugging"
