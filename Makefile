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

clean:
	rm -rf src
	rm -rf out
