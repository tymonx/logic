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

add_subdirectory(axi4)
add_subdirectory(gtest)

if (VERILATOR_FOUND)
    include_directories(SYSTEM ${VERILATOR_INCLUDE_DIR})

    set(LOGIC_CORE_SOURCES ${LOGIC_CORE_SOURCES}
        trace_verilated.cpp
    )
endif()

if (CMAKE_CXX_COMPILER_ID MATCHES Clang)
    set_source_files_properties(command_line.cpp
        PROPERTIES COMPILE_FLAGS -Wno-global-constructors
    )
endif()

add_library(logic-core OBJECT
    ${LOGIC_CORE_SOURCES}
    range.cpp
    trace_base.cpp
    trace_systemc.cpp
    bitstream.cpp
    bitstream_iterator.cpp
    bitstream_const_iterator.cpp
    bitstream_reference.cpp
    bitstream_const_reference.cpp
    command_line.cpp
    command_line_argument.cpp
)

add_library(logic STATIC
    $<TARGET_OBJECTS:logic-core>
    $<TARGET_OBJECTS:logic-axi4-stream>
)

target_link_libraries(logic PRIVATE
    verilated scv uvm-systemc systemc)
