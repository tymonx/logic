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

if (NOT CMAKE_CXX_COMPILER_ID MATCHES Clang)
    return()
endif ()

set(CMAKE_CXX_FLAGS ${CMAKE_CXX_FLAGS} -std=c++11 -fPIC)

if (LTO)
    set(CMAKE_CXX_FLAGS ${CMAKE_CXX_FLAGS} -flto)
endif()

set(CMAKE_CXX_FLAGS ${CMAKE_CXX_FLAGS}
    -pedantic
    -fstrict-aliasing
    -Weverything
    -Wno-padded
    -Wno-covered-switch-default
    -Wno-c++98-compat
    -Wno-c++98-compat-pedantic
)

if (WARNINGS_INTO_ERRORS)
    set(CMAKE_CXX_FLAGS ${CMAKE_CXX_FLAGS} -Werror)
endif()

if (CMAKE_BUILD_TYPE MATCHES "Release" OR NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE "Release")

    set(CMAKE_CXX_FLAGS_RELEASE
        -O2
        -DNDEBUG
        -fdata-sections
        -ffunction-sections
    )

    set(CMAKE_EXE_LINKER_FLAGS_RELEASE
        -Wl,--gc-sections
        -Wl,--strip-all
    )

    string(REPLACE ";" " " CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE}")
    string(REPLACE ";" " " CMAKE_EXE_LINKER_FLAGS_RELEASE
        "${CMAKE_EXE_LINKER_FLAGS_RELEASE}")
elseif (CMAKE_BUILD_TYPE MATCHES "MinSizeRel")
    set(CMAKE_CXX_FLAGS_MINSIZEREL
        -Os
        -DNDEBUG
        -fdata-sections
        -ffunction-sections
    )

    set(CMAKE_EXE_LINKER_FLAGS_MINSIZEREL
        -Wl,--gc-sections
    )

    string(REPLACE ";" " " CMAKE_CXX_FLAGS_MINSIZEREL
        "${CMAKE_CXX_FLAGS_MINSIZEREL}")

    string(REPLACE ";" " " CMAKE_EXE_LINKER_FLAGS_MINSIZEREL
        "${CMAKE_EXE_LINKER_FLAGS_MINSIZEREL}")
elseif (CMAKE_BUILD_TYPE MATCHES "Debug")
    set(CMAKE_CXX_FLAGS_DEBUG
        -O0
        -g3
        -ggdb
    )

    set(CMAKE_EXE_LINKER_FLAGS_DEBUG)

    string(REPLACE ";" " " CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG}")
    string(REPLACE ";" " " CMAKE_EXE_LINKER_FLAGS_DEBUG
        "${CMAKE_EXE_LINKER_FLAGS_DEBUG}")
elseif (CMAKE_BUILD_TYPE MATCHES "Coverage")
    set(CMAKE_CXX_FLAGS_COVERAGE
        -O0
        -g
        -fprofile-arcs
        -ftest-coverage
    )

    set(CMAKE_EXE_LINKER_FLAGS_COVERAGE
        --coverage
    )

    string(REPLACE ";" " " CMAKE_CXX_FLAGS_COVERAGE
        "${CMAKE_CXX_FLAGS_COVERAGE}")

    string(REPLACE ";" " " CMAKE_EXE_LINKER_FLAGS_COVERAGE
        "${CMAKE_EXE_LINKER_FLAGS_COVERAGE}")
endif()

string(REPLACE ";" " " CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")
string(REPLACE ";" " " CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS}")
