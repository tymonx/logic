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

`ifndef LOGIC_AXI4_STREAM_SVH
`define LOGIC_AXI4_STREAM_SVH

/* Define: LOGIC_AXI4_STREAM_IF_ASSIGN
 *
 * Assign SystemVerilog interface to another SystemVerilog interface.
 *
 * Parameters:
 *  lhs       - SystemVerilog interface.
 *  rhs       - SystemVerilog interface.
 */
`define LOGIC_AXI4_STREAM_IF_ASSIGN(lhs, rhs) \
    always_comb lhs``.tvalid = rhs``.tvalid; \
    always_comb lhs``.tlast = rhs``.tlast; \
    always_comb lhs``.tdata = rhs``.tdata; \
    always_comb lhs``.tstrb = rhs``.tstrb; \
    always_comb lhs``.tkeep = rhs``.tkeep; \
    always_comb lhs``.tdest = rhs``.tdest; \
    always_comb lhs``.tuser = rhs``.tuser; \
    always_comb lhs``.tid = rhs``.tid; \
    always_comb rhs``.tready = lhs``.tready

/* Define: LOGIC_AXI4_STREAM_IF_RX_ASSIGN
 *
 * Assign standalone signals to signals in SystemVerilog interface.
 *
 * Parameters:
 *  lhs       - SystemVerilog interface.
 *  rhs       - Standalone SystemVerilog signals.
 */
`define LOGIC_AXI4_STREAM_IF_RX_ASSIGN(lhs, rhs) \
    always_comb lhs``.tvalid = rhs``_tvalid; \
    always_comb lhs``.tlast = rhs``_tlast; \
    always_comb lhs``.tdata = rhs``_tdata; \
    always_comb lhs``.tstrb = rhs``_tstrb; \
    always_comb lhs``.tkeep = rhs``_tkeep; \
    always_comb lhs``.tdest = rhs``_tdest; \
    always_comb lhs``.tuser = rhs``_tuser; \
    always_comb lhs``.tid = rhs``_tid; \
    always_comb rhs``_tready = lhs``.tready

/* Define: LOGIC_AXI4_STREAM_IF_TX_ASSIGN
 *
 * Assign signals in SystemVerilog interface to standalone signals.
 *
 * Parameters:
 *  lhs       - Standalone SystemVerilog signals.
 *  rhs       - SystemVerilog interface.
 */
`define LOGIC_AXI4_STREAM_IF_TX_ASSIGN(lhs, rhs) \
    always_comb lhs``_tvalid = rhs``.tvalid; \
    always_comb lhs``_tlast = rhs``.tlast; \
    always_comb lhs``_tdata = rhs``.tdata; \
    always_comb lhs``_tstrb = rhs``.tstrb; \
    always_comb lhs``_tkeep = rhs``.tkeep; \
    always_comb lhs``_tdest = rhs``.tdest; \
    always_comb lhs``_tuser = rhs``.tuser; \
    always_comb lhs``_tid = rhs``.tid; \
    always_comb rhs``.tready = lhs``_tready

`endif /* LOGIC_AXI4_STREAM_SVH */
