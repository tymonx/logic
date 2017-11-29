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

if (NOT VERILATOR_FOUND)
    message(WARNING "Tests enabled but cannot find Verilator")
    return()
endif()

if (NOT GTEST_FOUND)
    message(WARNING "Tests enabled but cannot find Google Test")
    return()
endif()

if (NOT SVUNIT_FOUND)
    message(WARNING "Tests enabled but cannot find SVUnit")
    return()
endif()

set(HDL_SYNTHESIZABLE FALSE)

if (CMAKE_CXX_COMPILER_ID MATCHES Clang)
    set(CMAKE_CXX_FLAGS ${CMAKE_CXX_FLAGS}
        -Wno-global-constructors
        -Wno-zero-as-null-pointer-constant
        -Wno-over-aligned
    )
endif()

if (SVUNIT_FOUND)
    add_hdl_source(${SVUNIT_HDL_PACKAGE}
        LIBRARY svunit
        INCLUDES ${SVUNIT_INCLUDE_DIR}
    )
endif()

if (QUARTUS_FOUND)
    add_hdl_source(${QUARTUS_MEGA_FUNCTIONS}
        LIBRARY intel-sim
        VERILATOR_CONFIGURATIONS
            "lint_off -file \"${QUARTUS_MEGA_FUNCTIONS}\""
            "lint_off -msg STMTDLY -file \"${QUARTUS_MEGA_FUNCTIONS}\""
    )

    set(HDL_DEPENDS ${HDL_DEPENDS} altera_mf)
endif()

add_subdirectory(logic)
