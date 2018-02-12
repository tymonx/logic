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
 * Parameters:
 *  TDATA_BYTES - Number of bytes for tdata signal.
 *  TDEST_WIDTH - Number of bits for tdest signal.
 *  TUSER_WIDTH - Number of bits for tuser signal.
 *  TID_WIDTH   - Number of bits for tid signal.
 *
 * Ports:
 *  rx          - AXI4-Stream interface.
 *  tx          - AXI4-Stream interface.
 */
module logic_axi4_stream_assign #(
    int TDATA_BYTES = 1,
    int TDEST_WIDTH = 1,
    int TUSER_WIDTH = 1,
    int TID_WIDTH = 1
) (
    `LOGIC_MODPORT(logic_axi4_stream_if, rx) rx,
    `LOGIC_MODPORT(logic_axi4_stream_if, tx) tx
);
    always_comb tx.tlast = rx.tlast;
    always_comb tx.tvalid = rx.tvalid;
    always_comb rx.tready = tx.tready;

    generate
        if (TDATA_BYTES > 0) begin: tdata_enabled
            typedef logic [TDATA_BYTES-1:0][7:0] tdata_t;
            typedef logic [TDATA_BYTES-1:0] tkeep_t;
            typedef logic [TDATA_BYTES-1:0] tstrb_t;

            always_comb tx.tdata = tdata_t'(rx.tdata);
            always_comb tx.tstrb = tstrb_t'(rx.tstrb);
            always_comb tx.tkeep = tkeep_t'(rx.tkeep);
        end
        else begin: tdata_disabled
            always_comb tx.tdata = '0;
            always_comb tx.tstrb = '0;
            always_comb tx.tkeep = '0;

`ifdef VERILATOR
            logic _unused_ports = &{1'b0, rx.tdata, rx.tstrb, rx.tkeep, 1'b0};
`endif
        end

        if (TUSER_WIDTH > 0) begin: tuser_enabled
            typedef logic [TUSER_WIDTH-1:0] tuser_t;

            always_comb tx.tuser = tuser_t'(rx.tuser);
        end
        else begin: tuser_disabled
            always_comb tx.tuser = '0;

`ifdef VERILATOR
            logic _unused_ports = &{1'b0, rx.tuser, 1'b0};
`endif
        end

        if (TDEST_WIDTH > 0) begin: tdest_enabled
            typedef logic [TDEST_WIDTH-1:0] tdest_t;

            always_comb tx.tdest = tdest_t'(rx.tdest);
        end
        else begin: tdest_disabled
            always_comb tx.tdest = '0;

`ifdef VERILATOR
            logic _unused_ports = &{1'b0, rx.tdest, 1'b0};
`endif
        end

        if (TID_WIDTH > 0) begin: tid_enabled
            typedef logic [TID_WIDTH-1:0] tid_t;

            always_comb tx.tid = tid_t'(rx.tid);
        end
        else begin: tid_disabled
            always_comb tx.tid = '0;

`ifdef VERILATOR
            logic _unused_ports = &{1'b0, rx.tid, 1'b0};
`endif
        end
    endgenerate
endmodule
