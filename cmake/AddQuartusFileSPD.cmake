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

set(SPD_FILE "" CACHE STRING "SPD file")

if (NOT EXISTS "${SPD_FILE}")
    message(FATAL_ERROR "SPD file doesn't exist: ${SPD_FILE}")
endif()

if (NOT DEFINED WORK)
    set(WORK work)
endif()

if (NOT DEFINED WORKING_DIRECTORY)
    set(WORKING_DIRECTORY "${CMAKE_BINARY_DIR}")
endif()

get_filename_component(dir "${SPD_FILE}" DIRECTORY)

file(READ "${SPD_FILE}" content)
string(REGEX REPLACE "[\n ]+" ";" content_split "${content}")

set(hex_files "")
set(modelsim_vhdl_sources "")
set(modelsim_verilog_sources "")

set(type "")
set(path "")
set(simulator "")

foreach (item ${content_split})
    if (item MATCHES "<file")
        set(type "")
        set(path "")
        set(simulator "")
    endif()

    if (item MATCHES "path=")
        string(REGEX REPLACE ".*path=\"(.*)\".*" "\\1" path "${item}")
    endif()

    if (item MATCHES "type=")
        string(REGEX REPLACE ".*type=\"(.*)\".*" "\\1" type "${item}")
    endif()

    if (item MATCHES "simulator=")
        string(REGEX REPLACE ".*simulator=\"(.*)\".*" "\\1" simulator "${item}")
    endif()

    if (item MATCHES "/>")
        if (dir AND path)
            set(path "${dir}/${path}")
            get_filename_component(path "${path}" REALPATH)
        endif()

        if (type MATCHES VHDL)
            if (NOT simulator OR simulator MATCHES modelsim OR
                    simulator MATCHES mentor)
                list(APPEND modelsim_vhdl_sources "${path}")
            endif()
        elseif (type MATCHES VERILOG)
            if (NOT simulator OR simulator MATCHES modelsim OR
                    simulator MATCHES mentor)
                list(APPEND modelsim_verilog_sources "${path}")
            endif()
        elseif (type MATCHES HEX)
            list(APPEND hex_files "${path}")
        endif()

        set(type "")
        set(path "")
        set(simulator "")
    endif()
endforeach()

if (DEFINED MODELSIM_VLOG AND modelsim_verilog_sources)
    execute_process(
        COMMAND
            ${MODELSIM_VLOG}
            -sv
            -work ${WORK}
            ${modelsim_verilog_sources}
        WORKING_DIRECTORY
            "${WORKING_DIRECTORY}"
    )
endif()

if (DEFINED MODELSIM_VCOM AND modelsim_vhdl_sources)
    execute_process(
        COMMAND
            ${MODELSIM_VCOM}
            -2008
            -work ${WORK}
            ${modelsim_vhdl_sources}
        WORKING_DIRECTORY
            "${WORKING_DIRECTORY}"
    )
endif()

if (DEFINED MODELSIM_HEX_OUTPUT)
    foreach (hex_file ${hex_files})
        configure_file("${hex_file}" "${MODELSIM_HEX_OUTPUT}" COPYONLY)
    endforeach()
endif()
