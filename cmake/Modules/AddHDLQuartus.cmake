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

function(add_hdl_quartus)
    get_target_property(analysis ${ARG_NAME} HDL_ANALYSIS)

    if (analysis MATCHES ALL OR analysis MATCHES Quartus)
        set(quartus_defines "")

        list(APPEND quartus_defines SYNTHESIS)

        if (QUARTUS_EDITION MATCHES Pro)
            list(APPEND quartus_defines LOGIC_MODPORT_DISABLED)
        endif()

        add_quartus_project(${ARG_NAME}
            DEFINES
                ${quartus_defines}
        )
    endif()
endfunction()
