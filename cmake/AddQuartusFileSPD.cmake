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

if (NOT DEFINED MODELSIM_VLOG)
    set(MODELSIM_VLOG vlog)
endif()

if (NOT DEFINED MODELSIM_VCOM)
    set(MODELSIM_VCOM vcom)
endif()

if (NOT DEFINED WORK)
    set(WORK work)
endif()

if (NOT DEFINED WORKING_DIRECTORY)
    set(WORKING_DIRECTORY "${CMAKE_BINARY_DIR}")
endif()

get_filename_component(dir "${SPD_FILE}" DIRECTORY)
get_filename_component(name "${SPD_FILE}" NAME_WE)

file(READ "${SPD_FILE}" content)
string(REGEX REPLACE "\n" ";" content_split ${content})

set(hex_files "")
set(text_files "")
set(vhdl_files "")
set(verilog_files "")

foreach (line ${content_split})
    string(REGEX MATCH "path=\".*\\.hex\"" match "${line}")
    if (match)
        string(REGEX REPLACE ".*path=\"(.*\\.hex)\".*" "\\1"
            source "${line}")

        set(source "${dir}/${source}")
        get_filename_component(source "${source}" REALPATH)

        list(APPEND text_files "${source}")
    endif()

    string(REGEX MATCH "path=\".*\\.txt\"" match "${line}")
    if (match)
        string(REGEX REPLACE ".*path=\"(.*\\.txt)\".*" "\\1"
            source "${line}")

        set(source "${dir}/${source}")
        get_filename_component(source "${source}" REALPATH)

        list(APPEND hex_files "${source}")
    endif()

    string(REGEX MATCH "path=\".*\\.s?vh?d?\"" match "${line}")
    if (match)
        string(REGEX REPLACE ".*path=\"(.*\\.s?vh?d?)\".*" "\\1"
            source "${line}")

        if (NOT source MATCHES aldec AND
                NOT source MATCHES synopsys AND
                NOT source MATCHES cadence)
            set(source "${dir}/${source}")

            get_filename_component(source "${source}" REALPATH)

            if (CYGWIN)
                execute_process(COMMAND cygpath -m "${source}"
                    OUTPUT_VARIABLE source
                    OUTPUT_STRIP_TRAILING_WHITESPACE)
            endif()

            if (source MATCHES "\\.vhd$")
                list(APPEND vhdl_files "${source}")
            elseif (source MATCHES "\\.v$")
                list(APPEND verilog_files "${source}")
            elseif (source MATCHES "\\.sv$")
                list(APPEND verilog_files "${source}")
            endif()
        endif()
    endif()
endforeach()

set(inputs_file "${dir}/.inputs")

file(WRITE "${inputs_file}" "")

foreach (file ${hex_files} ${text_files})
    file(APPEND "${inputs_file}" "${file}\n")
endforeach()

if (verilog_files)
    execute_process(
        COMMAND
            ${MODELSIM_VLOG}
            -sv
            -work ${WORK}
            ${verilog_files}
        WORKING_DIRECTORY
            "${WORKING_DIRECTORY}"
    )
endif()

if (vhdl_files)
    execute_process(
        COMMAND
            ${MODELSIM_VCOM}
            -2008
            -work ${WORK}
            ${vhdl_files}
        WORKING_DIRECTORY
            "${WORKING_DIRECTORY}"
    )
endif()
