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

if (NOT TARGET quartus-analysis-all)
    add_custom_target(quartus-analysis-all)
endif()

if (NOT TARGET quartus-compile-all)
    add_custom_target(quartus-compile-all)
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
    set(quartus_revision ${target_name})
    set(quartus_family "")
    set(quartus_device "")
    set(quartus_ip_files "")
    set(quartus_sdc_files "")
    set(quartus_qsys_files "")
    set(quartus_source_tcl_script_files "")
    set(quartus_ip_search_paths "")

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
        if (arg STREQUAL SOURCES)
            set(state GET_SOURCES)
        elseif (arg STREQUAL PROJECT_DIRECTORY)
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
        elseif (arg STREQUAL DEVICE)
            set(state GET_DEVICE)
        elseif (arg STREQUAL FAMILY)
            set(state GET_FAMILY)
        elseif (arg STREQUAL REVISION)
            set(state GET_REVISION)
        elseif (arg STREQUAL IP_FILES)
            set(state GET_IP_FILES)
        elseif (arg STREQUAL SDC_FILES)
            set(state GET_SDC_FILES)
        elseif (arg STREQUAL QSYS_FILES)
            set(state GET_QSYS_FILES)
        elseif (arg STREQUAL SOURCE_TCL_SCRIPT_FILES)
            set(state GET_SOURCE_TCL_SCRIPT_FILES)
        elseif (arg STREQUAL IP_SEARCH_PATHS)
            set(state GET_IP_SEARCH_PATHS)

        # Handle state
        elseif (state STREQUAL GET_SOURCES)
            get_filename_component(arg ${arg} REALPATH)
            list(APPEND quartus_sources ${arg})
        elseif (state STREQUAL GET_DEFINES)
            list(APPEND quartus_defines ${arg})
        elseif (state STREQUAL GET_DEPENDS)
            list(APPEND quartus_depends ${arg})
        elseif (state STREQUAL GET_INCLUDES)
            list(APPEND quartus_includes ${arg})
        elseif (state STREQUAL GET_PROJECT_DIRECTORY)
            set(quartus_project_directory ${arg})
            set(state UNKNOWN)
        elseif (state STREQUAL GET_TOP_LEVEL_ENTITY)
            set(quartus_top_level_entity ${arg})
            set(state UNKNOWN)
        elseif (state STREQUAL GET_ASSIGNMENTS)
            list(APPEND quartus_assignments ${arg})
        elseif (state STREQUAL GET_DEVICE)
            set(quartus_device ${arg})
            set(state UNKNOWN)
        elseif (state STREQUAL GET_FAMILY)
            set(quartus_family "${arg}")
            set(state UNKNOWN)
        elseif (state STREQUAL GET_REVISION)
            set(quartus_revision ${arg})
            set(state UNKNOWN)
        elseif (state STREQUAL GET_IP_FILES)
            get_filename_component(arg ${arg} REALPATH)
            list(APPEND quartus_ip_files ${arg})
        elseif (state STREQUAL GET_SDC_FILES)
            get_filename_component(arg ${arg} REALPATH)
            list(APPEND quartus_sdc_files ${arg})
        elseif (state STREQUAL GET_QSYS_FILES)
            get_filename_component(arg ${arg} REALPATH)
            list(APPEND quartus_qsys_files ${arg})
        elseif (state STREQUAL GET_SOURCE_TCL_SCRIPT_FILES)
            get_filename_component(arg ${arg} REALPATH)
            list(APPEND quartus_source_tcl_script_files ${arg})
        elseif (state STREQUAL GET_IP_SEARCH_PATHS)
            get_filename_component(arg ${arg} REALPATH)
            list(APPEND quartus_ip_search_paths ${arg})
        else()
            message(FATAL_ERROR "Unknown argument")
        endif()
    endforeach()

    if (quartus_family)
        list(APPEND quartus_assignments
            "set_global_assignment -name FAMILY \"${quartus_family}\"")
    endif()

    if (quartus_device)
        list(APPEND quartus_assignments
            "set_global_assignment -name DEVICE \"${quartus_device}\"")
    endif()

    if (quartus_ip_search_paths)
        set(quartus_ip_search_paths_assignment
            "set_global_assignment -name IP_SEARCH_PATHS \"${quartus_ip_search_paths}\"")
    endif()

    foreach (ip_file ${quartus_ip_files})
        list(APPEND quartus_assignments
            "set_global_assignment -name IP_FILE ${ip_file}")
    endforeach()

    foreach (sdc_file ${quartus_sdc_files})
        list(APPEND quartus_assignments
            "set_global_assignment -name SDC_FILE ${sdc_file}")
    endforeach()

    foreach (qsys_file ${quartus_qsys_files})
        list(APPEND quartus_assignments
            "set_global_assignment -name QSYS_FILE ${qsys_file}")
    endforeach()

    foreach (tcl_file ${quartus_source_tcl_script_files})
        list(APPEND quartus_assignments
            "set_global_assignment -name SOURCE_TCL_SCRIPT_FILE ${tcl_file}")
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

    configure_file(
        ${ADD_QUARTUS_PROJECT_CURRENT_DIR}/AddQuartusProject.qpf.cmake.in
        ${quartus_project_directory}/${target_name}.qpf)

    configure_file(
        ${ADD_QUARTUS_PROJECT_CURRENT_DIR}/AddQuartusProject.qsf.cmake.in
        ${quartus_project_directory}/${target_name}.qsf)

    set(quartus_qsys_depends "")
    foreach (qsys_file ${quartus_qsys_files})
        get_filename_component(qsys_name ${qsys_file} NAME_WE)
        get_filename_component(qsys_dir ${qsys_file} DIRECTORY)

        set(dir ${qsys_dir}/${qsys_name})

        set(depends_list "")
        list(APPEND depends_list ${dir}/${qsys_name}.bsf)
        list(APPEND depends_list ${dir}/${qsys_name}.cmp)
        list(APPEND depends_list ${dir}/${qsys_name}.html)
        list(APPEND depends_list ${dir}/${qsys_name}.qgsynthc)
        list(APPEND depends_list ${dir}/${qsys_name}.qip)
        list(APPEND depends_list ${dir}/${qsys_name}.sopcinfo)
        list(APPEND depends_list ${dir}/${qsys_name}.xml)
        list(APPEND depends_list ${dir}/${qsys_name}_bb.v)
        list(APPEND depends_list ${dir}/${qsys_name}_inst.v)
        list(APPEND depends_list ${dir}/synth/${qsys_name}.v)

        list(APPEND quartus_qsys_depends ${depends_list})

        add_custom_command(
            OUTPUT ${depends_list}
            COMMAND ${QUARTUS_QSYS_GENERATE}
                --synthesis=VERILOG
                --quartus-project=${target_name}
                ${qsys_file}
            DEPENDS
                ${quartus_project_directory}/${target_name}.qpf
                ${quartus_project_directory}/${target_name}.qsf
                ${qsys_file}
            WORKING_DIRECTORY ${quartus_project_directory}
            COMMENT "Qsys generating ${qsys_name}"
        )
    endforeach()

    if (QUARTUS_EDITION MATCHES Pro)
        set(quartus_analysis ${QUARTUS_SYN})
    else ()
        set(quartus_analysis ${QUARTUS_MAP})
    endif()

    set(quartus_depends
        ${quartus_project_directory}/${target_name}.qpf
        ${quartus_project_directory}/${target_name}.qsf
        ${quartus_ip_files}
        ${quartus_sdc_files}
        ${quartus_qsys_files}
        ${quartus_qsys_depends}
        ${quartus_source_tcl_script_files}
        ${quartus_includes}
        ${quartus_sources}
    )

    add_custom_command(
        OUTPUT ${quartus_project_directory}/output_files/${target_name}.flow.rpt
        COMMAND ${quartus_analysis} --analysis_and_elaboration ${target_name}
        DEPENDS ${quartus_depends}
        WORKING_DIRECTORY ${quartus_project_directory}
        COMMENT "Quartus analysing ${quartus_top_level_entity}"
    )

    add_custom_command(
        OUTPUT ${quartus_project_directory}/output_files/${target_name}.sof
        COMMAND ${QUARTUS_SH}
            --flow compile ${target_name}
            -c ${quartus_revision}
        DEPENDS ${quartus_depends}
        WORKING_DIRECTORY ${quartus_project_directory}
        COMMENT "Quartus compiling ${quartus_top_level_entity}"
    )

    add_custom_target(quartus-analysis-${target_name} DEPENDS
        ${quartus_project_directory}/output_files/${target_name}.flow.rpt
    )

    add_dependencies(quartus-analysis-all quartus-analysis-${target_name})

    add_custom_target(quartus-compile-${target_name} DEPENDS
        ${quartus_project_directory}/output_files/${target_name}.sof
    )

    add_dependencies(quartus-compile-all quartus-compile-${target_name})
endfunction()
