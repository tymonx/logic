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
include(GetHDLProperty)

function(add_hdl_vivado hdl_target)
    set(VIVADO_DEFINES ${VIVADO_DEFINES}
        LOGIC_SYNTHESIS
    )

    get_hdl_property(analysis ${hdl_target} ANALYSIS)

    if (analysis MATCHES ALL OR analysis MATCHES Vivado)
        add_vivado_project(${hdl_target})
    endif()
endfunction()
