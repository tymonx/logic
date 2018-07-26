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

if (COMMAND get_hdl_depends)
    return()
endif()

function(get_hdl_depends hdl_target hdl_depends_var)
    set(hdl_depends "")

    get_target_property(target_depends ${hdl_target} HDL_DEPENDS)

    foreach (name ${target_depends})
        if (NOT TARGET ${name})
            message(FATAL_ERROR "HDL target doesn't exist: ${name}")
        endif()

        get_hdl_depends(${name} depends)

        list(APPEND hdl_depends ${depends})
        list(APPEND hdl_depends ${name})
    endforeach()

    list(REMOVE_DUPLICATES hdl_depends)

    set(${hdl_depends_var} ${hdl_depends} PARENT_SCOPE)
endfunction()
