SRC := src/wine-4.0
WINESRC := $(PWD)/$(SRC)

$(WINESRC):
	cd src && apt source wine

source: $(WINESRC)
	cd $(WINESRC) && patch -p1 < $(PWD)/mouse.patch

build: 
	docker build builder/ --tag wine-build
	docker run \
	 -v $(PWD)/out:/out \
	 wine-build \
	 /bin/bash -c "mkdir /src && \
cd /src && \
apt-get source wine --compile"

clean:
	rm -rf src/*
	rm -rf out/*
