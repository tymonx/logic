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

if (COMMAND add_quartus_project)
    return()
endif()

find_package(Quartus)

include(CMakeParseArguments)

if (QUARTUS_FOUND)
    set(ADD_QUARTUS_PROJECT_CURRENT_DIR ${CMAKE_CURRENT_LIST_DIR}
        CACHE INTERNAL "Add Quartus project current directory" FORCE)

    if (NOT TARGET quartus-analysis-all)
        add_custom_target(quartus-analysis-all)
    endif()

    if (NOT TARGET quartus-compile-all)
        add_custom_target(quartus-compile-all)
    endif()
endif()

function(add_quartus_project target_name)
    if (NOT QUARTUS_FOUND)
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
        IP_FILES
        SDC_FILES
        QSYS_FILES
        IP_SEARCH_PATHS
        NUM_PARALLEL_PROCESSORS
        SOURCE_TCL_SCRIPT_FILES
    )

    cmake_parse_arguments(ARG "${options}" "${one_value_arguments}"
        "${multi_value_arguments}" ${ARGN})

    set(quartus_assignments "")

    if (DEFINED QUARTUS_NUM_PARALLEL_PROCESSORS)
        set(ARG_NUM_PARALLEL_PROCESSORS ${QUARTUS_NUM_PARALLEL_PROCESSORS})
    endif()

    if (NOT DEFINED ARG_REVISION)
        set(ARG_REVISION ${target_name})
    endif()

    set(ARG_INCLUDES ${QUARTUS_INCLUDES} ${ARG_INCLUDES})
    set(ARG_DEFINES ${QUARTUS_DEFINES} ${ARG_DEFINES})
    set(ARG_ASSIGNMENTS ${QUARTUS_ASSIGNMENTS} ${ARG_ASSIGNMENTS})

    if (ARG_FAMILY)
        list(APPEND quartus_assignments
            "set_global_assignment -name FAMILY \"${ARG_FAMILY}\"")
    endif()

    if (ARG_DEVICE)
        list(APPEND quartus_assignments
            "set_global_assignment -name DEVICE \"${ARG_DEVICE}\"")
    endif()

    if (ARG_IP_SEARCH_PATHS)
        set(quartus_ip_search_paths_assignment
            "set_global_assignment -name IP_SEARCH_PATHS \"${ARG_IP_SEARCH_PATHS}\"")
    endif()

    foreach (ip_file ${ARG_IP_FILES})
        list(APPEND quartus_assignments
            "set_global_assignment -name IP_FILE ${ip_file}")
    endforeach()

    foreach (sdc_file ${ARG_SDC_FILES})
        list(APPEND quartus_assignments
            "set_global_assignment -name SDC_FILE ${sdc_file}")
    endforeach()

    foreach (qsys_file ${ARG_QSYS_FILE})
        list(APPEND quartus_assignments
            "set_global_assignment -name QSYS_FILE ${qsys_file}")
    endforeach()

    foreach (tcl_file ${ARG_SOURCE_TCL_SCRIPT_FILES})
        list(APPEND quartus_assignments
            "set_global_assignment -name SOURCE_TCL_SCRIPT_FILE ${tcl_file}")
    endforeach()

    if (NOT DEFINED ARG_PROJECT_DIRECTORY)
        set(ARG_PROJECT_DIRECTORY ${CMAKE_BINARY_DIR}/quartus/${target_name})
    endif()

    if (NOT DEFINED ARG_TOP_LEVEL_ENTITY)
        set(ARG_TOP_LEVEL_ENTITY ${target_name})
    endif()

    if (NOT DEFINED ARG_NUM_PARALLEL_PROCESSORS)
        set(ARG_NUM_PARALLEL_PROCESSORS ALL)
    endif()

    file(MAKE_DIRECTORY ${ARG_PROJECT_DIRECTORY})

    get_hdl_depends(${ARG_TOP_LEVEL_ENTITY} hdl_depends)

    foreach (hdl_name ${hdl_depends} ${ARG_TOP_LEVEL_ENTITY})
        get_target_property(hdl_synthesizable ${hdl_name} HDL_SYNTHESIZABLE)

        if (hdl_synthesizable)
            get_target_property(hdl_source ${hdl_name} HDL_SOURCE)
            list(APPEND ARG_SOURCES ${hdl_source})

            get_target_property(hdl_defines ${hdl_name} HDL_DEFINES)
            list(APPEND ARG_DEFINES ${hdl_defines})

            get_target_property(hdl_includes ${hdl_name} HDL_INCLUDES)
            list(APPEND ARG_INCLUDES ${hdl_includes})
        endif()
    endforeach()

    if (ARG_DEFINES)
        list(REMOVE_DUPLICATES ARG_DEFINES)
    endif()

    if (ARG_INCLUDES)
        list(REMOVE_DUPLICATES ARG_INCLUDES)
    endif()

    foreach (quartus_define ${ARG_DEFINES})
        list(APPEND quartus_assignments
            "set_global_assignment -name VERILOG_MACRO ${quartus_define}")
    endforeach()

    foreach (quartus_include ${ARG_INCLUDES})
        get_filename_component(quartus_include ${quartus_include} REALPATH)

        if (CYGWIN)
            execute_process(COMMAND cygpath -m ${quartus_include}
                OUTPUT_VARIABLE quartus_include
                OUTPUT_STRIP_TRAILING_WHITESPACE)
        endif()

        list(APPEND quartus_assignments
            "set_global_assignment -name SEARCH_PATH ${quartus_include}")
    endforeach()

    foreach (quartus_source ${ARG_SOURCES})
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

    configure_file(
        ${ADD_QUARTUS_PROJECT_CURRENT_DIR}/AddQuartusProject.qpf.cmake.in
        ${ARG_PROJECT_DIRECTORY}/${target_name}.qpf)

    configure_file(
        ${ADD_QUARTUS_PROJECT_CURRENT_DIR}/AddQuartusProject.qsf.cmake.in
        ${ARG_PROJECT_DIRECTORY}/${target_name}.qsf)

    set(quartus_qsys_depends "")
    foreach (qsys_file ${ARG_QSYS_FILES})
        get_filename_component(qsys_file ${qsys_file} REALPATH)
        get_filename_component(qsys_name ${qsys_file} NAME_WE)
        get_filename_component(qsys_dir ${qsys_file} DIRECTORY)

        list(APPEND quartus_qsys_depends
            ${qsys_dir}/${qsys_name}/synth/${qsys_name}.v)

        add_custom_command(
            OUTPUT ${qsys_dir}/${qsys_name}/synth/${qsys_name}.v
            COMMAND ${QUARTUS_QSYS_GENERATE}
                --synthesis=VERILOG
                --quartus-project=${target_name}
                ${qsys_file}
            DEPENDS
                ${ARG_PROJECT_DIRECTORY}/${target_name}.qpf
                ${ARG_PROJECT_DIRECTORY}/${target_name}.qsf
                ${qsys_file}
            WORKING_DIRECTORY
                ${ARG_PROJECT_DIRECTORY}
            COMMENT
                "Qsys generating ${qsys_name}"
        )
    endforeach()

    if (QUARTUS_EDITION MATCHES Pro)
        set(quartus_analysis ${QUARTUS_SYN})

        set(quartus_analysis_file
            ${ARG_PROJECT_DIRECTORY}/output_files/${target_name}.syn.rpt)
    else ()
        set(quartus_analysis ${QUARTUS_MAP})

        set(quartus_analysis_file
            ${ARG_PROJECT_DIRECTORY}/output_files/${target_name}.flow.rpt)
    endif()

    set(quartus_depends
        ${ARG_PROJECT_DIRECTORY}/${target_name}.qpf
        ${ARG_PROJECT_DIRECTORY}/${target_name}.qsf
        ${quartus_ip_files}
        ${quartus_sdc_files}
        ${quartus_qsys_files}
        ${quartus_qsys_depends}
        ${quartus_source_tcl_script_files}
        ${quartus_includes}
        ${quartus_sources}
    )

    add_custom_command(
        OUTPUT
            ${quartus_analysis_file}
        COMMAND
            ${quartus_analysis} --analysis_and_elaboration ${target_name}
        DEPENDS
            ${quartus_depends}
        WORKING_DIRECTORY
            ${ARG_PROJECT_DIRECTORY}
        COMMENT
            "Quartus analysing ${ARG_TOP_LEVEL_ENTITY}"
    )

    add_custom_command(
        OUTPUT
            ${ARG_PROJECT_DIRECTORY}/output_files/${target_name}.sof
        COMMAND
            ${QUARTUS_SH}
            --flow compile ${target_name}
            -c ${ARG_REVISION}
        DEPENDS
            ${quartus_depends}
        WORKING_DIRECTORY
            ${ARG_PROJECT_DIRECTORY}
        COMMENT
            "Quartus compiling ${ARG_PROJECT_DIRECTORY}"
    )

    add_custom_target(quartus-analysis-${target_name}
        DEPENDS ${quartus_analysis_file})

    add_dependencies(quartus-analysis-all quartus-analysis-${target_name})

    add_custom_target(quartus-compile-${target_name}
        DEPENDS ${ARG_PROJECT_DIRECTORY}/output_files/${target_name}.sof)

    add_dependencies(quartus-compile-all quartus-compile-${target_name})
endfunction()
