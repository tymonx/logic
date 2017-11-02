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

set(RTL_SOURCES "" CACHE INTERNAL
    "RTL sources" FORCE)

set(RTL_INCLUDES "" CACHE INTERNAL
    "RTL includes" FORCE)

set(VERILATOR_CONFIGURATIONS "" CACHE INTERNAL
    "Verilator configurations" FORCE)

function(add_verilator_configurations)
    set(VERILATOR_CONFIGURATIONS ${VERILATOR_CONFIGURATIONS} ${ARGV}
        CACHE INTERNAL "Verilator configurations" FORCE)
endfunction()

function(add_rtl_sources)
    foreach(src ${ARGV})
        get_filename_component(src ${src} REALPATH)
        list(APPEND sources ${src})
    endforeach()

    set(RTL_SOURCES ${RTL_SOURCES} ${sources}
        CACHE INTERNAL "RTL sources" FORCE)
endfunction()

function(add_rtl_includes)
    foreach(inc ${ARGV})
        get_filename_component(inc ${inc} REALPATH)
        list(APPEND includes ${inc})
    endforeach()

    set(RTL_INCLUDES ${RTL_INCLUDES} ${includes}
        CACHE INTERNAL "RTL includes" FORCE)
endfunction()
