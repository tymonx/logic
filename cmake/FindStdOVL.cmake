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
# FindStdOVL
# ----------
#
# Find Open Verification Library
#
# ::
#
#   STD_OVL_DIR             - Open Verification Library directory

if (COMMAND _find_accellera_std_ovl)
    return()
endif()

function(_find_accellera_std_ovl)
    find_package(PackageHandleStandardArgs REQUIRED)

    find_path(STD_OVL_DIR std_ovl_defines.h
        HINTS $ENV{STD_OVL_DIR} $ENV{STD_OVL}
        DOC "Path to the Open Verification Library directory"
    )

    mark_as_advanced(STD_OVL_DIR)

    find_package_handle_standard_args(STD_OVL REQUIRED_VARS STD_OVL_DIR)

    set(STD_OVL_FOUND ${STD_OVL_FOUND} PARENT_SCOPE)
    set(STD_OVL_DIR "${STD_OVL_DIR}" PARENT_SCOPE)
endfunction()

_find_accellera_std_ovl()
