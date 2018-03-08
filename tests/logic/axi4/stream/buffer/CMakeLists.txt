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

# SVUnit unit test

add_hdl_unit_test(logic_axi4_stream_buffer_unit_test.sv
    DEPENDS
        logic_pkg
        logic_unit_test_pkg
        logic_axi4_stream_if
        logic_axi4_stream_buffer
)

# SVUnit unit test

set(PARAMETERS
    TDATA_BYTES=4
    TUSER_WIDTH=1
    TDEST_WIDTH=1
    TID_WIDTH=1
)

set(hdl_name logic_axi4_stream_buffer_top)

add_hdl_systemc(${hdl_name}
    PARAMETERS
        ${PARAMETERS}
)

set_source_files_properties(main.cpp PROPERTIES
    COMPILE_DEFINITIONS
        "${PARAMETERS}"
)

add_executable(${hdl_name}_test
    main.cpp
    long_test.cpp
    basic_test.cpp
)

set_target_properties(${hdl_name}_test PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY
        "${CMAKE_BINARY_DIR}/systemc/unit_tests/${hdl_name}"
)

logic_target_compile_options(${hdl_name}_test
    PRIVATE
        $<$<CXX_COMPILER_ID:Clang>:-Wno-unused-member-function>
)

logic_target_link_libraries(${hdl_name}_test
    logic
    systemc-module-${hdl_name}
)

set(TESTS
    basic_test
    long_test
)

foreach (test ${TESTS})
    add_test(
        NAME
            ${hdl_name}_${test}
        COMMAND
            ${hdl_name}_test
            +UVM_TESTNAME=${test}
            +uvm_set_config_string=*,trace_filename,${hdl_name}_${test}
        WORKING_DIRECTORY
            "${CMAKE_BINARY_DIR}/systemc/unit_tests/${hdl_name}"
    )
endforeach()
