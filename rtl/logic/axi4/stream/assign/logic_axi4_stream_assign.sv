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

`include "logic.svh"

/* Module: logic_axi4_stream_assign
 *
 * Assign AXI4-Stream interfaces.
 *
 * Ports:
 *  rx          - AXI4-Stream interface.
 *  tx          - AXI4-Stream interface.
 */
module logic_axi4_stream_assign (
    `LOGIC_MODPORT(logic_axi4_stream_if, rx) rx,
    `LOGIC_MODPORT(logic_axi4_stream_if, tx) tx
);
    always_comb tx.tvalid = rx.tvalid;
    always_comb tx.tlast = rx.tlast;
    always_comb tx.tdata = rx.tdata;
    always_comb tx.tstrb = rx.tstrb;
    always_comb tx.tkeep = rx.tkeep;
    always_comb tx.tdest = rx.tdest;
    always_comb tx.tuser = rx.tuser;
    always_comb tx.tid = rx.tid;
    always_comb rx.tready = tx.tready;
endmodule
