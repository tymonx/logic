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

set(RTL_SOURCES "" CACHE INTERNAL "RTL sources" FORCE)
set(RTL_INCLUDES "" CACHE INTERNAL "RTL includes" FORCE)

macro(add_rtl_sources)
    set(rtl_sources)

    foreach(src ${ARGV})
        set(rtl_sources ${rtl_sources} ${CMAKE_CURRENT_SOURCE_DIR}/${src})
    endforeach()

    set(RTL_SOURCES ${RTL_SOURCES} ${rtl_sources}
        CACHE INTERNAL "RTL sources" FORCE)
endmacro()

macro(add_rtl_includes)
    set(rtl_includes)

    foreach(inc ${ARGV})
        set(rtl_includes ${rtl_includes} ${CMAKE_CURRENT_SOURCE_DIR}/${inc})
    endforeach()

    set(RTL_INCLUDES ${RTL_INCLUDES} ${rtl_includes}
        CACHE INTERNAL "RTL includes" FORCE)
endmacro()
