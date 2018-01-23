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
        logic_axi4_stream_buffer
)

# SVUnit unit test

set(MODULE_NAME logic_axi4_stream_buffer)
set(MODULE_TOP ${MODULE_NAME}_top)

set(MODULE_DEFINITIONS
    LOGIC_AXI4_STREAM_TDATA_BYTES=4
    LOGIC_AXI4_STREAM_TID_WIDTH=1
    LOGIC_AXI4_STREAM_TDEST_WIDTH=1
    LOGIC_AXI4_STREAM_TUSER_WIDTH=1
)

add_hdl_systemc(${MODULE_TOP}
    DEFINES ${MODULE_DEFINITIONS}
    OUTPUT_INCLUDES module_includes
    OUTPUT_LIBRARIES module_libraries
)

include_directories(SYSTEM
    ${module_includes}
)

set_source_files_properties(main.cpp PROPERTIES
    COMPILE_DEFINITIONS "${MODULE_DEFINITIONS}"
)

set(MODULE_NAME_TEST ${MODULE_NAME}_test)

add_executable(${MODULE_NAME_TEST}
    main.cpp
    long_test.cpp
    basic_test.cpp
)

target_link_libraries(${MODULE_NAME_TEST}
    logic
    ${module_libraries}
)

set(TESTS
    basic_test
    long_test
)

foreach (test ${TESTS})
    add_test(NAME ${MODULE_NAME}_${test}
        COMMAND ${MODULE_NAME_TEST} +UVM_TESTNAME=${test}
            +uvm_set_config_string=*,trace_filename,${MODULE_NAME}_${test}
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/output
    )
endforeach()
