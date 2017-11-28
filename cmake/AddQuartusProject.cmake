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

find_package(Quartus)

if (NOT QUARTUS_FOUND)
    function(add_quartus_project)
    endfunction()
endif()

if (COMMAND add_quartus_project)
    return()
endif()

set(ADD_QUARTUS_PROJECT_CURRENT_DIR ${CMAKE_CURRENT_LIST_DIR}
    CACHE INTERNAL "Add Quartus project current directory" FORCE)

set(QUARTUS_VERSION 17.0
    CACHE STRING "Quartus version")

set(QUARTUS_PROJECT_REVISION logic
    CACHE STRING "Quartus project revision")

if (QUARTUS_EDITION MATCHES Pro)
    set(QUARTUS_FAMILY "Arria 10" CACHE STRING "Quartus family")
    set(QUARTUS_DEVICE 10AS057H3F34E2SG CACHE STRING "Quartus device")
    set(QUARTUS_ANALYSIS_AND_ELABORATION ${QUARTUS_SYN})
else()
    set(QUARTUS_FAMILY "Cyclone V" CACHE STRING "Quartus family")
    set(QUARTUS_DEVICE 5CGXFC7C7F23C8 CACHE STRING "Quartus device")
    set(QUARTUS_ANALYSIS_AND_ELABORATION ${QUARTUS_MAP})
endif()

if (NOT TARGET quartus-analysis-and-elaboration-all)
    add_custom_target(quartus-analysis-and-elaboration-all)
endif()

function(add_quartus_project target_name)
    set(state GET_SOURCES)
    set(quartus_sources "")
    set(quartus_depends "")
    set(quartus_defines "")
    set(quartus_includes "")
    set(quartus_top_level_entity ${target_name})
    set(quartus_project_directory ${CMAKE_BINARY_DIR}/quartus/${target_name})
    set(quartus_assignments "")

    if (QUARTUS_EDITION MATCHES Pro)
        list(APPEND quartus_defines LOGIC_MODPORT_DISABLED)
    endif()

    if (QUARTUS_INCLUDES)
        foreach (quartus_include ${QUARTUS_INCLUDES})
            get_filename_component(quartus_include ${quartus_include} REALPATH)
            list(APPEND quartus_includes ${quartus_include})
        endforeach()
    endif()

    if (QUARTUS_DEFINES)
        foreach (quartus_define ${QUARTUS_DEFINES})
            list(APPEND quartus_defines ${quartus_define})
        endforeach()
    endif()

    if (QUARTUS_ASSIGNMENTS)
        foreach (quartus_assignment ${QUARTUS_ASSIGNMENTS})
            list(APPEND quartus_assignments ${quartus_assignment})
        endforeach()
    endif()

    foreach (arg ${ARGN})
        # Handle argument
        if (arg MATCHES PROJECT_DIRECTORY)
            set(state GET_PROJECT_DIRECTORY)
        elseif (arg MATCHES DEFINES)
            set(state GET_DEFINES)
        elseif (arg MATCHES INCLUDES)
            set(state GET_INCLUDES)
        elseif (arg MATCHES DEPENDS)
            set(state GET_DEPENDS)
        elseif (arg MATCHES TOP_LEVEL_ENTITY)
            set(state GET_TOP_LEVEL_ENTITY)
        elseif (arg MATCHES ASSIGNMENTS)
            set(state GET_ASSIGNMENTS)
        # Handle state
        elseif (state MATCHES GET_SOURCES)
            get_filename_component(arg ${arg} REALPATH)
            list(APPEND quartus_sources ${arg})
        elseif (state MATCHES GET_DEFINES)
            list(APPEND quartus_defines ${arg})
        elseif (state MATCHES GET_DEPENDS)
            list(APPEND quartus_depends ${arg})
        elseif (state MATCHES GET_INCLUDES)
            list(APPEND quartus_includes ${arg})
        elseif (state MATCHES GET_PROJECT_DIRECTORY)
            set(quartus_project_directory ${arg})
            set(state UNKNOWN)
        elseif (state MATCHES GET_TOP_LEVEL_ENTITY)
            set(quartus_top_level_entity ${arg})
            set(state UNKNOWN)
        elseif (state MATCHES GET_ASSIGNMENTS)
            list(APPEND quartus_assignments ${arg})
        else()
            message(FATAL_ERROR "Unknown argument")
        endif()
    endforeach()

    file(MAKE_DIRECTORY ${quartus_project_directory})

    get_hdl_depends(${quartus_top_level_entity} hdl_depends)

    foreach (hdl_name ${hdl_depends} ${quartus_top_level_entity})
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
        list(APPEND quartus_assignments
            "set_global_assignment -name VERILOG_MACRO ${quartus_define}")
    endforeach()

    foreach (quartus_include ${quartus_includes})
        if (CYGWIN)
            execute_process(COMMAND cygpath -m ${quartus_include}
                OUTPUT_VARIABLE quartus_include
                OUTPUT_STRIP_TRAILING_WHITESPACE)
        endif()

        list(APPEND quartus_assignments
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

        if (CYGWIN)
            execute_process(COMMAND cygpath -m ${quartus_source}
                OUTPUT_VARIABLE quartus_source
                OUTPUT_STRIP_TRAILING_WHITESPACE)
        endif()

        list(APPEND quartus_assignments
            "set_global_assignment -name ${quartus_type_file} ${quartus_source}")
    endforeach()

    string(REGEX REPLACE ";" "\n" quartus_assignments "${quartus_assignments}")

    configure_file(${ADD_QUARTUS_PROJECT_CURRENT_DIR}/AddQuartusProject.qpf.cmake.in
        ${quartus_project_directory}/logic.qpf)

    configure_file(${ADD_QUARTUS_PROJECT_CURRENT_DIR}/AddQuartusProject.qsf.cmake.in
        ${quartus_project_directory}/logic.qsf)

    add_custom_target(quartus-analysis-and-elaboration-${target_name}
        COMMAND ${QUARTUS_ANALYSIS_AND_ELABORATION}
            --analysis_and_elaboration logic
        DEPENDS
            ${quartus_project_directory}/logic.qpf
            ${quartus_project_directory}/logic.qsf
        WORKING_DIRECTORY ${quartus_project_directory}
        COMMENT "Quartus analysis and elaboration: ${quartus_top_level_entity}"
    )

    add_dependencies(quartus-analysis-and-elaboration-all
        quartus-analysis-and-elaboration-${target_name})
endfunction()
