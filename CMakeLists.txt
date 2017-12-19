# Copyright 2017 Tymoteusz Blazejczyk
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

cmake_minimum_required(VERSION 3.1)
project(Logic CXX)

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH}
    ${CMAKE_CURRENT_LIST_DIR}/cmake
)

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)

if (NOT DEFINED LOGIC_TESTS)
    option(LOGIC_TESTS "Enable/disable tests" ON)
endif()

if (NOT DEFINED LOGIC_RTL)
    option(LOGIC_RTL "Enable/disable RTL build" ON)
endif()

if (NOT DEFINED LOGIC_EXAMPLES)
    option(LOGIC_EXAMPLES "Enable/disable examples" OFF)
endif()

if (NOT DEFINED LOGIC_WARNINGS_INTO_ERRORS)
    option(LOGIC_WARNINGS_INTO_ERRORS "Enable/disable warnings as errors" OFF)
endif()

if (NOT DEFINED LOGIC_QUARTUS)
    option(LOGIC_QUARTUS "Enable/disable Intel FPGA Quartus projects" ON)
endif()

if (NOT DEFINED LOGIC_VIVADO)
    option(LOGIC_VIVADO "Enable/disable Xilinx Vivado projects" ON)
endif()

include(AddLogic)

include_directories(include)
include_directories(SYSTEM ${SYSTEMC_INCLUDE_DIRS})

add_subdirectory(src)

if (LOGIC_RTL)
    add_subdirectory(rtl)

    if (LOGIC_VIVADO)
        add_subdirectory(vivado)
    endif()

    if (LOGIC_TESTS)
        include(CTest)
        add_subdirectory(tests)
    endif()
endif()
