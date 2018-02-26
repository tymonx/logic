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
# FindSVUnit
# --------
#
# Find SVUnit
#
# ::
#
#   SVUNIT_HDL_PACKAGE      - SVUnit SystemVerilog package
#   SVUNIT_INCLUDE_DIR      - SVUnit include directory
#   SVUNIT_FOUND            - true if SVUnit found

if (COMMAND _find_svunit)
    return()
endif()

function(_find_svunit)
    find_package(PackageHandleStandardArgs REQUIRED)

    find_path(SVUNIT_HDL_SOURCES_DIR svunit_base.sv
        HINTS $ENV{SVUNIT_INSTALL}
        PATH_SUFFIXES svunit_base
        DOC "Path to the SVUnit include directory"
    )

    if (SVUNIT_HDL_SOURCES_DIR)
        set(SVUNIT_HDL_PACKAGE ${SVUNIT_HDL_SOURCES_DIR}/svunit_pkg.sv)
        set(SVUNIT_INCLUDE_DIR ${SVUNIT_HDL_SOURCES_DIR})
    endif()

    mark_as_advanced(SVUNIT_HDL_PACKAGE)
    mark_as_advanced(SVUNIT_INCLUDE_DIR)

    find_package_handle_standard_args(SVUnit REQUIRED_VARS
        SVUNIT_HDL_PACKAGE SVUNIT_INCLUDE_DIR)

    set(SVUNIT_FOUND ${SVUNIT_FOUND} PARENT_SCOPE)
    set(SVUNIT_INCLUDE_DIR "${SVUNIT_INCLUDE_DIR}" PARENT_SCOPE)
    set(SVUNIT_HDL_PACKAGE "${SVUNIT_HDL_PACKAGE}" PARENT_SCOPE)
endfunction()

_find_svunit()
