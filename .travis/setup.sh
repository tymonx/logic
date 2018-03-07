#!/bin/env bash
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
    if [ ! -f "$SYSTEMC_ARCHIVE_DIR/$SYSTEMC_TAR" ]; then
        echo "Downloading $SYSTEMC_URL/$SYSTEMC_TAR..."
        mkdir -p $SYSTEMC_ARCHIVE_DIR
        wget $SYSTEMC_URL/$SYSTEMC_TAR -O $SYSTEMC_ARCHIVE_DIR/$SYSTEMC_TAR
    else
        echo "SystemC $SYSTEMC_URL/$SYSTEMC_TAR already downloaded"
    fi

    if [ ! -f "$INSTALL/systemc/$SYSTEMC_VERSION/include/systemc.h" ];then
        echo "Creating SystemC directories..."
        mkdir -p $INSTALL/systemc/$SYSTEMC_VERSION
        mkdir -p /tmp/src/systemc/$SYSTEMC_VERSION
        mkdir -p /tmp/src/systemc/$SYSTEMC_VERSION/build

        echo "Unpacking SystemC archive file..."
        tar -xf $SYSTEMC_ARCHIVE_DIR/$SYSTEMC_TAR \
            -C /tmp/src/systemc/$SYSTEMC_VERSION --strip-components 1

        echo "Patching SystemC sources..."
        cd /tmp/src/systemc/$SYSTEMC_VERSION
        sed -i 's/nb_put/this->nb_put/' \
            src/tlm_core/tlm_1/tlm_analysis/tlm_analysis_fifo.h

        echo "Configuring SystemC sources..."
        cd /tmp/src/systemc/$SYSTEMC_VERSION/build
        ../configure --enable-pthreads --enable-shared \
            --prefix=$INSTALL/systemc/$SYSTEMC_VERSION

        echo "Building SystemC library..."
        make -j`nproc`

        echo "Installing SystemC library..."
        make install
    else
        echo "SystemC library already installed"
    fi

    export SYSTEMC_INCLUDE=$INSTALL/systemc/$SYSTEMC_VERSION/include
    export SYSTEMC_LIBDIR=$INSTALL/systemc/$SYSTEMC_VERSION/lib-linux64
}

function install_uvm_systemc {
    if [ ! -f "$UVM_SYSTEMC_ARCHIVE_DIR/$UVM_SYSTEMC_TAR" ]; then
        mkdir -p $UVM_SYSTEMC_ARCHIVE_DIR
        echo "Downloading $UVM_SYSTEMC_URL/$UVM_SYSTEMC_TAR..."
        wget $UVM_SYSTEMC_URL/$UVM_SYSTEMC_TAR \
            -O $UVM_SYSTEMC_ARCHIVE_DIR/$UVM_SYSTEMC_TAR
    else
        echo "UVM-SystemC $UVM_SYSTEMC_URL/$UVM_SYSTEMC_TAR already downloaded"
    fi

    if [ ! -f "$INSTALL/systemc/$SYSTEMC_VERSION/include/uvm.h" ]; then
        echo "Creating UVM-SystemC directories..."
        mkdir -p /tmp/src/uvm-systemc/$UVM_SYSTEMC_VERSION
        mkdir -p /tmp/src/uvm-systemc/$UVM_SYSTEMC_VERSION/build

        echo "Unpacking UVM-SystemC archive file..."
        tar -xf $UVM_SYSTEMC_ARCHIVE_DIR/$UVM_SYSTEMC_TAR \
            -C /tmp/src/uvm-systemc/$UVM_SYSTEMC_VERSION --strip-components 1

        echo "Creating UVM-SystemC configure file..."
        cd /tmp/src/uvm-systemc/$UVM_SYSTEMC_VERSION
        ./config/bootstrap

        echo "Configuring UVM-SystemC sources..."
        cd /tmp/src/uvm-systemc/$UVM_SYSTEMC_VERSION/build
        ../configure --enable-shared \
            --with-systemc=$INSTALL/systemc/$SYSTEMC_VERSION \
            --prefix=$INSTALL/systemc/$SYSTEMC_VERSION

        echo "Building UVM-SystemC library..."
        make -j`nproc`

        echo "Installing UVM-SystemC library..."
        make install
    else
        echo "UVM-SystemC library already installed"
    fi
}

function install_scv {
    if [ ! -f "$SCV_ARCHIVE_DIR/$SCV_TAR" ]; then
        echo "Downloading $SCV_URL/$SCV_TAR..."
        mkdir -p $SCV_ARCHIVE_DIR
        wget $SCV_URL/$SCV_TAR -O $SCV_ARCHIVE_DIR/$SCV_TAR
    else
        echo "SCV $SCV_URL/$SCV_TAR already downloaded"
    fi

    if [ ! -f "$INSTALL/systemc/$SYSTEMC_VERSION/include/scv.h" ]; then
        echo "Creating SCV directories..."
        mkdir -p /tmp/src/scv/$SCV_VERSION
        mkdir -p /tmp/src/scv/$SCV_VERSION/build

        echo "Unpacking SCV archive file..."
        tar -xf $SCV_ARCHIVE_DIR/$SCV_TAR \
            -C /tmp/src/scv/$SCV_VERSION --strip-components 1

        echo "Configuring SCV sources..."
        cd /tmp/src/scv/$SCV_VERSION/build
        ../configure --enable-shared \
            --with-systemc=$INSTALL/systemc/$SYSTEMC_VERSION \
            --prefix=$INSTALL/systemc/$SYSTEMC_VERSION

        echo "Building SCV library..."
        make -j`nproc`

        echo "Installing SCV library..."
        make install
    else
        echo "SCV library already installed"
    fi
}

function install_verilator {
    if [ ! -f "$VERILATOR_ARCHIVE_DIR/$VERILATOR_TAR" ]; then
        echo "Downloading $VERILATOR_URL/$VERILATOR_TAR..."
        mkdir -p $VERILATOR_ARCHIVE_DIR
        wget $VERILATOR_URL/$VERILATOR_TAR \
            -O $VERILATOR_ARCHIVE_DIR/$VERILATOR_TAR
    else
        echo "Verilator $VERILATOR_URL/$VERILATOR_TAR already downloaded"
    fi

    if [ ! -x "$INSTALL/verilator/$VERILATOR_VERSION/bin/verilator" ]; then
        echo "Creating Verilator directories..."
        mkdir -p $INSTALL/verilator/$VERILATOR_VERSION
        mkdir -p /tmp/src/verilator/$VERILATOR_VERSION

        echo "Unpacking Verilator archive file..."
        tar -xzf $VERILATOR_ARCHIVE_DIR/$VERILATOR_TAR \
            -C /tmp/src/verilator/$VERILATOR_VERSION --strip-components 1

        echo "Configuring Verilator sources..."
        cd /tmp/src/verilator/$VERILATOR_VERSION
        ./configure --prefix=$INSTALL/verilator/$VERILATOR_VERSION

        echo "Building Verilator library..."
        make -j`nproc`

        echo "Installing Verilator library..."
        make install
    else
        echo "Verilator already installed"
    fi

    export PATH=$INSTALL/verilator/$VERILATOR_VERSION/bin:$PATH
}

function install_gtest {
    if [ ! -f "$INSTALL/gtest/$GTEST_VERSION/include/gtest/gtest.h" ]; then
        echo "Creating Google Test directories..."
        mkdir -p /tmp/src/gtest
        mkdir -p $INSTALL/gtest/$GTEST_VERSION

        echo "Downloading Google Test sources..."
        cd /tmp/src/gtest
        git clone https://github.com/google/googletest.git $GTEST_VERSION
        mkdir -p /tmp/src/gtest/$GTEST_VERSION/build

        echo "Checkout Google Test stable version..."
        cd /tmp/src/gtest/$GTEST_VERSION/build
        git checkout -b dev $GTEST_VERSION

        echo "Configuring Google Test sources..."
        cd /tmp/src/gtest/$GTEST_VERSION/build
        cmake -DBUILD_SHARED_LIBS=ON \
            -DCMAKE_INSTALL_PREFIX=$INSTALL/gtest/$GTEST_VERSION ..

        echo "Building Google Test library..."
        cmake --build . --target all -- -j`nproc`

        echo "Installing Google Test library..."
        cmake --build . --target install
    else
        echo "Google Test library already installed"
    fi

    export GTEST_ROOT=$INSTALL/gtest/$GTEST_VERSION
}

function install_std_ovl {
    if [ ! -f "$STD_OVL_ARCHIVE_DIR/$STD_OVL_TAR" ]; then
        echo "Downloading $STD_OVL_URL/$STD_OVL_TAR..."
        mkdir -p $STD_OVL_ARCHIVE_DIR
        wget $STD_OVL_URL/$STD_OVL_TAR -O $STD_OVL_ARCHIVE_DIR/$STD_OVL_TAR
    else
        echo "OVL $STD_OVL_URL/$STD_OVL_TAR already downloaded"
    fi

    echo "Creating OVL directories..."
    mkdir -p /tmp/src/std_ovl/$STD_OVL_VERSION

    echo "Unpacking OVL archive file..."
    tar -xzf $STD_OVL_ARCHIVE_DIR/$STD_OVL_TAR \
        -C /tmp/src/std_ovl/$STD_OVL_VERSION --strip-components 1

    export STD_OVL_DIR=/tmp/src/std_ovl/$STD_OVL_VERSION
}

function install_tools {
    echo "Preparing tools..."

    WORKDIR=$(pwd)
    INSTALL=$HOME/tools

    SYSTEMC_ARCHIVE_DIR=$HOME/archive/systemc
    SYSTEMC_VERSION=2.3.2
    SYSTEMC_URL=http://accellera.org/images/downloads/standards/systemc
    SYSTEMC_TAR=systemc-$SYSTEMC_VERSION.tar.gz

    install_systemc

    UVM_SYSTEMC_ARCHIVE_DIR=$HOME/archive/uvm-systemc
    UVM_SYSTEMC_VERSION=1.0-beta1
    UVM_SYSTEMC_URL=http://accellera.org/images/downloads/standards/systemc
    UVM_SYSTEMC_TAR=uvm-systemc-$UVM_SYSTEMC_VERSION.tar.gz

    install_uvm_systemc

    SCV_ARCHIVE_DIR=$HOME/archive/scv
    SCV_VERSION=2.0.1
    SCV_URL=http://accellera.org/images/downloads/standards/systemc
    SCV_TAR=scv-$SCV_VERSION.tar.gz

    install_scv

    VERILATOR_ARCHIVE_DIR=$HOME/archive/verilator
    VERILATOR_VERSION=3.920
    VERILATOR_URL=https://www.veripool.org/ftp
    VERILATOR_TAR=verilator-$VERILATOR_VERSION.tgz

    install_verilator

    GTEST_VERSION=703b4a8

    install_gtest

    STD_OVL_ARCHIVE_DIR=$HOME/archive/std_ovl
    STD_OVL_VERSION=v2p8.1_Apr2014
    STD_OVL_URL=http://accellera.org/images/downloads/standards/ovl
    STD_OVL_TAR=std_ovl_$STD_OVL_VERSION.tgz

    install_std_ovl

    cd $WORKDIR
}

install_tools

set +u
