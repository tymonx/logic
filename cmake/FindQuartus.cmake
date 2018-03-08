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
# FindQuartus
# --------
#
# Find Quartus
#
# ::
#
#   QUARTUS_EXECUTABLE      - Quartus executable
#   QUARTUS_SH              - Quartus sh
#   QUARTUS_MAP             - Quartus map
#   QUARTUS_SYN             - Quartus syn
#   QUARTUS_QSYS_SCRIPT     - Quartus Qsys generate
#   QUARTUS_QSYS_GENERATE   - Quartus Qsys generate
#   QUARTUS_FOUND           - true if Quartus found

if (COMMAND _find_intel_quartus)
    return()
endif()

function(_find_intel_quartus)
    find_package(PackageHandleStandardArgs REQUIRED)

    set(QUARTUS_HINTS
        $ENV{QUARTUS_ROOTDIR}
        $ENV{QUARTUS_HOME}
        $ENV{QUARTUS_ROOT}
        $ENV{QUARTUS_DIR}
        $ENV{QUARTUS}
    )

    find_program(QUARTUS_EXECUTABLE quartus
        HINTS ${QUARTUS_HINTS}
        PATH_SUFFIXES bin bin64
        DOC "Path to the Quartus executable"
    )

    find_program(QUARTUS_MAP quartus_map
        HINTS ${QUARTUS_HINTS}
        PATH_SUFFIXES bin bin64
        DOC "Path to the Quartus map executable"
    )

    find_program(QUARTUS_SYN quartus_syn
        HINTS ${QUARTUS_HINTS}
        PATH_SUFFIXES bin bin64
        DOC "Path to the Quartus syn executable"
    )

    find_program(QUARTUS_SH quartus_sh
        HINTS ${QUARTUS_HINTS}
        PATH_SUFFIXES bin bin64
        DOC "Path to the Quartus sh executable"
    )

    find_program(QUARTUS_QSYS_GENERATE qsys-generate
        HINTS ${QUARTUS_HINTS}
        PATH_SUFFIXES ../qsys/bin ../qsys/bin64 ../sopc_builder/bin
        DOC "Path to the Quartus Qsys generate"
    )

    find_program(QUARTUS_QSYS_SCRIPT qsys-script
        HINTS ${QUARTUS_HINTS}
        PATH_SUFFIXES ../qsys/bin ../qsys/bin64 ../sopc_builder/bin
        DOC "Path to the Quartus Qsys script"
    )

    if (QUARTUS_SH)
        execute_process(COMMAND ${QUARTUS_SH}
            --tcl_eval puts "$::quartus(version)"
            OUTPUT_VARIABLE quartus_version
            OUTPUT_STRIP_TRAILING_WHITESPACE
        )

        if (quartus_version MATCHES Pro)
            set(QUARTUS_EDITION Pro PARENT_SCOPE)
        elseif (quartus_version MATCHES Lite)
            set(QUARTUS_EDITION Lite PARENT_SCOPE)
        else ()
            set(QUARTUS_EDITION Standard PARENT_SCOPE)
        endif()

        string(REGEX REPLACE " " ";" quartus_version ${quartus_version})

        list(GET quartus_version 1 QUARTUS_VERSION)

        set(QUARTUS_VERSION ${QUARTUS_VERSION} PARENT_SCOPE)
    endif()

    get_filename_component(QUARTUS_DIR ${QUARTUS_EXECUTABLE} DIRECTORY)
    get_filename_component(QUARTUS_DIR ${QUARTUS_DIR}/.. REALPATH)

    mark_as_advanced(QUARTUS_EXECUTABLE)
    mark_as_advanced(QUARTUS_SH)
    mark_as_advanced(QUARTUS_MAP)
    mark_as_advanced(QUARTUS_SYN)
    mark_as_advanced(QUARTUS_QSYS_SCRIPT)
    mark_as_advanced(QUARTUS_QSYS_GENERATE)

    find_package_handle_standard_args(Quartus REQUIRED_VARS
        QUARTUS_EXECUTABLE
        QUARTUS_MAP
        QUARTUS_SYN
        QUARTUS_SH
        QUARTUS_QSYS_SCRIPT
        QUARTUS_QSYS_GENERATE
    )

    set(QUARTUS_QSYS_GENERATE "${QUARTUS_QSYS_GENERATE}" PARENT_SCOPE)
    set(QUARTUS_QSYS_SCRIPT "${QUARTUS_QSYS_SCRIPT}" PARENT_SCOPE)
    set(QUARTUS_EXECUTABLE "${QUARTUS_EXECUTABLE}" PARENT_SCOPE)
    set(QUARTUS_MAP "${QUARTUS_MAP}" PARENT_SCOPE)
    set(QUARTUS_SYN "${QUARTUS_SYN}" PARENT_SCOPE)
    set(QUARTUS_DIR "${QUARTUS_DIR}" PARENT_SCOPE)
    set(QUARTUS_SH "${QUARTUS_SH}" PARENT_SCOPE)
    set(QUARTUS_FOUND ${QUARTUS_FOUND} PARENT_SCOPE)
endfunction()

_find_intel_quartus()
