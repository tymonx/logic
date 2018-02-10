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

add_hdl_systemc(logic_reset_synchronizer
    OUTPUT_INCLUDES
        module_includes
    OUTPUT_LIBRARIES
        module_libraries
)

add_executable(logic_reset_synchronizer_test
    logic_reset_synchronizer_test.cpp
)

target_include_directories(logic_reset_synchronizer_test
    SYSTEM PRIVATE
        ${module_includes}
)

target_link_libraries(logic_reset_synchronizer_test
    ${module_libraries}
    logic-gtest-main
)

add_test(
    NAME
        logic_reset_synchronizer_test
    COMMAND
        logic_reset_synchronizer_test
    WORKING_DIRECTORY
        "${CMAKE_BINARY_DIR}/output"
)
