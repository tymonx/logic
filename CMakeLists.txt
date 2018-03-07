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

cmake_minimum_required(VERSION 3.1)
project(Logic C CXX)

set(CMAKE_MODULE_PATH "${CMAKE_MODULE_PATH}" "${CMAKE_CURRENT_LIST_DIR}/cmake")

option(LOGIC_TESTS "Enable/disable tests" ON)
option(LOGIC_RTL "Enable/disable RTL build" ON)
option(LOGIC_WARNINGS_INTO_ERRORS "Enable/disable warnings as errors" OFF)

include(AddLogic)

set(LOGIC_INCLUDE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/include")

add_subdirectory(src)

if (LOGIC_RTL)
    add_subdirectory(rtl)

    if (LOGIC_TESTS)
        include(CTest)
        add_subdirectory(tests)
    endif()
endif()
