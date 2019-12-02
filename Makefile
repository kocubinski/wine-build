RELEASE ?= disco
VERSION ?= wine-4.0
SRC := src/$(VERSION)
WINESRC := $(PWD)/$(SRC)
PATCH := $(PWD)/mouse.patch

src:
	mkdir src && \
	 cd src && \
	 apt source wine && \
	 cp -r $(VERSION) $(VERSION).orig && \
	 cp -r $(VERSION) $(VERSION).patched && \
	 cd $(VERSION).patched && patch -p1 < $(PATCH) && \
	 cd ../$(VERSION) && patch -p1 < $(PATCH)

builder/Dockerfile:
	sed "s|@RELEASE@|$(RELEASE)|g;" builder/Dockerfile.in > \
	 builder/Dockerfile

build: src builder/Dockerfile
	docker build builder/ --tag wine-build
	cp $(PATCH) src/mouse.patch
	docker run \
	 -i \
	 -v $(PWD)/src:/src \
	 wine-build \
	 /bin/bash -c "cd /$(SRC) && \
dpkg-source --commit . mouse-hack ./mouse.patch && \
dpkg-buildpackage -us -uc"

rebuild:
	docker build builder/ --tag wine-build
	docker run \
	 -i \
	 -v $(PWD)/src:/src \
	 wine-build \
	 /bin/bash -c "cd /$(SRC) && \
dpkg-buildpackage -us -uc"

install:
	sudo dpkg -i src/fonts-wine_4*.deb
	sudo dpkg -i src/libwine_4*.deb
	sudo dpkg -i src/wine32_4*.deb
	sudo dpkg -i src/wine_4*.deb

uninstall:
	sudo apt remove fonts-wine libwine:i386 wine32 wine --yes

clean:
	rm -rf src
	rm -rf out
	rm -rf builder/Dockerfile
