#!/bin/bash

set -o nounset
set -o errexit

WINESRC=$PWD/src/wine-4.0

cp mouse.patch $WINESRC
cd $WINESRC
git reset HEAD --hard
patch -p1 < mouse-hack.patch
cd -

docker build builder/ --tag wine-build

#	/bin/bash -c "cd /out && ../wine/configure && make -j5"
docker run \
	-v $WINESRC:/wine \
	-v $PWD:/out \
	wine-build \
	/bin/bash -c "cd /out && make -j5"
