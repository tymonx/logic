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

set(CMAKE_MODULE_PATH "${CMAKE_MODULE_PATH}" "${CMAKE_CURRENT_LIST_DIR}")

set(SPD_FILE "" CACHE STRING "SPD file")
set(QUARTUS_DIR "" CACHE STRING "Quartus path")

if (NOT EXISTS "${SPD_FILE}")
    message(FATAL_ERROR "SPD file doesn't exist: ${SPD_FILE}")
endif()

get_filename_component(name "${SPD_FILE}" NAME_WE)
get_filename_component(dir "${SPD_FILE}" DIRECTORY)

file(READ "${SPD_FILE}" content)
string(REGEX REPLACE "[\n ]+" ";" content_split "${content}")

set(vhdl_files "")
set(input_files "")
set(verilog_files "")

set(modelsim_vcom "")
set(modelsim_vlog "")

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
            list(APPEND vhdl_files "${path}")

            if (NOT simulator OR simulator MATCHES modelsim OR
                    simulator MATCHES mentor)
                list(APPEND modelsim_vcom "${path}")
            endif()
        elseif (type MATCHES VERILOG)
            list(APPEND verilog_files "${path}")

            if (NOT simulator OR simulator MATCHES modelsim OR
                    simulator MATCHES mentor)
                list(APPEND modelsim_vlog "${path}")
            endif()
        elseif (type MATCHES HEX)
            list(APPEND input_files "${path}")
        endif()

        set(type "")
        set(path "")
        set(simulator "")
    endif()
endforeach()

file(WRITE "${dir}/.inputs" "")

foreach (input_file ${input_files})
    file(APPEND "${dir}/.inputs"  "${input_file}\n")
endforeach()

file(WRITE "${dir}/.verilog" "")

foreach (verilog_file ${verilog_files})
    file(APPEND "${dir}/.verilog"  "${verilog_file}\n")
endforeach()

set(modelsim_libraries_dir "${CMAKE_BINARY_DIR}/modelsim/libraries")

if (NOT EXISTS "${modelsim_libraries_dir}/${name}/")
    execute_process(
        COMMAND
            vlib ${name}
        WORKING_DIRECTORY
            "${modelsim_libraries_dir}"
    )
endif()

if (modelsim_vlog)
    execute_process(
        COMMAND
            vlog -work ${name} -sv ${modelsim_vlog}
        WORKING_DIRECTORY
            "${modelsim_libraries_dir}"
    )
endif()

if (modelsim_vcom)
    execute_process(
        COMMAND
            vcom -work ${name} -2008 ${modelsim_vcom}
        WORKING_DIRECTORY
            "${modelsim_libraries_dir}"
    )
endif()
