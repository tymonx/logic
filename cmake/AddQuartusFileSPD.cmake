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

set(SPD_FILE "" CACHE STRING "SPD file")

if (NOT EXISTS "${SPD_FILE}")
    message(FATAL_ERROR "SPD file doesn't exist: ${SPD_FILE}")
endif()

get_filename_component(dir "${SPD_FILE}" DIRECTORY)
get_filename_component(name "${SPD_FILE}" NAME_WE)

file(READ "${SPD_FILE}" content)
string(REGEX REPLACE "\n" ";" content_split ${content})

set(sources_file "${dir}/${name}.f")

file(WRITE "${sources_file}" "")

foreach (line ${content_split})
    string(REGEX MATCH "path=\".*\\.s?v\"" match "${line}")

    if (match)
        string(REGEX REPLACE ".*path=\"(.*\\.s?v)\".*" "\\1"
            source "${line}")

        if (NOT source MATCHES aldec AND
                NOT source MATCHES synopsys AND
                NOT source MATCHES cadence AND
                NOT source MATCHES ${name}_bb.v AND
                NOT source MATCHES ${name}_inst.v)
            set(source "${dir}/${source}")

            get_filename_component(source "${source}" REALPATH)

            if (CYGWIN)
                execute_process(COMMAND cygpath -m "${source}"
                    OUTPUT_VARIABLE source
                    OUTPUT_STRIP_TRAILING_WHITESPACE)
            endif()

            file(APPEND "${sources_file}" "${source}\n")
        endif()
    endif()
endforeach()
