FROM i386/ubuntu:disco
RUN . /etc/lsb-release && echo "deb-src http://us.archive.ubuntu.com/ubuntu/ $DISTRIB_CODENAME main restricted" >> /etc/apt/sources.list
RUN . /etc/lsb-release && echo "deb-src http://us.archive.ubuntu.com/ubuntu/ $DISTRIB_CODENAME universe" >> /etc/apt/sources.list
RUN apt-get update
RUN apt-get install build-essential --yes
RUN apt-get build-dep wine --yes
RUN apt-get install vim --yes
