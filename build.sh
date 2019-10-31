WINESRC=$PWD/../wine

docker build . --tag wine-build

docker run \
	-v $WINESRC:/wine \
	-v $PWD:/out \
	wine-build \
	/bin/bash -c "cd /out && ../wine/configure && make -j5"
