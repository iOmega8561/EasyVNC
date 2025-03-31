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

if [ ! -d "libvnc" ]; then

    if [ ! -d "libvnc-src" ]; then
        git clone https://github.com/LibVNC/libvncserver.git libvnc-src
    fi

    cd libvnc-src && mkdir build
    
    cd build && cmake .. \
         -DCMAKE_INSTALL_PREFIX="$SCRIPTPATH/libvnc" \
         -DCMAKE_BUILD_TYPE=RelWithDebInfo \
         -DBUILD_SHARED_LIBS=OFF \
         -DWITH_GNUTLS=OFF \
         -DWITH_OPENSSL=OFF \
         -DWITH_LIBJPEG=OFF \
         -DWITH_SASL=OFF \
         -DWITH_ZLIB=OFF
    
    make -j$(sysctl -n hw.logicalcpu)
    mkdir "$SCRIPTPATH/libvnc" && make install && cd ../..
fi

rm -fr libvnc-src
