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

`ifndef LOGIC_AVALON_MM_SVH
`define LOGIC_AVALON_MM_SVH

/* Define: LOGIC_AVALON_MM_IF_ASSIGN
 *
 * Assign SystemVerilog interface to another SystemVerilog interface.
 *
 * Parameters:
 *  lhs       - SystemVerilog interface.
 *  rhs       - SystemVerilog interface.
 */
`define LOGIC_AVALON_MM_IF_ASSIGN(lhs, rhs) \
    always_comb lhs``.read = rhs``.read; \
    always_comb lhs``.write = rhs``.write; \
    always_comb lhs``.address = rhs``.address; \
    always_comb lhs``.writedata = rhs``.writedata; \
    always_comb lhs``.byteenable = rhs``.byteenable; \
    always_comb rhs``.response = lhs``.response; \
    always_comb rhs``.readdata = lhs``.readdata; \
    always_comb rhs``.waitrequest = lhs``.waitrequest; \
    always_comb rhs``.readdatavalid = lhs``.readdatavalid; \
    always_comb rhs``.writeresponsevalid = lhs``.writeresponsevalid

/* Define: LOGIC_AVALON_MM_IF_SLAVE_ASSIGN
 *
 * Assign standalone signals to signals in SystemVerilog interface.
 *
 * Parameters:
 *  lhs       - SystemVerilog interface.
 *  rhs       - Standalone SystemVerilog signals.
 */
`define LOGIC_AVALON_MM_IF_SLAVE_ASSIGN(lhs, rhs) \
    always_comb lhs``.read = rhs``_read; \
    always_comb lhs``.write = rhs``_write; \
    always_comb lhs``.address = rhs``_address; \
    always_comb lhs``.writedata = rhs``_writedata; \
    always_comb lhs``.byteenable = rhs``_byteenable; \
    always_comb rhs``_response = lhs``.response; \
    always_comb rhs``_readdata = lhs``.readdata; \
    always_comb rhs``_waitrequest = lhs``.waitrequest; \
    always_comb rhs``_readdatavalid = lhs``.readdatavalid; \
    always_comb rhs``_writeresponsevalid = lhs``.writeresponsevalid

/* Define: LOGIC_AVALON_MM_IF_MASTER_ASSIGN
 *
 * Assign signals in SystemVerilog interface to standalone signals.
 *
 * Parameters:
 *  lhs       - Standalone SystemVerilog signals.
 *  rhs       - SystemVerilog interface.
 */
`define LOGIC_AVALON_MM_IF_MASTER_ASSIGN(lhs, rhs) \
    always_comb lhs``_read = rhs``.read; \
    always_comb lhs``_write = rhs``.write; \
    always_comb lhs``_address = rhs``.address; \
    always_comb lhs``_writedata = rhs``.writedata; \
    always_comb lhs``_byteenable = rhs``.byteenable; \
    always_comb rhs``.response = lhs``_response; \
    always_comb rhs``.readdata = lhs``_readdata; \
    always_comb rhs``.waitrequest = lhs``_waitrequest; \
    always_comb rhs``.readdatavalid = lhs``_readdatavalid; \
    always_comb rhs``.writeresponsevalid = lhs``_writeresponsevalid

`endif /* LOGIC_AVALON_MM_SVH */
