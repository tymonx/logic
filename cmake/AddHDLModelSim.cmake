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

if (MODELSIM_FOUND)
    file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/modelsim)
    file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/modelsim/.modules)
    file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/modelsim/libraries)

    if (NOT EXISTS "${CMAKE_BINARY_DIR}/modelsim/libraries/work/_info")
        execute_process(COMMAND ${MODELSIM_VLIB} work
            WORKING_DIRECTORY "${CMAKE_BINARY_DIR}/modelsim/libraries"
            OUTPUT_QUIET)
    endif()

    if (NOT EXISTS "${CMAKE_BINARY_DIR}/modelsim/libraries/modelsim.ini")
        set(library_dir "${CMAKE_BINARY_DIR}/modelsim/libraries/work")

        if (CYGWIN)
            execute_process(COMMAND cygpath -m "${library_dir}"
                OUTPUT_VARIABLE library_dir
                OUTPUT_STRIP_TRAILING_WHITESPACE)
        endif()

        execute_process(COMMAND ${MODELSIM_VMAP} work "${library_dir}"
            WORKING_DIRECTORY "${CMAKE_BINARY_DIR}/modelsim/libraries"
            OUTPUT_QUIET)
    endif()

    if (NOT TARGET modelsim-compile-all)
        add_custom_target(modelsim-compile-all ALL)
    endif()
endif()

function(add_hdl_modelsim hdl_name)
    if (NOT MODELSIM_FOUND)
        return()
    endif()

    cmake_parse_arguments(ARG "" "${_HDL_ONE_VALUE_ARGUMENTS}"
        "${_HDL_MULTI_VALUE_ARGUMENTS}" ${_HDL_${hdl_name}} ${ARGN})

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

    set(modelsim_compiler)
    set(modelsim_flags "")

    if (ARG_TYPE MATCHES SystemVerilog)
        set(modelsim_compiler ${MODELSIM_VLOG})
    elseif (ARG_TYPE MATCHES Verilog)
        set(modelsim_compiler ${MODELSIM_VLOG})
    elseif (ARG_TYPE MATCHES VHDL)
        set(modelsim_compiler ${MODELSIM_VCOM})
    else()
        return()
    endif()

    if (ARG_MODELSIM_LINT)
        list(APPEND modelsim_flags -lint)
    endif()

    if (ARG_MODELSIM_PEDANTICERRORS)
        list(APPEND modelsim_flags -pedanticerrors)
    endif()

    if (ARG_MODELSIM_WARNING_AS_ERROR)
        list(APPEND modelsim_flags -warning error)
    endif()

    list(APPEND modelsim_flags -work ${ARG_LIBRARY})

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

    if (ARG_TYPE MATCHES Verilog)
        if (ARG_TYPE MATCHES SystemVerilog)
            list(APPEND modelsim_flags -sv)
        endif()

        foreach (hdl_define ${ARG_DEFINES})
            list(APPEND modelsim_flags +define+${hdl_define})
        endforeach()

        foreach (hdl_include ${ARG_INCLUDES})
            if (CYGWIN)
                execute_process(COMMAND cygpath -m "${hdl_include}"
                    OUTPUT_VARIABLE hdl_include
                    OUTPUT_STRIP_TRAILING_WHITESPACE)
            endif()

            list(APPEND modelsim_flags +incdir+"${hdl_include}")
        endforeach()
    elseif (ARG_TYPE MATCHES VHDL)
        list(APPEND modelsim_flags -2008)
    endif()

    list(APPEND modelsim_flags ${ARG_MODELSIM_FLAGS})

    set(modelsim_modules_dir "${CMAKE_BINARY_DIR}/modelsim/.modules")
    set(modelsim_libraries_dir "${CMAKE_BINARY_DIR}/modelsim/libraries")
    set(modelsim_library_dir "${modelsim_libraries_dir}/${ARG_LIBRARY}")

    if (NOT EXISTS "${modelsim_library_dir}")
        set(library_dir "${modelsim_library_dir}")

        if (CYGWIN)
            execute_process(COMMAND cygpath -m "${library_dir}"
                OUTPUT_VARIABLE library_dir
                OUTPUT_STRIP_TRAILING_WHITESPACE)
        endif()

        execute_process(COMMAND ${MODELSIM_VLIB} ${ARG_LIBRARY}
            WORKING_DIRECTORY "${modelsim_libraries_dir}" OUTPUT_QUIET)

        execute_process(COMMAND ${MODELSIM_VMAP} ${ARG_LIBRARY} "${library_dir}"
            WORKING_DIRECTORY "${modelsim_libraries_dir}" OUTPUT_QUIET)
    endif()

    if (NOT EXISTS "${modelsim_modules_dir}/${ARG_LIBRARY}")
        file(MAKE_DIRECTORY "${modelsim_modules_dir}/${ARG_LIBRARY}")
    endif()

    set(modelsim_sources "")

    foreach (modelsim_source ${ARG_SOURCES} ${ARG_SOURCE})
        if (CYGWIN)
            execute_process(COMMAND cygpath -m "${modelsim_source}"
                OUTPUT_VARIABLE modelsim_source
                OUTPUT_STRIP_TRAILING_WHITESPACE)
        endif()

        list(APPEND modelsim_sources ${modelsim_source})
    endforeach()

    list(REMOVE_DUPLICATES modelsim_sources)

    set(modelsim_depends "")
    set(modelsim_packages "")
    set(modelsim_libraries "")

    foreach (name ${ARG_DEPENDS})
        get_hdl_property(hdl_compile ${name} COMPILE)
        get_hdl_property(hdl_compile_exclude ${name} COMPILE_EXCLUDE)
        get_hdl_property(hdl_library ${name} LIBRARY)
        get_hdl_property(hdl_package ${name} PACKAGE)
        get_hdl_property(hdl_source ${name} SOURCE)

        if (hdl_compile_exclude MATCHES ModelSim)
            continue()
        endif()

        if (NOT hdl_compile MATCHES ALL AND NOT hdl_compile MATCHES ModelSim)
            continue()
        endif()

        if (NOT TARGET modelsim-compile-${hdl_library}-${name})
            message(FATAL_ERROR "HDL doesn't exist ${name}")
        endif()

        if (hdl_package)
            list(APPEND modelsim_packages "${hdl_source}")

            get_hdl_property(hdl_includes ${name} INCLUDES)

            foreach (hdl_include ${hdl_includes})
                list(APPEND modelsim_packages "${hdl_include}")
            endforeach()
        endif()

        list(APPEND modelsim_libraries ${hdl_library})
        list(APPEND modelsim_depends modelsim-compile-${hdl_library}-${name})
    endforeach()

    list(REMOVE_DUPLICATES modelsim_depends)
    list(REMOVE_DUPLICATES modelsim_packages)
    list(REMOVE_DUPLICATES modelsim_libraries)

    foreach (modelsim_library ${modelsim_libraries})
        set(modelsim_flags ${modelsim_flags} -L ${modelsim_library})
    endforeach()

    set(hdl_module_file "${modelsim_modules_dir}/${ARG_LIBRARY}/${ARG_NAME}")

    add_custom_command(
        OUTPUT
            "${hdl_module_file}"
        COMMAND
            ${modelsim_compiler} ${modelsim_flags} ${modelsim_sources}
        COMMAND
            ${CMAKE_COMMAND} -E touch "${hdl_module_file}"
        DEPENDS
            ${ARG_SOURCE}
            ${ARG_SOURCES}
            ${ARG_INCLUDES}
            ${modelsim_depends}
            ${modelsim_packages}
        WORKING_DIRECTORY
            "${modelsim_libraries_dir}"
        COMMENT
            "ModelSim compiling HDL ${ARG_NAME} to ${ARG_LIBRARY} library"
    )

    add_custom_target(modelsim-compile-${ARG_LIBRARY}-${ARG_NAME}
        DEPENDS "${hdl_module_file}"
    )

    if (NOT TARGET modelsim-compile-${ARG_LIBRARY})
        add_custom_target(modelsim-compile-${ARG_LIBRARY})

        add_dependencies(modelsim-compile-all modelsim-compile-${ARG_LIBRARY})
    else()
        get_target_property(prev_target modelsim-compile-${ARG_LIBRARY}
            HDL_PREV_TARGET)

        add_dependencies(modelsim-compile-${ARG_LIBRARY}-${ARG_NAME}
            ${prev_target})
    endif()

    add_dependencies(modelsim-compile-${ARG_LIBRARY}
        modelsim-compile-${ARG_LIBRARY}-${ARG_NAME})

    set_target_properties(modelsim-compile-${ARG_LIBRARY} PROPERTIES
        HDL_PREV_TARGET modelsim-compile-${ARG_LIBRARY}-${ARG_NAME})
endfunction()
