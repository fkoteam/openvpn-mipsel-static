#!/bin/bash

set -e
set -x

mkdir ~/openvpn && cd ~/openvpn

BASE=`pwd`
SRC=$BASE/src
WGET="wget --prefer-family=IPv4"
DEST=$BASE/jffs
LDFLAGS="-L$DEST/lib -Wl,--gc-sections"
CPPFLAGS="-I$DEST/include"
CFLAGS="-mtune=mips1 -mips1 -O3 -ffunction-sections -fdata-sections"	
CXXFLAGS=$CFLAGS
CONFIGURE="./configure --prefix=/jffs --host=mips-linux"
MAKE="make -j`nproc`"
mkdir $SRC

######## ####################################################################
# ZLIB # ####################################################################
######## ####################################################################

mkdir $SRC/zlib && cd $SRC/zlib
$WGET https://www.zlib.net/fossils/zlib-1.2.10.tar.gz
tar zxvf zlib-1.2.10.tar.gz
cd zlib-1.2.10

LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
CXXFLAGS=$CXXFLAGS \
HOSTCC=mips-linux-uclibc-xgcc \
CROSS_PREFIX=mips-linux- \
./configure \
--prefix=/jffs

$MAKE
make install DESTDIR=$BASE

########### #################################################################
# OPENSSL # #################################################################
########### #################################################################

mkdir -p $SRC/openssl && cd $SRC/openssl
$WGET https://www.openssl.org/source/openssl-1.0.2j.tar.gz
tar zxvf openssl-1.0.2j.tar.gz
cd openssl-1.0.2j

./Configure linux-mips32 \
-mtune=mips1 -mips1 -ffunction-sections -fdata-sections -Wl,--gc-sections \
--prefix=/opts zlib \
--with-zlib-lib=$DEST/lib \
--with-zlib-include=$DEST/include

make CC=mips-linux-gcc
make CC=mips-linux-gcc install INSTALLTOP=$DEST OPENSSLDIR=$DEST/ssl

######## ####################################################################
# LZO2 # ####################################################################
######## ####################################################################

mkdir $SRC/lzo2 && cd $SRC/lzo2
$WGET http://www.oberhumer.com/opensource/lzo/download/lzo-2.09.tar.gz
tar zxvf lzo-2.09.tar.gz
cd lzo-2.09

LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
CXXFLAGS=$CXXFLAGS \
$CONFIGURE

$MAKE
make install DESTDIR=$BASE

########### #################################################################
# OPENVPN # #################################################################
########### #################################################################

mkdir $SRC/openvpn && cd $SRC/openvpn
$WGET https://swupdate.openvpn.org/community/releases/openvpn-2.4.0.tar.gz
tar zxvf openvpn-2.4.0.tar.gz
cd openvpn-2.4.0

LIBS="-lssl -lcrypto -lz" \
LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
CXXFLAGS=$CXXFLAGS \
$CONFIGURE \
--disable-plugins

$MAKE LIBS="-all-static -lssl -lcrypto -lz -llzo2"
make install DESTDIR=$BASE/openvpn
