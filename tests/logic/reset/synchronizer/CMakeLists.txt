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

add_hdl_source(logic_reset_synchronizer_unit_test.sv
    DEPENDS
        svunit_pkg
        logic_reset_synchronizer
    LIBRARY unit_test
    INCLUDES ${SVUNIT_INCLUDE_DIRS}
)

add_hdl_source(logic_reset_synchronizer_testrunner.sv
    DEPENDS
        svunit_pkg
        logic_reset_synchronizer_unit_test
    LIBRARY unit_test
    INCLUDES ${SVUNIT_INCLUDE_DIRS}
)

add_hdl_test(logic_reset_synchronizer_testrunner)

# Create SystemC with GTest

set(MODULE_NAME logic_reset_synchronizer)

add_hdl_systemc(${MODULE_NAME})

get_target_property(MODULE_LIBRARIES ${MODULE_NAME} LIBRARIES)
get_target_property(MODULE_INCLUDE_DIRS ${MODULE_NAME} INCLUDE_DIRECTORIES)

include_directories(SYSTEM
    ${MODULE_INCLUDE_DIRS}
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
    ${MODULE_LIBRARIES}
    logic-gtest-main
    ${GTEST_LIBRARIES}
)

add_test(NAME ${MODULE_NAME_TEST}
    COMMAND ${MODULE_NAME_TEST}
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/output
)
