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

add_hdl_sources(
    logic_reset_synchronizer_unit_test.sv
    logic_reset_synchronizer_testrunner.sv
)

add_hdl_test(logic_reset_synchronizer_testrunner)

# Create SystemC with GTest

set(MODULE_NAME logic_reset_synchronizer)
set(MODULE_TOP ${MODULE_NAME})

add_systemc_module(${MODULE_TOP}
    ${RTL_SOURCES}
    INCLUDE_DIRECTORIES ${RTL_INCLUDES}
)

get_target_property(MODULE_LIBRARIES ${MODULE_TOP} LIBRARIES)
get_target_property(MODULE_INCLUDE_DIRS ${MODULE_TOP} INCLUDE_DIRECTORIES)

include_directories(SYSTEM
    ${MODULE_INCLUDE_DIRS}
    ${GTEST_INCLUDE_DIRS}
)

set(TEST_MODULE_NAME ${MODULE_NAME}_test)

add_executable(${TEST_MODULE_NAME}
    main.cpp
    test.cpp
    dut.cpp
)

add_test(NAME ${TEST_MODULE_NAME}
    COMMAND ${TEST_MODULE_NAME}
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/output
)

target_link_libraries(${TEST_MODULE_NAME}
    logic
    ${GTEST_LIBRARIES}
    ${MODULE_LIBRARIES}
    logic-gtest-main
)
