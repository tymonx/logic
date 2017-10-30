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

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CMAKE_CURRENT_LIST_DIR}/cmake)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)

option(TESTS "Enable/disable tests" OFF)
option(EXAMPLES "Enable/disable examples" OFF)
option(WARNINGS_INTO_ERRORS "Enable/disable warnings as errors" OFF)

include(AddThreads)
include(AddGnuCompiler)
include(AddMsvcCompiler)
include(AddClangCompiler)

find_package(NaturalDocs)
find_package(SystemC REQUIRED COMPONENTS SCV UVM)
find_package(Verilator REQUIRED)

include_directories(include)
include_directories(SYSTEM ${SYSTEMC_INCLUDE_DIRS})

add_subdirectory(src)
