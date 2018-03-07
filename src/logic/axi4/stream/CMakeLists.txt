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

add_library(logic-axi4-stream OBJECT
    bus_if_base.cpp
    monitor.cpp
    packet.cpp
    reset_agent.cpp
    reset_driver.cpp
    reset_if.cpp
    reset_sequence.cpp
    reset_sequence_item.cpp
    reset_sequencer.cpp
    rx_agent.cpp
    rx_driver.cpp
    rx_sequence.cpp
    rx_sequence_item.cpp
    rx_sequencer.cpp
    scoreboard.cpp
    sequence.cpp
    sequencer.cpp
    tdata_byte.cpp
    test.cpp
    testbench.cpp
    tx_agent.cpp
    tx_driver.cpp
    tx_sequence.cpp
    tx_sequence_item.cpp
    tx_sequencer.cpp
)

target_include_directories(logic-axi4-stream PRIVATE
    ${LOGIC_INCLUDE_DIR}
)

target_include_directories(logic-axi4-stream SYSTEM PRIVATE
    ${SYSTEMC_INCLUDE_DIRS}
)

set(compile_options "")

if (CMAKE_CXX_COMPILER_ID MATCHES Clang)
    if (NOT CMAKE_CXX_COMPILER_VERSION VERSION_LESS 3.9)
        list(APPEND compile_options
            -Wno-undefined-func-template
        )
    endif()
endif()

logic_target_compile_options(logic-axi4-stream ${compile_options})
