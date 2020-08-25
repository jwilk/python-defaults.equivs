# Copyright © 2020 Jakub Wilk <jwilk@jwilk.net>
# SPDX-License-Identifier: MIT

$(foreach var,$(shell dpkg-architecture),$(eval export $(var)))

deb-version = 2.7.18-2
cur-version = 2.7.18
next-version = 2.7.19

deb-suffix =  _$(deb-version)_$(DEB_HOST_ARCH).deb

pkg-names = libpython-dbg libpython-dev libpython-stdlib python python-dbg python-dev python-doc python-minimal
equivs = $(addsuffix .equivs,$(pkgnames))
debs = $(addsuffix $(deb-suffix),$(pkg-names))

.PHONY: all
all: $(debs)

%$(deb-suffix): %.equivs
	equivs-build $(<)

%.equivs:
	echo 'Section: python' > $(@).tmp
	echo 'Maintainer: Jakub Wilk <jwilk@jwilk.net>' >> $(@).tmp
	echo >> $(@).tmp
	echo 'Package: $(@:.equivs=)' >> $(@).tmp
	echo 'Version: $(deb-version)' >> $(@).tmp
	echo 'Depends: $(subst python,python2.7,$(@:.equivs=)) (>= $(cur-version)), $(subst python,python2.7,$(@:.equivs=)) (<< $(next-version))' >> $(@).tmp
	echo 'Architecture: any' >> $(@).tmp
	echo 'Multi-Arch: allowed' >> $(@).tmp
	echo 'Description: Python 2.X ($(@:.equivs=))' >> $(@).tmp
	[ $@ != python-minimal.equivs ] || echo 'Links: /usr/bin/python2.7 /usr/bin/python' >> $(@).tmp
	mv $(@).tmp $(@)

.PHONY: clean
clean:
	rm -f *.tmp *.equivs *.deb *.changes *.buildinfo

# vim:ts=4 sts=4 sw=4 noet
