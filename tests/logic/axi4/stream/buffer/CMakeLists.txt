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

set(MODULE_PARAMETERS
    TDATA_BYTES=4
    TUSER_WIDTH=1
    TDEST_WIDTH=1
    TID_WIDTH=1
)

add_hdl_systemc(logic_axi4_stream_buffer_top
    PARAMETERS
        ${MODULE_PARAMETERS}
    OUTPUT_INCLUDES
        module_includes
    OUTPUT_LIBRARIES
        module_libraries
    OUTPUT_WORKING_DIRECTORY
        module_working_directory
)

set_source_files_properties(main.cpp PROPERTIES
    COMPILE_DEFINITIONS "${MODULE_PARAMETERS}"
)

add_executable(logic_axi4_stream_buffer_test
    main.cpp
    long_test.cpp
    basic_test.cpp
)

target_include_directories(logic_axi4_stream_buffer_test
    SYSTEM PRIVATE
        ${module_includes}
)

target_link_libraries(logic_axi4_stream_buffer_test
    ${module_libraries}
    logic
)

set(TESTS
    basic_test
    long_test
)

foreach (test ${TESTS})
    set(module_test logic_axi4_stream_buffer_${test})

    add_test(
        NAME
            ${module_test}
        COMMAND
            logic_axi4_stream_buffer_test
            +UVM_TESTNAME=${test}
            +uvm_set_config_string=*,trace_filename,${module_test}
        WORKING_DIRECTORY
            "${module_working_directory}"
    )
endforeach()
