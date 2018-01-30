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

/* Module: logic_axi4_stream_pack_keep_shift_unit
 *
 * Shift single byte at one position below.
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
 *  rx          - AXI4-Stream Rx interface.
 *  tx          - AXI4-Stream Tx interface.
 */
module logic_axi4_stream_pack_shift_unit #(
    int TDATA_BYTES = 4,
    int TDEST_WIDTH = 1,
    int TUSER_WIDTH = 1,
    int TID_WIDTH = 1,
    int USE_TLAST = 1,
    int USE_TKEEP = 1,
    int USE_TSTRB = 1
) (
    `LOGIC_MODPORT(logic_axi4_stream_if, rx) rx,
    `LOGIC_MODPORT(logic_axi4_stream_if, tx) tx
);
    genvar k;

    logic [TDATA_BYTES-1:0] select;

    logic [TDATA_BYTES:0] tkeep;
    logic [TDATA_BYTES:0][7:0] tdata;

    always_comb tkeep[TDATA_BYTES] = '0;
    always_comb tdata[TDATA_BYTES] = '0;

    generate
        for (k = 0; k < TDATA_BYTES; ++k) begin: mapping
            always_comb tkeep[k] = rx.tkeep[k];
            always_comb tdata[k] = rx.tdata[k];

            always_comb select[k] = &rx.tkeep[k:0];

            always_comb tx.tkeep[k] = select[k] ? tkeep[k] : tkeep[k + 1];
            always_comb tx.tdata[k] = select[k] ? tdata[k] : tdata[k + 1];
        end
    endgenerate

    always_comb rx.tready = tx.tready;
    always_comb tx.tvalid = rx.tvalid;

    generate
        if (USE_TSTRB > 0) begin: tstrb_enabled
            logic [TDATA_BYTES:0] tstrb;

            always_comb tstrb[TDATA_BYTES] = '0;

            for (k = 0; k < TDATA_BYTES; ++k) begin: mapping
                always_comb tstrb[k] = rx.tstrb[k];
                always_comb tx.tstrb[k] = select[k] ? tstrb[k] : tstrb[k + 1];
            end
        end
        else begin: tstrb_disabled
            always_comb tx.tstrb = '1;
`ifdef VERILATOR
            logic _unused_port = &{1'b0, rx.tstrb, 1'b0};
`endif
        end

        if (USE_TLAST > 0) begin: tlast_enabled
            always_comb tx.tlast = rx.tlast;
        end
        else begin: tlast_disabled
            always_comb tx.tlast = '1;
`ifdef VERILATOR
            logic _unused_port = &{1'b0, rx.tlast, 1'b0};
`endif
        end

        if (TUSER_WIDTH > 0) begin: tuser_enabled
            always_comb tx.tuser = rx.tuser;
        end
        else begin: tuser_disabled
            always_comb tx.tuser = '0;
`ifdef VERILATOR
            logic _unused_port = &{1'b0, rx.tuser, 1'b0};
`endif
        end

        if (TDEST_WIDTH > 0) begin: tdest_enabled
            always_comb tx.tdest = rx.tdest;
        end
        else begin: tdest_disabled
            always_comb tx.tdest = '0;
`ifdef VERILATOR
            logic _unused_port = &{1'b0, rx.tdest, 1'b0};
`endif
        end

        if (TID_WIDTH > 0) begin: tid_enabled
            always_comb tx.tid = rx.tid;
        end
        else begin: tid_disabled
            always_comb tx.tid = '0;
`ifdef VERILATOR
            logic _unused_port = &{1'b0, rx.tid, 1'b0};
`endif
        end
    endgenerate
endmodule
