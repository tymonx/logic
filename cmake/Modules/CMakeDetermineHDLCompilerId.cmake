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

function(_cmake_determine_hdl_compiler_id lang)
    set(compiler_name)
    set(compiler_command)

    set(CMAKE_${lang}_PLATFORM_ID)
    set(CMAKE_${lang}_COMPILER_ID)
    set(CMAKE_${lang}_COMPILER_VERSION)
    set(CMAKE_${lang}_COMPILER_VERSION_INTERNAL)

    get_filename_component(compiler_name "${CMAKE_${lang}_COMPILER}" NAME)

    # Verilator simulation tool
    if (compiler_name MATCHES verilator)
        set(CMAKE_${lang}_PLATFORM_ID Simulation)
        set(CMAKE_${lang}_COMPILER_ID Verilator)
        set(compiler_command ${CMAKE_${lang}_COMPILER} --version)

    # Icarus Verilog simulation tool
    elseif (compiler_name MATCHES iverilog)
        set(CMAKE_${lang}_PLATFORM_ID Simulation)
        set(CMAKE_${lang}_COMPILER_ID Icarus)
        set(compiler_command ${CMAKE_${lang}_COMPILER} -V)

    # GHDL simulation tool
    elseif (compiler_name MATCHES ghdl)
        set(CMAKE_${lang}_PLATFORM_ID Simulation)
        set(CMAKE_${lang}_COMPILER_ID GHDL)
        set(compiler_command ${CMAKE_${lang}_COMPILER} --version)

    # Mentor Graphics ModelSim simulation tool
    elseif (compiler_name MATCHES vcom)
        set(CMAKE_${lang}_PLATFORM_ID Simulation)
        set(CMAKE_${lang}_COMPILER_ID ModelSim)
        set(compiler_command ${CMAKE_${lang}_COMPILER} -version)

    # Mentor Graphics ModelSim simulation tool
    elseif (compiler_name MATCHES vlog)
        set(CMAKE_${lang}_PLATFORM_ID Simulation)
        set(CMAKE_${lang}_COMPILER_ID ModelSim)
        set(compiler_command ${CMAKE_${lang}_COMPILER} -version)

    # Intel Quartus Prime Lite/Standard/Pro synthesis tool
    elseif (compiler_name MATCHES quartus)
        set(CMAKE_${lang}_PLATFORM_ID FPGA)
        set(CMAKE_${lang}_COMPILER_ID Quartus)
        set(compiler_command ${CMAKE_${lang}_COMPILER}_sh
            --tcl_eval puts "\\$quartus(version)"
        )

    # Xilinx Vivado synthesis tool
    elseif (compiler_name MATCHES vivado)
        set(CMAKE_${lang}_PLATFORM_ID FPGA)
        set(CMAKE_${lang}_COMPILER_ID Vivado)
        set(compiler_command ${CMAKE_${lang}_COMPILER} -version)

    endif()

    if (compiler_command)
        execute_process(
            COMMAND ${compiler_command}
            RESULT_VARIABLE result
            OUTPUT_VARIABLE output
            OUTPUT_STRIP_TRAILING_WHITESPACE
        )

        if (result EQUAL 0)
            string(REGEX REPLACE "\n" ";" lines "${output}")

            foreach (line ${lines})
                set(compiler_version)

                string(REGEX MATCH "[0-9]+(\\.[0-9]+)?(\\.[0-9]+)?(\\.[0-9]+)?"
                    compiler_version "${line}")

                if (compiler_version)
                    set(CMAKE_${lang}_COMPILER_VERSION "${compiler_version}")
                    set(CMAKE_${lang}_COMPILER_VERSION_INTERNAL "${line}")
                    break()
                endif()
            endforeach()
        endif()
    endif()

    set(message "")

    if (CMAKE_${lang}_COMPILER_ID)
        set(message "${CMAKE_${lang}_COMPILER_ID}")

        if (CMAKE_${lang}_COMPILER_VERSION)
            set(message "${message} ${CMAKE_${lang}_COMPILER_VERSION}")
        endif()
    else()
        set(message "unknown")
    endif()

    message(STATUS "The ${lang} compiler identification is ${message}")

    set(CMAKE_${lang}_PLATFORM_ID "${CMAKE_${lang}_PLATFORM_ID}" PARENT_SCOPE)
    set(CMAKE_${lang}_COMPILER_ID "${CMAKE_${lang}_COMPILER_ID}" PARENT_SCOPE)

    set(CMAKE_${lang}_COMPILER_VERSION
        "${CMAKE_${lang}_COMPILER_VERSION}" PARENT_SCOPE)

    set(CMAKE_${lang}_COMPILER_VERSION_INTERNAL
        "${CMAKE_${lang}_COMPILER_VERSION_INTERNAL}" PARENT_SCOPE)
endfunction()
