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

if (COMMAND add_hdl_source)
    return()
endif()

include(AddHDLQsys)
include(AddHDLVivado)
include(AddHDLQuartus)
include(AddHDLModelSim)
include(AddHDLVerilator)

function(add_hdl_source hdl_file)
    set(one_value_arguments
        NAME
        TYPE
        SOURCE
        TARGET
        PACKAGE
        SYNTHESIZABLE
        MODELSIM_LINT
        MODELSIM_PEDANTICERRORS
        MODELSIM_WARNING_AS_ERROR
        VERILATOR_ALL_WARNINGS
        VERILATOR_LINT_WARNINGS
        VERILATOR_STYLE_WARNINGS
        VERILATOR_FATAL_WARNINGS
        OUTPUT_LIBRARIES
        OUTPUT_INCLUDES
        OUTPUT_WORKING_DIRECTORY
    )

    set(multi_value_arguments
        COMPILE
        COMPILE_EXCLUDE
        DEFINES
        DEPENDS
        INCLUDES
        ANALYSIS
        SOURCES
        LIBRARIES
        PARAMETERS
        FILES
        MIF_FILES
        INPUT_FILES
        MODELSIM_FLAGS
        MODELSIM_SOURCES
        MODELSIM_DEPENDS
        MODELSIM_SUPPRESS
        MODELSIM_VLOG_FILES
        MODELSIM_VCOM_FILES
        VERILATOR_FILES
        VERILATOR_CONFIGURATIONS
        QUARTUS_IP_FILES
        QUARTUS_SDC_FILES
        QUARTUS_SPD_FILES
        QUARTUS_QSYS_FILES
        QUARTUS_QSYS_INPUTS
        QUARTUS_QSYS_TCL_FILES
    )

    cmake_parse_arguments(ARG "" "${one_value_arguments}"
        "${multi_value_arguments}" ${ARGN})

    macro(set_default_value name value)
        if (NOT DEFINED ARG_${name})
            set(ARG_${name} ${value})
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

    if (NOT hdl_file)
        message(FATAL_ERROR "HDL file not provided as first argument")
    endif()

    get_filename_component(hdl_file "${hdl_file}" REALPATH)

    if (NOT EXISTS "${hdl_file}")
        message(FATAL_ERROR "HDL file doesn't exist: ${hdl_file}")
    endif()

    get_filename_component(hdl_name "${hdl_file}" NAME_WE)

    set_default_value(NAME ${hdl_name})
    set_default_value(SOURCE ${hdl_file})
    set_default_value(SOURCES "${ARG_UNPARSED_ARGUMENTS}")
    set_default_value(PACKAGE FALSE)
    set_default_value(COMPILE ModelSim Quartus)
    set_default_value(ANALYSIS FALSE)
    set_default_value(SYNTHESIZABLE FALSE)
    set_default_value(MODELSIM_LINT TRUE)
    set_default_value(MODELSIM_PEDANTICERRORS TRUE)
    set_default_value(MODELSIM_WARNING_AS_ERROR TRUE)
    set_default_value(VERILATOR_ALL_WARNINGS TRUE)
    set_default_value(VERILATOR_LINT_WARNINGS TRUE)
    set_default_value(VERILATOR_STYLE_WARNINGS TRUE)
    set_default_value(VERILATOR_FATAL_WARNINGS TRUE)

    if (DEFINED HDL_SYNTHESIZABLE)
        set(ARG_SYNTHESIZABLE ${HDL_SYNTHESIZABLE})
    endif()

    if (DEFINED ARG_ANALYSIS AND ARG_ANALYSIS STREQUAL "TRUE")
        set(ARG_ANALYSIS ALL)
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

    set_realpath(SOURCES)
    set_realpath(INCLUDES)
    set_realpath(MIF_FILES)
    set_realpath(INPUT_FILES)
    set_realpath(QUARTUS_IP_FILES)
    set_realpath(QUARTUS_SDC_FILES)
    set_realpath(QUARTUS_QSYS_FILES)
    set_realpath(QUARTUS_QSYS_INPUTS)
    set_realpath(QUARTUS_QSYS_TCL_FILES)
    set_realpath(VERILATOR_FILES)
    set_realpath(MODELSIM_SOURCES)
    set_realpath(MODELSIM_VCOM_FILES)
    set_realpath(MODELSIM_VLOG_FILES)

    foreach (quartus_file ${ARG_QUARTUS_IP_FILES} ${ARG_QUARTUS_QSYS_TCL_FILES}
            ${ARG_QUARTUS_QSYS_FILES})
        get_filename_component(name "${quartus_file}" NAME_WE)

        add_quartus_file("${quartus_file}")
        list(APPEND ARG_DEPENDS "${name}")
    endforeach()

    if (NOT ARG_TYPE)
        if (ARG_SOURCE MATCHES "\.sv$")
            set(ARG_TYPE SystemVerilog)
        elseif (ARG_SOURCE MATCHES "\.vhd$")
            set(ARG_TYPE VHDL)
        elseif (ARG_SOURCE MATCHES "\.v$")
            set(ARG_TYPE Verilog)
        elseif (ARG_SOURCE MATCHES "\.qsys$")
            set(ARG_TYPE Qsys)
        elseif (ARG_SOURCE MATCHES "\.ip$")
            set(ARG_TYPE IP)
        elseif (ARG_SOURCE MATCHES "\.tcl$")
            set(ARG_TYPE Tcl)
        else()
            message(FATAL_ERROR "HDL type is unknown for file ${ARG_SOURCE}")
        endif()
    endif()

    if (TARGET ${ARG_NAME})
        message(FATAL_ERROR "Target name ${ARG_NAME} already exists!")
    endif()

    add_custom_target(${ARG_NAME}
        DEPENDS
            ${ARG_FILES}
            ${ARG_SOURCE}
            ${ARG_SOURCES}
            ${ARG_INCLUDES}
            ${ARG_MIF_FILES}
            ${ARG_INPUT_FILES}
            ${ARG_QUARTUS_IP_FILES}
            ${ARG_QUARTUS_SDC_FILES}
            ${ARG_QUARTUS_SPD_FILES}
            ${ARG_QUARTUS_QSYS_FILES}
            ${ARG_QUARTUS_QSYS_INPUTS}
            ${ARG_QUARTUS_QSYS_TCL_FILES}
            ${ARG_VERILATOR_FILES}
            ${ARG_MODELSIM_VCOM_FILES}
            ${ARG_MODELSIM_VLOG_FILES}
        COMMENT
            "Generating artifacts for ${ARG_NAME} target"
    )

    foreach (argument ${one_value_arguments} ${multi_value_arguments})
        set_target_properties(${ARG_NAME} PROPERTIES
            HDL_${argument} "${ARG_${argument}}"
        )
    endforeach()

    if (ARG_DEPENDS)
        add_dependencies(${ARG_NAME} ${ARG_DEPENDS})
    endif()

    add_hdl_qsys()
    add_hdl_modelsim()
    add_hdl_verilator()
    add_hdl_quartus()
    add_hdl_vivado()
endfunction()
