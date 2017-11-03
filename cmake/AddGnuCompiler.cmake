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

if (NOT CMAKE_CXX_COMPILER_ID MATCHES GNU)
    return()
endif ()

if (CMAKE_SYSTEM_NAME MATCHES CYGWIN)
    set(CMAKE_CXX_FLAGS ${CMAKE_CXX_FLAGS} -std=gnu++11)
else()
    set(CMAKE_CXX_FLAGS ${CMAKE_CXX_FLAGS} -std=c++11)
endif()

set(CMAKE_CXX_FLAGS ${CMAKE_CXX_FLAGS} -fPIC)

if (LTO)
    set(CMAKE_CXX_FLAGS ${CMAKE_CXX_FLAGS} -flto)
endif()

if (WARNINGS_INTO_ERRORS)
    set(CMAKE_CXX_FLAGS ${CMAKE_CXX_FLAGS} -Werror)
endif()

if (CMAKE_BUILD_TYPE MATCHES "Release" OR NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE "Release")

    set(CMAKE_CXX_FLAGS_RELEASE
        -O2
        -s
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
        --coverage
    )

    set(CMAKE_EXE_LINKER_FLAGS_COVERAGE)

    string(REPLACE ";" " " CMAKE_CXX_FLAGS_COVERAGE
        "${CMAKE_CXX_FLAGS_COVERAGE}")

    string(REPLACE ";" " " CMAKE_EXE_LINKER_FLAGS_COVERAGE
        "${CMAKE_EXE_LINKER_FLAGS_COVERAGE}")
endif()

set(CMAKE_CXX_FLAGS ${CMAKE_CXX_FLAGS}
    -fstrict-aliasing
    -pedantic
    -Wall
    -Wcast-qual
    -Wcomments
    -Wconversion
    -Wctor-dtor-privacy
    -Wdisabled-optimization
    -Wendif-labels
    -Wenum-compare
    -Wfloat-equal
    -Wformat=2
    -Wformat-nonliteral
    -Winit-self
    -Winvalid-pch
    -Wlogical-op
    -Wmissing-declarations
    -Wmissing-include-dirs
    -Wno-long-long
    -Wnon-virtual-dtor
    -Wold-style-cast
    -Woverloaded-virtual
    -Wpacked
    -Wparentheses
    -Wpointer-arith
    -Wredundant-decls
    -Wshadow
    -Wsign-conversion
    -Wsign-promo
    -Wstack-protector
    -Wstrict-null-sentinel
    -Wstrict-overflow=2
    -Wsuggest-attribute=noreturn
    -Wswitch-default
    -Wswitch-enum
    -Wundef
    -Wuninitialized
    -Wunknown-pragmas
    -Wunused
    -Wunused-function
    -Wwrite-strings
)

if (NOT CMAKE_CXX_COMPILER_VERSION VERSION_LESS 6.0)
    set(CMAKE_CXX_FLAGS ${CMAKE_CXX_FLAGS}
        -Wduplicated-cond
        -Whsa
        -Wignored-attributes
        -Wmisleading-indentation
        -Wnull-dereference
        -Wplacement-new=2
        -Wshift-negative-value
        -Wshift-overflow=2
        -Wvirtual-inheritance
    )
endif()

if (NOT CMAKE_CXX_COMPILER_VERSION VERSION_LESS 5.0)
    set(CMAKE_CXX_FLAGS ${CMAKE_CXX_FLAGS}
        -Wdouble-promotion
        -Wsized-deallocation
        -Wsuggest-override
        -Wtrampolines
        -Wvector-operation-performance
        -Wzero-as-null-pointer-constant
    )
endif()

if (NOT CMAKE_CXX_COMPILER_VERSION VERSION_LESS 4.9)
    set(CMAKE_CXX_FLAGS ${CMAKE_CXX_FLAGS}
        -Wconditionally-supported
        -Wdate-time
        -Weffc++
        -Wextra
        -Winline
        -Wopenmp-simd
    )
endif()

if (NOT CMAKE_CXX_COMPILER_VERSION VERSION_LESS 4.8)
    set(CMAKE_CXX_FLAGS ${CMAKE_CXX_FLAGS}
        -Wpedantic
        -Wsuggest-attribute=format
    )
endif()

if (NOT CMAKE_CXX_COMPILER_VERSION VERSION_LESS 4.6)
    set(CMAKE_CXX_FLAGS ${CMAKE_CXX_FLAGS}
        -Wnoexcept
    )
endif()

string(REPLACE ";" " " CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")
string(REPLACE ";" " " CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS}")
