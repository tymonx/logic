# Copyright 2017 Tymoteusz Blazejczyk
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

if (NATURAL_DOCS_FOUND)
    return()
endif()

find_package(PackageHandleStandardArgs REQUIRED)

find_program(NATURAL_DOCS_EXECUTABLE
    NAMES NaturalDocs.exe NaturalDocs
    HINTS $ENV{NATURAL_DOCS_ROOT}
    PATH_SUFFIXES bin
    DOC "Path to the Natural Docs executable"
)

mark_as_advanced(NATURAL_DOCS_EXECUTABLE)

find_package_handle_standard_args(Natural_Docs REQUIRED_VARS
    NATURAL_DOCS_EXECUTABLE)

if (NATURAL_DOCS_FOUND)
    file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/doc/html)

    if (UNIX)
        add_custom_target(doc
            COMMAND mono ${NATURAL_DOCS_EXECUTABLE}
                -i ${CMAKE_SOURCE_DIR}
                -p ${CMAKE_SOURCE_DIR}/doc
                -o html ${CMAKE_BINARY_DIR}/doc/html
                -w ${CMAKE_BINARY_DIR}/doc/tmp
            WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
            COMMENT "Creating documentation"
        )
    else()
        add_custom_target(doc
            COMMAND ${NATURAL_DOCS_EXECUTABLE}
                -i ${CMAKE_SOURCE_DIR}
                -p ${CMAKE_SOURCE_DIR}/doc
                -o html ${CMAKE_BINARY_DIR}/doc/html
                -w ${CMAKE_BINARY_DIR}/doc/tmp
            WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
            COMMENT "Creating documentation"
        )
    endif()
endif()
