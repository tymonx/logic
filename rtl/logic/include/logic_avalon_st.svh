/* Copyright 2018 Tymoteusz Blazejczyk
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

`ifndef LOGIC_AVALON_ST_SVH
`define LOGIC_AVALON_ST_SVH

/* Define: LOGIC_AVALON_ST_IF_ASSIGN
 *
 * Assign SystemVerilog interface to another SystemVerilog interface.
 *
 * Parameters:
 *  lhs       - SystemVerilog interface.
 *  rhs       - SystemVerilog interface.
 */
`define LOGIC_AVALON_ST_IF_ASSIGN(lhs, rhs) \
    always_comb lhs``.valid = rhs``.valid; \
    always_comb lhs``.startofpacket = rhs``.startofpacket; \
    always_comb lhs``.endofpacket = rhs``.endofpacket; \
    always_comb lhs``.data = rhs``.data; \
    always_comb lhs``.empty = rhs``.empty; \
    always_comb lhs``.error = rhs``.error; \
    always_comb lhs``.channel = rhs``.channel; \
    always_comb rhs``.ready = lhs``.ready

/* Define: LOGIC_AVALON_ST_IF_RX_ASSIGN
 *
 * Assign standalone signals to signals in SystemVerilog interface.
 *
 * Parameters:
 *  lhs       - SystemVerilog interface.
 *  rhs       - Standalone SystemVerilog signals.
 */
`define LOGIC_AVALON_ST_IF_RX_ASSIGN(lhs, rhs) \
    always_comb lhs``.valid = rhs``_valid; \
    always_comb lhs``.startofpacket = rhs``_startofpacket; \
    always_comb lhs``.endofpacket = rhs``_endofpacket; \
    always_comb lhs``.data = rhs``_data; \
    always_comb lhs``.empty = rhs``_empty; \
    always_comb lhs``.error = rhs``_error; \
    always_comb lhs``.channel = rhs``_channel; \
    always_comb rhs``_ready = lhs``.ready

/* Define: LOGIC_AVALON_ST_IF_TX_ASSIGN
 *
 * Assign signals in SystemVerilog interface to standalone signals.
 *
 * Parameters:
 *  lhs       - Standalone SystemVerilog signals.
 *  rhs       - SystemVerilog interface.
 */
`define LOGIC_AVALON_ST_IF_TX_ASSIGN(lhs, rhs) \
    always_comb lhs``_valid = rhs``.valid; \
    always_comb lhs``_startofpacket = rhs``.startofpacket; \
    always_comb lhs``_endofpacket = rhs``.endofpacket; \
    always_comb lhs``_data = rhs``.data; \
    always_comb lhs``_empty = rhs``.empty; \
    always_comb lhs``_error = rhs``.error; \
    always_comb lhs``_channel = rhs``.channel; \
    always_comb rhs``.ready = lhs``_ready

`endif /* LOGIC_AVALON_ST_SVH */
