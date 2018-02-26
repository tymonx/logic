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
# FindVivado
# --------
#
# Find Vivado
#
# ::
#
#   VIVADO_EXECUTABLE   - Vivado executable

if (COMMAND _find_xilinx_vivado)
    return()
endif()

function(_find_xilinx_vivado)
    find_package(PackageHandleStandardArgs REQUIRED)

    set(VIVADO_HINTS
        $ENV{VIVADO_ROOTDIR}
        $ENV{VIVADO_HOME}
        $ENV{VIVADO_ROOT}
        $ENV{VIVADO_DIR}
        $ENV{VIVADO}
    )

    find_program(VIVADO_EXECUTABLE vivado
        HINTS ${VIVADO_HINTS}
        PATH_SUFFIXES bin bin64
        DOC "Path to the Vivado executable"
    )

    mark_as_advanced(VIVADO_EXECUTABLE)

    find_package_handle_standard_args(Vivado REQUIRED_VARS VIVADO_EXECUTABLE)

    set(VIVADO_EXECUTABLE "${VIVADO_EXECUTABLE}" PARENT_SCOPE)
    set(VIVADO_FOUND ${VIVADO_FOUND} PARENT_SCOPE)
endfunction()

_find_xilinx_vivado()
