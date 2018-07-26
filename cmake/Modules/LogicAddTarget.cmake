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

if (COMMAND logic_add_target)
    return()
endif()

include(LogicAddTargetModelSim)

function(logic_add_target)
    set(one_value_arguments
        NAME
        TYPE
        TARGET
        SYNTHESIZABLE
        OUTPUT_DIRECTORY
    )

    set(multi_value_arguments
        PATHS
        SOURCES
        DEPENDS
        DEFINES
        INCLUDES
        LIBRARIES
        MODELSIM_FLAGS
        MODELSIM_FLAGS_VHDL
        MODELSIM_FLAGS_VERILOG
        MODELSIM_FLAGS_SYSTEMVERILOG
        MODELSIM_COMMAND_FILES
        MODELSIM_COMMAND_FILES_VHDL
        MODELSIM_COMMAND_FILES_VERILOG
        MODELSIM_COMMAND_FILES_SYSTEMVERILOG
        MODELSIM_SUPPRESS
        VERILATOR_CONFIGURATIONS
    )

    cmake_parse_arguments(ARG "" "${one_value_arguments}"
        "${multi_value_arguments}" ${ARGN})

    set(ARG_SOURCES ${ARG_UNPARSED_ARGUMENTS} ${ARG_SOURCES})
    set(top_level "")

    if (ARG_SOURCES)
        list(GET ARG_SOURCES 0 source)
        list(REVERSE ARG_SOURCES)

        get_filename_component(top_level "${source}" NAME_WE)
    endif()

    macro(set_default_value name)
        if (NOT DEFINED ARG_${name})
            set(ARG_${name} ${ARGN})
        endif()
    endmacro()

    macro(set_realpath name)
        set(paths "")

        foreach (path ${ARG_${name}})
            get_filename_component(path "${path}" REALPATH)
            list(APPEND paths "${path}")
        endforeach()

        list(REMOVE_DUPLICATES paths)
        set(ARG_${name} ${paths})
    endmacro()

    set_default_value(TYPE Module)
    set_default_value(NAME ${top_level})
    set_default_value(TARGET ${top_level})
    set_default_value(DEPENDS ${LOGIC_DEPENDS})
    set_default_value(DEFINES ${LOGIC_DEFINES})
    set_default_value(INCLUDES ${LOGIC_INCLUDES})
    set_default_value(SYNTHESIZABLE ${LOGIC_SYNTHESIZABLE})
    set_default_value(OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}")

    set_realpath(PATHS)
    set_realpath(SOURCES)
    set_realpath(INCLUDES)
    set_realpath(OUTPUT_DIRECTORY)
    set_realpath(MODELSIM_COMMAND_FILES)
    set_realpath(MODELSIM_COMMAND_FILES_VHDL)
    set_realpath(MODELSIM_COMMAND_FILES_VERILOG)
    set_realpath(MODELSIM_COMMAND_FILES_SYSTEMVERILOG)

    set(compiler_ids
        Verilator
        ModelSim
        Quartus
        Vivado
    )

    set(target_depends "")

    foreach (compiler_id ${compiler_ids})
        if (CMAKE_SystemVerilog_COMPILER_ID MATCHES ${compiler_id} OR
                CMAKE_Verilog_COMPILER_ID MATCHES ${compiler_id} OR
                CMAKE_VLOGIC_COMPILER_ID MATCHES ${compiler_id})
            if (compiler_id MATCHES ModelSim)
                logic_add_target_modelsim(target_depends)
            endif()
        endif()
    endforeach()

    add_custom_target(${ARG_TARGET}
        DEPENDS
            ${ARG_PATHS}
            ${ARG_INCLUDES}
            ${ARG_SOURCES}
            ${ARG_MODELSIM_COMMAND_FILES}
            ${ARG_MODELSIM_COMMAND_FILES_VHDL}
            ${ARG_MODELSIM_COMMAND_FILES_VERILOG}
            ${ARG_MODELSIM_COMMAND_FILES_SYSTEMVERILOG}
            ${target_depends}
    )

    if (ARG_DEPENDS)
        add_dependencies(${ARG_TARGET} ${ARG_DEPENDS})
    endif()

    foreach (argument ${one_value_arguments} ${multi_value_arguments})
        set_target_properties(${ARG_TARGET} PROPERTIES
            LOGIC_${argument} "${ARG_${argument}}"
        )
    endforeach()
endfunction()
