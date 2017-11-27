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
# FindQuartus
# --------
#
# Find Quartus
#
# ::
#
#   QUARTUS_EXECUTABLE      - Quartus
#   QUARTUS_SH_EXECUTABLE   - Quartus Sh
#   QUARTUS_MAP_EXECUTABLE  - Quartus Map
#   QUARTUS_SYN_EXECUTABLE  - Quartus Syn
#   QUARTUS_FOUND           - true if Quartus found

if (QUARTUS_FOUND)
    return()
endif()

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

find_program(QUARTUS_MAP_EXECUTABLE quartus_map
    HINTS ${QUARTUS_HINTS}
    PATH_SUFFIXES bin bin64
    DOC "Path to the Quartus map executable"
)

find_program(QUARTUS_SYN_EXECUTABLE quartus_syn
    HINTS ${QUARTUS_HINTS}
    PATH_SUFFIXES bin bin64
    DOC "Path to the Quartus syn executable"
)

find_program(QUARTUS_SH_EXECUTABLE quartus_sh
    HINTS ${QUARTUS_HINTS}
    PATH_SUFFIXES bin bin64
    DOC "Path to the Quartus sh executable"
)

if (QUARTUS_SH_EXECUTABLE)
    execute_process(COMMAND ${QUARTUS_SH_EXECUTABLE}
        --tcl_eval puts "$quartus(version)"
        OUTPUT_VARIABLE quartus_version
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )

    if (quartus_version MATCHES Pro)
        set(QUARTUS_EDITION Pro)
    else ()
        set(QUARTUS_EDITION Standard)
    endif()
endif()

get_filename_component(QUARTUS_EXECUTABLE_DIR ${QUARTUS_EXECUTABLE}
    DIRECTORY)

find_file(QUARTUS_MEGA_FUNCTIONS altera_mf.v
    HINTS ${QUARTUS_EXECUTABLE_DIR}/..
    PATH_SUFFIXES eda eda/sim_lib
    DOC "Path to the Quartus Mega Functions"
)

mark_as_advanced(QUARTUS_EXECUTABLE)
mark_as_advanced(QUARTUS_SH_EXECUTABLE)
mark_as_advanced(QUARTUS_MAP_EXECUTABLE)
mark_as_advanced(QUARTUS_SYN_EXECUTABLE)
mark_as_advanced(QUARTUS_MEGA_FUNCTIONS)

find_package_handle_standard_args(Quartus REQUIRED_VARS
    QUARTUS_EXECUTABLE QUARTUS_MAP_EXECUTABLE QUARTUS_SYN_EXECUTABLE
    QUARTUS_SH_EXECUTABLE QUARTUS_MEGA_FUNCTIONS)
