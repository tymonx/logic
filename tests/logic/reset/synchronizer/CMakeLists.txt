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

# Create SystemVerilog with SVUnit

add_hdl_unit_test(logic_reset_synchronizer_unit_test.sv
    DEPENDS
        logic_reset_synchronizer
)

# Create SystemC with GTest

set(hdl_name logic_reset_synchronizer)

add_hdl_systemc(${hdl_name})

add_executable(${hdl_name}_test
    logic_reset_synchronizer_test.cpp
)

set_target_properties(${hdl_name}_test PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY
        "${CMAKE_BINARY_DIR}/systemc/unit_tests/${hdl_name}"
)

logic_target_compile_options(${hdl_name}_test)

logic_target_link_libraries(${hdl_name}_test
    systemc-module-${hdl_name}
    logic-gtest-main
)

add_test(
    NAME
        ${hdl_name}_test
    COMMAND
        ${hdl_name}_test
    WORKING_DIRECTORY
        "${CMAKE_BINARY_DIR}/systemc/unit_tests/${hdl_name}"
)
