#!/bin/bash
# Copyright 2018 Tymoteusz Blazejczyk
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -e
set -u

function install_systemc {
    if [ ! -f "$SYSTEMC_ROOT/$SYSTEMC_TAR" ]; then
        echo "Downloading $SYSTEMC_URL/$SYSTEMC_TAR..."
        wget $SYSTEMC_URL/$SYSTEMC_TAR -O $SYSTEMC_ROOT/$SYSTEMC_TAR
    else
        echo "SystemC $SYSTEMC_URL/$SYSTEMC_TAR already downloaded"
    fi

    echo "Creating SystemC directories..."
    mkdir -p /tmp/systemc/$SYSTEMC_VERSION
    mkdir -p /tmp/src/systemc/$SYSTEMC_VERSION
    mkdir -p /tmp/src/systemc/$SYSTEMC_VERSION/build

    echo "Unpacking SystemC archive file..."
    tar -xf $SYSTEMC_ROOT/$SYSTEMC_TAR \
        -C /tmp/src/systemc/$SYSTEMC_VERSION --strip-components 1

    echo "Patching SystemC sources..."
    cd /tmp/src/systemc/$SYSTEMC_VERSION
    sed -i 's/nb_put/this->nb_put/' \
        src/tlm_core/tlm_1/tlm_analysis/tlm_analysis_fifo.h

    echo "Configuring SystemC sources..."
    cd /tmp/src/systemc/$SYSTEMC_VERSION/build
    ../configure --enable-pthreads --enable-shared \
        --prefix=/tmp/systemc/$SYSTEMC_VERSION

    echo "Building SystemC library..."
    make -j`nproc`

    echo "Installing SystemC library..."
    make install

    export SYSTEMC_INCLUDE=/tmp/systemc/$SYSTEMC_VERSION/include
    export SYSTEMC_LIBDIR=/tmp/systemc/$SYSTEMC_VERSION/lib-linux64
}

function install_uvm_systemc {
    if [ ! -f "$UVM_SYSTEMC_ROOT/$UVM_SYSTEMC_TAR" ]; then
        echo "Downloading $UVM_SYSTEMC_URL/$UVM_SYSTEMC_TAR..."
        wget $UVM_SYSTEMC_URL/$UVM_SYSTEMC_TAR \
            -O $UVM_SYSTEMC_ROOT/$UVM_SYSTEMC_TAR
    else
        echo "UVM-SystemC $UVM_SYSTEMC_URL/$UVM_SYSTEMC_TAR already downloaded"
    fi

    echo "Creating UVM-SystemC directories..."
    mkdir -p /tmp/src/uvm-systemc/$UVM_SYSTEMC_VERSION
    mkdir -p /tmp/src/uvm-systemc/$UVM_SYSTEMC_VERSION/build

    echo "Unpacking UVM-SystemC archive file..."
    tar -xvf $UVM_SYSTEMC_ROOT/$UVM_SYSTEMC_TAR \
        -C /tmp/src/uvm-systemc/$UVM_SYSTEMC_VERSION --strip-components 1

    echo "Configuring UVM-SystemC sources..."
    cd /tmp/src/uvm-systemc/$UVM_SYSTEMC_VERSION/build
    ../configure --enable-shared --with-systemc=/tmp/systemc/$SYSTEMC_VERSION \
        --prefix=/tmp/systemc/$SYSTEMC_VERSION

    echo "Building UVM-SystemC library..."
    make -j`nproc`

    echo "Installing UVM-SystemC library..."
    make install
}

function install_scv {
    if [ ! -f "$SCV_ROOT/$SCV_TAR" ]; then
        echo "Downloading $SCV_URL/$SCV_TAR..."
        wget $SCV_URL/$SCV_TAR -O $SCV_ROOT/$SCV_TAR
    else
        echo "SCV $SCV_URL/$SCV_TAR already downloaded"
    fi

    echo "Creating SCV directories..."
    mkdir -p /tmp/src/scv/$SCV_VERSION
    mkdir -p /tmp/src/scv/$SCV_VERSION/build

    echo "Unpacking SCV archive file..."
    tar -xf $SCV_ROOT/$SCV_TAR \
        -C /tmp/src/scv/$SCV_VERSION --strip-components 1

    echo "Configuring SCV sources..."
    cd /tmp/src/scv/$SCV_VERSION/build
    ../configure --enable-shared --with-systemc=/tmp/systemc/$SYSTEMC_VERSION \
        --prefix=/tmp/systemc/$SYSTEMC_VERSION

    echo "Building SCV library..."
    make -j`nproc`

    echo "Installing SCV library..."
    make install
}

function install_verilator {
    if [ ! -f "$VERILATOR_ROOT/$VERILATOR_TAR" ]; then
        echo "Downloading $VERILATOR_URL/$VERILATOR_TAR..."
        wget $VERILATOR_URL/$VERILATOR_TAR -O $VERILATOR_ROOT/$VERILATOR_TAR
    else
        echo "Verilator $VERILATOR_URL/$VERILATOR_TAR already downloaded"
    fi

    echo "Creating Verilator directories..."
    mkdir -p /tmp/verilator/$VERILATOR_VERSION
    mkdir -p /tmp/src/verilator/$VERILATOR_VERSION

    echo "Unpacking Verilator archive file..."
    tar -xzf $VERILATOR_ROOT/$VERILATOR_TAR \
        -C /tmp/src/verilator/$VERILATOR_VERSION --strip-components 1

    echo "Installing Verilator dependencies..."
    sudo apt-get install git make autoconf g++ flex bison -y

    echo "Configuring Verilator sources..."
    cd /tmp/src/verilator/$VERILATOR_VERSION
    ./configure --prefix=/tmp/verilator/$VERILATOR_VERSION

    echo "Building Verilator library..."
    make -j`nproc`

    echo "Installing Verilator library..."
    make install

    export VERILATOR_ROOT=/tmp/verilator/$VERILATOR_VERSION
}

function install_gtest {
    if [ ! -f "$GTEST_ROOT/$GTEST_TAR" ]; then
        echo "Downloading $GTEST_URL/$GTEST_TAR..."
        wget $GTEST_URL/$GTEST_TAR -O $GTEST_ROOT/$GTEST_TAR
    else
        echo "Google Test $GTEST_URL/$GTEST_TAR already downloaded"
    fi

    echo "Creating Google Test directories..."
    mkdir -p /tmp/gtest/$GTEST_VERSION
    mkdir -p /tmp/src/gtest/$GTEST_VERSION
    mkdir -p /tmp/src/gtest/$GTEST_VERSION/build

    echo "Unpacking Google Test archive file..."
    uzip $GTEST_ROOT/$GTEST_TAR -d /tmp/src/gtest

    echo "Configuring Google Test sources..."
    cd /tmp/src/gtest/$GTEST_VERSION/build
    cmake -DBUILD_SHARED_LIBS=ON \
        -DCMAKE_INSTALL_PREFIX=/tmp/gtest/$GTEST_VERSION ..

    echo "Building Google Test library..."
    cmake --build . --target all -- -j`nproc`

    echo "Installing Google Test library..."
    cmake --build . --target install

    export GTEST_ROOT=/tmp/gtest/$GTEST_VERSION
}

echo "Preparing tools..."

sudo apt-get update -qq

SYSTEMC_ROOT=$HOME/systemc
SYSTEMC_VERSION=2.3.2
SYSTEMC_URL=http://accellera.org/images/downloads/standards/systemc
SYSTEMC_TAR=systemc-$SYSTEMC_VERSION.tar.gz

install_systemc

UVM_SYSTEMC_ROOT=$HOME/uvm-systemc
UVM_SYSTEMC_VERSION=1.0-beta1
UVM_SYSTEMC_URL=http://accellera.org/images/downloads/standards/systemc
UVM_SYSTEMC_TAR=uvm-systemc-$UVM_SYSTEMC_VERSION.tar.gz

install_uvm_systemc

SCV_ROOT=$HOME/scv
SCV_VERSION=2.0.1
SCV_URL=http://accellera.org/images/downloads/standards/systemc
SCV_TAR=scv-$SCV_VERSION.tar.gz

install_scv

VERILATOR_ROOT=$HOME/verilator
VERILATOR_VERSION=3.920
VERILATOR_URL=https://www.veripool.org/ftp
VERILATOR_TAR=verilator-$VERILATOR_VERSION.tgz

install_verilator

GTEST_ROOT=$HOME/gtest
GTEST_VERSION=master
GTEST_URL=https://github.com/google/googletest/archive
GTEST_TAR=$GTEST_VERSION.zip

install_gtest
