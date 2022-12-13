#!/bin/bash

# Compile Python from source on Debian systems
# 1. Copy src tar to /tmp
# 2. Edit TAR_SRC, VERSION, PYTHONS_LOCATION to reflect preferences
#
TAR_SRC="Python-3.9.7.tar.xz"
VERSION="3.9.7"
# directory to hold multiple versions
PYTHONS_LOCATION="/tmp/pythons"

# install dependencies (check for new/different versions. Run separately if preferred)
sudo apt update
sudo apt --assume-yes install xz-utils gcc make \
	libbz2-dev libffi-dev libc6-dev libdb5.3-dev \
	liblzma-dev libmpdec-dev libncursesw5-dev \
	libreadline6-dev libsqlite3-dev libtinfo-dev \
	libssl-dev libexpat1-dev zlib1g-dev libncurses5-dev \
	libgdbm-dev libnss3-dev libbz2-dev


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

LD_FLAGS="-L$PY_PREFIX/extlib/lib -Wl,--rpath=$PY_PREFIX/lib -Wl,--rpath=$PY_PREFIX/extlib/lib"

# enable optimization with 
cd /tmp && \ 
  tar -xvf $TAR_SRC && \
  cd $EXTRACTED_SRC && \
  ./configure --prefix=$PY_PREFIX --enable-shared LDFLAGS="$LD_FLAGS" && make && make install

# create a test venv
$PY_PREFIX/bin/python3 -m venv $TEST_VENV

# Run tests if needed 
# $PY_PREFIX/bin/python3 -m test
