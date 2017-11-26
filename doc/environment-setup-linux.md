Environment Setup - Linux
=========================

CMake
-----

Minimum required version: 3.1

`CMake` is an open-source, cross-platform family of tools designed to build, test
and package software.

Install CMake using package manager.

Fedora:

    sudo dnf install cmake

Ubuntu:

    sudo apt-get install cmake

Intel FPGA Quartus
------------------

Minimum required version: 17.0 Lite, Standard or Pro

`Intel FPGA Quartus` enables analysis and synthesis of HDL designs, which
enables the developer to compile their designs, perform timing analysis,
examine RTL diagrams, simulate a design using `ModelSim Intel Edition`.

Download Intel Quartus Lite, Standard or Pro version from:

    https://www.altera.com/downloads/download-center.html

Add `Intel FPGA Quartus` to *PATH* environment variable. For Bash shells edit
`~/.bashrc` file and add:

    export QUARTUS_ROOTDIR=<path_to_quartus>

    if [[ ! $PATH =~ $QUARTUS_ROOTDIR ]]; then
        export PATH=$QUARTUS_ROOTDIR/bin:$PATH
    fi

Add `ModelSim Intel Eidtion` to *PATH* environment variable. For Bash shells
edit `~/.bashrc` file and add:

    export MODELSIM_ROOTDIR=<path_to_modelsim>

    if [[ ! $PATH =~ $MODELSIM_ROOTDIR ]]; then
        export PATH=$MODELSIM_ROOTDIR/bin:$PATH
    fi

SystemC
-------

Required version: 2.3.1a

Download SystemC library using wget command line tool:

    wget http://accellera.org/images/downloads/standards/systemc/systemc-2.3.1a.tar.gz

Unpack SystemC archive:

    tar xvf systemc-2.3.1a.tar.gz

Change current location to SystemC source directory:

    cd systemc-2.3.1a

Create build directory:

    mkdir build

Change current location to build directory:

    cd build

Create SystemC install destination directory:

    mkdir -p /usr/local/systemc/2.3.1/

Force GNU C compiler to use gnu11 standard for C sources:

    export CC='gcc -std=gnu11'

Force GNU C++ compiler to use gnu++11 standard for C++ sources:

    export CXX='g++ -std=gnu++11'

Create build scripts:

    ../configure --enable-pthreads --enable-shared --prefix=/usr/local/systemc/2.3.1/

Build SystemC:

    make -j`nproc`

Install SystemC to `/usr/local/systemc/2.3.1/`

    sudo make install

Create `SYSTEMC_HOME` environment variable that points to SystemC install
directory. For Bash shells edit `~/.bashrc` file and add:

    export SYSTEMC_HOME=/usr/local/systemc/2.3.1

UVM-SystemC
-----------

Required version: 1.0-alpha1

Download UVM-SystemC library using wget command line tool:

    wget http://www.eda.org/images/downloads/drafts-review/uvm-systemc-1.0-alpha1.tar.gz

Unpack UVM-SystemC archive:

    tar xvf uvm-systemc-1.0-alpha1.tar.gz

Change current location to UVM-SystemC source directory:

    cd uvm-systemc-1.0-alpha1

Create build directory:

    mkdir build

Change current location to build directory:

    cd build

Force GNU C compiler to use gnu11 standard for C sources:

    export CC='gcc -std=gnu11'

Force GNU C++ compiler to use gnu++11 standard for C++ sources:

    export CXX='g++ -std=gnu++11'

Create build scripts:

    ../configure --enable-shared --with-systemc=$SYSTEMC_HOME --prefix=$SYSTEMC_HOME

Build UVM-SystemC:

    make -j`nproc`

Install UVM-SystemC to `$SYSTEM_HOME`

    sudo make install

SystemC Verification (SCV)
--------------------------

Required version: 2.0a

Download SystemC Verification library using wget command line tool:

    wget http://www.eda.org/images/downloads/standards/systemc/scv-2.0.0a.zip

Unpack SystemC Verification archive:

    unzip scv-2.0.0a.zip

Change current location to SystemC Verification source directory:

    cd scv-2.0.0a-20161019

Create build directory:

    mkdir build

Change current location to build directory:

    cd build

Force GNU C compiler to use gnu11 standard for C sources:

    export CC='gcc -std=gnu11'

Force GNU C++ compiler to use gnu++11 standard for C++ sources:

    export CXX='g++ -std=gnu++11'

Create build scripts:

    ../configure --enable-shared --with-systemc=$SYSTEMC_HOME --prefix=$SYSTEMC_HOME

Build SystemC Verification:

    make -j`nproc`

Install SystemC Verification to `$SYSTEM_HOME`

    sudo make install

Verilator
---------

Minimum required version: 3.914

Install required packages for Verilator tool.

Fedora:

    sudo dnf install git make autoconf g++ bison bison-devel flex flex-devel

Ubuntu:

    sudo apt-get install git make autoconf g++ bison flex

Download Verilator source code from remote git repository:

    git clone http://git.veripool.org/git/verilator

Change current location to Verilator source code:

    cd verilator

Force GNU C compiler to use gnu11 standard for C sources:

    export CC='gcc -std=gnu11'

Force GNU C++ compiler to use gnu++11 standard for C++ sources:

    export CXX='g++ -std=gnu++11'

Set `SYSTEMC_INCLUDE` environment variable for Verilator:

    export SYSTEMC_INCLUDE=$SYSTEM_HOME/include

Set `SYSTEMC_LIBDIR` environment variable for Verilator:

    export SYSTEMC_LIBDIR=$SYSTEM_HOME/lib-linux64

Change the newest development version to stable version:

    git checkout verilator_3_914

Create configure script:

    autoconf

Create build scripts:

    ./configure

Build Verilator:

    make -j`nproc`

Install Verilator:

    sudo make install

Google Test
-----------

Download `Google Test` source code:

    git clone https://github.com/google/googletest.git

Change current location to Google Test source code:

    cd googletest

Create build directory:

    mkdir build

Change current location to build directory:

    cd build

Force GNU C compiler to use gnu11 standard for C sources:

    export CC='gcc -std=gnu11'

Force GNU C++ compiler to use gnu++11 standard for C++ sources:

    export CXX='g++ -std=gnu++11'

Create build scripts using CMake

    cmake -DBUILD_SHARED_LIBS=ON -DCMAKE_INSTALL_PREFIX=/usr/local/ ..

Build Google Test:

    make -j`nproc`

Install Google Test:

    sudo make install

SVUnit
------

Download `SVUnit` source code:

    git clone https://github.com/nosnhojn/svunit-code.git

Create `SVUNIT_INSTALL` environment variable that points to SVUnit directory.
For Bash shells edit `~/.bashrc` file and add:

    export SVUNIT_INSTALL=<path-to-svunit-code>

    if [[ ! $PATH =~ $SVUNIT_INSTALL/bin ]]; then
        export PATH=$SVUNIT_INSTALL/bin:$PATH
    fi

Natural Docs
------------

Minimum required version: 2.0.1

Install required packages for Natural Docs tool.

Fedora:

    sudo dnf install mono

Ubuntu:

    sudo apt-get install mono

Download `Natural Docs` for Linux platforms:

    wget http://www.naturaldocs.org/download/natural_docs/2.0.1/Natural_Docs_2.0.1.zip

Unpack `Natural Docs` archive:

    unzip Natural_Docs_2.0.1.zip

Change original unpacked directory name to more Unix friendly directory name:

    mv Natural\ Docs natural_docs

Create `NATURAL_DOCS_ROOTDIR` environment variable that points to `Natural
Docs` directory. For Bash shells edit `~/.bashrc` file and add:

    export NATURAL_DOCS_ROOTDIR=<path-to-natural-docs>

    if [[ ! $PATH =~ $NATURAL_DOCS_ROOTDIR ]]; then
        export PATH=$NATURAL_DOCS_ROOTDIR:$PATH
    fi

GTKWave
-------

A VCD waveform viewer based on the GTK library. This viewer support VCD and LXT
formats for signal dumps. It also supports ModelSim `*.wlf` files using
`wlf2vcd` command.

Fedora:

    sudo dnf install gtkwave

Ubuntu:

    sudo apt-get install gtkwave

WaveDrom
--------

Optionally.

`WaveDrom` draws your Timing Diagram or Waveform from simple textual
description.  It comes with description language, rendering engine and the
editor.

WaveDrom editor can be downloaded from here:

    https://github.com/wavedrom/wavedrom.github.io/releases
