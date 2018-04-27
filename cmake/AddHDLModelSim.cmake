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

if (COMMAND add_hdl_modelsim)
    return()
endif()

find_package(ModelSim)

if (NOT DEFINED _HDL_CMAKE_ROOT_DIR)
    set(_HDL_CMAKE_ROOT_DIR "${CMAKE_CURRENT_LIST_DIR}" CACHE INTERNAL
        "HDL CMake root directory" FORCE)
endif()

if (MODELSIM_FOUND)
    file(MAKE_DIRECTORY "${CMAKE_BINARY_DIR}/modelsim/libraries")
    file(MAKE_DIRECTORY "${CMAKE_BINARY_DIR}/modelsim/libraries/.placeholders")

    if (NOT EXISTS "${CMAKE_BINARY_DIR}/modelsim/libraries/work/_info")
        execute_process(
            COMMAND
                ${MODELSIM_VLIB}
                work
            WORKING_DIRECTORY
            "${CMAKE_BINARY_DIR}/modelsim/libraries"
            OUTPUT_QUIET
        )
    endif()

    if (NOT EXISTS "${CMAKE_BINARY_DIR}/modelsim/libraries/modelsim.ini")
       execute_process(
            COMMAND
                ${MODELSIM_VMAP}
                work
                "${CMAKE_BINARY_DIR}/modelsim/libraries/work"
            WORKING_DIRECTORY
                "${CMAKE_BINARY_DIR}/modelsim/libraries"
            OUTPUT_QUIET
        )
    endif()

    if (NOT TARGET modelsim-compile-all)
        add_custom_target(modelsim-compile-all ALL)
    endif()
endif()

function(add_hdl_modelsim)
    if (NOT MODELSIM_FOUND)
        return()
    endif()

    if (DEFINED ARG_COMPILE_EXCLUDE)
        if (ARG_COMPILE_EXCLUDE MATCHES ModelSim)
            return()
        endif()
    endif()

    if (DEFINED ARG_COMPILE)
        if (NOT ARG_COMPILE MATCHES ALL AND NOT ARG_COMPILE MATCHES ModelSim)
            return()
        endif()
    endif()

    if (TARGET modelsim-compile-${ARG_NAME})
        message(FATAL_ERROR "ModelSim target ${ARG_NAME} already exist")
    endif()

    if (NOT ARG_TYPE MATCHES Verilog AND NOT ARG_TYPE MATCHES VHDL AND
            NOT ARG_TYPE MATCHES Qsys)
        return()
    endif()

    set(modelsim_libraries_dir "${CMAKE_BINARY_DIR}/modelsim/libraries")
    set(modelsim_library_dir "${modelsim_libraries_dir}/${ARG_NAME}")
    set(modelsim_ini_file "${_HDL_CMAKE_ROOT_DIR}/modelsim.ini")

    set(modelsim_flags "")
    set(modelsim_vcom_flags "")
    set(modelsim_vlog_flags "")

    list(APPEND modelsim_flags -modelsimini "${modelsim_ini_file}")

    if (ARG_TYPE MATCHES SystemVerilog OR ARG_TYPE MATCHES Qsys)
        list(APPEND modelsim_vlog_flags -sv)
    endif()

    foreach (hdl_define ${ARG_DEFINES})
        list(APPEND modelsim_vlog_flags +define+${hdl_define})
    endforeach()

    foreach (hdl_include ${ARG_INCLUDES})
        list(APPEND modelsim_vlog_flags +incdir+"${hdl_include}")
    endforeach()

    list(APPEND modelsim_vcom_flags -2008)

    if (ARG_MODELSIM_LINT)
        list(APPEND modelsim_flags -lint)
    endif()

    if (ARG_MODELSIM_PEDANTICERRORS)
        list(APPEND modelsim_flags -pedanticerrors)
    endif()

    if (ARG_MODELSIM_WARNING_AS_ERROR)
        list(APPEND modelsim_flags -warning error)
    endif()

    list(APPEND modelsim_flags -work ${ARG_NAME})

    if (DEFINED ARG_MODELSIM_SUPPRESS)
        list(LENGTH ARG_MODELSIM_SUPPRESS len)

        if (len GREATER 0)
            list(GET ARG_MODELSIM_SUPPRESS 0 suppress)
            list(REMOVE_AT ARG_MODELSIM_SUPPRESS 0)

            foreach (value ${ARG_MODELSIM_SUPPRESS})
                set(suppress "${suppress},${value}")
            endforeach()

            list(APPEND modelsim_flags -suppress ${suppress})
        endif()
    endif()

    if (ARG_MODELSIM_FLAGS)
        list(APPEND modelsim_flags ${ARG_MODELSIM_FLAGS})
    endif()

    set(modelsim_sources "")
    set(modelsim_depends "")
    set(modelsim_includes "")
    set(modelsim_libraries "")

    list(APPEND modelsim_sources
        ${ARG_MODELSIM_SOURCES}
        ${ARG_SOURCES}
        ${ARG_SOURCE}
    )

    list(APPEND modelsim_includes ${ARG_INCLUDES})

    get_hdl_depends(${ARG_NAME} depends)

    foreach (name ${depends})
        get_target_property(hdl_compile_exclude ${name} HDL_COMPILE_EXCLUDE)

        if (hdl_compile_exclude MATCHES ModelSim)
            continue()
        endif()

        get_target_property(hdl_compile ${name} HDL_COMPILE)

        if (NOT hdl_compile MATCHES ALL AND NOT hdl_compile MATCHES ModelSim)
            continue()
        endif()

        get_target_property(hdl_package ${name} HDL_PACKAGE)

        if (hdl_package)
            get_target_property(hdl_source ${name} HDL_SOURCE)

            list(APPEND modelsim_sources "${hdl_source}")
            list(APPEND modelsim_depends modelsim-compile-${name})

            get_target_property(hdl_includes ${name} HDL_INCLUDES)

            foreach (hdl_include ${hdl_includes})
                list(APPEND modelsim_includes "${hdl_include}")
            endforeach()

            list(APPEND modelsim_libraries ${name})
        endif()
    endforeach()

    list(REMOVE_DUPLICATES modelsim_depends)
    list(REMOVE_DUPLICATES modelsim_sources)
    list(REMOVE_DUPLICATES modelsim_includes)

    if (modelsim_libraries)
        list(APPEND modelsim_flags -Ldir "${CMAKE_BINARY_DIR}/modelsim/libraries")
    endif()

    foreach (modelsim_library ${modelsim_libraries})
        list(APPEND modelsim_flags -L ${modelsim_library})
    endforeach()

    set(modelsim_vcom_sources "")
    set(modelsim_vlog_sources "")

    foreach (modelsim_source ${ARG_SOURCES})
        if (modelsim_source MATCHES "\.s?v$")
            list(APPEND modelsim_vlog_sources "${modelsim_source}")
        elseif (modelsim_source MATCHES "\.vhd$")
            list(APPEND modelsim_vcom_sources "${modelsim_source}")
        endif()
    endforeach()

    get_target_property(modelsim_files ${ARG_NAME} HDL_MODELSIM_VCOM_FILES)
    list(APPEND modelsim_sources ${modelsim_files})

    foreach (modelsim_file ${modelsim_files})
        list(APPEND modelsim_vcom_flags -f ${modelsim_file})
    endforeach()

    get_target_property(modelsim_files ${ARG_NAME} HDL_MODELSIM_VLOG_FILES)
    list(APPEND modelsim_sources ${modelsim_files})

    foreach (modelsim_file ${modelsim_files})
        list(APPEND modelsim_vlog_flags -f ${modelsim_file})
    endforeach()

    if (ARG_TYPE MATCHES Verilog)
        list(APPEND modelsim_vlog_sources "${ARG_SOURCE}")
    elseif (ARG_TYPE MATCHES VHDL)
        list(APPEND modelsim_vcom_sources "${ARG_SOURCE}")
    elseif (ARG_TYPE MATCHES Qsys)
        list(APPEND modelsim_depends qsys-compile-${ARG_NAME})
    endif()

    set(modelsim_commands "")

    if (modelsim_vcom_sources)
        list(APPEND modelsim_commands
            COMMAND
                ${MODELSIM_VCOM}
            ARGS
                ${modelsim_flags}
                ${modelsim_vcom_flags}
                ${modelsim_vcom_sources}
        )
    endif()

    if (modelsim_vlog_sources)
        list(APPEND modelsim_commands
            COMMAND
                ${MODELSIM_VLOG}
            ARGS
                ${modelsim_flags}
                ${modelsim_vlog_flags}
                ${modelsim_vlog_sources}
        )
    endif()

    if (modelsim_commands)
        add_custom_command(
            OUTPUT
                "${modelsim_libraries_dir}/.placeholders/${ARG_NAME}"
            COMMAND
                ${MODELSIM_VLIB}
            ARGS
                ${ARG_NAME}
            COMMAND
                ${CMAKE_COMMAND}
            ARGS
                -E touch
                "${modelsim_libraries_dir}/.placeholders/${ARG_NAME}"
            WORKING_DIRECTORY
                "${modelsim_libraries_dir}"
            COMMENT
                "ModelSim creating library ${ARG_NAME}"
        )

        add_custom_command(
            OUTPUT
                "${modelsim_library_dir}/_info"
                "${modelsim_library_dir}/_vmake"
                "${modelsim_library_dir}/_lib.qdb"
            ${modelsim_commands}
            DEPENDS
                ${modelsim_sources}
                ${modelsim_includes}
                "${modelsim_ini_file}"
                "${modelsim_libraries_dir}/.placeholders/${ARG_NAME}"
            WORKING_DIRECTORY
                "${modelsim_libraries_dir}"
            COMMENT
                "ModelSim compiling ${ARG_NAME}"
        )

        add_custom_target(modelsim-compile-${ARG_NAME}
            DEPENDS
                "${modelsim_library_dir}/_info"
                "${modelsim_library_dir}/_vmake"
                "${modelsim_library_dir}/_lib.qdb"
        )
    else()
        add_custom_target(modelsim-compile-${ARG_NAME})
    endif()

    if (modelsim_depends)
        add_dependencies(modelsim-compile-${ARG_NAME} ${modelsim_depends})
    endif()

    add_dependencies(modelsim-compile-all modelsim-compile-${ARG_NAME})
    add_dependencies(${ARG_NAME} modelsim-compile-${ARG_NAME})
endfunction()
