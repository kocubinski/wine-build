SRC := src/wine-4.0
WINESRC := $(PWD)/$(SRC)

$(WINESRC):
	cd src && apt source wine

source: $(WINESRC)
	cd $(WINESRC) && patch -p1 < $(PWD)/mouse.patch

build: source
	docker build builder/ --tag wine-build
	docker run \
	 -v $(WINESRC):/$(SRC) \
	 -v $(PWD)/out:/out \
	 wine-build \
	 /bin/bash -c "cd /out && /$(SRC)/configure && make -j5"

clean:
	rm -rf src/*
	rm -rf out/*
