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

if (COMMAND logic_add_target_modelsim)
    return()
endif()

set(_CREATE_MODELSIM_LIBRARY
    "${CMAKE_CURRENT_LIST_DIR}/LogicAddTargetModelSimLibrary.cmake"
    CACHE INTERNAL "" FORCE
)

find_package(ModelSim)

include(LogicGetDepends)

function(logic_add_target_modelsim target_depends)
    set(hdl_paths "")
    set(hdl_depends "")
    set(hdl_sources "")
    set(hdl_defines "")
    set(hdl_includes "")
    set(hdl_suppress "")
    set(hdl_libraries "")

    foreach (depend ${ARG_DEPENDS})
        logic_get_depends(${depend} hdl_depends)
    endforeach()

    list(APPEND hdl_depends ${ARG_DEPENDS})
    list(REMOVE_DUPLICATES hdl_depends)

    foreach (hdl_depend ${hdl_depends})
        get_target_property(value ${hdl_depend} LOGIC_OUTPUT_DIRECTORY)
        list(APPEND hdl_paths ${value})

        get_target_property(value ${hdl_depend} LOGIC_NAME)
        list(APPEND hdl_libraries ${value})
    endforeach()

    list(APPEND hdl_paths ${ARG_PATHS})
    list(APPEND hdl_depends ${ARG_DEPENDS})
    list(APPEND hdl_sources ${ARG_SOURCES})
    list(APPEND hdl_defines ${ARG_DEFINES})
    list(APPEND hdl_includes ${ARG_INCLUDES})
    list(APPEND hdl_suppress ${ARG_MODELSIM_SUPPRESS})
    list(APPEND hdl_libraries ${ARG_LIBRARIES})

    list(REMOVE_DUPLICATES hdl_paths)
    list(REMOVE_DUPLICATES hdl_sources)
    list(REMOVE_DUPLICATES hdl_defines)
    list(REMOVE_DUPLICATES hdl_includes)
    list(REMOVE_DUPLICATES hdl_suppress)
    list(REMOVE_DUPLICATES hdl_libraries)

    set(vhdl_sources "")
    set(verilog_sources "")
    set(systemverilog_sources "")

    foreach (hdl_source ${hdl_sources})
        if (hdl_source MATCHES "\\.v$")
            list(APPEND verilog_sources "${hdl_source}")
        elseif (hdl_source MATCHES "\\.sv$")
            list(APPEND systemverilog_sources "${hdl_source}")
        elseif (hdl_source MATCHES "\\.vhdl?$")
            list(APPEND vhdl_sources "${hdl_source}")
        endif()
    endforeach()

    set(commands "")

    macro(set_verilog_commands)
        if (hdl_suppress)
            string(REPLACE ";" "," suppress "${hdl_suppress}")
            list(APPEND commands -suppress ${suppress})
        endif()

        foreach (hdl_path ${hdl_paths})
            list(APPEND commands -Ldir "${hdl_path}")
        endforeach()

        foreach (hdl_library ${hdl_libraries})
            list(APPEND commands -L ${hdl_library})
        endforeach()

        foreach (hdl_define ${hdl_defines})
            list(APPEND commands +define+${hdl_define})
        endforeach()

        foreach (hdl_include ${hdl_includes})
            list(APPEND commands +incdir+"${hdl_include}")
        endforeach()
    endmacro()

    if (CMAKE_SystemVerilog_COMPILER_ID MATCHES ModelSim AND
            systemverilog_sources)
        list(APPEND commands COMMAND
            ${MODELSIM_VLOG}
            -sv
            -work ${ARG_NAME}
        )

        set_verilog_commands()

        foreach (command_file ${ARG_MODELSIM_COMMAND_FILES}
                ${ARG_MODELSIM_COMMAND_FILES_SYSTEMVERILOG})
            list(APPEND commands -f "${command_file}")
        endforeach()

        list(APPEND commands
            ${ARG_MODELSIM_FLAGS}
            ${ARG_MODELSIM_FLAGS_SYSTEMVERILOG}
            ${systemverilog_sources}
        )
    endif()

    if (CMAKE_Verilog_COMPILER_ID MATCHES ModelSim AND verilog_sources)
        list(APPEND commands COMMAND
            ${MODELSIM_VLOG}
            -work ${ARG_NAME}
        )

        set_verilog_commands()

        foreach (command_file ${ARG_MODELSIM_COMMAND_FILES}
                ${ARG_MODELSIM_COMMAND_FILES_VERILOG})
            list(APPEND commands -f "${command_file}")
        endforeach()

        list(APPEND commands
            ${ARG_MODELSIM_FLAGS}
            ${ARG_MODELSIM_FLAGS_VERILOG}
            ${verilog_sources}
        )
    endif()

    if (CMAKE_VHDL_COMPILER_ID MATCHES ModelSim AND vhdl_sources)
        list(APPEND commands COMMAND
            ${MODELSIM_VCOM}
            -work ${ARG_NAME}
        )

        if (hdl_suppress)
            string(REPLACE ";" "," suppress "${hdl_suppress}")
            list(APPEND commands -suppress ${suppress})
        endif()

        foreach (command_file ${ARG_MODELSIM_COMMAND_FILES}
                ${ARG_MODELSIM_COMMAND_FILES_VHDL})
            list(APPEND commands -f "${command_file}")
        endforeach()

        list(APPEND commands
            ${ARG_MODELSIM_FLAGS}
            ${ARG_MODELSIM_FLAGS_VHDL}
            ${vhdl_sources}
        )
    endif()

    add_custom_command(
        OUTPUT
            "${CMAKE_CURRENT_BINARY_DIR}/${ARG_NAME}/_lib.qdb"
        COMMAND
            ${CMAKE_COMMAND}
            -DMODELSIM_VLIB="${MODELSIM_VLIB}"
            -DOUTPUT_DIRECTORY="${ARG_OUTPUT_DIRECTORY}"
            -DNAME="${ARG_NAME}"
            -P "${_CREATE_MODELSIM_LIBRARY}"
        ${commands}
        COMMENT
            "ModelSim compiling ${ARG_NAME}"
        WORKING_DIRECTORY
            "${ARG_OUTPUT_DIRECTORY}"
    )

    set(${target_depends}
        "${CMAKE_CURRENT_BINARY_DIR}/${ARG_NAME}/_lib.qdb"
        PARENT_SCOPE
    )
endfunction()
