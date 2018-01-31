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

if (NOT DEFINED _HDL_CMAKE_ROOT_DIR)
    set(_HDL_CMAKE_ROOT_DIR "${CMAKE_CURRENT_LIST_DIR}" CACHE INTERNAL
        "HDL CMake root directory" FORCE)
endif()

foreach (hdl_entry ${_HDL_LIST})
    unset(_HDL_${hdl_entry} CACHE)
endforeach()

set(_HDL_LIST "" CACHE INTERNAL "" FORCE)

set(_HDL_ONE_VALUE_ARGUMENTS
    NAME
    TYPE
    SOURCE
    TARGET
    LIBRARY
    SYNTHESIZABLE
    MODELSIM_LINT
    MODELSIM_PEDANTICERRORS
    MODELSIM_WARNING_AS_ERROR
    OUTPUT_LIBRARIES
    OUTPUT_INCLUDES
)

set(_HDL_MULTI_VALUE_ARGUMENTS
    COMPILE
    COMPILE_EXCLUDE
    DEFINES
    DEPENDS
    INCLUDES
    ANALYSIS
    SOURCES
    LIBRARIES
    PARAMETERS
    MIF_FILES
    TEXT_FILES
    MODELSIM_FLAGS
    MODELSIM_SUPPRESS
    VERILATOR_CONFIGURATIONS
    QUARTUS_IP_FILES
    QUARTUS_SDC_FILES
    QUARTUS_SPD_FILES
    QUARTUS_QSYS_FILES
    QUARTUS_QSYS_TCL_FILES
)

include(GetHDLProperty)
include(GetHDLDepends)
include(AddHDLSource)
include(AddHDLModelSim)
include(AddHDLQuartus)
include(AddHDLVivado)
include(AddHDLSystemC)
include(AddHDLVerilator)
include(AddHDLUnitTest)
