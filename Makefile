VERSION := wine-4.0
SRC := src/$(VERSION)
WINESRC := $(PWD)/$(SRC)
PATCH := $(PWD)/mouse.patch

src:
	mkdir src && \
	 cd src && \
	 apt source wine && \
	 cp -r $(VERSION) $(VERSION).orig && \
	 cp -r $(VERSION) $(VERSION).patched

src-old:
	mkdir src && \
	 cd src && \
	 apt source wine \
	 && \
	 cd $(VERSION) && \
	 cp $(PATCH) . && \
	 patch -p1 < $(PWD)/mouse.patch


source: $(WINESRC)

build-src: 
	docker build builder/ --tag wine-build
	docker run \
	 -v $(PWD)/out:/out \
	 wine-build \
	 /bin/bash -c "mkdir /src && \
cd /src && \
apt-get source wine --compile"

build:
	docker build builder/ --tag wine-build
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
