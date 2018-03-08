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
add_subdirectory(printer)

if (CMAKE_CXX_COMPILER_ID MATCHES Clang)
    set_source_files_properties(command_line.cpp
        PROPERTIES COMPILE_FLAGS -Wno-global-constructors
    )
endif()

add_library(logic-core OBJECT
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
    $<$<BOOL:VERILATOR_FOUND>:trace_verilated.cpp>
)

target_include_directories(logic-core PRIVATE
    ${LOGIC_INCLUDE_DIR}
)

target_include_directories(logic-core SYSTEM PRIVATE
    ${SYSTEMC_INCLUDE_DIRS}
    ${VERILATOR_INCLUDE_DIR}
)

logic_target_compile_options(logic-core)

if (WIN32)
    set(library_policy STATIC)
else()
    set(library_policy SHARED)
endif()

add_library(logic ${library_policy}
    $<TARGET_OBJECTS:logic-core>
    $<TARGET_OBJECTS:logic-core-printer>
    $<TARGET_OBJECTS:logic-axi4-stream>
)

set_target_properties(logic PROPERTIES
    ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib"
    LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib"
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib"
)

target_link_libraries(logic PUBLIC
    verilated scv uvm-systemc systemc)

target_include_directories(logic SYSTEM INTERFACE
    ${LOGIC_INCLUDE_DIR}
    ${SYSTEMC_INCLUDE_DIRS}
    ${VERILATOR_INCLUDE_DIR}
)

if (CMAKE_CXX_COMPILER_ID MATCHES Clang)
    set(compile_options "")

    if (NOT CMAKE_CXX_COMPILER_VERSION VERSION_LESS 3.9)
        list(APPEND compile_options
            -Wno-undefined-func-template
        )
    endif()

    target_compile_options(logic PUBLIC ${compile_options})
endif()
