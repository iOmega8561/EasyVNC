#!/usr/bin/env bash
#
#  Copyright (C) 2025  Giuseppe Rocco
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <https://www.gnu.org/licenses/>.

set -e

# Absolute path to this script.
SCRIPT=$(readlink -f $0)
# Absolute path this script is in.
SCRIPTPATH=`dirname $SCRIPT`

cd $SCRIPTPATH

# Grabbing functions for universal builds
source "${SCRIPTPATH}/setup-functions.sh"

# DEPLOYMENT TARGET
export MACOSX_DEPLOYMENT_TARGET=13.0

# GLOBAL COMPILER/LINKER FLAGS
export CFLAGS="-g -O2 -mmacosx-version-min=${MACOSX_DEPLOYMENT_TARGET}"
export LDFLAGS="-g -O2 -mmacosx-version-min=${MACOSX_DEPLOYMENT_TARGET}"

# ZLIB
if [ ! -d "zlib" ]; then

    if [ ! -d "zlib-src" ]; then
        git clone https://github.com/madler/zlib zlib-src
    fi

    cd zlib-src
    
    CFLAGS="${CFLAGS} -arch arm64 -arch x86_64" \
    LDFLAGS="${LDFLAGS} -arch arm64 -arch x86_64" \
    ./configure --static --prefix="$SCRIPTPATH/zlib"
    
    make -j$(sysctl -n hw.logicalcpu)
    mkdir "$SCRIPTPATH/zlib" && make install && cd ..
fi

rm -fr zlib-src

# LIBJPEG-TURBO
if [ ! -d "libjpeg" ]; then

    if [ ! -d "libjpeg-src" ]; then
        git clone https://github.com/libjpeg-turbo/libjpeg-turbo.git libjpeg-src
    fi
    
    build_cmake_universal "libjpeg" \
        -DCMAKE_BUILD_TYPE=RelWithDebInfo \
        -DENABLE_SHARED=OFF \
        -DENABLE_STATIC=ON
    
    merge_lipo_universal "libjpeg"
fi

rm -fr libjpeg-src

# LIBVNCSERVER
if [ ! -d "libvnc" ]; then

    if [ ! -d "libvnc-src" ]; then
        git clone https://github.com/LibVNC/libvncserver.git libvnc-src
    fi

    build_cmake_universal "libvnc" \
        -DCMAKE_BUILD_TYPE=RelWithDebInfo \
        -DBUILD_SHARED_LIBS=OFF \
        -DWITH_ZLIB=ON \
        -DZLIB_LIBRARY="$SCRIPTPATH/zlib/lib/libz.a" \
        -DZLIB_INCLUDE_DIR="$SCRIPTPATH/zlib/include" \
        -DWITH_JPEG=ON \
        -DJPEG_LIBRARY="$SCRIPTPATH/libjpeg/lib/libjpeg.a" \
        -DJPEG_INCLUDE_DIR="$SCRIPTPATH/libjpeg/include" \
        -DWITH_GNUTLS=OFF \
        -DWITH_OPENSSL=OFF \
        -DWITH_SASL=OFF
    
    merge_lipo_universal "libvnc"
fi

rm -fr libvnc-src
