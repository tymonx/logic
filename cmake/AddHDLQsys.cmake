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

if (COMMAND add_hdl_qsys)
    return()
endif()

find_package(Quartus)

if (NOT TARGET qsys-compile-all)
    add_custom_target(qsys-compile-all ALL)
endif()

function(add_hdl_qsys)
    if (NOT QUARTUS_FOUND)
        return()
    endif()

    if (NOT ARG_TYPE MATCHES Qsys)
        return()
    endif()

    get_filename_component(qsys_name "${ARG_SOURCE}" NAME_WE)

    if (ARG_SOURCE MATCHES "\\.ip$")
        set(qsys_type ip)
    elseif (ARG_SOURCE MATCHES "\\.qsys$")
        set(qsys_type qsys)
    elseif (ARG_SOURCE MATCHES "\\.tcl$")
        set(qsys_type tcl)
    else()
        message(FATAL_ERROR "Quartus file must be IP, Qsys or Tcl file")
    endif()

    set(qsys_dir "${CMAKE_CURRENT_BINARY_DIR}/${qsys_name}")
    set(qsys_file "${CMAKE_CURRENT_BINARY_DIR}/${qsys_name}.${qsys_type}")
    set(spd_file "${qsys_dir}/${qsys_name}.spd")
    set(output_files "${qsys_dir}/.inputs" "${qsys_dir}/.verilog")

    if (NOT ARG_SOURCE MATCHES "${qsys_file}")
        add_custom_command(
            OUTPUT
                "${qsys_file}"
            COMMAND
                ${CMAKE_COMMAND}
            ARGS
                -E copy
                "${ARG_SOURCE}"
                "${qsys_file}"
            DEPENDS
                "${ARG_SOURCE}"
        )
    endif()

    if (qsys_type MATCHES tcl)
        set(tcl_file "${qsys_file}")
        set(qsys_file "${CMAKE_CURRENT_BINARY_DIR}/${qsys_name}.ip")

        add_custom_command(
            OUTPUT
                "${qsys_file}"
            COMMAND
                ${QUARTUS_QSYS_SCRIPT}
            ARGS
                --script=${tcl_file}
            DEPENDS
                "${tcl_file}"
            WORKING_DIRECTORY
                "${CMAKE_CURRENT_BINARY_DIR}"
        )
    endif()

    add_custom_command(
        OUTPUT
            "${spd_file}"
        COMMAND
            ${QUARTUS_QSYS_GENERATE}
        ARGS
            "${qsys_file}"
            --upgrade-ip-cores
        COMMAND
            ${QUARTUS_QSYS_GENERATE}
        ARGS
            "${qsys_file}"
            --simulation=VERILOG
        DEPENDS
            "${qsys_file}"
        WORKING_DIRECTORY
            "${CMAKE_CURRENT_BINARY_DIR}"
    )

    add_custom_command(
        OUTPUT
            ${output_files}
        COMMAND
            ${CMAKE_COMMAND}
        ARGS
            -DSPD_FILE="${spd_file}"
            -DQUARTUS_DIR="${QUARTUS_DIR}"
            -P "${_HDL_CMAKE_ROOT_DIR}/AddHDLQsysSPD.cmake"
        DEPENDS
            "${spd_file}"
        WORKING_DIRECTORY
            "${CMAKE_BINARY_DIR}"
        COMMENT
            "Quartus Platform Designer compiling ${ARG_NAME}"
    )

    set_target_properties(${ARG_NAME} PROPERTIES
        HDL_VERILATOR_FILES "${qsys_dir}/.verilog"
        HDL_QUARTUS_QSYS_INPUTS "${qsys_dir}/.inputs"
    )

    add_custom_target(qsys-compile-${ARG_NAME} DEPENDS ${output_files})

    add_dependencies(qsys-compile-all qsys-compile-${ARG_NAME})
    add_dependencies(${ARG_NAME} qsys-compile-${ARG_NAME})
endfunction()
