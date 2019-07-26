#!/bin/bash

BUILD_DIR=$(mktemp -d --tmpdir oreka.XXXXX)


echo "Compiling and installing opus codec..."
tar -C $BUILD_DIR -xvf src/deps/opus-1.2.1.tar.gz
pushd $BUILD_DIR/opus-1.2.1 &> /dev/null
./configure --prefix=/opt/opus/
make CFLAGS="-fPIC -msse4.1"
ln -sf $BUILD_DIR/opus-1.2.1/.libs/libopus.a $BUILD_DIR/opus-1.2.1/.libs/libopusstatic.a
popd &> /dev/null

echo "Compiling and installing silk codec..."
tar -C $BUILD_DIR -xf src/deps/silk.tgz
pushd $BUILD_DIR/silk/SILKCodec/SILK_SDK_SRC_FIX/ &> /dev/null
CFLAGS='-fPIC' make lib
popd &> /dev/null

echo "Compiling and installing libg729..."
# copy the sources to the build dir
tar -C $BUILD_DIR -xf src/deps/bcg729-master.tar.gz
pushd $BUILD_DIR/bcg729-master &> /dev/null
# configure, make and install to the default prefix or different install root
sh ./autogen.sh
./configure --prefix=/usr
CFLAGS='-fPIC' make
make install
popd &> /dev/null


echo "Compiling and installing orkbasecxx..."
# copy the sources to the build dir
cp -r src/orkbasecxx $BUILD_DIR
pushd $BUILD_DIR/orkbasecxx &> /dev/null
# configure, make and install to the default prefix or different install root
autoreconf -i
./configure --prefix=/usr CXX=g++ \
    CPPFLAGS="-DXERCES_3 -I$BUILD_DIR/opus-1.2.1/include" \
    LDFLAGS="-Wl,-rpath=/usr/lib,-L$BUILD_DIR/opus-1.2.1/.libs"
make && make install
popd &> /dev/null


echo "Compiling and installing orkaudio..."
# copy the sources to the build dir
cp -r src/orkaudio $BUILD_DIR 
pushd $BUILD_DIR/orkaudio &> /dev/null
# configure, make and install to the default prefix or different install root
autoreconf -i
./configure --prefix=/usr CXX=g++ \
    CPPFLAGS="-DXERCES_3 -I$BUILD_DIR/orkbasecxx -I$BUILD_DIR/silk/SILKCodec/SILK_SDK_SRC_FIX/interface -I$BUILD_DIR/silk/SILKCodec/SILK_SDK_SRC_FIX/src -I$BUILD_DIR/opus-1.2.1/include  -I$BUILD_DIR/bcg729-1.0.0/include/" \
    LDFLAGS="-Wl,-rpath=/usr/lib,-L$BUILD_DIR/silk/SILKCodec/SILK_SDK_SRC_FIX -L$BUILD_DIR/opus-1.2.1/.libs -L$BUILD_DIR/orkbasecxx/.libs -L$BUILD_DIR/bcg729-1.0.0/src/.libs"
make && make install
popd &> /dev/null


PKG_DIR=$(mktemp -d)

cp -r src/deps/debian/* $PKG_DIR/
mkdir -p $PKG_DIR/usr/sbin
mkdir -p $PKG_DIR/usr/lib/orkaudio/plugins

cp /usr/sbin/orkaudio  $PKG_DIR/usr/sbin/
cp /usr/lib/{libbcg729.so,libbcg729.la,liborkbase.so,liborkbase.la,libgenerator.so,libgenerator.la,libvoip.so,libvoip.la} $PKG_DIR/usr/lib/
cp /usr/lib/orkaudio/plugins/*.so  $PKG_DIR/usr/lib/orkaudio/plugins/

mkdir -p /usr/deb

dpkg-deb --build $PKG_DIR /usr/deb/oreka.deb