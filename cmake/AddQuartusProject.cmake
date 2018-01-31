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

if (COMMAND add_quartus_project)
    return()
endif()

find_package(Quartus)

include(CMakeParseArguments)

if (QUARTUS_FOUND)
    set(ADD_QUARTUS_PROJECT_CURRENT_DIR "${CMAKE_CURRENT_LIST_DIR}"
        CACHE INTERNAL "Add Quartus project current directory" FORCE)

    if (NOT TARGET quartus-initialize-all)
        add_custom_target(quartus-initialize-all)
    endif()

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
        MIF_FILES
        SDC_FILES
        QSYS_FILES
        QSYS_TCL_FILES
        IP_SEARCH_PATHS
        NUM_PARALLEL_PROCESSORS
        SOURCE_TCL_SCRIPT_FILES
    )

    cmake_parse_arguments(ARG "${options}" "${one_value_arguments}"
        "${multi_value_arguments}" ${ARGN})

    macro(set_default_value name value)
        if (NOT DEFINED ARG_${name})
            set(ARG_${name} ${value})
        endif()
    endmacro()

    set(quartus_depends "")
    set(quartus_assignments "")

    set(ip_files "")
    set(qsys_files "")
    set(qsys_tcl_files "")

    if (DEFINED QUARTUS_NUM_PARALLEL_PROCESSORS)
        set(ARG_NUM_PARALLEL_PROCESSORS ${QUARTUS_NUM_PARALLEL_PROCESSORS})
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

    set_default_value(REVISION ${target_name})
    set_default_value(TOP_LEVEL_ENTITY "${target_name}")
    set_default_value(NUM_PARALLEL_PROCESSORS ALL)
    set_default_value(PROJECT_DIRECTORY
        "${CMAKE_BINARY_DIR}/quartus/${target_name}")

    file(MAKE_DIRECTORY "${ARG_PROJECT_DIRECTORY}")

    get_hdl_depends(${ARG_TOP_LEVEL_ENTITY} hdl_depends)

    foreach (hdl_name ${ARG_DEPENDS} ${hdl_depends} ${ARG_TOP_LEVEL_ENTITY})
        get_hdl_property(hdl_synthesizable ${hdl_name} SYNTHESIZABLE)

        if (hdl_synthesizable)
            get_hdl_property(hdl_type ${hdl_name} TYPE)

            get_hdl_property(sdc_files ${hdl_name} QUARTUS_SDC_FILES)
            list(APPEND ARG_SDC_FILES ${sdc_files})

            if (hdl_type MATCHES Qsys)
                get_hdl_property(hdl_source ${hdl_name} SOURCE)

                if (hdl_source MATCHES "\\.tcl$")
                    list(APPEND ARG_QSYS_TCL_FILES "${hdl_source}")
                elseif (hdl_source MATCHES "\\.ip$")
                    list(APPEND ARG_IP_FILES "${hdl_source}")
                elseif (hdl_source MATCHES "\\.qsys$")
                    list(APPEND ARG_QSYS_FILES "${hdl_source}")
                endif()
            elseif (hdl_type MATCHES Verilog OR hdl_type MATCHES VHDL)
                get_hdl_property(hdl_sources ${hdl_name} SOURCES)
                list(APPEND ARG_SOURCES ${hdl_sources})

                get_hdl_property(hdl_source ${hdl_name} SOURCE)
                list(APPEND ARG_SOURCES "${hdl_source}")

                get_hdl_property(hdl_defines ${hdl_name} DEFINES)
                list(APPEND ARG_DEFINES ${hdl_defines})

                get_hdl_property(hdl_includes ${hdl_name} INCLUDES)
                list(APPEND ARG_INCLUDES ${hdl_includes})

                get_hdl_property(mif_files ${hdl_name} MIF_FILES)
                list(APPEND ARG_MIF_FILES ${mif_files})
            endif()
        endif()
    endforeach()

    set(ip_search_paths "")

    if (ARG_IP_SEARCH_PATHS)
        foreach(ip_path ${ARG_IP_SEARCH_PATHS})
            get_filename_component(ip_path "${ip_path}" REALPATH)

            if (CYGWIN)
                execute_process(COMMAND cygpath -m "${ip_path}"
                    OUTPUT_VARIABLE ip_path
                    OUTPUT_STRIP_TRAILING_WHITESPACE)
            endif()

            list(APPEND ip_search_paths "${ip_path}")
        endforeach()

        set(quartus_ip_search_paths_assignment
            "set_global_assignment -name IP_SEARCH_PATHS \"${ip_search_paths}\"")
    endif()

    list(APPEND ip_search_paths "$$")

    foreach (file ${ARG_QSYS_TCL_FILES} ${ARG_QSYS_FILES} ${ARG_IP_FILES})
        get_filename_component(file "${file}" REALPATH)
        get_filename_component(name "${file}" NAME_WE)
        get_filename_component(filename "${file}" NAME)

        if (NOT file MATCHES "${ARG_PROJECT_DIRECTORY}/${filename}")
            add_custom_command(
                OUTPUT
                    "${ARG_PROJECT_DIRECTORY}/${filename}"
                COMMAND
                    ${CMAKE_COMMAND}
                ARGS
                    -E copy "${file}" "${ARG_PROJECT_DIRECTORY}"
                DEPENDS
                    "${file}"
            )
        endif()

        if (file MATCHES "\\.ip$")
            list(APPEND ip_files "${ARG_PROJECT_DIRECTORY}/${name}.ip")
        elseif (file MATCHES "\\.qsys$")
            list(APPEND qsys_files "${ARG_PROJECT_DIRECTORY}/${name}.qsys")
        elseif (file MATCHES "\\.tcl$")
            list(APPEND qsys_tcl_files "${ARG_PROJECT_DIRECTORY}/${name}.tcl")
        endif()
    endforeach()

    foreach (tcl_file ${qsys_tcl_files})
        get_filename_component(tcl_file "${tcl_file}" REALPATH)
        get_filename_component(name "${tcl_file}" NAME_WE)
        get_filename_component(dir "${tcl_file}" DIRECTORY)

        set(ip_file "${dir}/${name}.ip")
        set(tcl_file_arg "${tcl_file}")

        if (CYGWIN)
            execute_process(COMMAND cygpath -m "${tcl_file_arg}"
                OUTPUT_VARIABLE tcl_file_arg
                OUTPUT_STRIP_TRAILING_WHITESPACE)
        endif()

        set(qsys_flags "")

        if (QUARTUS_EDITION MATCHES Pro)
            list(APPEND qsys_flags --quartus-project=${target_name}.qpf)
        endif()

        add_custom_command(
            OUTPUT
                ${ip_file}
            COMMAND
                ${QUARTUS_QSYS_SCRIPT}
            ARGS
                --script="${tcl_file}"
                ${qsys_flags}
            COMMENT
                "Platform Designer is creating IP file: ${name}.ip"
            WORKING_DIRECTORY
                "${ARG_PROJECT_DIRECTORY}"
        )

        list(APPEND ip_files "${ip_file}")
    endforeach()

    set(qsys_ip_depends "")
    set(quartus_ip_dir "${ARG_PROJECT_DIRECTORY}/.ip")

    if (NOT EXISTS "${quartus_ip_dir}")
        file(MAKE_DIRECTORY "${quartus_ip_dir}")
    endif()

    string(REPLACE ";" "," qsys_search_path "${ip_search_paths}")

    foreach (ip_file ${ip_files})
        get_filename_component(ip_file "${ip_file}" REALPATH)
        list(APPEND quartus_depends "${ip_file}")

        get_filename_component(name "${ip_file}" NAME_WE)
        set(ip_file_arg "${ip_file}")

        if (CYGWIN)
            execute_process(COMMAND cygpath -m "${ip_file_arg}"
                OUTPUT_VARIABLE ip_file_arg
                OUTPUT_STRIP_TRAILING_WHITESPACE)
        endif()

        set(qsys_flags "")

        if (QUARTUS_EDITION MATCHES Pro)
            list(APPEND qsys_flags --quartus-project=${target_name}.qpf)
        endif()

        add_custom_command(
            OUTPUT
                "${quartus_ip_dir}/${name}"
            COMMAND
                ${QUARTUS_QSYS_GENERATE}
            ARGS
                "${ip_file_arg}"
                --upgrade-ip-cores
                --search-path=\"${qsys_search_path}\"
                ${qsys_flags}
            COMMAND
                ${QUARTUS_QSYS_GENERATE}
            ARGS
                "${ip_file_arg}"
                --synthesis=VERILOG
                --search-path=\"${qsys_search_path}\"
                ${qsys_flags}
            COMMAND
                ${CMAKE_COMMAND}
            ARGS
                -E touch "${quartus_ip_dir}/${name}"
            DEPENDS
                "${ip_file}"
            WORKING_DIRECTORY
                "${ARG_PROJECT_DIRECTORY}"
        )

        list(APPEND qsys_ip_depends "${quartus_ip_dir}/${name}")
        list(APPEND quartus_depends "${quartus_ip_dir}/${name}")
        list(APPEND quartus_assignments
            "set_global_assignment -name IP_FILE ${ip_file_arg}")
    endforeach()

    set(quartus_qsys_dir "${ARG_PROJECT_DIRECTORY}/.qsys")

    if (NOT EXISTS "${quartus_qsys_dir}")
        file(MAKE_DIRECTORY "${quartus_qsys_dir}")
    endif()

    foreach (qsys_file ${qsys_files})
        get_filename_component(qsys_file "${qsys_file}" REALPATH)
        list(APPEND quartus_depends "${qsys_file}")

        get_filename_component(name "${qsys_file}" NAME_WE)
        set(qsys_file_arg "${qsys_file}")

        if (CYGWIN)
            execute_process(COMMAND cygpath -m "${qsys_file_arg}"
                OUTPUT_VARIABLE qsys_file_arg
                OUTPUT_STRIP_TRAILING_WHITESPACE)
        endif()

        set(qsys_flags "")

        if (QUARTUS_EDITION MATCHES Pro)
            list(APPEND qsys_flags --quartus-project=${target_name}.qpf)
        endif()

        add_custom_command(
            OUTPUT
                "${quartus_qsys_dir}/${name}"
            COMMAND
                ${QUARTUS_QSYS_GENERATE}
            ARGS
                "${qsys_file_arg}"
                --upgrade-ip-cores
                --search-path=\"${qsys_search_path}\"
                ${qsys_flags}
            COMMAND
                ${QUARTUS_QSYS_GENERATE}
            ARGS
                "${qsys_file_arg}"
                --synthesis=VERILOG
                --search-path=\"${qsys_search_path}\"
                ${qsys_flags}
            COMMAND
                ${CMAKE_COMMAND}
            ARGS
                -E touch "${quartus_qsys_dir}/${name}"
            DEPENDS
                "${qsys_file}"
                ${qsys_ip_depends}
            WORKING_DIRECTORY
                "${ARG_PROJECT_DIRECTORY}"
        )

        list(APPEND quartus_depends "${quartus_qsys_dir}/${name}")
        list(APPEND quartus_assignments
            "set_global_assignment -name QSYS_FILE ${qsys_file_arg}")
    endforeach()

    if (ARG_SDC_FILES)
        list(REMOVE_DUPLICATES ARG_SDC_FILES)
    endif()

    foreach (mif_file ${ARG_MIF_FILES})
        get_filename_component(mif_file "${mif_file}" REALPATH)
        list(APPEND quartus_depends "${mif_file}")

        if (CYGWIN)
            execute_process(COMMAND cygpath -m "${mif_file}"
                OUTPUT_VARIABLE mif_file
                OUTPUT_STRIP_TRAILING_WHITESPACE)
        endif()

        list(APPEND quartus_assignments
            "set_global_assignment -name MIF_FILE ${mif_file}")
    endforeach()

    foreach (sdc_file ${ARG_SDC_FILES})
        get_filename_component(sdc_file "${sdc_file}" REALPATH)
        list(APPEND quartus_depends "${sdc_file}")

        if (CYGWIN)
            execute_process(COMMAND cygpath -m "${sdc_file}"
                OUTPUT_VARIABLE sdc_file
                OUTPUT_STRIP_TRAILING_WHITESPACE)
        endif()

        list(APPEND quartus_assignments
            "set_global_assignment -name SDC_FILE ${sdc_file}")
    endforeach()

    foreach (tcl_file ${ARG_SOURCE_TCL_SCRIPT_FILES})
        get_filename_component(tcl_file "${tcl_file}" REALPATH)
        list(APPEND quartus_depends "${tcl_file}")

        if (CYGWIN)
            execute_process(COMMAND cygpath -m "${tcl_file}"
                OUTPUT_VARIABLE tcl_file
                OUTPUT_STRIP_TRAILING_WHITESPACE)
        endif()

        list(APPEND quartus_assignments
            "set_global_assignment -name SOURCE_TCL_SCRIPT_FILE ${tcl_file}")
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
        get_filename_component(quartus_include "${quartus_include}" REALPATH)

        if (CYGWIN)
            execute_process(COMMAND cygpath -m "${quartus_include}"
                OUTPUT_VARIABLE quartus_include
                OUTPUT_STRIP_TRAILING_WHITESPACE)
        endif()

        list(APPEND quartus_assignments
            "set_global_assignment -name SEARCH_PATH ${quartus_include}")
    endforeach()

    foreach (quartus_source ${ARG_SOURCES})
        if (quartus_source MATCHES "\\.sv$")
            set(quartus_type_file SYSTEMVERILOG_FILE)
        elseif (quartus_source MATCHES "\\.vhd$")
            set(quartus_type_file VHDL_FILE)
        elseif (quartus_source MATCHES "\\.v$")
            set(quartus_type_file VERILOG_FILE)
        else()
            continue()
        endif()

        list(APPEND quartus_depends ${quartus_source})

        if (CYGWIN)
            execute_process(COMMAND cygpath -m "${quartus_source}"
                OUTPUT_VARIABLE quartus_source
                OUTPUT_STRIP_TRAILING_WHITESPACE)
        endif()

        list(APPEND quartus_assignments
            "set_global_assignment -name ${quartus_type_file} ${quartus_source}")
    endforeach()

    string(REGEX REPLACE ";" "\n" quartus_assignments "${quartus_assignments}")

    configure_file(
        "${ADD_QUARTUS_PROJECT_CURRENT_DIR}/AddQuartusProject.qpf.cmake.in"
        "${ARG_PROJECT_DIRECTORY}/${target_name}.qpf")

    configure_file(
        "${ADD_QUARTUS_PROJECT_CURRENT_DIR}/AddQuartusProject.qsf.cmake.in"
        "${ARG_PROJECT_DIRECTORY}/${target_name}.qsf")

    list(APPEND quartus_depends "${ARG_PROJECT_DIRECTORY}/${target_name}.qsf")
    list(APPEND quartus_depends "${ARG_PROJECT_DIRECTORY}/${target_name}.qpf")

    if (QUARTUS_EDITION MATCHES Pro)
        set(quartus_analysis ${QUARTUS_SYN})

        set(quartus_analysis_file
            "${ARG_PROJECT_DIRECTORY}/output_files/${target_name}.syn.rpt")
    else ()
        set(quartus_analysis ${QUARTUS_MAP})

        set(quartus_analysis_file
            "${ARG_PROJECT_DIRECTORY}/output_files/${target_name}.flow.rpt")
    endif()

    set(quartus_bitstream_file
        "${ARG_PROJECT_DIRECTORY}/output_files/${target_name}.sof")

    add_custom_command(
        OUTPUT
            "${quartus_analysis_file}"
        COMMAND
            ${quartus_analysis} --analysis_and_elaboration ${target_name}
        DEPENDS
            ${quartus_depends}
        WORKING_DIRECTORY
            "${ARG_PROJECT_DIRECTORY}"
        COMMENT
            "Quartus analysing ${ARG_TOP_LEVEL_ENTITY}"
    )

    add_custom_command(
        OUTPUT
            "${quartus_bitstream_file}"
        COMMAND
            ${QUARTUS_SH}
            --flow compile ${target_name}
            -c ${ARG_REVISION}
        DEPENDS
            ${quartus_depends}
        WORKING_DIRECTORY
            "${ARG_PROJECT_DIRECTORY}"
        COMMENT
            "Quartus compiling ${ARG_PROJECT_DIRECTORY}"
    )

    add_custom_target(quartus-initialize-${target_name}
        DEPENDS ${qsys_files} ${ip_files})

    add_dependencies(quartus-initialize-all quartus-initialize-${target_name})

    add_custom_target(quartus-analysis-${target_name}
        DEPENDS "${quartus_analysis_file}")

    add_dependencies(quartus-analysis-all quartus-analysis-${target_name})

    add_custom_target(quartus-compile-${target_name}
        DEPENDS "${quartus_bitstream_file}")

    add_dependencies(quartus-compile-all quartus-compile-${target_name})
endfunction()
