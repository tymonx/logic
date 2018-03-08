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

find_package(StdOVL)
include(AddHDL)

if (NOT STD_OVL_FOUND OR ADD_STD_OVL_INCLUDED)
    return()
endif()

set(ADD_STD_OVL_INCLUDED TRUE)

set(STD_OVL_SOURCES
    ovl_always.v
    ovl_cycle_sequence.v
    ovl_implication.v
    ovl_never.v
    ovl_never_unknown.v
    ovl_next.v
    ovl_one_hot.v
    ovl_range.v
    ovl_win_unchange.v
    ovl_zero_one_hot.v
    ovl_always_on_edge.v
    ovl_change.v
    ovl_decrement.v
    ovl_delta.v
    ovl_even_parity.v
    ovl_fifo_index.v
    ovl_frame.v
    ovl_handshake.v
    ovl_increment.v
    ovl_never_unknown_async.v
    ovl_no_overflow.v
    ovl_no_transition.v
    ovl_no_underflow.v
    ovl_odd_parity.v
    ovl_one_cold.v
    ovl_proposition.v
    ovl_quiescent_state.v
    ovl_time.v
    ovl_transition.v
    ovl_unchange.v
    ovl_width.v
    ovl_win_change.v
    ovl_window.v
)

foreach (std_ovl_source ${STD_OVL_SOURCES})
    add_hdl_source(${STD_OVL_DIR}/${std_ovl_source}
        TYPE SystemVerilog
        DEFINES
            OVL_VERILOG
            OVL_ASSERT_ON
            OVL_SVA_INTERFACE
        INCLUDES ${STD_OVL_DIR}
        SYNTHESIZABLE FALSE
        VERILATOR_CONFIGURATIONS
            "lint_off -msg COMBDLY      -file \"${STD_OVL_DIR}/std_ovl_clock.h\""
            "lint_off -msg STMTDLY      -file \"${STD_OVL_DIR}/std_ovl_task.h\""
            "lint_off -msg VARHIDDEN    -file \"${STD_OVL_DIR}/std_ovl_task.h\""
            "lint_off -msg BLKSEQ       -file \"${STD_OVL_DIR}/std_ovl_task.h\""
            "lint_off -msg UNUSED       -file \"${STD_OVL_DIR}/std_ovl_task.h\""
            "lint_off -msg WIDTH        -file \"${STD_OVL_DIR}/${std_ovl_source}\""
            "coverage_off -file \"${STD_OVL_DIR}/${std_ovl_source}\""
    )
endforeach()
