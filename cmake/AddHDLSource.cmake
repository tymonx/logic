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

include(AddHDLVivado)
include(AddHDLQuartus)
include(AddHDLModelSim)
include(AddHDLVerilator)

function(add_hdl_source hdl_file)
    if (NOT hdl_file)
        message(FATAL_ERROR "HDL file not provided as first argument")
    endif()

    get_filename_component(hdl_file "${hdl_file}" REALPATH)

    if (NOT EXISTS "${hdl_file}")
        message(FATAL_ERROR "HDL file doesn't exist: ${hdl_file}")
    endif()

    get_filename_component(hdl_name "${hdl_file}" NAME_WE)

    cmake_parse_arguments(ARG "" "${_HDL_ONE_VALUE_ARGUMENTS}"
        "${_HDL_MULTI_VALUE_ARGUMENTS}" ${ARGN})

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

    set_default_value(NAME ${hdl_name})
    set_default_value(SOURCE ${hdl_file})
    set_default_value(SOURCES "")
    set_default_value(DEPENDS "")
    set_default_value(DEFINES "")
    set_default_value(INCLUDES "")
    set_default_value(LIBRARIES "")
    set_default_value(LIBRARY work)
    set_default_value(COMPILE ModelSim Quartus)
    set_default_value(ANALYSIS FALSE)
    set_default_value(SYNTHESIZABLE FALSE)
    set_default_value(MODELSIM_LINT TRUE)
    set_default_value(MODELSIM_PEDANTICERRORS TRUE)
    set_default_value(MODELSIM_WARNING_AS_ERROR TRUE)
    set_default_value(MODELSIM_SUPPRESS "")
    set_default_value(VERILATOR_CONFIGURATIONS "")

    if (HDL_LIBRARY)
        set(ARG_LIBRARY ${HDL_LIBRARY})
    endif()

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
    set_realpath(QUARTUS_IP_FILES)
    set_realpath(QUARTUS_SDC_FILES)
    set_realpath(QUARTUS_QSYS_FILES)
    set_realpath(QUARTUS_QSYS_TCL_FILES)

    foreach (quartus_file ${ARG_QUARTUS_IP_FILES} ${ARG_QUARTUS_QSYS_TCL_FILES}
            ${ARG_QUARTUS_QSYS_FILES})
        get_filename_component(name "${quartus_file}" NAME_WE)

        add_quartus_file("${quartus_file}")
        list(APPEND ARG_DEPENDS "${name}")
    endforeach()

    if (NOT ARG_TYPE)
        if (ARG_SOURCE MATCHES .sv)
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

    if (NOT DEFINED _HDL_${ARG_NAME})
        set(hdl_list ${_HDL_LIST})
        list(APPEND hdl_list ${ARG_NAME})
        set(_HDL_LIST "${hdl_list}" CACHE INTERNAL "" FORCE)
    endif()

    set(hdl_entry "")

    foreach (argument ${_HDL_ONE_VALUE_ARGUMENTS})
        list(APPEND hdl_entry "${argument}" "${ARG_${argument}}")
    endforeach()

    foreach (argument ${_HDL_MULTI_VALUE_ARGUMENTS})
        list(APPEND hdl_entry "${argument}" "${ARG_${argument}}")
    endforeach()

    set(_HDL_${ARG_NAME} "${hdl_entry}" CACHE INTERNAL "" FORCE)

    add_hdl_modelsim(${ARG_NAME})
    add_hdl_verilator(${ARG_NAME})
    add_hdl_quartus(${ARG_NAME})
    add_hdl_vivado(${ARG_NAME})
endfunction()
