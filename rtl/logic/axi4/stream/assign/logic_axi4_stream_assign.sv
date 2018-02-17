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
 *  USE_TLAST   - Enable or disable tlast signal.
 *  USE_TKEEP   - Enable or disable tkeep signal.
 *  USE_TSTRB   - Enable or disable tstrb signal.
 *
 * Ports:
 *  rx          - AXI4-Stream interface.
 *  tx          - AXI4-Stream interface.
 */
module logic_axi4_stream_assign #(
    int TDATA_BYTES = 1,
    int TDEST_WIDTH = 1,
    int TUSER_WIDTH = 1,
    int TID_WIDTH = 1,
    int USE_TKEEP = 1,
    int USE_TSTRB = 1,
    int USE_TLAST = 1
) (
    `LOGIC_MODPORT(logic_axi4_stream_if, rx) rx,
    `LOGIC_MODPORT(logic_axi4_stream_if, tx) tx
);
    localparam int TKEEP_WIDTH = (USE_TKEEP > 0) ? TDATA_BYTES : 0;
    localparam int TSTRB_WIDTH = (USE_TSTRB > 0) ? TDATA_BYTES : 0;
    localparam int TLAST_WIDTH = (USE_TLAST > 0) ? 1 : 0;

    always_comb tx.tvalid = rx.tvalid;
    always_comb rx.tready = tx.tready;

    generate
        if (TDATA_BYTES > 0) begin: tdata_enabled
            typedef logic [TDATA_BYTES-1:0][7:0] tdata_t;
            always_comb tx.tdata = tdata_t'(rx.tdata);
        end
        else begin: tdata_disabled
            always_comb tx.tdata = '0;
`ifdef VERILATOR
            logic _unused_ports = &{1'b0, rx.tdata, 1'b0};
`endif
        end

        if (TLAST_WIDTH > 0) begin: tlast_enabled
            typedef logic [TLAST_WIDTH-1:0] tlast_t;
            always_comb tx.tlast = tlast_t'(rx.tlast);
        end
        else begin: tlast_disabled
            always_comb tx.tlast = '1;
`ifdef VERILATOR
            logic _unused_ports = &{1'b0, rx.tlast, 1'b0};
`endif
        end

        if (TKEEP_WIDTH > 0) begin: tkeep_enabled
            typedef logic [TKEEP_WIDTH-1:0] tkeep_t;
            always_comb tx.tkeep = tkeep_t'(rx.tkeep);
        end
        else begin: tkeep_disabled
            always_comb tx.tkeep = '1;
`ifdef VERILATOR
            logic _unused_ports = &{1'b0, rx.tkeep, 1'b0};
`endif
        end

        if (TSTRB_WIDTH > 0) begin: tstrb_enabled
            typedef logic [TSTRB_WIDTH-1:0] tstrb_t;
            always_comb tx.tstrb = tstrb_t'(rx.tstrb);
        end
        else begin: tstrb_disabled
            always_comb tx.tstrb = '1;
`ifdef VERILATOR
            logic _unused_ports = &{1'b0, rx.tstrb, 1'b0};
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
