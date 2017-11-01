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
    test.cpp
    testbench.cpp
    tx_agent.cpp
    tx_driver.cpp
    tx_sequence.cpp
    tx_sequence_item.cpp
    tx_sequencer.cpp
)
