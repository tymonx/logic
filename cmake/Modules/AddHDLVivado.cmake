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

if (COMMAND add_hdl_vivado)
    return()
endif()

include(AddVivadoProject)

function(add_hdl_vivado)
    get_target_property(analysis ${ARG_NAME} HDL_ANALYSIS)

    if (analysis MATCHES ALL OR analysis MATCHES Vivado)
        add_vivado_project(${ARG_NAME}
            DEFINES
                SYNTHESIS
        )
    endif()
endfunction()
