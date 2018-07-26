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

if (COMMAND _add_quartus_simulation_files)
    return()
endif()

function(_add_quartus_simulation_files)
    if (NOT QUARTUS_FOUND)
        return()
    endif()

    set(hdl_sources "")
    set(mentor_sources "")

    file(GLOB sources "${QUARTUS_DIR}/eda/sim_lib/*.v")
    list(APPEND hdl_sources ${sources})

    file(GLOB sources "${QUARTUS_DIR}/eda/sim_lib/*.sv")
    list(APPEND hdl_sources ${sources})

    file(GLOB sources "${QUARTUS_DIR}/eda/sim_lib/mentor/*.v")
    list(APPEND mentor_sources ${sources})

    file(GLOB sources "${QUARTUS_DIR}/eda/sim_lib/mentor/*.sv")
    list(APPEND mentor_sources ${sources})

    foreach (hdl_source ${hdl_sources})
        add_hdl_source("${hdl_source}"
            SYNTHESIZABLE FALSE
            MODELSIM_LINT FALSE
            MODELSIM_PEDANTICERRORS FALSE
            MODELSIM_WARNING_AS_ERROR FALSE
            VERILATOR_CONFIGURATIONS
                "lint_off -file \"${hdl_source}\""
                "lint_off -msg STMTDLY -file \"${hdl_source}\""
        )
    endforeach()

    foreach (hdl_source ${mentor_sources})
        if (hdl_source MATCHES _for_vhdl)
            continue()
        endif()

        add_hdl_source("${hdl_source}"
            SYNTHESIZABLE FALSE
            MODELSIM_LINT FALSE
            MODELSIM_PEDANTICERRORS FALSE
            MODELSIM_WARNING_AS_ERROR FALSE
            COMPILE ModelSim
            VERILATOR_CONFIGURATIONS
                "lint_off -file \"${hdl_source}\""
                "lint_off -msg STMTDLY -file \"${hdl_source}\""
            MODELSIM_SUPPRESS
                2083
                2186
                2263
                2576
                2583
                2600
                2633
                2697
        )
    endforeach()
endfunction()

_add_quartus_simulation_files()
