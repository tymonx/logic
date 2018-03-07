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

if (COMMAND logic_target_compile_options)
    return()
endif()

if (NOT CMAKE_CXX_COMPILER_ID MATCHES GNU)
    return()
endif()

function(logic_target_compile_options target)
    set(options "")

    if (CMAKE_SYSTEM_NAME MATCHES CYGWIN)
        list(APPEND options -std=gnu++11)
    else()
        list(APPEND options -std=c++11)
    endif()

    list(APPEND options -fPIC)

    if (LTO)
        list(APPEND options -flto)
    endif()

    if (LOGIC_WARNINGS_INTO_ERRORS)
        list(APPEND options -Werror)
    endif()

    if (CMAKE_BUILD_TYPE MATCHES "Release" OR NOT CMAKE_BUILD_TYPE)
        list(APPEND options
            -O2
            -s
            -DNDEBUG
            -fdata-sections
            -ffunction-sections
        )
    elseif (CMAKE_BUILD_TYPE MATCHES "MinSizeRel")
        list(APPEND options
            -Os
            -DNDEBUG
            -fdata-sections
            -ffunction-sections
        )
    elseif (CMAKE_BUILD_TYPE MATCHES "Coverage")
        list(APPEND options
            -O0
            -g
            --coverage
        )
    endif()

    list(APPEND options
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
        list(APPEND options
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
        list(APPEND options
            -Wdouble-promotion
            -Wsized-deallocation
            -Wsuggest-override
            -Wtrampolines
            -Wvector-operation-performance
            -Wzero-as-null-pointer-constant
        )
    endif()

    if (NOT CMAKE_CXX_COMPILER_VERSION VERSION_LESS 4.9)
        list(APPEND options
            -Wconditionally-supported
            -Wdate-time
            -Weffc++
            -Wextra
            -Winline
            -Wopenmp-simd
        )
    endif()

    if (NOT CMAKE_CXX_COMPILER_VERSION VERSION_LESS 4.8)
        list(APPEND options
            -Wpedantic
            -Wsuggest-attribute=format
        )
    endif()

    if (NOT CMAKE_CXX_COMPILER_VERSION VERSION_LESS 4.6)
        list(APPEND options
            -Wnoexcept
        )
    endif()

    target_compile_options(${target} PRIVATE ${options} ${ARGN})
endfunction()

function(logic_target_link_libraries target)
    set(options "")

    if (CMAKE_BUILD_TYPE MATCHES "Release" OR NOT CMAKE_BUILD_TYPE)
        list(APPEND options
            -Wl,--gc-sections
            -Wl,--strip-all
        )
    elseif (CMAKE_BUILD_TYPE MATCHES "MinSizeRel")
        list(APPEND options
            -Wl,--gc-sections
        )
    elseif (CMAKE_BUILD_TYPE MATCHES "Coverage")
        list(APPEND options
            --coverage
        )
    endif()

    target_link_libraries(${target} PRIVATE ${options} ${ARGN})
endfunction()
