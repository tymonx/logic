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
#   QUARTUS_EXECUTABLE    - Quartus
#   QUARTUS_FOUND         - true if Quartus found

if (QUARTUS_FOUND)
    return()
endif()

find_package(PackageHandleStandardArgs REQUIRED)

find_program(QUARTUS_EXECUTABLE quartus
    HINTS
        $ENV{QUARTUS_ROOTDIR}
        $ENV{QUARTUS_HOME}
        $ENV{QUARTUS_ROOT}
        $ENV{QUARTUS_DIR}
        $ENV{QUARTUS}
    PATH_SUFFIXES bin
    DOC "Path to the Quartus executable"
)

get_filename_component(QUARTUS_EXECUTABLE_DIR ${QUARTUS_EXECUTABLE}
    DIRECTORY)

find_file(QUARTUS_MEGA_FUNCTIONS altera_mf.v
    HINTS ${QUARTUS_EXECUTABLE_DIR}/..
    PATH_SUFFIXES eda eda/sim_lib
    DOC "Path to the Quartus Mega Functions"
)

mark_as_advanced(QUARTUS_EXECUTABLE)
mark_as_advanced(QUARTUS_MEGA_FUNCTIONS)

find_package_handle_standard_args(Quartus REQUIRED_VARS
    QUARTUS_EXECUTABLE QUARTUS_MEGA_FUNCTIONS)
