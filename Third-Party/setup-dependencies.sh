set -e

# Absolute path to this script.
SCRIPT=$(readlink -f $0)
# Absolute path this script is in.
SCRIPTPATH=`dirname $SCRIPT`

cd $SCRIPTPATH

# DEPLOYMENT TARGET
export MACOSX_DEPLOYMENT_TARGET=12.0
export CFLAGS="-g -O2 -arch arm64 -mmacosx-version-min=12.0"
export LDFLAGS="-g -O2 -arch arm64 -mmacosx-version-min=12.0"

if [ ! -d "zlib" ]; then

    if [ ! -d "zlib-src" ]; then
        git clone https://github.com/madler/zlib zlib-src
    fi

    cd zlib-src
    
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
    
    cd libjpeg-src && mkdir build
    
    cd build && cmake .. \
        -DCMAKE_INSTALL_PREFIX="$SCRIPTPATH/libjpeg" \
        -DCMAKE_BUILD_TYPE=RelWithDebInfo \
        -DENABLE_SHARED=OFF \
        -DENABLE_STATIC=ON
    
    make -j$(sysctl -n hw.logicalcpu)
    mkdir "$SCRIPTPATH/libjpeg" && make install && cd ../..
fi

rm -fr libjpeg-src

if [ ! -d "libvnc" ]; then

    if [ ! -d "libvnc-src" ]; then
        git clone https://github.com/LibVNC/libvncserver.git libvnc-src
    fi

    cd libvnc-src && mkdir build
    
    cd build && cmake .. \
         -DCMAKE_INSTALL_PREFIX="$SCRIPTPATH/libvnc" \
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
    
    make -j$(sysctl -n hw.logicalcpu)
    mkdir "$SCRIPTPATH/libvnc" && make install && cd ../..
fi

rm -fr libvnc-src
