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

if (NOT CMAKE_CXX_COMPILER_ID MATCHES Clang)
    return()
endif()

function(logic_target_compile_options target)
    set(options "")

    if (CMAKE_SYSTEM_NAME MATCHES CYGWIN)
        list(APPEND options -std=gnu++11)
    else()
        list(APPEND options -std=c++11)
    endif()

    if (NOT CMAKE_SYSTEM_NAME MATCHES CYGWIN)
        list(APPEND options -fPIC)
    endif()

    if (LTO)
        list(APPEND options -flto)
    endif()

    if (LOGIC_WARNINGS_INTO_ERRORS)
        list(APPEND options -Werror)
    endif()

    list(APPEND options
        -pedantic
        -fstrict-aliasing
        -Weverything
        -Wno-padded
        -Wno-covered-switch-default
        -Wno-c++98-compat
        -Wno-c++98-compat-pedantic
    )

    if (CMAKE_BUILD_TYPE MATCHES "Release" OR NOT CMAKE_BUILD_TYPE)
        list(APPEND options
            -O2
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
    elseif (CMAKE_BUILD_TYPE MATCHES "Debug")
        list(APPEND options
            -O0
            -g3
            -ggdb
        )
    elseif (CMAKE_BUILD_TYPE MATCHES "Coverage")
        list(APPEND options
            -O0
            -g
            -fprofile-arcs
            -ftest-coverage
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
