#!/bin/bash

set -o nounset
set -o errexit

WINESRC=$PWD/../wine
cp mouse-hack.patch $WINESRC
cd $WINESRC
patch -p1 < mouse-hack.patch
cd -

docker build . --tag wine-build

docker run \
	-v $WINESRC:/wine \
	-v $PWD:/out \
	wine-build \
	/bin/bash -c "cd /out && ../wine/configure && make -j5"
