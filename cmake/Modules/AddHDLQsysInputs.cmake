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

set(INPUT_FILES "" CACHE STRING "Input files")
set(OUTPUT_DIRECTORY "." CACHE STRING "Output directory")

get_filename_component(output_directory "${OUTPUT_DIRECTORY}" REALPATH)

foreach (input_file ${INPUT_FILES})
    get_filename_component(input_file "${input_file}" REALPATH)

    file(READ "${input_file}" input_context)
    string(REGEX REPLACE "\n" ";" input_list "${input_context}")

    foreach (input ${input_list})
        get_filename_component(name "${input}" NAME)

        if (UNIX)
            execute_process(
                COMMAND
                    ${CMAKE_COMMAND} -E create_symlink "${input}" "${name}"
                WORKING_DIRECTORY
                    "${output_directory}"
                OUTPUT_QUIET
            )
        else()
            execute_process(
                COMMAND
                    ${CMAKE_COMMAND} -E copy "${input}" "${name}"
                WORKING_DIRECTORY
                    "${output_directory}"
                OUTPUT_QUIET
            )
        endif()
    endforeach()
endforeach()
