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

/* Module: logic_axi4_stream_pack_restore
 *
 * Count valid bytes.
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
 *  aclk        - Clock.
 *  areset_n    - Asynchronous active-low reset.
 *  keep_count  - Count of bytes keep.
 *  rx          - AXI4-Stream Rx interface.
 *  tx          - AXI4-Stream Tx interface.
 */
module logic_axi4_stream_pack_restore #(
    int TDATA_BYTES = 4,
    int TDEST_WIDTH = 1,
    int TUSER_WIDTH = 1,
    int TID_WIDTH = 1,
    int USE_TLAST = 1,
    int USE_TKEEP = 1,
    int USE_TSTRB = 1,
    int COUNT_WIDTH = (TDATA_BYTES >= 2) ? $clog2(TDATA_BYTES) : 1
) (
    input aclk,
    input areset_n,
    input [COUNT_WIDTH-1:0] keep_count,
    `LOGIC_MODPORT(logic_axi4_stream_if, rx) rx,
    `LOGIC_MODPORT(logic_axi4_stream_if, tx) tx
);
    logic [TDATA_BYTES-1:0] keep;

    always_comb rx.tready = tx.tready;

    always_comb keep = ~({TDATA_BYTES{1'b1}} << keep_count);

    always_ff @(posedge aclk or negedge areset_n) begin
        if (!areset_n) begin
            tx.tvalid <= '0;
        end
        else if (tx.tready) begin
            tx.tvalid <= rx.tvalid;
        end
    end

    always_ff @(posedge aclk) begin
        if (tx.tready) begin
            tx.tdata <= {rx.tdata, {TDATA_BYTES{8'b0}}};
            tx.tkeep[TDATA_BYTES+:TDATA_BYTES] <= rx.tkeep;

            tx.tkeep[0+:TDATA_BYTES] <= (tx.tlast && tx.tvalid) ?
                {TDATA_BYTES{1'b0}} : keep;
        end
    end

    generate
        if (USE_TSTRB > 0) begin: tstrb_enabled
            always_ff @(posedge aclk) begin
                if (tx.tready) begin
                    tx.tstrb <= {rx.tstrb, {TDATA_BYTES{1'b0}}};
                end
            end
        end
        else begin: tstrb_disabled
            always_comb tx.tstrb = '1;
`ifdef VERILATOR
            logic _unused_port = &{1'b0, rx.tstrb, 1'b0};
`endif
        end

        if (USE_TLAST > 0) begin: tlast_enabled
            always_ff @(posedge aclk) begin
                if (tx.tready) begin
                    tx.tlast <= rx.tlast;
                end
            end
        end
        else begin: tlast_disabled
            always_comb tx.tlast = '1;
`ifdef VERILATOR
            logic _unused_port = &{1'b0, rx.tlast, 1'b0};
`endif
        end

        if (TUSER_WIDTH > 0) begin: tuser_enabled
            always_ff @(posedge aclk) begin
                if (tx.tready) begin
                    tx.tuser <= rx.tuser;
                end
            end
        end
        else begin: tuser_disabled
            always_comb tx.tuser = '0;
`ifdef VERILATOR
            logic _unused_port = &{1'b0, rx.tuser, 1'b0};
`endif
        end

        if (TDEST_WIDTH > 0) begin: tdest_enabled
            always_ff @(posedge aclk) begin
                if (tx.tready) begin
                    tx.tdest <= rx.tdest;
                end
            end
        end
        else begin: tdest_disabled
            always_comb tx.tdest = '0;
`ifdef VERILATOR
            logic _unused_port = &{1'b0, rx.tdest, 1'b0};
`endif
        end

        if (TID_WIDTH > 0) begin: tid_enabled
            always_ff @(posedge aclk) begin
                if (tx.tready) begin
                    tx.tid <= rx.tid;
                end
            end
        end
        else begin: tid_disabled
            always_comb tx.tid = '0;
`ifdef VERILATOR
            logic _unused_port = &{1'b0, rx.tid, 1'b0};
`endif
        end
    endgenerate
endmodule
