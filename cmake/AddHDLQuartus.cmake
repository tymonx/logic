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

if (COMMAND add_hdl_quartus)
    return()
endif()

include(AddQuartusProject)
include(GetHDLProperty)

function(add_hdl_quartus hdl_target)
    set(QUARTUS_DEFINES ${QUARTUS_DEFINES}
        LOGIC_SYNTHESIS
    )

    if (QUARTUS_EDITION MATCHES Pro)
        set(QUARTUS_DEFINES ${QUARTUS_DEFINES}
            LOGIC_MODPORT_DISABLED
        )
    endif()

    get_hdl_property(analysis ${hdl_target} ANALYSIS)

    if (analysis MATCHES ALL OR analysis MATCHES Quartus)
        add_quartus_project(${hdl_target})
    endif()
endfunction()
