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

include(AddHDLSource)

if (QUARTUS_FOUND)
    set(hdl_modules "")
    set(hdl_sources "")

    file(GLOB sources "${QUARTUS_DIR}/eda/sim_lib/*.v")
    list(APPEND hdl_sources ${sources})

    file(GLOB sources "${QUARTUS_DIR}/eda/sim_lib/*.sv")
    list(APPEND hdl_sources ${sources})

    file(GLOB sources "${QUARTUS_DIR}/eda/sim_lib/mentor/*.v")
    list(APPEND hdl_sources ${sources})

    file(GLOB sources "${QUARTUS_DIR}/eda/sim_lib/mentor/*.sv")
    list(APPEND hdl_sources ${sources})

    foreach (hdl_source ${hdl_sources})
        if (hdl_source MATCHES _for_vhdl)
            continue()
        endif()

        get_filename_component(hdl_module "${hdl_source}" NAME_WE)
        list(APPEND hdl_modules ${hdl_module})
    endforeach()
endif()

function(add_quartus_file file)
    add_hdl_source(${file}
        TYPE
            Qsys
        MODELSIM_LINT
            FALSE
        MODELSIM_PEDANTICERRORS
            FALSE
        MODELSIM_WARNING_AS_ERROR
            FALSE
        VERILATOR_ALL_WARNINGS
            FALSE
        VERILATOR_LINT_WARNINGS
            FALSE
        VERILATOR_STYLE_WARNINGS
            FALSE
        VERILATOR_FATAL_WARNINGS
            FALSE
        DEPENDS
            ${hdl_modules}
    )
endfunction()

function(add_quartus_files)
    foreach (file ${ARGN})
        add_quartus_file("${file}")
    endforeach()
endfunction()
