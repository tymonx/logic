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

#.rst:
# FindNaturalDocs
# --------
#
# Find NaturalDocs
#
# ::
#
#   NATURAL_DOCS_EXECUTABLE - Natural Docs executable
#   NATURAL_DOCS_FOUND      - true if Natural Docs found

if (COMMAND _find_natural_docs)
    return()
endif()

function(_find_natural_docs)
    find_package(PackageHandleStandardArgs REQUIRED)

    find_program(NATURAL_DOCS_EXECUTABLE
        NAMES NaturalDocs.exe NaturalDocs
        HINTS
            $ENV{NATURAL_DOCS_ROOT}
            $ENV{NATURAL_DOCS_ROOTDIR}
            $ENV{NATURAL_DOCS_HOME}
            $ENV{NATURAL_DOCS_DIR}
            $ENV{NATURAL_DOCS}
        PATH_SUFFIXES bin
        DOC "Path to the Natural Docs executable"
    )

    mark_as_advanced(NATURAL_DOCS_EXECUTABLE)

    find_package_handle_standard_args(Natural_Docs REQUIRED_VARS
        NATURAL_DOCS_EXECUTABLE)

    if (NATURAL_DOCS_FOUND)
        file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/doc/html)

        set(NATURAL_DOCS_COMMAND ${NATURAL_DOCS_EXECUTABLE})

        if (UNIX AND NOT CMAKE_SYSTEM_NAME MATCHES CYGWIN)
            set(NATURAL_DOCS_COMMAND mono ${NATURAL_DOCS_COMMAND})
        endif()

        set(NATURAL_DOCS_CONFIG_DIRECTORY   ${CMAKE_SOURCE_DIR}/doc)
        set(NATURAL_DOCS_WORKING_DIRECTORY  ${CMAKE_BINARY_DIR}/doc/tmp)
        set(NATURAL_DOCS_OUTPUT_DIRECTORY   ${CMAKE_BINARY_DIR}/doc/html)

        if (CMAKE_SYSTEM_NAME MATCHES CYGWIN)
            execute_process(COMMAND cygpath -m ${NATURAL_DOCS_CONFIG_DIRECTORY}
                OUTPUT_VARIABLE NATURAL_DOCS_CONFIG_DIRECTORY
                OUTPUT_STRIP_TRAILING_WHITESPACE)

            execute_process(COMMAND cygpath -m ${NATURAL_DOCS_WORKING_DIRECTORY}
                OUTPUT_VARIABLE NATURAL_DOCS_WORKING_DIRECTORY
                OUTPUT_STRIP_TRAILING_WHITESPACE)

            execute_process(COMMAND cygpath -m ${NATURAL_DOCS_OUTPUT_DIRECTORY}
                OUTPUT_VARIABLE NATURAL_DOCS_OUTPUT_DIRECTORY
                OUTPUT_STRIP_TRAILING_WHITESPACE)
        endif()

        add_custom_target(doc
            COMMAND ${NATURAL_DOCS_COMMAND}
                -p ${NATURAL_DOCS_CONFIG_DIRECTORY}
                -o html ${NATURAL_DOCS_OUTPUT_DIRECTORY}
                -w ${NATURAL_DOCS_WORKING_DIRECTORY}
            WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
            COMMENT "Creating documentation"
        )
    endif()

    set(NATURAL_DOCS_FOUND ${NATURAL_DOCS_FOUND} PARENT_SCOPE)
    set(NATURAL_DOCS_EXECUTABLE "${NATURAL_DOCS_EXECUTABLE}" PARENT_SCOPE)
endfunction()

_find_natural_docs()
