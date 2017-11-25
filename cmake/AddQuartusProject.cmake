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

set(ADD_QUARTUS_PROJECT_CURRENT_DIR ${CMAKE_CURRENT_LIST_DIR}
    CACHE INTERNAL "Add Quartus project current directory" FORCE)

set(QUARTUS_VERSION 17.0
    CACHE STRING "Quartus version")

set(QUARTUS_PROJECT_REVISION logic
    CACHE STRING "Quartus project revision")

set(QUARTUS_FAMILY "Cyclone V"
    CACHE STRING "Quartus family")

set(QUARTUS_DEVICE 5CGXFC7C7F23C8
    CACHE STRING "Quartus device")

set(QUARTUS_TOP_LEVEL_ENTITY logic_axi4_stream_queue_top
    CACHE STRING "Quartus top level entity")

set(QUARTUS_PROJECT_DIRECTORY
    ${CMAKE_BINARY_DIR}/quartus/${QUARTUS_TOP_LEVEL_ENTITY}
    CACHE STRING "Quartus project directory")

function(add_quartus_project)
    set(QUARTUS_ASSIGNMENTS "")

    file(MAKE_DIRECTORY ${QUARTUS_PROJECT_DIRECTORY})

    get_hdl_depends(${QUARTUS_TOP_LEVEL_ENTITY} hdl_depends)

    set(quartus_sources "")
    set(quartus_defines "")
    set(quartus_includes "")

    list(APPEND quartus_defines "LOGIC_CONFIG_TARGET=logic_pkg::TARGET_INTEL")

    foreach (hdl_name ${hdl_depends} ${QUARTUS_TOP_LEVEL_ENTITY})
        get_hdl_properties(${hdl_name}
            SOURCE hdl_source
            DEFINES hdl_defines
            INCLUDES hdl_includes
            SYNTHESIZABLE hdl_synthesizable
        )

        if (hdl_synthesizable)
            list(APPEND quartus_sources ${hdl_source})
            list(APPEND quartus_defines ${hdl_defines})
            list(APPEND quartus_includes ${hdl_includes})
        endif()
    endforeach()

    list(REMOVE_DUPLICATES quartus_defines)
    list(REMOVE_DUPLICATES quartus_includes)

    foreach (quartus_define ${quartus_defines})
        list(APPEND QUARTUS_ASSIGNMENTS
            "set_global_assignment -name VERILOG_MACRO ${quartus_define}")
    endforeach()

    foreach (quartus_include ${quartus_includes})
        list(APPEND QUARTUS_ASSIGNMENTS
            "set_global_assignment -name SEARCH_PATH ${quartus_include}")
    endforeach()

    foreach (quartus_source ${quartus_sources})
        if (quartus_source MATCHES .sv)
            set(quartus_type_file SYSTEMVERILOG_FILE)
        elseif (quartus_source MATCHES .vhd)
            set(quartus_type_file VHDL_FILE)
        elseif (quartus_source MATCHES .v)
            set(quartus_type_file VERILOG_FILE)
        endif()

        list(APPEND QUARTUS_ASSIGNMENTS
            "set_global_assignment -name ${quartus_type_file} ${quartus_source}")
    endforeach()

    string(REGEX REPLACE ";" "\n" QUARTUS_ASSIGNMENTS "${QUARTUS_ASSIGNMENTS}")

    configure_file(${ADD_QUARTUS_PROJECT_CURRENT_DIR}/AddQuartusProject.qpf.cmake.in
        ${QUARTUS_PROJECT_DIRECTORY}/logic.qpf)

    configure_file(${ADD_QUARTUS_PROJECT_CURRENT_DIR}/AddQuartusProject.qsf.cmake.in
        ${QUARTUS_PROJECT_DIRECTORY}/logic.qsf)
endfunction()
