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

if (COMMAND add_hdl_source)
    return()
endif()

find_package(ModelSim)
find_package(SystemC REQUIRED COMPONENTS SCV UVM)
find_package(Verilator)

include(CMakeParseArguments)

set(HDL_TARGETS "" CACHE INTERNAL "RTL targets" FORCE)

set(VERILATOR_CONFIGURATION_FILE
    ${CMAKE_CURRENT_LIST_DIR}/VerilatorConfig.cmake.in
    CACHE INTERNAL "Verilator configuration file" FORCE)

file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/output)

if (MODELSIM_FOUND)
    set(MODELSIM_RUN_TCL
        ${CMAKE_CURRENT_LIST_DIR}/../scripts/modelsim_run.tcl
        CACHE INTERNAL "ModelSim run script" FORCE)

    file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/modelsim)
    file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/modelsim/.modules)

    if (NOT EXISTS ${CMAKE_BINARY_DIR}/modelsim/work/_info)
        execute_process(COMMAND ${MODELSIM_VLIB} work
            WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/modelsim OUTPUT_QUIET)
    endif()

    if (NOT EXISTS ${CMAKE_BINARY_DIR}/modelsim/modelsim.ini)
        execute_process(COMMAND ${MODELSIM_VMAP} work work
            WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/modelsim OUTPUT_QUIET)
    endif()

    if (NOT TARGET modelsim-compile-all)
        add_custom_target(modelsim-compile-all ALL)
    endif()
endif()

if (VERILATOR_FOUND)
    file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/verilator/.coverage)
    file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/verilator/.configs)

    add_custom_target(verilator-coverage
        ${VERILATOR_COVERAGE_EXECUTABLE}
            --annotate-all
            --annotate ${CMAKE_BINARY_DIR}/verilator/.coverage
            ${CMAKE_BINARY_DIR}/output/*.dat
    )

    if (NOT TARGET verilator-compile-all)
        add_custom_target(verilator-compile-all ALL)
    endif()

    if (NOT TARGET verilator-analysis-all)
        add_custom_target(verilator-analysis-all)
    endif()
endif()

function(get_hdl_depends hdl_target hdl_depends_var)
    set(hdl_depends "")

    get_target_property(hdl_target_depends ${hdl_target} HDL_DEPENDS)

    foreach (hdl_target_depend ${hdl_target_depends})
        set(hdl_depends_next)

        get_hdl_depends(${hdl_target_depend} depends)

        list(APPEND hdl_depends ${hdl_target_depend})
        list(APPEND hdl_depends ${depends})
    endforeach()

    list(REMOVE_DUPLICATES hdl_depends)

    set(${hdl_depends_var} ${hdl_depends} PARENT_SCOPE)
endfunction()

function(add_hdl_modelsim hdl_target)
    if (NOT MODELSIM_FOUND)
        return()
    endif()

    set(modelsim_compiler)
    set(modelsim_flags "")

    get_target_property(hdl_type ${hdl_target} HDL_TYPE)
    if (hdl_type MATCHES SystemVerilog)
        set(modelsim_compiler ${MODELSIM_VLOG})
    elseif (hdl_type MATCHES Verilog)
        set(modelsim_compiler ${MODELSIM_VLOG})
    elseif (hdl_type MATCHES VHDL)
        set(modelsim_compiler ${MODELSIM_VCOM})
    else()
        return()
    endif()

    get_target_property(hdl_option ${hdl_target} HDL_MODELSIM_LINT)
    if (hdl_option)
        list(APPEND modelsim_flags -lint)
    endif()

    get_target_property(hdl_option ${hdl_target} HDL_MODELSIM_PEDANTICERRORS)
    if (hdl_option)
        list(APPEND modelsim_flags -pedanticerrors)
    endif()

    get_target_property(hdl_library ${hdl_target} HDL_LIBRARY)
    if (NOT hdl_library)
        set(hdl_library ${hdl_target})
    endif()

    list(APPEND modelsim_flags -work ${hdl_library})

    if (hdl_type MATCHES Verilog)
        if (hdl_type MATCHES SystemVerilog)
            list(APPEND modelsim_flags -sv)
        endif()

        get_target_property(hdl_defines ${hdl_target} HDL_DEFINES)
        foreach (hdl_define ${hdl_defines})
            list(APPEND modelsim_flags +define+${hdl_define})
        endforeach()

        get_target_property(hdl_includes ${hdl_target} HDL_INCLUDES)
        foreach (hdl_include ${hdl_includes})
            if (CYGWIN)
                execute_process(COMMAND cygpath -m ${hdl_include}
                    OUTPUT_VARIABLE hdl_include
                    OUTPUT_STRIP_TRAILING_WHITESPACE)
            endif()

            list(APPEND modelsim_flags +incdir+${hdl_include})
        endforeach()
    elseif (hdl_type MATCHES VHDL)
        list(APPEND modelsim_flags -2008)
    endif()

    if (NOT EXISTS ${CMAKE_BINARY_DIR}/modelsim/${hdl_library})
        execute_process(COMMAND ${MODELSIM_VLIB} ${hdl_library}
            WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/modelsim OUTPUT_QUIET)
    endif()

    get_target_property(hdl_source ${hdl_target} HDL_SOURCE)
    set(modelsim_source ${hdl_source})

    if (CYGWIN)
        execute_process(COMMAND cygpath -m ${hdl_source}
            OUTPUT_VARIABLE modelsim_source
            OUTPUT_STRIP_TRAILING_WHITESPACE)
    endif()

    get_target_property(modelsim_depends ${hdl_target} HDL_DEPENDS)

    set(modelsim_libraries ${hdl_library})

    foreach (modelsim_depend ${modelsim_depends})
        get_target_property(modelsim_library ${modelsim_depend} HDL_LIBRARY)
        if (NOT modelsim_library)
            set(modelsim_library ${modelsim_depend})
        endif()

        list(APPEND modelsim_libraries ${modelsim_library})
    endforeach()

    list(REMOVE_DUPLICATES modelsim_libraries)

    foreach (modelsim_library ${modelsim_libraries})
        set(modelsim_flags ${modelsim_flags} -L ${modelsim_library})
    endforeach()

    add_custom_command(
        OUTPUT
            ${CMAKE_BINARY_DIR}/modelsim/.modules/${hdl_target}
        COMMAND
            ${modelsim_compiler} ${modelsim_flags} ${modelsim_source}
        COMMAND
            ${CMAKE_COMMAND} -E touch ./.modules/${hdl_target}
        DEPENDS
            ${hdl_source} ${modelsim_depends}
        WORKING_DIRECTORY
            ${CMAKE_BINARY_DIR}/modelsim
        COMMENT
            "ModelSim compiling HDL: ${hdl_target}"
    )

    add_custom_target(modelsim-compile-${hdl_target}
        DEPENDS ${CMAKE_BINARY_DIR}/modelsim/.modules/${hdl_target})

    add_dependencies(${hdl_target} modelsim-compile-${hdl_target})
    add_dependencies(modelsim-compile-all modelsim-compile-${hdl_target})
endfunction()

function(add_hdl_verilator hdl_target)
    if (NOT VERILATOR_FOUND)
        return()
    endif()

    set(options)

    set(one_value_arguments
        PREFIX
        ANALYSIS
        COMPILE
    )

    set(multi_value_arguments
        DEFINES
        PARAMETERS
    )

    cmake_parse_arguments(ARG "${options}" "${one_value_arguments}"
        "${multi_value_arguments}" ${ARGN})

    get_target_property(verilator_analysis ${hdl_target} HDL_VERILATOR_ANALYSIS)
    get_target_property(verilator_compile ${hdl_target} HDL_VERILATOR_COMPILE)

    if (ARG_ANALYSIS)
        set(verilator_analysis ${ARG_ANALYSIS})
    endif()

    if (ARG_COMPILE)
        set(verilator_compile ${ARG_COMPILE})
    endif()

    if (verilator_compile)
        set(verilator_analysis TRUE)
    endif()

    if (NOT verilator_analysis AND NOT verilator_compile)
        return()
    endif()

    set(verilator_sources "")
    set(verilator_defines "")
    set(verilator_includes "")
    set(verilator_parameters "")
    set(verilator_configurations "")

    list(APPEND verilator_defines ${ARG_DEFINES})
    list(APPEND verilator_parameters ${ARG_PARAMETERS})

    get_hdl_depends(${hdl_target} hdl_depends)

    foreach (hdl_depend ${hdl_depends} ${hdl_target})
        get_target_property(source ${hdl_depend} HDL_SOURCE)
        list(APPEND verilator_sources ${source})

        get_target_property(defines ${hdl_depend} HDL_DEFINES)
        list(APPEND verilator_defines ${defines})

        get_target_property(includes ${hdl_depend} HDL_INCLUDES)
        list(APPEND verilator_includes ${includes})

        get_target_property(configs ${hdl_depend} HDL_VERILATOR_CONFIGURATIONS)
        list(APPEND verilator_configurations ${configs})
    endforeach()

    list(REMOVE_DUPLICATES verilator_defines)
    list(REMOVE_DUPLICATES verilator_includes)
    list(REMOVE_DUPLICATES verilator_parameters)
    list(REMOVE_DUPLICATES verilator_configurations)

    set(verilator_configuration_file
        ${CMAKE_BINARY_DIR}/verilator/.configs/${hdl_target}.vlt)

    set(verilator_config "")
    foreach (config ${verilator_configurations})
        set(verilator_config "${verilator_config}${config}\n")
    endforeach()

    configure_file(${VERILATOR_CONFIGURATION_FILE}
        ${verilator_configuration_file})

    get_target_property(hdl_name ${hdl_target} HDL_NAME)

    set(verilator_flags "")

    list(APPEND verilator_flags --top-module ${hdl_name})

    foreach (verilator_parameter ${verilator_parameters})
        list(APPEND verilator_parameters -G${verilator_parameter})
    endforeach()

    foreach (verilator_define ${verilator_defines})
        list(APPEND verilator_flags -D${verilator_define})
    endforeach()

    foreach (verilator_include ${verilator_includes})
        list(APPEND verilator_flags -I${verilator_include})
    endforeach()

    list(APPEND verilator_flags ${verilator_configuration_file})
    list(APPEND verilator_flags ${verilator_sources})

    set(verilator_target ${hdl_target})

    if (ARG_PREFIX)
        set(verilator_target ${ARG_PREFIX})
    endif()

    if (verilator_analysis AND
            NOT TARGET verilator-analysis-${verilator_target})
        set(analysis_flags "")
        list(APPEND analysis_flags -Wall)
        list(APPEND analysis_flags --lint-only)

        add_custom_target(verilator-analysis-${verilator_target}
                ${VERILATOR_EXECUTABLE}
                ${analysis_flags}
                ${verilator_flags}
            DEPENDS
                ${verilator_sources}
                ${verilator_includes}
                ${verilator_configuration_file}
        )

        add_dependencies(verilator-analysis-all
            verilator-analysis-${verilator_target})

        if (TARGET ${hdl_target})
            add_dependencies(${hdl_target}
                verilator-analysis-${verilator_target})
        endif()
    endif()

    if (verilator_compile AND NOT TARGET verilator-compile-${verilator_target})
        set(compile_flags "")

        list(APPEND compile_flags --sc)
        list(APPEND compile_flags -O2)
        list(APPEND compile_flags -Wall)
        list(APPEND compile_flags --trace)
        list(APPEND compile_flags --coverage)
        list(APPEND compile_flags --prefix ${verilator_target})
        list(APPEND compile_flags -Mdir .)

        if (CMAKE_CXX_COMPILER_ID MATCHES GNU OR
                CMAKE_CXX_COMPILER_ID MATCHES Clang)
            set(flags
                -std=c++11
                -O2
                -fdata-sections
                -ffunction-sections
            )

            list(APPEND compile_flags -CFLAGS '${flags}')
        endif()

        set(verilator_output_directory
            ${CMAKE_BINARY_DIR}/verilator/${verilator_target})

        file(MAKE_DIRECTORY ${verilator_output_directory})

        set(verilator_library ${verilator_target}__ALL.a)

        add_custom_command(
            OUTPUT
                ${verilator_output_directory}/${verilator_library}
            COMMAND
                ${VERILATOR_EXECUTABLE}
            ARGS
                ${compile_flags}
                ${verilator_flags}
            COMMAND
                $(MAKE)
            ARGS
                -f ${verilator_target}.mk
            DEPENDS
                ${verilator_depends}
                ${verilator_sources}
                ${verilator_includes}
                ${verilaotr_configuration_file}
            WORKING_DIRECTORY
                ${verilator_output_directory}
            COMMENT
                "Creating SystemC ${verilator_target} module"
        )

        add_custom_target(verilator-compile-${verilator_target}
            DEPENDS ${verilator_output_directory}/${verilator_library})

        add_dependencies(verilator-compile-all
            verilator-compile-${verilator_target})

        if (TARGET ${hdl_target})
            add_dependencies(${hdl_target}
                verilator-compile-${verilator_target})
        endif()

        add_library(verilated_${verilator_target} STATIC IMPORTED)

        add_dependencies(verilated_${verilator_target}
            verilator-compile-${verilator_target})

        set_target_properties(verilated_${verilator_target} PROPERTIES
            IMPORTED_LOCATION
                ${verilator_output_directory}/${verilator_library}
        )

        set(module_libraries
            verilated_${verilator_target}
            verilated
            ${SYSTEMC_LIBRARIES}
        )

        set(module_include_directories
            ${VERILATOR_INCLUDE_DIR}
            ${SYSTEMC_INCLUDE_DIRS}
            ${verilator_output_directory}
        )

        set_target_properties(${verilator_target} PROPERTIES
            LIBRARIES "${module_libraries}"
            INCLUDE_DIRECTORIES "${module_include_directories}"
        )
    endif()
endfunction()

function(add_hdl_source hdl_source_or_target)
    set(options)

    set(one_value_arguments
        NAME
        TYPE
        SOURCE
        LIBRARY
        SYNTHESIZABLE
        MODELSIM_LINT
        MODELSIM_PEDANTICERRORS
        VERILATOR_ANALYSIS
        VERILATOR_COMPILE
    )

    set(multi_value_arguments
        DEPENDS
        DEFINES
        INCLUDES
        VERILATOR_CONFIGURATIONS
    )

    cmake_parse_arguments(ARG "${options}" "${one_value_arguments}"
        "${multi_value_arguments}" ${ARGN})

    if (NOT DEFINED ARG_SYNTHESIZABLE)
        set(ARG_SYNTHESIZABLE FALSE)
    endif()

    if (NOT DEFINED ARG_MODELSIM_LINT)
        set(ARG_MODELSIM_LINT TRUE)
    endif()

    if (NOT DEFINED ARG_MODELSIM_PEDANTICERRORS)
        set(ARG_MODELSIM_PEDANTICERRORS TRUE)
    endif()

    if (NOT DEFINED ARG_VERILATOR_ANALYSIS)
        set(ARG_VERILATOR_ANALYSIS FALSE)
    endif()

    if (NOT DEFINED ARG_VERILATOR_COMPILE)
        set(ARG_VERILATOR_COMPILE FALSE)
    endif()

    if (DEFINED HDL_LIBRARY)
        set(ARG_LIBRARY ${HDL_LIBRARY})
    endif()

    if (DEFINED HDL_SYNTHESIZABLE)
        set(ARG_SYNTHESIZABLE ${HDL_SYNTHESIZABLE})
    endif()

    set(ARG_DEPENDS ${HDL_DEPENDS} ${ARG_DEPENDS})
    set(ARG_DEFINES ${HDL_DEFINES} ${ARG_DEFINES})
    set(ARG_INCLUDES ${HDL_INCLUDES} ${ARG_INCLUDES})

    if (ARG_DEPENDS)
        list(REMOVE_DUPLICATES ARG_DEPENDS)
    endif()

    if (ARG_DEFINES)
        list(REMOVE_DUPLICATES ARG_DEFINES)
    endif()

    if (ARG_INCLUDES)
        list(REMOVE_DUPLICATES ARG_INCLUDES)
    endif()

    set(arg_includes "")

    foreach (arg_include ${ARG_INCLUDES})
        get_filename_component(arg_include ${arg_include} REALPATH)
        list(APPEND arg_includes ${arg_include})
    endforeach()

    set(ARG_INCLUDES ${arg_includes})

    if (NOT ARG_SOURCE)
        get_filename_component(hdl_source ${hdl_source_or_target} REALPATH)
        if (EXISTS ${hdl_source})
            set(ARG_SOURCE ${hdl_source})
        endif()
    endif()

    if (NOT ARG_SOURCE)
        message(FATAL_ERROR "HDL source is not defined")
    endif()

    get_filename_component(ARG_SOURCE ${ARG_SOURCE} REALPATH)

    if (NOT EXISTS ${ARG_SOURCE})
        message(FATAL_ERROR "HDL source doesn't exist: ${ARG_SOURCE}")
    endif()

    if (NOT ARG_NAME)
        get_filename_component(ARG_NAME ${ARG_SOURCE} NAME_WE)
    endif()

    if (NOT ARG_TYPE)
        if (ARG_SOURCE MATCHES .sv)
            set(ARG_TYPE SystemVerilog)
        elseif (ARG_SOURCE MATCHES .vhd)
            set(ARG_TYPE VHDL)
        elseif (ARG_SOURCE MATCHES .v)
            set(ARG_TYPE Verilog)
        elseif (ARG_SOURCE MATCHES .qsys)
            set(ARG_TYPE Qsys)
        elseif (ARG_SOURCE MATCHES .ip)
            set(ARG_TYPE IP)
        elseif (ARG_SOURCE MATCHES .tcl)
            set(ARG_TYPE Tcl)
        endif()
    endif()

    get_filename_component(hdl_target ${hdl_source_or_target} NAME_WE)

    if (NOT TARGET ${hdl_target})
        add_custom_target(${hdl_target})
    else()
        message(FATAL_ERROR "Target already exists."
            " Set different target name: "
            " add_hdl_source(<target_name> SOURCE <file> ...)")
    endif()

    set_target_properties(${hdl_target} PROPERTIES
        HDL_NAME ${ARG_NAME}
        HDL_TYPE ${ARG_TYPE}
        HDL_SOURCE ${ARG_SOURCE}
        HDL_LIBRARY ${ARG_LIBRARY}
        HDL_DEPENDS "${ARG_DEPENDS}"
        HDL_DEFINES "${ARG_DEFINES}"
        HDL_INCLUDES "${ARG_INCLUDES}"
        HDL_SYNTHESIZABLE ${ARG_SYNTHESIZABLE}
        HDL_MODELSIM_LINT ${ARG_MODELSIM_LINT}
        HDL_MODELSIM_PEDANTICERRORS ${ARG_MODELSIM_PEDANTICERRORS}
        HDL_VERILATOR_COMPILE ${ARG_VERILATOR_COMPILE}
        HDL_VERILATOR_ANALYSIS ${ARG_VERILATOR_ANALYSIS}
        HDL_VERILATOR_CONFIGURATIONS "${ARG_VERILATOR_CONFIGURATIONS}"
    )

    if (ARG_DEPENDS)
        add_dependencies(${hdl_target} ${ARG_DEPENDS})
    endif()

    set(HDL_TARGETS ${HDL_TARGETS} ${hdl_target}
        CACHE INTERNAL "HDL targets" FORCE)

    add_hdl_modelsim(${hdl_target})
    add_hdl_verilator(${hdl_target})
endfunction()

function(add_hdl_systemc target_name)
    add_hdl_verilator(${target_name}
        COMPILE TRUE
        ANALYSIS TRUE
        ${ARGN}
    )
endfunction()

function(add_hdl_test test_name)
    if (MODELSIM_FOUND)
        set(modelsim_waveform ${CMAKE_BINARY_DIR}/output/${test_name}.wlf)

        if (CYGWIN)
            execute_process(COMMAND cygpath -m ${MODELSIM_RUN_TCL}
                OUTPUT_VARIABLE MODELSIM_RUN_TCL
                OUTPUT_STRIP_TRAILING_WHITESPACE)

            execute_process(COMMAND cygpath -m ${modelsim_waveform}
                OUTPUT_VARIABLE modelsim_waveform
                OUTPUT_STRIP_TRAILING_WHITESPACE)
        endif()

        set(hdl_depends "")
        set(hdl_libraries "")
        set(modelsim_flags "")

        list(APPEND modelsim_flags -c)
        list(APPEND modelsim_flags -wlf ${modelsim_waveform})
        list(APPEND modelsim_flags -do ${MODELSIM_RUN_TCL})

        get_hdl_depends(${test_name} hdl_depends)

        foreach (hdl_name ${hdl_depends} ${test_name})
            get_target_property(hdl_library ${hdl_name} HDL_LIBRARY)
            list(APPEND hdl_libraries ${hdl_library})
        endforeach()

        list(REMOVE_DUPLICATES hdl_libraries)

        foreach (hdl_library ${hdl_libraries})
            list(APPEND modelsim_flags -L ${hdl_library})
        endforeach()

        add_test(NAME ${test_name}
            COMMAND ${MODELSIM_VSIM} ${modelsim_flags} ${test_name}
            WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/modelsim
        )
    endif()
endfunction()
