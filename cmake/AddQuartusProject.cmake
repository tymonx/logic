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

file(MAKE_DIRECTORY "${CMAKE_BINARY_DIR}/logic/deps")

if (NOT DEFINED _HDL_CMAKE_ROOT_DIR)
    set(_HDL_CMAKE_ROOT_DIR "${CMAKE_CURRENT_LIST_DIR}" CACHE INTERNAL
        "HDL CMake root directory" FORCE)
endif()

if (QUARTUS_FOUND)
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

    set_default_value(REVISION ${target_name})
    set_default_value(TOP_LEVEL_ENTITY "${target_name}")
    set_default_value(NUM_PARALLEL_PROCESSORS ALL)
    set_default_value(PROJECT_DIRECTORY
        "${CMAKE_BINARY_DIR}/quartus/${target_name}")

    if (NOT ARG_DEVICE)
        if (QUARTUS_DEVICE)
            set(ARG_DEVICE ${QUARTUS_DEVICE})
        else()
            if (QUARTUS_EDITION MATCHES Pro)
                set(ARG_DEVICE "10CX220YF780I5G")
            else()
                set(ARG_DEVICE "5CGXFC7C7F23C8")
            endif()
        endif()
    endif()

    if (NOT ARG_FAMILY)
        if (QUARTUS_FAMILY)
            set(ARG_FAMILY ${QUARTUS_FAMILY})
        else()
            if (QUARTUS_EDITION MATCHES Pro)
                set(ARG_FAMILY "Cyclone 10 GX")
            else()
                set(ARG_FAMILY "Cyclone V")
            endif()
        endif()
    endif()

    list(APPEND quartus_assignments
        "set_global_assignment -name FAMILY \"${ARG_FAMILY}\"")

    list(APPEND quartus_assignments
        "set_global_assignment -name DEVICE \"${ARG_DEVICE}\"")

    file(MAKE_DIRECTORY "${ARG_PROJECT_DIRECTORY}")

    get_hdl_depends(${ARG_TOP_LEVEL_ENTITY} hdl_depends)

    foreach (hdl_name ${ARG_DEPENDS} ${hdl_depends} ${ARG_TOP_LEVEL_ENTITY})
        get_target_property(hdl_synthesizable ${hdl_name} HDL_SYNTHESIZABLE)

        if (hdl_synthesizable)
            get_target_property(hdl_type ${hdl_name} HDL_TYPE)

            get_target_property(sdc_files ${hdl_name} HDL_QUARTUS_SDC_FILES)
            list(APPEND ARG_SDC_FILES ${sdc_files})

            if (hdl_type MATCHES Qsys)
                get_target_property(hdl_source ${hdl_name} HDL_SOURCE)

                if (hdl_source MATCHES "\\.tcl$")
                    list(APPEND ARG_QSYS_TCL_FILES "${hdl_source}")
                elseif (hdl_source MATCHES "\\.ip$")
                    list(APPEND ARG_IP_FILES "${hdl_source}")
                elseif (hdl_source MATCHES "\\.qsys$")
                    list(APPEND ARG_QSYS_FILES "${hdl_source}")
                endif()
            elseif (hdl_type MATCHES Verilog OR hdl_type MATCHES VHDL)
                get_target_property(hdl_sources ${hdl_name} HDL_SOURCES)
                list(APPEND ARG_SOURCES ${hdl_sources})

                get_target_property(hdl_source ${hdl_name} HDL_SOURCE)
                list(APPEND ARG_SOURCES "${hdl_source}")

                get_target_property(hdl_defines ${hdl_name} HDL_DEFINES)
                list(APPEND ARG_DEFINES ${hdl_defines})

                get_target_property(hdl_includes ${hdl_name} HDL_INCLUDES)
                list(APPEND ARG_INCLUDES ${hdl_includes})

                get_target_property(mif_files ${hdl_name} HDL_MIF_FILES)
                list(APPEND ARG_MIF_FILES ${mif_files})
            endif()
        endif()
    endforeach()

    set(ip_search_paths "")

    foreach(ip_path ${ARG_IP_SEARCH_PATHS})
        list(APPEND ip_search_paths "${ip_path}")
    endforeach()

    if (ip_search_paths)
        set(quartus_ip_search_paths_assignment
            "set_global_assignment -name IP_SEARCH_PATHS \"${ip_search_paths}\"")
    endif()

    list(APPEND ip_search_paths "$$")

    foreach (file ${ARG_QSYS_TCL_FILES} ${ARG_QSYS_FILES} ${ARG_IP_FILES})
        get_filename_component(file "${file}" REALPATH)
        get_filename_component(name "${file}" NAME_WE)
        get_filename_component(filename "${file}" NAME)

        set(qsys_file "${ARG_PROJECT_DIRECTORY}/${filename}")

        if (NOT file MATCHES "${qsys_file}")
            add_custom_command(
                OUTPUT
                    "${qsys_file}"
                COMMAND
                    ${CMAKE_COMMAND}
                ARGS
                    -E copy "${file}" "${filename}"
                DEPENDS
                    "${file}"
                COMMENT
                    "Initializing Quartus file ${filename} in ${target_name}"
                WORKING_DIRECTORY
                    "${ARG_PROJECT_DIRECTORY}"
            )
        endif()

        if (file MATCHES "\\.ip$")
            list(APPEND ip_files "${qsys_file}")
        elseif (file MATCHES "\\.qsys$")
            list(APPEND qsys_files "${qsys_file}")
        elseif (file MATCHES "\\.tcl$")
            list(APPEND qsys_tcl_files "${qsys_file}")
        endif()
    endforeach()

    set(quartus_pro
        --quartus-project=${target_name}.qpf
    )

    foreach (qsys_tcl_file ${qsys_tcl_files})
        get_filename_component(qsys_tcl_file "${qsys_tcl_file}" REALPATH)
        get_filename_component(name "${qsys_tcl_file}" NAME_WE)
        get_filename_component(dir "${qsys_tcl_file}" DIRECTORY)

        set(ip_file "${dir}/${name}.ip")

        add_custom_command(
            OUTPUT
                ${ip_file}
            COMMAND
                ${QUARTUS_QSYS_SCRIPT}
            ARGS
                --script="${qsys_tcl_file}"
                $<$<STREQUAL:QUARTUS_EDITION,Pro>:${quartus_pro}>
            DEPENDS
                "${qsys_tcl_file}"
            COMMENT
                "Platform Designer is creating IP file ${name}.ip"
            WORKING_DIRECTORY
                "${ARG_PROJECT_DIRECTORY}"
        )

        list(APPEND ip_files "${ip_file}")
    endforeach()

    string(REPLACE ";" "," qsys_search_path "${ip_search_paths}")

    foreach (ip_file ${ip_files})
        get_filename_component(ip_file "${ip_file}" REALPATH)
        get_filename_component(name "${ip_file}" NAME)

        set(output_file
            "${CMAKE_BINARY_DIR}/logic/deps/quartus.${target_name}.${name}")

        add_custom_command(
            OUTPUT
                "${output_file}"
            COMMAND
                ${QUARTUS_QSYS_GENERATE}
            ARGS
                "${ip_file}"
                --family=\""${ARG_FAMILY}"\"
                --part=\""${ARG_DEVICE}"\"
                --upgrade-ip-cores
                --search-path=\"${qsys_search_path}\"
                $<$<STREQUAL:QUARTUS_EDITION,Pro>:${quartus_pro}>
            COMMAND
                ${QUARTUS_QSYS_GENERATE}
            ARGS
                "${ip_file}"
                --family=\""${ARG_FAMILY}"\"
                --part=\""${ARG_DEVICE}"\"
                --synthesis=VERILOG
                --search-path=\"${qsys_search_path}\"
                $<$<STREQUAL:QUARTUS_EDITION,Pro>:${quartus_pro}>
            COMMAND
                ${CMAKE_COMMAND}
            ARGS
                -E touch "${output_file}"
            DEPENDS
                "${ip_file}"
            COMMENT
                "Platform Designer is generating IP core from ${name}"
            WORKING_DIRECTORY
                "${ARG_PROJECT_DIRECTORY}"
        )

        list(APPEND quartus_depends "${output_file}")
        list(APPEND quartus_assignments
            "set_global_assignment -name IP_FILE ${ip_file}")
    endforeach()

    foreach (qsys_file ${qsys_files})
        get_filename_component(qsys_file "${qsys_file}" REALPATH)
        get_filename_component(name "${qsys_file}" NAME)

        set(output_file
            "${CMAKE_BINARY_DIR}/logic/deps/quartus.${target_name}.${name}")

        add_custom_command(
            OUTPUT
                "${output_file}"
            COMMAND
                ${QUARTUS_QSYS_GENERATE}
            ARGS
                "${qsys_file}"
                --family=\""${ARG_FAMILY}"\"
                --part=\""${ARG_DEVICE}"\"
                --upgrade-ip-cores
                --search-path=\"${qsys_search_path}\"
                $<$<STREQUAL:QUARTUS_EDITION,Pro>:${quartus_pro}>
            COMMAND
                ${QUARTUS_QSYS_GENERATE}
            ARGS
                "${qsys_file}"
                --family=\""${ARG_FAMILY}"\"
                --part=\""${ARG_DEVICE}"\"
                --synthesis=VERILOG
                --search-path=\"${qsys_search_path}\"
                $<$<STREQUAL:QUARTUS_EDITION,Pro>:${quartus_pro}>
            COMMAND
                ${CMAKE_COMMAND}
            ARGS
                -E touch "${output_file}"
            DEPENDS
                "${qsys_file}"
                ${quartus_depends}
            COMMENT
                "Platform Designer is generating IP core from ${name}"
            WORKING_DIRECTORY
                "${ARG_PROJECT_DIRECTORY}"
        )

        list(APPEND quartus_depends "${output_file}")
        list(APPEND quartus_assignments
            "set_global_assignment -name QSYS_FILE ${qsys_file}")
    endforeach()

    if (ARG_SDC_FILES)
        list(REMOVE_DUPLICATES ARG_SDC_FILES)
    endif()

    foreach (mif_file ${ARG_MIF_FILES})
        get_filename_component(mif_file "${mif_file}" REALPATH)
        list(APPEND quartus_depends "${mif_file}")
        list(APPEND quartus_assignments
            "set_global_assignment -name MIF_FILE ${mif_file}")
    endforeach()

    foreach (sdc_file ${ARG_SDC_FILES})
        get_filename_component(sdc_file "${sdc_file}" REALPATH)
        list(APPEND quartus_depends "${sdc_file}")
        list(APPEND quartus_assignments
            "set_global_assignment -name SDC_FILE ${sdc_file}")
    endforeach()

    foreach (tcl_file ${ARG_SOURCE_TCL_SCRIPT_FILES})
        get_filename_component(tcl_file "${tcl_file}" REALPATH)
        list(APPEND quartus_depends "${tcl_file}")
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
        list(APPEND quartus_depends "${quartus_include}")
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

        list(APPEND quartus_depends "${quartus_source}")
        list(APPEND quartus_assignments
            "set_global_assignment -name ${quartus_type_file} ${quartus_source}")
    endforeach()

    string(REGEX REPLACE ";" "\n" quartus_assignments "${quartus_assignments}")

    configure_file(
        "${_HDL_CMAKE_ROOT_DIR}/AddQuartusProject.qpf.cmake.in"
        "${ARG_PROJECT_DIRECTORY}/${target_name}.qpf")

    configure_file(
        "${_HDL_CMAKE_ROOT_DIR}/AddQuartusProject.qsf.cmake.in"
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
            ${quartus_analysis}
        ARGS
            --analysis_and_elaboration ${target_name}
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
        ARGS
            --flow compile ${target_name}
            -c ${ARG_REVISION}
        DEPENDS
            ${quartus_depends}
        WORKING_DIRECTORY
            "${ARG_PROJECT_DIRECTORY}"
        COMMENT
            "Quartus compiling ${ARG_TOP_LEVEL_ENTITY}"
    )

    add_custom_target(quartus-initialize-${target_name}
        DEPENDS ${quartus_depends})

    add_dependencies(quartus-initialize-all quartus-initialize-${target_name})

    add_custom_target(quartus-analysis-${target_name}
        DEPENDS "${quartus_analysis_file}")

    add_dependencies(quartus-analysis-all quartus-analysis-${target_name})

    add_custom_target(quartus-compile-${target_name}
        DEPENDS "${quartus_bitstream_file}")

    add_dependencies(quartus-compile-all quartus-compile-${target_name})
endfunction()
