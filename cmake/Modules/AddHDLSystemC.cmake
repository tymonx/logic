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

if (COMMAND add_hdl_systemc)
    return()
endif()

function(add_hdl_systemc target_name)
    set(one_value_arguments
        NAME
        TARGET
    )

    set(multi_value_arguments
        DEFINES
        INCLUDES
        PARAMETERS
        VERILATOR_CONFIGURATIONS
    )

    cmake_parse_arguments(ARG "" "${one_value_arguments}"
        "${multi_value_arguments}" ${ARGN})

    set(ARG_COMPILE Verilator)
    set(ARG_ANALYSIS Verilator)
    set(ARG_SYNTHESIZABLE TRUE)

    if (NOT ARG_NAME)
        set(ARG_NAME ${target_name})
    endif()

    if (NOT ARG_TARGET)
        set(ARG_TARGET ${target_name})
    endif()

    add_hdl_verilator()
endfunction()
