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

if (COMMAND set_hdl_path)
    return()
endif()

function(set_hdl_path variable path)
    get_filename_component(path "${path}" REALPATH)

    if (CYGWIN)
        execute_process(
            COMMAND
                cygpath -m "${path}"
            OUTPUT_VARIABLE
                path
            OUTPUT_STRIP_TRAILING_WHITESPACE
        )
    endif()

    set(${variable} "${path}" PARENT_SCOPE)
endfunction()
