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

if (NOT GTEST_FOUND)
    return()
endif()

if (CMAKE_CXX_COMPILER_ID MATCHES Clang)
    set_source_files_properties(factory.cpp
        PROPERTIES COMPILE_FLAGS "-Wno-exit-time-destructors"
    )
endif()

add_library(logic-gtest-main STATIC
    factory.cpp
    main.cpp
)

target_include_directories(logic-gtest-main
    PUBLIC SYSTEM
        ${LOGIC_INCLUDE_DIR}
        ${GTEST_INCLUDE_DIRS}
)

target_link_libraries(logic-gtest-main
    PUBLIC
        logic
        ${GTEST_LIBRARIES}
)

if (CMAKE_CXX_COMPILER_ID MATCHES Clang)
    target_compile_options(logic-gtest-main PUBLIC
        -Wno-zero-as-null-pointer-constant
        -Wno-global-constructors
        -Wno-over-aligned
        -Wno-weak-vtables
    )
endif()
