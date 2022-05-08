#!/bin/bash
# Get an updated config.sub and config.guess
cp $BUILD_PREFIX/share/gnuconfig/config.* ./bin/scripts

export CXXFLAGS=$(echo "${CXXFLAGS}" | sed "s/-std=c++17/-std=c++14/g")

autoconf

if [[ "$host_alias" != "$build_alias" ]]
then
  # The normal build makes various tools that are used later in the build, in
  # particular omniidl. When cross-compiling, the tools must already be
  # available for your native platform.
  # Compile for native platform first.
  mkdir -p ${BUILD_PREFIX}/var/omniNames-logs
  touch ${BUILD_PREFIX}/var/omniNames-logs/.mkdir
  mkdir -p ${BUILD_PREFIX}/etc/omniORB-config
  touch ${BUILD_PREFIX}/etc/omniORB-config/.mkdir

  mkdir build-native
  cd build-native
  LDFLAGS_FOR_BUILD=$(echo $LDFLAGS | sed "s?$PREFIX?$BUILD_PREFIX?g")
  LDFLAGS_LD_FOR_BUILD=$(echo $LDFLAGS_LD | sed "s?$PREFIX?$BUILD_PREFIX?g")
  ../configure --prefix="${BUILD_PREFIX}" \
               --host=$build_alias \
               --build=$build_alias \
               --with-openssl \
               --with-omniORB-config="${BUILD_PREFIX}/etc/omniORB-config/omniORB.cfg" \
               --with-omniNames-logdir="${BUILD_PREFIX}/var/omniNames-logs" \
               CC=$CC_FOR_BUILD \
               CXX=$CXX_FOR_BUILD \
               AR=${build_alias}-ar \
               LD=${build_alias}-ld \
               RANLIB=${build_alias}-ranlib \
               LDFLAGS="$LDFLAGS_FOR_BUILD" \
               LDFLAGS_LD="$LDFLAGS_LD_FOR_BUILD"
  make -j$CPU_COUNT
  make install
  cd ..
fi

mkdir -p ${PREFIX}/var/omniNames-logs
touch ${PREFIX}/var/omniNames-logs/.mkdir
mkdir -p ${PREFIX}/etc/omniORB-config
touch ${PREFIX}/etc/omniORB-config/.mkdir

mkdir build
cd build
../configure --prefix="${PREFIX}" \
             --host=$host_alias \
             --build=$build_alias \
             --with-openssl \
             --with-omniORB-config="${PREFIX}/etc/omniORB-config/omniORB.cfg" \
             --with-omniNames-logdir="${PREFIX}/var/omniNames-logs"

make -j$CPU_COUNT
make install
