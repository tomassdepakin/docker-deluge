FROM ghcr.io/linuxserver/baseimage-ubuntu:bionic

# set version label
LABEL maintainer="tomassdepakin"

# environment variables
ARG DEBIAN_FRONTEND="noninteractive"
ENV PYTHON_EGG_CACHE="/config/plugins/.python-eggs"

# install software
RUN \
 echo "**** add repositories ****" && \
 apt-get update && \
 apt-get install -y \
	wget gcc g++ make autoconf libtool libboost-system1.65.1 libboost-system1.65-dev \
    libboost-chrono1.65.1 libboost-chrono1.65-dev \
    libboost-random1.65.1 libboost-random1.65-dev \
    libboost-python1.65.1 libboost-python1.65-dev \
    libssl-dev python3 python3-distutils python3-dev \
    python3-setuptools && \
 echo "**** building libtorrent ****" && \
 cd /usr/src && \
    wget https://github.com/arvidn/libtorrent/archive/libtorrent-1_1_14.tar.gz && \
    tar xf libtorrent-1_1_14.tar.gz && \
    cd libtorrent-libtorrent-1_1_14 && \
    ./autotool.sh && \
    PYTHON=/usr/bin/python3 ./configure \
        --with-boost-python=boost_python3 \
        --enable-static=no \
        --enable-python-binding \
        --prefix=/usr/local && \
    make -j6 && make install && ldconfig && \
 echo "**** building deluge ****" && \
 cd /usr/src && \
    wget https://ftp.osuosl.org/pub/deluge/source/2.0/deluge-2.0.3.tar.xz && \
    tar xf deluge-2.0.3.tar.xz && \
    cd deluge-2.0.3 && \
    python3 setup.py build && \
    python3 setup.py install && \
 echo "**** cleanup ****"  && \
 apt-get remove -y --purge \
    wget gcc g++ make autoconf libtool \
    libboost-system1.65-dev libboost-chrono1.65-dev \
    libboost-random1.65-dev libboost-python1.65-dev \
    libssl-dev python3-dev && \
 apt-get autoremove -y --purge && \
 rm -rf \
    /tmp/* \
    /usr/src/* \
    /var/lib/apt/lists/* \
    /var/tmp/*

# add local files
COPY root/ /

# ports and volumes
EXPOSE 8112 6881 6881/udp 58846 58946 58946/udp
VOLUME /config /downloads /torrents
