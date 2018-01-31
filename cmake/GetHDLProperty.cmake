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

if (COMMAND get_hdl_property)
    return()
endif()

include(CMakeParseArguments)

function(get_hdl_property var name property)
    cmake_parse_arguments(ARG "" "${_HDL_ONE_VALUE_ARGUMENTS}"
        "${_HDL_MULTI_VALUE_ARGUMENTS}" ${_HDL_${name}})

    if (DEFINED ARG_${property})
        set(${var} "${ARG_${property}}" PARENT_SCOPE)
    else()
        set(${var} "" PARENT_SCOPE)
    endif()
endfunction()
