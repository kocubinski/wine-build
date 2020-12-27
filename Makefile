RELEASE ?= groovy
VERSION ?= wine-5.0
SRC := src/$(VERSION)
WINESRC := $(PWD)/$(SRC)
PATCH := $(PWD)/mouse.patch

builder/Dockerfile:
	sed "s|@RELEASE@|$(RELEASE)|g;" builder/Dockerfile.in > \
	 builder/Dockerfile

image: builder/Dockerfile
	docker build builder/ --tag wine-build

src:
	mkdir src && \
	 cd src && \
	 apt source wine && \
	 cp -r $(VERSION) $(VERSION).orig && \
	 cp -r $(VERSION) $(VERSION).patched && \
	 cd $(VERSION).patched && patch -p1 < $(PATCH) && \
	 cd ../$(VERSION) && patch -p1 < $(PATCH)

src-docker:
	mkdir src
	docker run \
	 -v $(PWD)/src:/src \
	 wine-build \
	 /bin/bash -c "cd /src && \
chown -Rv _apt:root /src && \
apt source wine"
	sudo chown -R $(shell id -u):$(shell id -g) src

build: src image
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
	sudo dpkg -i src/fonts-wine_5*.deb
	sudo dpkg -i src/libwine_5*.deb
	sudo dpkg -i src/wine32_5*.deb
	sudo dpkg -i src/wine_5*.deb

uninstall:
	sudo apt remove fonts-wine libwine:i386 wine32 wine --yes

clean:
	rm -rf src
	rm -rf out
	rm -rf builder/Dockerfile
