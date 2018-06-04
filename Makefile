drivers=sgp30 sgpc3
clean_drivers=$(foreach d, $(drivers), clean_$(d))
release_drivers=$(foreach d, $(drivers), release/$(d))

.PHONY: FORCE all $(release_drivers) $(clean_drivers)

all: $(drivers)

$(drivers): FORCE
	cd $@ && $(MAKE) $(MFLAGS)

svm30: FORCE
	cd $@ && $(MAKE) $(MFLAGS)

$(release_drivers):
	export rel=$@ && \
	export driver=$${rel#release/} && \
	export tag="$$(git describe --always --dirty)" && \
	export pkgname="$${driver}-$${tag}" && \
	export pkgdir="release/$${pkgname}" && \
	rm -rf "$${pkgdir}" && mkdir -p "$${pkgdir}" && \
	cp -r embedded-common/* "$${pkgdir}" && \
	cp -r sgp-common/* "$${pkgdir}" && \
	cp -r $${driver}/* "$${pkgdir}" && \
	perl -pi -e 's/^sensirion_common_dir :=.*$$/sensirion_common_dir := ./' "$${pkgdir}/Makefile" && \
	perl -pi -e 's/^sgp_common_dir :=.*$$/sgp_common_dir := ./' "$${pkgdir}/Makefile" && \
	perl -pi -e "s/^(#define\s+SGP_DRV_VERSION_STR\s+)\".*\"$$/\\1\"$${tag}\"/" "$${pkgdir}/$${driver}.c" && \
	cd "$${pkgdir}" && $(MAKE) $(MFLAGS) && $(MAKE) clean $(MFLAGS) && cd - && \
	cd release && zip -r "$${pkgname}.zip" "$${pkgname}" && cd - && \
	ln -sf $${pkgname} $@

release: clean $(release_drivers)

$(clean_drivers):
	export rel=$@ && \
	export driver=$${rel#clean_} && \
	cd $${driver} && $(MAKE) clean $(MFLAGS) && cd -

clean: $(clean_drivers)
	cd svm30 && $(MAKE) clean $(MFLAGS) && cd - && \
	rm -rf release
