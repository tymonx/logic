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

set(HDL_DEPENDS)
set(HDL_DEFINES)
set(HDL_INCLUDES ${CMAKE_CURRENT_SOURCE_DIR}/include)

add_subdirectory(packages)
add_subdirectory(interfaces)

set(HDL_DEPENDS
    logic_pkg
    logic_axi4_lite_pkg
    logic_axi4_lite_if
    logic_axi4_stream_if
    logic_avalon_mm_pkg
    logic_avalon_mm_if
    logic_avalon_st_if
)

add_subdirectory(reset)
add_subdirectory(basic)
add_subdirectory(clock)
add_subdirectory(axi4)
