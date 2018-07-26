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

include(CMakeDetermineCompiler)

macro(_cmake_determine_hdl_compiler lang)
    if (NOT CMAKE_${lang}_COMPILER_ENV_VAR)
        string(TOUPPER  "${lang}_COMPILER" CMAKE_${lang}_COMPILER_ENV_VAR)
    endif()

    if (NOT CMAKE_${lang}_COMPILER_NAMES)
        set(CMAKE_${lang}_COMPILER_NAMES)
    endif()

    if (NOT CMAKE_${lang}_SOURCE_FILE_EXTENSIONS)
        if ("${lang}" STREQUAL SystemVerilog)
            set(CMAKE_${lang}_SOURCE_FILE_EXTENSIONS "sv")
        elseif ("${lang}" STREQUAL Verilog)
            set(CMAKE_${lang}_SOURCE_FILE_EXTENSIONS "v")
        elseif ("${lang}" STREQUAL VHDL)
            set(CMAKE_${lang}_SOURCE_FILE_EXTENSIONS "vhd;vhdl")
        endif()
    endif()

    if (NOT CMAKE_${lang}_IGNORE_EXTENSIONS)
        if ("${lang}" STREQUAL SystemVerilog)
            set(CMAKE_${lang}_IGNORE_EXTENSIONS
                "h;H;vh;VH;svh;SVH;o;O;a;A;obj;OBJ"
            )
        elseif ("${lang}" STREQUAL Verilog)
            set(CMAKE_${lang}_IGNORE_EXTENSIONS
                "h;H;vh;VH;o;O;a;A;obj;OBJ"
            )
        elseif ("${lang}" STREQUAL VHDL)
            set(CMAKE_${lang}_IGNORE_EXTENSIONS
                "o;O;a;A;obj;OBJ"
            )
        endif()
    endif()

    if (NOT CMAKE_${lang}_COMPILER)
        set(CMAKE_${lang}_COMPILER_INIT NOTFOUND)

        # Prefer the environment variable
        if(NOT $ENV{${CMAKE_${lang}_COMPILER_ENV_VAR}} STREQUAL "")
            get_filename_component(CMAKE_${lang}_COMPILER_INIT
                "$ENV{${CMAKE_${lang}_COMPILER_ENV_VAR}}"
                PROGRAM PROGRAM_ARGS CMAKE_${lang}_FLAGS_ENV_INIT
            )

            if(CMAKE_${lang}_FLAGS_ENV_INIT)
                set(CMAKE_${lang}_COMPILER_ARG1
                    "${CMAKE_${lang}_FLAGS_ENV_INIT}"
                    CACHE STRING "First argument to ${lang} compiler"
                )
            endif()

            if(NOT EXISTS ${CMAKE_${lang}_COMPILER_INIT})
                message(FATAL_ERROR "Could not find compiler set in environment"
                    " variable ${CMAKE_${lang}_COMPILER_ENV_VAR}:\n"
                    "$ENV{${CMAKE_${lang}_COMPILER_ENV_VAR}}.\n"
                    "${CMAKE_${lang}_COMPILER_INIT}"
                )
            endif()
        endif()

        # Next prefer the generator specified compiler
        if(CMAKE_GENERATOR_${lang})
            if(NOT CMAKE_${lang}_COMPILER_INIT)
                set(CMAKE_${lang}_COMPILER_INIT "${CMAKE_GENERATOR_${lang}}")
            endif()
        endif()

        # Finally list compilers to try
        if(NOT CMAKE_${lang}_COMPILER_INIT)
            set(CMAKE_${lang}_COMPILER_LIST)

            if ("${lang}" STREQUAL SystemVerilog)
                list(APPEND CMAKE_${lang}_COMPILER_LIST
                    verilator
                    iverilog
                    vlog
                )
            elseif ("${lang}" STREQUAL Verilog)
                list(APPEND CMAKE_${lang}_COMPILER_LIST
                    verilator
                    iverilog
                    vlog
                )
            elseif ("${lang}" STREQUAL VHDL)
                list(APPEND CMAKE_${lang}_COMPILER_LIST
                    ghdl
                    vcom
                )
            endif()

            list(APPEND CMAKE_${lang}_COMPILER_LIST
                quartus
                vivado
            )
        endif()

        _cmake_find_compiler(${lang})
    else()
        _cmake_find_compiler_path(${lang})
    endif()

    mark_as_advanced(CMAKE_${lang}_COMPILER)
    mark_as_advanced(CMAKE_${lang}_COMPILER_WRAPPER)

    if (NOT CMAKE_${lang}_COMPILER_ID_RUN AND CMAKE_${lang}_COMPILER)
        set(CMAKE_${lang}_COMPILER_ID_RUN TRUE)

        include(CMakeDetermineHDLCompilerId)

        _cmake_determine_hdl_compiler_id(${lang})
    endif()

    # Configure variables set in this file for fast reload later on
    configure_file("${CMAKE_CURRENT_LIST_DIR}/CMake${lang}Compiler.cmake.in"
        "${CMAKE_PLATFORM_INFO_DIR}/CMake${lang}Compiler.cmake"
        @ONLY
    )
endmacro()
