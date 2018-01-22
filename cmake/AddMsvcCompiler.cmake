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

if (ADD_MSVC_COMPILER)
    return()
endif()

if (NOT CMAKE_CXX_COMPILER_ID MATCHES MSVC)
    return()
endif ()

set(ADD_MSVC_COMPILER TRUE)

set(CMAKE_CXX_FLAGS ${CMAKE_CXX_FLAGS} /std:c++latest)
set(CMAKE_CXX_FLAGS ${CMAKE_CXX_FLAGS} /W4)

if (WARNINGS_INTO_ERRORS)
    set(CMAKE_CXX_FLAGS ${CMAKE_CXX_FLAGS} /WX)
endif()

string(REPLACE ";" " " CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")
