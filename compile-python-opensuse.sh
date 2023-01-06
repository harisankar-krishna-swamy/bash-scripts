#!/usr/bin/bash

# Compile Python from source on OpenSuse
# 1. Copy src tar to /tmp
# 2. Edit TAR_SRC, VERSION, MAJOR_VERSION, PYTHONS_LOCATION to reflect preferences
#
TAR_SRC="Python-3.9.7.tar.xz"
VERSION="3.9.7"
MAJOR_VERSION="3.9"
# directory to hold multiple versions
PYTHONS_LOCATION="/tmp/pythons"

# dependencies (need to refine this)
sudo zypper -n in libopenssl-1_1-devel ncurses-devel xz-devel libbz2-devel \
         libffi-devel glibc-devel libdb-4_8-devel lzma-sdk-devel \
         readline-devel sqlite3-devel libexpat-devel lzlib-devel \
         zlib-devel libopenssl-devel gcc make 

TEST_VENV="/tmp/pyvenv-$VERSION"
PY_PREFIX="$PYTHONS_LOCATION/python-$VERSION"
EXTRACTED_SRC="Python-$VERSION"

FOLDERS=($EXTRACTED_SRC $PY_PREFIX $TEST_VENV)

for folder in ${FOLDERS[@]}; do
    echo $folder;
    if [ -d $folder ]; then
        rm -rf $folder
    fi
done

mkdir -p $PY_PREFIX
LD_FLAGS="-L$PY_PREFIX/lib64 -Wl,--rpath=$PY_PREFIX/lib64"

# enable optimization with --enable-optimizations in configure
cd /tmp && \ 
  tar -xvf $TAR_SRC && \
  cd $EXTRACTED_SRC && \
  ./configure --prefix=$PY_PREFIX --enable-shared --enable-ipv6 --enable-shared --with-system-ffi \
              LDFLAGS="$LD_FLAGS" && make && make install

ln -s $PY_PREFIX/lib64/python$MAJOR_VERSION/lib-dynload $PY_PREFIX/lib/python$MAJOR_VERSION/lib-dynload

# create a test venv
$PY_PREFIX/bin/python3 -m venv $TEST_VENV

# Run tests if needed 
# $PY_PREFIX/bin/python3 -m test
