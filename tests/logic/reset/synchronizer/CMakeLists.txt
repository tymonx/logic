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

# Create SystemVerilog with SVUnit

add_hdl_unit_test(logic_reset_synchronizer_unit_test.sv
    DEPENDS
        logic_reset_synchronizer
)

# Create SystemC with GTest

set(MODULE_NAME logic_reset_synchronizer)

add_hdl_systemc(${MODULE_NAME}
    OUTPUT_INCLUDES module_includes
    OUTPUT_LIBRARIES module_libraries
)

include_directories(SYSTEM
    ${module_includes}
    ${GTEST_INCLUDE_DIRS}
)

set(MODULE_NAME_TEST ${MODULE_NAME}_test)

add_executable(${MODULE_NAME_TEST}
    main.cpp
    test.cpp
    dut.cpp
)

target_link_libraries(${MODULE_NAME_TEST}
    logic
    ${module_libraries}
    logic-gtest-main
    ${GTEST_LIBRARIES}
)

add_test(NAME ${MODULE_NAME_TEST}
    COMMAND ${MODULE_NAME_TEST}
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/output
)
