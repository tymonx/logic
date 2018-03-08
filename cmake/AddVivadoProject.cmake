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

if (COMMAND add_vivado_project)
    return()
endif()

find_package(Vivado)

if (VIVADO_FOUND)
    set(ADD_VIVADO_PROJECT_CURRENT_DIR "${CMAKE_CURRENT_LIST_DIR}"
        CACHE INTERNAL "Add Vivado project current directory" FORCE)

    if (NOT TARGET vivado-analysis-all)
        add_custom_target(vivado-analysis-all)
    endif()
endif()

function(add_vivado_project target_name)
    if (NOT VIVADO_FOUND)
        return()
    endif()

    set(options)

    set(one_value_arguments
        FAMILY
        DEVICE
        REVISION
        TOP_LEVEL_ENTITY
        PROJECT_DIRECTORY
    )

    set(multi_value_arguments
        DEPENDS
        SOURCES
        DEFINES
        INCLUDES
        ASSIGNMENTS
        NUM_PARALLEL_PROCESSORS
    )

    cmake_parse_arguments(ARG "${options}" "${one_value_arguments}"
        "${multi_value_arguments}" ${ARGN})

    set(ARG_INCLUDES ${VIVADO_INCLUDES} ${ARG_INCLUDES})
    set(ARG_DEFINES ${VIVADO_DEFINES} ${ARG_DEFINES})
    set(ARG_ASSIGNMENTS ${VIVADO_ASSIGNMENTS} ${ARG_ASSIGNMENTS})

    if (NOT DEFINED ARG_PROJECT_DIRECTORY)
        set(ARG_PROJECT_DIRECTORY
            "${CMAKE_BINARY_DIR}/vivado/${target_name}")
    endif()

    if (NOT DEFINED ARG_TOP_LEVEL_ENTITY)
        set(ARG_TOP_LEVEL_ENTITY ${target_name})
    endif()

    file(MAKE_DIRECTORY "${ARG_PROJECT_DIRECTORY}")

    get_hdl_depends(${ARG_TOP_LEVEL_ENTITY} hdl_depends)

    foreach (hdl_name ${hdl_depends} ${ARG_TOP_LEVEL_ENTITY})
        get_target_property(hdl_synthesizable ${hdl_name} HDL_SYNTHESIZABLE)

        if (hdl_synthesizable)
            get_target_property(hdl_sources ${hdl_name} HDL_SOURCES)
            list(APPEND ARG_SOURCES "${hdl_sources}")

            get_target_property(hdl_source ${hdl_name} HDL_SOURCE)
            list(APPEND ARG_SOURCES "${hdl_source}")

            get_target_property(hdl_defines ${hdl_name} HDL_DEFINES)
            list(APPEND ARG_DEFINES "${hdl_defines}")

            get_target_property(hdl_includes ${hdl_name} HDL_INCLUDES)
            list(APPEND ARG_INCLUDES "${hdl_includes}")
        endif()
    endforeach()

    if (ARG_DEFINES)
        list(REMOVE_DUPLICATES ARG_DEFINES)
    endif()

    if (ARG_INCLUDES)
        list(REMOVE_DUPLICATES ARG_INCLUDES)
    endif()

    set(vivado_defines_list "")

    foreach (vivado_define ${ARG_DEFINES})
        list(APPEND vivado_defines_list "lappend defines ${vivado_define}")
    endforeach()

    set(vivado_includes_list "")

    foreach (vivado_include ${ARG_INCLUDES})
        get_filename_component(vivado_include "${vivado_include}" REALPATH)
        list(APPEND vivado_includes_list "lappend includes ${vivado_include}")
    endforeach()

    set(vivado_sources_list "")

    foreach (vivado_source ${ARG_SOURCES})
        if (vivado_source MATCHES "\.sv$")
            set(vivado_type_file SYSTEMVERILOG_FILE)
        elseif (vivado_source MATCHES "\.vhd$")
            set(vivado_type_file VHDL_FILE)
        elseif (vivado_source MATCHES "\.v$")
            set(vivado_type_file VERILOG_FILE)
        endif()

        list(APPEND vivado_sources_list "lappend sources ${vivado_source}")
    endforeach()

    string(REGEX REPLACE ";" "\n" vivado_includes_list
        "${vivado_includes_list}")

    string(REGEX REPLACE ";" "\n" vivado_defines_list "${vivado_defines_list}")

    string(REGEX REPLACE ";" "\n" vivado_sources_list "${vivado_sources_list}")

    configure_file(${ADD_VIVADO_PROJECT_CURRENT_DIR}/AddVivadoProject.tcl.cmake.in
        ${ARG_PROJECT_DIRECTORY}/${target_name}.tcl)

    add_custom_command(
        OUTPUT
            "${ARG_PROJECT_DIRECTORY}/vivado.jou"
        COMMAND
            ${VIVADO_EXECUTABLE} -notrace -mode batch -source ${target_name}.tcl
        DEPENDS
            "${ARG_PROJECT_DIRECTORY}/${target_name}.tcl"
            ${ARG_INCLUDES}
            ${ARG_SOURCES}
        WORKING_DIRECTORY
            "${ARG_PROJECT_DIRECTORY}"
        COMMENT
            "Vivado compiling ${ARG_PROJECT_DIRECTORY}"
    )

    add_custom_target(vivado-analysis-${target_name}
        DEPENDS ${ARG_PROJECT_DIRECTORY}/vivado.jou
    )

    add_dependencies(vivado-analysis-all vivado-analysis-${target_name})
endfunction()
