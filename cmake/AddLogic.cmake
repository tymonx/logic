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

if (ADD_LOGIC_INCLUDED)
    return()
endif()

set(ADD_LOGIC_INCLUDED TRUE)

include(AddThreads)
include(AddGnuCompiler)
include(AddMsvcCompiler)
include(AddClangCompiler)
include(AddVivadoProject)
include(AddQuartusProject)
include(AddHDL)
include(AddStdOVL)

find_package(SVUnit)
find_package(ModelSim)
find_package(NaturalDocs)
find_package(SystemC REQUIRED COMPONENTS SCV UVM)
find_package(Verilator)
find_package(Vivado)
find_package(Quartus)
find_package(GTest)
find_package(StdOVL)

if (SVUNIT_FOUND)
    add_hdl_source(${SVUNIT_HDL_PACKAGE}
        LIBRARY svunit
        SYNTHESIZABLE FALSE
        INCLUDES "${SVUNIT_INCLUDE_DIR}"
    )
endif()

if (QUARTUS_FOUND)
    file(GLOB VERILOG_SOURCES "${QUARTUS_DIR}/eda/sim_lib/*.v")
    file(GLOB SYSTEMVERILOG_SOURCES "${QUARTUS_DIR}/eda/sim_lib/*.sv")

    foreach (hdl_source ${VERILOG_SOURCES} ${SYSTEMVERILOG_SOURCES})
        get_filename_component(hdl_name "${hdl_source}" NAME_WE)

        add_hdl_source("${hdl_source}"
            LIBRARY intel
            SYNTHESIZABLE FALSE
            MODELSIM_LINT FALSE
            MODELSIM_PEDANTICERRORS FALSE
            MODELSIM_WARNING_AS_ERROR FALSE
            VERILATOR_CONFIGURATIONS
                "lint_off -file \"${hdl_source}\""
                "lint_off -msg STMTDLY -file \"${hdl_source}\""
        )
    endforeach()

    if (MODELSIM_FOUND)
        file(GLOB VERILOG_SOURCES "${QUARTUS_DIR}/eda/sim_lib/mentor/*.v")
        file(GLOB SYSTEMVERILOG_SOURCES "${QUARTUS_DIR}/eda/sim_lib/mentor/*.sv")

        foreach (hdl_source ${VERILOG_SOURCES} ${SYSTEMVERILOG_SOURCES})
            if (hdl_source MATCHES for_vhdl OR
                    hdl_source MATCHES ct1_hssi_atoms_ncrypt OR
                    hdl_source MATCHES tennm_atoms_ncrypt OR
                    hdl_source MATCHES fourteennm_atoms_ncrypt)
                continue()
            endif()

            get_filename_component(hdl_name "${hdl_source}" NAME_WE)

            add_hdl_source("${hdl_source}"
                LIBRARY intel
                SYNTHESIZABLE FALSE
                MODELSIM_LINT FALSE
                MODELSIM_PEDANTICERRORS FALSE
                MODELSIM_WARNING_AS_ERROR FALSE
                COMPILE ModelSim
                VERILATOR_CONFIGURATIONS
                    "lint_off -file \"${hdl_source}\""
                    "lint_off -msg STMTDLY -file \"${hdl_source}\""
            )
        endforeach()
    endif()
endif()
