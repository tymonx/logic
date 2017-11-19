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

if (CMAKE_CXX_COMPILER_ID MATCHES Clang)
    set(CMAKE_CXX_FLAGS ${CMAKE_CXX_FLAGS}
        -Wno-global-constructors
        -Wno-zero-as-null-pointer-constant
        -Wno-over-aligned
    )
endif()

function(add_systemc_module)
    verilator_add_systemc_module(${ARGV})
endfunction()

file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/output)

add_rtl_sources(
    ${QUARTUS_MEGA_FUNCTIONS}
)

add_hdl_includes(
    ${SVUNIT_INCLUDE_DIRS}
)

add_hdl_sources(
    ${SVUNIT_HDL_SOURCES}
)

add_verilator_configurations(
    "lint_off -msg STMTDLY      -file \"${QUARTUS_MEGA_FUNCTIONS}\""
    "lint_off -msg PINMISSING   -file \"${QUARTUS_MEGA_FUNCTIONS}\""
)

if (VERILATOR_FOUND)
    file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/coverage)

    add_custom_target(coverage
        ${VERILATOR_COVERAGE_EXECUTABLE}
            --annotate ${CMAKE_BINARY_DIR}/coverage
            ${CMAKE_BINARY_DIR}/output/*.dat
    )
endif()

add_subdirectory(logic)

create_simulation()
