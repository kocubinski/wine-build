RELEASE ?= groovy
VERSION ?= wine-6.0.3~repack
SRC := src/$(VERSION)
WINESRC := $(PWD)/$(SRC)
PATCH := $(PWD)/mtkoan.patch

builder/Dockerfile:
	sed "s|@RELEASE@|$(RELEASE)|g;" builder/Dockerfile.in > \
	 builder/Dockerfile

mtkoan.patch:
	cat mouse.patch > mtkoan.patch
	cat misc.patch >> mtkoan.patch

image: builder/Dockerfile
	docker build builder/ --tag wine-build

# clone for manual modification. try
#
# diff -Naur src/wine-6.0.3\~repack.orig/dlls/dinput/mouse.c src/wine/dlls/dinput/mouse.c
# 
# or so to generate the patch file.
wine-src: mtkoan.patch
	mkdir -p src
	git clone -b wine-6.0.3 --depth 1 https://github.com/wine-mirror/wine.git src/wine
	cd src/wine && patch -p1 < $(PATCH)

wine-configure:
	docker run \
	 -i \
	 -v $(PWD)/src:/src \
	 wine-build \
	 /bin/bash -c "cd /src/wine && ./configure"

wine-make:
	docker run \
	 -i \
	 -v $(PWD)/src:/src \
	 wine-build \
	 /bin/bash -c "cd /src/wine && make -j20"

src: mtkoan.patch
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
	cp $(PATCH) src/mtkoan.patch
	docker run \
	 -i \
	 -v $(PWD)/src:/src \
	 wine-build \
	 /bin/bash -c "cd /$(SRC) && \
dpkg-source --commit . mtkoan-hack ./mtkoan.patch && \
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
	sudo dpkg -i src/fonts-wine_6*.deb
	-sudo dpkg -i src/libwine_6*.deb
	sudo apt install -f --yes
	sudo dpkg -i src/wine32_6*.deb
	sudo dpkg -i src/wine_6*.deb

uninstall:
	sudo apt remove fonts-wine libwine:i386 wine32 wine --yes

clean:
	rm -rf src
	rm -rf out
	rm -rf builder/Dockerfile
	rm -f mtkoan.patch
