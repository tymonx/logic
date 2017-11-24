Logic
=====

Modern C++11 framework for testing RTL modules using SystemC and UVM.

Requirements
------------

These 3rd party tools and libraries must be installed to build and run tests:

  * [CMake](https://cmake.org/) - build, test and package project
  * [IntelFPGA Quartus](https://www.altera.com/downloads/download-center.html) - synthesis tool for Intel FPGAs
  * [Verilator](https://www.veripool.org/wiki/verilator/) - simulator, lint and coverage tool
  * [SystemC 2.3.1](http://accellera.org/downloads/standards/systemc) - SystemC C++ library
  * [SystemC Verification 2.0](http://accellera.org/downloads/standards/systemc) - SystemC data randomization
  * [UVM-SystemC 1.0](http://www.eda.org/activities/working-groups/systemc-verification) - UVM for SystemC
  * [Natural Docs](http://www.naturaldocs.org/) - code documentation generator
  * [GoogleTest](ihttps://github.com/google/googletest) - C++ unit test framework
  * [SVUnit](http://agilesoc.com/open-source-projects/svunit/) - SystemVerilog unit test framework
  * [GTKWave](http://gtkwave.sourceforge.net/) - waveform viewer
  * [WaveDrom](ihttp://wavedrom.com/) - digital timing diagram

Workspace
---------

  * README.md       - this read me file in MarkDown format
  * LICENSE         - license file
  * CMakeLists.txt  - CMake root script for building and testing project
  * doc             - configuration files for code documentation generator
  * rtl             - RTL source files
  * src             - C++ source files
  * include         - C++ include headers
  * tests           - unit tests and verification tests in SystemC using
                      Google Test or UVM and SystemVerilog using SVUnit
  * cmake           - additional CMake scripts for building project
  * scripts         - additional scripts in TCL or Python for building project

Build
-----

After cloning this repository, change current location to repository directory:

    cd logic

Create build directory:

    mkdir build

Change current location to build directory:

    cd build

Create build scripts using CMake:

    cmake ..

Build project using CMake:

    cmake --build . --target all

Or build project using make:

    make -j`nproc`

To build documentation:

    cmake --build . target doc

Built HTML documentation can be found in:

    doc/html

To view HTML documentation, open it using web browser:

    <WEB_BROWSER> doc/html/index.html

Tests
-----

Run all unit tests:

    ctest

Run only unit tests for AXI4-Stream:

    ctest -R axi4_stream

All waveforms generated from unit tests are located in:

    build/output

All unit tests logs are stored in:

    build/Testing/Temporary/LastTest.log

Verilator Coverage
------------------

Run Verilator coverage after running all tests:

    cmake --build . --target verilator-coverage
