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

if (COMMAND add_quartus_file)
    return()
endif()

if (NOT DEFINED _HDL_CMAKE_ROOT_DIR)
    set(_HDL_CMAKE_ROOT_DIR "${CMAKE_CURRENT_LIST_DIR}" CACHE INTERNAL
        "HDL CMake root directory" FORCE)
endif()

find_package(Quartus)
find_package(ModelSim)

include(SetHDLPath)

if (NOT TARGET modelsim-compile-all)
    add_custom_target(modelsim-compile-all ALL)
endif()

function(add_quartus_file file)
    set(file_type "")

    if (NOT file)
        message(FATAL_ERROR "Quartus file is not defined")
    endif()

    get_filename_component(file "${file}" REALPATH)
    get_filename_component(name "${file}" NAME_WE)

    if (NOT EXISTS "${file}")
        message(FATAL_ERROR "Quartus file doesn't exist: ${file}")
    endif()

    if (file MATCHES "\\.ip$")
        set(file_type ip)
    elseif (file MATCHES "\\.qsys$")
        set(file_type qsys)
    elseif (file MATCHES "\\.tcl$")
        set(file_type tcl)
    else()
        message(FATAL_ERROR "Quartus file must be IP, Qsys or Tcl file")
    endif()

    set(spd_file "${CMAKE_CURRENT_BINARY_DIR}/${name}/${name}.spd")
    set(qsys_file "${CMAKE_CURRENT_BINARY_DIR}/${name}.${file_type}")

    if (NOT file MATCHES "${qsys_file}")
        add_custom_command(
            OUTPUT
                "${qsys_file}"
            COMMAND
                ${CMAKE_COMMAND}
            ARGS
                -E copy "${file}" "${name}.${file_type}"
            DEPENDS
                "${file}"
            WORKING_DIRECTORY
                "${CMAKE_CURRENT_BINARY_DIR}"
        )
    endif()

    set(entries
        TYPE Qsys
        NAME "${name}"
        SOURCE "${file}"
        LIBRARY "${name}"
        SOURCES ""
        DEPENDS ""
        DEFINES ""
        INCLUDES ""
        COMPILE Quartus ModelSim
        ANALYSIS Quartus ModelSim
        SYNTHESIZABLE TRUE
        QUARTUS_SPD_FILES "${spd_file}"
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

    if (file_type MATCHES tcl)
        set(tcl_file "${qsys_file}")
        set_hdl_path(input_file "${qsys_file}")
        set(qsys_file "${CMAKE_CURRENT_BINARY_DIR}/${name}.ip")

        add_custom_command(
            OUTPUT
                "${qsys_file}"
            COMMAND
                ${QUARTUS_QSYS_SCRIPT}
            ARGS
                --script=${input_file}
            DEPENDS
                "${tcl_file}"
            WORKING_DIRECTORY
                "${CMAKE_CURRENT_BINARY_DIR}"
        )

        set(file_type ip)
    endif()

    set_hdl_path(input_file "${qsys_file}")
    set(modules_dir "${CMAKE_BINARY_DIR}/modelsim/.modules")
    set(modelsim_libraries_dir "${CMAKE_BINARY_DIR}/modelsim/libraries")

    if (NOT EXISTS "${modelsim_libraries_dir}/${name}")
        set_hdl_path(library_dir
            "${CMAKE_BINARY_DIR}/modelsim/libraries/${name}")

        execute_process(COMMAND ${MODELSIM_VLIB} ${name}
            WORKING_DIRECTORY "${modelsim_libraries_dir}" OUTPUT_QUIET)

        execute_process(COMMAND ${MODELSIM_VMAP} ${name} "${library_dir}"
            WORKING_DIRECTORY "${modelsim_libraries_dir}" OUTPUT_QUIET)
    endif()

    if (NOT EXISTS "${modules_dir}/${name}")
        file(MAKE_DIRECTORY "${modules_dir}/${name}")
    endif()

    add_custom_command(
        OUTPUT
            "${spd_file}"
        COMMAND
            ${QUARTUS_QSYS_GENERATE}
        ARGS
            "${input_file}"
            --upgrade-ip-cores
        COMMAND
            ${QUARTUS_QSYS_GENERATE}
        ARGS
            "${input_file}"
            --simulation=VERILOG
        DEPENDS
            "${qsys_file}"
        WORKING_DIRECTORY
            "${CMAKE_CURRENT_BINARY_DIR}"
    )

    add_custom_command(
        OUTPUT
            "${modules_dir}/${name}/${name}"
        COMMAND
            ${CMAKE_COMMAND}
        ARGS
            -DWORK=${name}
            -DSPD_FILE="${spd_file}"
            -DMODELSIM_VCOM="${MODELSIM_VCOM}"
            -DMODELSIM_VLOG="${MODELSIM_VLOG}"
            -DWORKING_DIRECTORY="${CMAKE_BINARY_DIR}/modelsim/libraries"
            -P "${_HDL_CMAKE_ROOT_DIR}/AddQuartusFileSPD.cmake"
        COMMAND
            ${CMAKE_COMMAND}
        ARGS
            -E touch "${modules_dir}/${name}/${name}"
        DEPENDS
            "${spd_file}"
        WORKING_DIRECTORY
            "${CMAKE_BINARY_DIR}/modelsim"
    )

    add_custom_target(modelsim-compile-${name}-${name}
        DEPENDS "${modules_dir}/${name}/${name}"
    )

    if (NOT TARGET modelsim-compile-${name})
        add_custom_target(modelsim-compile-${name})
        add_dependencies(modelsim-compile-all modelsim-compile-${name})
    endif()

    add_dependencies(modelsim-compile-${name}
        modelsim-compile-${name}-${name})
endfunction()

function(add_quartus_files)
    foreach (file ${ARGN})
        add_quartus_file("${file}")
    endforeach()
endfunction()
