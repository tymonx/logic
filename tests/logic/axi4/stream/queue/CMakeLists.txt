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

add_hdl_unit_test(logic_axi4_stream_queue_unit_test.sv
    NAME
        logic_axi4_stream_queue_generic_unit_test
    DEPENDS
        logic_pkg
        logic_axi4_stream_queue
    PARAMETERS
        TARGET=logic_pkg::TARGET_GENERIC
)

add_hdl_unit_test(logic_axi4_stream_queue_unit_test.sv
    NAME
        logic_axi4_stream_queue_intel_unit_test
    DEPENDS
        logic_pkg
        logic_axi4_stream_queue
    PARAMETERS
        TARGET=logic_pkg::TARGET_INTEL
    MODELSIM_SUPPRESS
        3009
        3017
        3722
)

# UVM-SystemC unit test

set(MODULE_DEFINITIONS
    LOGIC_AXI4_STREAM_TDATA_BYTES=4
    LOGIC_AXI4_STREAM_TID_WIDTH=1
    LOGIC_AXI4_STREAM_TDEST_WIDTH=1
    LOGIC_AXI4_STREAM_TUSER_WIDTH=1
)

add_hdl_systemc(logic_axi4_stream_queue_top
    DEFINES
        ${MODULE_DEFINITIONS}
    OUTPUT_INCLUDES
        module_includes
    OUTPUT_LIBRARIES
        module_libraries
    OUTPUT_WORKING_DIRECTORY
        module_working_directory
)

set_source_files_properties(main.cpp PROPERTIES
    COMPILE_DEFINITIONS "${MODULE_DEFINITIONS}"
)

add_executable(logic_axi4_stream_queue_test
    main.cpp
    long_test.cpp
    basic_test.cpp
)

target_include_directories(logic_axi4_stream_queue_test
    SYSTEM PRIVATE
        ${module_includes}
)

target_link_libraries(logic_axi4_stream_queue_test
    ${module_libraries}
    logic
)

set(TESTS
    basic_test
    long_test
)

foreach (test ${TESTS})
    set(module_test logic_axi4_stream_queue_${test})

    add_test(
        NAME
            ${module_test}
        COMMAND
            logic_axi4_stream_queue_test
            +UVM_TESTNAME=${test}
            +uvm_set_config_string=*,trace_filename,${module_test}
        WORKING_DIRECTORY
            "${module_working_directory}"
    )
endforeach()
