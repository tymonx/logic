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

find_package(Vivado)

if (NOT VIVADO_FOUND)
    function(add_vivado_project)
    endfunction()
endif()

if (COMMAND add_vivado_project)
    return()
endif()

set(ADD_VIVADO_PROJECT_CURRENT_DIR ${CMAKE_CURRENT_LIST_DIR}
    CACHE INTERNAL "Add Vivado project current directory" FORCE)

if (NOT TARGET vivado-compile-all)
    add_custom_target(vivado-compile-all)
endif()

function(add_vivado_project target_name)
    set(state GET_SOURCES)
    set(vivado_sources "")
    set(vivado_depends "")
    set(vivado_defines "")
    set(vivado_includes "")
    set(vivado_top_level_entity ${target_name})
    set(vivado_project_directory ${CMAKE_BINARY_DIR}/vivado/${target_name})
    set(vivado_assignments "")

    if (VIVADO_INCLUDES)
        foreach (vivado_include ${VIVADO_INCLUDES})
            get_filename_component(vivado_include ${vivado_include} REALPATH)
            list(APPEND vivado_includes ${vivado_include})
        endforeach()
    endif()

    if (VIVADO_DEFINES)
        foreach (vivado_define ${VIVADO_DEFINES})
            list(APPEND vivado_defines ${vivado_define})
        endforeach()
    endif()

    if (VIVADO_ASSIGNMENTS)
        foreach (vivado_assignment ${VIVADO_ASSIGNMENTS})
            list(APPEND vivado_assignments ${vivado_assignment})
        endforeach()
    endif()

    foreach (arg ${ARGN})
        # Handle argument
        if (arg STREQUAL PROJECT_DIRECTORY)
            set(state GET_PROJECT_DIRECTORY)
        elseif (arg STREQUAL DEFINES)
            set(state GET_DEFINES)
        elseif (arg STREQUAL INCLUDES)
            set(state GET_INCLUDES)
        elseif (arg STREQUAL DEPENDS)
            set(state GET_DEPENDS)
        elseif (arg STREQUAL TOP_LEVEL_ENTITY)
            set(state GET_TOP_LEVEL_ENTITY)
        elseif (arg STREQUAL ASSIGNMENTS)
            set(state GET_ASSIGNMENTS)
        # Handle state
        elseif (state STREQUAL GET_SOURCES)
            get_filename_component(arg ${arg} REALPATH)
            list(APPEND vivado_sources ${arg})
        elseif (state STREQUAL GET_DEFINES)
            list(APPEND vivado_defines ${arg})
        elseif (state STREQUAL GET_DEPENDS)
            list(APPEND vivado_depends ${arg})
        elseif (state STREQUAL GET_INCLUDES)
            list(APPEND vivado_includes ${arg})
        elseif (state STREQUAL GET_PROJECT_DIRECTORY)
            set(vivado_project_directory ${arg})
            set(state UNKNOWN)
        elseif (state STREQUAL GET_TOP_LEVEL_ENTITY)
            set(vivado_top_level_entity ${arg})
            set(state UNKNOWN)
        elseif (state STREQUAL GET_ASSIGNMENTS)
            list(APPEND vivado_assignments ${arg})
        else()
            message(FATAL_ERROR "Unknown argument")
        endif()
    endforeach()

    file(MAKE_DIRECTORY ${vivado_project_directory})

    get_hdl_depends(${vivado_top_level_entity} hdl_depends)

    foreach (hdl_name ${hdl_depends} ${vivado_top_level_entity})
        get_hdl_properties(${hdl_name}
            SOURCE hdl_source
            DEFINES hdl_defines
            INCLUDES hdl_includes
            SYNTHESIZABLE hdl_synthesizable
        )

        if (hdl_synthesizable)
            list(APPEND vivado_sources ${hdl_source})
            list(APPEND vivado_defines ${hdl_defines})
            list(APPEND vivado_includes ${hdl_includes})
        endif()
    endforeach()

    list(REMOVE_DUPLICATES vivado_defines)
    list(REMOVE_DUPLICATES vivado_includes)

    set(vivado_defines_list "")

    foreach (vivado_define ${vivado_defines})
        list(APPEND vivado_defines_list "lappend defines ${vivado_define}")
    endforeach()

    set(vivado_includes_list "")

    foreach (vivado_include ${vivado_includes})
        if (CYGWIN)
            execute_process(COMMAND cygpath -m ${vivado_include}
                OUTPUT_VARIABLE vivado_include
                OUTPUT_STRIP_TRAILING_WHITESPACE)
        endif()

        list(APPEND vivado_includes_list "lappend includes ${vivado_include}")
    endforeach()

    set(vivado_sources_list "")

    foreach (vivado_source ${vivado_sources})
        if (vivado_source MATCHES .sv)
            set(vivado_type_file SYSTEMVERILOG_FILE)
        elseif (vivado_source MATCHES .vhd)
            set(vivado_type_file VHDL_FILE)
        elseif (vivado_source MATCHES .v)
            set(vivado_type_file VERILOG_FILE)
        endif()

        if (CYGWIN)
            execute_process(COMMAND cygpath -m ${vivado_source}
                OUTPUT_VARIABLE vivado_source
                OUTPUT_STRIP_TRAILING_WHITESPACE)
        endif()

        list(APPEND vivado_sources_list "lappend sources ${vivado_source}")
    endforeach()

    string(REGEX REPLACE ";" "\n" vivado_includes_list
        "${vivado_includes_list}")

    string(REGEX REPLACE ";" "\n" vivado_defines_list "${vivado_defines_list}")

    string(REGEX REPLACE ";" "\n" vivado_sources_list "${vivado_sources_list}")

    configure_file(${ADD_VIVADO_PROJECT_CURRENT_DIR}/AddVivadoProject.tcl.cmake.in
        ${vivado_project_directory}/logic.tcl)

    add_custom_command(
        OUTPUT ${vivado_project_directory}/vivado.jou
        COMMAND ${VIVADO_EXECUTABLE} -notrace -mode batch -source logic.tcl
        DEPENDS
            ${vivado_project_directory}/logic.tcl
            ${vivado_includes}
            ${vivado_sources}
        WORKING_DIRECTORY ${vivado_project_directory}
        COMMENT "Vivado compiling ${vivado_top_level_entity}"
    )

    add_custom_target(vivado-compile-${target_name}
        DEPENDS ${vivado_project_directory}/vivado.jou
    )

    add_dependencies(vivado-compile-all vivado-compile-${target_name})
endfunction()
