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
# FindModelSim
# --------
#
# Find ModelSim
#
# ::
#
#   MODELSIM_VLIB           - ModelSim vlib
#   MODELSIM_VMAP           - ModelSim vmap
#   MODELSIM_VCOM           - ModelSim vcom
#   MODELSIM_VLOG           - ModelSim vlog
#   MODELSIM_VSIM           - ModelSim vsim
#   MODELSIM_FOUND          - true if ModelSim found

if (COMMAND _find_mentor_graphics_modelsim)
    return()
endif()

function(_find_mentor_graphics_modelsim)
    find_package(PackageHandleStandardArgs REQUIRED)

    set(MODELSIM_HINTS
        $ENV{MODELSIM_ROOTDIR}
        $ENV{MODELSIM_HOME}
        $ENV{MODELSIM_ROOT}
        $ENV{MODELSIM_DIR}
        $ENV{MODELSIM}
        $ENV{MODELSIM_ROOT}
        $ENV{QUARTUS_ROOTDIR}
        $ENV{QUARTUS_HOME}
        $ENV{QUARTUS_ROOT}
        $ENV{QUARTUS_DIR}
        $ENV{QUARTUS}
    )

    set(MODELSIM_PATH_SUFFIXES
        bin
        ../modelsim_ae/bin
        ../modelsim_ase/bin
    )

    find_program(MODELSIM_VLIB vlib
        HINTS ${MODELSIM_HINTS}
        PATH_SUFFIXES bin ${MODELSIM_PATH_SUFFIXES}
        DOC "Path to the vlib executable"
    )

    find_program(MODELSIM_VMAP vmap
        HINTS ${MODELSIM_HINTS}
        PATH_SUFFIXES bin ${MODELSIM_PATH_SUFFIXES}
        DOC "Path to the vmap executable"
    )

    find_program(MODELSIM_VCOM vcom
        HINTS ${MODELSIM_HINTS}
        PATH_SUFFIXES bin ${MODELSIM_PATH_SUFFIXES}
        DOC "Path to the vcom executable"
    )

    find_program(MODELSIM_VLOG vlog
        HINTS ${MODELSIM_HINTS}
        PATH_SUFFIXES bin ${MODELSIM_PATH_SUFFIXES}
        DOC "Path to the vlog executable"
    )

    find_program(MODELSIM_VSIM vsim
        HINTS ${MODELSIM_HINTS}
        PATH_SUFFIXES bin ${MODELSIM_PATH_SUFFIXES}
        DOC "Path to the vsim executable"
    )

    mark_as_advanced(MODELSIM_VLIB)
    mark_as_advanced(MODELSIM_VMAP)
    mark_as_advanced(MODELSIM_VCOM)
    mark_as_advanced(MODELSIM_VLOG)
    mark_as_advanced(MODELSIM_VSIM)

    find_package_handle_standard_args(ModelSim REQUIRED_VARS
        MODELSIM_VSIM
        MODELSIM_VMAP
        MODELSIM_VCOM
        MODELSIM_VLOG
        MODELSIM_VLIB
    )

    set(MODELSIM_VLIB "${MODELSIM_VLIB}" PARENT_SCOPE)
    set(MODELSIM_VMAP "${MODELSIM_VMAP}" PARENT_SCOPE)
    set(MODELSIM_VCOM "${MODELSIM_VCOM}" PARENT_SCOPE)
    set(MODELSIM_VLOG "${MODELSIM_VLOG}" PARENT_SCOPE)
    set(MODELSIM_VSIM "${MODELSIM_VSIM}" PARENT_SCOPE)
    set(MODELSIM_FOUND ${MODELSIM_FOUND} PARENT_SCOPE)
endfunction()

_find_mentor_graphics_modelsim()
