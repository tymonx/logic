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

if (COMMAND add_hdl_unit_test)
    return()
endif()

if (NOT DEFINED _HDL_CMAKE_ROOT_DIR)
    set(_HDL_CMAKE_ROOT_DIR "${CMAKE_CURRENT_LIST_DIR}" CACHE INTERNAL
        "HDL CMake root directory" FORCE)
endif()

find_package(SVUnit)

include(CMakeParseArguments)
include(AddHDLUnitTestModelSim)

file(MAKE_DIRECTORY "${CMAKE_BINARY_DIR}/modelsim/unit_tests")

function(add_hdl_unit_test hdl_file)
    if (NOT SVUNIT_FOUND)
        return()
    endif()

    if (NOT hdl_file)
        message(FATAL_ERROR "HDL file not provided as first argument")
    endif()

    get_filename_component(hdl_file "${hdl_file}" REALPATH)

    if (NOT EXISTS "${hdl_file}")
        message(FATAL_ERROR "HDL file doesn't exist: ${hdl_file}")
    endif()

    get_filename_component(hdl_name "${hdl_file}" NAME_WE)

    set(one_value_arguments
        NAME
        SOURCE
        UNIT_TEST_NAME
    )

    set(multi_value_arguments
        SOURCES
        DEPENDS
        DEFINES
        INCLUDES
        PARAMETERS
        INPUT_FILES
        MODELSIM_FLAGS
        MODELSIM_DEPENDS
        MODELSIM_SUPPRESS
        MODELSIM_WARNING_AS_ERROR
    )

    cmake_parse_arguments(ARG "" "${one_value_arguments}"
        "${multi_value_arguments}" ${ARGN})

    macro(set_default_value name value)
        if (NOT DEFINED ARG_${name})
            set(ARG_${name} ${value})
        endif()
    endmacro()

    set_default_value(NAME ${hdl_name})
    set_default_value(UNIT_TEST_NAME ${hdl_name})
    set_default_value(SOURCE "${hdl_file}")
    set_default_value(MODELSIM_WARNING_AS_ERROR TRUE)

    set(test_runner_name "${ARG_NAME}_runner")
    set(test_runner_source "${CMAKE_CURRENT_BINARY_DIR}/${test_runner_name}.sv")

    configure_file("${_HDL_CMAKE_ROOT_DIR}/SVUnitTestRunner.sv.in"
        "${test_runner_source}")

    add_hdl_source("${ARG_SOURCE}"
        SYNTHESIZABLE
            FALSE
        SOURCES
            ${ARG_SOURCES}
        NAME
            ${ARG_NAME}
        DEPENDS
            svunit_pkg
            ${ARG_DEPENDS}
        DEFINES
            ${ARG_DEFINES}
        INCLUDES
            ${SVUNIT_INCLUDE_DIR}
            ${ARG_INCLUDES}
        INPUT_FILES
            ${ARG_INPUT_FILES}
    )

    add_hdl_source("${test_runner_source}"
        SYNTHESIZABLE
            FALSE
        DEPENDS
            svunit_pkg
            ${ARG_NAME}
        MODELSIM_DEPENDS
            ${ARG_MODELSIM_DEPENDS}
    )

    add_hdl_unit_test_modelsim()
endfunction()
