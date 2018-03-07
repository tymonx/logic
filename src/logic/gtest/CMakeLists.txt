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
    SYSTEM PUBLIC
        ${LOGIC_INCLUDE_DIR}
        ${GTEST_INCLUDE_DIRS}
)

target_link_libraries(logic-gtest-main
    PUBLIC
        logic
        ${GTEST_LIBRARIES}
)

if (CMAKE_CXX_COMPILER_ID MATCHES Clang)
    set(compile_options
        -Wno-global-constructors
        -Wno-over-aligned
        -Wno-weak-vtables
    )

    if (NOT CMAKE_CXX_COMPILER_VERSION VERSION_LESS 5.0)
        list(APPEND compile_options
            -Wno-zero-as-null-pointer-constant
        )
    endif()

    target_compile_options(logic-gtest-main PUBLIC ${compile_options})
endif()
