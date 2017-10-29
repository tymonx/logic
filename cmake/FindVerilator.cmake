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

#.rst:
# FindVerilator
# --------
#
# Find Verilator
#
# ::
#
#   VERILATOR_EXECUTABLE    - Verilator
#   VERILATOR_FOUND         - true if Verilator found

if (VERILATOR_FOUND)
    return()
endif()

find_package(PackageHandleStandardArgs REQUIRED)
find_package(SystemC)

find_program(VERILATOR_EXECUTABLE verilator
    HINTS $ENV{VERILATOR_ROOT}
    PATH_SUFFIXES bin
    DOC "Path to the Verilator executable"
)

get_filename_component(VERILATOR_EXECUTABLE_DIR ${VERILATOR_EXECUTABLE}
    DIRECTORY)

find_path(VERILATOR_INCLUDE_DIR verilated.h
    HINTS $ENV{VERILATOR_ROOT} ${VERILATOR_EXECUTABLE_DIR}/..
    PATH_SUFFIXES include share/verilator/include
    DOC "Path to the Verilator headers"
)

mark_as_advanced(VERILATOR_EXECUTABLE)
mark_as_advanced(VERILATOR_INCLUDE_DIR)

find_package_handle_standard_args(Verilator REQUIRED_VARS
    VERILATOR_EXECUTABLE VERILATOR_INCLUDE_DIR)

add_library(verilated STATIC
    ${VERILATOR_INCLUDE_DIR}/verilated.cpp
    ${VERILATOR_INCLUDE_DIR}/verilated_vcd_c.cpp
    ${VERILATOR_INCLUDE_DIR}/verilated_vcd_sc.cpp
)

set_target_properties(verilated PROPERTIES
    ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib
)

target_include_directories(verilated SYSTEM PRIVATE
    ${VERILATOR_INCLUDE_DIR}
    ${SYSTEMC_INCLUDE_DIRS}
)

if (CMAKE_CXX_COMPILER_ID MATCHES GNU)
    target_compile_options(verilated PRIVATE
        -Wno-cast-qual
        -Wno-cast-equal
        -Wno-float-equal
        -Wno-suggest-override
        -Wno-conversion
        -Wno-unused-parameter
        -Wno-effc++
        -Wno-format
        -Wno-format-nonliteral
        -Wno-missing-declarations
        -Wno-old-style-cast
        -Wno-shadow
        -Wno-sign-conversion
        -Wno-strict-overflow
        -Wno-suggest-attribute=noreturn
        -Wno-suggest-final-methods
        -Wno-suggest-final-types
        -Wno-switch-default
        -Wno-switch-enum
        -Wno-undef
        -Wno-inline
        -Wno-zero-as-null-pointer-constant
    )
elseif (CMAKE_CXX_COMPILER_ID MATCHES Clang)
    target_compile_options(verilated PRIVATE -Wno-everything)
endif()

function(verilator_add_systemc_module target_name)
    set(state GET_SOURCES)
    set(target_sources)
    set(target_depends)
    set(target_definitions)
    set(target_include_directories)
    set(target_top_module ${target_name})
    set(target_output_directory
        ${CMAKE_BINARY_DIR}/systemc/${target_top_module})

    foreach (arg ${ARGN})
        # Handle argument
        if (arg MATCHES OUTPUT_DIRECTORY)
            set(state GET_OUTPUT_DIRECTORY)
        elseif (arg MATCHES DEFINITIONS)
            set(state GET_DEFINITIONS)
        elseif (arg MATCHES INCLUDE_DIRECTORIES)
            set(state GET_INCLUDE_DIRECTORIES)
        elseif (arg MATCHES DEPENDS)
            set(state GET_DEPENDS)
        elseif (arg MATCHES TOP_MODULE)
            set(state GET_TOP_MODULE)
        # Handle state
        elseif (state MATCHES GET_SOURCES)
            list(APPEND target_sources ${arg})
        elseif (state MATCHES GET_DEFINITIONS)
            list(APPEND target_definitions ${arg})
        elseif (state MATCHES GET_DEPENDS)
            list(APPEND target_depends ${arg})
        elseif (state MATCHES GET_INCLUDE_DIRECTORIES)
            list(APPEND target_include_directories ${arg})
        elseif (state MATCHES GET_OUTPUT_DIRECTORY)
            set(target_output_directory ${arg})
            set(state UNKNOWN)
        elseif (state MATCHES GET_TOP_MODULE)
            set(target_top_module ${arg})
            set(state UNKNOWN)
        else()
            message(FATAL_ERROR "Unknown argument")
        endif()
    endforeach()

    set(target_library ${target_top_module}__ALL.a)

    set(target_include_directories_expand "")
    foreach (inc ${target_include_directories})
        list(APPEND target_include_directories_expand -I${inc})
    endforeach()

    set(target_definitions_expand "")
    foreach (def ${target_definitions})
        list(APPEND target_definitions_expand -D${def})
    endforeach()

    file(MAKE_DIRECTORY ${target_output_directory})

    add_custom_command(
        OUTPUT
            ${target_output_directory}/${target_library}
        COMMAND
            ${VERILATOR_EXECUTABLE}
        ARGS
            --sc
            -O3
            -CFLAGS '-O3 -fdata-sections -ffunction-sections'
            --trace
            --prefix ${target_top_module}
            --top-module ${target_top_module}
            -Mdir ${target_output_directory}
            ${target_definitions_expand}
            ${target_include_directories_expand}
            ${target_sources}
        COMMAND
            make
        ARGS
            -f ${target_output_directory}/${target_top_module}.mk
        DEPENDS
            ${target_depends}
            ${target_sources}
        WORKING_DIRECTORY ${target_output_directory}
        COMMENT
            "Creating SystemC ${target_top_module} module"
    )

    add_custom_target(${target_name}
        DEPENDS ${target_output_directory}/${target_library})

    add_library(verilated_${target_name} STATIC IMPORTED)

    add_dependencies(verilated_${target_name} ${target_name})

    set_target_properties(verilated_${target_name} PROPERTIES
        IMPORTED_LOCATION ${target_output_directory}/${target_library}
    )

    set(module_libraries
        verilated_${target_name}
        verilated
    )

    set(module_include_directories
        ${VERILATOR_INCLUDE_DIR}
        ${target_output_directory}
    )

    set_target_properties(${target_name} PROPERTIES
        LIBRARIES "${module_libraries}"
        INCLUDE_DIRECTORIES "${module_include_directories}"
    )
endfunction()
