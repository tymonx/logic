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

if (COMMAND add_quartus_file)
    return()
endif()

find_package(Quartus)
find_package(ModelSim)

file(MAKE_DIRECTORY "${CMAKE_BINARY_DIR}/modelsim/.qsys")

if (NOT TARGET modelsim-compile-qsys)
    add_custom_target(modelsim-compile-qsys ALL)
endif()

if (NOT TARGET modelsim-compile-all)
    add_custom_target(modelsim-compile-all ALL)
endif()

add_dependencies(modelsim-compile-all modelsim-compile-qsys)

function(add_quartus_file file)
    if (NOT file)
        message(FATAL_ERROR "Quartus file is not defined")
    endif()

    get_filename_component(file "${file}" REALPATH)

    if (NOT EXISTS "${file}")
        message(FATAL_ERROR "Quartus file doesn't exist: ${file}")
    endif()

    if (NOT file MATCHES "\\.ip$" AND NOT file MATCHES "\\.qsys$"
            AND NOT file MATCHES "\\.tcl$")
        message(FATAL_ERROR "Quartus file must be IP, Qsys or Tcl file")
    endif()

    get_filename_component(name "${file}" NAME_WE)
    get_filename_component(filename "${file}" NAME)

    set(entries
        TYPE Qsys
        NAME "${name}"
        SOURCE "${file}"
        LIBRARY "${name}"
        SOURCES ""
        DEPENDS ""
        DEFINED ""
        INCLUDES ""
        COMPILE Quartus ModelSim
        ANALYSIS Quartus ModelSim
        SYNTHESIZABLE TRUE
    )

    if (NOT DEFINED _HDL_${name})
        set(hdl_list ${_HDL_LIST})
        list(APPEND hdl_list ${name})
        set(_HDL_LIST "${hdl_list}" CACHE INTERNAL "" FORCE)
    endif()

    set(_HDL_${name} "${entries}" CACHE INTERNAL "" FORCE)

    if (NOT MODELSIM_FOUND)
        return()
    endif()

    configure_file("${file}" "${CMAKE_CURRENT_BINARY_DIR}" COPYONLY)

    if (filename MATCHES "\\.tcl$")
        set(ip_file "${CMAKE_CURRENT_BINARY_DIR}/${name}.ip")
        set(tcl_file "${CMAKE_CURRENT_BINARY_DIR}/${name}.tcl")
        set(qsys_file "${CMAKE_CURRENT_BINARY_DIR}/${name}.qsys")

        if (NOT EXISTS "${ip_file}" OR NOT EXISTS "${qsys_file}")
            if (CYGWIN)
                execute_process(COMMAND cygpath -m "${tcl_file}"
                    OUTPUT_VARIABLE tcl_file
                    OUTPUT_STRIP_TRAILING_WHITESPACE)
            endif()

            execute_process(
                COMMAND
                    ${QUARTUS_QSYS_SCRIPT}
                    --script=${tcl_file}
                WORKING_DIRECTORY
                    "${CMAKE_CURRENT_BINARY_DIR}"
            )
        endif()

        if (EXISTS "${ip_file}")
            set(filename "${name}.ip")
        elseif (EXISTS "${qsys_file}")
            set(filename "${name}.qsys")
        endif()
    endif()

    if (CYGWIN)
        execute_process(COMMAND cygpath -m "${filename}"
            OUTPUT_VARIABLE filename
            OUTPUT_STRIP_TRAILING_WHITESPACE)
    endif()

    set(spd_file "${CMAKE_CURRENT_BINARY_DIR}/${name}/${name}.spd")

    if (NOT EXISTS "${spd_file}")
        execute_process(
            COMMAND
                ${QUARTUS_QSYS_GENERATE}
                "${filename}"
                --upgrade-ip-cores
            WORKING_DIRECTORY
                "${CMAKE_CURRENT_BINARY_DIR}"
        )

        execute_process(
            COMMAND
                ${QUARTUS_QSYS_GENERATE}
                "${filename}"
                --simulation=VERILOG
            WORKING_DIRECTORY
                "${CMAKE_CURRENT_BINARY_DIR}"
        )

        if (NOT EXISTS "${spd_file}")
            message(FATAL_ERROR "Quartus SPD file doesn't exist: ${spd_file}")
        endif()
    endif()

    file(READ "${spd_file}" spd_content)

    string(REGEX REPLACE "\n" ";" spd_list ${spd_content})

    set(hdl_sources "")
    foreach (spd_line ${spd_list})
        string(REGEX MATCH "path=\".*\\.s?v\"" match "${spd_line}")

        if (match)
            string(REGEX REPLACE ".*path=\"(.*\\.s?v)\".*" "\\1"
                hdl_source "${spd_line}")

            if (NOT hdl_source MATCHES aldec AND
                    NOT hdl_source MATCHES synopsys AND
                    NOT hdl_source MATCHES cadence AND
                    NOT hdl_source MATCHES ${name}_bb.v AND
                    NOT hdl_source MATCHES ${name}_inst.v)
                set(hdl_source
                    "${CMAKE_CURRENT_BINARY_DIR}/${name}/${hdl_source}")

                get_filename_component(hdl_source "${hdl_source}" REALPATH)

                if (CYGWIN)
                    execute_process(COMMAND cygpath -m "${hdl_source}"
                        OUTPUT_VARIABLE hdl_source
                        OUTPUT_STRIP_TRAILING_WHITESPACE)
                endif()

                list(APPEND hdl_sources "${hdl_source}")
            endif()
        endif()
    endforeach()

    if (NOT EXISTS "${CMAKE_BINARY_DIR}/modelsim/${name}")
        execute_process(COMMAND ${MODELSIM_VLIB} ${name}
            WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/modelsim OUTPUT_QUIET)
    endif()

    add_custom_command(
        OUTPUT
            "${CMAKE_BINARY_DIR}/modelsim/.qsys/${name}"
        COMMAND
            ${MODELSIM_VLOG}
        ARGS
            -sv
            -work ${name}
            ${hdl_sources}
        COMMAND
            ${CMAKE_COMMAND}
        ARGS
            -E touch "${CMAKE_BINARY_DIR}/modelsim/.qsys/${name}"
        DEPENDS
            "${CMAKE_CURRENT_BINARY_DIR}/${filename}"
        COMMENT
            "ModelSim compiling Quartus Qsys/Ip module ${name}"
        WORKING_DIRECTORY
            "${CMAKE_BINARY_DIR}/modelsim"
    )

    add_custom_target(modelsim-compile-qsys-${name}
        DEPENDS "${CMAKE_BINARY_DIR}/modelsim/.qsys/${name}"
    )

    add_dependencies(modelsim-compile-qsys
        modelsim-compile-qsys-${name})
endfunction()

function(add_quartus_files)
    foreach (file ${ARGN})
        add_quartus_file("${file}")
    endforeach()
endfunction()
